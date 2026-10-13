-- Original synthetic metadata cases. Host Lua only; not native engine execution.
dofile(TEST_ROOT..'/fixtures/containers.lua')
function getText(k) return k=='UI_B47_Category_MedicalMedicine' and 'Medicines and medicinal herbs' or k end
local R=require 'B47ANCEDQuartermaster/Categorizer'
local C=require 'B47ANCEDQuartermaster/Catalog'
local S=B47ANCEDQuartermaster.Schema
local function script(kind,display,tags,props,fullType)
    props=props or {};local o={}
    local fields={getItemType=kind,getDisplayCategory=display,getTags=tags or {},getFullName=fullType or 'Fixture.Item',
        getDisplayName=props.name or 'item',getWeaponCategories=props.weapons or {},getBodyLocation=props.body,
        getDaysFresh=props.fresh,getSkillTrained=props.skill,getFabricType=props.fabric,getSwingAnim=props.anim,
        getAmmoType=props.ammo,getDoubleClickRecipe=props.open,getRecordedMediaCat=props.media}
    for k,v in pairs(fields) do local value=v;o[k]=function() return value end end
    o.isRanged=function() return props.ranged==true end
    o.isCanBandage=function() return props.bandage==true end
    o.isMedicalLoot=function() return props.medical==true end
    o.isMechanicsLoot=function() return props.mechanics==true end
    o.isSpice=function() return props.spice==true end
    o.isSurvivalGearLoot=function() return props.outdoor==true end
    o.isAlcoholic=function() return props.alcohol==true end
    if props.fluids then
        ComponentType={FluidContainer='FluidContainer'}
        local fluids={}
        for _,fluid in ipairs(props.fluids) do local name=fluid;fluids[#fluids+1]={getFluidType=function() return name end,getPercentage=function() return 1 end} end
        o.getComponentScriptFor=function() return {getCapacity=function() return 1 end,getInitialFluids=function() return fluids end} end
    end
    return o
end
local tested={};local samples={}
local function check(expected,kind,display,tags,props,fullType)
    local o=script(kind,display,tags,props,fullType)
    local semantic='B47_'..expected
    local id=R.families.destination(semantic)
    local actual,_,_,purpose=R.resolve(o);assert(actual==id and purpose==semantic,expected..' got '..actual)
    tested[id]=true;samples[id]=o;samples[semantic]=o
    -- Display/localized names are not classifier authority; use a distinct script object.
    local other=script(kind,display,tags,props,fullType);other.getDisplayName=function() return '完全不同 / renamed' end
    assert(R.resolve(other)==id,'localized-name dependence')
    local instance={getScriptItem=function() return o end,getAge=function() error('mutable state read') end,
        isRotten=function() error('mutable state read') end,isFrozen=function() error('mutable state read') end}
    assert(R.resolve(instance)==id,'instance differs from script classification')
end
check('AmmoLoose','normal',nil,{'base:ammo'})
check('AmmoPackages','normal','Ammo',nil,{open='OriginalOpenRecipe'})
check('AmmoBoxes','container','Bag',{'base:ammocase'})
check('ClothingEquipment','container','Bag',{'base:ammocase'},{body='base:ammostrap'})
do
 local strap=script('container','Bag',{'base:ammocase'},{body='base:ammostrap'},'Fixture.Bandolier')
 local cat,_,broad,semantic,historical=R.resolve(strap)
 assert(R.match(cat,{B47_Ammo=true},broad,semantic,historical)==0,'bandolier must not retain ammunition family membership')
 assert(R.match(cat,{B47_Clothing=true},broad,semantic,historical)==1)
end
check('AmmoMagazines','normal','Ammo',{'base:magazine'})
check('Handguns','weapon',nil,nil,{ranged=true,anim='Handgun'})
check('FirearmsOther','weapon',nil,nil,{ranged=true,anim='Rifle'})
check('Shotguns','weapon',nil,nil,{ranged=true,anim='Rifle',ammo='base:shotgun_shells'})
check('FirearmsOther','weapon',nil,nil,{ranged=true})
check('MeleeLongBlade','weapon',nil,nil,{weapons={'base:longblade'}})
check('MeleeBlunt','weapon',nil,nil,{weapons={'base:smallblunt'}})
check('MeleeLongBlunt','weapon',nil,nil,{weapons={'base:blunt'}})
SandboxVars.B47ANCEDQuartermaster.ClassifyToolsByUse=false
check('ToolsCutting','weapon',nil,nil,{weapons={'base:axe'}})
SandboxVars.B47ANCEDQuartermaster.ClassifyToolsByUse=true
check('MeleeSpears','weapon',nil,nil,{weapons={'base:spear'}})
check('MeleeOther','weapon')
check('WeaponAttachments','weaponpart',nil,{'base:flashlight'})
check('ToolsGeneral','normal',nil,{'base:screwdriver'})
check('ToolsCarpentry','normal',nil,{'base:hammer'})
check('ToolsMetal','weapon',nil,{'base:smithinghammer','base:hammer'})
check('ToolsMechanics','normal','VehicleMaintenance',{'base:wrench'},{mechanics=true})
check('ToolsSewing','normal',nil,{'base:sewingneedle'})
check('ToolsCutting','weapon',nil,{'base:sharpknife'},{weapons={'base:smallblade'}})
check('ToolsFarming','weapon','GardeningWeapon',{'base:digplow'})
check('MedicalBandages','normal',nil,nil,{bandage=true})
check('MedicalMedicine','food',nil,nil,{medical=true})
check('MedicalTools','normal',nil,{'base:scissors'},{medical=true})
check('MedicalOther','normal',nil,nil,{medical=true})
check('FoodPerishable','food',nil,nil,{fresh=3})
check('FoodShelfStable','food',nil,nil,{fresh=1000000000})
check('FoodSeasoning','food',nil,nil,{spice=true,fresh=3})
check('FoodOther','food')
check('BeveragesWater','normal','Water')
check('BeveragesAlcohol','food',nil,nil,{alcohol=true})
check('BeveragesOther','food',nil,{'base:sealedbeveragecan'})
check('BeveragesOther','food',nil,{'base:alcoholicbeverage','base:herbaltea'})
check('BeveragesSoda','normal','Food',nil,{fluids={'Cola'}})
check('BeveragesMilk','normal','Food',nil,{fluids={'CowMilk'}})
check('BeveragesEmptyWater','normal','WaterContainer',nil,{fluids={}})
local clothing={ClothingHead='base:hat',ClothingEyes='base:eyes',ClothingFace='base:mask',
 ClothingTops='base:tshirt',ClothingOuterwear='base:jacket_bulky',ClothingBottoms='base:pants',
 ClothingUnderwear='base:underwear',ClothingSocks='base:socks',ClothingFootwear='base:shoes',
 ClothingGloves='base:hands',ClothingAccessories='base:neck'}
for cat,body in pairs(clothing) do check(cat,'clothing',nil,nil,{body=body}) end
check('ClothingHeadwearArmor','clothing','ProtectiveGear',nil,{body='base:hat'})
check('ClothingCostumes','clothing','Clothing',{'base:costume'},{body='base:jacket'})
check('ClothingCostumes','clothing','Memento',nil,{body='base:fullhat'},'Base.Hat_Spiffo')
check('ClothingTops','clothing','Clothing',nil,{body='base:tshirt'},'Base.Tshirt_SpiffoDECAL')
for _,slot in ipairs({'base:shoulderholster','base:holsterdouble','base:fannypackfront','base:belt'}) do
 check('ClothingEquipment','container','Bag',nil,{body=slot},'Fixture.Equipment')
end
for _,slot in ipairs({'base:ears','base:necklace','base:rightwrist'}) do
 check('ClothingJewelry','clothing','Accessory',nil,{body=slot},'Fixture.Jewelry')
end
do
 local protective=script('clothing','ProtectiveGear',nil,{body='base:hat'},'Fixture.ArmoredHat')
 local cat,_,broad,semantic,historical=R.resolve(protective)
 assert(cat=='B47_ClothingHeadwearArmor' and R.match(cat,{B47_ClothingProtective=true},broad,semantic,historical)==2)
 assert(R.match(cat,{B47_ClothingHeadwear=true},broad,semantic,historical)==0,'regular clothing must not include armor')
 local expected={ClothingAccessories=true,ClothingEquipment=true,ClothingJewelry=true,ClothingGloves=true,ClothingHeadwear=true,ClothingTops=true,ClothingBottoms=true,ClothingUnderlayers=true,ClothingFootwear=true,ClothingEyes=true,ClothingOuterwear=true,ClothingOther=true,ClothingCostumes=true}
 expected.ContainersBags=true
 local count=0
 for base in pairs(R.families.armorDestinations) do expected[base:sub(5)..'Armor']=true end
 for _,id in ipairs(R.families.children.B47_Clothing) do if R.isLeaf(id) then assert(expected[id:sub(5)],'unexpected Clothing leaf '..id);expected[id:sub(5)]=nil;count=count+1 end end
 assert(count==24 and next(expected)==nil,'requested Clothing hierarchy with armor pairs and Bags')
end
for cat,slot in pairs({ClothingEquipmentArmor='base:ammostrap',ClothingGlovesArmor='base:hands',ClothingHeadwearArmor='base:hat',ClothingTopsArmor='base:tshirt',ClothingBottomsArmor='base:pants',ClothingUnderlayersArmor='base:underwear',ClothingFootwearArmor='base:shoes',ClothingEyesArmor='base:eyes',ClothingOuterwearArmor='base:jacket',ClothingOtherArmor='Example:ArmorSlot'}) do
 check(cat,'clothing','Clothing',{'base:armor'},{body=slot},'Fixture.ModdedArmor')
end
check('ClothingOther','clothing',nil,nil,{body='SomeMod:UnrecognizedSlot'})
for _,slot in ipairs({'base:right_middlefinger','base:left_middlefinger','base:right_ringfinger','base:left_ringfinger','Example:Left_RingFinger'}) do
 check('ClothingJewelry','clothing','Accessory',nil,{body=slot},'Example.Ring')
end
check('HouseholdKeys','keyring','Container',{'base:keyring'},nil,'Example.KeyRing')
check('LiteratureSkill','literature',nil,nil,{skill='Tailoring'})
check('LiteratureManuals','literature','RecipeResource')
check('LiteratureMaps','map')
check('LiteratureMagazines','literature',nil,{'base:magazine'})
check('LiteratureNotes','literature',nil,{'base:write'})
check('LiteratureOther','literature')
check('Media','normal',nil,nil,{media='OriginalRecordedFamily'})
check('MaterialsWood','normal','Material',{'base:makewoodcharcoallarge'})
check('MaterialsMetal','normal','Material',{'base:hasmetal'})
check('MaterialsMetal','weapon',nil,{'base:toolhead'},{weapons={'base:blunt'}})
check('MaterialsTextile','normal','Material',{'base:leatherfurtannedlarge'})
check('MaterialsFasteners','normal','Material',{'base:screws'})
check('MaterialsBinding','normal',nil,{'base:glue'})
check('MaterialsPaint','normal','Paint')
check('ElectricalComponents','normal','Material',{'base:wire'})
check('MaterialsOther','normal','Material')
check('VehicleTires','normal',nil,{'base:wholetire'})
check('VehicleBatteries','normal',nil,{'base:carbattery'})
check('VehicleOther','normal',nil,nil,{mechanics=true})
check('OutdoorFishing','normal',nil,{'base:fishingnet'})
check('OutdoorTrapping','normal','Trapping')
check('OutdoorFarming','literature','Gardening')
check('OutdoorCamping','normal',nil,{'base:tentbed'})
check('OutdoorFire','normal',nil,{'base:lighter'})
check('OutdoorLighting','drainable',nil,{'base:flashlight'})
check('OutdoorOther','normal',nil,nil,{outdoor=true})
check('ContainersBags','container','Bag',nil,{body='base:back'})
do
 local bag=script('container','Bag',nil,{body='base:back'},'Fixture.Backpack')
 local cat,_,broad,semantic,historical=R.resolve(bag)
 assert(cat=='B47_ContainersBags' and R.families.parents[cat][1]=='B47_Clothing')
 assert(R.match(cat,{B47_Clothing=true},broad,semantic,historical)==1)
 assert(R.match(cat,{B47_Containers=true},broad,semantic,historical)==1,'preserve existing Containers rules')
 assert(R.match(cat,{B47_ContainersBags=true},broad,semantic,historical)==3,'preserve saved Bags ID')
end
check('ContainersFluid','container','WaterContainer')
check('ContainersOther','container')
check('ElectricalRadios','radio',nil,{'base:usesbattery'})
check('ElectricalPower','drainable',nil,{'base:battery'})
check('ElectricalOther','alarmclock')
check('HouseholdKeys','key')
check('HouseholdKeys','container',nil,{'base:keyring'},{body='base:back'})
check('HouseholdKitchen','weapon','CookingWeapon',{'base:fork'})
check('HouseholdCleaning','normal','Household',{'base:cleanstains'})
check('HouseholdCare','normal','Appearance')
check('HouseholdFurnishings','moveable')
check('HouseholdOther','normal','Household')
check('MaterialsAnimal','normal','AnimalPart')
check('HouseholdKeepsakes','weapon','Memento',{'base:fakeweapon'},{ranged=true})
check('Misc','normal','UnknownForeignCategory',{'UnknownMod:UnknownTag'})
check('Instruments','weapon','InstrumentWeapon',nil,{weapons={'base:blunt'}})
check('Smoking','food','Tool',{'base:tobacco'},{fresh=7})
check('Recreation','normal','Sports')
check('Stationery','normal','Household',{'base:pen'})
check('AnimalSupplies','normal','Animal')
assert(R.resolve(nil)=='B47_Misc')
check('MeleeShortBlade','weapon',nil,nil,{weapons={'base:smallblade'}})
check('SubMachineGuns','weapon',nil,{'base:smg'},{ranged=true,anim='Rifle'})
check('AssaultRifles','weapon',nil,{'base:assaultrifle'},{ranged=true,anim='Rifle'})
check('SniperRifles','weapon',nil,{'base:sniperrifle'},{ranged=true,anim='Rifle'})
check('Explosives','weapon',nil,{'base:grenade'})
check('WeaponComponents','normal',nil,{'base:gunpart'})
local total=0
for short in pairs(R.labels) do local id='B47_'..short;if R.isLeaf(id) then assert(tested[id],'untested leaf '..id);total=total+1 end end
-- Native Set iteration and ResourceLocation-backed metadata strings.
local o=script('weapon',nil,nil,{})
o.getWeaponCategories=function() local n=0;return {iterator=function() return {hasNext=function() return n==0 end,next=function() n=n+1;return 'base:smallblade' end} end} end
assert(R.resolve(o)=='B47_MeleeShortBlade')
-- Cache once per script/policy, never read native metadata from drawing.
local reads=0;o=script('weapon','ToolWeapon',{'base:hammer'},{weapons={'base:smallblunt'}})
o.getTags=function() reads=reads+1;return {'base:hammer'} end
assert(R.resolve(o)=='B47_ToolsCarpentry');local before=reads
for i=1,100 do assert(R.resolve(o)=='B47_ToolsCarpentry') end;assert(reads==before)
SandboxVars.B47ANCEDQuartermaster.ClassifyToolsByUse=false
assert(R.resolve(o)=='B47_ToolsCarpentry' and reads==before,'retired tool setting changed primary classification')
SandboxVars.B47ANCEDQuartermaster.ClassifyToolsByUse=true
for _,fullType in ipairs({'Base.Nails','Base.Screws','Base.NailsBox','Base.ScrewsBox'}) do
 assert(R.resolve(script('normal','Material',{},nil,fullType))=='B47_MaterialsFasteners')
end
assert(R.semantic(script('drainable','Electronics',{},nil,'Base.Battery'))=='B47_ElectricalPower')
assert(R.resolve(script('weapon','MaterialWeapon',{},nil,'Base.Plank'))=='B47_MaterialsWood')
assert(R.resolve(script('normal','Tool',{},nil,'Base.BlowTorch'))=='B47_ToolsMetal')
assert(R.resolve(script('normal','VehicleMaintenance',{},nil,'Base.Jack'))=='B47_ToolsMechanics')
assert(R.resolve(script('normal','VehicleMaintenance',{},nil,'Base.TirePump'))=='B47_ToolsMechanics')
assert(R.resolve(script('key',nil,{},nil,'Base.CarKey'))=='B47_HouseholdKeys')
-- Every old family survives read/save; unknown old rules remain dormant, not a new authority grant.
local Store=require 'B47ANCEDQuartermaster/Store'
require 'B47ANCEDQuartermaster/Targets'
local f=CONTAINER_FIXTURE
local target=B47ANCEDQuartermaster.Targets.make(f.a,0,f.player)
local Model=require 'B47ANCEDQuartermaster/Model'
local previous={'Ammo','Firearms','Melee','WeaponParts','Tools','Medical','Food','Beverages','Clothing','Literature','Media','Materials','Vehicle','Outdoor','Containers','Electrical','Household','Misc'}
for _,short in ipairs(previous) do
 local family='B47_'..short;local leaf=R.families.defaults[family] or family
 local config=S.empty();config.cats[family]=true;config.cats.DormantOldRule=true
 f.a.md={B47ANCEDQuartermaster={schemaVersion=1,containers={['0']={schemaVersion=2,taxonomyVersion=1,revision=0,config=config,kind='crate',containerCount=1}}},Foreign={keep=true}}
 local sent=f.sent();local loaded,err,rev=Store.load(target)
 assert(loaded and not err and loaded.cats[family] and loaded.cats.DormantOldRule and f.sent()==sent)
 assert(R.migrate(R.migrate(loaded.cats,1),2)[family],'migration not idempotent')
 local api=C.build({},{{name='example',category=leaf,fullType='Fixture.Example',owner='pz-vanilla',legacy=family}})
 local picker={selectedCats=loaded.cats,selectedItems={},selectedPresets={}}
 local model=Model.new(picker,api,'other')
 assert(model.byId['c:'..family] and model:effectiveCount(loaded.cats,{})==1,'broad rule invisible or uncounted')
 assert(api.covered(leaf,'example',loaded.cats),'broad membership lost')
 local record={target=target,original=S.copy(loaded),revision=rev}
 assert(Store.commit(record,loaded) and f.a.md.Foreign.keep and f.sent()==sent+1)
 assert(f.a.md.B47ANCEDQuartermaster.containers['0'].taxonomyVersion==6)
 local invalid=S.copy(loaded);invalid.cats.B47_InventedCategory=true
 assert(not Store.commit(record,invalid),'new unknown category accepted')
 if R.isFamily(family) and leaf~=family then
  assert(R.match(leaf,{[family]=true},family)==1 and R.match(leaf,{[leaf]=true},family)>=2)
 end
 assert(R.match(leaf,{DormantOldRule=true},family)==0,'unknown category routes')
end
-- Specific categories outrank broad rules even at lower fill priority; explicit item wins both.
local actual=samples.B47_MedicalBandages
local item={getScriptItem=function() return actual end,getDisplayName=function() return 'item' end,getContainer=function() return 'source' end}
local function candidate(id,cats,priority,explicit)
 local c=S.empty();c.cats=cats;c.priority=priority;if explicit then c.items.item=true end
 return {key=id,container=id,config=c,distance=0}
end
local broad=candidate('broad',{B47_Medical=true},999)
local specific=candidate('specific',{B47_MedicalBandages=true},-999)
local exact=candidate('item',{},-1000,true)
assert(C.destination(item,{broad,specific})==specific)
assert(C.destination(item,{broad,specific,exact})==exact)
local linked=S.empty();linked.presets.Medical='b47:1'
local preset={Medical={owned=true,gen=1,cats={B47_Medical=true},items={}}}
broad.config=linked;assert(C.destination(item,{broad},preset)==broad,'broad preset coverage lost')
-- Visible descendant edit preserves unseen effective selections without resurrecting a broad rule.
local api=C.build({},{{name='dressing',category='B47_MedicalBandages',legacy='B47_Medical',owner='pz-vanilla'},
 {name='medicine',category='B47_MedicalMedicine',legacy='B47_Medical',owner='pz-vanilla'}})
local picker={selectedCats={B47_Medical=true},selectedItems={},selectedPresets={}}
local model=Model.new(picker,api,'other')
assert(model.selectedCount==2 and model:effectiveCount({B47_Medical=true},{})==2)
local leaf=model.byId['c:B47_MedicalSupplies']
model:applyRows({{kind='item',group=leaf,key='dressing'}},'select')
assert(picker.selectedCats.B47_Medical and not picker.selectedCats.B47_MedicalSupplies,'no-op visible select invented a specific rule')
model:applyRows({{kind='item',group=leaf,key='dressing'}},'clear')
assert(not model:covered(leaf,'dressing') and model:covered(model.byId['c:B47_MedicalMedicine'],'medicine'))
assert(not picker.selectedCats.B47_Medical and model.selectedCount==1,'broad rule resurrected')
assert(not picker.selectedItems.medicine and picker.selectedCats.B47_MedicalMedicine,'compatibility row blocked removal of conversion-created explicit rule')
local rows=model:rows('Medicines',false,nil,{},{});assert(#rows>0,'new category search missing')
assert(not R.validRules({B47_Invented=true},{}))
print('PASS OFFLINE taxonomy: '..total..' leaf cases; localized-name/state independence, native-shaped sets, cache/policy, all 18 old-rule load/save/visibility/idempotence, unknown-rule rejection, specific/item/preset precedence and hidden-member preservation')

-- Corrections from old Misc retain broad coverage and remain visible/countable.
local corrected=script('normal','Unrecognized',{'base:cleanstains'})
local category,_,legacy=R.resolve(corrected)
assert(category=='B47_HouseholdCleaning' and legacy=='B47_Misc')
assert(R.match(category,{B47_Misc=true},legacy)==1)
local legacyApi=C.build({},{{name='cleaner',category=category,legacy=legacy,owner='pz-vanilla'}})
local legacyModel=Model.new({selectedCats={B47_Misc=true},selectedItems={}},legacyApi,'other')
assert(legacyModel.selectedCount==1 and legacyModel.byId['c:B47_Misc'])
-- MP rejects old/missing taxonomy write metadata, without changing persistent state.
local A=require 'B47ANCEDQuartermaster/Authority'
local sent=f.sent();f.network(false,true)
assert(A.handle(f.player,'commit',{taxonomyVersion=1}).status=='TaxonomyPeerMismatch')
assert(A.handle(f.player,'commit',{taxonomyVersion=3}).status=='TaxonomyPeerMismatch','dev.10 write peer accepted')
assert(A.handle(f.player,'presetChange',{}).status=='TaxonomyPeerMismatch')
assert(f.sent()==sent);f.network(false,false)
-- An older server's discovery cannot initialize a current taxonomy session.
local Session=require 'B47ANCEDQuartermaster/Session'
local session=Session.new(target,0);local request=A.request;local outcome
A.request=function(_,_,_,done) done({status='ok',taxonomyVersion=1,session='old',targets={}}) end
session:open(function(status) outcome=status end)
assert(outcome=='TaxonomyPeerMismatch' and not session.id and not session.busy)
A.request=function(_,_,_,done) done({status='ok',taxonomyVersion=3,session='dev10',targets={}}) end
session:open(function(status) outcome=status end)
assert(outcome=='TaxonomyPeerMismatch' and not session.id and not session.busy,'dev.10 server accepted')
A.request=request
print('PASS OFFLINE taxonomy authority: corrected Misc compatibility, reject missing/old MP write taxonomy and old-server discovery')

