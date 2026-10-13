local Model=require 'B47ANCEDQuartermaster/Model'
local api={getCategories=function() return {'Ammunition','Food'} end,
    getItemNames=function() return {'9mm Rounds','Shells','Custom Ammo','Soup','Shared'} end,
    getItemsInCategory=function(cat)
        if cat=='Ammunition' then return {{name='9mm Rounds'},{name='Shells'},{name='Custom Ammo'},{name='Shared'}} end
        return {{name='Soup'},{name='Shared'}}
    end}
local p={selectedCats={},selectedItems={}}
local m=Model.new(p,api,'Other',function(cat,name)
    if name=='Custom Ammo' or name=='Soup' then return 'cooking','Cooking Mod' end
    return 'pz-vanilla','Vanilla'
end)
local ammo,food=m.byId['c:Ammunition'],m.byId['c:Food']
local function items(rows)
    local result={}
    for _,r in ipairs(rows) do if r.kind=='item' then result[#result+1]=r end end
    return result
end
local function keys(rows)
    local result={};for _,r in ipairs(items(rows)) do result[r.key]=true end;return result
end
for _,text in ipairs({'Ammunition','ammun','AMMUNITION'}) do
    local rows=m:rows(text,false,nil,{})
    assert(#items(rows)==4 and rows[1].group==ammo)
end
local rows=m:rows('9mm',false,nil,{})
assert(#rows==3 and rows[1].kind=='category' and rows[2].kind=='mod' and rows[3].key=='9mm Rounds')
assert(#items(m:rows('Cooking Mod',false,nil,{}))==2)
assert(#items(m:rows('.',false,nil,{}))==0,'search interpreted as a Lua pattern')
m:applyRows(items(m:rows('9mm',false,nil,{})),'select')
assert(p.selectedItems['9mm Rounds'] and not p.selectedCats.Ammunition and m.selectedCount==1)
m:applyRows(items(m:rows('ammun',false,nil,{})),'select')
assert(p.selectedCats.Ammunition and m.selectedCount==4 and not p.selectedItems['9mm Rounds'])
-- Clearing a filtered subset of a full category preserves nonmatching coverage via conversion.
m:applyRows(items(m:rows('9mm',false,nil,{})),'clear')
assert(not p.selectedCats.Ammunition and not p.selectedItems['9mm Rounds'] and p.selectedItems.Shells)
assert(m.selectedCount==3)
local checked=m:rows('ammun',true,nil,{})
assert(#items(checked)==3)
local contents=m:rows('ammun',false,{Shells=true},{})
assert(#items(contents)==1 and keys(contents).Shells)
m:applyRows(items(contents),'invert');assert(not p.selectedItems.Shells and p.selectedItems['Custom Ammo'])
-- Clearing one mod inside a native category leaves the other mod effectively selected.
m:setGroup(ammo,true)
local vanilla=ammo.mods[1];local cooking=ammo.mods[2]
m:applyRows({{kind='mod',group=ammo,mod=cooking}},'clear')
assert(not p.selectedCats.Ammunition and not p.selectedItems['Custom Ammo'])
assert(vanilla.state=='full' and cooking.state=='none' and ammo.state=='partial')
m:applyRows({{kind='mod',group=ammo,mod=cooking}},'select')
assert(p.selectedCats.Ammunition and cooking.state=='full' and ammo.state=='full')
-- Shared names are inverted once from the snapshot, not once per row.
m:clear();p.selectedItems.Shared=true;m:refresh()
rows={{kind='item',group=ammo,key='Shared'},{kind='item',group=food,key='Shared'}}
m:applyRows(rows,'invert');assert(not p.selectedItems.Shared and m.selectedCount==0)
m:applyRows(rows,'invert');assert(p.selectedItems.Shared and m.selectedCount==1)
-- Count is independent of visibility, dedupes overlap and retains orphan explicit names.
assert(m:effectiveCount({Ammunition=true,Food=true},{Shared=true,Orphan=true})==6)
local expansion={[ammo.id]=true,[vanilla.id]=true}
local before=m:rows('',false,nil,expansion)
m:rows('Cooking Mod',false,nil,expansion)
local after=m:rows('',false,nil,expansion)
assert(#before==#after and not expansion[cooking.id])
print('PASS bulk model: three-level literal search, filters, category/mod conversion, invert dedupe, effective counts')
