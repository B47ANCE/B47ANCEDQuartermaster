require 'B47ANCEDQuartermaster/Schema'
local E={};B47ANCEDQuartermaster.EvolvedRequirements=E
local function integer(n) return type(n)=='number' and n==math.floor(n) and n>0 and n<=1000000 end
local function name(t) return type(t)=='string' and #t<=256 and t:match('^[%w_]+%.[%w_]+$') end
function E.intent(raw)
    if type(raw)~='table' or not name(raw.baseType) or raw.portion~='full' or type(raw.additions)~='table' then return end
    local result={baseType=raw.baseType,portion='full',additions={}};local seen={}
    for k in pairs(raw) do if k~='baseType' and k~='portion' and k~='additions' then return end end
    for i,a in ipairs(raw.additions) do
        if i>32 or type(a)~='table' or not name(a.fullType) or not integer(a.count)
            or (a.class~='ingredient' and a.class~='seasoning') or seen[a.fullType] then return end
        for k in pairs(a) do if k~='fullType' and k~='count' and k~='class' then return end end
        seen[a.fullType]=true;result.additions[#result.additions+1]={fullType=a.fullType,count=a.count,class=a.class}
    end
    local count=0;for k in pairs(raw.additions) do if type(k)~='number' then return end;count=count+1 end
    if count~=#result.additions or count==0 then return end
    table.sort(result.additions,function(a,b) return a.fullType<b.fullType end)
    return result
end
function E.key(recipe,raw)
    local intent=E.intent(raw);if not intent then return end
    local key='evolved:'..recipe..':'..intent.baseType
    for _,a in ipairs(intent.additions) do key=key..':'..a.class..':'..a.fullType..':'..a.count end
    return key
end
function E.identity(recipe) return recipe:getModule():getName()..'.'..recipe:getUntranslatedName() end
function E.lookup(id)
    local all=getScriptManager():getAllEvolvedRecipes();local found
    for i=0,all:size()-1 do local recipe=all:get(i)
        if E.identity(recipe)==id then if found then return end;found=recipe end
    end
    return found
end
-- Java's native portion arithmetic uses binary32, including the Cooking-level
-- reduction in regular ingredient consumption. Never simulate by item creation.
local float=require('B47ANCEDQuartermaster/NativeFloat').round
E.float=float
local function fresh(item)
    return not item:isBurnt() and not item:isRotten() and not item:isCooked() and not item:isFrozen()
        and item:getAge()<item:getOffAge()
end
function E.capacity(item,use,class,skill)
    if not instanceof(item,'Food') or not fresh(item) or item:getFluidContainer() then return 0 end
    local h=item:getHungChange();if type(h)~='number' or h>=0 or h~=h then return 0 end
    local portion=float(use/100)
    local consumed=class=='seasoning' and portion or float(portion-float(float((3*skill)/100)*portion))
    if portion<=0 or consumed<=0 then return 0 end
    local count=0
    -- Native recipe maxima bound a project's additions. This internal ceiling
    -- rejects ambiguous enormous-use items rather than approximating capacity.
    while -h>=portion and count<256 do
        count=count+1;h=float(h+consumed)
        if (class=='seasoning' and h> -0.01) or (class=='ingredient' and h>= -0.02) then return count end
    end
    if count==256 and -h>=portion then return 0 end
    return count
end
local function resolve(kind,id,quantity,player,raw)
    if kind~='evolved' or type(id)~='string' or #id>256 or not integer(quantity) then return nil,'invalid' end
    local intent=E.intent(raw);if not intent then return nil,'evolvedUnsupported' end
    local recipe=E.lookup(id);if not recipe then return nil,'invalid' end
    if recipe:getMinimumWater()>0 then return nil,'evolvedUnsupported' end
    local manager=getScriptManager();local base=manager:FindItem(intent.baseType)
    local result=manager:FindItem(recipe:getFullResultItem())
    if not result or result:getItemType()~=ItemType.FOOD then return nil,'evolvedUnsupported' end
    if not base or intent.baseType~=recipe:getBaseItem() or base:getReplaceOnUse() or base:getReplaceOnDeplete() then return nil,'evolvedUnsupported' end
    local skill=player:getPerkLevel(Perks.Cooking)
    if type(skill)~='number' or skill<0 or skill>10 or skill~=math.floor(skill) then return nil,'evolvedUnsupported' end
    local key=E.key(id,intent);local baseType=intent.baseType
    local nodes={{key=key..':base',class='base',amount=quantity,types={[baseType]=true},alternatives={baseType},
        accepts=function(it)
            if it:getFullType()~=baseType or it:haveExtraItems() or it:isNoRecipes(player) then return false end
            local fluid=it:getFluidContainer();if fluid and not fluid:isEmpty() then return false end
            if instanceof(it,'Food') then local spices=it:getSpices();return fresh(it) and (not spices or spices:size()==0) end
            return true
        end}}
    local regular=0
    for _,a in ipairs(intent.additions) do
        local script=manager:FindItem(a.fullType)
        local member=script and recipe:getItemsList():get(script:getName())
        if not member or member:getModule()~=script:getModuleName() or member:getUse()<=0
            or script:getItemType()~=ItemType.FOOD or script:getReplaceOnUse() or script:getReplaceOnDeplete()
            or script:isSpice()~=(a.class=='seasoning') then return nil,'evolvedUnsupported' end
        if a.class=='seasoning' then if a.count~=1 then return nil,'evolvedUnsupported' end
        else regular=regular+a.count end
        local t,class,use=a.fullType,a.class,member:getUse();local amount=a.count*quantity
        if amount>1000000 then return nil,'tooLarge' end
        local function units(it) return E.capacity(it,use,class,skill) end
        nodes[#nodes+1]={key=key..':'..class..':'..t,class=class,amount=amount,types={[t]=true},alternatives={t},
            pool=id..':'..class..':'..use..':'..skill,units=units,
            accepts=function(it) return it:getFullType()==t and not it:isNoRecipes(player) and units(it)>0 end}
    end
    if regular>recipe:getMaxItems() or regular==0 then return nil,'evolvedUnsupported' end
    return nodes
end
function E.resolve(...)
    local ok,nodes,err=pcall(resolve,...);if not ok then return nil,'evolvedUnsupported' end
    return nodes,err
end
return E
