-- Original native-shaped script fixtures; no engine execution or copied mod data.
dofile(TEST_ROOT..'/fixtures/containers.lua')
local R=require 'B47ANCEDQuartermaster/Categorizer'
local C=require 'B47ANCEDQuartermaster/Catalog'
local S=B47ANCEDQuartermaster.Schema
ComponentType={FluidContainer='fluid'}
local function item(id,kind,display,tags,extra)
    extra=extra or {}
    local o={canBeWrite=extra.writable==true}
    o.getFullName=function() return id end;o.getItemType=function() return 'base:'..(kind or 'normal') end
    o.getDisplayCategory=function() return display end;o.getTags=function() return tags or {} end
    o.getDisplayName=function() return 'نام / irrelevant Hammer Beer' end
    o.getModID=function() return 'pz-vanilla' end
    o.isHidden=function() return extra.hidden==true end;o.getObsolete=function() return extra.obsolete==true end
    o.getDaysFresh=function() return extra.fresh or 1000000000 end
    o.getEatType=function() return extra.eatType end
    o.isSpice=function() return false end
    o.getWeaponCategories=function() return extra.weapon or {} end
    o.getSkillTrained=function() return extra.skill end
    o.hasResearchableRecipes=function() return extra.recipes==true end
    o.getDoubleClickRecipe=function() return extra.open end
    o.getBodyLocation=function() return extra.body end
    o.getComponentScriptFor=function(_,type)
        assert(type==ComponentType.FluidContainer)
        if not extra.fluids then return nil end
        local entries={}
        for _,f in ipairs(extra.fluids) do local fluid=f;entries[#entries+1]={getFluidType=function() return fluid end,getPercentage=function() return 1 end} end
        -- Native Java list methods rather than a plain Lua array.
        return {getInitialFluids=function() return {size=function() return #entries end,get=function(_,i) return entries[i+1] end} end,
            isInitialFluidsIsRandom=function() return extra.random==true end,getCapacity=function() return 1 end}
    end
    return o
end
local function check(cat,...)
    local o=item(...);assert(R.semantic(o)=='B47_'..cat,o:getFullName()..' semantic got '..R.semantic(o))
    local expected=R.families.destination('B47_'..cat);assert(R.resolve(o)==expected)
    local instance={getScriptItem=function() return o end,getFluidContainer=function() error('instance-fluid access') end,
        getAge=function() error('instance-age access') end,isRotten=function() error('instance-condition access') end}
    assert(R.semantic(instance)=='B47_'..cat and R.resolve(instance)==expected)
    return o
end
-- Stable declared fluids classify product purpose, not current contents.
for _,fluid in ipairs({'Beer','Wine','Whiskey','Vodka','Rum','Gin','Tequila','Champagne','Scotch','Port','Sherry','Vermouth','Brandy','Cider','CoffeeLiqueur','Curacao'}) do
    check('BeveragesAlcohol','Fixture.'..fluid,'normal','Food',nil,{fluids={fluid}})
end
check('BeveragesAlcohol','Fixture.MixedCocktail','normal','Food',nil,{fluids={'Wine','JuiceOrange','Water'}})
check('BeveragesSoda','Fixture.RandomSoftDrink','normal','Food',nil,{fluids={'Cola','GingerAle'},random=true})
check('BeveragesOther','Fixture.MixedRandomDrink','normal','Food',nil,{fluids={'Beer','Cola'},random=true})
check('FoodOther','Fixture.UnknownFluid','normal','Food',nil,{fluids={'Beer','Petrol'}})
check('FoodShelfStable','Fixture.CannedMeal','food','Food',nil,{eatType='CanDrink'})
check('FoodPerishable','Fixture.Icecream','food','Food',nil,{eatType='CanDrink',fresh=7})
for _,fluid in ipairs({'CowMilk','MilkChocolate'}) do check('BeveragesMilk','Fixture.'..fluid,'normal','Food',nil,{fluids={fluid}}) end
check('BeveragesSoda','Fixture.Cola','normal','Food',nil,{fluids={'Cola'}})
check('BeveragesWater','Fixture.WaterDrink','normal','Food',nil,{fluids={'Water'}})
check('BeveragesEmptyWater','Fixture.EmptyWaterBottle','normal','WaterContainer',nil,{fluids={}})
check('ContainersBags','Fixture.HydrationPack','container','Bag',nil,{fluids={'Water'}})
for _,purpose in ipairs({'BeveragesWater','BeveragesOther','BeveragesSoda','BeveragesMilk','BeveragesEmptyWater'}) do
 assert(R.match('B47_'..purpose,{B47_BeveragesNonAlcoholic=true},nil,'B47_'..purpose)==1,'former non-alcoholic rule must retain coverage')
 assert(R.match('B47_'..purpose,{B47_Beverages=true},nil,'B47_'..purpose)==1)
end
assert(R.match('B47_BeveragesAlcohol',{B47_BeveragesNonAlcoholic=true},nil,'B47_BeveragesAlcohol')==0)
assert(not R.isLeaf('B47_BeveragesNonAlcoholic') and R.isFamily('B47_BeveragesNonAlcoholic'))
for _,fluid in ipairs({'JuiceOrange','JuiceCranberry','JuiceTomato'}) do
    check('BeveragesOther','Fixture.'..fluid,'normal','Food',nil,{fluids={fluid}})
end
for _,fluid in ipairs({'Grenadine','SimpleSyrup','JuiceLemon'}) do check('FoodOther','Fixture.'..fluid,'normal','Food',nil,{fluids={fluid}}) end
check('HouseholdCleaning','Fixture.Cleaner','normal','Household',nil,{fluids={'Bleach'}})
check('HouseholdCare','Fixture.Perfume','normal','Junk',nil,{fluids={'Perfume'}})
check('ContainersFluid','Fixture.EmptyJar','normal','Material',nil,{fluids={}})
-- Strong purpose wins over incidental weapon/memento identity.
check('Instruments','Fixture.Guitar','weapon','InstrumentWeapon',nil,{weapon={'base:blunt'}})
check('Instruments','Fixture.Whistle','normal','Instrument',{'base:ismemento'})
check('Smoking','Fixture.Tobacco','food','Tool',{'base:tobacco'},{fresh=7})
check('Smoking','Fixture.Cigarette','food','Junk',{'base:smokable'})
check('MeleeLongBlunt','Fixture.SportsWeapon','weapon','SportsWeapon',nil,{weapon={'base:blunt'}})
check('Recreation','Base.TennisRacket','weapon','SportsWeapon',nil,{weapon={'base:blunt'}})
check('MeleeLongBlunt','Base.BaseballBat','weapon','SportsWeapon',nil,{weapon={'base:blunt'}})
check('MeleeLongBlunt','Base.Golfclub','weapon','SportsWeapon',nil,{weapon={'base:blunt'}})
check('Stationery','Fixture.Marker','normal','Household',{'base:bluepen','base:write'})
check('AnimalSupplies','Fixture.Leash','normal','Animal')
check('Misc','Fixture.LiveAnimal','animal','Animal')
check('LiteratureNotes','Base.Notebook','literature','Literature',{'base:magazine'},{writable=true})
check('LiteratureMagazines','Foreign.Notebook','literature','Literature',{'base:magazine'},{writable=true})
check('LiteratureSkill','Fixture.SkillBook','literature','SkillBook',nil,{writable=true,skill='Tailoring'})
check('LiteratureManuals','Fixture.Manual','literature','RecipeResource',nil,{writable=true,recipes=true})
check('OutdoorFarming','Base.RoseBagSeed_Empty','literature','RecipeResource',nil,{recipes=true})
check('LiteratureManuals','Foreign.RoseBagSeed_Empty','literature','RecipeResource',nil,{recipes=true})
check('LiteratureManuals','Base.RoseBagSeed_EmptyManual','literature','RecipeResource',nil,{recipes=true})
check('ElectricalOther','Fixture.Camera','normal','Memento',{'base:camera','base:ismemento'})
check('ElectricalOther','Base.CameraFilm','normal','Junk')
check('MaterialsAnimal','Base.FurTuft_White','normal','Junk')
check('Misc','Foreign.FurTuft_White','normal','ForeignCategory')
check('MaterialsTextile','Base.FabricRoll_Cotton','drainable','Material')
check('MaterialsTextile','Base.LeatherStripsDirtyBundle','normal','Material')
check('ClothingOther','Base.FabricRoll_Cotton','clothing','Clothing',nil,{body='foreign:Slot'})
check('Misc','Base.FabricRoll_Cotton','normal','UnknownCategory')
check('ToolsMetal','Base.StoneAnvil','normal','Tool')
check('MaterialsOther','Base.WoodenBlockAnvilMold','normal','Material')
check('HouseholdKeepsakes','Fixture.Collectible','normal','Junk',{'base:ismemento'})
check('HouseholdKitchen','Fixture.CanOpener','normal','Cooking',{'base:canopener'})
check('ToolsFarming','Fixture.ElectricShears','normal','Tool',{'base:shear','base:miscelectronic','base:usesbattery'})
check('ToolsGeneral','Fixture.Multitool','weapon','ToolWeapon',{'base:smallfiles','base:awl','base:sharpknife','base:screwdriver'},{weapon={'base:smallblade'}})
check('ToolsMetal','Fixture.MetalSnips','weapon','ToolWeapon',{'base:sheetmetalsnips','base:canopener'},{weapon={'base:smallblade'}})
check('HouseholdCleaning','Fixture.GrillBrush','normal','Cooking',{'base:cleanstains'})
for _,on in ipairs({true,false}) do
    SandboxVars.B47ANCEDQuartermaster.ClassifyToolsByUse=on
    check('ToolsMetal','Fixture.Hammer','weapon','ToolWeapon',{'base:smithinghammer'},{weapon={'base:smallblunt'}})
    check('HouseholdKitchen','Fixture.KitchenKnife','weapon','CookingWeapon',{'base:sharpknife'},{weapon={'base:smallblade'}})
    check('ToolsMetal','Base.StoneAnvil','normal','Tool')
    check('Instruments','Fixture.Guitar','weapon','InstrumentWeapon',nil,{weapon={'base:blunt'}})
end
SandboxVars.B47ANCEDQuartermaster.ClassifyToolsByUse=true
-- Exclusions are catalog-only, not routing or deletion of known saved IDs.
local valid=item('Fixture.RealJar','normal','WaterContainer')
local hidden=item('Fixture.Intermediate','normal','Hidden')
local wound=item('Base.Wound_Fixture','clothing','Wound')
local developer=item('Base.TestDebugWater','normal','Tool')
assert(R.catalogEligible(valid))
for _,o in ipairs({hidden,wound,developer}) do assert(not R.catalogEligible(o));assert(R.known(R.resolve(o))) end
assert(R.catalogEligible(item('Base.CorpseMale','normal','Corpse')),'real carriable corpse hidden')
assert(R.catalogEligible(item('Foreign.DebugLookingName','normal','Tool')),'name guess exclusion')
assert(R.catalogEligible(item('Foreign.Wound','clothing','Wound')),'unproven foreign exclusion')
assert(R.catalogEligible(item('Base.TestWaterMug','normal','Water')),'legitimate known mug hidden')
getScriptManager=function() return {getAllItems=function() return {size=function() return 4 end,get=function(_,i) return ({valid,hidden,wound,developer})[i+1] end} end} end
C.invalidate();local api=C.build();assert(#api.entries==1 and api.entries[1].fullType=='Fixture.RealJar')
local inherited={cats={B47_ToolsMetal=true,B47_LiteratureNotes=true,B47_Household=true},items={},presets={},priority=0}
local old={schemaVersion=2,taxonomyVersion=2,revision=2,config=inherited}
assert(S.decode(old));assert(S.envelope(inherited,3).taxonomyVersion==6)
assert(R.migrate(inherited.cats,2).B47_ToolsMetal)
local additions={B47_Instruments=true,B47_Smoking=true,B47_Recreation=true,B47_Stationery=true,B47_AnimalSupplies=true,B47_ClothingJewelry=true,B47_ClothingEquipment=true,B47_ClothingCostumes=true,B47_ClothingEquipmentArmor=true,B47_ClothingGlovesArmor=true,B47_ClothingHeadwearArmor=true,B47_ClothingTopsArmor=true,B47_ClothingBottomsArmor=true,B47_ClothingUnderlayersArmor=true,B47_ClothingFootwearArmor=true,B47_ClothingEyesArmor=true,B47_ClothingOuterwearArmor=true,B47_ClothingOtherArmor=true,B47_AmmoPackages=true,B47_BeveragesSoda=true,B47_BeveragesMilk=true,B47_BeveragesEmptyWater=true}
for _,id in ipairs({'Weapons','Explosives','Sharp','Blunt','MeleeLongBlade','MeleeShortBlade','SubMachineGuns','AssaultRifles','SniperRifles','WeaponAttachments','WeaponComponents'}) do additions['B47_'..id]=true end
local previous=S.empty();local priorCount=0
for short in pairs(R.labels) do local id='B47_'..short;if not additions[id] and not ({B47_OutdoorFarmingSupplies=true,B47_ElectricalSupplies=true,B47_VehicleParts=true,B47_ClothingHeadwear=true,B47_ClothingUnderlayers=true,B47_BeveragesNonAlcoholic=true,B47_MedicalSupplies=true,B47_CampingSupplies=true,B47_HouseholdUtilities=true,B47_MaterialsGeneral=true,B47_ToolsGeneralPurpose=true,B47_FoodGeneral=true,B47_WeaponsOther=true,B47_FoodPantry=true})[id] then previous.cats[id]=true;priorCount=priorCount+1 end end
assert(priorCount==100 and R.validRules(previous.cats,{}))
local copy=S.decode({schemaVersion=2,taxonomyVersion=2,revision=1,config=previous})
assert(S.equal(copy,previous));assert(S.equal(S.envelope(copy,2).config,previous))
local count=0;for _,id in pairs(R.labels) do count=count+1 end
for _,id in ipairs({'B47_Instruments','B47_Smoking','B47_Recreation','B47_Stationery','B47_AnimalSupplies'}) do assert(R.known(id) and (R.isLeaf(id) or R.isLegacy(id))) end
local families=R.families
for parent,children in pairs(families.children) do
    local unique={};for _,child in ipairs(children) do assert(not unique[child]);unique[child]=true;assert(R.known(child)) end
end
print('PASS OFFLINE correction: stable script fluids/writing, semantic precedence, scope false positives, tool policies, catalog-only exclusions and dev.9 migration')
