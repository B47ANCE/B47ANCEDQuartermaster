-- Original synthetic items; no third-party category database.
local function script(name,kind,tags,category,owner)
    return {getFullName=function() return 'Fixture.'..name end,getDisplayName=function() return name end,
        getItemType=function() return kind end,getTags=function() return tags or {} end,
        getDisplayCategory=function() return category end,getModID=function() return owner or 'pz-vanilla' end,
        getModuleName=function() return 'Fixture' end,isHidden=function() return false end,getObsolete=function() return false end}
end
local items={script('RoundA','normal',{'base:ammo'}),script('RoundB','normal',{'base:ammo'}),
    script('RoundC','normal',{'base:ammo'}),script('Lunch','food',nil,nil,'fixture-mod')}
function getScriptManager() return {getAllItems=function() return {size=function() return #items end,get=function(_,i) return items[i+1] end} end} end
function getModInfoByID(id) return {getName=function() return id end} end
CATALOG_FIXTURE={script=script,items=items}
