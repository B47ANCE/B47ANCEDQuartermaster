-- Offline only: native-shaped authority fixtures, not actual MP replication.
dofile(TEST_ROOT..'/fixtures/containers.lua')
dofile(TEST_ROOT..'/fixtures/catalog.lua')
local f=CONTAINER_FIXTURE
local ticks={};Events={OnTick={Add=function(fn) ticks[#ticks+1]=fn end}}
Events.OnClientCommand={Add=function() end};Events.OnServerCommand={Add=function() end}
Events.OnObjectAboutToBeRemoved={Add=function() end}
local md={};function f.player:getModData() return md end
function f.player:getDisplayName() return 'A' end
function f.player:getMaxWeight() return 100 end
function f.player:getWornItems() return f.list() end
function f.player:getPrimaryHandItem() end
function f.player:getSecondaryHandItem() end
getScriptManager=function() return {FindItem=function(_,t) if t=='Base.Nails' or t=='Base.Glue' then return {getDisplayName=function() return t end} end end} end
local function container(c,obj)
    c.items={};c.room=true
    function c:getItems() return f.list(self.items) end
    function c:getItemWithID(id) for _,it in ipairs(self.items) do if it:getID()==id then return it end end end
    c.getItemWithIDRecursiv=c.getItemWithID
    function c:getParent() return obj end
    function c:getContainingItem() end
    function c:hasRoomFor() return self.room end
    function c:isItemAllowed() return true end
    function c:isRemoveItemAllowed() return true end
    function c:getCapacityWeight() return #self.items end
    function c:getEffectiveCapacity() return 100 end
    if obj then function obj:getContainerIndex() return 0 end end
    return c
end
local carried=container({});function f.player:getInventory() return carried end
local a,b=container(f.a.containers[1],f.a),container(f.b.containers[1],f.b)
container(f.unrelatedObject.containers[1],f.unrelatedObject)
local function item(id,c,t)
    local it={id=id,container=c,md={}}
    function it:getID() return self.id end
    function it:getFullType() return t or 'Base.Nails' end
    function it:getModData() return self.md end
    function it:getContainer() return self.container end
    function it:isFavorite() return false end
    function it:isEquipped() return false end
    function it:getAttachedSlot() return -1 end
    function it:getIsCraftingConsumed() return false end
    function it:getActualWeight() return 1 end
    function it:getDisplayName() return 'Nails' end
    c.items[#c.items+1]=it
    return it
end
local A=require 'B47ANCEDQuartermaster/Authority'
local Q=B47ANCEDQuartermaster
local D,P,H,M=Q.Dibs,Q.Personal,Q.Shopping,Q.Movement
local x=item(1,a)
local other=setmetatable({ownMD={}}, {__index=f.player})
function other:getUsername() return 'account-b' end
function other:getDisplayName() return 'B' end
function other:getModData() return self.ownMD end
f.network(false,true)
local syncs=0;function syncItemModData() syncs=syncs+1 end
assert(D.transition(f.player,x,'wanted'))
assert(D.transition(other,x,'wanted'))
local details=D.details(x);assert(details.wanted[1].label=='A' and details.wanted[2].label=='B')
local first=details.wanted[1].order
assert(D.transition(f.player,x,'wanted') and D.details(x).wanted[1].order==first,'repeated Wanted moved rank')
assert(D.transition(f.player,x,'needed'))
assert(#D.details(x).wanted==1 and D.details(x).needed[1].label=='A')
assert(D.transition(f.player,x,'wanted'))
assert(D.details(x).wanted[1].label=='B' and D.details(x).wanted[2].label=='A')
assert(D.transition(f.player,x,'none'))
assert(#D.details(x).wanted==1)
assert(D.transition(f.player,x,'needed') and D.transition(f.player,x,'none'))
assert(D.transition(f.player,x,'wanted') and D.details(x).wanted[2].order>first)
assert(syncs>0)
-- Server retains exact references; foreign player cannot use inspection capability.
local discovery=Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}})
local preserved=Q.Bindings.sessions[f.player]
local inspected=A.handle(f.player,'dibsInspect',{ids={1}});assert(inspected.status=='ok')
assert(Q.Bindings.sessions[f.player]==preserved,'Dibs replaced sorting session')
assert(A.handle(other,'dibsChange',{token=inspected.token,state='none'}).status=='invalid')
assert(A.handle(f.player,'dibsChange',{token=inspected.token,state='none',owner='account-b'}).status=='ok')
assert(D.details(x).wanted[1].label=='B','cleared another player')
local snapshot=P.snapshot(f.player)
assert(P.change(f.player,{kind='wish',fullType='Base.Nails',quantity=222,revision=snapshot.revision}).status=='ok')
snapshot=P.snapshot(f.player);assert(snapshot.wish['Base.Nails']==222 and snapshot.wishActive==true and snapshot.progress==nil)
assert(P.snapshot(other).wish['Base.Nails']==1,'physical Wanted did not establish target-one Wish')
assert(P.change(f.player,{kind='wish',fullType='Base.Nails',quantity=3.5,revision=snapshot.revision}).status=='invalid')
assert(P.change(f.player,{kind='wish',fullType='fake',quantity=3,revision=snapshot.revision}).status=='invalid')
assert(P.change(f.player,{kind='wish',fullType='Base.Nails',quantity=111,revision=snapshot.revision}).status=='ok')
snapshot=P.snapshot(f.player)
assert(P.change(f.player,{kind='wish',fullType='Base.Nails',quantity=0,revision=snapshot.revision}).status=='ok')
local y=item(2,a);local z=item(3,b);item(4,b)
snapshot=P.snapshot(f.player)
assert(P.change(f.player,{kind='shopping',fullType='Base.Nails',quantity=3,revision=snapshot.revision}).status=='ok')
local begin=H.handle(f.player,'shoppingBegin',{});assert(begin.status=='ok' and begin.progress.known and begin.progress.total==3 and begin.progress.completed==0)
assert(Q.Bindings.sessions[f.player]==preserved,'Shopping replaced sorting session')
local function withdraw()
    local before=M.runs[f.player].collected
    local offer=H.handle(f.player,'shoppingNext',{run=begin.run});assert(offer.status=='ok' and offer.withdrawal and not offer.destination and offer.progress.completed==before)
    local run=M.runs[f.player];local op=run.operations[offer.operation]
    assert(M.handle(f.player,'movePut',{operation=op.id}).status=='invalid')
    assert(M.handle(f.player,'moveTake',{operation=op.id}).status=='ok')
    local old=op.item:getModData().B47Dibs
    for i,it in ipairs(op.container.items) do if it==op.item then table.remove(op.container.items,i);break end end
    carried.items[#carried.items+1]=op.item;op.item.container=carried
    assert(M.handle(f.player,'moveCarried',{operation=op.id}).status=='ok')
    assert(op.item:getModData().B47Dibs==old,'withdrawal lost Dibs')
    assert(M.handle(f.player,'moveCarried',{operation=op.id}).status=='invalid','duplicate confirmation')
    return op.item
end
assert(withdraw()==x and withdraw()==y and withdraw()==z,'source/item order nondeterministic')
assert(H.handle(f.player,'shoppingNext',{run=begin.run}).status=='done')
assert(#carried.items==3 and #b.items==1 and not P.snapshot(f.player).shopping['Base.Nails'],'over-collection')
-- Gross six minus three already carried: one available, two outstanding.
snapshot=P.snapshot(f.player);P.change(f.player,{kind='shopping',fullType='Base.Nails',quantity=6,revision=snapshot.revision})
begin=H.handle(f.player,'shoppingBegin',{});withdraw()
assert(H.handle(f.player,'shoppingNext',{run=begin.run}).status=='done')
assert(P.snapshot(f.player).shopping['Base.Nails']==2)
-- Same native ID replacement cannot consume a retained grant.
local fresh=item(9,a);begin=H.handle(f.player,'shoppingBegin',{})
local offer=H.handle(f.player,'shoppingNext',{run=begin.run})
a.items={};item(9,a)
assert(M.handle(f.player,'moveTake',{operation=offer.operation}).status=='invalid')
M.handle(f.player,'moveCancel',{operation=offer.operation})
H.handle(f.player,'shoppingCancel',{run=begin.run})
-- Capacity ends cleanly; no invented staging or list progress.
carried.room=false;begin=H.handle(f.player,'shoppingBegin',{})
assert(H.handle(f.player,'shoppingNext',{run=begin.run}).status=='capacity')
assert(P.snapshot(f.player).shopping['Base.Nails']==2);carried.room=true
-- Cancel after native dispatch retains operation until authoritative arrival.
begin=H.handle(f.player,'shoppingBegin',{});offer=H.handle(f.player,'shoppingNext',{run=begin.run})
local op=M.runs[f.player].operations[offer.operation]
assert(M.handle(f.player,'moveTake',{operation=op.id}).status=='ok')
assert(H.handle(f.player,'shoppingCancel',{run=begin.run}).status=='ok')
a.items={};carried.items[#carried.items+1]=op.item;op.item.container=carried
for _,tick in ipairs(ticks) do tick() end
assert(P.snapshot(f.player).shopping['Base.Nails']==1 and not M.runs[f.player],'cancelled completed TAKE not accounted')
-- Same account after reconnect uses same list; native item serialization contract
-- retains table data in fixtures. Actual native save/load remains untested.
assert(P.snapshot(setmetatable({}, {__index=f.player})).shopping['Base.Nails']==1)
-- A granted TAKE known not to have been submitted must not strand shopping.
do
 local value=item(100,a)
 local pending={id='unsubmitted',time=getTimestampMs(),withdrawal=true,phase='take',item=value,carrier=carried}
 M.runs[f.player]={id='cancel-probe',kind='shopping',time=getTimestampMs(),operations={unsubmitted=pending},collected=0}
 assert(M.handle(f.player,'moveCancel',{operation=pending.id,outcome='invalid'}).status=='invalid')
 assert(M.runs[f.player].operations[pending.id]==pending,'malformed cancellation released a grant')
 assert(M.handle(f.player,'moveCancel',{operation=pending.id,outcome='notSubmitted'}).status=='ok')
 assert(H.handle(f.player,'shoppingCancel',{run='cancel-probe'}).status=='ok')
 assert(not M.runs[f.player],'known-unsubmitted TAKE kept the server busy')
 assert(H.handle(f.player,'shoppingBegin',{}).status=='ok')
 local run=M.runs[f.player];H.handle(f.player,'shoppingCancel',{run=run.id})
end
f.network(true,false)
assert(A.handle(f.player,'personalChange',{}).status=='invalid')
assert(not D.transition(f.player,x,'needed'))
print('PASS OFFLINE consolidated: per-player Dibs/order/capabilities, exact/partial withdrawals, stale identity, capacity, cancellation and current Wish targets')
