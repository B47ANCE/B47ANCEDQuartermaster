-- Disposable ModData fixtures only; no real saves or servers are touched.
dofile(TEST_ROOT..'/fixtures/containers.lua')
local Store=require 'B47ANCEDQuartermaster/Store'
local D=require 'B47ANCEDQuartermaster/SortingData'
local R=B47ANCEDQuartermaster.Categorizer
local S=B47ANCEDQuartermaster.Schema
local f=CONTAINER_FIXTURE
local t={obj=f.a,container=f.a:getContainerByIndex(0),ci=0}
local native=R.nativeID('Food')
assert(not package.loaded['B47ANCEDQuartermaster/LegacyCategorizer'] and not package.loaded['B47ANCEDQuartermaster/Taxonomy'])
local rejected=S.empty();rejected.cats.B47_Food=true;assert(not S.envelope(rejected,0))
rejected.cats={};rejected.presets.Old=7;assert(not S.envelope(rejected,0))
local function old()
 local c=S.empty();c.cats[native]=true;c.cats.B47_Food=true;c.cats.UnknownOld=true
 c.items.Apple=true;c.priority=17;c.presets.Meals='b47:7';c.presets.Foreign=7
 local e={config=c,revision=3,schemaVersion=1,taxonomyVersion=6,legacyImported=true}
 e.kind=t.container:getType();e.containerCount=f.a:getContainerCount()
 return {schemaVersion=1,containers={['0']=e}}
end
-- Published 0.5 format also carries current native/item selections forward.
f.a.md={[S.key]=old()};f.a.md[S.key].containers['0'].schemaVersion=2
local published=assert(Store.load(t));assert(published.cats[native] and published.items.Apple and published.priority==17)
-- A second corrupt slot cannot cause a partial conversion of the first slot.
f.a.containers[2]=f.a.containers[1]
local slots=old();slots.containers['0'].containerCount=2
slots.containers['1']={schemaVersion=99}
f.a.md={QuartermasterSorting=slots};local atomicBefore=f.sent()
assert(not Store.load(t) and f.a.md.QuartermasterSorting==slots and f.a.md[S.key]==nil and f.sent()==atomicBefore)
f.a.containers[2]=nil
local protected={value=42};local foreign={['0']={Food=true}}
for _,alias in ipairs(D.aliases) do
 f.a.md={[alias]=old(),UnrelatedMod=protected,LSBox=foreign};local before=f.sent()
 local c,err,rev=Store.load(t)
 assert(c and not err and c.cats[native] and not c.cats.B47_Food and not c.cats.UnknownOld)
 assert(c.items.Apple and c.priority==17 and c.presets.Meals=='b47:7' and not c.presets.Foreign)
 assert(rev==4 and f.a.md[alias]==nil and f.a.md.UnrelatedMod==protected and f.a.md.LSBox==foreign)
 local e=f.a.md[S.key].containers['0'];assert(e.schemaVersion==S.version and e.taxonomyVersion==7 and e.legacyImported==nil)
 assert(f.sent()==before+1)
 local again,_,sameRev=Store.load(t);assert(S.equal(c,again) and sameRev==rev and f.sent()==before+1,'cleanup not idempotent')
 local record={target=t,original=S.copy(c),revision=rev};c.priority=18;assert(Store.commit(record,c))
 assert(select(1,Store.load(t)).priority==18)
end
-- Current source wins over aliases; a corrupt/future slot must not partially erase data.
f.a.md={[S.key]=old(),QuartermasterSorting=old()}
f.a.md[S.key].containers['0'].config.priority=99
assert(select(1,Store.load(t)).priority==99 and f.a.md.QuartermasterSorting==nil)
for _,mode in ipairs({'future','corrupt','identity'}) do
 local raw=old();local e=raw.containers['0']
 if mode=='future' then e.taxonomyVersion=99 elseif mode=='corrupt' then e.config.items=false else e.kind='different' end
 f.a.md={QuartermasterSorting=raw};local before=f.sent()
 assert(not Store.load(t));assert(f.a.md.QuartermasterSorting==raw and f.a.md[S.key]==nil and f.sent()==before)
end
f.a.md={QuartermasterSorting=old()};local before=f.sent();f.network(true,false)
assert(not Store.load(t) and f.a.md.QuartermasterSorting and f.sent()==before,'client cleaned shared state')
f.network(false,false)
-- Whole Container parents keep identities, membership and child inheritance.
local parent={schema=1,id='group',revision=2,config=old().containers['0'].config,members={fixture=true}}
local children={['0']={group='group',mode='inherit',revision=4}}
f.a.md={B47WholeContainer={schema=1,id='object',parents={['0']=parent},children=children},UnrelatedMod=protected}
local F=require 'B47ANCEDQuartermaster/Furniture';assert(F.state(t)==children['0'])
assert(D.furniture(f.a,f.a.md.B47WholeContainer))
local cleaned=f.a.md.B47WholeContainer.parents['0']
assert(cleaned.id==parent.id and cleaned.members==parent.members and cleaned.revision==3 and cleaned.config.items.Apple and not cleaned.config.cats.B47_Food)
local after=f.sent();D.furniture(f.a,f.a.md.B47WholeContainer);assert(f.sent()==after and f.a.md.UnrelatedMod==protected)
-- Shared preset generation/ownership and unrelated supply-planning data survive.
local data=ModData.getOrCreate(S.key);local personal={sentinel=true};data.personal=personal;data.dibs=protected
data.presetLibrary={schema=1,revision=9,serial=7,definitions={Meals={cats={[native]=true,B47_Food=true},items={Apple=true},gen=7,rev=1,owner='owner',owned=true}}}
local P=require 'B47ANCEDQuartermaster/Presets';local snapshot=P.snapshot();local def=snapshot.definitions.Meals
assert(snapshot.revision==10 and def.gen==7 and def.rev==2 and def.owner=='owner' and def.items.Apple and def.cats[native] and not def.cats.B47_Food)
assert(data.personal==personal and data.dibs==protected and P.snapshot().revision==10)
assert(S.resolves(def,'b47:7'))
print('PASS OFFLINE sorting-data retirement: native/items/priority/owned presets, all aliases, current precedence, idempotence, corruption/future/client rejection, furniture and unrelated data preservation')
