require 'B47ANCEDQuartermaster/Planner'
require 'B47ANCEDQuartermaster/Presets'
local M={operations={},runs={}}
B47ANCEDQuartermaster.Movement=M
local B,T,P=B47ANCEDQuartermaster.Bindings,B47ANCEDQuartermaster.Targets,B47ANCEDQuartermaster.Planner
local identities=setmetatable({},{__mode='k'})
local sequence=0
local G=require 'B47ANCEDQuartermaster/GroundSources'
local Trace=require 'B47ANCEDQuartermaster/SortTrace'
local function fresh()
    sequence=sequence+1
    return tostring(getTimestampMs())..':'..sequence
end
-- Ephemeral protocol limits, not configurable gameplay speed/range settings.
local lifetime=1800000
local function near(player,t)
    local s=t.obj:getSquare()
    return T.sameFloor(player,s) and math.max(math.abs(player:getX()-s:getX()),math.abs(player:getY()-s:getY()))<=2
end
-- An arrival query cannot grant movement until the server observes adjacency.
-- This deadline is a protocol safety bound, not a gameplay delay/setting.
local function arrival(player,op,target,leg)
    local time=getTimestampMs()
    op.arrivalDeadlines=op.arrivalDeadlines or {}
    local deadline=op.arrivalDeadlines[leg]
    if deadline and time>=deadline then return {status='invalid',reason='arrivalTimeout'} end
    if near(player,target) then return nil end
    op.arrivalDeadlines[leg]=deadline or time+15000
    return {status='waiting',reason='arrivalPending'}
end
local function eligible(player,item)
    return item and not item:isEquipped() and not item:isFavorite() and item:getAttachedSlot()==-1
        and not item:getIsCraftingConsumed()
end
local function present(container,item)
    return item:getContainer()==container and container:getItemWithID(item:getID())==item
end
local function accepts(player,container,item)
    return container:isItemAllowed(item) and container:hasRoomFor(player,item)
end
function M.carrier(player,id)
    if not id or id==0 then return player:getInventory() end
    local item=player:getInventory():getItemWithIDRecursiv(id)
    if item and instanceof(item,'InventoryContainer') and item:isEquipped() then return item:getInventory() end
end
local function identity(t)
    local id=identities[t.obj]
    if not id then id=fresh();identities[t.obj]=id end
    -- Native object ModData replication conveys an incarnation marker, never a
    -- client permission. Server validation continues to use retained references.
    local md=t.obj:getModData()
    if md.B47MovementInstance~=id then
        md.B47MovementInstance=id
        t.obj:transmitModData()
    end
    local d=T.descriptor(t)
    return {x=d.x,y=d.y,z=d.z,ci=t.ci,instance=id}
end
local function valid(player,op)
    if getTimestampMs()-op.time>=lifetime then return false,'expired' end
    if not eligible(player,op.item) then return false,'itemProtected' end
    if M.carrier(player,op.carrierID)~=op.carrier then return false,'carrierChanged' end
    if op.withdrawal then return true end
    if op.destinationRecord.revoked or not T.valid(op.destination,player) then return false,'destinationInvalidated' end
    if op.destination.obj:getModData().B47MovementInstance~=op.marker then return false,'destinationMarkerChanged' end
    if not B47ANCEDQuartermaster.Schema.equal(op.config,B47ANCEDQuartermaster.Store.load(op.destination,player)) then return false,'configurationChanged' end
    if not B47ANCEDQuartermaster.Schema.equal(op.effective,B47ANCEDQuartermaster.Presets.resolve(op.config)) then return false,'effectiveRulesChanged' end
    return true
end
function M.withdraw(player,record,carrierID,run)
    if isClient() or not record or record.revoked or not T.valid(record.target,player) then return {status='invalid'} end
    local position=T.descriptor(record.target)
    for _,key in ipairs({'x','y','z','ci'}) do if position[key]~=record.position[key] then return {status='invalid'} end end
    local container=record.target.container
    local item=run.item
    local carrier=M.carrier(player,carrierID)
    if not eligible(player,item) or not present(container,item) or not container:isRemoveItemAllowed(item) then return {status='invalid'} end
    if not carrier or not accepts(player,carrier,item) then return {status='capacity'} end
    local meta=identity(record.target)
    local op={id=fresh(),time=getTimestampMs(),item=item,source=record.target,sourceRecord=record,container=container,
        carrier=carrier,carrierID=carrierID,withdrawal=true,phase='planned',shoppingRun=run,sourceMarker=meta.instance}
    return {status='ok',operation=op.id,itemID=item:getID(),source=meta,carrierID=carrierID,withdrawal=true},op
