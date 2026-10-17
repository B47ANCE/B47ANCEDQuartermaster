require 'B47ANCEDQuartermaster/Movement'
local M,B,T=B47ANCEDQuartermaster.Movement,B47ANCEDQuartermaster.Bindings,B47ANCEDQuartermaster.Targets
local Trips={}
B47ANCEDQuartermaster.Trips=Trips
local Trace=require 'B47ANCEDQuartermaster/SortTrace'
local G=require 'B47ANCEDQuartermaster/GroundSources'
local Migration=require 'B47ANCEDQuartermaster/Migration'
local Route=require 'B47ANCEDQuartermaster/Route'
function Trips.batchSize()
 local value=Migration.option('SortBatchSize');local n=tonumber(value) or 20
 if n~=n or n==math.huge or n==-math.huge then n=20 end
 return math.max(1,math.min(100,math.floor(n)))
end
local function hasOperations(run)
    for _ in pairs(run.operations) do return true end
    return false
end
local function skip(run,id,reason)
    if not run.considered[id] then
        run.considered[id]=true;run.skipped=run.skipped+1
        run.skipReasons=run.skipReasons or {};reason=reason or 'planningRejected'
        run.skipReasons[reason]=(run.skipReasons[reason] or 0)+1
    end
end
local function sourceOf(player,session,token)
    if token=='ground' then local run=M.runs[player];return run and run.container,{ground=true} end
    if token=='inventory' then return player:getInventory() end
    local bag=type(token)=='string' and token:match('^bag:(%d+)$')
    if bag then return M.carrier(player,tonumber(bag)) end
    local record=B.target(player,session,token)
    if record then return record.target.container,record.target end
end
local function room(player,c)
    return math.max(0,c:getEffectiveCapacity(player)-c:getCapacityWeight())
