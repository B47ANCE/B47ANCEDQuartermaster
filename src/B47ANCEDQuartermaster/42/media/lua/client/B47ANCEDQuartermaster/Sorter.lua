require 'B47ANCEDQuartermaster/Executor'
local E,A,T=B47ANCEDQuartermaster.Executor,B47ANCEDQuartermaster.Authority,B47ANCEDQuartermaster.Targets
local Trace=require 'B47ANCEDQuartermaster/SortTrace'
local S={active={}}
local Progress=require 'B47ANCEDQuartermaster/Progress'
local External=require 'B47ANCEDQuartermaster/ContainerSources'
local traceSequence=0
B47ANCEDQuartermaster.Sorter=S
function S.progress(run)
    local total=tonumber(run.sourceCount)
    local processed=run.completed+run.failed+(run.planningSkipped or 0)
    local batch=E.batches and E.batches[run.playerNum]
    if batch and batch.trace==run.trace then processed=processed+(batch.completed or 0)+(batch.failed or 0) end
    return {known=total~=nil,total=total or 0,completed=math.min(total or 0,processed),label='UI_B47_ProgressSort'}
end
local function empty(player) return #ISTimedActionQueue.getTimedActionQueue(player).queue==0 end
local function diagnostic(value) return tostring(value or 'unknown'):gsub('[^%w_:%.-]','?'):sub(1,80) end
local function planningResult(run,result)
    run.serverVersion=result.serverVersion or run.serverVersion
    run.sourceCount=result.sourceCount or run.sourceCount
    run.planningTargets=result.planningTargets or run.planningTargets
    run.planningSkipped=result.skipped or run.planningSkipped
    if type(result.skipReasons)=='table' then run.skipReasons=result.skipReasons end
