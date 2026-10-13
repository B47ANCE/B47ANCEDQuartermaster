dofile(TEST_ROOT..'/fixtures/containers.lua')
require 'B47ANCEDQuartermaster/Configuration'
require 'B47ANCEDQuartermaster/Targets'
CONTAINER_FIXTURE.origin=B47ANCEDQuartermaster.Targets.make(CONTAINER_FIXTURE.a,0,CONTAINER_FIXTURE.player)
local f=CONTAINER_FIXTURE
LootSorter=nil -- The authoritative replacement must load without foreign globals.
f.a.md={LSBox={['0']={Food=true}},LSBoxItems={['0']={Apple=true}},
    LSBoxPresets={['0']={Meals=7}},LSBoxPriority={['0']=4},UnrelatedMod={value=9}}
local A=require 'B47ANCEDQuartermaster/Authority'
local B,S=B47ANCEDQuartermaster.Bindings,B47ANCEDQuartermaster.Schema
local originalLegacy=B47ANCEDQuartermaster.Configuration.clone(f.a.md)
local before=f.sent()
local discovered=A.handle(f.player,'discover',{scope={x=0,y=0,z=0}})
assert(discovered.status=='ok' and f.sent()==before,'discovery wrote data')
local token
for id,r in pairs(B.sessions[f.player].records) do if r.target.obj==f.a then token=id end end
assert(token)
assert(A.handle(f.player,'load',{session=discovered.session,target=B47ANCEDQuartermaster.Targets.descriptor(f.origin)}).status=='invalid')
local loaded=A.handle(f.player,'load',{session=discovered.session,token=token})
assert(loaded.status=='ok' and f.sent()==before,'load wrote data')
local config=S.copy(loaded.config);config.priority=23
local saved=A.handle(f.player,'commit',{session=discovered.session,token=token,config=config,revision=0})
assert(saved.status=='ok' and saved.config.priority==23 and f.sent()==before+1)
local own=f.a.md.B47ANCEDQuartermaster
assert(own.schemaVersion==1 and own.containers['0'].config.priority==23 and own.containers['0'].revision==1)
assert(own.containers['0'].legacyImported and own.containers['0'].taxonomyVersion==6)
assert(A.handle(f.player,'commit',{session=discovered.session,token=token,config=config,revision=0}).status=='conflict','duplicate write accepted')
for k,v in pairs(originalLegacy) do assert(B47ANCEDQuartermaster.Configuration.equal(v,f.a.md[k]),'foreign data modified') end
config.priority=24;config.WholeContainer=true
assert(A.handle(f.player,'commit',{session=discovered.session,token=token,config=config,revision=0}).status=='invalid')
config.WholeContainer=nil
-- Another authoritative writer changes the revision: a stale working snapshot must not win.
own.containers['0'].revision=2
assert(A.handle(f.player,'commit',{session=discovered.session,token=token,config=config,revision=0}).status=='conflict')
assert(own.containers['0'].config.priority==23)
B.invalidate(f.a)
assert(A.handle(f.player,'commit',{session=discovered.session,token=token,config=config,revision=0}).status=='invalid')
f.network(true,false)
assert(A.handle(f.player,'commit',{session=discovered.session,token=token,config=config,revision=0}).status=='invalid')
f.network(false,false)
assert(f.sent()==before+1)
print('PASS standalone authority: lazy read, owned coherent commit, legacy untouched, malformed/conflict/stale/client rejection')
