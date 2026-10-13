assert(LootSorter==nil)
function getText(key) return key end
-- Any accidental dependency call is a hard failure.
function BSgetCategory() error('foreign categorizer called') end
function BSupdateMedia() error('foreign mutator called') end
dofile(TEST_ROOT..'/fixtures/catalog.lua')
local R=require 'B47ANCEDQuartermaster/Categorizer'
local C=require 'B47ANCEDQuartermaster/Catalog'
local S=B47ANCEDQuartermaster.Schema
local script=CATALOG_FIXTURE.script
local function expect(kind,tags,category,expected)
    assert(R.semantic(script('Test',kind,tags,category))=='B47_'..expected)
end
expect('base:food',nil,nil,'FoodOther')
expect('base:weaponpart',nil,nil,'WeaponAttachments')
expect('base:container',nil,nil,'ContainersOther')
expect('base:moveable',nil,nil,'HouseholdFurnishings')
expect('base:key',nil,nil,'HouseholdKeys')
expect('base:clothing',nil,nil,'ClothingOther')
expect('base:normal',{'base:ammo'},'UnrelatedForeignCategory','AmmoLoose')
expect('base:normal',nil,'UnrelatedForeignCategory','Misc')
expect('base:normal',{'base:sealedbeveragecan'},'Food','BeveragesOther')
expect('base:normal',nil,'WaterContainer','ContainersFluid')
expect('base:drainable',{'base:flashlight'},nil,'OutdoorLighting')
expect('base:weapon',{'base:hammer'},'ToolWeapon','ToolsCarpentry')
SandboxVars={B47ANCEDQuartermaster={ClassifyToolsByUse=false}}
expect('base:weapon',{'base:hammer'},'ToolWeapon','ToolsCarpentry')
expect('base:normal',{'base:hammer'},nil,'ToolsCarpentry')
SandboxVars=nil
local ranged=script('Gun','weapon');ranged.isRanged=function() return true end
assert(R.resolve(ranged)=='B47_FirearmsOther')
local medical=script('Med','drainable');medical.isMedicalLoot=function() return true end
assert(R.resolve(medical)=='B47_MedicalSupplies')
local odd=script('Odd','normal');R.overrides['Fixture.Odd']='Tools'
assert(R.resolve(odd)=='B47_ToolsGeneralPurpose');R.overrides['Fixture.Odd']=nil
local tags={iterator=function() local i=0;return {hasNext=function() return i==0 end,next=function() i=i+1;return 'base:ammo' end} end}
local ammo=script('Ammo','normal');ammo.getTags=function() return tags end
assert(R.resolve(ammo)=='B47_AmmoLoose','Java-style tag iteration')
local api=C.build()
assert(#api.getItemsInCategory('B47_Ammo')==3)
assert(api.owner('B47_Food','Lunch')=='fixture-mod','origin confused with functional category')
assert(api.categoryLabel('B47_Ammo')=='UI_B47_Category_Ammo')
local duplicate=C.build({{name='Lunch',category='B47_Food',fullType='Other.Lunch',owner='other-mod'}},api.entries)
assert(duplicate.owner('B47_Food','Lunch')=='unknown:','ambiguous provenance hidden')
local migrated=R.migrate({LegacyCategory=true,B47_Ammo=true},0)
assert(migrated.LegacyCategory and migrated.B47_Ammo and not R.migrate({},99))
local item={getScriptItem=function() return ammo end,getDisplayName=function() return 'Ammo' end,getContainer=function() return 'source' end}
local function candidate(key,priority,explicit,container,distance)
    local config=S.empty();config.priority=priority
    if explicit then config.items.Ammo=true else config.cats.B47_Ammo=true end
    return {key=key,config=config,container=container or key,distance=distance or 0}
end
local category=candidate('cat',100)
local explicit=candidate('explicit',-10,true)
assert(C.destination(item,{category,explicit})==explicit,'explicit precedence')
local high=candidate('high',200)
assert(C.destination(item,{category,high})==high,'priority')
assert(C.destination(item,{category,high},{},function(c) return c~=high end)==category,'capacity/access predicate')
local near=candidate('near',100,false,nil,1)
category.distance=5
assert(C.destination(item,{category,near})==near,'distance tie')
local first=candidate('a',100,false,nil,1)
assert(C.destination(item,{near,first})==first,'stable tie')
local self=candidate('self',999,true,'source')
assert(C.destination(item,{self,category})==category,'self routing')
assert(C.category(item)==R.resolve(ammo),'planner and catalog resolver differ')
local audit=C.audit()
assert(audit.counts.B47_AmmoLoose==3 and audit.counts.B47_FoodGeneral==1 and #audit.unresolved==0)
print('PASS owned categorizer: semantic rules, sandbox, fallback, provenance, migration, shared catalog and destination ranking')
