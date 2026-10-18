require 'B47ANCEDQuartermaster/Movement'
local M,B,T=B47ANCEDQuartermaster.Movement,B47ANCEDQuartermaster.Bindings,B47ANCEDQuartermaster.Targets
local Trips={}
B47ANCEDQuartermaster.Trips=Trips
local Trace=require 'B47ANCEDQuartermaster/SortTrace'
local G=require 'B47ANCEDQuartermaster/GroundSources'
local Migration=require 'B47ANCEDQuartermaster/Migration'
local Route=require 'B47ANCEDQuartermaster/Route'
local Carry=require 'B47ANCEDQuartermaster/CarryBudget'
local External=require 'B47ANCEDQuartermaster/ContainerSources'
function Trips.batchSize()
 -- Saved sandbox value only. A carry is sized by free weight, not this count.
 local value=Migration.option('SortBatchSize');local n=tonumber(value) or 20
 if n~=n or n==math.huge or n==-math.huge then n=20 end
 return math.max(1,math.min(100,math.floor(n)))
end
local EXAM_CAP=250
local HAUL_CAP=400
local function placeKey(sq)
    -- Planning hint only: native building identity, never native room identity.
    -- Current target/permission/capacity checks remain independent of clusters.
    local building=sq and sq.getBuilding and sq:getBuilding() or nil
    local def=building and building:getDef()
    if def then return 'building:'..tostring(def)..':'..tostring(sq:getZ()) end
    if not sq or not sq.getX or not sq.getY then return nil end
    return 'near:'..math.floor(sq:getX()/8)..':'..math.floor(sq:getY()/8)..':'..tostring(sq:getZ())
end
local function stackKey(item)
    if item and item.getFullType then
        local full=item:getFullType()
        if type(full)=='string' and full~='' then return full end
    end
    local script=item and item.getScriptItem and item:getScriptItem() or nil
    if script and script.getFullName then
        local name=script:getFullName()
        if type(name)=='string' and name~='' then return name end
    end
    return item and item.getID and tostring(item:getID()) or '?'
