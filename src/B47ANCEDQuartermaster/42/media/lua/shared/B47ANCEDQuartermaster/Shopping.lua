require 'B47ANCEDQuartermaster/Personal'
require 'B47ANCEDQuartermaster/Trips'
local Q=B47ANCEDQuartermaster
local M,B,T=Q.Movement,Q.Bindings,Q.Targets
local H={};Q.Shopping=H
function H.confirm(player,op)
    if op.confirmed then return end
    op.confirmed=true
    local run=op.shoppingRun
    local fullType=op.item:getFullType()
    run.collected=run.collected+1
    Q.Personal.collected(player,fullType)
end
function H.handle(player,command,args)
    if isClient() then return {status='invalid'} end
    local run=M.runs[player]
    if command=='shoppingBegin' then
        if run or M.operations[player] then return {status='busy'} end
        local snapshot=Q.Personal.snapshot(player);if snapshot.status~='ok' then return snapshot end
        if snapshot.shoppingBlocked then return {status=snapshot.shoppingBlocked} end
        if args.wish then
            if args.list~=nil and args.list~='wish' and args.list~='needed' then return {status='invalid'} end
            local goal=(args.list=='needed' and snapshot.neededGoals or snapshot.wishGoals)[args.wish]
            local linked=args.list=='needed' and snapshot.neededDemand or snapshot.wishDemand
            if not goal or linked[args.wish]==nil then return {status='invalid'} end
            if goal.remaining==0 then return {status='fulfilled'} end
        elseif snapshot.outstanding==0 then return {status='empty'} end
        local previous=B.sessions[player]
        local result,err=B.discover(player,{scope={x=math.floor(player:getX()),y=math.floor(player:getY()),z=math.floor(player:getZ())}})
        local s=B.sessions[player];B.sessions[player]=previous
        if not result then return {status=err} end
        local records={}
        for _,meta in ipairs(result.targets) do records[#records+1]=s.records[meta.token] end
        table.sort(records,function(a,b)
            local x,y=a.position,b.position
            local dx=(x.x-player:getX())^2+(x.y-player:getY())^2
            local dy=(y.x-player:getX())^2+(y.y-player:getY())^2
            if dx~=dy then return dx<dy end
            for _,k in ipairs({'x','y','z','index','ci'}) do if x[k]~=y[k] then return x[k]<y[k] end end
            return a.token<b.token
        end)
        run={id=M.fresh(),kind='shopping',scope=args.wish and {wish=args.wish,list=args.list} or nil,time=getTimestampMs(),records=records,
            operations={},considered=setmetatable({},{__mode='k'}),collected=0}
        M.runs[player]=run
        return {status='ok',run=run.id}
    end
    if not run or run.kind~='shopping' or run.id~=args.run then return {status='invalid'} end
    if command=='shoppingCancel' then
        run.cancelled=true
        for _,op in pairs(run.operations) do M.handle(player,'moveCancel',{operation=op.id}) end
        local pending=false;for _ in pairs(run.operations) do pending=true end
        if not pending then M.runs[player]=nil end
        return {status='ok',collected=run.collected}
    end
    if command~='shoppingNext' or run.cancelled then return {status='invalid'} end
    for _ in pairs(run.operations) do return {status='busy'} end
    local _,data=Q.Personal.identity(player)
    local ledger,err=Q.ShoppingRequirements.ledger(player,data,run.scope)
    if not ledger then M.runs[player]=nil;return {status=err} end
    local capacity=false
    -- Preserve deterministic distance/ID ordering within each semantic tier.
    -- This reuses the same discovered records and never changes movement grants.
    local tiers={{},{},{}}
    for _,record in ipairs(run.records) do
        if not record.revoked and T.valid(record.target,player) and Q.RoomAccess.can(player,record.target,'inspect') and Q.RoomAccess.can(player,record.target,'withdraw') then
            local items=record.target.container:getItems();local sorted={}
            for i=0,items:size()-1 do sorted[#sorted+1]=items:get(i) end
            table.sort(sorted,function(a,b) return a:getID()<b:getID() end)
            for _,item in ipairs(sorted) do
                if not run.considered[item] then
                    local priority=Q.ShoppingRequirements.priority(ledger,item)
                    if priority>0 and M.eligible(player,item) then tiers[priority][#tiers[priority]+1]={record=record,item=item} end
                end
            end
        end
    end
    for priority=3,1,-1 do
        for _,candidate in ipairs(tiers[priority]) do
                local record,item=candidate.record,candidate.item
                if not record.revoked and T.valid(record.target,player) and Q.RoomAccess.can(player,record.target,'inspect') and Q.RoomAccess.can(player,record.target,'withdraw') and Q.ShoppingRequirements.worthTaking(ledger,item) then
                    for _,c in ipairs(Q.Trips.carriers(player)) do
                        local budget=math.max(0,player:getMaxWeight()-player:getInventory():getCapacityWeight())
                        if item:getActualWeight()*c.factor<=budget then
                            local offer,op=M.withdraw(player,record,c.id,{item=item})
                            if op then
                                op.shoppingRun=run;run.operations[op.id]=op;run.considered[item]=true
                                return offer
                            elseif offer.status=='capacity' then capacity=true end
                        else capacity=true end
                    end
                end
        end
    end
    M.runs[player]=nil
    return {status=capacity and 'capacity' or 'done',collected=run.collected,lists=Q.Personal.snapshot(player)}
end
return H
