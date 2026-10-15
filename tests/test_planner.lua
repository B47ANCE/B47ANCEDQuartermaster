dofile(TEST_ROOT..'/fixtures/containers.lua')
dofile(TEST_ROOT..'/fixtures/catalog.lua')
LootSorter=nil
local P=require 'B47ANCEDQuartermaster/Planner'
local B,S,Store=B47ANCEDQuartermaster.Bindings,B47ANCEDQuartermaster.Schema,B47ANCEDQuartermaster.Store
local f=CONTAINER_FIXTURE
local discovery=assert(B.discover(f.player,{scope={x=0,y=0,z=0}}))
local function record(obj)
    for _,r in pairs(B.sessions[f.player].records) do if r.target.obj==obj then return r end end
end
local a,b=record(f.a),record(f.b)
local function save(r,explicit)
    r.original=S.empty();r.revision=0
    local c=S.empty()
    if explicit then c.items.RoundA=true else c.cats.B47_Native_4974656D=true;c.priority=100 end
    assert(Store.commit(r,c))
end
save(a,false);save(b,true)
local item={getScriptItem=function() return CATALOG_FIXTURE.items[1] end,
    getDisplayName=function() return 'RoundA' end,getContainer=function() return 'player-inventory' end}
local before=f.sent()
assert(P.choose(f.player,discovery.session,item,{},function() return true end).target.obj==f.b)
assert(P.choose(f.player,discovery.session,item,{},function(t) return t.obj~=f.b end).target.obj==f.a)
-- A synchronous server batch resolves rules once, but checks live eligibility
-- for every item. Count expensive work rather than relying on wall-clock noise.
local oldLoad,oldEffective=Store.load,S.effective
local loads,resolutions=0,0
Store.load=function(...) loads=loads+1;return oldLoad(...) end
S.effective=function(...) resolutions=resolutions+1;return oldEffective(...) end
local prepared=assert(P.prepare(f.player,discovery.session,{}))
local initialLoads,initialResolutions=loads,resolutions
assert(initialLoads>0 and initialResolutions>0)
for i=1,100 do
    assert(P.choose(f.player,discovery.session,item,{},function(t) return i%2==0 or t.obj~=f.b end,nil,prepared).target.obj==(i%2==0 and f.b or f.a))
end
assert(loads==initialLoads and resolutions==initialResolutions,'batch repeated configuration/rule work per item')
assert(not P.choose({},discovery.session,item,{},function() return true end,nil,prepared),'foreign batch owner accepted')
Store.load,S.effective=oldLoad,oldEffective
B.invalidate(f.b)
assert(P.choose(f.player,discovery.session,item,{},function() return true end,nil,prepared).target.obj==f.a,'prepared candidates bypassed revocation')
assert(P.choose(f.player,discovery.session,item,{},function() return true end).target.obj==f.a)
assert(not P.choose(f.player,discovery.session,item,{},nil),'missing transfer eligibility accepted')
f.network(true,false)
assert(not P.choose(f.player,discovery.session,item,{},function() return true end),'client planner accepted')
assert(f.sent()==before,'planning wrote world state')
print('PASS authoritative planner primitive: persisted rules, shared resolver, explicit precedence, eligibility, revocation, client rejection')

-- The picker uses the script name while a real vehicle key has a vehicle-specific name.
local C=B47ANCEDQuartermaster.Catalog
local function instance(display,scriptName,kind)
    local script=CATALOG_FIXTURE.script(scriptName,kind)
    return {getDisplayName=function() return display end,getScriptItem=function() return script end,
        getContainer=function() return 'inventory' end}
end
local key=instance('Test Sedan Key','Vehicle Key','key')
local ring=instance("Survivor's Key Ring",'Key Ring','container')
local house=instance('House Key','Key','key')
local cfg=S.empty();cfg.items['Vehicle Key']=true
local destination={key='keys',container='shelf',config=cfg}
local candidates={destination}
assert(C.destination(key,candidates)==destination,'vehicle-named key missed its script rule')
assert(C.destination(ring,candidates)==nil,'Vehicle Key incorrectly matched a keyring')
assert(C.destination(house,candidates)==nil,'Vehicle Key incorrectly matched another key type')
cfg.items['Key Ring']=true
assert(C.destination(ring,candidates)==destination,'explicit keyring selection stopped matching renamed rings')
assert(C.destination(key,candidates)==destination,'selecting both lost vehicle-key match')
cfg.items={['Test Sedan Key']=true}
assert(C.destination(key,candidates)==destination,'existing instance-specific rule regressed')
assert(C.destination(instance('Other Sedan Key','Vehicle Key','key'),candidates)==nil)
assert(C.destination(key,candidates,{},function() return false end)==nil,'script match bypassed eligibility')
cfg.items={['Vehicle Key']=true}
local broad=S.empty();broad.cats[B47ANCEDQuartermaster.Categorizer.nativeID('Key')]=true;broad.priority=100
assert(C.destination(key,{destination,{key='broad',container='other',config=broad}})==destination,
    'script-name explicit rule lost precedence to category priority')
print('PASS renamed keys: script-name match, retained instance rule, keyring/type isolation and authority eligibility')
