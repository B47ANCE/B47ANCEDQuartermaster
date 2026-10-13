-- Dev.12 offline classifier and saved-rule contract. Native MP remains untested.
dofile(TEST_ROOT..'/fixtures/containers.lua')
function getText(key) return key end
local R=require 'B47ANCEDQuartermaster/Categorizer'
local C=require 'B47ANCEDQuartermaster/Catalog'
local Model=require 'B47ANCEDQuartermaster/Model'
local S=B47ANCEDQuartermaster.Schema
local function script(full,display,kind,tags,medical)
 local item={getFullName=function() return full end,getDisplayName=function() return full end,
  getDisplayCategory=function() return display end,getItemType=function() return 'base:'..(kind or 'normal') end,
  getTags=function() return tags or {} end,isMedicalLoot=function() return medical==true end,
  isCanBandage=function() return full=='Fixture.Bandage' end,isHidden=function() return false end,getObsolete=function() return false end}
 return item
end
local cases={
 {script('Base.Scissors','HouseholdWeapon','weapon',{'base:scissors'}),'Stationery','Stationery'},
 {script('Base.ScissorsBlunt','Household','normal',{'base:scissors'}),'Stationery','Stationery'},
 {script('Fixture.Bandage','FirstAid','normal',{},true),'MedicalBandages','MedicalSupplies'},
 {script('Fixture.MedicalTool','FirstAid','normal',{'base:scissors'},true),'MedicalTools','MedicalSupplies'},
 {script('Fixture.MedicalOther','FirstAid','normal',{},true),'MedicalOther','MedicalSupplies'},
 {script('Fixture.Medicine','FirstAid','food',{},true),'MedicalMedicine','MedicalMedicine'},
 {script('Fixture.Match','Camping','normal',{'base:lighter'}),'OutdoorFire','CampingSupplies'},
 {script('Fixture.Tent','Camping','normal',{'base:tentbed'}),'OutdoorCamping','CampingSupplies'},
 {script('Base.Calculator','Household'),'ElectricalOther','ElectricalOther','HouseholdOther'},
 {script('Base.Buckle','Material'),'MaterialsFasteners','MaterialsFasteners','MaterialsOther'},
 {script('Base.CompassGeometry','ToolWeapon','weapon'),'Stationery','Stationery','MeleeOther'},
 {script('Base.GlassBlowingPipe','Material'),'ToolsGeneral','ToolsGeneralPurpose','MaterialsOther'},
 {script('Base.Paintbrush','Tool','normal',{'base:paintbrush'}),'MaterialsPaint','MaterialsPaint','ToolsGeneral'},
 {script('Base.PaintbrushCrafted','Tool','normal',{'base:paintbrush'}),'MaterialsPaint','MaterialsPaint','ToolsGeneral'},
 {script('Base.WaterRationCan_Box','Food'),'BeveragesWater','BeveragesWater','FoodOther'},
 {script('Base.WaterRationCan','Food','food',{'base:cannedfood'}),'BeveragesWater','BeveragesWater','FoodShelfStable'},
}
local entries={}
for _,case in ipairs(cases) do
 local item,semantic,physical,prior=case[1],'B47_'..case[2],'B47_'..case[3],case[4] and 'B47_'..case[4] or nil
 local cat,_,broad,actual,historical=R.resolve(item)
 assert(cat==physical and actual==semantic and historical==(prior or semantic),item:getFullName())
 assert(R.match(cat,{[physical]=true},broad,actual,historical)==3)
 if R.isLegacy(historical) then assert(R.match(cat,{[historical]=true},broad,actual,historical)==2) end
 if prior then
  assert(R.match(cat,{[prior]=true},broad,actual,historical)==2)
  if R.isLegacy(semantic) then assert(R.match(cat,{[semantic]=true},broad,actual,historical)==0) end
 end
 if semantic=='B47_MedicalBandages' then assert(R.match(cat,{B47_MedicalTools=true},broad,actual,historical)==0) end
 if semantic=='B47_OutdoorFire' then assert(R.match(cat,{B47_OutdoorCamping=true},broad,actual,historical)==0) end
 assert(R.match(cat,{[broad]=true},broad,actual,historical)>=1)
 entries[#entries+1]={name=item:getDisplayName(),category=cat,semantic=actual,historical=historical,legacy=broad,fullType=item:getFullName(),owner='vanilla'}
end
local api=C.build({},entries)
assert(api.getCategories() and #api.getCategories()>0)
local picker={selectedCats={B47_MedicalBandages=true},selectedItems={},selectedPresets={}}
local model=Model.new(picker,api,'other')
assert(model.byId['c:B47_MedicalBandages'] and model.byId['c:B47_MedicalSupplies'])
assert(model:covered(model.byId['c:B47_MedicalSupplies'],'Fixture.Bandage'))
assert(not model:covered(model.byId['c:B47_MedicalSupplies'],'Fixture.MedicalTool'))
assert(#model:rows('Medical',true,nil,{},{} )>0)
local old=S.empty();old.cats.B47_OutdoorFire=true;old.cats.B47_MedicalTools=true
local decoded=S.decode({schemaVersion=2,taxonomyVersion=4,revision=3,config=old})
assert(decoded and S.equal(decoded,old) and S.envelope(decoded,3).taxonomyVersion==6)
assert(R.migrate(old.cats,4).B47_OutdoorFire and not R.migrate(old.cats,7))
local count,aliases=0,0
for short in pairs(R.labels) do local id='B47_'..short;if R.isLeaf(id) then count=count+1 end;if R.isLegacy(id) then aliases=aliases+1 end end
assert(count==102 and aliases==23) -- dev.34 clothing hierarchy, costumes and armor pairs.
print('PASS OFFLINE dev.12 freeze: medical/camping unions, 8 corrections, exact historical scope, picker, migration, protocol 5')

