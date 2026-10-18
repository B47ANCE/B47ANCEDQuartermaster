-- Server-owned ephemeral Sort bookkeeping. Native actions alone move inventory.
local Q=B47ANCEDQuartermaster
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local Policy=require 'B47ANCEDQuartermaster/LedgerPolicy'
local Options=require 'B47ANCEDQuartermaster/Migration'
local A=require 'B47ANCEDQuartermaster/ContentAnalysis'
local External=require 'B47ANCEDQuartermaster/ContainerSources'
local S={contexts=setmetatable({},{__mode='k'})};Q.SortLedger=S
function S.enabled() return Policy.enabled() and Options.option('SortUpdatesLedger')~=false end
function S.cleanup(actor)
 S.contexts[actor]=nil
 local op=Q.Movement and Q.Movement.operations[actor]
 if op and op.ledgerPickup then
  Q.Movement.handle(actor,'moveCancel',{operation=op.id,outcome=op.phase=='planned' and 'notSubmitted' or 'unknown'})
 end
end
local function scopeValid(actor,c)
 if not Scope.includes(c.scope,actor:getCurrentSquare()) then return false end
 local now=getTimestampMs()
 if c.scopeCheckedAt and now-c.scopeCheckedAt<1000 then return c.scopeChecked end
 local current=Scope.capture(actor,c.scope.kind)
 c.scopeCheckedAt=now;c.scopeChecked=current and Scope.signature(current)==c.signature or false
 return c.scopeChecked
end
local function inspect(actor,t)
 if t and t.external then return External.valid(t,actor,false) end
 return Q.Targets.valid(t,actor) and Q.RoomAccess.can(actor,t,'discover') and Q.RoomAccess.can(actor,t,'inspect')
end
local function entryValid(actor,c,r)
 if not scopeValid(actor,c) or not inspect(actor,r.target) or not Scope.includes(c.scope,r.target.obj:getSquare()) then return false end
 local d=Q.Targets.descriptor(r.target)
 for _,k in ipairs({'x','y','z','ci'}) do if r.position[k]~=d[k] then return false end end
 return r.target.obj:getModData().B47LedgerPhysical==r.physical
end
function S.valid(actor,c)
 return not isClient() and S.enabled() and c and S.contexts[actor]==c and not actor:isDead() and scopeValid(actor,c)
  and Media.writer(actor) and c.paper and Media.owned(actor,c.paper:getID(),Media.sheet)==c.paper
  and Q.Ledger.snapshotFor(c.paper)==c.base and (not c.base or c.base.revision==c.revision)
  and (c.base~=nil or Q.Ledger.unboundPaper(c.paper)) or false
end
function S.check(actor,sq)
 local c=S.contexts[actor]
 return c and c.ready and S.valid(actor,c) and Scope.includes(c.scope,sq) or false,'SortLedgerRequired'
end
-- Candidate ranking only. The caller checks the actor before its synchronous
-- planning slice; TAKE/PUT grants always use check(), never this lightweight hint.
function S.candidate(actor,sq)
 local c=S.contexts[actor]
 return not isClient() and c and c.ready and scopeValid(actor,c) and Scope.includes(c.scope,sq) or false
end
local function consider(actor,c,item,target)
 if item:getFullType()~=Media.sheet then return end
 local snapshot=Q.Ledger.snapshotFor(item)
 local carried=Media.owned(actor,item:getID(),Media.sheet)==item
 if snapshot and require('B47ANCEDQuartermaster/LedgerRequirement').covers(snapshot,c.origin) then
  if Policy.complete(snapshot) then
   if target and (not Q.RoomAccess.can(actor,target,'withdraw') or not Media.usable(item)) then return end
   local sq=target and target.obj:getSquare() or c.origin
   local distance=carried and -1 or (sq:getX()-actor:getX())^2+(sq:getY()-actor:getY())^2+100*(sq:getZ()-actor:getZ())^2
   if not c.best or distance<c.best.distance or distance==c.best.distance and item:getID()<c.best.item:getID() then c.best={item=item,target=target,distance=distance,snapshot=snapshot} end
  elseif carried and (not c.fallback or item:getID()<c.fallback:getID()) then c.fallback=item end
 elseif carried and Q.Ledger.unboundPaper(item) and (not c.fallback or item:getID()<c.fallback:getID()) then c.fallback=item end
end
local function inventory(actor,c,container,target,depth)
 if c.seen[container] then return true end;c.seen[container]=true
 if depth>16 then return false end
 local items=container:getItems();if items:size()>4096 then return false end
 -- Carried bags use exact native ownership; world bags use captured native paths.
 for n=0,items:size()-1 do
  c.examined=c.examined+1;if c.examined>65536 then return false end
  local item=items:get(n);consider(actor,c,item,target)
  if not target and instanceof(item,'InventoryContainer') and not inventory(actor,c,item:getInventory(),nil,depth+1) then return false end
 end
 return true
