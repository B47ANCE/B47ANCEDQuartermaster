-- Production native-action/service paths with host-owned engine-shaped fixtures.
dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
local f=CONTAINER_FIXTURE;local actor=f.player;local list=f.list;local serial=100
function getRandomUUID() serial=serial+1;return 'fixture-ledger-'..serial end
function getGameTime() return {getWorldAgeHours=function() return 42.5 end} end
function getText(key) return key end
actor.isDead=function() return false end
local def={getID=function() return 77 end,getName=function() return 'kitchen' end,getX=function() return 0 end,getY=function() return 0 end,getX2=function() return 2 end,getY2=function() return 2 end,getZ=function() return 0 end}
local building={getDef=function() return {getRooms=function() return list({def}) end} end}
-- Exact native BuildingDef reference remains stable.
local bd=building:getDef();building.getDef=function() return bd end
local room={getRoomDef=function() return def end};local power=true
for _,sq in pairs(f.squares) do
 sq.building=building;sq.getRoom=function() return room end;sq.isBlockedTo=function() return false end;sq.isWindowTo=function() return false end
 sq.haveElectricity=function() return power end;sq.hasGridPower=function() return false end
 sq.canReachTo=function() return true end
end
getCell().getChunkForGridSquare=function() return {} end
actor.getX=function() return actor.square:getX() end;actor.getY=function() return actor.square:getY() end
local function container()
 local c={items={}}
 function c:getItems() return list(self.items) end
 function c:getItemWithID(id) for _,v in ipairs(self.items) do if v:getID()==id then return v end end end
 c.getItemWithIDRecursiv=c.getItemWithID
 function c:AddItem(item) self.items[#self.items+1]=item;item.container=self;return item end
 function c:Remove(item) if self.failRemove==item then error('fixture native removal failed') end;for n,v in ipairs(self.items) do if v==item then table.remove(self.items,n);return end end end -- native Remove can leave a stale container pointer
 function c:containsTypeRecurse(t) for _,v in ipairs(self.items) do if v:getFullType()==t then return true end end;return false end
 function c:getCapacityWeight() return #self.items end
 function c:getEffectiveCapacity() return 100 end
 function c:getType() return 'crate' end
 function c:getContainingItem() end
 function c:getCustomName() return 'Fixture crate' end
 function c:isItemAllowed() return true end
 function c:isRemoveItemAllowed() return true end
 function c:hasRoomFor() return true end
 return c
end
local function item(t,name,count)
 serial=serial+1;local it={id=serial,t=t,name=name or t,count=count or 1,md={},condition=10}
 function it:getID() return self.id end;function it:getFullType() return self.t end;function it:getDisplayName() return self.name end
 function it:getContainer() return self.container end;function it:getCount() return self.count end
 function it:getActualWeight() return .1 end;it.getUnequippedWeight=it.getActualWeight
 function it:getCondition() return self.condition end;function it:getDisplayCategory() return 'Ammo' end
 function it:getModData() return self.md end;function it:hasModData() for _ in pairs(self.md) do return true end;return false end
 function it:getMediaData() return nil end;function it:CanStack(other) return self.t==other.t and self.condition==other.condition end
 function it:getFluidContainer() end
 function it:getWorldItem() end
 function it:isFavorite() return false end;function it:isEquipped() return false end;function it:getAttachedSlot() return -1 end;function it:getIsCraftingConsumed() return false end
 return it
end
local inv=container();actor.getInventory=function() return inv end
local paper=inv:AddItem(item('B47ANCEDQuartermaster.SupplySheet'));local pen=inv:AddItem(item('Base.Pen'));local cd=inv:AddItem(item('Base.Disc_Retail'))
f.a.containers={container()};f.b.containers={container()};f.unrelatedObject.containers={container()}
for i=1,200 do f.a.containers[1]:AddItem(item('Fixture.Ammo','5.56 Fixture Rounds')) end
function instanceItem(t) return item(t) end
local added,removed=0,0
function sendAddItemToContainer() added=added+1 end;function sendRemoveItemFromContainer() removed=removed+1 end
function syncItemModData() end
ISBaseObject={}
function ISBaseObject:derive(name) local c={Type=name,SuperType=self};c.__index=c;setmetatable(c,{__index=self});return c end
package.loaded.ISBaseObject=ISBaseObject
dofile(GAME_ROOT..'/media/lua/shared/TimedActions/ISBaseTimedAction.lua');package.loaded['TimedActions/ISBaseTimedAction']=ISBaseTimedAction
local A=require 'B47ANCEDQuartermaster/Authority';local L=require 'B47ANCEDQuartermaster/Ledger';local C=require 'B47ANCEDQuartermaster/LedgerAction';local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local function complete(offer)
 local action=assert(C:new(actor,offer.token));assert(not C:new(actor,offer.token),'native reconstruction replay accepted')
 action.action={setActionAnim=function() end};action:start();assert(action:getDuration()==offer.seconds*50)
 assert(action:complete());assert(not action:complete(),'duplicate completion changed state')
end
local function run(p)
 assert(L.handle(actor,'ledgerBegin',{item=p:getID(),scopeKind='building'}).status=='ok')
 local duration,actions=0,0
 for n=1,300 do
  local r=L.handle(actor,'ledgerNext',{seconds=0})
  if r.status=='action' then duration=duration+r.seconds;actions=actions+1;complete(r)
  elseif r.status=='walk' then actor.square=getCell():getGridSquare(r.position.x,r.position.y,r.position.z)
  elseif r.status=='done' then return duration,actions
  else assert(r.status=='waiting',r.status) end
 end;error('inspection failed to terminate')
end
local duration,actions=run(paper)
assert(actions==3 and duration==10+3*5+1,'native stack entry timing or empty compartments changed')
assert(inv:getItemWithID(paper:getID())==paper and inv:getItemWithID(pen:getID())==pen)
local view=L.handle(actor,'ledgerRead',{item=paper:getID()})
assert(view.status=='ok' and not view.digital and #view.rows==3 and view.rows[1].quantity==200 and view.rows[1].recorded==42.5)
assert(L.handle(actor,'ledgerRead',{item=paper:getID(),query='5.56'}).status=='invalid','paper gained digital search')
assert(type(view.revision)=='string' and not view.totalRows and not view.totalContainers,'reader leaked private totals or numeric revision counts')
assert(L.handle(actor,'ledgerRead',{item=paper:getID(),entry=2,row=1}).status=='invalid','reader accepted raw private record positions')
-- Stored content is historical, not automatically refreshed.
f.a.containers[1]:AddItem(item('Fixture.Other','Other'))
assert(L.handle(actor,'ledgerRead',{item=paper:getID()}).rows[1].quantity==200)
local access=B47ANCEDQuartermaster.RoomAccess.can
B47ANCEDQuartermaster.RoomAccess.can=function() return false end
view=L.handle(actor,'ledgerRead',{item=paper:getID()});assert(#view.rows==0 and #view.rooms==0 and view.redacted,'private records or room headings disclosed')
B47ANCEDQuartermaster.RoomAccess.can=access
local computer=f.object(actor.square,f.grid,nil,false);computer.getSprite=function() return {name='appliances_com_01_72'} end
local sq=computer:getSquare();local pos={x=sq:getX(),y=sq:getY(),z=sq:getZ(),index=computer:getObjectIndex()}
local offer=L.handle(actor,'ledgerBurn',{item=paper:getID(),cd=cd:getID(),computer=pos});assert(offer.status=='action')
power=false;assert(not L.valid(actor,offer.token,L.grants[offer.token].action));L.stop(actor,offer.token);assert(inv:getItemWithID(cd:getID())==cd and added==0)
power=true
-- Definite failure rolls the output back despite native stale container pointers.
inv.failRemove=cd;offer=L.handle(actor,'ledgerBurn',{item=paper:getID(),cd=cd:getID(),computer=pos})
local failed=assert(C:new(actor,offer.token));failed.action={setActionAnim=function() end};failed:start();assert(not failed:complete());assert(#inv.items==3 and inv:getItemWithID(cd:getID())==cd)
inv.failRemove=nil
offer=L.handle(actor,'ledgerBurn',{item=paper:getID(),cd=cd:getID(),computer=pos});assert(offer.status=='action');complete(offer)
assert(not inv:getItemWithID(cd:getID()) and added==1 and removed==1 and inv:getItemWithID(paper:getID())==paper)
local disc;for _,v in ipairs(inv.items) do if v:getFullType()==Media.disc then disc=v end end;assert(disc)
view=L.handle(actor,'ledgerRead',{item=disc:getID(),computer=pos,query='5.56'});assert(view.status=='ok' and #view.rows==1 and view.digital)
assert(#L.handle(actor,'ledgerRead',{item=disc:getID(),computer=pos,query='5X56'}).rows==0,'search treated punctuation as a pattern')
power=false;assert(L.handle(actor,'ledgerRead',{item=disc:getID(),computer=pos}).status=='LedgerPower');power=true
-- Dedicated constructor sender binding and native clock challenge.
f.network(false,true);local commands={};function sendServerCommand(p,_,command,data) commands[#commands+1]={actor=p,command=command,data=data} end
local other={};local cd2=inv:AddItem(item('Base.Disc_Retail'))
offer=L.handle(actor,'ledgerBurn',{item=paper:getID(),cd=cd2:getID(),computer=pos});assert(offer.status=='action')
assert(not C:new(other,offer.token));local a=assert(C:new(actor,offer.token));local progress=0;a.netAction={getProgress=function() return progress end};assert(a:serverStart())
local challenge=commands[#commands].data.challenge
assert(L.handle(actor,'ledgerConfirm',{token=offer.token,challenge='forged'}).status=='denied')
assert(L.handle(actor,'ledgerConfirm',{token=offer.token,challenge=challenge}).status=='ok');progress=1;assert(a:complete());assert(not a:complete())
-- Stop/resume preserves verified inspections; restart uncertainty requires inspection.
f.network(false,false)
local partial=inv:AddItem(item(Media.sheet));assert(L.handle(actor,'ledgerBegin',{item=partial:getID(),scopeKind='building'}).status=='ok')
local first
for n=1,100 do local r=L.handle(actor,'ledgerNext',{});if r.status=='action' then first=r;break end;assert(r.status=='waiting' or r.status=='walk') end
assert(first);complete(first)
local saved=L.jobs[actor].snapshot;assert(#saved.order==1 and not saved.complete)
assert(L.handle(actor,'ledgerCancel',{}).status=='ok' and #saved.order==1)
local _,resumed=run(partial);assert(resumed==2 and saved.complete and #saved.order==3,'resume duplicated or discarded completed entries')
local changed=inv:AddItem(item(Media.sheet));assert(L.handle(actor,'ledgerBegin',{item=changed:getID(),scopeKind='building'}).status=='ok')
for n=1,100 do local r=L.handle(actor,'ledgerNext',{});if r.status=='action' then first=r;break end end
local old=assert(C:new(actor,first.token));old.action={setActionAnim=function() end};old:start()
f.a.containers[1]:AddItem(item('Fixture.Changed','Changed while writing'))
assert(not old:complete() and #L.jobs[actor].snapshot.order==0,'changed contents committed as a successful inspection')
L.handle(actor,'ledgerCancel',{})
-- Safehouse scope uses server-owned bounds and native floor range, not a radius.
getCell().getMinZ=function() return 0 end;getCell().getMaxZ=function() return 0 end
local house={getId=function() return 'fixture-house' end,getTitle=function() return 'Fixture safehouse' end,getX=function() return 0 end,getX2=function() return 2 end,getY=function() return 0 end,getY2=function() return 2 end}
SafeHouse.getSafehouseList=function() return list({house}) end
local safe=inv:AddItem(item(Media.sheet));assert(L.handle(actor,'ledgerBegin',{item=safe:getID(),scopeKind='safehouse'}).status=='ok')
assert(L.jobs[actor].scope.key=='safehouse:fixture-house');L.cleanup(actor)
-- Exact physical reachability and native rollback/restart recovery.
local reach=actor.square.canReachTo;actor.square.canReachTo=function() return false end
local there=f.b:getSquare();local priorSquare=actor.square;actor.square=f.a:getSquare()
actor.square.canReachTo=function() return false end;assert(not Media.reachable(actor,f.b));actor.square.canReachTo=reach;actor.square=priorSquare
local original=inv:AddItem(item('Base.Disc_Retail'));local unfinished=inv:AddItem(item(Media.disc))
local journal={input=original:getID(),output=unfinished:getID(),phase='outputAdded',snapshot='fixture'}
assert(not Media.recover(actor,journal) and journal.phase=='rolledBack' and inv:getItemWithID(original:getID())==original and not inv:getItemWithID(unfinished:getID()))
local committed=inv:AddItem(item(Media.disc));journal={input=-99999,output=committed:getID(),phase='outputAdded',snapshot='fixture'}
assert(not Media.recover(actor,journal) and journal.phase=='uncertain','absence from one inventory was treated as proof of consumption')
journal.phase='committed';assert(Media.recover(actor,journal)==committed)
local beforeCount=#inv.items;journal={input=-99999,output=-99998,phase='uncertain'};assert(not Media.recover(actor,journal) and journal.phase=='uncertain' and #inv.items==beforeCount,'unknown recovery created inventory')
-- Future schema is preserved; no reset or native mutation.
local data=ModData.getOrCreate('B47ANCEDQuartermasterLedger');data.schema=99
assert(L.handle(actor,'ledgerBegin',{item=paper:getID(),scopeKind='building'}).status~='ok' and data.schema==99)
print('PASS OFFLINE production ledger: 200 native-stack-equivalent rounds, timed physical inspections, static/private paper pages, power/cancellation, conservative CD rollback/conservation, digital literal search and native sender/challenge/replay guards; no PZ runtime claim')

LEDGER_FIXTURE={paper=paper,disc=disc,inv=inv,computer=computer,position=pos,building=building,definition=def,item=item,container=container,run=run,setPower=function(v) power=v end}
