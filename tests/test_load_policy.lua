dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
local Q=require 'B47ANCEDQuartermaster/Authority';local f=CONTAINER_FIXTURE
local L=B47ANCEDQuartermaster.LoadPolicy;local C=require 'B47ANCEDQuartermaster/CarryBudget'
f.network(false,true)
local used,capacity=18,50
local inventory={getCapacityWeight=function() return used end,getEffectiveCapacity=function() return capacity end}
f.player.getInventory=function() return inventory end;f.player.getMaxWeight=function() return 20 end
local state=L.handle(f.player,'loadGet',{});assert(state.status=='ok' and state.policy.enabled==false and C.free(f.player)==2)
local revision=state.policy.revision
local function change(enabled,value)
 local r=L.handle(f.player,'loadChange',{revision=revision,enabled=enabled,utilization=value})
 if r.status=='ok' then revision=r.policy.revision end;return r
end
for _,util in ipairs({50,75,100}) do
 assert(change(true,util).status=='ok');assert(C.free(f.player)==50*util/100-18)
end
used=50;assert(C.free(f.player)==0);used=51;assert(C.free(f.player)==0);used=18
local id,data=B47ANCEDQuartermaster.Personal.identity(f.player)
for _,bad in ipairs({-1,49,101,75.5,0/0,math.huge,'100',false}) do
 assert(change(true,bad).status=='invalid' and data.loadPolicy.revision==revision,'invalid percentage changed persisted intent')
end
assert(L.handle(f.player,'loadChange',{revision=revision-1,enabled=false,utilization=100}).status=='conflict')
B47ANCEDQuartermaster.Movement.runs[f.player]={}
assert(change(false,100).status=='busy');B47ANCEDQuartermaster.Movement.runs[f.player]=nil
capacity=40;assert(C.limit(f.player)==40,'hard maximum was cached instead of re-read')
capacity=0/0;assert(C.limit(f.player)==0 and change(true,100).status=='unsupported');capacity=50
local equipped=true;local carrier={getContainingItem=function() return {isEquipped=function() return equipped end,getWeightReduction=function() return 50 end} end}
local item={getActualWeight=function() return 3 end,getUnequippedWeight=function() return 10 end}
used=45;assert(C.accepts(f.player,carrier,item));equipped=false;assert(not C.accepts(f.player,carrier,item));used=18
L.cleanup(f.player);assert(L.get(f.player).enabled,'reconnect dropped preference')
local saved=data.loadPolicy;data.loadPolicy={schema=99};assert(not L.get(f.player) and C.limit(f.player)==0 and data.loadPolicy.schema==99,'future data was reset')
data.loadPolicy=saved;assert(change(false,50).status=='ok' and C.free(f.player)==2)
f.network(true,false);assert(L.handle(f.player,'loadChange',{}).status=='invalid' and not L.get(f.player),'client ran authoritative preference logic')
local P=require 'B47ANCEDQuartermaster/Protocol';assert(P.version('loadChange')==1 and not P.accepts('loadChange',{protocol=0}))
print('PASS OFFLINE Dangerous Load: disabled default, 50/75/100%, live native capacity, native weight/reduction, concurrent job guard, stale/forged values, persistence and corruption/client rejection')
