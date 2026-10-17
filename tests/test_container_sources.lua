-- Native-shaped source identity/permission tests; no third-party Lua is loaded.
dofile(TEST_ROOT..'/fixtures/containers.lua')
dofile(TEST_ROOT..'/fixtures/catalog.lua')
local M=require 'B47ANCEDQuartermaster/Movement'
local Q=B47ANCEDQuartermaster;local C=require 'B47ANCEDQuartermaster/ContainerSources'
local f=CONTAINER_FIXTURE;local player=f.player;f.network(false,true)
local function container(parent)
 local c={items={},parent=parent}
 function c:getItems() return f.list(self.items) end
 function c:getItemWithID(id) for _,it in ipairs(self.items) do if it:getID()==id then return it end end end
 function c:getContainingItem() return self.bag end
 function c:getParent() return self.parent end
 function c:getType() return 'crate' end
 function c:getOutermostContainer() if self.bag then return self.bag:getContainer():getOutermostContainer() end;return self end
 function c:getVehiclePart() return self.part end
 function c:isItemAllowed() return true end
 function c:isRemoveItemAllowed() return true end
 function c:hasRoomFor() return true end
 function c:getCapacityWeight() return #self.items end
 return c
end
local inventory=container(player)
function player:getInventory() return inventory end
function player:getMaxWeight() return 20 end
local sq=f.square(3,0,0);local vehicles={};local access,area=true,true
local vehicle={md={}}
function vehicle:getId() return 31 end
function vehicle:getSquare() return sq end
function vehicle:getPartByIndex(n) if n==0 then return self.part end end
function vehicle:canAccessContainer(n,who) return access and n==0 and who==player end
function vehicle:isInArea(_,who) return area and who==player end
function vehicle:transmitPartModData(part) assert(part==self.part);self.transmissions=(self.transmissions or 0)+1 end
local part={md={}};vehicle.part=part;vehicles[31]=vehicle
function part:getVehicle() return vehicle end
function part:getIndex() return 0 end
function part:getId() return 'ModdedCargoBay' end
function part:getArea() return 'CargoAccess' end
function part:getModData() return self.md end
local cargo=container(vehicle);cargo.part=part
function part:getItemContainer() return cargo end
getVehicleById=function(id) return vehicles[id] end
local session={id='source-fixture',records={}}
local hint=assert(C.hint(cargo,player));local target=assert(C.capture(player,hint,session))
local meta=M.identity(target);assert(meta.external and meta.vehicle==31 and meta.part=='ModdedCargoBay')
assert(C.resolve(meta,player).container==cargo and C.reachable(target,player))
local transmitted=vehicle.transmissions;M.identity(target);assert(vehicle.transmissions==transmitted,'unchanged identity retransmitted')
access=false;assert(C.valid(target,player,false) and not C.reachable(target,player) and not C.capture(player,hint,session));access=true
area=false;assert(not C.capture(player,hint,session) and not C.reachable(target,player));area=true
vehicles[31]={};assert(not C.valid(target,player,false) and not C.resolve(meta,player));vehicles[31]=vehicle
local oldPart=vehicle.part;vehicle.part={};assert(not C.valid(target,player,false));vehicle.part=oldPart
local originalSquare=sq;sq=f.square(4,0,0);assert(not C.valid(target,player,false) and not C.resolve(meta,player));sq=originalSquare
local loot=SafeHouse.isSafehouseAllowLoot;SafeHouse.isSafehouseAllowLoot=function() return false end
assert(not C.capture(player,hint,session));SafeHouse.isSafehouseAllowLoot=loot
local function bag(id,parent)
 local b={class='InventoryContainer'};local c=container();c.bag=b
 function b:getID() return id end;function b:getContainer() return parent end;function b:getInventory() return c end
 parent.items[#parent.items+1]=b;return b,c
end
local first,inside=bag(-80,cargo);local second,nested=bag(81,inside)
local nestedHint=assert(C.hint(nested,player));assert(#nestedHint.bags==2)
local nestedTarget=assert(C.capture(player,nestedHint,session));local nestedMeta=M.identity(nestedTarget)
assert(C.resolve(nestedMeta,player).container==nested)
inside.items={};assert(not C.valid(nestedTarget,player,false) and not C.resolve(nestedMeta,player));inside.items={second}
for _,bad in ipairs({{vehicle=31,index=-1,part='ModdedCargoBay',bags={}},
 {vehicle=31,index=0,part='WrongPart',bags={}}, {vehicle=31,index=0,part='ModdedCargoBay',bags={[2]=-80}},
 {vehicle=31,index=0,part='ModdedCargoBay',bags={0/0}}, {vehicle=31,index=0,part='ModdedCargoBay',bags={999}}}) do
 assert(not C.capture(player,bad,session),'malformed or stale vehicle source accepted')
end
local discovery=assert(Q.Bindings.discover(player,{scope={x=0,y=0,z=0}}));local bound=Q.Bindings.sessions[player]
local physical=f.a.containers[1];physical.items={}
function physical:getItemWithID(id) for _,it in ipairs(self.items) do if it:getID()==id then return it end end end
function physical:getOutermostContainer() return self end
function physical:getParent() return f.a end
function f.a:getContainerIndex(c) if c==physical then return 0 end end
local stored,storedInside=bag(90,physical)
local storedHint=assert(C.hint(storedInside,player));local storedTarget=assert(C.capture(player,storedHint,bound))
assert(C.resolve(M.identity(storedTarget),player).container==storedInside)
assert(not C.capture(player,storedHint,{id='foreign',records={}}),'undiscovered physical root accepted')
physical.items={};assert(not C.valid(storedTarget,player,false))
f.network(true,false);assert(not C.capture(player,hint,session),'client captured authoritative handle')
print('PASS OFFLINE external sources: vehicle parts, nested vehicle/world bags, marker reuse, ID/part replacement, movement, access, safehouse and malformed hints')