end
function M.planOne(player,args,context)
    if isClient() then return {status="invalid"} end
        -- No destination/category/configuration submitted by the client is used.
        if args.destination~=nil or args.target~=nil or args.config~=nil then return {status='invalid'} end
        if not B.session(player,args.session) or type(args.itemID)~='number' or args.itemID~=math.floor(args.itemID) then return {status='invalid'} end
        local source,sourceRecord
        local carriedSource=type(args.source)=='string' and args.source:match('^bag:(%d+)$')
        if context and context.ground then
            source=context.ground;sourceRecord=source.record or {};if not (source.ground and G.valid(source,player) or not source.ground and T.valid(source,player)) then return {status='invalid'} end
        elseif args.source~='inventory' and not carriedSource then
            local r=B.target(player,args.session,args.source)
            if not r or (not (context and context.prepareAway) and not near(player,r.target)) then return {status='invalid'} end
            source=r.target
            sourceRecord=r
        end
        local container=source and source.container or M.carrier(player,tonumber(carriedSource))
        if not container then return {status='invalid'} end
        local item=context and context.ground and context.ground.item or container:getItemWithID(args.itemID)
        if not eligible(player,item) or not (source and source.ground and G.valid(source,player) or present(container,item)) or not container:isRemoveItemAllowed(item) then return {status='invalid'} end
        local carrierID=context and context.carrierID or tonumber(carriedSource) or 0
        local carrier=M.carrier(player,carrierID)
        if not carrier or (source and not accepts(player,carrier,item)) then return {status='capacity'} end
        local library=context and context.library or B47ANCEDQuartermaster.Presets.snapshot()
        local choice,rejection=P.choose(player,args.session,item,library and library.definitions or {},function(t,it,candidate)
            if context and context.planning then
                return candidate.rulesReady and accepts(player,t.container,it) and (not context.accepts or context.accepts(t,it))
            end
            local config=B47ANCEDQuartermaster.Store.load(t,player)
            return config and B47ANCEDQuartermaster.Presets.resolve(config) and accepts(player,t.container,it)
                and (not context or context.accepts(t,it))
        end,context and context.trace,context and context.planning)
        if not choice then Trace.emit(context and context.trace,'DESTINATION_REJECTED','noDestination');return {status='noDestination',reason=rejection} end
        Trace.emit(context and context.trace,'RULE_MATCHED','ok',nil,choice.key)
        local dest=identity(choice.target)
        local op={id=fresh(),time=getTimestampMs(),item=item,source=source,sourceRecord=sourceRecord,container=container,
            carrier=carrier,carrierID=carrierID,
            destinationRecord=B.sessions[player].records[choice.key],
            destination=choice.target,config=choice.config,effective=choice.effective,marker=dest.instance,trace=context and context.trace,phase=source and 'planned' or 'carried'}
        return {status='ok',operation=op.id,itemID=item:getID(),destination=dest,
            carrierID=carrierID,source=source and (source.ground and G.descriptor(source) or identity(source)) or false,carried=not source},op
end
local function forget(player,op)
    if M.operations[player]==op then M.operations[player]=nil end
    local run=M.runs[player]
    if run then run.operations[op.id]=nil end
