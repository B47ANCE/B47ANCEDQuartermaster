-- Knowledge is additional eligibility, never a substitute for native permissions.
local G={};B47ANCEDQuartermaster.LedgerRequirement=G
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local Options=require 'B47ANCEDQuartermaster/Migration'
local Drives=require 'B47ANCEDQuartermaster/LedgerDrives'
local papers=setmetatable({},{__mode='k'});local buildings=setmetatable({},{__mode='k'})
local function at(sq,kind) return Scope.capture({getCurrentSquare=function() return sq end},kind) end
function G.enabled(kind)
 return Options.option(kind=='shopping' and 'RequireLedgerForCollecting' or 'RequireLedgerForSorting')~=false
end
local function complete(item)
 local s=require('B47ANCEDQuartermaster/Ledger').snapshotFor(item)
 return s and s.complete==true and s.status=='LedgerComplete' and s or nil
end
local function building(sq)
 local b=sq and sq:getBuilding();local def=b and b:getDef()
 if not def then return end
 -- Bound map-classification reuse to one second, including native room changes.
 -- Never cache player permission, power, item presence or media bindings.
 local c=buildings[def]
 if not c or getTimestampMs()-c.at>=1000 then
  local scope=at(sq,'building');c=scope and {key=scope.key,signature=Scope.signature(scope),at=getTimestampMs()} or nil;buildings[def]=c
 end
 return c
end
function G.covers(s,sq)
 if not sq or not s then return false end
 if s.scope.kind=='building' then local b=building(sq);return b and b.signature==s.signature or false end
 if s.scope.kind=='safehouse' then local scope=at(sq,'safehouse');return scope and Scope.signature(scope)==s.signature or false end
 return false
end
local function carried(actor)
 local c=papers[actor];local now=getTimestampMs()
 if c and now-c.at<1000 then return c.items end
 c={at=now,items={}};papers[actor]=c;local visited={};local count=0
 local function scan(container,depth)
  if not container or visited[container] or depth>16 then return end;visited[container]=true
  local items=container:getItems()
  for n=0,items:size()-1 do
   count=count+1;if count>4096 then c.tooLarge=true;return end
   local item=items:get(n)
   if item:getFullType()==Media.sheet then c.items[#c.items+1]=item end
   if instanceof(item,'InventoryContainer') then scan(item:getInventory(),depth+1) end
   if c.tooLarge then return end
  end
 end
 scan(actor:getInventory(),0)
 if c.tooLarge then c.items={} end -- fail closed, never silently authorize a truncated scan
 return c.items
end
function G.check(actor,sq,kind)
 if isClient() then return false,'LedgerRequired' end
 if not G.enabled(kind) then return true end
 if not actor or actor:isDead() or not sq then return false,'LedgerRequired' end
 for _,paper in ipairs(carried(actor)) do
  if Media.owned(actor,paper:getID(),Media.sheet)==paper and G.covers(complete(paper),sq) then return true end
 end
 local range=Options.option('LedgerComputerRange')
 if type(range)~='number' or range~=range or range%1~=0 or range<1 or range>30 then range=10 end
 local b=building(sq);local ids=Drives.candidates(b and b.key,sq,range)
 if not ids then return false,'LedgerRequired' end
 for _,id in ipairs(ids) do
  local disc,s,computer=Drives.provider(actor,id)
  if disc and s.complete==true and s.status=='LedgerComplete' and G.covers(s,sq) then
   local cs=computer:getSquare();local cb=building(cs)
   if b and cb and b.key==cb.key or cs:getZ()==sq:getZ() and math.max(math.abs(cs:getX()-sq:getX()),math.abs(cs:getY()-sq:getY()))<=range then return true end
  end
 end
 return false,'LedgerRequired'
end
function G.operation(actor,op)
 local kind=op.withdrawal and 'shopping' or 'sort'
 if not G.enabled(kind) then return true end
 local ok,why=G.check(actor,actor:getCurrentSquare(),kind);if not ok then return false,why end
 if op.source and op.source.obj then ok,why=G.check(actor,op.source.obj:getSquare(),kind);if not ok then return false,why end end
 if op.destination then return G.check(actor,op.destination.obj:getSquare(),kind) end
 return true
end
function G.protected(actor,item)
 if isClient() or not G.enabled('sort') and not G.enabled('shopping') then return false end
 if item:getFullType()==Media.sheet and Media.owned(actor,item:getID(),Media.sheet)==item and complete(item) then return true end
 return item:getFullType()==Media.disc and Drives.protected(item) or false
end
return G
