local Ownership=require 'B47ANCEDQuartermaster/Ownership'
function getText(k) return k end
local function item(name,owner,cat,hidden)
    return {isHidden=function() return hidden end,getObsolete=function() return false end,
        getDisplayName=function() return name end,getDisplayCategory=function() return cat or 'Food' end,
        getModID=function() return owner end}
end
local data={item('Apple','pz-vanilla'),item('Soup','CookingID'),item('Shared','CookingID'),
    item('Shared','OtherID'),item('Missing',nil),item('Unlisted','GoneID'),item('Hidden','CookingID',nil,true)}
function getScriptManager() return {getAllItems=function()
    return {size=function() return #data end,get=function(_,i) return data[i+1] end}
end} end
local lookups=0
function getModInfoByID(id)
    lookups=lookups+1
    if id=='CookingID' then return {getName=function() return 'Cooking Mod' end} end
end
local owner=Ownership.build()
local id,label=owner('Food','Apple');assert(id=='pz-vanilla' and label=='UI_QMSS_Vanilla')
id,label=owner('Food','Soup');assert(id=='CookingID' and label=='Cooking Mod')
owner('Food','Soup');assert(lookups==1,'mod title not cached')
id,label=owner('Food','Shared');assert(id=='unknown:' and label=='UI_QMSS_Unknown')
assert(owner('Food','Missing')=='unknown:' and owner('Food','Hidden')=='unknown:')
id,label=owner('Food','Unlisted');assert(id=='GoneID' and label=='GoneID')
assert(owner('Food','Base.Apple')=='unknown:','guessed provenance from module prefix')
getScriptManager=function() error('unavailable') end
assert(Ownership.build()('Food','Apple')=='unknown:')
print('PASS ownership: engine mod IDs, vanilla sentinel, titles, ambiguity/missing fallback, cached metadata')
