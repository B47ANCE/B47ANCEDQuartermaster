-- Native class instances only. The context outlives vanilla's wiped merge donors.
-- PZ can auto-load this alphabetically before Executor, including ResetLua.
require 'B47ANCEDQuartermaster/Authority'
require 'TimedActions/ISInventoryTransferAction'
require 'TimedActions/ISTimedActionQueue'
local Q=B47ANCEDQuartermaster
local E=Q.Executor or {active={},batches={}};Q.Executor=E
local A=Q.Authority
local Trace=require 'B47ANCEDQuartermaster/SortTrace'
local function queue(player) return ISTimedActionQueue.getTimedActionQueue(player).queue end
function E.batchSupported()
    return type(ISInventoryTransferAction.canMergeAction)=='function' and type(ISInventoryTransferAction.checkQueueList)=='function'
end
local function cancelOp(op)
    if not op.cancelSent then op.cancelSent=true;A.request(op.playerNum,'moveCancel',{operation=op.id},function() end) end
end
local function parked(b,op)
    if op.state=='done' or op.state=='spill' or op.state=='revert' then return true end
    if b.mode=='take' and op.state=='carried' then return true end
    return false
end
local function reportOf(b)
    local report={kept={},done={},spill={},revert={},failed={}}
    for _,op in ipairs(b.ops) do
        if op.state=='spill' then report.spill[op.id]=op.spillDest
        elseif op.state=='revert' then report.revert[op.id]=true
        elseif op.state=='failed' then report.failed[op.id]=true
        elseif op.state=='done' then report.done[op.id]=true
        elseif b.mode=='take' and op.state=='carried' then report.kept[op.id]=true end
    end
    return report
end
local function done(b,status)
    if b.closed then return end
    b.closed=true;E.batches[b.playerNum]=nil
    for _,op in ipairs(b.ops) do if not parked(b,op) then cancelOp(op) end end
    Trace.emit(b.trace,'BATCH_COMPLETED',status,nil,nil,nil,b.completed)
    b.callback(status,b.completed,b.failed,b.rejection or (status~='ok' and {phase=b.phase,status=status,reason='clientBatchStopped'} or nil),reportOf(b))
end
local function fail(b,op)
    if op.state=='failed' or op.state=='done' then return end
    op.state='failed';op.closed=true;b.failed=b.failed+1;cancelOp(op)
end
local function stateCount(b,state)
    local n=0;for _,op in ipairs(b.ops) do if op.state==state then n=n+1 end end;return n
end
local function walk(b,target,nextPhase)
    local sq=target and target.obj:getSquare()
    if not sq then done(b,'invalid');return end
    local external=target.external and target.root.part
    if external and require('B47ANCEDQuartermaster/ContainerSources').reachable(target,b.player)
        or not external and Q.Targets.sameFloor(b.player,sq) and math.max(math.abs(b.player:getX()-sq:getX()),math.abs(b.player:getY()-sq:getY()))<=1 then b.phase=nextPhase;return end
    local action
    if external then
        require 'Vehicles/TimedActions/ISPathFindAction'
        action=ISPathFindAction:pathToVehicleArea(b.player,target.root.obj,target.root.part:getArea())
    else
        local stand=AdjacentFreeTileFinder.Find(sq,b.player)
        if stand then action=ISWalkToTimedAction:new(b.player,stand) end
    end
    if not action then done(b,'unreachable');return end
    action.b47Batch=b
    local nativeStart,nativeStop=action.start,action.stop
    function action:stop() done(b,'cancelled');if nativeStop then nativeStop(self) end end
    function action:forceCancel() done(b,'cancelled') end
    function action:start() b.walkStarted=Trace.begin();b.walkLength=nil;b.walkActive=true;if nativeStart then nativeStart(self) end end
    action:setOnComplete(function() if not b.closed then Trace.emit(b.trace,'ROUTE_WALK_COMPLETE',nextPhase,nil,nil,b.walkStarted,b.walkLength);b.walkActive=false;b.phase=nextPhase end end)
    b.phase='walking';ISTimedActionQueue.add(action)
    Trace.emit(b.trace,'ACTION_QUEUED',nextPhase=='grantTake' and 'walk-take-batch' or 'walk-put-batch')
