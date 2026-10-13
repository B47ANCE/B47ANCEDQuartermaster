-- Engine-shaped fixtures: offline checks, not native PZ acceptance.
dofile(TEST_ROOT..'/fixtures/containers.lua')
require 'B47ANCEDQuartermaster/Session'
local f=CONTAINER_FIXTURE
local Q=B47ANCEDQuartermaster
local T,C,S,A=Q.Targets,Q.Configuration,Q.Session,Q.Authority
local a,b,player=f.a,f.b,f.player
local ta,tb,tu=T.make(a,0,player),T.make(b,0,player),T.make(f.unrelatedObject,0,player)
f.origin,f.unrelated=ta,tu
assert(#T.discover(ta,player)==3 and T.discover(ta,player)[1].container==ta.container)
assert(#T.siblings(ta,player)==2 and #T.siblings(tu,player)==1)
local odd=f.object(f.square(3,0,0),f.grid,{x=0,y=0,z=0})
a.members={a,b,f.decor,odd};assert(#T.siblings(ta,player)==2)
for _,r in ipairs({1,5,10,20,30}) do
    SandboxVars.B47ANCEDQuartermaster.ContainerRange=r
    local near=f.object(f.square(r,r,0));local far=f.object(f.square(r+1,r,0))
    assert(T.inArea(ta,T.make(near,0,player)));assert(not T.inArea(ta,T.make(far,0,player)))
end
local def={rooms=f.list()};local building={getDef=function() return def end}
function def:getRooms() return self.rooms end
local upper=f.object(f.square(0,0,1,building))
a.sq.building=building;b.sq.building=building
def.rooms=f.list({{getIsoRoom=function() return {getSquares=function() return f.list({a.sq,b.sq,f.unrelatedObject.sq}) end} end},{getIsoRoom=function() return {getSquares=function() return f.list({upper.sq}) end} end}})
SandboxVars.B47ANCEDQuartermaster.WholeBuilding=true
assert(#T.discover(ta,player)==3 and T.inArea(ta,T.make(upper,0,player)) and not T.inArea(ta,tu))
local farRoom=f.square(45,38,2,building)
local farObject=f.object(farRoom)
local roomDef={getX=function() return 45 end,getX2=function() return 46 end,
    getY=function() return 38 end,getY2=function() return 39 end,getZ=function() return 2 end}
def.rooms[#def.rooms+1]=roomDef
assert(#T.discover(ta,player)==4 and T.inArea(ta,T.make(farObject,0,player)),
    'Entire Building was truncated by Tile Radius or excluded another loaded floor')
SandboxVars.B47ANCEDQuartermaster.WholeBuilding=false
SandboxVars.B47ANCEDQuartermaster.ContainerRange=10
local s=S.new(ta,0);local result
s:open(function(x) result=x end)
assert(result=='ok' and s.selected and f.sent()==0)
s.selected.working.cats.B47_Food=true;s.selected.working.presets.Kit=7;s.selected.working.priority=4
local originalGetItems=a.containers[1].getItems
a.containers[1].getItems=function() return f.list({{getDisplayName=function() return 'New contents' end,
    getFullType=function() return 'Fixture.New' end,getScriptItem=function() return nil end}}) end
s:refresh(function(x) result=x end)
assert(result=='ok' and s.selected.contents['New contents'] and s.selected.working.priority==4 and f.sent()==0,'refresh lost edits or stale contents')
a.containers[1].getItems=originalGetItems
s.whole=true;s:applyWhole(function(x) result=x end)
assert(result=='ok' and f.sent()==0 and s:record(tb).working.cats.B47_Food)
assert(not s:record(tu).working,'discovery eagerly loaded unrelated configuration')
s:select(tb,function(x) result=x end);assert(not s.whole)
s.selected.working.cats={B47_Beverages=true}
s:select(ta,function() end);assert(s.selected.working.cats.B47_Food)
s:save(function(x) result=x end)
assert(result=='ok' and f.sent()==2 and C.read(ta).cats.B47_Food and C.read(tb).cats.B47_Beverages)
assert(C.read(ta).presets.Kit==7 and C.read(tb).priority==4)
assert(not a.md.LSBox and not b.md.LSBox,'legacy data written')
s:save(function(x) result=x end);assert(f.sent()==2,'clean targets wrote data')
s:select(tb,function() end);s.selected.working.cats.B47_Medical=true;s:close();assert(not C.read(tb).cats.B47_Medical)
local s2=S.new(ta,0);s2:open(function() end);s2.selected.working.items.Shells=true
a.md.B47ANCEDQuartermaster.containers['0'].config.cats.External=true
a.md.B47ANCEDQuartermaster.containers['0'].revision=2
s2:save(function(x) result=x end);assert(result=='partial' and s2.selected.error=='conflict' and not C.read(ta).items.Shells)
assert(s2:dirty(s2.selected))
-- One failed target must not mark clean; the other can commit successfully.
local s3=S.new(ta,0);s3:open(function() end);s3.selected.working.priority=8
s3:select(tb,function() end);s3.selected.working.priority=9
b.sq.objects[1]=f.object(b.sq)
s3:save(function(x) result=x end)
assert(result=='partial' and s3:dirty(s3:record(tb)) and not s3:dirty(s3:record(ta)))
assert(C.read(ta).priority==8 and b.md.B47ANCEDQuartermaster.containers['0'].config.priority==4)
assert(not C.valid({cats={},items={},presets={},priority=0/0}))
assert(C.valid({cats={},items={},presets={},priority=10000}))
assert(not C.valid({cats={},items={},presets={},priority=0,WholeContainer=true}))
f.network(false,true);SafeHouse.isSafehouseAllowLoot=function() return false end
assert(not T.make(a,0,player))
SafeHouse.isSafehouseAllowLoot=function() return true end
f.network(true,false)
assert(A.handle(player,'discover',{scope={x=0,y=0,z=0}}).status=='invalid')
f.network(false,false)
print('PASS containers: geometry, lazy handle loading, staged Save/Cancel, conflict, partial save, native-only writes, authority')