end
local function clusterFor(target,descriptor)
    if not Route.enabled() then return 'dest:'..Route.key(descriptor) end
    local sq=target and target.obj and target.obj.getSquare and target.obj:getSquare() or nil
    local place=placeKey(sq)
    if place then return place end
    return 'dest:'..Route.key(descriptor)
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
    if token=='external' then
        local run=M.runs[player];local target=run and run.external
        if target and External.valid(target,player,false) then return target.container,target end
        return
    end
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
        local known,why=require('B47ANCEDQuartermaster/LedgerRequirement').check(player,player:getCurrentSquare(),args.area==true and 'area' or 'sort');if not known then return {status=why} end
        Trace.emit(args.trace,'REQUEST_RECEIVED',command)
        if run or M.operations[player] then return {status='busy'} end
        local session=B.session(player,args.session)
        if not session then return {status='invalid'} end
        if args.area==true and (args.sweep~=session.areaSweep or not session.areaSources or not session.areaSources[args.source]) then return {status='invalid'} end
        local source,target,areaConfig,areaEffective
        if args.source=='external' then
            if args.area==true then return {status='invalid'} end
            target=External.capture(player,args.sourceHint,session);source=target and target.container
        elseif args.source=='ground' then source=G.snapshot(player,args.sourceItems,args.session);target={ground=true}
        else source,target=sourceOf(player,args.session,args.source) end
        if not source then return {status='invalid'} end
        local known,why=require('B47ANCEDQuartermaster/LedgerRequirement').operation(player,{source=target,area=args.area==true});if not known then return {status=why} end
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
            ids=ids,refs=refs,considered={},operations={},skipped=0,time=getTimestampMs(),area=args.area==true,sweep=args.sweep,sourceConfig=areaConfig,sourceEffective=areaEffective,
            external=target and target.external and target or nil}
        if not require('B47ANCEDQuartermaster/SortLedger').started(player,run) then return {status='SortLedgerRequired'} end
        M.runs[player]=run
        Trace.emit(args.trace,'SOURCE_ENUMERATION','complete',nil,run.id,measured,#ids)
        return {status='ok',run=run.id,sourceCount=#ids}
    end
    if not run or args.run~=run.id then return {status='invalid'} end
    if command=='tripCancel' then M.runs[player]=nil;return {status='ok'} end
    if command~='tripNext' then return {status='busy'} end
    local known,why=require('B47ANCEDQuartermaster/LedgerRequirement').check(player,player:getCurrentSquare(),run.area and 'area' or 'sort');if not known then return {status=why} end
    run.routeFocus=nil
    local outstanding=0
    for _ in pairs(run.operations) do outstanding=outstanding+1 end
    local source,target=sourceOf(player,run.session,run.source)
    if source~=run.container or (run.target and (not target or target.obj~=run.target.obj)) then return {status='invalid'} end
    local covered,why=require('B47ANCEDQuartermaster/LedgerRequirement').operation(player,{source=target,area=run.area});if not covered then return {status=why} end
    if target and not target.ground and (not B47ANCEDQuartermaster.RoomAccess.can(player,target,'inspect') or not B47ANCEDQuartermaster.RoomAccess.can(player,target,'withdraw')) then return {status='RoomAccessChanged'} end
    local sourceConfig=run.area and target and B47ANCEDQuartermaster.Store.load(target,player)
    local sourceEffective=sourceConfig and B47ANCEDQuartermaster.Presets.resolve(sourceConfig)
    if run.area and target and (not sourceEffective or not B47ANCEDQuartermaster.Schema.equal(sourceConfig,run.sourceConfig)
        or not B47ANCEDQuartermaster.Schema.equal(sourceEffective,run.sourceEffective)) then return {status='invalid',reason='sourceConfigurationChanged'} end
    local candidates=carriers(player)
    local budget=Carry.free(player)
    -- One closed carry is prepared before any offer is returned. Chunk the scan
    -- so a large crate cannot hitch the server, and do not start the next carry
    -- while this one still has grants open.
    local library=B47ANCEDQuartermaster.Presets.snapshot()
    local planning=B47ANCEDQuartermaster.Planner.prepare(player,run.session,library and library.definitions or {},run.trace)
    if not planning then return {status='invalid'} end
    local session=B.session(player,run.session)
    if run.area and (not session or session.areaSweep~=run.sweep) then return {status='invalid'} end
    if outstanding>0 then return {status='waiting',skipped=run.skipped,skipReasons=run.skipReasons,planningTargets=#planning.candidates,reason='haulOpen'} end
    run.pool=run.pool or {}
    local function held()
        local reserved={}
        for _,entry in pairs(run.pool) do
            if entry.container and entry.weight then reserved[entry.container]=(reserved[entry.container] or 0)+entry.weight end
        end
        return reserved
    end
    local function pendingScan()
        for index=1,#run.ids do
            local id=run.ids[index]
            if not run.considered[id] and not run.pool[id] then return true end
        end
        return false
    end
    local function classify(item,id,reserved)
        local weight=Carry.weight(item)
        if target then
            local fits=false
            for _,c in ipairs(candidates) do
                if weight*c.factor<=budget and c.container:isItemAllowed(item) and c.container:hasRoomFor(player,item)
                    and weight<=room(player,c.container) then fits=true;break end
            end
            if not fits then skip(run,id,'carryCapacity');return end
        end
        local knowledgeBlocked=false
        local choice,reason=B47ANCEDQuartermaster.Planner.choose(player,run.session,item,library and library.definitions or {},function(t,it,candidate)
            if not candidate or not candidate.rulesReady or not t or not t.container then return false end
            if not require('B47ANCEDQuartermaster/LedgerRequirement').candidate(player,t.obj:getSquare(),run.area and 'area' or 'sort') then knowledgeBlocked=true;return false end
            if not t.container:isItemAllowed(it) or not t.container:hasRoomFor(player,it) then return false end
            return Carry.weight(it)<=(room(player,t.container)-(reserved[t.container] or 0))
        end,run.trace,planning)
        if not choice or not choice.target or not choice.target.container then skip(run,id,knowledgeBlocked and 'LedgerRequired' or reason or 'planningRejected');return end
        local descriptor=T.descriptor(choice.target)
        local dx,dy=(descriptor.x or 0)-player:getX(),(descriptor.y or 0)-player:getY()
        run.pool[id]={id=id,weight=weight,stack=stackKey(item),cluster=clusterFor(choice.target,descriptor),place=placeKey(choice.target.obj and choice.target.obj:getSquare() or nil),dist=dx*dx+dy*dy,container=choice.target.container}
        reserved[choice.target.container]=(reserved[choice.target.container] or 0)+weight
    end
    local reserved=held()
    local examined=0
    local index=run.scan or 1
    local guard=0
    while #run.ids>0 and guard<#run.ids and examined<EXAM_CAP do
        if index<1 or index>#run.ids then index=1 end
        local id=run.ids[index]
        index=index+1
        guard=guard+1
        if not run.considered[id] and not run.pool[id] then
            examined=examined+1
            local item=source:getItemWithID(id)
            if run.area and (session.areaSeen[id] or (sourceConfig and item and B47ANCEDQuartermaster.Catalog.matchesItem(item,sourceConfig,library and library.definitions or {}))) then skip(run,id,'alreadySorted')
            elseif item~=run.refs[id] or not M.eligible(player,item) then skip(run,id,item~=run.refs[id] and 'sourceChanged' or 'itemProtected')
            else classify(item,id,reserved) end
        end
    end
    run.scan=index
    local playerPlace=Route.enabled() and placeKey(player:getCurrentSquare()) or nil
    local function totals()
        local clusters={}
        for _,entry in pairs(run.pool) do
            local row=clusters[entry.cluster]
            if not row then row={key=entry.cluster,place=entry.place,weight=0,dist=entry.dist or 0,count=0};clusters[entry.cluster]=row end
            row.weight=row.weight+entry.weight
            row.count=row.count+1
            if entry.dist and entry.dist<row.dist then row.dist=entry.dist end
        end
        return clusters
    end
    local function roomFills()
        local factor=1
        if target then for _,c in ipairs(candidates) do factor=math.min(factor,c.factor) end end
        for _,row in pairs(totals()) do
            if row.count>=HAUL_CAP or (target and budget>0 and row.weight*factor>=budget) then return true end
        end
        return false
    end
    if pendingScan() and not roomFills() then
        Trace.emit(run.trace,'TRIP_PLANNING','loadPending',nil,run.id,measured,examined)
        return {status='waiting',skipped=run.skipped,skipReasons=run.skipReasons,planningTargets=#planning.candidates,reason='loadPending'}
    end
    local function carrierFor(item,weight,carryBudget,carrierReserved)
        if not target then
            local bag=type(run.source)=='string' and run.source:match('^bag:(%d+)$')
            return {id=tonumber(bag) or 0,container=source,factor=0}
        end
        for _,c in ipairs(candidates) do
            if weight*c.factor<=carryBudget and c.container:isItemAllowed(item) and c.container:hasRoomFor(player,item)
                and weight<=(room(player,c.container)-(carrierReserved[c.container] or 0)) then return c end
        end
    end
    local function takeCluster(cluster)
        local list={}
        for _,entry in pairs(run.pool) do if entry.cluster==cluster.key then list[#list+1]=entry end end
        table.sort(list,function(a,b)
            if a.dist~=b.dist then return a.dist<b.dist end
            if a.stack~=b.stack then return tostring(a.stack)<tostring(b.stack) end
            return a.id<b.id
        end)
        local loadReserved=held()
        local carryReserved={}
        local carryBudget=budget
        local taken={}
        for _,entry in ipairs(list) do
            if #taken>=HAUL_CAP then break end
            local item=source:getItemWithID(entry.id)
            if item~=run.refs[entry.id] or not M.eligible(player,item) then
                skip(run,entry.id,item~=run.refs[entry.id] and 'sourceChanged' or 'itemProtected')
                run.pool[entry.id]=nil
                if entry.container then loadReserved[entry.container]=math.max(0,(loadReserved[entry.container] or 0)-entry.weight) end
            else
                local weight=Carry.weight(item)
                local carrier=carrierFor(item,weight,carryBudget,carryReserved)
                if carrier then
                    if entry.container then loadReserved[entry.container]=math.max(0,(loadReserved[entry.container] or 0)-weight) end
                    local function accepts(limit)
                        return function(t,it)
                            if not t or not t.container then return false end
                            if limit and clusterFor(t,T.descriptor(t))~=cluster.key then return false end
                            return Carry.weight(it)<=(room(player,t.container)-(loadReserved[t.container] or 0))
                        end
                    end
                    local args={session=run.session,source=run.source,itemID=entry.id}
                    local context={carrierID=carrier.id,ground=source.groundRecords and source.groundRecords[entry.id],external=run.external,trace=run.trace,
                        area=run.area,sourceConfig=sourceConfig,sourceEffective=sourceEffective,planning=planning,library=library,
                        prepareAway=true,accepts=accepts(true)}
                    local offer,op=M.planOne(player,args,context)
                    if not op then
                        context.accepts=accepts(false)
                        offer,op=M.planOne(player,args,context)
                        if op and offer and offer.destination and op.destination then
                            entry.hops=(entry.hops or 0)+1
                            if entry.hops>=3 then
                                skip(run,entry.id,'destinationRejected')
                                run.pool[entry.id]=nil
                            else
                                entry.cluster=clusterFor(op.destination,offer.destination)
                                entry.place=placeKey(op.destination.obj and op.destination.obj:getSquare() or nil)
                                entry.container=op.destination.container
                                entry.dist=((offer.destination.x or 0)-player:getX())^2+((offer.destination.y or 0)-player:getY())^2
                                entry.weight=weight
                                if entry.container then loadReserved[entry.container]=(loadReserved[entry.container] or 0)+weight end
                            end
                            run.operations[op.id]=nil
                        else
                            skip(run,entry.id,offer and offer.reason or 'planningRejected')
                            run.pool[entry.id]=nil
                        end
                    else
                        offer.stack=entry.stack
                        offer.trace=run.trace
                        run.operations[op.id]=op
                        run.pool[entry.id]=nil
                        run.considered[entry.id]=true
                        if run.area and session then session.areaSeen[entry.id]=true end
                        if op.destination and op.destination.container then loadReserved[op.destination.container]=(loadReserved[op.destination.container] or 0)+weight end
                        carryReserved[carrier.container]=(carryReserved[carrier.container] or 0)+weight
                        if target then carryBudget=carryBudget-weight*carrier.factor end
                        taken[#taken+1]=offer
                    end
                end
            end
        end
        if #taken==0 then
            for _,entry in ipairs(list) do
                if run.pool[entry.id] then
                    local item=source:getItemWithID(entry.id)
                    local weight=item and Carry.weight(item) or entry.weight
                    if not item or not carrierFor(item,weight,budget,{}) then
                        skip(run,entry.id,'carryCapacity')
                        run.pool[entry.id]=nil
                    end
                end
            end
        end
        return taken
    end
    local blocked={}
    local offers
    for _=1,8 do
        local best
        for _,row in pairs(totals()) do
            if row.count>0 and not blocked[row.key] then
                if not best then best=row
                else
                    local hereA=playerPlace~=nil and row.place==playerPlace
                    local hereB=playerPlace~=nil and best.place==playerPlace
                    local fitA=math.min(row.weight,math.max(budget,0))
                    local fitB=math.min(best.weight,math.max(budget,0))
                    local better=false
                    if hereA~=hereB then better=hereA
                    elseif fitA~=fitB then better=fitA>fitB
                    elseif row.dist~=best.dist then better=row.dist<best.dist
                    else better=tostring(row.key)<tostring(best.key) end
                    if better then best=row end
                end
            end
        end
        if not best then break end
        offers=takeCluster(best)
        if offers and #offers>0 then break end
        blocked[best.key]=true
        offers=nil
    end
    if not offers or #offers==0 then
        local remaining=false
        for _,id in ipairs(run.ids) do if not run.considered[id] then remaining=true;break end end
        if remaining or hasOperations(run) then return {status='waiting',skipped=run.skipped,skipReasons=run.skipReasons,planningTargets=#planning.candidates,reason='loadPending'} end
        Trace.emit(run.trace,'TRIP_PLANNING','zero',nil,run.id,measured,#run.ids)
        Trace.emit(run.trace,'PLAN_CREATED','zero')
        require('B47ANCEDQuartermaster/SortLedger').finished(player,run)
        M.runs[player]=nil
        return {status='done',skipped=run.skipped,skipReasons=run.skipReasons,planningTargets=#planning.candidates}
    end
    table.sort(offers,function(a,b)
        local x,y=a.destination or {},b.destination or {}
        local dx=((x.x or 0)-player:getX())^2+((x.y or 0)-player:getY())^2
        local dy=((y.x or 0)-player:getX())^2+((y.y or 0)-player:getY())^2
        if dx~=dy then return dx<dy end
        if x.instance~=y.instance then return tostring(x.instance)<tostring(y.instance) end
        if x.ci~=y.ci then return (x.ci or 0)<(y.ci or 0) end
        if a.stack~=b.stack then return tostring(a.stack)<tostring(b.stack) end
        return (a.itemID or 0)<(b.itemID or 0)
    end)
    local remaining=false
    for _,id in ipairs(run.ids) do if not run.considered[id] then remaining=true;break end end
    Trace.emit(run.trace,'PLAN_CREATED',#offers)
    Trace.emit(run.trace,'TRIP_PLANNING','complete',nil,run.id,measured,#offers)
    return {status='ok',offers=offers,remaining=remaining,skipped=run.skipped,skipReasons=run.skipReasons,planningTargets=#planning.candidates}
end
Trips.carriers=carriers
return Trips
