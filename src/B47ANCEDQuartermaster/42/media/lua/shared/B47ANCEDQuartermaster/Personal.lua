require 'B47ANCEDQuartermaster/Schema'
require 'B47ANCEDQuartermaster/ShoppingRequirements'
require 'B47ANCEDQuartermaster/ShoppingPreferences'
local P={}
B47ANCEDQuartermaster.Personal=P
local function root()
    if isClient() then return end
    local md=ModData.getOrCreate('B47ANCEDQuartermaster')
    md.personal=md.personal or {schema=1,serial=0,accounts={},players={}}
    if type(md.personal)~='table' or md.personal.schema~=1 or type(md.personal.accounts)~='table'
        or type(md.personal.players)~='table' or type(md.personal.serial)~='number'
        or md.personal.serial~=math.floor(md.personal.serial) or md.personal.serial<0 or md.personal.serial>=9007199254740990 then return end
    return md.personal
end
function P.identity(player)
    local r=root();if not r then return end
    local id
    if isServer() then
        local account=player:getUsername()
        if type(account)~='string' or account=='' then return end
        id=r.accounts[account]
        if not id then r.serial=r.serial+1;id='p'..r.serial;r.accounts[account]=id end
    else
        local md=player:getModData()
        id=md.B47PersonalIdentity
        if not id or not r.players[id] then r.serial=r.serial+1;id='p'..r.serial;md.B47PersonalIdentity=id end
    end
    r.players[id]=r.players[id] or {revision=0,shopping={},wish={}}
    local data=r.players[id]
    if data.wishSchema==nil or data.wishSchema==1 then
        -- dev.2 counters were historical acquisition, never current possession.
        -- Preserve targets; explicitly retire counters without granting credit.
        data.wishProgress=nil;data.wishDemand={};data.wishSchema=2
    elseif data.wishSchema~=2 or type(data.wishDemand)~='table' then return end
    if data.dibsListSchema==nil then
        data.needed={};data.neededDemand={};data.extras={};data.addReceipts={};data.dibsListSchema=1
    elseif data.dibsListSchema~=1 or type(data.needed)~='table' or type(data.neededDemand)~='table'
        or type(data.extras)~='table' or type(data.addReceipts)~='table' then return end
    -- A read must not erase corrupt or future-schema preferences and silently
    -- relax collection constraints. Only absent preferences receive defaults.
    local preferences=B47ANCEDQuartermaster.ShoppingPreferences.normalize(data.preferences)
    if not preferences then return nil,nil,'schema' end
    if data.preferences==nil then data.preferences=preferences end
    return id,r.players[id]
end
function P.establishWish(player,fullType,kind)
    local _,data=P.identity(player);if not data then return false end
    local targets=kind=='needed' and data.needed or data.wish
    if targets[fullType] then return true end
    if type(fullType)~='string' or not getScriptManager():FindItem(fullType) then return false end
    local count=0;for _ in pairs(targets) do count=count+1 end;if count>=256 then return false end
    targets[fullType]=1;data.revision=data.revision+1
    return true
