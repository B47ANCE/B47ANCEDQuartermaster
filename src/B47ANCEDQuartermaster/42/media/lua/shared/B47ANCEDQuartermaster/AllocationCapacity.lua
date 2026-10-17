-- Shared pure capacity arithmetic for physical and room scopes. The caller
-- supplies native snapshots/permissions, never client-reported weights.
local A=require 'B47ANCEDQuartermaster/AllocationProfile'
local C={};B47ANCEDQuartermaster.AllocationCapacity=C
local function number(n) return type(n)=='number' and n==n and n>=0 and n<1e12 end
function C.empty() return {capacity=0,used=0,categories={},items={},refs={},containers={},count=0} end
local function add(scope,row)
 if not number(row.weight) or not A.fullType(row.fullType) or type(row.path)~='table' then return nil,'AllocationIdentityUnavailable' end
 local ref=row.ref or row
 if scope.refs[ref] then return true end
 scope.refs[ref]=true;scope.items[row.fullType]=(scope.items[row.fullType] or 0)+row.weight
 local seen={};for _,category in ipairs(row.path) do if not seen[category] then
  seen[category]=true;scope.categories[category]=(scope.categories[category] or 0)+row.weight
 end end
 return true
end
C.add=add
function C.measure(compartments)
 local scope=C.empty()
 for _,part in ipairs(compartments) do if not scope.containers[part.container] then
  if not part.container or not number(part.capacity) or not number(part.used) or #part.items>4096 then return nil,'AllocationCapacityUnavailable' end
  scope.containers[part.container]=true;scope.capacity=scope.capacity+part.capacity;scope.used=scope.used+part.used;scope.count=scope.count+1
  for _,row in ipairs(part.items) do local ok,e=add(scope,row);if not ok then return nil,e end end
 end end
 return scope
end
function C.project(scope,pending,incoming)
 -- Local overlays avoid copying thousands of native refs/maps per admission.
 local out={capacity=scope.capacity,used=scope.used,categories=setmetatable({},{__index=scope.categories}),items=setmetatable({},{__index=scope.items}),refs={},containers=scope.containers,count=scope.count}
 local physical={};local destinations=scope.reservationContainers or scope.containers
 local function actual(ref) return scope.refs[ref] or scope.hasRef and scope.hasRef(ref) end
 local function physicalActual(ref) return scope.physicalHasRef and scope.physicalHasRef(ref) or not scope.physicalHasRef and actual(ref) end
 out.hasRef=function(ref) return out.refs[ref] or actual(ref) end
 local function include(row)
  if not row or row.cancelled or not destinations[row.destination] then return true end
  local ref=row.ref or row
  if not out.hasRef(ref) then local ok,e=add(out,row);if not ok then return nil,e end end
  if scope.containers[row.destination] and not physical[ref] and not physicalActual(ref) then out.used=out.used+row.weight;physical[ref]=true end
  return true
 end
 for _,row in ipairs(pending or {}) do local ok,e=include(row);if not ok then return nil,e end end
 local ok,e=include(incoming);if not ok then return nil,e end
 return out
end
function C.combine(parts,expired)
 local scope=C.empty();scope.parts={};local work=0
 for _,part in ipairs(parts) do if not scope.containers[part.container] then
  scope.containers[part.container]=true;scope.parts[#scope.parts+1]=part
  scope.capacity=scope.capacity+part.scope.capacity;scope.used=scope.used+part.scope.used;scope.count=scope.count+1
  for _,kind in ipairs({'categories','items'}) do for key,value in pairs(part.scope[kind]) do
   scope[kind][key]=(scope[kind][key] or 0)+value;work=work+1
   if work%64==0 and expired and expired() then return nil,'AllocationSnapshotBudget' end
  end end
 end end
 scope.hasRef=function(ref) for _,part in ipairs(scope.parts) do if part.scope.refs[ref] then return true end end;return false end
 return scope
end
function C.check(profile,scope,pending,incoming)
 -- Legacy/no-profile destinations have no extra quota. They still pass the
 -- same physical-capacity projection and the caller's native access checks.
 if profile~=nil and not A.valid(profile) or not incoming or not number(incoming.weight) or not A.fullType(incoming.fullType) then return nil,'AllocationCapacityUnavailable' end
 local projected,e=C.project(scope,pending,incoming);if not projected then return nil,e end
 if projected.capacity<=0 or projected.used>projected.capacity and projected.used>scope.used then return false,'AllocationPhysicalCapacity',projected end
 for _,ceiling in ipairs(A.ceilings(profile,incoming.fullType,incoming.path)) do
  -- Quotas never round a ceiling upwards. Native hasRoomFor (including native
  -- two-decimal correction/special restrictions) is checked independently.
  local limit=scope.capacity*ceiling.percent/100
  local used=projected[ceiling.kind=='category' and 'categories' or 'items'][ceiling.key] or 0
  local existing=scope[ceiling.kind=='category' and 'categories' or 'items'][ceiling.key] or 0
  if ceiling.percent==0 or used>limit and used>existing then return false,'AllocationQuotaExceeded',projected,ceiling end
 end
 return true,nil,projected
end
function C.rolePreference(groups,primaryAt,secondaryAt)
 local p,s=groups.primary,groups.secondary
 local hasP=p and p.capacity>0;local hasS=s and s.capacity>0
 if not hasP then return hasS and 'secondary' or 'unassigned' end
 if not hasS then return 'primary' end
 if s.used*100>=s.capacity*secondaryAt then return 'primary' end
 if p.used*100>=p.capacity*primaryAt then return 'secondary' end
 return 'primary'
end
-- Ephemeral, server-owned admission ledger; no client locks, quantities or
-- deadlines are accepted. Reconciliation omits refs already in native snapshots.
function C.ledger(now)
 local l={entries={},count=0}
 function l:expire()
  local time=now();for key,row in pairs(self.entries) do if row.expires<=time then self.entries[key]=nil;self.count=self.count-1 end end
 end
 function l:pending()
  self:expire();local rows={};for _,row in pairs(self.entries) do rows[#rows+1]=row end;return rows
 end
 function l:release(key)
  if self.entries[key] then self.entries[key]=nil;self.count=self.count-1 end
 end
 function l:reserve(key,row,profile,scope)
  self:expire()
  if type(row)~='table' or not row.ref or type(row.path)~='table' or #row.path>16 or not number(row.weight) or not A.fullType(row.fullType) then return nil,'AllocationIdentityUnavailable' end
  if self.entries[key] then
   local old=self.entries[key];local same=#old.path==#row.path
   for n,value in ipairs(old.path) do if row.path[n]~=value then same=false end end
   return same and old.ref==row.ref and old.destination==row.destination and old.fullType==row.fullType and old.weight==row.weight,'AllocationReservationConflict'
  end
  if self.count>=1024 or not row.ref then return nil,'AllocationReservationLimit' end
  for _,old in pairs(self.entries) do if old.ref==row.ref then return false,'AllocationReservationConflict' end end
  local ok,e=C.check(profile,scope,self:pending(),row);if not ok then return ok,e end
  local stored={};for k,v in pairs(row) do stored[k]=v end;stored.path={};for n,category in ipairs(row.path) do stored.path[n]=category end;stored.expires=now()+1800000
  self.entries[key]=stored;self.count=self.count+1;return true
 end
 return l
end
return C
