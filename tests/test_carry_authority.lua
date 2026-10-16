-- Real owned server authority; only native inventory mutation is simulated.
dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
local M=require 'B47ANCEDQuartermaster/Movement'
local Q=B47ANCEDQuartermaster;local f=CONTAINER_FIXTURE
local function storage(c)
 c.items={};c.capacity=100
 function c:getItems() return f.list(self.items) end
 function c:getItemWithID(id) for _,it in ipairs(self.items) do if it:getID()==id then return it end end end
 function c:getCapacityWeight() local w=0;for _,it in ipairs(self.items) do w=w+it:getActualWeight() end;return w end
 function c:getEffectiveCapacity() return self.capacity end
 function c:hasRoomFor(_,it) return self:getCapacityWeight()+it:getActualWeight()<=self.capacity end
 function c:isItemAllowed() return true end;function c:isRemoveItemAllowed() return true end
 return c
end
local source=storage(f.a.containers[1]);local dest=storage(f.b.containers[1]);local carried=storage({})
local thirdObject=f.object(f.decor.sq);local third=storage(thirdObject.containers[1])
f.player.getInventory=function() return carried end;f.player.getMaxWeight=function() return 20 end
local discovered=assert(Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}}));local sourceToken
for token,r in pairs(Q.Bindings.sessions[f.player].records) do
 local c=r.target.container
 if c==source then sourceToken=token end
 if c==dest or c==third then
  local cfg=Q.Schema.empty();cfg.items.RoundA=true;cfg.priority=c==dest and 100 or 0
  local original,_,revision=Q.Store.load(r.target)
  assert(Q.Store.commit({target=r.target,original=original,revision=revision},cfg))
 end
end
local seq=0
local function plan()
 seq=seq+1
 local it={container=source,getID=function() return seq end,getActualWeight=function() return 1 end,
  getScriptItem=function() return CATALOG_FIXTURE.items[1] end,getDisplayName=function() return 'RoundA' end,
  isEquipped=function() return false end,isFavorite=function() return false end,getAttachedSlot=function() return -1 end,
  getIsCraftingConsumed=function() return false end}
 -- Capture this exact ID instead of closing over the changing sequence.
 local id=seq;it.getID=function() return id end
 function it:getContainer() return self.container end
 source.items[#source.items+1]=it
 local offer,op=M.planOne(f.player,{session=discovered.session,source=sourceToken,itemID=id})
 assert(offer.status=='ok');return it,offer,op
end
local function reset()
 M.operations={};M.runs={};source.items={};dest.items={};third.items={};carried.items={}
 source.capacity=100;dest.capacity=100;third.capacity=100
end
local function cmd(op,name,actor) return M.handle(actor or f.player,name,{operation=op.id}) end
local function take(it,op)
 assert(cmd(op,'moveTake').status=='ok')
 for i,value in ipairs(source.items) do if value==it then table.remove(source.items,i);break end end
 carried.items[#carried.items+1]=it;it.container=carried
 assert(cmd(op,'moveCarried').status=='ok')
end
reset();local it,offer,op=plan()
M.runs[f.player]={session=discovered.session,operations={[op.id]=op},time=getTimestampMs()}
take(it,op);dest.capacity=0
local spill=cmd(op,'movePut');assert(spill.status=='spill' and op.destination.container==third)
third.capacity=0;dest.capacity=100
assert(cmd(op,'movePut').status=='revert','spill oscillated back to a previously rejected crate')
assert(cmd(op,'moveRevert',{}).status=='invalid','foreign actor received return grant')
local can=Q.RoomAccess.can
Q.RoomAccess.can=function(player,t,permission) return not (t.container==source and permission=='deposit') and can(player,t,permission) end
assert(cmd(op,'moveRevert').reason=='RoomAccessChanged' and it.container==carried,'return bypassed source deposit permission')
Q.RoomAccess.can=can
source.capacity=0;assert(cmd(op,'moveRevert').reason=='sourceRejected');source.capacity=100
assert(cmd(op,'moveRevert').status=='ok' and cmd(op,'moveRevert').status=='invalid','return grant replay')
assert(cmd(op,'moveReverted').status=='waiting','unperformed return credited')
carried.items={};source.items={it};it.container=source
Q.RoomAccess.can=function() return false end
assert(cmd(op,'moveReverted').status=='ok','completed native return lost after later permission change')
Q.RoomAccess.can=can
assert(cmd(op,'moveReverted').status=='invalid','return confirmation replay')

-- Alternate capacity includes other players' pending operations, not just this batch.
reset();local operations={}
for i=1,3 do local value,_,operation=plan();operations[#operations+1]=operation;M.operations[f.player]=operation;take(value,operation) end
M.operations={};local run={session=discovered.session,operations={},time=getTimestampMs()};M.runs[f.player]=run
for _,operation in ipairs(operations) do run.operations[operation.id]=operation end
dest.capacity=0;third.capacity=2
assert(cmd(operations[1],'movePut').status=='spill')
assert(cmd(operations[2],'movePut').status=='spill')
assert(cmd(operations[3],'movePut').status=='revert','alternate over-reserved beyond native capacity')
assert(#carried.items==3 and #dest.items==0 and #third.items==0,'authority moved inventory directly')
f.a.md.B47MovementInstance='replaced'
assert(cmd(operations[3],'moveRevert').reason=='sourceMarkerChanged','stale source return granted')
print('PASS OFFLINE carry authority: alternate destination, no spill cycles, pending capacity, return permissions/capacity/identity, confirmation/replay and exact conservation')