end
local function carriers(player)
    local list={{id=0,container=player:getInventory(),factor=1}}
    local seen={}
    local function add(item)
        if item and not seen[item] and instanceof(item,'InventoryContainer') and item:isEquipped() then
            seen[item]=true
            list[#list+1]={id=item:getID(),container=item:getInventory(),factor=math.max(0,1-item:getWeightReduction()/100)}
        end
    end
    local worn=player:getWornItems()
    for i=0,worn:size()-1 do add(worn:get(i):getItem()) end
    add(player:getPrimaryHandItem());add(player:getSecondaryHandItem())
    table.sort(list,function(a,b) if a.factor==b.factor then return a.id<b.id end return a.factor<b.factor end)
    return list
end
function Trips.handle(player,command,args)
    local measured=Trace.begin()
    if isClient() or not player or type(args)~='table' then return {status='invalid'} end
    if command=='tripDiscover' then
        Trace.emit(args.trace,'REQUEST_RECEIVED',command)
        local result,err=B.discover(player,args)
        Trace.emit(args.trace,result and 'SESSION_VALIDATED' or 'SESSION_REJECTED',result and 'ok' or err)
        if not result then return {status=err} end
        for _,meta in ipairs(result.targets) do
            local record=B.target(player,result.session,meta.token)
            if not record then return {status='invalid'} end
            meta.identity=M.identity(record.target)
        end
        return result
    end
    local run=M.runs[player]
    if run and run.kind=='shopping' then return {status='busy'} end
    if command=='tripBegin' then
        Trace.emit(args.trace,'REQUEST_RECEIVED',command)
        if run or M.operations[player] then return {status='busy'} end
        local session=B.session(player,args.session)
        if not session then return {status='invalid'} end
        if args.area==true and (args.sweep~=session.areaSweep or not session.areaSources or not session.areaSources[args.source]) then return {status='invalid'} end
        local source,target,areaConfig,areaEffective
        if args.source=='ground' then source=G.snapshot(player,args.sourceItems,args.session);target={ground=true}
        else source,target=sourceOf(player,args.session,args.source) end
        if not source then return {status='invalid'} end
        if target and not target.ground and (not B47ANCEDQuartermaster.RoomAccess.can(player,target,'inspect')
            or not B47ANCEDQuartermaster.RoomAccess.can(player,target,'withdraw')) then return {status='RoomAccessDenied'} end
        if args.area==true and target then
            if target.ground or source:getType()=='floor' or source:getContainingItem() then return {status='invalid'} end
            if not B47ANCEDQuartermaster.RoomAccess.can(player,target,'withdraw') or not B47ANCEDQuartermaster.RoomAccess.can(player,target,'inspect') then return {status='RoomAccessDenied'} end
            local config=B47ANCEDQuartermaster.Store.load(target,player)
            local effective=config and B47ANCEDQuartermaster.Presets.resolve(config);local configured=false
            if effective then for _,field in ipairs({'cats','items'}) do for _ in pairs(effective[field]) do configured=true;break end end end
            if not configured then return {status='invalid'} end
            areaConfig=config;areaEffective=effective
        end
        Trace.emit(args.trace,'SOURCE_RESOLVED',args.source)
        local contents=source:getItems()
        if contents:size()>4096 then return {status='tooLarge'} end -- protocol bound, never truncate
        local ids,refs={},{}
        for i=0,contents:size()-1 do
            local item=contents:get(i)
            if M.eligible(player,item) then ids[#ids+1]=item:getID();refs[item:getID()]=item end
        end
        run={id=M.fresh(),trace=args.trace,session=args.session,source=args.source,container=source,target=target,
            ids=ids,refs=refs,considered={},operations={},skipped=0,time=getTimestampMs(),area=args.area==true,sweep=args.sweep,sourceConfig=areaConfig,sourceEffective=areaEffective}
        M.runs[player]=run
        Trace.emit(args.trace,'SOURCE_ENUMERATION','complete',nil,run.id,measured,#ids)
        return {status='ok',run=run.id,sourceCount=#ids}
    end
    if not run or args.run~=run.id then return {status='invalid'} end
    if command=='tripCancel' then M.runs[player]=nil;return {status='ok'} end
    if command~='tripNext' then return {status='busy'} end
    local size=Trips.batchSize();local outstanding=0
    if not Route.enabled() then run.routeFocus=nil end
    for _ in pairs(run.operations) do outstanding=outstanding+1 end
    if outstanding>=size*2 then return {status='waiting'} end
    local source,target=sourceOf(player,run.session,run.source)
    if source~=run.container or (run.target and (not target or target.obj~=run.target.obj)) then return {status='invalid'} end
    if target and not target.ground and (not B47ANCEDQuartermaster.RoomAccess.can(player,target,'inspect') or not B47ANCEDQuartermaster.RoomAccess.can(player,target,'withdraw')) then return {status='RoomAccessChanged'} end
    local sourceConfig=run.area and target and B47ANCEDQuartermaster.Store.load(target,player)
    local sourceEffective=sourceConfig and B47ANCEDQuartermaster.Presets.resolve(sourceConfig)
    if run.area and target and (not sourceEffective or not B47ANCEDQuartermaster.Schema.equal(sourceConfig,run.sourceConfig)
        or not B47ANCEDQuartermaster.Schema.equal(sourceEffective,run.sourceEffective)) then return {status='invalid',reason='sourceConfigurationChanged'} end
    local candidates=carriers(player)
    local carrierReserved,destReserved={},{}
    local budget=math.max(0,player:getMaxWeight()-player:getInventory():getCapacityWeight())
    local offers={}
    -- Reuse immutable rule work within this request, never live permissions or
    -- contents across requests. Rebuild after every native transfer/prefetch.
    local library=B47ANCEDQuartermaster.Presets.snapshot()
    local planning=B47ANCEDQuartermaster.Planner.prepare(player,run.session,library and library.definitions or {},run.trace)
    if not planning then return {status='invalid'} end
    local session=B.session(player,run.session)
    if run.area and (not session or session.areaSweep~=run.sweep) then return {status='invalid'} end
    -- Reserve only items not yet observed at their promised destination/carrier.
    -- Actual native contents already contribute to getCapacityWeight().
    for _,op in pairs(run.operations) do
        local weight=math.max(0,op.item:getActualWeight())
        if op.item:getContainer()~=op.destination.container then destReserved[op.destination.container]=(destReserved[op.destination.container] or 0)+weight end
        if op.source and (op.source.ground and G.valid(op.source,player) or op.item:getContainer()==op.container) then
            carrierReserved[op.carrier]=(carrierReserved[op.carrier] or 0)+weight
            for _,c in ipairs(candidates) do if c.container==op.carrier then budget=budget-weight*c.factor;break end end
        end
    end
    local examined=0;run.cursor=run.cursor or 1
    for offset=0,#run.ids-1 do
        if examined>=100 or #offers>=size or outstanding+#offers>=size*2 then break end
        local index=(run.cursor+offset-1)%#run.ids+1
        local id=run.ids[index];examined=examined+1
        run.nextCursor=index%#run.ids+1
        if not run.considered[id] then
            local item=source:getItemWithID(id)
            if run.area and (session.areaSeen[id] or sourceConfig and item and B47ANCEDQuartermaster.Catalog.matchesItem(item,sourceConfig,library and library.definitions or {})) then skip(run,id,'alreadySorted')
            elseif item~=run.refs[id] or not M.eligible(player,item) then skip(run,id,item~=run.refs[id] and 'sourceChanged' or 'itemProtected')
            else
                local weight=math.max(0,item:getActualWeight())
                local chosen
                if not target then
                    chosen={id=tonumber(run.source:match('^bag:(%d+)$')) or 0,container=source,factor=0}
                else
                    for _,c in ipairs(candidates) do
                        if weight*c.factor<=budget and c.container:isItemAllowed(item) and c.container:hasRoomFor(player,item)
                            and weight<=(room(player,c.container)-(carrierReserved[c.container] or 0)) then chosen=c;break end
                    end
                end
                if chosen then
                    local offer,op=M.planOne(player,{session=run.session,source=run.source,itemID=id},
                        {carrierID=chosen.id,ground=source.groundRecords and source.groundRecords[id],trace=run.trace,
                            area=run.area,sourceConfig=sourceConfig,sourceEffective=sourceEffective,
                            planning=planning,library=library,prepareAway=true,accepts=function(t,it)
                            return it:getActualWeight()<=room(player,t.container)-(destReserved[t.container] or 0)
                        end})
                    if op and (not run.routeFocus or Route.key(offer.destination)==run.routeFocus) then
                        offer.trace=run.trace
                        run.operations[op.id]=op;offers[#offers+1]=offer;run.considered[id]=true
                        if run.area then session.areaSeen[id]=true end
                        carrierReserved[chosen.container]=(carrierReserved[chosen.container] or 0)+weight
                        destReserved[op.destination.container]=(destReserved[op.destination.container] or 0)+weight
                        if target then budget=budget-weight*chosen.factor end
                    elseif not op and outstanding==0 and #offers==0 then skip(run,id,offer.reason or 'planningRejected') end
                elseif outstanding==0 and #offers==0 then skip(run,id,'carryCapacity') end
            end
        end
    end
    run.cursor=run.nextCursor or run.cursor
    if run.routeFocus then
        if #offers>0 then run.focusExamined=0 else run.focusExamined=(run.focusExamined or 0)+examined end
        if outstanding==0 and #offers==0 and run.focusExamined>=#run.ids then run.routeFocus=nil;run.focusExamined=0 end
    end
    if #offers==0 then
        local remaining=false;for _,id in ipairs(run.ids) do if not run.considered[id] then remaining=true;break end end
        if remaining or hasOperations(run) then return {status='waiting',skipped=run.skipped,skipReasons=run.skipReasons,planningTargets=#planning.candidates} end
        Trace.emit(run.trace,'TRIP_PLANNING','zero',nil,run.id,measured,#run.ids)
        Trace.emit(run.trace,'PLAN_CREATED','zero')
        M.runs[player]=nil;return {status='done',skipped=run.skipped,skipReasons=run.skipReasons,planningTargets=#planning.candidates}
    end
    Trace.emit(run.trace,'PLAN_CREATED',#offers)
    -- Group deposits at each chosen destination. This is traversal ordering only;
    -- Planner choices are immutable and are never recalculated by the client.
    table.sort(offers,function(a,b)
        local x,y=a.destination,b.destination
        if x.instance==y.instance then return x.ci<y.ci or (x.ci==y.ci and a.itemID<b.itemID) end
        local dx=(x.x-player:getX())^2+(x.y-player:getY())^2
        local dy=(y.x-player:getX())^2+(y.y-player:getY())^2
        if dx==dy then return x.instance<y.instance end
        return dx<dy
    end)
    if Route.enabled() then
        local focus=run.routeFocus or Route.order(offers,player,run.trace)
        local selected={}
        for _,offer in ipairs(offers) do
            if Route.key(offer.destination)==focus then selected[#selected+1]=offer
            else run.operations[offer.operation]=nil;run.considered[offer.itemID]=nil end
        end
        run.routeFocus=focus;run.focusExamined=0;offers=selected
    end
    local remaining=false
    for _,id in ipairs(run.ids) do if not run.considered[id] then remaining=true;break end end
    Trace.emit(run.trace,'TRIP_PLANNING','complete',nil,run.id,measured,#offers)
    return {status='ok',offers=offers,remaining=remaining,skipped=run.skipped,skipReasons=run.skipReasons,planningTargets=#planning.candidates}
end
Trips.carriers=carriers
return Trips