end
local function transfer(b,leg)
    local wanted=leg=='take' and 'take' or 'put';local ops={}
    for _,op in ipairs(b.ops) do
        if op.state==wanted then
            local src=leg=='take' and op.source.container or op.carrier
            local dst=leg=='take' and op.carrier or op.destination.container
            local allowed,reason=E.check(op,leg,op.item,src,dst)
            if allowed then ops[#ops+1]=op else
                b.rejection=b.rejection or {phase=b.phase,status='invalid',reason=reason or 'dispatchGuardRejected'}
                fail(b,op)
            end
        end
    end
    if #ops==0 then done(b,'partial');return end
    local src=leg=='take' and ops[1].source.container or ops[1].carrier
    local dst=leg=='take' and ops[1].carrier or ops[1].destination.container
    local native=ISInventoryTransferAction
    local head=native:new(b.player,ops[1].item,src,dst)
    head.b47Batch,head.leg=b,leg
    function head:canMergeAction(other)
        return other and other.b47Batch==b and other.leg==leg and other.Type==self.Type
            and other.srcContainer==self.srcContainer and other.destContainer==self.destContainer
            and other.allowMissingItems==self.allowMissingItems and not other.onCompleteFunc
    end
    function head:isValid()
        if b.closed then return false end
        local op=self.item and b.byID[self.item:getID()]
        if not op then self.b47Invalid='operationItemMissing';return false end
        if op.state~=wanted then self.b47Invalid='operationStateRejected:'..tostring(op.state);return false end
        -- Completed MP transactions have already changed client containment.
        -- Source removal and destination replication need not arrive together.
        -- Vanilla owns validation of the already-submitted transaction; B47
        -- checks pending groups below before their next native submission.
        if not (self.dispatched and isClient()) and not E.check(op,leg,self.item,src,dst) then
            self.b47Invalid='batchGuardRejected';return false
        end
        local valid=native.isValid(self)
        if not valid then self.b47Invalid='nativeValidationRejected' end
        return valid
    end
    function head:checkQueueList()
        native.checkQueueList(self)
        for groupIndex=#self.queueList,1,-1 do
            local group=self.queueList[groupIndex]
            for itemIndex=#group.items,1,-1 do
                local item=group.items[itemIndex]
                local op=b.byID[item:getID()]
                local valid,reason
                if not op then reason='operationItemMissing'
                elseif op.state~=wanted then reason='operationStateRejected'
                elseif isClient() and self.dispatched and item:getContainer()==dst then valid=true
                else valid,reason=E.check(op,leg,item,src,dst) end
                if not valid then
                    b.rejection=b.rejection or {phase=b.phase,status='invalid',reason=reason or 'dispatchGuardRejected'}
                    -- These entries have not been submitted. Retain completed native
                    -- work and discard only newly inadmissible queued transfers.
                    if op then fail(b,op) end
                    table.remove(group.items,itemIndex)
                end
            end
            if #group.items==0 then table.remove(self.queueList,groupIndex) end
        end
    end
    function head:start()
        if not self:isValid() then done(b,'invalid');self:forceStop();return end
        self:checkQueueList()
        if #self.queueList==0 then done(b,'partial');self:forceStop();return end
        Trace.emit(b.trace,'ACTION_STARTED',leg..'-batch',nil,nil,nil,#ops)
        local ok,err=pcall(native.start,self)
        if not ok then Trace.failure(b.trace,'BATCH_START',err);done(b,'uncertain');self:forceStop();return end
        self.dispatched=isClient()
    end
    function head:perform()
        self.b47PerformCount=(self.b47PerformCount or 0)+1
        local ok,err=pcall(native.perform,self)
        if not ok then Trace.failure(b.trace,'BATCH_PERFORM',err);done(b,'uncertain');self:forceStop() end
    end
    function head:stop()
        local rejected=isClient() and self.transactionId and isItemTransactionRejected
            and isItemTransactionRejected(self.transactionId)
        local reason=rejected and 'nativeTransactionRejected' or self.b47Invalid
            or ((self.b47PerformCount or 0)>0 and 'nativeStoppedAfterPerform' or 'nativeStoppedBeforePerform')
        b.rejection=b.rejection or {phase=b.phase,status='cancelled',reason=reason}
        done(b,'cancelled');native.stop(self)
    end
    function head:forceCancel()
        b.rejection=b.rejection or {phase=b.phase,status='cancelled',reason='nativeQueueCancelled'}
        done(b,'cancelled')
    end
    head:setOnComplete(function()
        if not b.closed then b.phase=leg=='take' and 'confirmCarried' or 'confirmDone';b.phaseTime=getTimestampMs() end
    end)
    b.phase=leg=='take' and 'taking' or 'putting'
    -- Vanilla's queue gate inserts all donors before the head can begin. This
    -- lets native start() submit its full first group instead of a lone item.
    -- Native weight/type grouping, timing and item transactions remain intact.
    require 'TimedActions/ISQueueActionsAction'
    local gate=ISQueueActionsAction:new(b.player,function()
        if b.closed then return end
        ISTimedActionQueue.add(head)
        for i=2,#ops do
            if b.closed then break end
            local action=native:new(b.player,ops[i].item,src,dst)
            action.b47Batch,action.leg=b,leg
            -- If native merging stops at an unrelated action, an owned donor
            -- still fails closed after cancellation rather than run unguarded.
            for _,method in ipairs({'canMergeAction','isValid','checkQueueList','start','perform','stop','forceCancel'}) do action[method]=head[method] end
            ISTimedActionQueue.add(action)
        end
    end)
    gate.b47Batch=b
    function gate:stop() done(b,'cancelled');ISQueueActionsAction.stop(self) end
    function gate:forceCancel() done(b,'cancelled') end
    ISTimedActionQueue.add(gate)
    Trace.emit(b.trace,'ACTION_QUEUED',leg..'-batch',nil,nil,nil,#ops)
end
local function requestAll(b,command,fromState,toState,nextPhase)
    local selected={}
    for _,op in ipairs(b.ops) do if op.state==fromState then selected[#selected+1]=op end end
    if #selected==0 then b.phase=nextPhase;return end
    if command=='moveTake' or command=='movePut' then
        if b.arrivalCommand~=command then b.arrivalCommand=command;b.arrivalStarted=getTimestampMs() end
        if getTimestampMs()-b.arrivalStarted>=15000 then
            b.rejection=b.rejection or {phase=command,status='uncertain',reason='arrivalTimeout'}
            done(b,'uncertain');return
        end
    end
    if b.nextRequestAt and getTimestampMs()<b.nextRequestAt then return end
    local ids={};for i,op in ipairs(selected) do ids[i]=op.id end
    b.pending=1;b.requestStarted=Trace.begin()
    A.request(b.playerNum,'moveBatch',{phase=command,operations=ids,trace=b.trace},function(response)
        b.pending=0
        if b.closed then for _,op in ipairs(selected) do cancelOp(op) end;return end
        if response.status=='rateLimited' then b.nextRequestAt=getTimestampMs()+250;return end
        if response.status~='ok' or type(response.results)~='table' or #response.results~=#selected then
            b.rejection=b.rejection or {phase=command,status=response.status,reason=response.reason or 'batchResponseRejected',serverVersion=response.serverVersion}
            done(b,'uncertain');return
        end
        -- Validate correlation before applying any states. Never infer a grant
        -- from a missing, duplicate, reordered or malformed response entry.
        for i,op in ipairs(selected) do
            local result=response.results[i]
            if type(result)~='table' or result.operation~=op.id or type(result.status)~='string' then
                b.rejection=b.rejection or {phase=command,status='invalid',reason='batchCorrelationRejected'}
                done(b,'uncertain');return
            end
        end
        for i,op in ipairs(selected) do
            local result=response.results[i]
            if result.status=='ok' then
                op.state=toState
                if toState=='carried' then
                    op.item=op.carrier:getItemWithID(op.itemID)
                    if not op.item then done(b,'uncertain');return end
                    b.byID[op.itemID]=op
                elseif toState=='done' then
                    op.closed=true
                    if b.mode=='revert' then b.failed=b.failed+1 else b.completed=b.completed+1 end
                end
            elseif result.status=='spill' and type(result.destination)=='table' and result.destination.instance~=nil then
                op.offer.destination=result.destination
                op.destination=nil
                op.spillDest=result.destination
                op.state='spill'
            elseif result.status=='revert' then op.state='revert'
            elseif result.status=='waiting' then b.nextRequestAt=getTimestampMs()+250
            else
                b.rejection=b.rejection or {phase=command,status=result.status,reason=result.reason or 'unspecified',serverVersion=response.serverVersion}
                fail(b,op)
            end
        end
        Trace.emit(b.trace,'BATCH_GRANTS',command,nil,nil,b.requestStarted,#selected)
        if stateCount(b,fromState)>0 then
            -- Retry authorization/confirmation queries, never native transfers.
            b.retry=true
        else b.phase=nextPhase;b.retry=false;b.nextRequestAt=nil end
    end)
end
function E.startBatch(playerNum,offers,callback,mode)
    local player=getSpecificPlayer(playerNum)
    if not E.batchSupported() or not player or E.active[playerNum] or E.batches[playerNum] or #queue(player)>0 or #offers<1 or #offers>100 then return false end
    local b={player=player,playerNum=playerNum,time=getTimestampMs(),phase='resolve',mode=mode or 'both',ops={},byID={},callback=callback,completed=0,failed=0,trace=offers[1].trace}
    local ids={}
    for _,offer in ipairs(offers) do
        if ids[offer.operation] or offer.withdrawal then return false end
        ids[offer.operation]=true
        b.ops[#b.ops+1]={player=player,playerNum=playerNum,time=b.time,id=offer.operation,itemID=offer.itemID,offer=offer,state='resolve',trace=b.trace}
    end
    E.batches[playerNum]=b
    return true
end
function E.cancelBatch(playerNum)
    local b=E.batches[playerNum];if not b then return end
    done(b,'cancelled')
    local action=queue(b.player)[1]
    if action and action.b47Batch==b then action:forceStop() end
end
local function tick(b)
    if b.closed then return end
    Trace.observe(b.trace,b.player)
    if b.phase=='walking' and b.walkActive and Q.SortTraceEnabled==true and b.player.getPathFindBehavior2 then
        local behavior=b.player:getPathFindBehavior2()
        if behavior and behavior.getPathLength then local ok,length=pcall(behavior.getPathLength,behavior);if ok and type(length)=='number' and length>0 and not b.walkLength then b.walkLength=length;Trace.emit(b.trace,'ROUTE_NATIVE_PATH','observed',nil,nil,nil,length) end end
    end
    if (b.player.pressedMovement and b.player:pressedMovement(false)) or (b.player.pressedCancelAction and b.player:pressedCancelAction()) then E.cancelBatch(b.playerNum);return end
    if getTimestampMs()-b.time>=1800000 then
        done(b,'uncertain');local action=queue(b.player)[1]
        if action and action.b47Batch==b then action:forceStop() end
        return
    end
    if b.pending and b.pending>0 then return end
    if #queue(b.player)>0 then return end
    if b.phase=='resolve' then
        if getTimestampMs()-b.time>15000 then done(b,'uncertain');return end
        for _,op in ipairs(b.ops) do
            -- A native ground TAKE removes its world object. PUT needs the carried
            -- reference and live destination, not a newly resolved removed source.
            if b.mode~='put' then op.source=op.source or (op.offer.source and E.resolve(op.offer.source,b.player)) end
            if b.mode=='revert' and (not op.offer.source or op.offer.source.ground) then
                fail(b,op)
            else
            op.destination=op.destination or E.resolve(op.offer.destination,b.player)
            op.carrier=op.carrier or Q.Movement.carrier(b.player,op.offer.carrierID)
            if not op.destination or not op.carrier or (b.mode~='put' and op.offer.source and not op.source) then return end
            local first=b.ops[1]
            local sameCarrier=op.carrier==first.carrier
            local sameSource=(op.source and op.source.container)==(first.source and first.source.container)
            local sameDest=op.destination.container==first.destination.container
            if b.mode=='take' or b.mode=='revert' then
                if not sameCarrier or not sameSource then done(b,'invalid');return end
            elseif not sameDest or not sameCarrier or (b.mode~='put' and not sameSource) then done(b,'invalid');return end
            if b.mode=='put' or b.mode=='revert' then op.item=op.carrier and op.carrier:getItemWithID(op.itemID) or nil
            else op.item=op.source and op.source.ground and op.source.item or (op.source and op.source.container or op.carrier):getItemWithID(op.itemID) end
            if not op.item then fail(b,op)
            elseif b.mode=='revert' then
                if not op.source then fail(b,op) else b.byID[op.itemID]=op;op.destination=op.source;op.state='carried' end
            elseif b.mode=='put' then b.byID[op.itemID]=op;op.state='carried'
            else b.byID[op.itemID]=op;op.state=op.source and 'planned' or 'unconfirmed' end
            end
        end
        local first=b.ops[1]
        local function lead(state)
            for _,op in ipairs(b.ops) do if op.state==state and op.destination then return op end end
        end
        if b.mode=='take' then
            if not first.source then done(b,'invalid');return end
            walk(b,first.source,'grantTake')
        elseif b.mode=='put' or b.mode=='revert' then
            local carried=lead('carried')
            if not carried then done(b,'partial') else walk(b,carried.destination,'grantPut') end
        elseif first.source then walk(b,first.source,'grantTake') else b.phase='confirmCarried';b.phaseTime=getTimestampMs() end
    elseif b.phase=='grantTake' then requestAll(b,'moveTake','planned','take','takeReady')
    elseif b.phase=='takeReady' then transfer(b,'take')
    elseif b.phase=='confirmCarried' then
        if getTimestampMs()-(b.phaseTime or b.time)>15000 then done(b,'uncertain');return end
        requestAll(b,'moveCarried',b.ops[1].source and 'take' or 'unconfirmed','carried',b.mode=='take' and 'finished' or 'putWalk')
    elseif b.phase=='putWalk' then
        local carried
        for _,op in ipairs(b.ops) do if op.state=='carried' and op.destination then carried=op;break end end
        if not carried then done(b,'partial') else walk(b,carried.destination,'grantPut') end
    elseif b.phase=='grantPut' then requestAll(b,b.mode=='revert' and 'moveRevert' or 'movePut','carried','put','putReady')
    elseif b.phase=='putReady' then transfer(b,'put')
    elseif b.phase=='confirmDone' then
        if getTimestampMs()-(b.phaseTime or b.time)>15000 then done(b,'uncertain');return end
        requestAll(b,b.mode=='revert' and 'moveReverted' or 'moveDone','put','done','finished')
    elseif b.phase=='finished' then done(b,b.failed>0 and 'partial' or 'ok') end
end
function E.tickBatches()
    for _,b in pairs(E.batches) do
        -- Drain only cheap ready transitions. A queued action, pending response,
        -- retry deadline or unchanged phase yields immediately; no busy loop.
        for _=1,8 do
            local phase=b.phase
            local ok,err=pcall(tick,b)
            if not ok then Trace.failure(b.trace,'BATCH_TICK',err);E.cancelBatch(b.playerNum);break end
            if b.closed or (b.pending and b.pending>0) or #queue(b.player)>0 or b.phase==phase then break end
        end
    end
end
if Events and Events.OnTick then Events.OnTick.Add(E.tickBatches) end
return E
