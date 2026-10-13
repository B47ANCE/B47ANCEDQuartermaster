-- Actual vanilla queue-list/perform code, real owned authority/planner/executor.
-- Engine/network leaves simulated: offline evidence, never dedicated certification.
dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
local f=CONTAINER_FIXTURE
local q={queue={}}
local Base={}
function Base:derive(name) local c={Type=name};c.__index=c;return setmetatable(c,{__index=self}) end
function Base:setOnComplete(fn) self.onCompleteFunc=fn;self.onCompleteArgs={} end
function Base:forceStop() self:stop() end
function Base:perform() for i,a in ipairs(q.queue) do if a==self then table.remove(q.queue,i);break end end end
Base.stop=Base.perform
ISBaseTimedAction=Base;ISInventoryPage={};package.loaded['TimedActions/ISBaseTimedAction']=true
dofile(GAME_ROOT..'/media/lua/client/TimedActions/ISInventoryTransferAction.lua')
local N=ISInventoryTransferAction
local nativeQueueList,nativePerform,nativeValid=N.checkQueueList,N.perform,N.isValid
round=function(n,d) return math.floor(n*10^d+.5)/10^d end
table.wipe=function(t) for k in pairs(t) do t[k]=nil end end
local opens,groups,maxGroup=0,0,0
local actionLeaves={setTime=function() end,reset=function() end,stopTimedActionAnim=function() end,setLoopedAction=function() end,setWaitForFinished=function() end}
function N:new(player,item,src,dst)
 return setmetatable({character=player,item=item,srcContainer=src,destContainer=dst,maxTime=50,queueList={{items={item},time=50,type=item:getFullType()}},action=actionLeaves},self)
