-- Actual production service, native-shaped transfers and native action lifecycle.
dofile(TEST_ROOT..'/test_ledger.lua')
local F,f=LEDGER_FIXTURE,CONTAINER_FIXTURE
local Q=B47ANCEDQuartermaster;local actor=f.player;local L=Q.Ledger
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local S=require 'B47ANCEDQuartermaster/SortLedger'
local G=require 'B47ANCEDQuartermaster/LedgerRequirement'
local C=require 'B47ANCEDQuartermaster/LedgerAction'
local data=ModData.getOrCreate('B47ANCEDQuartermasterLedger');data.schema=1
local opts=SandboxVars.B47ANCEDQuartermaster;opts.SortUpdatesLedger=nil
local Protocol=require 'B47ANCEDQuartermaster/Protocol'
assert(Protocol.version('ledgerSortPrepare')==5 and not Protocol.accepts('ledgerSortPrepare',{protocol=4}))
assert(Protocol.version('moveTake')==12 and not Protocol.accepts('moveTake',{protocol=11}))
CharacterActionAnims={Read='Read'};actor.reportEvent=function() end
local function nativeAction() return {setActionAnim=function(self,value) self.anim=value end,setAnimVariable=function() end,setOverrideHandModelsObject=function() end} end
actor.square=f.a:getSquare();actor.getMaxWeight=function() return 100 end
actor.getWornItems=function() return f.list() end
actor.getPrimaryHandItem=function() end;actor.getSecondaryHandItem=function() end
local function clearPapers()
 for n=#F.inv.items,1,-1 do if F.inv.items[n]:getFullType()==Media.sheet then F.inv:Remove(F.inv.items[n]) end end
end
clearPapers();F.inv:AddItem(F.paper);F.run(F.paper);actor.square=f.a:getSquare()
local original=L.snapshotFor(F.paper);assert(original.complete)
local cd=F.inv:AddItem(F.item('Base.Disc_Retail'))
local burn=L.handle(actor,'ledgerBurn',{item=F.paper:getID(),cd=cd:getID(),computer=F.position});assert(burn.status=='action',burn.status)
local burnAction=assert(C:new(actor,burn.token));burnAction.action={setActionAnim=function() end};burnAction:start();assert(burnAction:complete())
local originalID=original.id;local oldFinished=original.finished
local bag=F.item('Base.Bag_Duffel');bag.class='InventoryContainer';local bagInventory=F.container();bag.getInventory=function() return bagInventory end
f.b.containers[1]:AddItem(bag);F.inv:Remove(F.paper);bagInventory:AddItem(F.paper)
local blank=F.inv:AddItem(F.item(Media.sheet))
assert(S.enabled() and not G.check(actor,actor.square,'sort'),'default workflow was bypassed')
local function prepare()
 for _=1,100 do local r=L.handle(actor,'ledgerSortPrepare',{});if r.status~='waiting' then return r end end
 error('bounded search did not finish')
