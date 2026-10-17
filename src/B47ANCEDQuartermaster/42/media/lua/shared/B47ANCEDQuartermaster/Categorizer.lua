-- Active categories are native metadata, never an owned or imported item taxonomy.
require 'B47ANCEDQuartermaster/Schema'
local R={version=7,labels={}}
B47ANCEDQuartermaster.Categorizer=R
local function read(value,key)
    local kind=type(value)
    if kind~='table' and kind~='userdata' then return end
    -- Script definitions do not expose InventoryItem getters. A missing call
    -- still logs an engine exception inside pcall, so check before invocation.
    local method=value[key]
    if type(method)~='function' then return end
    local ok,result=pcall(method,value)
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
    return id
end
function R.known(id) return R.nativeName(id)~=nil end
function R.isLeaf(id) return R.known(id) end
function R.isFamily() return false end
function R.isCompatibility() return false end
function R.validRules(cats)
    for id,on in pairs(cats) do
        if on~=true or not R.known(id) then return false end
    end
    return true
end
function R.resolve(value)
    local category=R.nativeID(R.nativeCategory(value))
    return category,'native-category'
end
function R.memberships(category)
    return R.known(category) and {[category]=true} or {}
end
function R.match(category,cats)
    return R.known(category) and cats[category] and 3 or 0
end
function R.rank(value)
    local id,reason=R.resolve(value)
    return id,reason,1000,'high',{{category=id,physical=id,reason=reason,weight=1000}}
end
function R.inspect(value)
    local id,reason,legacy=R.resolve(value)
    return id,reason,legacy,{{category=id,reason=reason}}
end
function R.semantic(value) local category=R.resolve(value);return category end
function R.invalidate() end
function R.catalogEligible(item)
    if read(item,'isHidden')==true or read(item,'getObsolete')==true then return false,'native-hidden-obsolete' end
    local full=read(item,'getFullName');local display=read(item,'getDisplayCategory')
    if display=='Hidden' then return false,'native-hidden-category' end
    local kind=tostring(read(item,'getItemType') or ''):lower():gsub('^.-:','')
    if type(full)=='string' and full:match('^Base%.') and kind=='clothing' and (display=='Wound' or display=='ZedDmg') then return false,'native-body-damage-representation' end
    if full=='Base.Animal_Item_Dummy' or full=='Base.FISH_DEV_ITEM' or full=='Base.TestDebugWater' or full=='Base.DebugFluid' then return false,'verified-development-definition' end
    return true
end
return R
