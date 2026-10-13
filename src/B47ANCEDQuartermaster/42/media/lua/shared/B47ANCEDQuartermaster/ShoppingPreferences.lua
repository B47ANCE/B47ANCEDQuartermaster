B47ANCEDQuartermaster=B47ANCEDQuartermaster or {}
local F={};B47ANCEDQuartermaster.ShoppingPreferences=F
local modes={freshness={any=true,fresh=true,nonrotten=true},cooked={any=true,yes=true,no=true},frozen={any=true,yes=true,no=true},rotten={any=true,allow=true,exclude=true}}
local function number(n) return type(n)=='number' and n==n and n~=math.huge and n~=-math.huge end
function F.rule(raw)
    if type(raw)~='table' then return end
    local result={}
    for k,v in pairs(raw) do
        if k=='condition' or k=='uses' then
            if not number(v) or v<0 or v>100 or v~=math.floor(v) then return end
            result[k]=v
        elseif modes[k] then
            if not modes[k][v] then return end
            result[k]=v
        else return end
    end
    if (result.freshness=='fresh' or result.freshness=='nonrotten') and result.rotten=='exclude' then result.rotten=nil end
    return result
end
function F.normalize(raw)
    if raw==nil then return {schema=1,global={},overrides={},confirm=true} end
    if type(raw)~='table' or raw.schema~=1 or type(raw.overrides)~='table' or type(raw.confirm)~='boolean' then return end
    local global=F.rule(raw.global);if not global then return end
    local result={schema=1,global=global,overrides={},confirm=raw.confirm};local count=0
    for t,rule in pairs(raw.overrides) do
        count=count+1;if count>256 or type(t)~='string' or #t>256 then return end
        local r=F.rule(rule);if not r then return end
        -- Fields omitted from an override inherit the global rule.
        result.overrides[t]=r
    end
    return result
end
function F.applicable(item)
    return {condition=instanceof(item,'HandWeapon') or instanceof(item,'Clothing'),food=instanceof(item,'Food'),uses=instanceof(item,'DrainableComboItem')}
end
function F.forScript(script)
    local t=script and script:getItemType()
    return {condition=t~=nil and (t==ItemType.WEAPON or t==ItemType.CLOTHING or t==ItemType.ALARM_CLOCK_CLOTHING),food=t~=nil and t==ItemType.FOOD,uses=t~=nil and t==ItemType.DRAINABLE}
end
function F.compile(raw)
    local value=F.normalize(raw) or F.normalize(nil)
    local effective={}
    for t,override in pairs(value.overrides) do
        local r={};for k,v in pairs(value.global) do r[k]=v end;for k,v in pairs(override) do r[k]=v end;effective[t]=r
    end
    return function(item)
        local rule=effective[item:getFullType()] or value.global
        local ok,accepted=pcall(function()
            local applicable=F.applicable(item)
            if applicable.condition and rule.condition and rule.condition>0 then
                local max=item:getConditionMax();local n=item:getCondition()
                if not number(max) or max<=0 or not number(n) or n*100<max*rule.condition then return false end
            end
            if applicable.uses and rule.uses and rule.uses>0 then
                local n=item:getCurrentUsesFloat();if not number(n) or n*100<rule.uses then return false end
            end
            if applicable.food then
                if rule.freshness=='fresh' and not (item:getAge()<item:getOffAge()) then return false end
                if (rule.freshness=='nonrotten' or rule.rotten=='exclude') and item:isRotten() then return false end
                if rule.cooked and rule.cooked~='any' and item:isCooked()~=(rule.cooked=='yes') then return false end
                if rule.frozen and rule.frozen~='any' and item:isFrozen()~=(rule.frozen=='yes') then return false end
            end
            return true
        end)
        return ok and accepted==true
    end
end
function F.edit(player,args)
    local Q=B47ANCEDQuartermaster;local P=Q.Personal;local snapshot=P.snapshot(player)
    if snapshot.status~='ok' then return snapshot end
    local _,data=P.identity(player);if args.revision~=data.revision then return {status='conflict'} end
    local value=F.normalize(data.preferences) or F.normalize(nil)
    if args.action=='resetAll' then value=F.normalize(nil)
    elseif args.action=='confirm' and type(args.value)=='boolean' then value.confirm=args.value
    elseif args.action=='global' then
        local rule=F.rule(args.rule);if not rule then return {status='invalid'} end
        for k,v in pairs(rule) do if v==0 or v=='any' or v=='allow' then rule[k]=nil end end
        value.global=rule
    elseif args.action=='override' or args.action=='remove' then
        local t=args.fullType;if type(t)~='string' or #t>256 then return {status='invalid'} end
        if args.action=='remove' then value.overrides[t]=nil
        else
            local script=getScriptManager():FindItem(t);if not script then return {status='invalid'} end
            local rule=F.rule(args.rule);if not rule then return {status='invalid'} end
            local applicable=F.forScript(script)
            if not applicable.condition and not applicable.food and not applicable.uses then return {status='invalid'} end
            for k in pairs(rule) do
                if k=='condition' and not applicable.condition or k=='uses' and not applicable.uses
                    or k~='condition' and k~='uses' and not applicable.food then return {status='invalid'} end
            end
            local populated=false;for _ in pairs(rule) do populated=true end
            value.overrides[t]=populated and rule or nil;if not F.normalize(value) then return {status='tooLarge'} end
        end
    else return {status='invalid'} end
    data.preferences=value;data.revision=data.revision+1
    return P.snapshot(player)
end
return F
