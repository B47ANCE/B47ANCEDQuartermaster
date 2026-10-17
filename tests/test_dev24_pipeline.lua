-- Actual vanilla queue-list/perform code, real owned authority/planner/executor.
-- Engine/network leaves simulated: offline evidence, never dedicated certification.
dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
local f=CONTAINER_FIXTURE
local q={queue={}}
local Base={}
function Base:derive(name) local c={Type=name};c.__index=c;return setmetatable(c,{__index=self}) end
function Base:new(player) return setmetatable({character=player},self) end
function Base:beginAddingActions() self._isAddingActions=true;self._numAddedActions=0 end
function Base:endAddingActions() local n=self._numAddedActions or 0;self._isAddingActions=nil;self._numAddedActions=nil;return n>0 end
function Base:forceComplete() self.completed=true end
function Base:setOnComplete(fn) self.onCompleteFunc=fn;self.onCompleteArgs={} end
function Base:forceStop() self:stop() end
function Base:perform() for i,a in ipairs(q.queue) do if a==self then table.remove(q.queue,i);break end end end
Base.stop=Base.perform
ISBaseTimedAction=Base;ISInventoryPage={};package.loaded['TimedActions/ISBaseTimedAction']=true
dofile(GAME_ROOT..'/media/lua/client/TimedActions/ISInventoryTransferAction.lua')
dofile(GAME_ROOT..'/media/lua/client/TimedActions/ISQueueActionsAction.lua')
package.loaded['TimedActions/ISQueueActionsAction']=true
local N=ISInventoryTransferAction
local nativeQueueList,nativePerform,nativeValid=N.checkQueueList,N.perform,N.isValid
local nativeNew,nativeStart,nativeUpdate,nativeStop=N.new,N.start,N.update,N.stop
local lifecycle=DEV47_NATIVE_TRANSACTIONS==true
round=function(n,d) return math.floor(n*10^d+.5)/10^d end
table.wipe=function(t) for k in pairs(t) do t[k]=nil end end
local opens,groups,maxGroup=0,0,0
local firstSubmitted,gateCount
local actionLeaves={setTime=function() end,reset=function(self) self.completed=false end,stopTimedActionAnim=function() end,setLoopedAction=function() end,setWaitForFinished=function() end,
 getJobDelta=function() return 0 end,forceComplete=function(self) self.completed=true end}
function N:new(player,item,src,dst)
 if lifecycle and isClient() then local a=nativeNew(self,player,item,src,dst);a.action=setmetatable({},{__index=actionLeaves});return a end
 return setmetatable({character=player,item=item,srcContainer=src,destContainer=dst,maxTime=50,queueList={{items={item},time=50,type=item:getFullType()}},action=actionLeaves},self)