end
function P.snapshot(player)
    local id,data,error=P.identity(player);if not id then return {status=error or 'identity'} end
    if data.shoppingSchema~=nil and data.shoppingSchema~=2 then return {status='unsupported'} end
    if not data.shoppingSchema then
        -- dev.1 stored outstanding only. Preserve that outstanding at migration;
        -- original historical project demand did not exist and is not invented.
        for _,item in ipairs(B47ANCEDQuartermaster.ShoppingRequirements.carried(player)) do
            local t=item:getFullType();if data.shopping[t] then data.shopping[t]=data.shopping[t]+1 end
        end
        data.shoppingSchema=2;data.projects={}
    end
    local R=B47ANCEDQuartermaster.ShoppingRequirements
    local items=R.carried(player);local counts={};local accepts=B47ANCEDQuartermaster.ShoppingPreferences.compile(data.preferences)
    for _,item in ipairs(items) do if accepts(item) then local t=item:getFullType();counts[t]=(counts[t] or 0)+1 end end
    local ledger,err=R.ledger(player,data,nil,items)
    local result={status='ok',identity=id,revision=data.revision,shopping={},manual={},projects={},wish={},wishActive=true,wishDemand={},
        requirements=ledger and ledger.rows or {},gross=ledger and ledger.gross or 0,
        carried=ledger and ledger.carried or 0,outstanding=ledger and ledger.outstanding or 0,shoppingBlocked=err,
        collected=data.collectedSinceEdit or 0}
    for t,n in pairs(data.shopping) do result.manual[t]=n end
    result.wishGoals={}
    for t,n in pairs(data.wish) do
        result.wish[t]=n
        local current=counts[t] or 0
        result.wishGoals[t]={target=n,current=current,remaining=math.max(0,n-current),fulfilled=current>=n}
        if data.wishDemand[t] then result.wishDemand[t]=math.max(0,n-current) end
    end
    result.wanted=result.wish;result.wantedGoals=result.wishGoals
    result.needed={};result.neededGoals={};result.neededDemand={};result.extras={}
    result.preferences=B47ANCEDQuartermaster.ShoppingPreferences.normalize(data.preferences)
    result.summaries={wanted={total=0,fulfilled=0,remaining=0},needed={total=0,fulfilled=0,remaining=0}}
    for t,n in pairs(data.needed) do
        result.needed[t]=n;local current=counts[t] or 0
        result.neededGoals[t]={target=n,current=current,remaining=math.max(0,n-current),fulfilled=current>=n}
        if data.neededDemand[t] then result.neededDemand[t]=math.max(0,n-current) end
    end
    for _,kind in ipairs({'wanted','needed'}) do
        local summary=result.summaries[kind]
        for _,goal in pairs(result[kind..'Goals']) do
            summary.total=summary.total+1;summary.fulfilled=summary.fulfilled+(goal.fulfilled and 1 or 0);summary.remaining=summary.remaining+goal.remaining
        end
    end
    for key,extra in pairs(data.extras) do result.extras[#result.extras+1]={key=key,fullType=extra.fullType,quantity=extra.quantity,source=extra.source} end
    table.sort(result.extras,function(a,b) return a.key<b.key end)
    for key,project in pairs(data.projects or {}) do
        result.projects[#result.projects+1]={key=key,kind=project.kind,recipe=project.recipe,quantity=project.quantity,
            origin=project.origin,
            intent=project.intent and B47ANCEDQuartermaster.EvolvedRequirements.intent(project.intent) or nil}
    end
    table.sort(result.projects,function(a,b) return a.key<b.key end)
    if ledger then for _,row in ipairs(ledger.rows) do
        if row.outstanding>0 and #row.alternatives==1 and not row.units then
            local t=row.alternatives[1];result.shopping[t]=(result.shopping[t] or 0)+row.outstanding
        end
    end
    end
    return result
end
function P.project(player,args)
    local current=P.snapshot(player);if current.status~='ok' then return current end
    local _,data=P.identity(player)
    if args.revision~=data.revision then return {status='conflict'} end
    local key=B47ANCEDQuartermaster.ShoppingRequirements.projectKey(args.kind,args.recipe,args.intent,args.origin)
    if not key then return {status='invalid'} end
    local old=data.projects[key];local n=args.quantity
    if type(n)~='number' or n~=math.floor(n) or n<0 or n>1000000 then return {status='invalid'} end
    if args.add and n==0 then return {status='invalid'} end
    if args.add then n=n+(old and old.quantity or 0) end
    if n>0 then
        local nodes,err=B47ANCEDQuartermaster.ShoppingRequirements.resolve(args.kind,args.recipe,n,player,args.intent)
        if not nodes then return {status=err} end
        local count=0;for _ in pairs(data.projects) do count=count+1 end
        if not old and count>=256 then return {status='tooLarge'} end
    elseif not old then return {status='invalid'} end
    data.projects[key]=n>0 and {kind=args.kind,recipe=args.recipe,quantity=n,
        origin=args.origin,
        intent=args.kind=='evolved' and B47ANCEDQuartermaster.EvolvedRequirements.intent(args.intent) or nil} or nil
    local ledger,err=B47ANCEDQuartermaster.ShoppingRequirements.ledger(player,data)
    if not ledger and n>0 then data.projects[key]=old;return {status=err} end
    data.revision=data.revision+1;data.collectedSinceEdit=0
    return P.snapshot(player)
end
function P.change(player,args)
    local snapshot=P.snapshot(player);if snapshot.status~='ok' then return snapshot end
    local _,data=P.identity(player)
    if not data or (args.kind~='shopping' and args.kind~='wish' and args.kind~='wanted' and args.kind~='needed') then return {status='invalid'} end
    local kind=args.kind=='wanted' and 'wish' or args.kind
    if args.revision~=data.revision then return {status='conflict'} end
    local t,n=args.fullType,args.quantity
    if type(t)~='string' or #t>256
        or type(n)~='number' or n~=math.floor(n) or n<0 or n>1000000 then return {status='invalid'} end
    local existed=data[kind][t]~=nil
    if n>0 and not existed and not getScriptManager():FindItem(t) then return {status='invalid'} end
    local count=0;for _ in pairs(data[kind]) do count=count+1 end
    if n>0 and not data[kind][t] and count>=256 then return {status='tooLarge'} end
    data[kind][t]=n>0 and n or nil;data.revision=data.revision+1
    if kind=='shopping' then data.collectedSinceEdit=0 end
    if kind=='wish' then
        if n==0 then data.wishDemand[t]=nil end
    end
    if kind=='needed' and n==0 then data.neededDemand[t]=nil end
    return P.snapshot(player)
end
function P.wishToShopping(player,args)
    local snapshot=P.snapshot(player);if snapshot.status~='ok' then return snapshot end
    local _,data=P.identity(player);local t=args.fullType
    if args.revision~=data.revision then return {status='conflict'} end
    local needed=args.kind=='needed';local targets=needed and data.needed or data.wish
    local demand=needed and data.neededDemand or data.wishDemand
    local goals=needed and snapshot.neededGoals or snapshot.wishGoals
    if type(t)~='string' or not targets[t] or not getScriptManager():FindItem(t) then return {status='invalid'} end
    if goals[t].remaining==0 then return {status='fulfilled'} end
    -- A linked gross target yields the deficit after ONE aggregate carried
    -- allocation. Storing the deficit as gross would subtract carried twice.
    local old=demand[t];demand[t]=true
    local ledger,err=B47ANCEDQuartermaster.ShoppingRequirements.ledger(player,data)
    if not ledger then demand[t]=old;return {status=err} end
    if not old then data.revision=data.revision+1;data.collectedSinceEdit=0 end
    return P.snapshot(player)
end
-- Only successful authoritative withdrawal confirmation calls this function.
function P.collected(player,fullType)
    local _,data=P.identity(player);if not data then return end
    -- Gross demand persists. Current native carried items supply the credit.
    data.revision=data.revision+1;data.collectedSinceEdit=(data.collectedSinceEdit or 0)+1
end
return P
