dofile(TEST_ROOT..'/fixtures/containers.lua')
dofile(TEST_ROOT..'/fixtures/catalog.lua')
-- PZ's runtime may omit global next; pairs still has its own iterator.
next=nil
LootSorter=nil
local M=require 'B47ANCEDQuartermaster/Movement'
local B,S,Store=B47ANCEDQuartermaster.Bindings,B47ANCEDQuartermaster.Schema,B47ANCEDQuartermaster.Store
local f=CONTAINER_FIXTURE
local function container(c)
    c.items={};c.room=true
    function c:getItemWithID(id) for _,it in ipairs(self.items) do if it:getID()==id then return it end end end
    function c:hasRoomFor() return self.room end
    function c:isItemAllowed() return true end
    function c:isRemoveItemAllowed() return true end
    return c
end
local carried=container({})
f.player.getInventory=function() return carried end
local source,dest=container(f.a.containers[1]),container(f.b.containers[1])
local discovery=assert(B.discover(f.player,{scope={x=0,y=0,z=0}}))
local records={}
for _,r in pairs(B.sessions[f.player].records) do records[r.target.obj]=r end
local r=records[f.b];r.original=S.empty();r.revision=0
local config=S.empty();config.items.RoundA=true;assert(Store.commit(r,config))
local item={container=source,getID=function() return 17 end,getCategory=function() return 'Ammo' end,
    getScriptItem=function() return CATALOG_FIXTURE.items[1] end,getDisplayName=function() return 'RoundA' end,
    isEquipped=function() return false end,isFavorite=function() return false end,getAttachedSlot=function() return -1 end,
    getIsCraftingConsumed=function() return false end}
function item:getContainer() return self.container end
local function reset()
    M.operations={};item.container=source;source.items={item};carried.items={};dest.items={};dest.room=true
end
local function plan()
    return M.handle(f.player,'movePlan',{session=discovery.session,source=records[f.a].token,itemID=17})
end
local function cmd(offer,name,player) return M.handle(player or f.player,name,{operation=offer.operation}) end
-- Server clock independently bounds arrival; late adjacency cannot revive it.
reset();item.container=carried;source.items={};carried.items={item}
local delayed=M.handle(f.player,'movePlan',{session=discovery.session,source='inventory',itemID=17})
assert(delayed.status=='ok')
local initialX=f.player.getX;f.player.getX=function() return -5 end
local waiting=cmd(delayed,'movePut')
assert(waiting.status=='waiting' and waiting.reason=='arrivalPending' and M.operations[f.player].phase=='carried')
f.advance(15000);f.player.getX=initialX
assert(cmd(delayed,'movePut').reason=='arrivalTimeout' and item.container==carried,'late arrival revived expired authorization wait')
reset()
local originalZ=f.player.getZ
reset();f.player.getZ=function() return .1 end
assert(plan().status=='ok','same grid-floor fractional Z rejected')
reset();f.player.getZ=function() return 1.1 end
assert(plan().status=='invalid','different grid floor accepted')
f.player.getZ=originalZ
reset()
local offer=plan();assert(offer.status=='ok')
assert(offer.destination.instance==f.b.md.B47MovementInstance)
assert(cmd(offer,'moveTake').status=='ok')
assert(cmd(offer,'moveTake').status=='invalid','grant replay')
assert(cmd(offer,'moveCarried').status=='waiting')
-- Fixture simulates native movement. Production never performs these writes.
source.items={};carried.items={item};item.container=carried
assert(cmd(offer,'moveCarried').status=='ok')
assert(cmd(offer,'movePut',{}).status=='invalid','foreign actor')
assert(cmd(offer,'movePut').status=='ok')
assert(cmd(offer,'movePut').status=='invalid','PUT grant replay')
carried.items={};dest.items={item};item.container=dest
assert(cmd(offer,'moveDone').status=='ok')
reset();offer=plan();f.b.sq.objects[1]={}
assert(cmd(offer,'moveTake').status=='invalid');assert(item.container==source)
f.b.sq.objects[1]=f.b
reset();offer=plan();assert(cmd(offer,'moveTake').status=='ok')
source.items={};carried.items={item};item.container=carried
assert(cmd(offer,'moveCarried').status=='ok')
f.b.sq.objects[1]={}
assert(cmd(offer,'movePut').status=='invalid');assert(item.container==carried)
f.b.sq.objects[1]=f.b
reset();offer=plan();f.a.sq.objects[1]={}
assert(cmd(offer,'moveTake').status=='invalid');assert(item.container==source)
f.a.sq.objects[1]=f.a
reset();offer=plan();source.items={{getID=function() return 17 end}}
assert(cmd(offer,'moveTake').status=='invalid','same-ID substitute accepted')
reset();assert(M.handle(f.player,'movePlan',{session=discovery.session,source=records[f.a].token,itemID=17,destination='override'}).status=='invalid')
reset();offer=plan();assert(cmd(offer,'moveTake').status=='ok')
source.items={};carried.items={item};item.container=carried
assert(cmd(offer,'moveCarried').status=='ok');dest.room=false
assert(cmd(offer,'movePut').status=='invalid');assert(item.container==carried)
reset();offer=plan();f.network(true,false)
assert(cmd(offer,'moveTake').status=='invalid','client authority')
f.network(false,false)
print('PASS OFFLINE one-item authority: exact refs, native outcome confirmation, grants, invalidation, substitution, capacity, actor and routing isolation')

