-- OFFLINE DOMAIN PROTOTYPE. Not a registered gameplay service or native adapter.
-- The trusted port must establish native sender/time/conversion boundaries first.
local M={}
local function copy(value)
 if type(value)~='table' then return value end
 local out={};for k,v in pairs(value) do out[k]=copy(v) end;return out
end
local function integer(n) return type(n)=='number' and n==n and n%1==0 and n>=0 and n<1000000 end
function M.new(store,port)
 if store.schema==nil and next(store)==nil then store.schema=1;store.serial=0;store.snapshots={};store.bindings={};store.burns={} end
 if store.schema~=1 or type(store.snapshots)~='table' or type(store.bindings)~='table' or type(store.burns)~='table' then return nil,'schema' end
 local api={};local offers={};local serial=0
 function api.begin(actor,paper)
  if not port.server() or not port.owns(actor,paper) then return nil,'denied' end
  local scope=port.scope(actor);if not scope then return nil,'scope' end
  local old=store.bindings[port.id(paper)]
  if old then return copy(old),'resume' end
  store.serial=store.serial+1;local id='ledger:'..store.serial
  store.snapshots[id]={schema=1,id=id,scope=copy(scope),revision=0,entries={},expected={},discovered=false,status='incomplete',began=port.now()}
  store.bindings[port.id(paper)]={snapshot=id,kind='paper'}
  return copy(store.bindings[port.id(paper)]),'ok'
 end
 local function owned(actor,paper,revision)
  if not port.server() or not port.owns(actor,paper) then return end
  local b=store.bindings[port.id(paper)];local s=b and store.snapshots[b.snapshot]
  if not s or b.kind~='paper' or revision~=s.revision or not port.scopeValid(actor,s.scope) then return end
  return s
 end
 function api.discovered(actor,paper,revision,targets,receipt)
  local s=owned(actor,paper,revision)
  if not s or not port.discoveryReceipt(actor,s.scope,targets,receipt) then return nil,'denied' end
  if #targets>4096 then return nil,'tooLarge' end
  local seen={};for _,id in ipairs(targets) do if type(id)~='string' or seen[id] then return nil,'invalid' end;seen[id]=true end
  s.expected=seen;s.discovered=true;s.revision=s.revision+1;return s.revision,'ok'
 end
 function api.prepare(actor,paper,revision,target)
  local s=owned(actor,paper,revision)
  if not s or not port.canInspect(actor,target,s.scope) then return nil,'denied' end
  local rows=port.inspect(actor,target);if not rows or #rows>4096 then return nil,'unavailable' end
  local options=port.timing();if not integer(options.base) or not integer(options.container) or options.container<1 or options.container>15
   or not integer(options.entry) or options.entry<1 or options.entry>5 then return nil,'settings' end
  serial=serial+1;local token='inspection:'..serial
  local offer={token=token,actor=actor,paper=paper,snapshot=s.id,revision=s.revision,target=target,rows=copy(rows),
   seconds=(not s.baseCharged and options.base or 0)+options.container+#rows*options.entry}
  offers[token]=offer
  return {token=token,seconds=offer.seconds,target=target},'ok'
 end
 function api.complete(actor,paper,token,receipt)
  local offer=offers[token]
  if not offer or offer.actor~=actor or offer.paper~=paper then return nil,'denied' end
  local s=owned(actor,paper,offer.revision)
  if not s or s.id~=offer.snapshot or not port.inspectionReceipt(actor,offer,receipt)
   or not port.canInspect(actor,offer.target,s.scope) then return nil,'denied' end
  if not port.sameContents(actor,offer.target,offer.rows) then offers[token]=nil;return nil,'reinspect' end
  offers[token]=nil;s.baseCharged=true
  s.entries[offer.target]={target=offer.target,rows=copy(offer.rows),recorded=port.now()}
  s.revision=s.revision+1;s.status='incomplete'
  if s.discovered then
   local complete=true;for id in pairs(s.expected) do if not s.entries[id] then complete=false end end
   if complete then s.status='complete' end
  end
  return s.revision,'ok'
 end
 function api.view(actor,item,digital,query,page)
  if not port.server() or not port.owns(actor,item) then return nil,'denied' end
  local binding=store.bindings[port.id(item)];local s=binding and store.snapshots[binding.snapshot]
  if not s then return nil,'unavailable' end
  if digital and (binding.kind~='disc' or not port.poweredComputer(actor)) then return nil,'powerOrMedia' end
  if not digital and (binding.kind~='paper' or query and query~='') then return nil,'paperHasNoSearch' end
  page=page or 1;if not integer(page) or page<1 then return nil,'invalid' end
  query=(query or ''):lower();if #query>128 then return nil,'invalid' end
  local out={status=s.status,recorded=s.began,revision=s.revision,rows={},permissionLimited=false}
  local rows={};local targets={};for id in pairs(s.entries) do targets[#targets+1]=id end;table.sort(targets)
  for _,id in ipairs(targets) do
   local e=s.entries[id]
   if port.canView(actor,s.scope,id) then
    for _,r in ipairs(e.rows) do
     if query=='' or r.name:lower():find(query,1,true) or r.fullType:lower():find(query,1,true) then
      rows[#rows+1]={target=id,recorded=e.recorded,item=copy(r)}
     end
    end
   else out.permissionLimited=true end
  end
  out.total=#rows
  for n=(page-1)*64+1,math.min(#rows,page*64) do out.rows[#out.rows+1]=rows[n] end
  return out,'ok'
 end
 function api.burn(actor,paper,disc,key,receipt)
  if not port.server() or not port.owns(actor,paper) or not port.owns(actor,disc) or not port.compatibleCD(disc)
   or not port.poweredComputer(actor) then return nil,'denied' end
  local binding=store.bindings[port.id(paper)];local s=binding and store.snapshots[binding.snapshot]
  if not s or binding.kind~='paper' or s.status~='complete' then return nil,'incomplete' end
  if not port.burnReceipt(actor,paper,disc,s,receipt) then return nil,'receipt' end
  if type(key)~='string' or #key>96 then return nil,'invalid' end
  if store.burns[key] then return nil,'replayOrUnknownOutcome' end
  for _,burn in pairs(store.burns) do if burn.input==port.id(disc) then return nil,'discLocked' end end
  if not port.atomicConversionVerified then return nil,'nativeConversionUnverified' end
  store.burns[key]={status='prepared',input=port.id(disc),snapshot=s.id}
  local ok,result=pcall(port.convert,actor,paper,disc,s,receipt)
  if not ok or not result then store.burns[key].status='outcomeUnknown';return nil,'outcomeUnknown' end
  store.bindings[port.id(result)]={snapshot=s.id,kind='disc'};store.burns[key].status='committed'
  return result,'ok'
 end
 return api
end
return M
