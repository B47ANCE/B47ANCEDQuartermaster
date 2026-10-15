dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
require 'B47ANCEDQuartermaster/Authority'
local f=CONTAINER_FIXTURE;local Q=B47ANCEDQuartermaster;local S,Store,P,F=Q.Schema,Q.Store,Q.Presets,Q.Furniture
local Profile=Q.AllocationProfile;local cat=Q.Categorizer.nativeID('Food')
local target=Q.Targets.make(f.a,0,f.player)
local oldConfig={cats={[cat]=true},items={SharedName=true},presets={},priority=17}
local original={schemaVersion=2,taxonomyVersion=7,revision=7,config=S.copy(oldConfig),kind=target.container:getType(),containerCount=f.a:getContainerCount()}
f.a.md[S.key]={schemaVersion=1,containers={['0']=original}};f.a.md.OtherMod={keep=true}
local before=f.sent();local config,err,revision=Store.load(target,f.player)
assert(config and not err and revision==7 and f.a.md[S.key].containers['0']==original and f.sent()==before,'read silently migrated legacy schema')
assert(not config.allocation and S.equal(config,oldConfig))
config.allocation=Profile.empty();config.allocation.items['Missing.ModItem']=25
config.allocation.paths['Missing.ModItem']={cat}
local record={target=target,original=S.copy(oldConfig),revision=revision}
assert(Store.commit(record,config,f.player))
assert(f.a.md[S.key].containers['0'].schemaVersion==3 and f.a.md[S.key].allocationBackups['0'].schemaVersion==2)
assert(S.equal(f.a.md[S.key].allocationBackups['0'].config,oldConfig) and f.a.md.OtherMod.keep)
local backup=f.a.md[S.key].allocationBackups['0'];config.priority=19;assert(Store.commit(record,config,f.player))
assert(f.a.md[S.key].allocationBackups['0']==backup and Store.load(target,f.player).allocation.items['Missing.ModItem']==25)
local world=ModData.getOrCreate('B47ANCEDQuartermaster')
world.presetLibrary={schema=1,revision=0,serial=1,definitions={Legacy={cats={[cat]=true},items={SharedName=true},gen=1,rev=1,owned=true,owner='local:0'}}}
assert(P.snapshot().definitions.Legacy and world.presetLibrary.schema==1 and world.presetAllocationBackup==nil)
local changed=P.change({name='Legacy',generation=1,revision=0,config=config},f.player)
assert(changed.status=='ok' and world.presetLibrary.schema==2 and world.presetAllocationBackup.schema==1)
assert(changed.library.definitions.Legacy.allocation.items['Missing.ModItem']==25)
local link=S.link(changed.library.definitions.Legacy)
changed=P.change({name='Legacy',generation=1,revision=1,renameTo='Renamed label'},f.player)
assert(changed.status=='ok' and changed.library.definitions.Legacy.label=='Renamed label' and S.link(changed.library.definitions.Legacy)==link,'rename broke generation-bound saved links')
changed=P.change({name='Copy',generation=0,revision=2,duplicateOf='Legacy',sourceGeneration=1},f.player)
assert(changed.status=='ok' and changed.library.definitions.Copy.gen~=1 and changed.library.definitions.Copy.allocation.items['Missing.ModItem']==25)
-- Shared furniture retains a complete profile and independently customized child.
f.a.md={};f.b.md={};Q.Bindings.sessions={}
local d=assert(Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}}));local a,b
for _,m in ipairs(d.targets) do local r=Q.Bindings.target(f.player,d.session,m.token);if r.target.obj==f.a then a=m.token elseif r.target.obj==f.b then b=m.token end end
local parent=Q.Authority.handle(f.player,'load',{session=d.session,token=a,whole=true})
local result=Q.Authority.handle(f.player,'groupChange',{session=d.session,token=a,whole=true,revision=parent.revision,config=config,taxonomyVersion=7})
assert(result.status=='ok' and Store.load(Q.Targets.make(f.b,0,f.player),f.player).allocation.items['Missing.ModItem']==25)
local child=Q.Authority.handle(f.player,'load',{session=d.session,token=b})
local custom=S.copy(child.config);custom.allocation.items['Missing.ModItem']=60
result=Q.Authority.handle(f.player,'groupChange',{session=d.session,token=b,action='custom',revision=child.revision,config=custom,taxonomyVersion=7})
assert(result.status=='ok')
assert(Store.load(Q.Targets.make(f.a,0,f.player),f.player).allocation.items['Missing.ModItem']==25)
assert(Store.load(Q.Targets.make(f.b,0,f.player),f.player).allocation.items['Missing.ModItem']==60)
child=Q.Authority.handle(f.player,'load',{session=d.session,token=b})
assert(Q.Authority.handle(f.player,'groupChange',{session=d.session,token=b,action='reset',revision=child.revision,confirm=true,taxonomyVersion=7}).status=='ok')
assert(Store.load(Q.Targets.make(f.b,0,f.player),f.player).allocation.items['Missing.ModItem']==25)
print('PASS OFFLINE allocation persistence: legacy read without rewrite, original backup, orphan/priority preservation, preset label rename/stable links/duplicate, Whole inheritance, complete child override and reset')