end
function N:isValid() return self.item and (self.item:getContainer()==self.srcContainer or self.item:getContainer()==self.destContainer) end
function N:start() opens=opens+1;self:checkQueueList();self.started=true end
function N:stop() Base.stop(self) end
function N:playTransferCompleteSound() end;function N:playSourceContainerCloseSound() end;function N:playDestContainerCloseSound() end
function N:stopLoopingSound() end;function N:resetJobDelta() end;function N:startActionAnim() end
function N:isAlreadyTransferred(it) return it:getContainer()==self.destContainer end
removeItemTransaction=function() end;createItemTransaction=function() return 1 end
local W=Base:derive('ISWalkToTimedAction');ISWalkToTimedAction=W
function W:new(player,square) return setmetatable({character=player,square=square},self) end
function W:start() self.started=true end
function W:perform() f.player.square=self.square;Base.perform(self);if self.onCompleteFunc then self.onCompleteFunc() end end
W.stop=Base.stop
local immediateStart=false
ISTimedActionQueue={getTimedActionQueue=function() return q end,add=function(a) q.queue[#q.queue+1]=a;if immediateStart and #q.queue==1 then a:start() end end}
function q:indexOf(a) for i,v in ipairs(self.queue) do if v==a then return i end end;return -1 end
AdjacentFreeTileFinder={Find=function(sq) return sq end}
for _,path in ipairs({'ISInventoryTransferAction','ISTimedActionQueue','WalkToTimedAction'}) do package.loaded['TimedActions/'..path]=true end
local function storage(c)
 c.items={};c.capacity=1000
 function c:getItemWithID(id) for _,it in ipairs(self.items) do if it:getID()==id then return it end end end
 c.getItemWithIDRecursiv=c.getItemWithID
 function c:getItems() return f.list(self.items) end
 function c:getCapacityWeight() local w=0;for _,it in ipairs(self.items) do w=w+it:getActualWeight() end;return w end
 function c:getEffectiveCapacity() return self.capacity end
 function c:hasRoomFor(_,it) return self:getCapacityWeight()+it:getActualWeight()<=self.capacity end
 function c:isItemAllowed() return true end;function c:isRemoveItemAllowed() return true end
 function c:getType() return 'crate' end;function c:getContainingItem() end
 return c
end
local routeCase=false;local routeFar;local routeOrder={};local routeOptimized=true;local routeBookAfterFar=false
local groundMode=false
local src,dst=storage(f.a.containers[1]),storage(f.b.containers[1]);local carried=storage({})
carried.getParent=function() return nil end
local normalSourceType=src.getType
local worlds={}
function f.a.sq:getWorldObjects() local l=f.list(worlds);function l:contains(o) for _,v in ipairs(self) do if v==o then return true end end;return false end;return l end
function f.a.sq:isBlockedTo() return self.blocked==true end
src.getType=function(self) return groundMode and 'floor' or normalSourceType(self) end
src.getParent=function() return f.a end;f.a.getContainerIndex=function() return 0 end
f.player.getInventory=function() return carried end;f.player.getMaxWeight=function() return 1000 end
f.player.getWornItems=function() return f.list({}) end;f.player.getPrimaryHandItem=function() end;f.player.getSecondaryHandItem=function() end
f.player.getX=function() return f.player.square:getX() end;f.player.getY=function() return f.player.square:getY() end
f.player.getZ=function() return f.player.square:getZ() end
local A=require 'B47ANCEDQuartermaster/Authority';local Q=B47ANCEDQuartermaster
local E=require 'B47ANCEDQuartermaster/Executor';local S=require 'B47ANCEDQuartermaster/Sorter'
local singlePlayer=false
local RPC,prefetched,maxOutstanding={},false,0
A.request=function(_,command,args,cb)
 if command=='tripNext' and E.batches[0] then prefetched=true end
 RPC[#RPC+1]={command=command,args=args,cb=cb}
end
local function flush()
 local pending=RPC;RPC={}
 for _,r in ipairs(pending) do
  f.network(false,true);local result=A.handle(f.player,r.command,r.args);f.network(not singlePlayer,false);r.cb(result)
 end
 local run=Q.Movement.runs[f.player];local n=0;if run then for _ in pairs(run.operations) do n=n+1 end end
 maxOutstanding=math.max(n,maxOutstanding)
end
local function nativeMove(item,source,dest)
 if routeCase and dest==routeFar then if routeOptimized then assert(#dst.items==200,'left nearby book work for distant bandage') end;routeOrder[#routeOrder+1]=#dst.items end
 if routeCase and dest==dst and #routeOrder>0 then routeBookAfterFar=true end
 assert(item:getContainer()==source,'duplicate or stale native move')
 for i,it in ipairs(source.items) do if it==item then table.remove(source.items,i);break end end
 dest.items[#dest.items+1]=item;item.container=dest
 if item.world then for i,o in ipairs(worlds) do if o==item.world then table.remove(worlds,i);break end end;item.world=nil end
end
N.transferItem=function(self,it) nativeMove(it,self.srcContainer,self.destContainer) end
local cancelQueued=false
local replicationGapChecks=0
local function pump()
 local a=q.queue[1];if not a then return end
 if cancelQueued and a.leg=='take' then cancelQueued=false;S.cancel(0);return end
 if not a.started then a:start() end
 if q.queue[1]~=a then return end
 if getmetatable(a)==W then a:perform();return end
 if not singlePlayer and a.dispatched then
  -- Native MP source removal may precede the destination containment update.
  -- Exercise actual vanilla isValid, not the fixture's simplified predicate.
  local it=a.item;local oldContainer=it.container;local contains=a.srcContainer.contains
  local simplified=N.isValid
  it.container=nil;a.srcContainer.contains=function() return false end;N.isValid=nativeValid
  local valid=a:isValid()
  it.container=oldContainer;a.srcContainer.contains=contains;N.isValid=simplified
  assert(valid,'in-flight native transaction cancelled during replication gap')
  replicationGapChecks=replicationGapChecks+1
 end
 assert(getmetatable(a)==N and rawget(getmetatable(a),'new')==N.new,'native metatable changed')
 local group=a.queueList[1];assert(group and #group.items<=20,'vanilla grouping cap lost')
 maxGroup=math.max(maxGroup,#group.items);groups=groups+1
 if not singlePlayer then for _,it in ipairs(group.items) do nativeMove(it,a.srcContainer,a.destContainer) end end
 a:perform()
end
local function item(id,weight)
 local it={id=id,container=src,weight=weight or .05}
 function it:getWorldItem() return self.world end
 function it:getID() return self.id end;function it:getContainer() return self.container end
 function it:getActualWeight() return self.weight end;it.getWeight=it.getActualWeight
 function it:getFullType() return 'Fixture.RoundA' end;function it:getDisplayName() return 'RoundA' end
 function it:getScriptItem() return CATALOG_FIXTURE.items[1] end
 function it:isFavorite() return self.favorite==true end;function it:isEquipped() return false end
 function it:getAttachedSlot() return -1 end;function it:getIsCraftingConsumed() return false end
 function it:setJobDelta() end
 return it
end
local inventoryMode=false
local function scenario(count,size,hook,weight)
 local worldSource=src
 if inventoryMode then src=carried end
 routeOrder={};routeBookAfterFar=false
 f.network(false,true);f.player.square=f.a.sq;src.items={};dst.items={};carried.items={};dst.capacity=1000;carried.capacity=1000
 q.queue={};RPC={};opens,groups,maxGroup=0,0,0;prefetched=false;maxOutstanding=0
 E.active={};E.batches={};S.active={};Q.Movement.runs={};Q.Movement.operations={};Q.Bindings.sessions={}
 SandboxVars.B47ANCEDQuartermaster.SortBatchSize=size
 worlds={};f.a.sq.blocked=false
 for i=1,count do
  local it=item(i,weight);src.items[i]=it
  if groundMode then local o={getSquare=function() return f.a.sq end,getItem=function() return it end};it.world=o;worlds[#worlds+1]=o end
 end
 if routeCase then
  local it=src.items[1];it.getFullType=function() return 'Fixture.RoundB' end;it.getDisplayName=function() return 'RoundB' end;it.getScriptItem=function() return CATALOG_FIXTURE.items[2] end
  local obj=f.object(f.square(8,0,0));routeFar=storage(obj.containers[1])
 end
 local discovery=assert(Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}}))
 local record
 for _,r in pairs(Q.Bindings.sessions[f.player].records) do if r.target.container==dst then record=r end end
 local original,_,revision=Q.Store.load(record.target);record.original=original;record.revision=revision
 local cfg=Q.Schema.empty();cfg.items.RoundA=true;assert(Q.Store.commit(record,cfg))
 if routeCase then
  for _,r in pairs(Q.Bindings.sessions[f.player].records) do if r.target.container==routeFar then local original,_,revision=Q.Store.load(r.target);local cfg=Q.Schema.empty();cfg.items.RoundB=true;assert(Q.Store.commit({target=r.target,original=original,revision=revision},cfg)) end end
 end
 f.network(not singlePlayer,false);local result,moved,failed
 assert(S.start(0,src,function(status,n,bad) result,moved,failed=status,n,bad end))
 for step=1,3000 do
  if hook then hook(step,src.items[1],E.batches[0]) end
  S.tick();E.tick();flush();pump();f.advance(250)
  if result then flush();break end
 end
 assert(result,'pipeline stalled')
 local actual=#dst.items+(routeCase and #routeFar.items or 0)
 assert(actual+#src.items+(src==carried and 0 or #carried.items)==count,'item conservation violated')
 assert(moved<=actual,'completion credited before server observation')
 assert(maxOutstanding<=math.max(1,math.min(100,size))*2,'unbounded prefetch')
 src=worldSource
 return result,moved,failed,opens,maxGroup,prefetched
end
-- Quantity, planning-size and native-heavy-item boundaries exercise the real
-- pipeline and vanilla queue merge/perform code (including wiped donor tables).
for _,case in ipairs({{0,1},{1,1},{2,1},{3,1},{5,2},{6,3},{7,3},{20,20},{21,20},{40,20},{41,20},{65,20},{99,100},{100,100},{101,100},{125,100}}) do
 local status,moved,_,opened,group,prefetch=scenario(case[1],case[2])
 assert(status=='ok' and moved==case[1])
 if case[1]>1 and case[2]>1 then assert(opened<case[1]*2,'container reopened per item') end
 if case[1]>case[2] and case[2]>1 then assert(prefetch,'next batch not prefetched during execution') end
end
inventoryMode=true
local normalMaxWeight=f.player.getMaxWeight
f.player.getMaxWeight=function() return 1 end -- Already-carried items can be deposited while overweight.
for _,sp in ipairs({false,true}) do
 singlePlayer=sp
 local status,moved,failed=scenario(701,20)
 assert(status=='ok' and moved==701 and failed==0,'701-item player inventory deposit failed')
end
f.player.getMaxWeight=normalMaxWeight
inventoryMode=false;singlePlayer=false
print('PASS OFFLINE player inventory: 701 items deposited in SP/MP-shaped queue fixtures, zero skips')
-- A local walk to x=5 completes before server position reaches that tile.
-- Use separate position evidence inside the server handler, not shared arrival.
local originalDestination,originalStorage=f.b,dst
originalDestination.md={};originalStorage.items={}
f.b=f.object(f.square(5,0,0));dst=storage(f.b.containers[1])
local separatedSquare=f.b.sq
local function arrivalScenario(command,delay,mode,fromInventory)
 local original=A.handle;local started,waits=nil,0;inventoryMode=fromInventory==true
 A.handle=function(player,cmd,args)
  if cmd==command then
   started=started or getTimestampMs()
   if getTimestampMs()-started<delay then
    local x=player.getX;player.getX=function() return -5 end
    local response=original(player,cmd,args);player.getX=x
    if response.status=='waiting' then
     waits=waits+1
     assert(#dst.items==0,'PUT dispatched before server arrival')
    end
    return response
   end
  end
  return original(player,cmd,args)
 end
 local status,moved,failed=scenario(701,20,function()
  if started and mode=='capacity' then dst.capacity=0 end
  if started and mode=='removed' then separatedSquare.objects=f.list({}) end
  if started and mode=='cancel' then S.cancel(0) end
 end)
 A.handle=original;inventoryMode=false
 return status,moved,failed,waits
end
for _,sp in ipairs({false,true}) do
 singlePlayer=sp
 local status,moved,failed,waits=arrivalScenario('movePut',750,nil,true)
 assert(status=='ok' and moved==701 and failed==0 and waits>0,'delayed server PUT position lost inventory items')
end
singlePlayer=false
local status,moved,failed,waits=arrivalScenario('moveTake',750,nil,false)
assert(status=='ok' and moved==701 and failed==0 and waits>0,'delayed TAKE arrival failed')
status,moved,failed,waits=arrivalScenario('movePut',math.huge,nil,true)
assert((status=='uncertain' or status=='invalid') and moved==0 and waits>0,'permanent non-adjacency transferred/stalled')
for _,mode in ipairs({'capacity','removed','cancel'}) do
 separatedSquare.objects=f.list({f.b})
 status,moved=arrivalScenario('movePut',750,mode,true)
 assert(status~='ok' and moved==0,'arrival wait bypassed '..mode)
end
separatedSquare.objects=f.list({});f.b,dst=originalDestination,originalStorage
print('PASS OFFLINE dev43 arrival: 701 delayed PUT items in SP/MP-shaped fixtures, delayed TAKE, bounded timeout and capacity/removal/cancel rejection')
-- A native/server rejection after walking must not silently drain the entire run.
inventoryMode=true
local normalHandle=A.handle;local rejected=0;local summary;local normalPrint=print
print=function(message,...)
 if type(message)=='string' and message:find('sort summary',1,true) then summary=message end
 normalPrint(message,...)
end
A.handle=function(player,command,args)
 if command=='movePut' then rejected=rejected+1;return {status='invalid',reason='testPutRejected',serverVersion='fixture-server'} end
 return normalHandle(player,command,args)
end
local stopped,moved,failed=scenario(701,20)
A.handle=normalHandle;print=normalPrint;inventoryMode=false
assert(stopped=='invalid' and moved==0 and failed<=20 and rejected<=20,'zero-progress rejection discarded later inventory batches')
assert(summary and summary:find('movePut:invalid:testPutRejected',1,true) and summary:find('server=fixture-server',1,true),'first rejection/server version absent from client summary')
print('PASS OFFLINE zero-progress player inventory: fail closed after first rejected batch, untouched remainder and exact first-failure diagnostics')
inventoryMode=true;summary=nil
print=function(message,...)
 if type(message)=='string' and message:find('sort summary',1,true) then summary=message end
 normalPrint(message,...)
end
local unconfigured,moved,skipped=scenario(701,20,function(step)
 if step==1 then for _,it in ipairs(src.items) do
  it.getDisplayName=function() return 'RoundB' end;it.getScriptItem=function() return CATALOG_FIXTURE.items[2] end
 end end
end)
print=normalPrint;inventoryMode=false
assert(unconfigured=='ok' and moved==0 and skipped==701,'terminal planning skips were lost or transfers credited')
assert(summary and summary:find('transferFailed=0',1,true) and summary:find('planningSkipped=701',1,true)
 and summary:find('noMatchingRule:701',1,true),'planning and native failures were conflated')
print('PASS OFFLINE terminal skip reporting: 701 unmatched inventory items, no native attempts, exact client summary')
for _,weight in ipairs({.1,.11,1,4}) do local status,moved=scenario(8,4,nil,weight);assert(status=='ok' and moved==8) end
local status,moved=scenario(10,4,function(step,it) if step==1 then for _,x in ipairs(src.items) do x.favorite=true end end end)
assert(status=='ok' and moved==0)
status,moved=scenario(10,4,function(step) if step==1 then dst.capacity=.1 end end)
assert(status=='ok' and moved<=2)
status,moved=scenario(10,4,function(step) if step==1 then carried.capacity=.1 end end)
assert(status=='ok' and moved==10,'future batches ignored freed carrier capacity')
status,moved=scenario(10,4,function(step) if step==3 then S.cancel(0) end end)
assert(status=='cancelled' and moved==0)
status,moved=scenario(40,20,function(_,_,batch) if batch then cancelQueued=true end end)
assert(status=='cancelled' and moved==0)
status,moved=scenario(10,4,function(_,_,batch) if batch and batch.phase=='takeReady' then for _,x in ipairs(src.items) do x.favorite=true end end end)
assert(moved==0,'stale favorite authorization transferred items')
status,moved=scenario(10,4,function(_,_,batch) if batch and batch.phase=='grantPut' then dst.capacity=0 end end)
assert(moved==0,'changed capacity authorized deposit')
immediateStart=true
status,moved=scenario(41,20);assert(status=='ok' and moved==41)
immediateStart=false;singlePlayer=true
status,moved=scenario(41,20);assert(status=='ok' and moved==41)
singlePlayer=false
for _,value in ipairs({-1,0,101,1000}) do SandboxVars.B47ANCEDQuartermaster.SortBatchSize=value;assert(Q.Trips.batchSize()==math.max(1,math.min(100,value))) end
if DEV25_GROUND then
 groundMode=true
 status,moved=scenario(7,3);assert(status=='ok' and moved==7,'ground pipeline failed')
 immediateStart=true
 status,moved=scenario(3,2);assert(status=='ok' and moved==3)
 immediateStart=false;singlePlayer=true
 status,moved=scenario(3,2);assert(status=='ok' and moved==3)
 singlePlayer=false
 status,moved=scenario(3,2,function(_,_,batch) if batch and batch.phase=='takeReady' then worlds={} end end);assert(moved==0,'removed source transferred')
 status,moved=scenario(4,2,function(step) if step==1 then dst.capacity=0 end end);assert(status=='ok' and moved==0)
 status,moved=scenario(4,2,function(step) if step==3 then S.cancel(0) end end);assert(status=='cancelled' and moved==0)
 groundMode=false
 print('PASS OFFLINE dev25 ground pipeline: native queue SP/MP/immediate start and removed-world rejection')
end
do
 routeCase=true;routeOptimized=false;SandboxVars.B47ANCEDQuartermaster.RouteOptimization=false
 local status,moved=scenario(201,20);assert(status=='ok' and moved==201 and routeBookAfterFar and routeOrder[1]<200,'baseline did not reproduce early departure')
 local baseline=routeOrder[1]
 routeOptimized=true;SandboxVars.B47ANCEDQuartermaster.RouteOptimization=true
 status,moved=scenario(201,20);assert(status=='ok' and moved==201 and #routeOrder==1 and routeOrder[1]==200 and not routeBookAfterFar,'optimized bookshelf workload/revisit failed')
 routeCase=false
 print('PASS OFFLINE dev27 production benchmark: baseline first distant visit after '..baseline..' nearby transfers and revisits nearby work; optimized after 200, zero premature revisit; all 201 exact native transfers conserved')
end
assert(N.checkQueueList==nativeQueueList and N.perform==nativePerform,'global native methods replaced')
-- Distinguish native rejection from a stop after the first completed group.
inventoryMode=true;singlePlayer=false
for _,reject in ipairs({false,true}) do
 local observed;local stoppedOnce=false;local originalPrint=print
 print=function(message,...)
  if type(message)=='string' and message:find('sort summary',1,true) then observed=message end
  originalPrint(message,...)
 end
 local status=scenario(3,3,function(_,_,batch)
  local action=q.queue[1]
  if not stoppedOnce and batch and batch.phase=='putting' and action and (action.b47PerformCount or 0)>0 then
   stoppedOnce=true
   if reject then
    local valid=N.isValid;N.isValid=function() return false end
    assert(not action:isValid());N.isValid=valid
   end
   action:stop()
  end
 end,.2)
 print=originalPrint
 assert(stoppedOnce and status=='cancelled','native stop probe not exercised')
 local expected=reject and 'nativeValidationRejected' or 'nativeStoppedAfterPerform'
 assert(observed and observed:find(expected,1,true),'native stop origin was lost')
end
inventoryMode=false
print('PASS OFFLINE dev46 native rejection versus stop-after-first-group diagnostics')
local P=require 'B47ANCEDQuartermaster/Protocol'
assert(P.version('tripNext')==4 and not P.accepts('tripNext',{protocol=1}) and not P.accepts('movePut',{protocol=3}))
assert(replicationGapChecks>0,'replication-gap guard regression was not exercised')
print('PASS OFFLINE dev45 native in-flight replication gap validation')
print('PASS OFFLINE dev24: 29 production pipeline scenarios, native donor merge/perform, bounded overlap, capacity, cancellation and mixed-peer rejection')