-- A preset-only destination is routable; edits invalidate retained routing before PUT.
local Presets=B47ANCEDQuartermaster.Presets
local definition=S.empty();definition.items.RoundA=true
assert(Presets.change({name='Ammo',revision=0,generation=0,config=definition},f.player).status=='ok')
local linked=S.empty();linked.presets.Ammo=S.link(Presets.snapshot().definitions.Ammo)
assert(Store.commit(r,linked))
reset();offer=plan();assert(offer.status=='ok')
assert(cmd(offer,'moveTake').status=='ok')
source.items={};carried.items={item};item.container=carried
assert(cmd(offer,'moveCarried').status=='ok')
definition.items={}
assert(Presets.change({name='Ammo',revision=1,generation=1,config=definition},f.player).status=='ok')
local changedPreset=cmd(offer,'movePut')
assert(changedPreset.status=='invalid' and changedPreset.reason=='effectiveRulesChanged' and item.container==carried,'changed preset still granted PUT or rejection cause lost: '..tostring(changedPreset.reason))
assert(Store.commit(r,config));reset()
print('PASS OFFLINE preset routing and edit invalidation after TAKE; carried item retained')

-- Engine-shaped client queue plus real owned authority. No Quartermaster loads.
local q={queue={}}
ISTimedActionQueue={getTimedActionQueue=function() return q end,add=function(a) q.queue[#q.queue+1]=a end}
local Base={}
function Base:derive(name) local t={Type=name};t.__index=t;setmetatable(t,{__index=self});return t end
function Base:setOnComplete(fn) self.complete=fn end
function Base:forceStop() self:stop() end
local native=Base:derive('native')
ISInventoryTransferAction=native
local submissions=0
local beforeSubmit
function native:new(player,it,sc,dc)
    return setmetatable({character=player,item=it,srcContainer=sc,destContainer=dc},self)
end
function native:isValid() return true end
function native:start()
    if beforeSubmit then beforeSubmit(self) end
    self:checkQueueList() -- verified vanilla last dynamic Lua call before native submission
    submissions=submissions+1
end
function native:perform() q.queue={};if self.complete then self.complete() end end
function native:stop() q.queue={} end
local walk=Base:derive('walk');ISWalkToTimedAction=walk
function walk:new(player,stand) return setmetatable({character=player,stand=stand},self) end
function walk:stop() q.queue={} end
function walk:perform() q.queue={};if self.complete then self.complete() end end
AdjacentFreeTileFinder={Find=function(sq) return sq end}
for _,name in ipairs({'ISInventoryTransferAction','ISTimedActionQueue','WalkToTimedAction'}) do package.loaded['TimedActions/'..name]=true end
local A=require 'B47ANCEDQuartermaster/Authority'
A.request=function(_,command,args,cb)
    f.network(false,false)
    local result=M.handle(f.player,command,args)
    f.network(true,false)
    cb(result)
end
-- Native alphabetical startup loads BatchExecutor first; Executor must reuse it.
local earlyBatch=require 'B47ANCEDQuartermaster/BatchExecutor'
assert(type(earlyBatch.batchSupported)=='function')
local E=require 'B47ANCEDQuartermaster/Executor'
assert(E==earlyBatch and type(E.tickBatches)=='function','early batch module must survive Executor initialization')
local result
local function begin()
    f.network(false,false);reset();q.queue={};submissions=0;beforeSubmit=nil;result=nil
    f.network(true,false)
    assert(E.start(0,discovery.session,records[f.a].token,17,function(s) result=s end))
    E.tick();E.tick() -- resolve + native TAKE queued
    assert(#q.queue==1)
end
local function completeTransfer()
    local action=q.queue[1]
    assert(getmetatable(action)==native and rawget(getmetatable(action),'new')==native.new,
        'dedicated timed-action decoder cannot reconstruct a client-only transfer subclass')
    assert(action:isValid());action:start()
    if #q.queue==0 then return end
    -- ONLY the fake native engine mutates inventory in this test.
    action.srcContainer.items={};action.destContainer.items={item};item.container=action.destContainer
    action:perform()
end
local function throughWalk()
    completeTransfer();E.tick();assert(q.queue[1].Type=='walk' and getmetatable(q.queue[1])==walk)
    q.queue[1]:perform();E.tick();assert(q.queue[1].leg=='put')
end
begin();throughWalk();completeTransfer();E.tick()
assert(result=='ok' and submissions==2 and item.container==dest)
begin();completeTransfer();f.b.sq.objects[1]={};E.tick()
assert(result=='invalid' and submissions==1 and item.container==carried)
f.b.sq.objects[1]=f.b
begin();throughWalk()
beforeSubmit=function() f.b.sq.objects[1]={} end
q.queue[1]:start()
assert(submissions==1 and item.container==carried and result=='invalid','late replacement dispatched')
f.b.sq.objects[1]=f.b
begin();E.cancel(0)
assert(result=='cancelled' and submissions==0 and item.container==source)
begin();completeTransfer();E.cancel(0)
assert(result=='cancelled' and item.container==carried)
begin();throughWalk();q.queue[1].destContainer=source;q.queue[1]:start()
assert(submissions==1 and result=='invalid' and item.container==carried,'destination override dispatched')
f.network(false,false)
print('PASS OFFLINE client executor: TAKE/walk/PUT, final-call replacement veto, cancellation, no destination override; fake native mutations only')
-- Single-item fallback must also await authoritative arrival, without dispatch
-- or success credit while waiting. Server position is isolated from client X.
local normalHandle=M.handle;local putPolls=0
M.handle=function(player,command,args)
 if command=='movePut' then
  putPolls=putPolls+1
  if putPolls<=2 then
   local x=player.getX;player.getX=function() return -5 end
   local r=normalHandle(player,command,args);player.getX=x;return r
  end
 end
 return normalHandle(player,command,args)
end
begin();completeTransfer();E.tick();q.queue[1]:perform();E.tick()
assert(putPolls==1 and #q.queue==0 and submissions==1 and not result)
E.tick();assert(putPolls==1,'arrival metadata poll was not bounded')
f.advance(250);E.tick();assert(putPolls==2 and #q.queue==0 and not result)
f.advance(250);E.tick();assert(q.queue[1].leg=='put' and submissions==1)
completeTransfer();E.tick();assert(result=='ok' and submissions==2 and item.container==dest)
M.handle=normalHandle
-- An unrelated action queued during a grant response cannot be credited as PUT.
local normalRequest=A.request
A.request=function(playerNum,command,args,callback)
 normalRequest(playerNum,command,args,function(r)
  if command=='movePut' and r.status=='ok' then q.queue={{Type='unrelated'}} end
  callback(r)
 end)
end
begin();completeTransfer();E.tick();q.queue[1]:perform();E.tick()
assert(result=='cancelled' and submissions==1 and item.container==carried,'unsubmitted PUT reported success')
A.request=normalRequest;q.queue={}
print('PASS OFFLINE dev43 single executor: delayed arrival, bounded query rate and no false success for unrelated queue')

-- A real withdrawal offer reuses the owned subclass without destination/PUT.
local confirm=B47ANCEDQuartermaster.Shopping.confirm
local confirmed=0
B47ANCEDQuartermaster.Shopping.confirm=function() confirmed=confirmed+1 end
local function beginWithdrawal()
    f.network(false,false);reset();M.runs={};q.queue={};submissions=0;beforeSubmit=nil;result=nil
    local offer,op=M.withdraw(f.player,records[f.a],0,{item=item})
    assert(offer.status=='ok' and offer.destination==nil)
    M.runs[f.player]={kind='shopping',time=getTimestampMs(),operations={[op.id]=op}}
    f.network(true,false)
    assert(E.acceptOffer(0,offer,function(status) result=status end));E.tick()
    assert(q.queue[1].Type=='walk' and getmetatable(q.queue[1])==walk and submissions==0,'TAKE before walking')
end
beginWithdrawal();q.queue[1]:perform();E.tick()
assert(q.queue[1].leg=='take');f.b.sq.objects[1]={}
completeTransfer();E.tick()
assert(result=='ok' and confirmed==1 and submissions==1 and item.container==carried and #q.queue==0,'withdrawal used destination/PUT')
f.b.sq.objects[1]=f.b
beginWithdrawal();E.cancel(0);assert(result=='cancelled' and submissions==0 and item.container==source)
beginWithdrawal();q.queue[1]:perform();E.tick()
beforeSubmit=function() f.a.sq.objects[1]={} end
q.queue[1]:start();assert(submissions==0 and result=='invalid','stale source dispatched withdrawal')
f.a.sq.objects[1]=f.a;M.runs={};beforeSubmit=nil
B47ANCEDQuartermaster.Shopping.confirm=confirm
f.network(false,false)
print('PASS OFFLINE withdrawal executor: walk before TAKE, no destination/PUT, cancellation and stale source dispatch guard')

-- Execute installed vanilla start itself against the owned subclass, with engine
-- leaves mocked. This guards against relying only on the simplified queue above.
local stubClass=ISInventoryTransferAction
ISBaseTimedAction=Base;ISInventoryPage={}
package.loaded['TimedActions/ISBaseTimedAction']=true
dofile(GAME_ROOT..'/media/lua/client/TimedActions/ISInventoryTransferAction.lua')
local realStart=ISInventoryTransferAction.start
ISInventoryTransferAction=stubClass
local stubStart=native.start
local function prepareNativeStart(replace)
    begin();throughWalk()
    local action=q.queue[1]
    native.start=realStart
    action.queueList={{items={item}}}
    action.isAlreadyTransferred=function() return false end
    action.playSourceContainerOpenSound=function() end
    action.playDestContainerOpenSound=function() if replace then f.b.sq.objects[1]={} end end
    action.getTransferStartSoundName=function() end
    action.startActionAnim=function() end
    action.action={setWaitForFinished=function() end}
    item.getType=function() return 'Ammo' end
    carried.getType=function() return 'inventory' end
    f.player.isPlayerMoving=function() return false end
    f.player.getEmitter=function() return {playSound=function() return 1 end} end
    createItemTransaction=function(_,items,sc,dc)
        assert(#items==1 and items[1]==item and sc==carried and dc==dest)
        submissions=submissions+1;return 99
    end
    action:start()
    assert(submissions==(replace and 1 or 2))
    assert(item.container==carried,'mock dispatch moved item')
    native.start=stubStart
    f.b.sq.objects[1]=f.b
    E.cancel(0)
end
prepareNativeStart(false)
prepareNativeStart(true)
print('PASS OFFLINE installed vanilla start: final checkQueueList boundary blocks observable replacement without native dispatch')

-- Multi-item production driver, real owned server planner/transport handlers,
-- equipped bag staging and several bounded trips through fake native actions.
local Trips=require 'B47ANCEDQuartermaster/Trips'
local Sorter=require 'B47ANCEDQuartermaster/Sorter'
local function shape(c,capacity)
    c.capacity=capacity
    function c:getItems() return f.list(self.items) end
    function c:getEffectiveCapacity() return self.capacity end
    function c:getCapacityWeight()
        local n=0
        for _,it in ipairs(self.items) do
            n=n+it:getActualWeight()
            if it.bag then n=n+it.bag:getCapacityWeight()*0.5 end
        end
        return n
    end
    function c:hasRoomFor(_,it) return self.room and self:getCapacityWeight()+it:getActualWeight()<=self.capacity end
    function c:getContainingItem() return self.owner end
    return c
end
shape(source,100);shape(dest,100);shape(carried,6)
local bagContainer=shape(container({}),6)
local bag={class='InventoryContainer',bag=bagContainer,getID=function() return 901 end,isEquipped=function() return true end,
    getWeightReduction=function() return 50 end,getActualWeight=function() return 0 end,getInventory=function() return bagContainer end}
bagContainer.owner=bag
carried.getItemWithIDRecursiv=function(self,id) if id==901 then return bag end return self:getItemWithID(id) or bagContainer:getItemWithID(id) end
f.player.getMaxWeight=function() return 6 end
f.player.getWornItems=function() return f.list({{getItem=function() return bag end}}) end
f.player.getPrimaryHandItem=function() end;f.player.getSecondaryHandItem=function() end
f.player.getCurrentSquare=function() return f.a.sq end
source.getParent=function() return f.a end
f.a.getContainerIndex=function(_,c) return c==source and 0 or -1 end
A.request=function(_,command,args,cb)
    f.network(false,false)
    local result=(command:sub(1,4)=='trip' and Trips or M).handle(f.player,command,args)
    f.network(true,false);cb(result)
end
f.network(false,false);reset();carried.items={bag};bagContainer.items={}
local originals={}
for n=1,6 do
    local it={};for k,v in pairs(item) do it[k]=v end
    it.getID=function() return 100+n end;it.getActualWeight=function() return 2 end;it.container=source
    originals[#originals+1]=it
end
-- Independent B47 regression: an uncarryable first item must not consume
-- destination reservations needed by a later carryable item.
local oversized,small={},{}
for k,v in pairs(item) do oversized[k]=v;small[k]=v end
oversized.getID=function() return 701 end;oversized.getActualWeight=function() return 10 end;oversized.container=source
small.getID=function() return 702 end;small.getActualWeight=function() return 1 end;small.container=source
source.items={oversized,small};dest.capacity=10;dest.items={}
local fresh=assert(B.discover(f.player,{scope={x=0,y=0,z=0}}))
local sourceHandle
for _,meta in ipairs(fresh.targets) do if B.target(f.player,fresh.session,meta.token).target.container==source then sourceHandle=meta.token end end
local opened=Trips.handle(f.player,'tripBegin',{session=fresh.session,source=sourceHandle})
assert(opened.status=='ok')
local planned=Trips.handle(f.player,'tripNext',{run=opened.run})
assert(planned.status=='ok' and #planned.offers==1 and planned.offers[1].itemID==702,
    'uncarryable item blocked an eligible destination allocation')
Trips.handle(f.player,'tripCancel',{run=opened.run});dest.capacity=100
print('PASS OFFLINE B47 uncarryable-item destination capacity regression')
local tracePrint=print;local latencyLines={}
print=function(line) if tostring(line):find('[B47QM SORT TRACE]',1,true) then latencyLines[#latencyLines+1]=line else tracePrint(line) end end
B47ANCEDQuartermaster.SortTraceEnabled=true
source.items=originals
beforeSubmit=nil;submissions=0;q.queue={};local runResult;local counts
f.network(true,false)
assert(Sorter.start(0,source,function(status,moved,failed) runResult=status;counts={moved,failed} end))
local trace={};local usedBag=false
for step=1,200 do
    Sorter.tick();E.tick()
    local action=q.queue[1]
    if action then
        if action.leg then
            assert(getmetatable(action)==native and rawget(getmetatable(action),'new')==native.new)
            assert(action:isValid());action:start()
            assert(q.queue[1]==action,'unexpected rejection')
            trace[#trace+1]=action.leg
            if action.destContainer==bagContainer then usedBag=true end
            for i,v in ipairs(action.srcContainer.items) do if v==action.item then table.remove(action.srcContainer.items,i);break end end
            table.insert(action.destContainer.items,action.item);action.item.container=action.destContainer
            action:perform()
        else
            assert(getmetatable(action)==walk and rawget(getmetatable(action),'new')==walk.new,
                'dedicated timed-action decoder cannot reconstruct a client-only walk subclass')
            -- Native walking has start(); the fixture must exercise that hook too.
            walk.start=walk.start or function() end
            trace[#trace+1]='walk';action:start();action:perform()
        end
    end
    if runResult then break end
end
assert(runResult=='ok' and counts[1]==6 and counts[2]==0,'trip runner failed')
assert(#dest.items==6 and #source.items==0 and #bagContainer.items==0 and #carried.items==1)
assert(usedBag and trace[1]=='take' and trace[2]=='take','did not stage a trip before depositing')
assert(submissions==12,'each item must have exactly one TAKE and one PUT')
print=tracePrint;B47ANCEDQuartermaster.SortTraceEnabled=false
local stages=table.concat(latencyLines,'\n')
assert(stages:find('stage=ACTION_STARTED',1,true) and stages:find('stage=GRANT_RESPONSE',1,true))
assert(stages:find('stage=TRIP_PLANNING',1,true) and stages:find('stage=HANDLE_GENERATION',1,true))
assert(stages:find('durationMs=',1,true) and stages:find('clock=wall',1,true))
print('PASS OFFLINE timed Sort trace integration preserves multiple trips and native metatables')

assert(not M.runs[f.player] and not E.active[0] and not Sorter.active[0])
local firstPut,lastTake
for i,leg in ipairs(trace) do if leg=='put' and not firstPut then firstPut=i end;if leg=='take' then lastTake=i end end
assert(firstPut<lastTake,'expected capacity to require multiple trips')
f.network(false,false)
print('PASS OFFLINE production sorter: marker-bound source, equipped bag, trip loading, return walks, multiple trips, no duplicate moves')

-- Cancel a trip with a completed TAKE: retain carried contents, release all
-- pending authorizations, and never manufacture an undo transfer.
local x=dest.items[1];dest.items={};source.items={x};x.container=source
runResult=nil;q.queue={}
f.network(true,false)
assert(Sorter.start(0,source,function(s) runResult=s end))
for step=1,20 do
    Sorter.tick();E.tick()
    local action=q.queue[1]
    if action and action.leg=='take' then
        action:start();source.items={};action.destContainer.items={x};x.container=action.destContainer
        action:perform();break
    end
end
Sorter.cancel(0)
assert(runResult=='cancelled' and x.container==bagContainer and #dest.items==0 and not M.runs[f.player])
assert(ISInventoryTransferAction==native and native.start==stubStart,'global native action was replaced')
-- UI integration registers owned handlers with native registries. No upstream
-- controls or actions are replaced, even while the legacy frontend is installed.
local controls={}
function Base:new() return setmetatable({},self) end
ISInventoryWindowControlHandler=Base;ISLootWindowObjectControlHandler=Base
ISLootWindowFloorControlHandler=Base
ISInventoryWindowContainerControls={AddHandler=function(c) controls[#controls+1]=c end}
local floorControls={}
ISLootWindowContainerControls={AddHandler=ISInventoryWindowContainerControls.AddHandler,AddFloorHandler=function(c) floorControls[#floorControls+1]=c end}
for _,path in ipairs({'ISUI/InventoryWindow/ISInventoryWindowControlHandler','ISUI/InventoryWindow/ISInventoryWindowContainerControls',
    'ISUI/LootWindow/ISLootWindowObjectControlHandler','ISUI/LootWindow/ISLootWindowFloorControlHandler','ISUI/LootWindow/ISLootWindowContainerControls','ISUI/ISContextMenu'}) do package.loaded[path]=true end
require 'B47ANCEDQuartermaster/SortControls'
assert(#controls==2)
assert(controls[1].Type=='B47InventorySortControl' and controls[2].Type=='B47LootSortControl')
assert(#floorControls==1 and floorControls[1].Type=='B47FloorSortControl')
local transientEmpty=true
local aggregate={getType=function() return 'floor' end,isEmpty=function() return transientEmpty end,getParent=function() end,getContainingItem=function() end}
local floorHandler=floorControls[1]:new();floorHandler.playerNum=0;floorHandler.container=aggregate
local oldSpecific=getSpecificPlayer;getSpecificPlayer=function() return f.player end
for i=1,8 do transientEmpty=i%2==0;assert(floorHandler:shouldBeVisible(),'floor Sort must remain visible during empty proxy rebuild') end
aggregate.getType=function() return 'proximity' end
for i=1,8 do transientEmpty=i%2==0;assert(floorHandler:shouldBeVisible(),'parentless aggregate Sort must remain visible') end
getSpecificPlayer=oldSpecific
-- The real inventory control opens a scope menu; only the chosen callback starts.
local openedMenu
ISContextMenu={get=function()
 local menu={options={}}
 function menu:addOption(name,target,callback) local o={name=name,target=target,callback=callback};self.options[#self.options+1]=o;return o end
 function menu:addSubMenu(option,sub) option.sub=sub end
 openedMenu=menu;return menu
end}
function ISContextMenu:getNew() return ISContextMenu.get() end
getMouseX=function() return 10 end;getMouseY=function() return 20 end;isGamePaused=function() return false end
getText=getText or function(key) return key end
local area=require 'B47ANCEDQuartermaster/RoomSort'
local areaStart,singleStart,request=area.start,Sorter.start,A.request
local chosen,selectedSource
area.start=function(_,view) chosen=view;return true end
Sorter.start=function(_,source) selectedSource=source;return true end
A.request=function(_,command,args,done) assert(command=='areaOptions');done({status='ok',building=true,rooms={{nativeFallback=true,label='Storage'}}}) end
local handler=controls[1]:new();handler.playerNum=0;handler.container=carried
carried.getParent=function() end;carried.getContainingItem=function() end
f.player.getJoypadBind=function() return -1 end
handler:perform();assert(openedMenu and #openedMenu.options==3 and not chosen and not selectedSource)
openedMenu.options[1].callback();assert(chosen.kind=='building' and not selectedSource)
openedMenu.options[2].callback();assert(chosen.kind=='nativeRoom' and not selectedSource)
openedMenu.options[3].callback();assert(selectedSource==carried)
area.start,Sorter.start,A.request=areaStart,singleStart,request
print('PASS OFFLINE inventory scope control: menu opens without sorting; building, room and exact current-source choices dispatch independently')
f.network(false,false)
print('PASS OFFLINE trip cancellation retains carrier contents; owned inventory/loot controls registered without replacing vanilla')
