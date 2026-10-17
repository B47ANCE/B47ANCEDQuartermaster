-- Active categories are native metadata, never an owned or imported item taxonomy.
require 'B47ANCEDQuartermaster/Schema'
local L=require 'B47ANCEDQuartermaster/LegacyCategorizer'
local R={version=L.version,labels={},families=L.families}
B47ANCEDQuartermaster.Categorizer=R
local function read(value,key)
    if not value then return end
    local ok,result=pcall(function() return value[key](value) end)
    if ok then return result end
end
local function categoryText(value)
    return type(value)=='string' and #value>0 and #value<=128 and not value:find('%c') and value or nil
end
-- Bounded canonical encoding. Tokens are configuration intent, never client claims.
function R.nativeID(value)
    if not categoryText(value) then return end
    return 'B47_Native_'..value:gsub('.',function(c) return string.format('%02X',string.byte(c)) end)
end
function R.nativeName(id)
    if type(id)~='string' then return end
    local encoded=id:match('^B47_Native_([0-9A-F]+)$')
    if not encoded or #encoded>256 or #encoded%2~=0 then return end
    return categoryText(encoded:gsub('%x%x',function(pair) return string.char(tonumber(pair,16)) end))
end
-- Native getCategory literals verified in installed B42.21 classes. Script items
-- lack the InventoryItem fallback getter; no temporary inventory items are created.
local fallback={food='Food',clothing='Clothing',weapon='Weapon',literature='Literature',
    container='Container',weaponpart='WeaponPart',key='Key',keyring='Key Ring',
    alarmclock='AlarmClock',alarmclockclothing='AlarmClock'}
function R.nativeCategory(value)
    local script=read(value,'getScriptItem') or value
    local category=categoryText(read(value,'getDisplayCategory')) or categoryText(read(script,'getDisplayCategory'))
    if category then return category end
    category=categoryText(read(value,'getCategory'))
    if category then return category end
    local kind=tostring(read(script,'getItemType') or ''):lower():gsub('^.-:','')
    return fallback[kind] or 'Item'
end
function R.label(id)
    local native=R.nativeName(id)
    if native then
        local key='IGUI_ItemCat_'..native;local label=getText(key)
        return label==key and native or label
    end
    if L.known(id) then return getText('UI_QMSS_PreviousCategoryRule',L.label(id)) end
    return id
end
function R.known(id) return R.nativeName(id)~=nil or L.known(id) end
function R.isLeaf(id) return R.nativeName(id)~=nil or L.isLeaf(id) end
function R.isFamily(id) return L.isFamily(id) end
function R.isLegacy(id) return L.isLegacy(id) end
function R.isCompatibility(id) return L.known(id) end
function R.validRules(cats,previous)
    for id,on in pairs(cats) do
        if on~=true or not (R.known(id) or previous and previous[id]==true) then return false end
    end
    return true
end
function R.resolve(value)
    local category=R.nativeID(R.nativeCategory(value))
    -- Supplemental evidence interprets old saved rules only, never active categories.
    local _,_,legacy,semantic,historical,secondary=L.resolve(value)
    return category,'native-category',legacy,semantic,historical,secondary
end
function R.memberships(category,legacy,semantic,historical,secondary)
    local out={[category]=true}
    if semantic then
        for id in pairs(L.memberships(L.families.destination(semantic),legacy,semantic,historical,secondary)) do out[id]=true end
    end
    return out
end
function R.match(category,cats,legacy,semantic,historical,secondary)
    if not R.known(category) then return 0 end
    if cats[category] then return 3 end
    if semantic then return L.match(L.families.destination(semantic),cats,legacy,semantic,historical,secondary) end
    return 0
end
function R.rank(value)
    local id,reason=R.resolve(value)
    return id,reason,1000,'high',{{category=id,physical=id,reason=reason,weight=1000}}
end
function R.inspect(value)
    local id,reason,legacy=R.resolve(value)
    return id,reason,legacy,{{category=id,reason=reason}}
end
function R.semantic(value) return R.resolve(value) end
function R.invalidate() L.invalidate() end
function R.catalogEligible(value) return L.catalogEligible(value) end
function R.migrate(...) return L.migrate(...) end
return R
