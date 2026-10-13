-- Source authority tests only; engine-shaped fixtures, not live MP.
dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
require 'B47ANCEDQuartermaster/Authority'
local f=CONTAINER_FIXTURE;local Q=B47ANCEDQuartermaster;local G=Q.GroundSources
local worlds={};local sq=f.a.sq;local c=f.a.containers[1]
function sq:getWorldObjects() local l=f.list(worlds);function l:contains(o) for _,v in ipairs(self) do if v==o then return true end end;return false end;return l end
function sq:isBlockedTo() return self.blocked==true end
local it={id=1900000000};function it:getID() return self.id end;function it:getContainer() return c end;function it:getWorldItem() return self.world end
local obj={getSquare=function() return sq end,getItem=function() return it end};it.world=obj;worlds={obj}
local hint=G.descriptor({obj=obj,item=it});local t=assert(G.resolve(hint,f.player));assert(t.item==it)
assert(G.snapshot(f.player,{hint,hint}):getItems():size()==1,'duplicate view rows were not deduplicated')
local held=assert(G.snapshot(f.player,{hint}));assert(held:getItemWithID(it.id)==it)
worlds={};assert(not G.valid(t,f.player) and not held:getItemWithID(it.id),'removed world reference accepted')
worlds={obj};sq.blocked=true;assert(not G.resolve(hint,f.player));sq.blocked=false
local other={getSquare=function() return sq end,getItem=function() return it end};worlds={obj,other};assert(not G.resolve(hint,f.player),'ambiguous native ID accepted');worlds={obj}
f.network(false,true);SafeHouse.isSafehouseAllowLoot=function() return false end;assert(not G.snapshot(f.player,{hint}));SafeHouse.isSafehouseAllowLoot=function() return true end
local malformed={{ground=true,x=0/0,y=0,z=0,itemID=it.id},{ground=true,x=0,y=0,z=0,itemID='x'},{ground=true,x=999999999,y=0,z=0,itemID=it.id},{[2]=hint},{[1]=hint,extra=hint}}
for _,bad in ipairs(malformed) do assert(not G.snapshot(f.player,bad.ground and {bad} or bad)) end
local discovery=assert(Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}}))
local foreign={ground=true,x=20,y=0,z=0,itemID=it.id};assert(not G.snapshot(f.player,{foreign}))
local physical=f.b.containers[1];local pit={getID=function() return 99 end};physical.getItemWithID=function(_,id) return id==99 and pit or nil end
local target;for _,rec in pairs(Q.Bindings.sessions[f.player].records) do if rec.target.container==physical then target=rec.target end end
local ph=Q.Targets.descriptor(target);ph.itemID=99;ph.physical=true
local mixed=assert(G.snapshot(f.player,{hint,ph,ph},discovery.session));assert(mixed:getItems():size()==2 and mixed:getItemWithID(99)==pit)
assert(not G.snapshot(f.player,{ph},'forged-session'))
physical.getItemWithID=function() end;assert(not mixed:getItemWithID(99),'changed physical source accepted')
assert(not G.snapshot(f.player,{ph},discovery.session))
print('PASS OFFLINE dev25 source authority: retained references, duplicate/ambiguous IDs, large native IDs, walls, safehouse, malformed hints and mixed physical sources')
