dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
require 'B47ANCEDQuartermaster/Authority'
local Q=B47ANCEDQuartermaster;local f=CONTAINER_FIXTURE
local Storage=Q.AllocationStorage;local C=Q.AllocationCapacity;local P=Q.AllocationProfile
local float=require('B47ANCEDQuartermaster/NativeFloat').round
local category=Q.Categorizer.nativeID('Food')
local script=CATALOG_FIXTURE.script('Steak','normal',nil,'Food')
local function item(c,weight)
 return {getContainer=function() return c end,getFullType=function() return 'Base.Steak' end,getUnequippedWeight=function() return weight end,
  getScriptItem=function() return script end,getDisplayName=function() return 'Steak' end,getDisplayCategory=function() return 'Food' end}
end
local function container(c)
 c.items={};c.getItems=function(self) return f.list(self.items) end
 c.getEffectiveCapacity=function() return 50 end
 c.getCapacityWeight=function(self) local n=0;for _,it in ipairs(self.items) do n=float(n+it:getUnequippedWeight()) end;return n end
 c.isItemAllowed=function() return true end;c.hasRoomFor=function() return true end
 return c
end
local a,b=container(f.a.containers[1]),container(f.b.containers[1])
a.items={item(a,5)};b.items={item(b,5)}
local ta,tb=Q.Targets.make(f.a,0,f.player),Q.Targets.make(f.b,0,f.player)
local parts=assert(Storage.atomic(f.player,{ta,tb},getTimestampMs()+100))
assert(parts[1].scope.categories[category]==5 and parts[2].capacity==50)
local used=b.getCapacityWeight;b.getCapacityWeight=function() return 6 end
local unknown,reason=Storage.atomic(f.player,{tb},getTimestampMs()+100)
assert(not unknown and reason=='AllocationOccupancyUnavailable','incomplete native contents authorized quota')
b.getCapacityWeight=used
assert(not Storage.atomic(f.player,{ta},getTimestampMs()),'snapshot deadline granted a truncated scope')
local config=Q.Schema.empty();config.cats[category]=true;config.allocation=P.empty();config.allocation.cats[category]=25
for _,target in ipairs({ta,tb}) do
 local current,_,revision=Q.Store.load(target,f.player)
 assert(Q.Store.commit({target=target,original=current,revision=revision},config,f.player))
end
local incoming=item({},5);local R=Q.AllocationRuntime
local function operation(id,it)
 return {id=id,item=it or incoming,destination=tb,config=Q.Schema.copy(config),effective=Q.Schema.effective(config,{}),phase='carried'}
end
local first=operation('actor-a');assert(R.admit(f.player,first))
local second=operation('actor-b',item({},5))
local actor={};for key,value in pairs(f.player) do actor[key]=value end
assert(not R.admit(actor,second),'two actors double-spent container quota')
assert(R.admit(f.player,first),'reservation replay double-counted the exact item')
first.phase='put';R.release(first,'unknown');assert(R.diagnostics().reservations==1,'unknown PUT released reserved capacity')
assert(not R.admit(actor,second))
R.release(first,'notSubmitted');assert(R.diagnostics().reservations==0)
assert(R.admit(actor,second));R.release(second)
local original,_,revision=Q.Store.load(tb,f.player)
assert(Q.Store.commit({target=tb,original=original,revision=revision},config,f.player))
local stale,why=R.admit(actor,second)
assert(stale==false and why=='configurationChanged','same-value configuration revision revived stale admission')
local discovery=assert(Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}}));local token
for _,meta in ipairs(discovery.targets) do local record=Q.Bindings.target(f.player,discovery.session,meta.token);if record.target.obj==f.b then token=meta.token end end
local inspect=require 'B47ANCEDQuartermaster/AllocationInspection'
local restricted=P.empty();restricted.items['Base.Steak']=1
local status=inspect.handle(f.player,{session=discovery.session,token=token,profile=restricted})
assert(status.status=='ok' and #status.over==1 and status.over[1].used==5 and status.advisory)
local permissions=Q.RoomAccess.can;local reads=0;local getItems=b.getItems
Q.RoomAccess.can=function(player,target,action) if action=='inspect' then return false end;return permissions(player,target,action) end
b.getItems=function(self) reads=reads+1;return getItems(self) end
assert(inspect.handle(f.player,{session=discovery.session,token=token,profile=restricted}).status=='RoomAccessDenied' and reads==0,'capacity inspection read contents without inspect permission')
Q.RoomAccess.can=permissions;b.getItems=getItems
-- Internal room accounting counts opaque stock but never adds opaque capacity.
parts=assert(Storage.atomic(f.player,{ta,tb},getTimestampMs()+100));parts[1].permitted=false
local scope=assert(Storage.scope(f.player,incoming,parts,{},getTimestampMs()+100))
assert(scope.capacity==50 and scope.used==5 and scope.categories[category]==10)
local roomProfile=P.empty();roomProfile.cats[category]=25
local row=assert(Storage.item(incoming));row.destination=b
assert(not C.check(roomProfile,scope,{},row),'opaque stock allowed cross-actor room quota overspend')
local existing=assert(Storage.item(a.items[1]));existing.destination=b
assert(C.check(roomProfile,scope,{},existing),'zero aggregate growth became automatic eviction/rejection')
roomProfile.cats[category]=0;assert(not C.check(roomProfile,scope,{},existing),'intra-room move bypassed hard zero')
assert(R.enforcing()==false and R.mode()==2,'unvalidated enforcement activated')
print('PASS OFFLINE allocation native-shaped snapshots, incomplete occupancy fail-closed, deadlines, cross-actor admissions, replay, unknown PUT retention, opaque-room accounting and native activation gate')
