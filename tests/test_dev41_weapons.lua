-- Owned metadata and hierarchy contracts. Offline, not native MP acceptance.
dofile(TEST_ROOT..'/fixtures/containers.lua')
dofile(TEST_ROOT..'/fixtures/catalog.lua')
local R=require 'B47ANCEDQuartermaster/Categorizer'
local C=require 'B47ANCEDQuartermaster/Catalog'
local Model=require 'B47ANCEDQuartermaster/Model'
local labels={Weapons='Weapons',Sharp='Sharp',MeleeBlades='Blade',MeleeLongBlade='Long',MeleeShortBlade='Short',Firearms='Firearms',WeaponParts='Attachments & Parts',WeaponAttachments='Attachments'}
function getText(key) local id=key:match('UI_B47_Category_(.+)');return labels[id] or id or key end
B47ANCEDQuartermaster.UIOptions={groupByMod=function() return false end}
local function item(name,kind,tags,weapons,full,ranged,anim)
 local o=CATALOG_FIXTURE.script(name,kind,tags)
 o.getFullName=function() return full or 'Fixture.'..name end
 o.getWeaponCategories=function() return weapons or {} end
 o.isRanged=function() return ranged==true end;o.getSwingAnim=function() return anim end
 return o
end
local axe=item('Axe','weapon',{'base:choptree'},{'base:axe'})
local blade=item('Sword','weapon',{}, {'base:longblade'})
local knife=item('Knife','weapon',{}, {'base:smallblade'})
local scope=item('Scope','weaponpart')
local bomb=item('Bomb','weapon',{}, {},'Base.PipeBomb')
local cat,_,legacy,semantic,historical,secondary=R.resolve(axe)
assert(cat=='B47_ToolsCutting' and secondary=='B47_MeleeLongBlade')
assert(R.match(cat,{B47_Sharp=true},legacy,semantic,historical,secondary)==1)
assert(R.match(cat,{B47_MeleeLongBlade=true},legacy,semantic,historical,secondary)==2)
assert(R.match(cat,{B47_ToolsCutting=true},legacy,semantic,historical,secondary)==3)
SandboxVars.B47ANCEDQuartermaster.ClassifyToolsByUse=false
assert(R.resolve(axe)=='B47_ToolsCutting','old save option overrode mandatory tool purpose')
local entries={}
for _,o in ipairs({axe,blade,knife,scope,bomb}) do
 local c,_,l,s,h,w=R.resolve(o)
 entries[#entries+1]={name=o:getDisplayName(),category=c,legacy=l,semantic=s,historical=h,secondary=w,fullType=o:getFullName()}
end
local api=C.build({},entries)
local picker={selectedCats={},selectedItems={},selectedPresets={}}
local model=Model.new(picker,api,'Other');local expanded={}
for _,g in ipairs(model.groups) do expanded[g.id]=true end
local rows=model:rows('',false,nil,expanded)
local seen={};for _,row in ipairs(rows) do
 if row.kind=='item' then seen[row.key]=(seen[row.key] or 0)+1 end
 if row.key=='B47_MeleeLongBlade' then assert(row.depth==3 and row.group.displayParent.key=='B47_MeleeBlades') end
 if row.key=='B47_WeaponAttachments' then assert(row.depth==3) end
end
assert(seen.Axe==2 and seen.Sword==1 and seen.Scope==1,'dual display or nested leaves duplicated/lost')
local search=model:rows('Sharp',false,nil,{},{});local visible={}
for _,row in ipairs(search) do if row.kind=='item' then visible[row.key]=true end end
assert(visible.Axe and visible.Sword and visible.Knife and not visible.Scope)
local itemRows={};for _,row in ipairs(search) do if row.kind=='item' then itemRows[#itemRows+1]=row end end
model:applyRows(itemRows,'select')
assert(model.selectedCount==3 and not picker.selectedItems.Scope,'visible selection escaped branch or double counted tool')
model:clear();model:setGroup(model.byId['c:B47_Weapons'],true)
assert(model.selectedCount==5,'Weapons group omitted descendants or counted duplicate tool')
local filtered=model:rows('Weapons',false,{Scope=true}, {}, {})
local n=0;for _,row in ipairs(filtered) do if row.kind=='item' then n=n+1;assert(row.key=='Scope') end end
assert(n==1,'deep parent search bypassed Only Contents')
local collapsed=model:rows('',false,nil,{})
for _,row in ipairs(collapsed) do assert(row.kind~='item','collapsed descendants leaked into visible operations') end
local carried=item('Axe','weapon',{'base:choptree'},{'base:axe'})
carried.getContainer=function() return 'source' end
carried.getScriptItem=function() return carried end
local config=B47ANCEDQuartermaster.Schema.empty();config.cats.B47_Sharp=true
assert(C.destination(carried,{{key='weapons',container='dest',config=config}}),'secondary weapon rule failed server ranking')
for _,case in ipairs({{'Base.AssaultRifle','B47_AssaultRifles'},{'Base.HuntingRifle','B47_SniperRifles'},{'Fixture.UnknownRifle','B47_FirearmsOther'}}) do
 assert(R.resolve(item('gun','weapon',{}, {},case[1],true,'Rifle'))==case[2])
end
assert(R.resolve(bomb)=='B47_Explosives')
print('PASS OFFLINE dev41: four category levels, secondary tool rows/routing, deep search/contents/collapse/bulk/count and vanilla gun/explosive identity')