end
function M.handle(player,command,args)
    if isClient() or not player or type(args)~='table' then return {status='invalid'} end
    if command=='moveBatch' then
        local allowed={moveTake=true,moveCarried=true,movePut=true,moveDone=true}
        local ids=args.operations
        if not allowed[args.phase] or type(ids)~='table' or getmetatable(ids)~=nil or #ids<1 or #ids>100 then return {status='invalid'} end
        local seen={};local count=0
        -- Validate the entire bounded payload before changing any grant state.
        for index,id in pairs(ids) do
            if type(index)~='number' or index<1 or index>#ids or index~=math.floor(index)
                or type(id)~='string' or #id<1 or #id>128 or id:find('%c') or seen[id] then return {status='invalid'} end
            seen[id]=true;count=count+1
        end
        if count~=#ids then return {status='invalid'} end
        local results={}
        for i,id in ipairs(ids) do
            local result=M.handle(player,args.phase,{operation=id,trace=args.trace})
            results[i]={operation=id,status=result.status,reason=result.reason}
        end
        return {status='ok',results=results}
    end
    local op=M.operations[player]
    if M.runs[player] and args.operation then op=M.runs[player].operations[args.operation] end
    if op and getTimestampMs()-op.time>=lifetime then M.operations[player]=nil;op=nil end
    if command=='movePlan' then
        if op or M.runs[player] then return {status='busy'} end
        local offer,record=M.planOne(player,args)
        M.operations[player]=record
        return offer
    end
    if not op or args.operation~=op.id then return {status='invalid',reason='operationNotFound'} end
    if command=='moveCancel' then
        if args.outcome~=nil and args.outcome~='notSubmitted' and args.outcome~='rejected' and args.outcome~='unknown' then return {status='invalid'} end
        -- Cancellation only relinquishes this player's grant; it never moves,
        -- credits or rolls back an item. Keep unknown native outcomes observed.
        if op.withdrawal and op.phase=='take' and args.outcome~='notSubmitted' and args.outcome~='rejected' then op.cancelRequested=true
        else forget(player,op) end
        return {status='ok'}
    end
    if command=='moveDone' then
        if op.phase~='put' then return {status='invalid'} end
        -- Confirmation is read-only. Never retry or roll back an uncertain move.
        if not present(op.destination.container,op.item) then return {status='waiting'} end
        forget(player,op);return {status='ok'}
    end
    if command=='moveCarried' and op.withdrawal then
        if op.phase~='take' then return {status='invalid'} end
        -- Once native TAKE succeeded, report that fact even if later eligibility
        -- changes. A confirmation never grants another transfer or mutates items.
        if not present(op.carrier,op.item) then return {status='waiting'} end
        B47ANCEDQuartermaster.Shopping.confirm(player,op)
        forget(player,op);return {status='ok',collected=true}
    end
    local operationValid,operationReason=valid(player,op)
    if not operationValid then forget(player,op);return {status='invalid',reason=operationReason} end
    if command=='moveTake' then
        if op.withdrawal then
            if op.shoppingRun and op.shoppingRun.kind=='shopping' and B47ANCEDQuartermaster.ShoppingRequirements then
                local _,data=B47ANCEDQuartermaster.Personal.identity(player)
                local ledger=B47ANCEDQuartermaster.ShoppingRequirements.ledger(player,data,op.shoppingRun.scope)
                if not ledger or not B47ANCEDQuartermaster.ShoppingRequirements.worthTaking(ledger,op.item) then return {status='invalid'} end
            end
            local position=T.descriptor(op.source)
            for _,key in ipairs({'x','y','z','ci'}) do if position[key]~=op.sourceRecord.position[key] then return {status='invalid'} end end
            if op.source.obj:getModData().B47MovementInstance~=op.sourceMarker then return {status='invalid'} end
        end
        if op.phase~='planned' or op.sourceRecord.revoked or not (op.source.ground and G.valid(op.source,player) or not op.source.ground and T.valid(op.source,player))
            or not (op.source.ground and G.valid(op.source,player) or not op.source.ground and present(op.container,op.item)) or not op.container:isRemoveItemAllowed(op.item)
            or not accepts(player,op.carrier,op.item) or not valid(player,op)
            or not (op.source.ground and G.valid(op.source,player) or not op.source.ground and T.valid(op.source,player)) then return {status='invalid'} end
        local waiting=arrival(player,op,op.source,'take')
        if waiting then return waiting end
        op.phase='take'
        Trace.emit(op.trace or op.id,'TAKE_GRANTED','ok',op.id,op.sourceMarker)
        return {status='ok'}
    elseif command=='moveCarried' then
        if op.phase~='take' and op.phase~='carried' then return {status='invalid'} end
        if not present(op.carrier,op.item) then return {status='waiting'} end
        op.phase='carried';return {status='ok'}
    elseif command=='movePut' then
        if op.withdrawal then return {status='invalid'} end
        if op.phase~='carried' then return {status='invalid',reason='notCarriedPhase'} end
        if not present(op.carrier,op.item) then return {status='invalid',reason='itemNotCarried'} end
        if not accepts(player,op.destination.container,op.item) then return {status='invalid',reason='destinationCapacityOrPermission'} end
        if not op.carrier:isRemoveItemAllowed(op.item) then return {status='invalid',reason='sourceRemoveDenied'} end
        local authorized,reason=valid(player,op)
        if not authorized then return {status='invalid',reason=reason} end
        local waiting=arrival(player,op,op.destination,'put')
        if waiting then return waiting end
        op.phase='put';Trace.emit(op.trace or op.id,'PUT_GRANTED','ok',op.id,op.marker);return {status='ok'}
    end
    return {status='invalid'}
end
if Events and Events.OnTick then
    Events.OnTick.Add(function()
        for player,op in pairs(M.operations) do
            if getTimestampMs()-op.time>=lifetime then M.operations[player]=nil end
        end
        for player,run in pairs(M.runs) do if getTimestampMs()-run.time>=lifetime then M.runs[player]=nil end end
        for player,run in pairs(M.runs) do
            if run.kind=='shopping' then
                for _,op in pairs(run.operations) do
                    if op.cancelRequested and present(op.carrier,op.item) then
                        B47ANCEDQuartermaster.Shopping.confirm(player,op);forget(player,op)
                    end
                end
                if run.cancelled then
                    local pending=false;for _ in pairs(run.operations) do pending=true end
                    if not pending then M.runs[player]=nil end
                end
            end
        end
    end)
end
M.identity=identity
M.eligible=eligible
M.fresh=fresh
return M