end
local function scan(actor,c)
 -- Each request/tick visits bounded world work. No forced chunk loads.
 local deadline=getTimestampMs()+2
 for _=1,512 do
  if getTimestampMs()>=deadline then return end
  if c.inventory then
   local v=c.inventory
   if not inspect(actor,v.target) or v.container~=v.target.container then c.error='LedgerChanged';return end
   local items=v.container:getItems()
   if items:size()~=v.size then c.error='LedgerChanged';return end
   if v.index>=v.size then c.inventory=table.remove(c.bags)
   else
    c.examined=c.examined+1;if c.examined>65536 then c.error='tooLarge';return end
    local item=items:get(v.index);consider(actor,c,item,v.target);v.index=v.index+1
    if instanceof(item,'InventoryContainer') and not c.seen[item:getInventory()] then
     local root=v.target.external and v.target.root or v.target
     local ids,refs={},{}
     if v.target.external then for n,id in ipairs(v.target.bags) do ids[n]=id;refs[n]=v.target.refs[n] end end
     if #ids>=16 then c.error='tooLarge';return end
     ids[#ids+1]=item:getID();refs[#refs+1]=item
     local t={external=true,obj=root.obj,ci=root.ci,container=item:getInventory(),root=root,bags=ids,refs=refs,square=root.obj:getSquare()}
     if inspect(actor,t) then
      c.seen[t.container]=true;local size=t.container:getItems():size();if size>4096 then c.error='tooLarge';return end
      c.bags[#c.bags+1]={container=t.container,target=t,index=0,size=size}
     end
    end
   end
  elseif c.objects then
   if c.oi>=c.objects:size() then c.objects=nil
   else
    local obj=c.objects:get(c.oi);local count=obj:getContainerCount() or 0
    if count>100 then c.error='tooLarge';return end
    if c.ci>=count then c.oi=c.oi+1;c.ci=0
    else
     local t=Q.Targets.make(obj,c.ci,actor);c.ci=c.ci+1
     if t and inspect(actor,t) and not c.seen[t.container] then
      c.seen[t.container]=true;local size=t.container:getItems():size()
      if size>4096 then c.error='tooLarge';return end
      c.inventory={container=t.container,target=t,index=0,size=size}
     end
    end
   end
  else
   local p=c.cursor.next();if not p then c.scanned=true;return end
   local sq=getCell():getGridSquare(p.x,p.y,p.z)
   if sq and Scope.includes(c.searchScope,sq) and not c.tiles[sq] then
    c.tiles[sq]=true
    if (not isServer() or SafeHouse and SafeHouse.isSafehouseAllowLoot(sq,actor))
     and Q.RoomAccess.can(actor,{obj={getSquare=function() return sq end}},'discover')
     and Q.RoomAccess.can(actor,{obj={getSquare=function() return sq end}},'inspect') then
     c.objects=sq:getObjects();c.oi=0;c.ci=0;if c.objects:size()>512 then c.error='tooLarge';return end
    end
   end
  end
 end
end
function S.pickupValid(actor,pickup)
 local c=S.contexts[actor];local t=pickup.target
 return c and c.pickup==pickup and Media.writer(actor) and scopeValid(actor,c) and inspect(actor,t)
  and Q.RoomAccess.can(actor,t,'withdraw') and t.container:getItemWithID(pickup.item:getID())==pickup.item
  and Q.Ledger.snapshotFor(pickup.item)==pickup.snapshot and Policy.complete(pickup.snapshot)
end
local function record(actor,c,target)
 if target and target.external and not target.root.part then target=target.root end
 if not target or target.ground or target.external or c.byContainer[target.container] then return end
 if not inspect(actor,target) or not Scope.includes(c.scope,target.obj:getSquare()) then c.error='LedgerChanged';return end
 if #c.records>=4096 then c.error='tooLarge';return end
 local key,position,physical=Q.Ledger.physical(target)
 if not key then c.error='failed';return end
 local r={key=key,position=position,physical=physical,target=target};c.byContainer[target.container]=r;c.records[#c.records+1]=r
end
function S.confirmPickup(actor,pickup)
 local c=S.contexts[actor]
 if c and c.pickup==pickup and Media.owned(actor,pickup.item:getID(),Media.sheet)==pickup.item then
  c.paper=pickup.item;c.pickup=nil;record(actor,c,pickup.target)
 end
end
function S.prepare(actor,args)
 if not S.enabled() then return {status='ready',disabled=true} end
 if select(2,Q.RoomAccess.service())=='unknown' then return {status='RoomPermissionUnavailable'} end
 if not Media.writer(actor) then return {status='SortWritingRequired'} end
 local c=S.contexts[actor]
 if not c then
  if Q.Movement.runs[actor] or Q.Movement.operations[actor] or Q.Ledger.jobs[actor] or Q.Ledger.actors[actor] then return {status='busy'} end
  local active=0;for _ in pairs(S.contexts) do active=active+1 end;if active>=16 then return {status='busy'} end
  local scope=Scope.capture(actor,'building') or Scope.capture(actor,'safehouse');local cursor=scope and Scope.cursor(scope)
  if not cursor then return {status='LedgerScopeUnavailable'} end
  c={scope=scope,searchScope=scope,signature=Scope.signature(scope),origin=actor:getCurrentSquare(),cursor=cursor,seen={},tiles={},bags={},examined=0,records={},byContainer={},done={},time=getTimestampMs()}
  S.contexts[actor]=c
  if not inventory(actor,c,actor:getInventory(),nil,0) then c.error='tooLarge' end
 end
 c.time=getTimestampMs()
 if not scopeValid(actor,c) then return {status='LedgerScopeChanged'} end
 if c.error then return {status=c.error} end
 if not c.scanned then scan(actor,c);if c.error then return {status=c.error} end;if not c.scanned then return {status='waiting'} end end
 if not c.paper and not c.pickup then
  c.paper=c.best and c.best.item or c.fallback
  if not c.paper then return {status='SortLedgerRequired'} end
  c.base=Q.Ledger.snapshotFor(c.paper);c.revision=c.base and c.base.revision
  if c.base then
   local scope=Scope.capture(actor,c.base.scope.kind)
   if not scope or Scope.signature(scope)~=c.base.signature then return {status='LedgerScopeChanged'} end
   c.scope=scope;c.signature=c.base.signature;c.scopeCheckedAt=nil
  end
  if Media.owned(actor,c.paper:getID(),Media.sheet)~=c.paper then
   local t=c.best.target;c.pickup={kind='ledgerPickup',item=c.paper,target=t,snapshot=c.base};c.paper=nil
  end
 end
 if c.pickup then
  if Q.Movement.operations[actor] then return {status='waiting'} end
  local p=c.pickup
  if not S.pickupValid(actor,p) then return {status='LedgerChanged'} end
  local offer,op=Q.Movement.withdraw(actor,{target=p.target,position=Q.Targets.descriptor(p.target)},0,p)
  if not op then return offer end
  Q.Movement.operations[actor]=op;return {status='pickup',offer=offer}
 end
 if not S.valid(actor,c) then return {status='SortLedgerRequired'} end
 c.ready=true;return {status='ready'}
end
function S.started(actor,run)
 if not S.enabled() then return true end
 local c=S.contexts[actor];if not S.valid(actor,c) or not c.ready or c.sealed then return false end
 if c.session and (c.session~=run.session or c.sweep~=run.sweep) then return false end
 c.session=run.session;c.sweep=run.sweep
 local session=Q.Bindings.session(actor,run.session);if not session then return false end
 c.expected=c.expected or (run.area and session.areaSources or {[run.source]=true})
 c.run=run.id;run.sortLedger=c;return true
end
function S.observed(actor,op,target)
 local run=Q.Movement.runs[actor];local c=run and run.sortLedger
 if c and c==S.contexts[actor] then record(actor,c,target) end
end
function S.finished(actor,run)
 local c=run.sortLedger
 if c and c==S.contexts[actor] then c.done[run.source]=true;c.run=nil;c.time=getTimestampMs() end
end
function S.next(actor)
 if not S.enabled() then return {status='done',summary='SortLedgerSkipped'} end
 local c=S.contexts[actor]
 if not S.valid(actor,c) then return {status='SortLedgerRequired'} end
 if c.error then return {status=c.error} end
 if Q.Movement.runs[actor] or Q.Movement.operations[actor] or c.run or not c.expected then return {status='busy'} end
 for source in pairs(c.expected) do if not c.done[source] then return {status='invalid'} end end
 if #c.records==0 then S.cleanup(actor);return {status='done',summary='SortLedgerUnchanged'} end
 c.time=getTimestampMs();c.sealed=true;c.index=c.index or 1
 local r=c.records[c.index]
 if r then
  if not entryValid(actor,c,r) then return {status='LedgerChanged'} end
  if not r.analysis then r.analysis=A.begin(r.target.container,actor,function() return S.valid(actor,c) and entryValid(actor,c,r) end) end
  if not r.analysis then return {status='LedgerChanged'} end
  local _,status=r.analysis.step()
  if status=='waiting' then return {status='waiting'} end
  if status~='done' then return {status='LedgerChanged'} end
  r.rows=Q.Ledger.prepareRows(r);if not r.rows then return {status='LedgerChanged'} end
  c.index=c.index+1;return {status='waiting'}
 end
 return Q.Ledger.sortGrant(actor,c)
end
function S.writeValid(actor,c)
 if not S.valid(actor,c) or not c.sealed then return false end
 for _,r in ipairs(c.records) do if not entryValid(actor,c,r) then return false end end
 return true
end
function S.tick()
 if isClient() then return end
 local now=getTimestampMs();local deadline=now+4
 for actor,c in pairs(S.contexts) do
  if actor:isDead() or not S.enabled() or now-c.time>=1800000 then S.cleanup(actor)
  elseif not c.scanned and not c.error then
   scan(actor,c)
  end
  if getTimestampMs()>=deadline then break end
 end
end
return S