end
function N:isValid() if lifecycle and isClient() then return nativeValid(self) end;return self.item and (self.item:getContainer()==self.srcContainer or self.item:getContainer()==self.destContainer) end
function N:start() opens=opens+1;if lifecycle and isClient() then return nativeStart(self) end;self:checkQueueList();self.started=true end
function N:stop() if lifecycle and isClient() then return nativeStop(self) end;Base.stop(self) end
function N:playTransferCompleteSound() end;function N:playSourceContainerCloseSound() end;function N:playDestContainerCloseSound() end
function N:stopLoopingSound() end;function N:resetJobDelta() end;function N:startActionAnim() end
function N:isAlreadyTransferred(it) return it:getContainer()==self.destContainer end
removeItemTransaction=function() end;createItemTransaction=function() return 1 end
local transactions,transactionSerial={},0
if lifecycle then
 N.playSourceContainerOpenSound=function() end;N.playDestContainerOpenSound=function() end;N.getTransferStartSoundName=function() end
 createItemTransaction=function(player,items,src,dst)
  firstSubmitted=firstSubmitted or #items
  transactionSerial=transactionSerial+1;local copy={};for _,it in ipairs(items) do copy[#copy+1]=it end
  transactions[transactionSerial]={items=copy,src=src,dst=dst,status='pending'};return transactionSerial
 end
 removeItemTransaction=function(id,cancel) local t=transactions[id];if t then t.removed=true;t.cancelled=cancel end end
 isItemTransactionConsistent=function() return true end
 isItemTransactionDone=function(id) return transactions[id] and transactions[id].status=='done' or false end
 isItemTransactionRejected=function(id) return transactions[id] and transactions[id].status=='rejected' or false end
 getItemTransactionDuration=function() return 10 end
 ISTradingUI={GetUIForPlayer=function() end};getServerOptions=function() return {getInteger=function() return 0 end} end
 CharacterTrait={DESENSITIZED='desensitized',COWARDLY='cowardly',BRAVE='brave',HEMOPHOBIC='blood',DEXTROUS='dextrous',ALL_THUMBS='thumbs'}
 Metabolics={LightWork='light'};getCore=function() return {getGameMode=function() return 'Sandbox' end} end
end
local W=Base:derive('ISWalkToTimedAction');ISWalkToTimedAction=W
function W:new(player,square) return setmetatable({character=player,square=square},self) end
function W:start() self.started=true end
function W:perform() f.player.square=self.square;Base.perform(self);if self.onCompleteFunc then self.onCompleteFunc() end end
W.stop=Base.stop
local immediateStart=false
ISTimedActionQueue={getTimedActionQueue=function() return q end,add=function(a)
 local current=q.queue[1]
 if current and current._isAddingActions then
  table.insert(q.queue,2+current._numAddedActions,a);current._numAddedActions=current._numAddedActions+1
 else q.queue[#q.queue+1]=a;if immediateStart and #q.queue==1 then a:start() end end
end}
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
 function c:contains(it) return self:getItemWithID(it:getID())==it end
 function c:isInCharacterInventory(player) return self==player:getInventory() end
 function c:isVehicleSeat() return false end
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
if lifecycle then
 f.player.hasTrait=function() return false end;f.player.isWearingAwkwardGloves=function() return false end
 f.player.isTimedActionInstant=function() return false end;f.player.isPlayerMoving=function() return false end
 f.player.setMetabolicTarget=function() end
 f.player.getEmitter=function() return {playSound=function() return 1 end,isPlaying=function() return false end} end
end
local A=require 'B47ANCEDQuartermaster/Authority';local Q=B47ANCEDQuartermaster
local E=require 'B47ANCEDQuartermaster/Executor';local S=require 'B47ANCEDQuartermaster/Sorter'
local singlePlayer=false
local RPC,prefetched,maxOutstanding={},false,0
local rpcCounts={}
A.request=function(_,command,args,cb)
 rpcCounts[command]=(rpcCounts[command] or 0)+1
 if command=='tripNext' and E.batches[0] then prefetched=true end
 RPC[#RPC+1]={command=command,args=args,cb=cb}
end
local function flush()
 local pending=RPC;RPC={}
 for _,r in ipairs(pending) do
  f.network(false,true);local result=A.handle(f.player,r.command,r.args);result.serverVersion=result.serverVersion or 'fixture-server';f.network(not singlePlayer,false);r.cb(result)
 end
 local run=Q.Movement.runs[f.player];local n=0;if run then for _ in pairs(run.operations) do n=n+1 end end
 maxOutstanding=math.max(n,maxOutstanding)
end
local moveProbe
local function nativeMove(item,source,dest)
 if moveProbe then moveProbe(item,source,dest) end
 if routeCase and dest==routeFar then if routeOptimized then assert(#dst.items==200,'left nearby book work for distant bandage') end;routeOrder[#routeOrder+1]=#dst.items end
 if routeCase and dest==dst and #routeOrder>0 then routeBookAfterFar=true end
 assert(item:getContainer()==source,'duplicate or stale native move')
 for i,it in ipairs(source.items) do if it==item then table.remove(source.items,i);break end end
 dest.items[#dest.items+1]=item;item.container=dest
 if item.world then for i,o in ipairs(worlds) do if o==item.world then table.remove(worlds,i);break end end;item.world=nil end
end
N.transferItem=function(self,it) nativeMove(it,self.srcContainer,self.destContainer) end
local cancelQueued=false
local cancelGate,protectGate=false,false
local rejectNextTransaction=false
local replicationGapChecks=0
local aliasItem=false
local aliasMeta={__eq=function(a,b) return a.id==b.id end}
aliasMeta.__index=function(t,k) local original=rawget(t,'original');return original and original[k] end
local function pump()
 local a=q.queue[1];if not a then return end
 if cancelQueued and a.leg=='take' then cancelQueued=false;S.cancel(0);return end
 if getmetatable(a)==ISQueueActionsAction then
  if a.b47Batch.phase=='putting' then
   if cancelGate then cancelGate=false;S.cancel(0);return end
   if protectGate then protectGate=false;for _,it in ipairs(carried.items) do it.favorite=true end end
  end
  gateCount=(gateCount or 0)+1
  if not a.completed then a:start() end
  if a.completed then a:perform() end
  return
 end
 if not a.started then a:start() end
 if q.queue[1]~=a then return end
 if aliasItem and a.leg then
  local original=a.item;setmetatable(original,aliasMeta)
  a.item=setmetatable({original=original},aliasMeta)
  assert(a:isValid(),'equivalent native item wrapper lost its authorized operation')
 end
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
 if not singlePlayer then
  if lifecycle then
   local transaction=assert(transactions[a.transactionId],'native start/reset did not submit a transaction')
   assert(not transaction.removed and transaction.status=='pending','native transaction replay')
   if rejectNextTransaction then rejectNextTransaction=false;transaction.status='rejected';nativeUpdate(a);return end
   assert(#transaction.items==#group.items,'queue group changed after native submission')
   for _,it in ipairs(transaction.items) do nativeMove(it,transaction.src,transaction.dst) end
   transaction.status='done';nativeUpdate(a);assert(a.action.completed,'native update did not complete acknowledged transaction')
  else for _,it in ipairs(group.items) do nativeMove(it,a.srcContainer,a.destContainer) end end
 end
 a:perform()
end
local function item(id,weight)
 local it={id=id,container=src,weight=weight or .05}
 function it:getWorldItem() return self.world end
 function it:getID() return self.id end;function it:getContainer() return self.container end
 function it:getActualWeight() return self.weight end;it.getWeight=it.getActualWeight
 function it:getFullType() return 'Fixture.RoundA' end;function it:getDisplayName() return 'RoundA' end
 function it:getType() return 'RoundA' end
 function it:getScriptItem() return CATALOG_FIXTURE.items[1] end
 function it:isFavorite() return self.favorite==true end;function it:isEquipped() return false end
 function it:getAttachedSlot() return -1 end;function it:getIsCraftingConsumed() return false end
 function it:setJobDelta() end
 return it
end
local inventoryMode=false
local additionalDestination
local function scenario(count,size,hook,weight)
 local worldSource=src
 if inventoryMode then src=carried end
 routeOrder={};routeBookAfterFar=false
 f.network(false,true);f.player.square=f.a.sq;src.items={};dst.items={};carried.items={};dst.capacity=1000;carried.capacity=1000
 q.queue={};RPC={};rpcCounts={};opens,groups,maxGroup=0,0,0;firstSubmitted=nil;gateCount=0;prefetched=false;maxOutstanding=0
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
 local actual=#dst.items+(routeCase and #routeFar.items or 0)+(additionalDestination and #additionalDestination.items or 0)
 assert(actual+#src.items+(src==carried and 0 or #carried.items)==count,'item conservation violated')
 assert(moved<=actual,'completion credited before server observation')
 assert(maxOutstanding<=400,'carry exceeded protocol bound')
 src=worldSource
 return result,moved,failed,opens,maxGroup,prefetched
end
-- Quantity, planning-size and native-heavy-item boundaries exercise the real
-- pipeline and vanilla queue merge/perform code (including wiped donor tables).
for _,case in ipairs({{0,1},{1,1},{2,1},{3,1},{5,2},{6,3},{7,3},{20,20},{21,20},{40,20},{41,20},{65,20},{99,100},{100,100},{101,100},{125,100}}) do
 local status,moved,_,opened,group,prefetch=scenario(case[1],case[2])
 assert(status=='ok' and moved==case[1])
 if case[1]>1 and case[2]>1 then assert(opened<case[1]*2,'container reopened per item') end
 assert(not prefetch,'new carry planned while previous carry was executing')
end
inventoryMode=true;aliasItem=true
local aliasStatus,aliasMoved=scenario(41,20)
assert(aliasStatus=='ok' and aliasMoved==41,'equivalent item wrappers stopped PUT')
aliasItem=false
print('PASS OFFLINE dev48 stable item ID lookup across equivalent wrappers')
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
 local original=Q.Movement.handle;local started,waits=nil,0;inventoryMode=fromInventory==true
 Q.Movement.handle=function(player,cmd,args)
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
 Q.Movement.handle=original;inventoryMode=false
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
local normalHandle=Q.Movement.handle;local rejected=0;local summary;local normalPrint=print
print=function(message,...)
 if type(message)=='string' and message:find('sort summary',1,true) then summary=message end
 normalPrint(message,...)
end
Q.Movement.handle=function(player,command,args)
 if command=='movePut' then rejected=rejected+1;return {status='invalid',reason='testPutRejected',serverVersion='fixture-server'} end
 return normalHandle(player,command,args)
end
local stopped,moved,failed=scenario(701,20)
Q.Movement.handle=normalHandle;print=normalPrint;inventoryMode=false
assert(stopped=='invalid' and moved==0 and failed<=100 and rejected<=100,'zero-progress rejection discarded later inventory batches')
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
local capacityHandle=Q.Movement.handle
Q.Movement.handle=function(player,command,args)
 if command=='movePut' then dst.capacity=0 end
 return capacityHandle(player,command,args)
end
status,moved=scenario(10,4)
Q.Movement.handle=capacityHandle
assert(moved==0,'changed capacity authorized deposit')
immediateStart=true
status,moved=scenario(41,20);assert(status=='ok' and moved==41)
immediateStart=false;singlePlayer=true
status,moved=scenario(41,20);assert(status=='ok' and moved==41)
singlePlayer=false
if lifecycle then
 immediateStart=true;inventoryMode=true
 status,moved=scenario(20,20)
 assert(status=='ok' and moved==20 and firstSubmitted==20,'first native transaction started before the authorized light-item batch was queued')
 assert(opens==1 and gateCount==1,'same-container batch reopened or used multiple queue gates')
 status,moved=scenario(8,20,nil,.2)
 assert(status=='ok' and moved==8 and opens==1 and firstSubmitted==1,'heavy items lost native individual transfer semantics or continuous queue')
 status,moved=scenario(20,20,function(step)
  if step==1 then for i,it in ipairs(carried.items) do local name=i%2==0 and 'Fixture.LightA' or 'Fixture.LightB';it.getFullType=function() return name end end end
 end)
 assert(status=='ok' and moved==20 and opens==1 and firstSubmitted==10,'mixed light types failed native grouping within one continuous queue')
 for _,instant in ipairs({false,true}) do
  immediateStart=instant
  status,moved=scenario(20,20,function(step) if step==1 then cancelGate=true end end)
  assert(status=='cancelled' and moved==0 and firstSubmitted==nil,'queue-gate cancellation submitted items')
  for _=1,25 do if #q.queue>0 then pump() end end
  assert(firstSubmitted==nil,'cancelled gate donors escaped batch guards')
 end
 immediateStart=false
 status,moved=scenario(20,20,function(step) if step==1 then protectGate=true end end)
 assert(status~='ok' and moved==0 and firstSubmitted==nil,'stale favorite state bypassed final native-start guard')
 immediateStart=false;inventoryMode=false
 print('PASS OFFLINE dev50 complete native batch before immediate start, one container open, native heavy-item timing retained')
end
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
 local status,moved=scenario(201,20);assert(status=='ok' and moved==201 and not routeBookAfterFar and routeOrder[1]==200,'crate carry left before unloading all nearby items')
 local baseline=routeOrder[1]
 routeOptimized=true;SandboxVars.B47ANCEDQuartermaster.RouteOptimization=true
 status,moved=scenario(201,20);assert(status=='ok' and moved==201 and #routeOrder==1 and routeOrder[1]==200 and not routeBookAfterFar,'optimized bookshelf workload/revisit failed')
 routeCase=false
 print('PASS OFFLINE carry routing: one crate with optimization off / one room with optimization on; both finish 200 nearby items before distant destination; all 201 native transfers conserved')
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
if lifecycle then
 inventoryMode=true;singlePlayer=false
 local triggered=false;local summary;local originalPrint=print
 print=function(message,...) if type(message)=='string' and message:find('sort summary',1,true) then summary=message end;originalPrint(message,...) end
 local status=scenario(3,3,function(_,_,batch)
  local action=q.queue[1]
  if not triggered and batch and batch.phase=='putting' and action and (action.b47PerformCount or 0)>0 then triggered=true;rejectNextTransaction=true end
 end,.2)
 print=originalPrint;inventoryMode=false
 assert(triggered and status=='cancelled' and #dst.items==1,'native rejection after first transaction did not stop safely')
 assert(summary and summary:find('nativeTransactionRejected',1,true),'actual native update rejection was misclassified')
 print('PASS OFFLINE dev47 actual native update/stop rejection after first submitted transaction, with exact diagnostic classification')
end
local P=require 'B47ANCEDQuartermaster/Protocol'
assert(P.version('tripNext')==11 and not P.accepts('tripNext',{protocol=1}) and not P.accepts('movePut',{protocol=3}))
assert(replicationGapChecks>0,'replication-gap guard regression was not exercised')
print('PASS OFFLINE dev45 native in-flight replication gap validation')
print('PASS OFFLINE dev24: 29 production pipeline scenarios, native donor merge/perform, bounded closed carries, capacity, cancellation and mixed-peer rejection')
if lifecycle then print('PASS OFFLINE dev47 installed native constructor/start/update/validation/perform with simulated transaction acknowledgements; engine/network unverified') end


-- Network cardinality is independent of native item/group timing.
inventoryMode=true
local batchStatus,batchMoved=scenario(20,20,nil,1)
assert(batchStatus=='ok' and batchMoved==20 and rpcCounts.moveBatch==2)
assert(not rpcCounts.moveCarried and not rpcCounts.movePut and not rpcCounts.moveDone,'per-item query roundtrips remain')
inventoryMode=false
batchStatus,batchMoved=scenario(20,20,nil,1)
assert(batchStatus=='ok' and batchMoved==20 and rpcCounts.moveBatch==4 and not rpcCounts.moveTake)
print('PASS OFFLINE throughput: 20-item deposit 60 -> 2 requests; container transfer 80 -> 4; unchanged native grouping/timing')

-- Failed correlation cannot authorize even a valid server grant response.
inventoryMode=true
local query=A.request
A.request=function(player,command,args,callback)
 return query(player,command,args,function(response)
  if command=='moveBatch' and args.phase=='movePut' and response.results and #response.results>1 then
   response.results[1],response.results[2]=response.results[2],response.results[1]
  end
  callback(response)
 end)
end
local mismatchStatus,mismatchMoved=scenario(20,20)
assert(mismatchStatus=='uncertain' and mismatchMoved==0,'uncorrelated batch response dispatched native movement')
A.request=query
local throttled=false
A.request=function(player,command,args,callback)
 if command=='moveBatch' and not throttled then throttled=true;callback({status='rateLimited'});return end
 return query(player,command,args,callback)
end
local retryStatus,retryMoved=scenario(20,20)
assert(throttled and retryStatus=='ok' and retryMoved==20,'admission retry lost/replayed transfers')
A.request=query;inventoryMode=false
print('PASS OFFLINE phase batching: reordered response fails closed; bounded admission retry preserves exact native transfers')

-- One changed item fails individually; the remaining authorized items stay queued.
inventoryMode=true
local perItem=Q.Movement.handle;local protectedOne=false
Q.Movement.handle=function(player,command,args)
 if command=='movePut' and not protectedOne then
  local run=Q.Movement.runs[player];local op=run and run.operations[args.operation]
  if op then op.item.favorite=true;protectedOne=true end
 end
 return perItem(player,command,args)
end
local partialStatus,partialMoved,partialFailed=scenario(20,20,nil,1)
Q.Movement.handle=perItem
assert(protectedOne and partialStatus=='ok' and partialMoved==19 and partialFailed==1,'partial batch lost per-item protection semantics')
local delayedCallback,delayedResponse
A.request=function(player,command,args,callback)
 return query(player,command,args,function(response)
  if command=='moveBatch' and args.phase=='movePut' then delayedCallback,delayedResponse=callback,response
  else callback(response) end
 end)
end
local cancelledStatus,cancelledMoved=scenario(20,20,function()
 if delayedCallback then local callback=delayedCallback;delayedCallback=nil;S.cancel(0);callback(delayedResponse) end
end)
A.request=query;inventoryMode=false
assert(cancelledStatus=='cancelled' and cancelledMoved==0,'late grant response escaped cancellation')
print('PASS OFFLINE phase batching: partial item rejection preserves 19/20 authorized transfers; late cancellation dispatches none')

-- A carry is loaded completely before the first PUT; the next TAKE waits for
-- the current carry to be empty. Native groups above remain capped at 20.
do
 local normalWeight=f.player.getMaxWeight
 f.player.getMaxWeight=function() return 6 end
 local phase,loads,unloads='put',0,0
 moveProbe=function(_,from,to)
  if to==carried and phase=='put' then
   assert(#carried.items==0,'next carry began before previous carry was unloaded')
   phase='take';loads=loads+1
  elseif to==dst and phase=='take' then
   assert(#carried.items==4,'walk/unload began before filling the carry')
   phase='put';unloads=unloads+1
  end
 end
 local status,moved=scenario(8,1,nil,1.5)
 assert(status=='ok' and moved==8 and loads==2 and unloads==2)
 -- A server allowance raises the comfort budget, while native storage still caps it.
 f.player.getMaxWeight=function() return 3 end
 SandboxVars.B47ANCEDQuartermaster.CarryAllowance=3
 loads,unloads,phase=0,0,'put'
 status,moved=scenario(8,100,function(step) if step==1 then carried.capacity=6 end end,1.5)
 assert(status=='ok' and moved==8 and loads==2 and unloads==2)
 SandboxVars.B47ANCEDQuartermaster.CarryAllowance=0
 f.player.getMaxWeight=function() return 150 end
 local beforeFirstTake
 moveProbe=function(_,_,to) if to==carried and not beforeFirstTake then beforeFirstTake=rpcCounts.tripNext end end
 status,moved=scenario(601,20,nil,1)
 assert(status=='ok' and moved==601 and beforeFirstTake==1,'waited for the entire source catalog before first carry')
 moveProbe=nil;f.player.getMaxWeight=normalWeight
 print('PASS OFFLINE full carries: fill before unload, no overlapping carry, allowance bounded by native capacity; 601 items start after one 250-item planning slice')
end

do
 local object=f.object(f.square(3,0,0));local alternate=storage(object.containers[1])
 additionalDestination=alternate
 for _,returnToSource in ipairs({false,true}) do
  alternate.items={};alternate.capacity=returnToSource and 0 or 1000
  local filled=false
  local status,moved,failed=scenario(6,20,function(step)
   if step==1 then
    f.network(false,true)
    for _,entry in ipairs({{obj=f.b,priority=100},{obj=object,priority=0}}) do
     local target=assert(Q.Targets.make(entry.obj,0,f.player));local old,_,revision=Q.Store.load(target)
     local cfg=Q.Schema.empty();cfg.items.RoundA=true;cfg.priority=entry.priority
     assert(Q.Store.rawCommit({target=target,original=old,revision=revision},cfg))
    end
    f.network(true,false)
   end
   if not filled and #carried.items==6 then dst.capacity=0;filled=true end
  end,1)
  if returnToSource then
   assert(filled and status=='ok' and moved==0 and failed==6 and #src.items==6 and #carried.items==0,'failed carry was not returned natively to its source')
  else
   assert(filled and status=='ok' and moved==6 and #alternate.items==6 and #carried.items==0,'full destination did not spill carry to alternate matching storage')
  end
 end
 additionalDestination=nil;object.md={};alternate.items={}
 print('PASS OFFLINE native carry fallback: crate fills after TAKE, alternate receives six items; no alternate returns six items to source; no loss/duplication')
end

-- Generic native vehicle source, with an access area far from the vehicle's
-- center. No Workshop Lua is executed and no model-specific IDs are hardcoded.
do
 local oldSource,oldDestination,oldObject=src,dst,f.b
 local oldMetadata=oldObject.md;oldObject.md={}
 local oldVehicleLookup=getVehicleById
 local sq=f.square(12,0,0);local vehicle={};local part={md={}};local calls=0
 local cargo=storage({});src=cargo
 f.b=f.object(f.square(5,0,0));dst=storage(f.b.containers[1])
 function vehicle:getId() return 55 end;function vehicle:getSquare() return sq end
 function vehicle:getPartByIndex(index) if index==0 then return part end end
 function vehicle:canAccessContainer(index,player) return index==0 and player==f.player end
 function vehicle:isInArea(area,player) return area=='CargoAccess' and player:getX()==0 end
 function vehicle:transmitPartModData(p) assert(p==part) end
 function part:getVehicle() return vehicle end;function part:getIndex() return 0 end
 function part:getId() return 'CargoFixture' end;function part:getArea() return 'CargoAccess' end
 function part:getModData() return self.md end;function part:getItemContainer() return cargo end
 function cargo:getParent() return vehicle end;function cargo:getOutermostContainer() return self end
 function cargo:getVehiclePart() return part end
 getVehicleById=function(id) if id==55 then return vehicle end end
 package.loaded['Vehicles/TimedActions/ISPathFindAction']=true
 ISPathFindAction={pathToVehicleArea=function(_,player,v,area)
  assert(v==vehicle and area=='CargoAccess');calls=calls+1
  return W:new(player,f.a.sq)
 end}
 local drift=false
 local status,moved=scenario(6,20,function(_,_,batch)
  if S.active[0] and S.active[0].haul and not drift then drift=true;f.player.square=f.b.sq end
 end,1)
 assert(status=='ok' and moved==6 and calls==1 and #cargo.items==0 and #carried.items==0,'vehicle source/native access-area route failed')
 vehicle.canAccessContainer=function() return false end
 local started,reason=S.start(0,cargo,function() end)
 assert(not started and reason=='invalid','inaccessible vehicle fell through to an unsupported world-object API')
 getVehicleById=oldVehicleLookup;oldObject.md=oldMetadata;src,dst,f.b=oldSource,oldDestination,oldObject
 print('PASS OFFLINE vehicle source: exact native part, server capture/grants, native access-area walk far from center, six native TAKE/PUT moves conserved')
end

-- Real multi-source room orchestration on the same installed native queue fixture.
do
 local RoomSort=require 'B47ANCEDQuartermaster/RoomSort'
 groundMode=false;inventoryMode=false;singlePlayer=false
 getRandomUUID=function() return '33333333-3333-3333-3333-333333333333' end
 getTimestamp=function() return math.floor(getTimestampMs()/1000) end
 getOnlinePlayers=function() return f.list({f.player}) end
 SafeHouse.isSafehouseAllowInteract=function() return true end
 SafeHouse.getSafeHouse=function() end
 f.player.isDead=function() return false end
 f.network(false,true);f.player.square=f.a.sq
 q.queue={};RPC={};E.active={};E.batches={};S.active={};Q.Movement.runs={};Q.Movement.operations={};Q.Bindings.sessions={}
 src.items={};dst.items={};carried.items={};src.capacity=1000;dst.capacity=1000;carried.capacity=1000
 dst.getParent=function() return f.b end;f.b.getContainerIndex=function() return 0 end
 local thirdObject=f.object(f.decor.sq);local third=storage(thirdObject.containers[1])
 third.getParent=function() return thirdObject end;thirdObject.getContainerIndex=function() return 0 end
 for i=1,20 do src.items[#src.items+1]=item(i,1) end
 local correct=item(42,1);correct.getDisplayName=function() return 'RoundB' end;correct.getScriptItem=function() return CATALOG_FIXTURE.items[2] end;src.items[#src.items+1]=correct
 for i=101,107 do local it=item(i,1);it.container=third;third.items[#third.items+1]=it end
 local bag=item(9001,0);bag.class='InventoryContainer';bag.container=carried
 local bagSource=storage({});bag.getInventory=function() return bagSource end
 bag.getDisplayName=function() return 'Carried Bag' end;bag.getScriptItem=function() return CATALOG_FIXTURE.items[4] end
 bagSource.getContainingItem=function() return bag end;bagSource.getParent=function() end
 bagSource.isInCharacterInventory=function() return true end;bagSource.getOutermostContainer=function() return carried end
 carried.items={bag}
 for n=2001,2002 do local it=item(n,1);it.container=bagSource;bagSource.items[#bagSource.items+1]=it end
 for n=3001,3002 do local it=item(n,1);it.container=carried;carried.items[#carried.items+1]=it end
 local initial=assert(Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}}))
 for _,record in pairs(Q.Bindings.sessions[f.player].records) do
  local c=record.target.container;local cfg=Q.Schema.empty()
  if c==src then cfg.items.RoundB=true elseif c==dst or c==third then cfg.items.RoundA=true;cfg.priority=c==dst and 100 or 0 end
  local original,_,revision=Q.Store.load(record.target)
  assert(Q.Store.rawCommit({target=record.target,original=original,revision=revision},cfg))
 end
 local def={getName=function() return 'Storage Room' end}
 for _,sq in pairs(f.squares) do sq.getRoomDef=function() return def end end
 local result,moved,skipped
 f.network(true,false)
 assert(RoomSort.start(0,{kind='nativeRoom'},function(s,n,k) result,moved,skipped=s,n,k end))
 for _=1,3000 do
  f.network(false,true);Q.RoomScopes.tick();f.network(true,false)
  RoomSort.tick();S.tick();E.tick();flush();pump();f.advance(16)
  if result then flush();break end
 end
 assert(result=='ok' and moved==24,'room sweep failed to move misplaced native items')
 assert(#src.items==1 and src.items[1]==correct and #dst.items==24 and #third.items==7 and #carried.items==1 and carried.items[1]==bag and #bagSource.items==0,'room sorting moved correct items or duplicated physical inventory')
 assert(skipped==33 and not RoomSort.active[0] and not Q.Movement.runs[f.player])
 -- Removing source sorting rules after enumeration must invalidate the next
 -- area batch, rather than treating unconfigured stock as misplaced items.
 f.network(false,true)
 local binding=Q.Bindings.sessions[f.player];local sourceRecord
 for _,r in pairs(binding.records) do if r.target.container==src then sourceRecord=r;break end end
 local begun=Q.Trips.handle(f.player,'tripBegin',{session=binding.id,source=sourceRecord.token,area=true,sweep=binding.areaSweep})
 assert(begun.status=='ok')
 local original,_,revision=Q.Store.load(sourceRecord.target)
 assert(Q.Store.rawCommit({target=sourceRecord.target,original=original,revision=revision},Q.Schema.empty()))
 local changed=Q.Trips.handle(f.player,'tripNext',{run=begun.run})
 assert(changed.status=='invalid' and changed.reason=='sourceConfigurationChanged' and #src.items==1)
 assert(Q.Trips.handle(f.player,'tripCancel',{run=begun.run}).status=='ok')
 -- Whole Building uses the same operation, including carried stock, without Rooms.
 local bd={getRooms=function() return f.list({def}) end}
 local building={getDef=function() return bd end}
 def.getID=function() return 1 end;def.getX=function() return 0 end;def.getY=function() return 0 end
 def.getX2=function() return 3 end;def.getY2=function() return 2 end;def.getZ=function() return 0 end
 for _,sq in pairs(f.squares) do sq.building=building end
 SandboxVars.B47ANCEDQuartermaster.WholeBuilding=true
 local extra=item(5001,1);extra.container=carried;carried.items[#carried.items+1]=extra
 local inBag=item(5002,1);inBag.container=bagSource;bagSource.items[#bagSource.items+1]=inBag
 result=nil;moved=nil
 f.network(true,false)
 assert(RoomSort.start(0,{kind='building'},function(s,n,k) result,moved,skipped=s,n,k end))
 for _=1,3000 do
  RoomSort.tick();S.tick();E.tick();flush();pump();f.advance(16)
  if result then flush();break end
 end
 assert(result=='ok' and moved==2 and #dst.items==26 and #src.items==1 and #third.items==7)
 assert(#bagSource.items==0 and #carried.items==1 and carried.items[1]==bag)
 print('PASS OFFLINE whole-building sweep: inventory and unequipped bag included; two additional exact native moves, correct/unconfigured stock preserved')
 print('PASS OFFLINE room sweep: inventory plus unequipped carried bag and three physical sources; 24 exact moves, 33 skips, bag retained, ground excluded, native grouping and cleanup')
end
