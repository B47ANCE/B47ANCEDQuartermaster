-- Original native-shaped fixtures. Offline Lua, not engine/network acceptance.
dofile(TEST_ROOT..'/fixtures/containers.lua')
function getText(key) return key end
local R=require 'B47ANCEDQuartermaster/Categorizer'
local C=require 'B47ANCEDQuartermaster/Catalog'
local Model=require 'B47ANCEDQuartermaster/Model'
local S=B47ANCEDQuartermaster.Schema
local function script(id,display,kind,tags,body,ranged)
 return {getFullName=function() return id end,getDisplayName=function() return id end,
  getItemType=function() return 'base:'..(kind or 'normal') end,getDisplayCategory=function() return display end,
  getTags=function() return tags or {} end,getBodyLocation=function() return body end,
  isRanged=function() return ranged==true end,isHidden=function() return false end,getObsolete=function() return false end}
end
local cases={
 {'AnimalSupplies','OutdoorFarmingSupplies',script('Fixture.Leash','Animal')},
 {'OutdoorFarming','OutdoorFarmingSupplies',script('Fixture.Seeds','Gardening')},
 {'ElectricalComponents','ElectricalSupplies',script('Fixture.Wire','Electronics',nil,{'base:wire'})},
 {'ElectricalPower','ElectricalSupplies',script('Base.Battery','Electronics')},
 {'VehicleBatteries','VehicleParts',script('Fixture.CarBattery','VehicleMaintenance',nil,{'base:carbattery'})},
 {'VehicleOther','VehicleParts',script('Fixture.Brake','VehicleMaintenance')},
 {'ClothingHead','ClothingHeadwear',script('Fixture.Hat','Clothing','clothing',nil,'base:hat')},
 {'ClothingFace','ClothingHeadwear',script('Fixture.Mask','Clothing','clothing',nil,'base:mask')},
 {'ClothingUnderwear','ClothingUnderlayers',script('Fixture.Underwear','Clothing','clothing',nil,'base:underwear')},
 {'ClothingSocks','ClothingUnderlayers',script('Fixture.Socks','Clothing','clothing',nil,'base:socks')}
}
local entries={}
for _,case in ipairs(cases) do
 local old,new,obj='B47_'..case[1],'B47_'..case[2],case[3]
 local category,reason,broad,semantic=R.resolve(obj)
 assert(category==new and semantic==old and R.isLegacy(old) and not R.isLeaf(old) and R.isLeaf(new))
 assert(R.match(category,{[old]=true},broad,semantic)==2)
 assert(R.match(category,{[new]=true},broad,semantic)==3)
 for _,other in ipairs(cases) do
  if other~=case then assert(R.match(category,{['B47_'..other[1]]=true},broad,semantic)==0,'old narrow rule broadened') end
 end
 entries[#entries+1]={name=obj:getDisplayName(),category=category,semantic=semantic,legacy=broad,fullType=obj:getFullName(),owner='pz-vanilla'}
 local config=S.empty();config.cats[old]=true
 local decoded=S.decode({schemaVersion=2,taxonomyVersion=3,revision=1,config=config})
 assert(decoded and S.equal(decoded,config) and S.envelope(decoded,2).taxonomyVersion==6)
 assert(R.migrate(R.migrate(decoded.cats,3),4)[old] and not decoded.cats[new])
end
-- Consolidation must not widen existing broad Materials into batteries.
local component,power=cases[3][3],cases[4][3]
local cat,_,legacy,semantic=R.resolve(component);assert(R.match(cat,{B47_Materials=true},legacy,semantic)==1)
cat,_,legacy,semantic=R.resolve(power);assert(R.match(cat,{B47_Materials=true},legacy,semantic)==0)
for _,obj in ipairs({script('Fixture.Camera','Memento',nil,{'base:camera'}),
 script('Fixture.Generator','Electronics'),script('Fixture.Bullhorn','Tool',nil,{'base:megaphone'}),script('Fixture.Radio','Communications','radio')}) do
 assert(R.resolve(obj)~='B47_ElectricalSupplies' and R.semantic(obj)~='B47_ElectricalPower')
end
local api=C.build({},entries)
do
 local p={selectedCats={B47_Electrical=true},selectedItems={},selectedPresets={}}
 local m=Model.new(p,api,'Other');local leaf=m.byId['c:B47_ElectricalSupplies']
 m:setGroup(leaf,false)
 for _,name in ipairs(leaf.children) do assert(not m:covered(leaf,name),'child category remained selected through its parent') end
end
local picker={selectedCats={},selectedItems={},selectedPresets={}}
local model=Model.new(picker,api,'other')
for _,case in ipairs(cases) do assert(not model.byId['c:B47_'..case[1]],'obsolete unselected row visible') end
local group=model.byId['c:B47_ElectricalSupplies'];assert(group and #group.children==2 and #group.mods==1)
local hierarchy=model:rows('Electrical',false,nil,{['c:B47_Electrical']=true,['c:B47_ElectricalSupplies']=true}, {})
assert(hierarchy[1] and hierarchy[1].kind=='category' and hierarchy[1].key=='B47_Electrical'
    and hierarchy[2] and hierarchy[2].kind=='subcategory' and hierarchy[2].key=='B47_ElectricalSupplies'
    and hierarchy[3] and hierarchy[3].kind=='mod' and hierarchy[4] and hierarchy[4].kind=='item',
    'broad/subcategory/mod/item presentation hierarchy missing')
model:setGroup(group,true)
assert(picker.selectedCats.B47_ElectricalSupplies and not picker.selectedCats.B47_ElectricalPower and not picker.selectedCats.B47_ElectricalComponents)
picker={selectedCats={B47_ElectricalPower=true},selectedItems={},selectedPresets={}}
model=Model.new(picker,api,'other');group=model.byId['c:B47_ElectricalSupplies']
assert(model.byId['c:B47_ElectricalPower'] and model.selectedCount==1 and group.state=='partial')
assert(model:covered(group,'Base.Battery') and not model:covered(group,'Fixture.Wire'))
assert(#model:rows('Electrical',true,nil,{},{} )>0,'legacy/search hierarchy lost')
model:setGroup(model.byId['c:B47_ElectricalPower'],false);assert(not picker.selectedCats.B47_ElectricalPower and model.selectedCount==0)
local empty=C.build({},{});picker={selectedCats={B47_FirearmsOther=true},selectedItems={},selectedPresets={}}
model=Model.new(picker,empty,'other');assert(model.byId['c:B47_FirearmsOther'],'persisted empty rule hidden')
local selectedRows=model:rows('',true,nil,{},{} )
assert(#selectedRows==3 and selectedRows[1].key=='B47_Weapons' and selectedRows[2].key=='B47_Firearms' and selectedRows[3].key=='B47_FirearmsOther','selected empty rule lost its parent in Only Checked')
model:setGroup(model.byId['c:B47_FirearmsOther'],false);assert(not picker.selectedCats.B47_FirearmsOther)
local legacyEmpty=Model.new({selectedCats={B47_AnimalSupplies=true},selectedItems={}},empty,'other')
assert(legacyEmpty.byId['c:B47_AnimalSupplies'] and #legacyEmpty:rows('',true,nil,{},{} )==2)
legacyEmpty:setGroup(legacyEmpty.byId['c:B47_AnimalSupplies'],false);assert(not legacyEmpty.picker.selectedCats.B47_AnimalSupplies)
assert(not Model.new({selectedCats={},selectedItems={}},empty,'other').byId['c:B47_FirearmsOther'])
local fallback=script('Foreign.ExperimentalGun',nil,'weapon',nil,nil,true)
cat,_,legacy,semantic=R.resolve(fallback);assert(cat=='B47_FirearmsOther')
local populated=C.build({},{{name='experimental',category=cat,semantic=semantic,legacy=legacy,owner='foreign'}})
assert(Model.new({selectedCats={},selectedItems={}},populated,'other').byId['c:B47_FirearmsOther'],'populated fallback did not appear')
local axe=script('Fixture.Axe','ToolWeapon','weapon',{'base:axe'})
axe.getWeaponCategories=function() return {'base:axe'} end
SandboxVars.B47ANCEDQuartermaster.ClassifyToolsByUse=false
cat,_,legacy,semantic=R.resolve(axe);assert(cat=='B47_ToolsCutting')
assert(Model.new({selectedCats={},selectedItems={}},C.build({},{{name='axe',category=cat,semantic=semantic,legacy=legacy}}),'other').byId['c:B47_ToolsCutting'])
SandboxVars.B47ANCEDQuartermaster.ClassifyToolsByUse=true;assert(R.resolve(axe)=='B47_ToolsCutting')
-- Rank: item > current physical > historical semantic > broad family.
local obj=power;obj.getScriptItem=function() return obj end;obj.getContainer=function() return 'source' end
local function dest(id,cats,item)
 local config=S.empty();config.cats=cats;config.priority=1000;if item then config.items[obj:getDisplayName()]=true;config.priority=-1000 end
 return {key=id,config=config,container=id}
end
local broad=dest('broad',{B47_Electrical=true});local narrow=dest('old',{B47_ElectricalPower=true})
local current=dest('new',{B47_ElectricalSupplies=true});current.config.priority=-999
local item=dest('item',{},true)
assert(C.destination(obj,{broad,narrow})==narrow)
assert(C.destination(obj,{broad,narrow,current})==current)
assert(C.destination(obj,{broad,narrow,current,item})==item)
local physical,supported,aliases=0,0,0
for short in pairs(R.labels) do local id='B47_'..short;supported=supported+1;if R.isLeaf(id) then physical=physical+1 end;if R.isLegacy(id) then aliases=aliases+1 end end
assert(physical==102 and supported==147 and aliases==23) -- dev.34 armor pairs.
print('PASS OFFLINE consolidation: 13 exact legacy memberships, six current destinations, no widening, partial/legacy UI, empty/modded fallback visibility, migration and four-level routing')
