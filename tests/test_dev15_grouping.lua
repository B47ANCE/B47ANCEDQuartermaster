B47ANCEDQuartermaster=B47ANCEDQuartermaster or {}
local Q=B47ANCEDQuartermaster
local Model=require 'B47ANCEDQuartermaster/Model'
Q.Categorizer=require 'B47ANCEDQuartermaster/Categorizer'
local grouped=false
Q.UIOptions={groupByMod=function() return grouped end}
local picker={selectedCats={},selectedItems={}}
local api={
    getCategories=function() return {'B47_MedicalBandages'} end,
    getItemsInCategory=function(cat) return cat=='B47_MedicalBandages' and {{name='Bandage'},{name='Mod Bandage'}} or {} end,
    getItemNames=function() return {'Bandage','Mod Bandage'} end,
    categoryLabel=function() return 'Bandages' end,
}
local owner=function(_,name) return name=='Bandage' and 'pz-vanilla' or 'test-mod',name=='Bandage' and 'Project Zomboid' or 'Example Mod' end
local model=Model.new(picker,api,'Other',owner)
local group=model.byId['c:B47_MedicalBandages']
assert(#group.mods==0 and group.ownerLabels['Mod Bandage']=='Example Mod')
local rows=model:rows('example mod',false,nil,{['c:B47_Medical']=true,['c:B47_MedicalBandages']=true})
assert(#rows==3 and rows[1].kind=='category' and rows[2].kind=='subcategory'
    and rows[3].kind=='item' and rows[3].key=='Mod Bandage' and rows[3].depth==2)
grouped=true
model=Model.new(picker,api,'Other',owner)
group=model.byId['c:B47_MedicalBandages']
assert(#group.mods==2)
rows=model:rows('example mod',false,nil,{['c:B47_Medical']=true,['c:B47_MedicalBandages']=true,[group.mods[2].id]=true})
assert(#rows==4 and rows[3].kind=='mod' and rows[4].kind=='item' and rows[4].depth==3)
assert(next(picker.selectedCats)==nil and next(picker.selectedItems)==nil)
print('PASS OFFLINE dev.15: default direct items, optional mod grouping, mod search, no rule mutation')