end
local function endRun(run,status)
    if run.closed then return end
    local batch=E.batches and E.batches[run.playerNum]
    if batch and batch.trace==run.trace then
        run.completed=run.completed+(batch.completed or 0);run.failed=run.failed+(batch.failed or 0)
    end
    Trace.emit(run.trace,'OPERATION_COMPLETED',status)
    run.closed=true;S.active[run.playerNum]=nil
    Progress.clear(run.playerNum,run)
    E.cancel(run.playerNum)
    local reasons={}
    for _,key in ipairs({'sourceChanged','itemProtected','noMatchingRule','destinationRejected','carryCapacity','planningRejected','alreadySorted'}) do
        local n=run.skipReasons and run.skipReasons[key]
        if type(n)=='number' and n>0 then reasons[#reasons+1]=key..':'..math.min(4096,math.floor(n)) end
    end
    local rejection=run.rejection or {}
    print('[B47ANCEDQuartermaster] sort summary status='..diagnostic(status)..' completed='..run.completed..' transferFailed='..run.failed
        ..' planningSkipped='..(run.planningSkipped or 0)..' reasons='..table.concat(reasons,',')..' server='..diagnostic(run.serverVersion)
        ..' sourceCount='..diagnostic(run.sourceCount)..' planningTargets='..diagnostic(run.planningTargets)
        ..' firstFailure='..diagnostic(rejection.phase)..':'..diagnostic(rejection.status)..':'..diagnostic(rejection.reason))
    if run.id then A.request(run.playerNum,'tripCancel',{run=run.id},function() end) end
    if run.callback then run.callback(status,run.completed,run.failed+(run.planningSkipped or 0),run.skipReasons) end
end
function S.cancel(playerNum)
    local run=S.active[playerNum]
    if run then
        endRun(run,'cancelled')
        local action=ISTimedActionQueue.getTimedActionQueue(run.player).queue[1]
        if action and action.sortRun==run then action:forceStop() end
    end
    if B47ANCEDQuartermaster.LedgerUI then B47ANCEDQuartermaster.LedgerUI.cancelSort(playerNum) end
end
local function request(run,command,args,done)
    run.pending=true
    local started=Trace.begin()
    args.trace=run.trace
    Trace.emit(run.trace,'REQUEST_SENT',command)
    A.request(run.playerNum,command,args,function(result)
        run.pending=false
        planningResult(run,result)
        Trace.emit(run.trace,'RESPONSE_RECEIVED',command..':'..tostring(result.status),nil,nil,started)
        if run.closed then
            if result.run then A.request(run.playerNum,'tripCancel',{run=result.run},function() end) end
        else
            local processing=Trace.begin()
            done(result)
            Trace.emit(run.trace,'CLIENT_RESPONSE_PROCESSING',command,nil,nil,processing)
        end
    end)
end
function S.start(playerNum,source,callback,options)
    local clicked=Trace.begin()
    if not require('B47ANCEDQuartermaster/Compatibility').allowed() then return false,'IncompatibleMod' end
    local player=getSpecificPlayer(playerNum)
    if B47ANCEDQuartermaster.Collector and B47ANCEDQuartermaster.Collector.active[playerNum] then return false,'busy' end
    if B47ANCEDQuartermaster.RoomSort and B47ANCEDQuartermaster.RoomSort.active[playerNum] and not (options and options.area) then return false,'busy' end
    if not player or not source or S.active[playerNum] or E.active[playerNum] or E.batches[playerNum] or not empty(player) then return false,'busy' end
    if not (options and (options.area or options.ledgerPrepared)) and require('B47ANCEDQuartermaster/SortLedger').enabled() then
        local V=require 'B47ANCEDQuartermaster/LedgerUI'
        local prepared={ledgerPrepared=true};for k,v in pairs(options or {}) do prepared[k]=v end
        return V.prepareSort(playerNum,function()
            return S.start(playerNum,source,function(status,completed,failed,reasons)
                V.sortFinished(playerNum,status,function(final,ledgerOutcome) if callback then callback(final,completed,failed,reasons,ledgerOutcome) end end)
            end,prepared)
        end,function(status) if callback then callback(status,0,0,{}) end end)
    end
    local token,target,sourceItems,sourceHint
    if not (options and options.area) then sourceHint=External.hint(source,player) end
    if sourceHint then token='external'
    elseif (source:getType()=='floor' or (not source:getParent() and not source:getContainingItem() and source~=player:getInventory())) then sourceItems=B47ANCEDQuartermaster.GroundSources.hints(source,player);if not sourceItems then return false,'invalid' end;token='ground' end
    if token=='ground' or token=='external' then
    elseif source==player:getInventory() then token='inventory'
    elseif source:getContainingItem() then
        local bag=source:getContainingItem()
        if B47ANCEDQuartermaster.Movement.carrier(player,bag:getID())~=source then return false,'invalid' end
        token='bag:'..bag:getID()
    else
        local obj=source:getParent()
        if obj and obj.getContainerIndex then target=T.make(obj,obj:getContainerIndex(source),player) end
        if not target then return false,'invalid' end
    end
    if options and options.area and token=='ground' then return false,'invalid' end
    local square=player:getCurrentSquare()
    traceSequence=traceSequence+1
    local participant=player.getOnlineID and player:getOnlineID() or playerNum
    local run={player=player,playerNum=playerNum,source=source,sourceTarget=target,sourceToken=token,sourceItems=sourceItems,sourceHint=sourceHint,
        trace=tostring(participant)..':'..tostring(getTimestampMs())..':'..traceSequence,
        startSquare=player:getCurrentSquare(),callback=callback,completed=0,failed=0,time=getTimestampMs(),phase='discover'}
    S.active[playerNum]=run
    run.pipeline=E.batchSupported();run.buffer={}
    run.area=options and options.area;run.sweep=options and options.sweep
    if not run.area then Progress.start(playerNum,run,S.progress,function(r) return S.active[playerNum]==r end) end
    Trace.emit(run.trace,'OPERATION_CREATED',token or 'container')
    Trace.observe(run.trace,player)
    if player.setHaloNote then player:setHaloNote(getText('UI_B47_SortPreparing')) end
    Trace.emit(run.trace,'CLIENT_PREPARATION','acknowledged',nil,nil,clicked)
    if B47ANCEDQuartermaster.SortTraceEnabled==true then
        local state=B47ANCEDQuartermaster.Catalog.diagnostics()
        Trace.emit(run.trace,'STATIC_CATALOG',state.preparing and 'PREPARING' or state.prepared and 'READY' or 'UNINITIALIZED',nil,nil,nil,state.classified,state.prepared and 'hit' or 'miss')
    end
    if options and options.discovery then
        run.discovery=options.discovery;run.phase='bind';run.traceBindAt=Trace.begin();run.scopeRoom=options.area or options.discovery.view and options.discovery.view.kind=='customRoom';return true
    end
    request(run,'tripDiscover',{scope={x=square:getX(),y=square:getY(),z=square:getZ()}},function(r)
        if r.status~='ok' then endRun(run,r.status);return end
        run.discovery=r;run.phase='bind';run.traceBindAt=Trace.begin()
    end)
    return true
end
local function returnWalk(run,square)
    local walk=ISWalkToTimedAction:new(run.player,square)
    walk.sortRun=run
    function walk:stop() endRun(run,'cancelled');ISWalkToTimedAction.stop(self) end
    function walk:forceCancel() endRun(run,'cancelled') end
    return walk
end
local function itemFinished(run,status)
    if run.closed then return end
    if status=='cancelled' or status=='uncertain' then endRun(run,status);return end
    if status=='ok' then run.completed=run.completed+1 else run.failed=run.failed+1 end
    run.busy=false
end
local function sameSourceOffer(a,b,player)
    if not a or not b or a.carrierID~=b.carrierID then return false end
    if (a.source and a.source.ground) or (b.source and b.source.ground) then
        local p,q=a.source,b.source
        if not p or not q or not p.ground or not q.ground or p.x~=q.x or p.y~=q.y or p.z~=q.z then return false end
        local first,second=E.resolve(p,player),E.resolve(q,player)
        return first and second and first.container==second.container
    end
    local p,q=a.source,b.source
    if not p and not q then return true end
    return p and q and p.instance==q.instance and p.ci==q.ci
end
local function samePutOffer(a,b)
    local x,y=a.destination,b.destination
    return x and y and x.instance==y.instance and x.ci==y.ci and a.carrierID==b.carrierID and not a.revert and not b.revert
end
local function applyReport(run,group,report)
    report=report or {}
    for _,offer in ipairs(group) do
        local id=offer.operation
        if report.kept and report.kept[id] then offer.taken=true
        elseif report.done and report.done[id] then offer.put=true
        elseif report.spill and report.spill[id] then offer.taken=true;offer.destination=report.spill[id];offer.put=nil;offer.revert=nil
        elseif report.revert and report.revert[id] then offer.taken=true;offer.revert=true;offer.put=nil
        elseif report.failed and report.failed[id] then offer.drop=true end
    end
    if run.haul then
        local live={}
        for _,offer in ipairs(run.haul) do if not offer.drop then live[#live+1]=offer end end
        run.haul=live
    end
end
local function onHaulBatch(run,group,status,completed,failed,rejection,report)
    run.busy=false
    if rejection then run.rejection=run.rejection or rejection;run.serverVersion=rejection.serverVersion or run.serverVersion end
    if run.closed then return end
    run.completed=run.completed+(completed or 0)
    run.failed=run.failed+(failed or 0)
    if status=='cancelled' or status=='uncertain' then endRun(run,status);return end
    applyReport(run,group,report)
    local progressed=false
    for _,field in ipairs({'kept','done','spill','revert','failed'}) do
        for _ in pairs(report and report[field] or {}) do progressed=true;break end
    end
    local failures=0
    for _ in pairs(report and report.failed or {}) do failures=failures+1 end
    if failures==#group or status=='invalid' and not progressed then endRun(run,'invalid');return end
end
local function takeGroup(run)
    local group={}
    for _,offer in ipairs(run.haul or {}) do
        if not offer.taken and not offer.carried and not offer.revert and not offer.drop then
            if #group==0 or (#group<100 and sameSourceOffer(group[1],offer,run.player)) then group[#group+1]=offer end
        end
    end
    return group
end
local function putGroup(run)
    local group,first={},nil
    for _,offer in ipairs(run.haul or {}) do
        if (offer.taken or offer.carried) and not offer.put and not offer.revert and not offer.drop then
            if not first then first=offer end
            if first and #group<100 and samePutOffer(first,offer) then group[#group+1]=offer end
        end
    end
    return group
end
local function revertGroup(run)
    local group,first={},nil
    for _,offer in ipairs(run.haul or {}) do
        if offer.revert and not offer.put and not offer.drop then
            if not first then first=offer end
            if first and #group<100 and sameSourceOffer(first,offer,run.player) then group[#group+1]=offer end
        end
    end
    return group
end
local function pipelineStep(run)
    local sq=run.player:getCurrentSquare();local origin=run.startSquare
    local building=run.discovery and run.discovery.building and origin and origin:getBuilding()
    local currentBuilding=sq and sq:getBuilding()
    local scopeReady=run.scopeRoom or building and currentBuilding and currentBuilding:getDef()==building:getDef()
        or not building and sq and origin and sq:getZ()==origin:getZ()
        and math.max(math.abs(sq:getX()-origin:getX()),math.abs(sq:getY()-origin:getY()))<=3
    if run.busy or not empty(run.player) then return end
    if run.haul and #run.haul>0 then
        local mode,group
        if run.haulPhase~='put' and run.haulPhase~='revert' then
            group=takeGroup(run);mode='take'
            if #group==0 then run.haulPhase='put' end
        end
        if (not group or #group==0) and run.haulPhase=='put' then
            group=putGroup(run);mode='put'
            if #group==0 then run.haulPhase='revert' end
        end
        if (not group or #group==0) and run.haulPhase=='revert' then
            group=revertGroup(run);mode='revert'
        end
        if group and #group>0 then
            run.busy=true
            if not E.startBatch(run.playerNum,group,function(status,completed,failed,rejection,report)
                onHaulBatch(run,group,status,completed,failed,rejection,report)
            end,mode) then endRun(run,'cancelled') end
            return
        end
        run.haul=nil;run.haulPhase=nil
    end
    if not scopeReady and not run.prefetch and origin then
        local action=returnWalk(run,origin);run.busy=true
        action:setOnComplete(function() if not run.closed then run.busy=false end end)
        ISTimedActionQueue.add(action)
        return
    end
    if run.exhausted and not run.prefetch then endRun(run,'ok');return end
    if run.prefetch or getTimestampMs()<(run.nextPrefetchAt or 0) then return end
    run.prefetch=true
    run.nextPrefetchAt=getTimestampMs()+250
    Trace.emit(run.trace,'PREFETCH_REQUEST','tripNext')
    A.request(run.playerNum,'tripNext',{run=run.id,trace=run.trace},function(r)
        run.prefetch=false
        if run.closed then return end
        planningResult(run,r)
        if r.status=='waiting' or r.status=='rateLimited' then return end
        if r.status=='done' then run.exhausted=true;return end
        if r.status~='ok' then endRun(run,r.status);return end
        run.planningSkipped=r.skipped or run.planningSkipped
        run.haul=r.offers or {}
        run.haulPhase='take'
        local pendingTake=false
        for _,offer in ipairs(run.haul) do
            if offer.carried then offer.taken=true else pendingTake=true end
        end
        if not pendingTake then run.haulPhase='put' end
        if #run.haul==0 then run.haul=nil;run.exhausted=not r.remaining end
        run.exhausted=not r.remaining
        Trace.emit(run.trace,'PLAN_READY',#(run.haul or {}))
    end)
end
local function step(run)
    if (run.player.pressedMovement and run.player:pressedMovement(false)) or (run.player.pressedCancelAction and run.player:pressedCancelAction()) then S.cancel(run.playerNum);return end
    Trace.observe(run.trace,run.player)
    if B47ANCEDQuartermaster.SortTraceEnabled==true then
        local state=run.phase..':'..tostring(run.pending)..':'..tostring(run.busy)
        if run.traceState~=state then
            Trace.emit(run.trace,'CLIENT_STATE',state,nil,nil,run.traceStateAt)
            run.traceState,run.traceStateAt=state,Trace.begin()
        end
    end
    if run.pending or (run.busy and not run.pipeline) then return end
    if getTimestampMs()-run.time>=1800000 then endRun(run,'uncertain');return end
    if run.pipeline and run.id then pipelineStep(run);return end
    if run.phase=='bind' then
        if getTimestampMs()-run.time>15000 then endRun(run,'uncertain');return end
        if not run.sourceToken then
            if not T.valid(run.sourceTarget,run.player) then endRun(run,'invalid');return end
            for _,meta in ipairs(run.discovery.targets) do
                local target=E.resolve(meta.identity,run.player)
                if target and target.obj==run.sourceTarget.obj and target.container==run.source then run.sourceToken=meta.token;break end
            end
            if not run.sourceToken then
                if B47ANCEDQuartermaster.SortTraceEnabled==true and not run.traceBindWait then Trace.emit(run.trace,'HANDLE_RESOLUTION','waiting','native-replication');run.traceBindWait=Trace.begin() end
                return
            end -- await native ModData replication
        end
        Trace.emit(run.trace,'HANDLE_RESOLUTION','resolved',nil,nil,run.traceBindAt)
        request(run,'tripBegin',{session=run.discovery.session,source=run.sourceToken,sourceItems=run.sourceItems,sourceHint=run.sourceHint,area=run.area,sweep=run.sweep},function(r)
            if r.status~='ok' then endRun(run,r.status);return end
            run.id=r.run;run.phase='next'
            Trace.emit(run.trace,'RESPONSE_ACCEPTED','tripBegin')
        end)
    elseif run.phase=='next' and empty(run.player) then
        request(run,'tripNext',{run=run.id},function(r)
            run.planningSkipped=r.skipped or run.planningSkipped
            if r.status=='done' then endRun(run,'ok');return end
            if r.status~='ok' then endRun(run,r.status);return end
            Trace.emit(run.trace,'PLAN_READY',#(r.offers or {}))
            run.offers=r.offers;run.remaining=r.remaining;run.loaded={};run.index=1;run.phase='load'
        end)
    elseif run.phase=='load' and empty(run.player) then
        local offer=run.offers[run.index]
        if not offer then run.phase='deposit';run.index=1;return end
        run.busy=true;run.index=run.index+1
        Trace.emit(run.trace,'TRIP_SELECTED',offer.operation)
        local started=E.acceptOffer(run.playerNum,offer,function(status) itemFinished(run,status) end,function(op)
            run.loaded[#run.loaded+1]=op;run.busy=false
        end)
        if not started then endRun(run,'cancelled') end
    elseif run.phase=='deposit' and empty(run.player) then
        local op=run.loaded[run.index]
        if not op then
            if not run.remaining then run.phase='next';return end
            run.phase='return'
            return
        end
        run.index=run.index+1;run.busy=true
        if not E.resume(op) then itemFinished(run,'invalid') end
    elseif run.phase=='return' and empty(run.player) then
        if run.sourceTarget and not T.valid(run.sourceTarget,run.player) then endRun(run,'invalid');return end
        local square=run.sourceTarget and AdjacentFreeTileFinder.Find(run.sourceTarget.obj:getSquare(),run.player) or run.startSquare
        if not square then endRun(run,'unreachable');return end
        local walk=returnWalk(run,square)
        run.phase='returning'
        walk:setOnComplete(function() if not run.closed then run.phase='next' end end)
        ISTimedActionQueue.add(walk)
        Trace.emit(run.trace,'ACTION_QUEUED','walk-return')
    end
end
function S.tick()
    for _,run in pairs(S.active) do
        local ok,err=pcall(step,run)
        if not ok then Trace.failure(run.trace,run.phase,err);endRun(run,'uncertain') end
    end
end
if Events and Events.OnTick then
    -- Local ready-state dispatch is cheap; only network retry queries are polled.
    Events.OnTick.Add(S.tick)
end
return S
