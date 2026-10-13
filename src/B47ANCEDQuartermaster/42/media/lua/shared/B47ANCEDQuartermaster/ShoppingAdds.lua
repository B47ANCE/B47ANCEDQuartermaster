require 'B47ANCEDQuartermaster/Personal'
local Q=B47ANCEDQuartermaster;local A={};Q.ShoppingAdds=A
local function integer(n) return type(n)=='number' and n==math.floor(n) and n>0 and n<=1000000 end
local function copy(value) local result={};for k,v in pairs(value) do result[k]=v end;return result end
function A.handle(player,args)
    local snapshot=Q.Personal.snapshot(player);if snapshot.status~='ok' then return snapshot end
    local _,data=Q.Personal.identity(player)
    local operation=args.operation
    if type(operation)~='string' or #operation<1 or #operation>100 then return {status='invalid'} end
    if args.bulk~=nil and type(args.bulk)~='boolean' or args.again~=nil and type(args.again)~='boolean' then return {status='invalid'} end
    local kind=args.kind;local key;local selected={};local new,duplicate=0,0
    if kind=='shopping' then
        if type(args.fullType)~='string' or #args.fullType>256 or not getScriptManager():FindItem(args.fullType) or not integer(args.quantity) then return {status='invalid'} end
        key='manual:'..args.fullType
        duplicate=data.shopping[args.fullType] and 1 or 0;new=1-duplicate
    elseif kind=='craft' or kind=='build' or kind=='evolved' then
        key=Q.ShoppingRequirements.projectKey(kind,args.recipe,args.intent,args.origin)
        if not key or not integer(args.quantity) then return {status='invalid'} end
        local nodes,err=Q.ShoppingRequirements.resolve(kind,args.recipe,args.quantity,player,args.intent)
        if not nodes then return {status=err} end
        duplicate=data.projects[key] and 1 or 0;new=1-duplicate
    elseif kind=='wanted' or kind=='needed' then
        local targets=kind=='wanted' and data.wish or data.needed
        local links=kind=='wanted' and data.wishDemand or data.neededDemand
        if args.bulk==true then for t in pairs(targets) do selected[#selected+1]=t end
        elseif type(args.fullType)=='string' and targets[args.fullType] then selected[1]=args.fullType
        else return {status='invalid'} end
        table.sort(selected);local qualifying={}
        for _,t in ipairs(selected) do
            if snapshot[kind..'Goals'][t].remaining>0 and getScriptManager():FindItem(t) then
                qualifying[#qualifying+1]=t
                if links[t] then duplicate=duplicate+1 else new=new+1 end
            end
        end
        selected=qualifying;key=kind..':'..(args.bulk and 'bulk' or args.fullType)
    else return {status='invalid'} end
    local digest=key..'|'..tostring(args.quantity)..'|'..tostring(args.revision)..'|'..tostring(args.again==true)
    local receipt=data.addReceipts[operation]
    if receipt then
        if receipt.digest~=digest then return {status='invalid'} end
        if receipt.committed then snapshot.replayed=true;return snapshot end
    end
    if args.revision~=data.revision then return {status='conflict'} end
    if (kind=='wanted' or kind=='needed') and #selected==0 then return {status='fulfilled'} end
    local now=getTimestampMs();local activation=data.lastAdd
    local signature=key..'|'..tostring(args.quantity)
    if not receipt and activation and activation.signature==signature and now>=activation.time and now-activation.time<350 then
        snapshot.replayed=true;return snapshot
    end
    local confirmed=false
    if args.confirmation then
        if not receipt or receipt.token~=args.confirmation or receipt.revision~=data.revision or now-receipt.time>60000 then return {status='conflict'} end
        if args.mode~='again' and args.mode~='newOnly' then return {status='invalid'} end
        confirmed=args.mode=='again'
    elseif duplicate>0 and data.preferences.confirm then
        if receipt and receipt.revision==data.revision and now-receipt.time<=60000 then
            return {status='duplicate',confirmation=receipt.token,new=new,duplicate=duplicate,revision=data.revision}
        end
        local count=0;for _ in pairs(data.addReceipts) do count=count+1 end
        if count>=256 then
            local victim,serial
            for op,r in pairs(data.addReceipts) do local age=r.serial or -1;if not serial or age<serial then serial=age;victim=op end end
            if victim then data.addReceipts[victim]=nil end
        end
        local token=Q.Movement.fresh()
        data.addReceipts[operation]={digest=digest,token=token,time=now,revision=data.revision}
        return {status='duplicate',confirmation=token,new=new,duplicate=duplicate,revision=data.revision}
    elseif args.mode~=nil then return {status='invalid'} end
    local old={shopping=data.shopping,projects=data.projects,wishDemand=data.wishDemand,neededDemand=data.neededDemand,extras=data.extras}
    data.shopping=copy(data.shopping);data.projects=copy(data.projects);data.wishDemand=copy(data.wishDemand);data.neededDemand=copy(data.neededDemand);data.extras=copy(data.extras)
    local function reject(status)
        for k,v in pairs(old) do data[k]=v end
        return {status=status}
    end
    if kind=='shopping' then
        if args.mode~='newOnly' or duplicate==0 then
            local n=(data.shopping[args.fullType] or 0)+args.quantity;if n>1000000 then return reject('tooLarge') end
            data.shopping[args.fullType]=n
        end
    elseif kind=='craft' or kind=='build' or kind=='evolved' then
        if args.mode~='newOnly' or duplicate==0 then
            local n=args.quantity+(data.projects[key] and data.projects[key].quantity or 0)
            if not integer(n) then return reject('tooLarge') end
            data.projects[key]={kind=kind,recipe=args.recipe,quantity=n,origin=args.origin,intent=kind=='evolved' and Q.EvolvedRequirements.intent(args.intent) or nil}
        end
    else
        local links=kind=='wanted' and data.wishDemand or data.neededDemand
        for _,t in ipairs(selected) do
            if links[t] and (confirmed or args.again==true and not data.preferences.confirm) then
                -- Extra demand is independent from the synchronized possession goal.
                data.extras[operation..':'..t]={fullType=t,quantity=snapshot[kind..'Goals'][t].remaining,source=kind}
            else links[t]=true end
        end
    end
    for _,field in ipairs({'shopping','projects','extras'}) do local count=0;for _ in pairs(data[field]) do count=count+1 end;if count>256 then return reject('tooLarge') end end
    local ledger,err=Q.ShoppingRequirements.ledger(player,data);if not ledger then return reject(err) end
    data.revision=data.revision+1;data.collectedSinceEdit=0
    data.addSerial=(data.addSerial or 0)+1
    data.addReceipts[operation]={digest=digest,committed=true,serial=data.addSerial}
    -- Protocol history is bounded. Evicted exact replays carry an obsolete
    -- revision, so they still cannot become a fresh addition.
    local count=0;for _ in pairs(data.addReceipts) do count=count+1 end
    if count>256 then
        local victim,oldest
        for op,r in pairs(data.addReceipts) do if op~=operation then
            local age=r.serial or -1;if not oldest or age<oldest then oldest=age;victim=op end
        end end
        if victim then data.addReceipts[victim]=nil end
    end
    data.lastAdd={signature=signature,time=now}
    return Q.Personal.snapshot(player)
end
function A.remove(player,args)
    local snapshot=Q.Personal.snapshot(player);if snapshot.status~='ok' then return snapshot end
    local _,data=Q.Personal.identity(player);if args.revision~=data.revision then return {status='conflict'} end
    if args.kind=='extra' and type(args.key)=='string' and data.extras[args.key] then data.extras[args.key]=nil
    elseif (args.kind=='wanted' or args.kind=='needed') and type(args.fullType)=='string' then
        local links=args.kind=='wanted' and data.wishDemand or data.neededDemand;links[args.fullType]=nil
    else return {status='invalid'} end
    data.revision=data.revision+1;return Q.Personal.snapshot(player)
end
return A
