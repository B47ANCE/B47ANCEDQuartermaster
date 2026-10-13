B47ANCEDQuartermaster=B47ANCEDQuartermaster or {}
function getText(key) return key end
dofile(TEST_ROOT..'/fixtures/catalog.lua')
local R=require 'B47ANCEDQuartermaster/Categorizer'
local make=CATALOG_FIXTURE.script
local modded=make('HerbalDressing','base:normal',nil,'Medical','example-mod')
local vanillaOwner=make('HerbalDressing','base:normal',nil,'Medical','pz-vanilla')
assert(R.resolve(modded)=='B47_MedicalSupplies')
assert(R.resolve(vanillaOwner)==R.resolve(modded),'mod ownership influenced taxonomy')
local semantic,reason,weight,confidence,candidates=R.rank(modded)
assert(semantic=='B47_MedicalOther' and reason=='medical-display-category' and weight==550 and confidence=='medium')
assert(candidates[1].physical=='B47_MedicalSupplies' and candidates[1].weight>candidates[2].weight)
local weak=make('Unexplained','base:normal',nil,nil,'example-mod')
local _,why,score,level=R.rank(weak)
assert(R.resolve(weak)=='B47_Misc' and why=='fallback' and score==0 and level=='low')
local strong=make('Known','base:normal',nil,'Medical','example-mod')
R.overrides['Fixture.Known']='ToolsSewing'
assert(R.resolve(strong)=='B47_ToolsSewing')
assert(select(3,R.rank(strong))==1000)
R.overrides['Fixture.Known']=nil;R.invalidate()
print('PASS OFFLINE dev.15 scoring: definition evidence, explicit override, mod neutrality, low-confidence fallback')
