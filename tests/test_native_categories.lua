-- Original native-interface fixtures. No third-party code or category mappings.
dofile(TEST_ROOT..'/fixtures/containers.lua')
dofile(TEST_ROOT..'/fixtures/catalog.lua')
local R=require 'B47ANCEDQuartermaster/Categorizer'
local C=require 'B47ANCEDQuartermaster/Catalog'
local S=B47ANCEDQuartermaster.Schema
local Compatibility=require 'B47ANCEDQuartermaster/Compatibility'
local function active(ids)
 getActivatedMods=function() return {size=function() return #ids end,get=function(_,i) return ids[i+1] end} end
 Compatibility.invalidate()
end
getText=function(key,arg) if key=='UI_QMSS_PreviousCategoryRule' then return 'Previous category rule: '..arg end;return key end
function BSgetCategory() error('foreign classifier must not be called') end
local function script(name,kind,category,tags,full)
 local item=CATALOG_FIXTURE.script(name,kind,tags,category)
 if full then item.getFullName=function() return full end end
 return item
end
active({'B47ANCEDQuartermaster'})
-- Missing Java getters raise/log an engine exception even inside pcall. Count
-- failed protected calls so a correct fallback cannot disguise that failure.
local protectedCall=pcall;local lookupFailures=0
pcall=function(fn,...)
 local ok,result=protectedCall(fn,...)
 if not ok then lookupFailures=lookupFailures+1 end
 return ok,result
end
local definition=script('GetterFallback','food')
assert(R.nativeCategory(definition)=='Food')
assert(R.nativeCategory({getScriptItem='not-callable',getItemType=function() return 'food' end})=='Food')
local inventory={getScriptItem=function() return definition end,getCategory=function() return 'NativeInventoryFallback' end}
assert(R.nativeCategory(inventory)=='NativeInventoryFallback')
assert(R.catalogEligible({}))
for _,value in ipairs({42,true,'invalid object'}) do assert(R.nativeCategory(value)=='Item') end
assert(R.nativeCategory(nil)=='Item')
pcall=protectedCall
assert(lookupFailures==0,'category fallback invoked missing/non-callable getters')
local scissors=script('Scissors','normal','ToolWeapon',{'base:scissors'},'Base.Scissors')
assert(R.nativeName(R.resolve(scissors))=='ToolWeapon','retired override changed vanilla category')
local defaults={normal='Item',food='Food',weapon='Weapon',container='Container',weaponpart='WeaponPart',key='Key',keyring='Key Ring',alarmclock='AlarmClock',clothing='Clothing',literature='Literature'}
for kind,expected in pairs(defaults) do assert(R.nativeName(R.resolve(script(kind,'base:'..kind)))==expected) end
for _,name in ipairs({'Medical','Food / Stored','Example Mod Category','日本語'}) do
 local id=R.nativeID(name);assert(R.nativeName(id)==name and R.known(id) and R.isLeaf(id))
end
assert(not R.nativeID('bad\ncategory') and not R.nativeID(string.rep('x',129)))
for _,id in ipairs({'B47_Native_0','B47_Native_0a','B47_Native_00','B47_Native_ZZ'}) do assert(not R.nativeName(id)) end
local custom=script('Sample','normal','ExampleCustom')
local api=C.build(nil,{{name='Sample',category=R.resolve(custom),fullType=custom:getFullName(),owner='pz-vanilla'}})
for _,id in ipairs(api.getCategories()) do assert(R.nativeName(id),'custom taxonomy leaked into active category list') end
local item={getScriptItem=function() return custom end,getDisplayName=function() return 'Sample' end,getContainer=function() return 'source' end}
local config=S.empty();config.cats[R.nativeID('ExampleCustom')]=true
local candidate={key='one',container='destination',config=config,distance=0}
assert(C.destination(item,{candidate},{},function() return true end)==candidate)
config.cats={[R.nativeID('ClientOnlyCategory')]=true}
assert(not C.destination(item,{candidate},{},function() return true end),'client-only category claim controlled server routing')
config.items.Sample=true
assert(C.destination(item,{candidate},{},function() return true end)==candidate,'explicit item intent was treated as category authority')
-- Retired categories are no longer recognized, displayed or routed.
local cat=R.resolve(scissors)
assert(R.match(cat,{B47_Stationery=true})==0)
assert(not R.known('B47_Stationery') and not R.validRules({B47_Stationery=true},{B47_Stationery=true}))
local Model=require 'B47ANCEDQuartermaster/Model'
local envelope=assert(S.envelope({cats={[R.nativeID('ExampleCustom')]=true},items={},presets={},priority=0},0,false))
local restored=assert(S.decode(envelope));assert(restored.cats[R.nativeID('ExampleCustom')])
for _,ids in ipairs({{'BetterSortCC'},{'EURY_CONTAINERS'},{'REORDER_CONTAINERS'},{'BetterSortCC','EURY_CONTAINERS'}}) do
 active(ids);assert(Compatibility.allowed())
 local native=R.nativeID('ExampleCustom')
 local api=C.build({},{{name='One',category=native,fullType='Fixture.One',owner='pz-vanilla'},{name='Two',category=native,fullType='Fixture.Two',owner='pz-vanilla'}})
 local picker={selectedCats={},selectedItems={}}
 local model=Model.new(picker,api,'Other');local group=model.byId['c:'..native]
 model:setGroup(group,true)
 if Compatibility.explicitCategorySelections() then
  assert(not picker.selectedCats[native] and picker.selectedItems.One and picker.selectedItems.Two,'client-local category was persisted as a server category rule')
 else assert(picker.selectedCats[native] and not picker.selectedItems.One) end
 assert(group.state=='full' and model.selectedCount==2)
 model:setItem(group,'One',false)
 assert(not model:covered(group,'One') and model:covered(group,'Two'))
end
-- Inventory labels, pinned ordering, filters and refresh/render chains are untouched.
ISInventoryPane={refreshContainer=function() return 'external-refresh' end,renderdetails=function() return 'external-render' end,itemSortByCatInc=function() return true end}
local refresh,render,sort=ISInventoryPane.refreshContainer,ISInventoryPane.renderdetails,ISInventoryPane.itemSortByCatInc
local I=require 'B47ANCEDQuartermaster/InventoryCategories';I.install(true)
local pane={itemslist={{cat='External Category'}}};I.present(pane)
assert(ISInventoryPane.refreshContainer==refresh and ISInventoryPane.renderdetails==render and ISInventoryPane.itemSortByCatInc==sort and pane.itemslist[1].cat=='External Category')
active({'Quartermaster'});assert(not Compatibility.allowed())
active({'B47ANCEDQuartermaster'})
print('PASS OFFLINE native categories: vanilla/mod metadata, safe tokens, server routing, retired-rule rejection, optional combinations, explicit snapshots and untouched inventory UI')