end
local offer=prepare();assert(offer.status=='pickup',offer.status)
assert(offer.offer.source.external and bagInventory:getItemWithID(F.paper:getID())==F.paper,'nested paper was not resolved or preparation directly moved it')
assert(Q.Movement.handle(actor,'moveTake',{operation=offer.offer.operation}).status=='ok')
bagInventory:Remove(F.paper);F.inv:AddItem(F.paper) -- native transfer result
assert(Q.Movement.handle(actor,'moveCarried',{operation=offer.offer.operation}).status=='ok')
assert(prepare().status=='ready' and S.contexts[actor].paper==F.paper,'blank paper won over completed building ledger')
assert(G.check(actor,actor.square,'sort'))
assert(not Q.Movement.eligible(actor,F.paper),'sort removed its own ledger')
local pen
for _,item in ipairs(F.inv.items) do if item:getFullType()=='Base.Pen' then pen=item end end
assert(pen and not Q.Movement.eligible(actor,pen),'sort removed its writing tool')
F.inv:Remove(pen);assert(not G.check(actor,actor.square,'sort'));F.inv:AddItem(pen)
-- Plan and confirm a real storage-to-storage operation through Trips/Movement.
f.a.containers[1].items={};f.b.containers[1].items={}
local round=F.item('Fixture.RoundA','RoundA');round.getScriptItem=function() return CATALOG_FIXTURE.items[1] end
f.a.containers[1]:AddItem(round)
local d=assert(Q.Bindings.discover(actor,{scope={x=0,y=0,z=0}}));local records={}
for _,record in pairs(Q.Bindings.sessions[actor].records) do records[record.target.obj]=record end
local dest=records[f.b];dest.original=Q.Schema.empty();dest.revision=0
local config=Q.Schema.empty();config.items.RoundA=true;assert(Q.Store.commit(dest,config))
local begin=Q.Trips.handle(actor,'tripBegin',{session=d.session,source=records[f.a].token});assert(begin.status=='ok',begin.status)
assert(S.next(actor).status=='busy','writing allowed during a live trip')
local run=Q.Movement.runs[actor]
local plan,op=Q.Movement.planOne(actor,{session=d.session,source=records[f.a].token,itemID=round:getID()})
assert(plan.status=='ok',plan.status);run.operations[op.id]=op;run.considered[round:getID()]=true
local function move(command) return Q.Movement.handle(actor,command,{operation=op.id}) end
assert(move('moveTake').status=='ok');assert(move('moveCarried').status=='waiting')
assert(#S.contexts[actor].records==1,'unconfirmed native TAKE credited') -- confirmed ledger pickup source only
f.a.containers[1]:Remove(round);F.inv:AddItem(round)
assert(move('moveCarried').status=='ok')
F.inv:Remove(pen);assert(move('movePut').status=='SortLedgerRequired','candidate hint authorized a transfer without supplies');F.inv:AddItem(pen)
assert(move('movePut').status=='ok')
assert(move('moveDone').status=='waiting' and #S.contexts[actor].records==2,'unconfirmed native PUT credited')
F.inv:Remove(round);f.b.containers[1]:AddItem(round);assert(move('moveDone').status=='ok')
assert(L.snapshotFor(F.paper)==original,'ledger changed before whole job finished')
local ended
for _=1,100 do ended=Q.Trips.handle(actor,'tripNext',{run=run.id});if ended.status~='waiting' then break end end
assert(ended.status=='done',ended.status)
local function writing()
 for _=1,300 do local r=L.handle(actor,'ledgerSortNext',{});if r.status~='waiting' then return r end end
 error('write preparation did not finish')
end
local write=writing();assert(write.status=='action' and write.kind=='sortWrite',write.status)
assert(L.snapshotFor(F.paper)==original,'write offer changed the snapshot')
local action=assert(C:new(actor,write.token));action.action=nativeAction();action:start()
assert(action.action.anim=='Read','writing did not use the native paper pose')
assert(action:complete());assert(not action:complete(),'write completion replay accepted')
local updated=L.snapshotFor(F.paper)
assert(updated.id~=originalID and updated.finished==oldFinished and updated.complete,'unvisited data was made fresh or completion was lost')
assert(data.snapshots[originalID]==original,'original CD generation overwritten')
local quantities={};for _,e in pairs(updated.entries) do for _,r in ipairs(e.rows) do quantities[r.fullType]=(quantities[r.fullType] or 0)+r.quantity end end
assert(quantities['Fixture.RoundA']==1 and #updated.order==#original.order,'confirmed quantities/locations wrong')
assert(f.b.containers[1]:getItemWithID(round:getID())==round,'writing changed physical inventory')
assert(S.next(actor).status=='SortLedgerRequired','completed context replay accepted')
-- No completed accessible ledger: a carried blank is valid and stays partial.
L.cleanup(actor);clearPapers();F.inv:AddItem(blank);f.advance(1100)
assert(prepare().status=='ready' and S.contexts[actor].paper==blank)
local c=S.contexts[actor];c.expected={inventory=true};c.done.inventory=true
local fakeRun={sortLedger=c};Q.Movement.runs[actor]=fakeRun
S.observed(actor,{},records[f.b].target);Q.Movement.runs[actor]=nil
write=writing();assert(write.status=='action')
action=assert(C:new(actor,write.token));action.action=nativeAction();action:start();assert(action:complete())
assert(L.snapshotFor(blank).status=='LedgerPartial' and not L.snapshotFor(blank).complete and L.snapshotFor(blank).finished==nil,'partial ledger claimed a complete building inspection')
-- Early/forged writes, cancellation, changed inventory and opt-outs fail safely.
L.cleanup(actor);assert(prepare().status=='ready');c=S.contexts[actor]
c.expected={inventory=true};assert(S.next(actor).status=='invalid','unfinished source allowed a write')
c.done.inventory=true;Q.Movement.runs[actor]={sortLedger=c};S.observed(actor,{},records[f.b].target);Q.Movement.runs[actor]=nil
write=writing();assert(write.status=='action')
local before=L.snapshotFor(blank);action=assert(C:new(actor,write.token));action.action=nativeAction();action:start()
F.inv:Remove(pen);assert(not action:complete() and L.snapshotFor(blank)==before,'tool loss wrote data');F.inv:AddItem(pen)
L.cleanup(actor);assert(prepare().status=='ready');c=S.contexts[actor];c.expected={inventory=true};c.done.inventory=true
Q.Movement.runs[actor]={sortLedger=c};S.observed(actor,{},records[f.b].target);Q.Movement.runs[actor]=nil
write=writing();action=assert(C:new(actor,write.token));action.action=nativeAction();action:start()
f.b.containers[1]:AddItem(F.item('Fixture.Concurrent'))
assert(not action:complete() and L.snapshotFor(blank)==before,'concurrent change wrote a stale analysis')
-- A genuine two-source area sweep may write only after BOTH server trips end.
L.cleanup(actor);assert(prepare().status=='ready')
local src=records[f.a];src.original=Q.Schema.empty();src.revision=0;assert(Q.Store.commit(src,config))
local session=Q.Bindings.sessions[actor];session.areaSweep='actual-area-sweep';session.areaSeen={}
session.areaSources={inventory=true,[src.token]=true}
for _,item in ipairs(F.inv.items) do if not item.getScriptItem then item.getScriptItem=function() end end end
local extra=F.inv:AddItem(F.item('Fixture.RoundA','RoundA'));extra.getScriptItem=function() return CATALOG_FIXTURE.items[1] end
local function areaSource(source)
 local b=Q.Trips.handle(actor,'tripBegin',{session=d.session,source=source,area=true,sweep=session.areaSweep});assert(b.status=='ok',b.status)
 for _=1,300 do
  local next=Q.Trips.handle(actor,'tripNext',{run=b.run})
  if next.status=='done' then return end
  assert(next.status=='ok' or next.status=='waiting',next.status)
  for _,offer in ipairs(next.offers or {}) do
   local operation=Q.Movement.runs[actor].operations[offer.operation]
   assert(operation.phase=='carried','fixture expected inventory deposit')
   assert(Q.Movement.handle(actor,'movePut',{operation=operation.id}).status=='ok')
   F.inv:Remove(operation.item);operation.destination.container:AddItem(operation.item)
   assert(Q.Movement.handle(actor,'moveDone',{operation=operation.id}).status=='ok')
  end
 end
 error('area source did not finish')
end
local generation=L.snapshotFor(blank).id;local count=data.count
areaSource('inventory');assert(S.next(actor).status=='invalid','area wrote between source containers')
areaSource(src.token);write=writing();assert(write.status=='action')
action=assert(C:new(actor,write.token));action.action=nativeAction();action:start();assert(action:complete())
assert(L.snapshotFor(blank).id==generation and data.count==count,'unshared paper allocated a snapshot on every Sort')
-- Private completed ledgers do not block a permitted carried fallback or leak offers.
F.inv:AddItem(F.paper);F.inv:Remove(F.paper);f.b.containers[1]:AddItem(F.paper)
local access=Q.RoomAccess.can
Q.RoomAccess.can=function(a,t,kind) if t.obj==f.b and (kind=='inspect' or kind=='withdraw') then return false end;return access(a,t,kind) end
L.cleanup(actor);assert(prepare().status=='ready' and S.contexts[actor].paper==blank,'private completed ledger was selected')
Q.RoomAccess.can=access
-- Discovery can span requests while a carried fallback is removed.
L.cleanup(actor);clearPapers();F.inv:AddItem(blank)
Q.RoomAccess.can=function(a,t,kind) if t.obj==f.b then return false end;return access(a,t,kind) end
local clock=getTimestampMs;local time=clock()
getTimestampMs=function() time=time+2;return time end
assert(S.prepare(actor,{}).status=='waiting' and S.contexts[actor].fallback==blank)
getTimestampMs=clock;F.inv:Remove(blank)
local lost=prepare();assert(lost.status=='SortLedgerRequired','lost carried fallback became a pickup')
Q.RoomAccess.can=access;F.inv:AddItem(blank)
L.cleanup(actor);opts.SortUpdatesLedger=false;assert(not S.enabled() and G.check(actor,actor.square,'sort'))
opts.SortUpdatesLedger=nil;opts.LedgerMode=2;assert(not S.enabled() and G.check(actor,actor.square,'sort'))
print('PASS OFFLINE sort ledger: building-first real pickup, blank/partial fallback, required/protected writing supplies, actual native confirmation, whole-trip gate, one timed write, copy-on-write, old freshness, unchanged inventory, replay/tool/concurrent-change refusal and opt-outs; native/dedicated NOT TESTED')
