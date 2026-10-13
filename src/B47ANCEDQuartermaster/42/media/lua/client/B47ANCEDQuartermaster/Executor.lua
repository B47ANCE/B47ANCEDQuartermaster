require 'B47ANCEDQuartermaster/Authority'
require 'TimedActions/ISInventoryTransferAction'
require 'TimedActions/ISTimedActionQueue'
require 'TimedActions/WalkToTimedAction'
local E=B47ANCEDQuartermaster.Executor or {active={},batches={}}
B47ANCEDQuartermaster.Executor=E
local A,T=B47ANCEDQuartermaster.Authority,B47ANCEDQuartermaster.Targets
local Trace=require 'B47ANCEDQuartermaster/SortTrace'
local function queue(player) return ISTimedActionQueue.getTimedActionQueue(player).queue end
local function alive(t,player)
    if t and t.ground then return B47ANCEDQuartermaster.GroundSources.valid(t,player) end
    return t and T.valid(t,player) and t.obj:getModData().B47MovementInstance==t.instance
end
-- Resolve only a server-issued incarnation marker, never whatever occupies an
-- object-list index. Once resolved, retain these references for the operation.
local function resolve(meta,player)
    if not meta then return end
    if meta.ground then return B47ANCEDQuartermaster.GroundSources.resolve(meta,player) end
    local sq=getCell():getGridSquare(meta.x,meta.y,meta.z)
    if not sq then return end
    local objects=sq:getObjects()
    local found
    for i=0,objects:size()-1 do
        local obj=objects:get(i)
        if obj:getModData().B47MovementInstance==meta.instance then
            if found then return end -- ambiguous marker fails closed
            found={obj=obj,ci=meta.ci,container=obj:getContainerByIndex(meta.ci),instance=meta.instance}
        end
    end
    if alive(found,player) then return found end
end
local function finish(op,status)
    if op.closed then return end
    Trace.emit(op.trace or op.id,'TRANSFER_COMPLETED',status)
    op.closed=true;E.active[op.playerNum]=nil
    if op.id then A.request(op.playerNum,'moveCancel',{operation=op.id},function() end) end
    if op.callback then op.callback(status) end
end
local function request(op,command,done)
    op.pending=true
    local measured=Trace.begin()
    Trace.emit(op.trace or op.id,'GRANT_REQUEST',command,nil,op.id)
    A.request(op.playerNum,command,{operation=op.id,trace=op.trace},function(result)
        op.pending=false
        Trace.emit(op.trace or op.id,'GRANT_RESPONSE',result.status,command,op.id,measured)
        if not op.closed then done(result) end
    end)
end
local function check(op,leg,item,source,destination)
    if op.closed or getTimestampMs()-op.time>=1800000 or (not op.offer.withdrawal and not alive(op.destination,op.player)) then return false end
    if op.offer.withdrawal and leg~='take' then return false end
    if (op.player.pressedMovement and op.player:pressedMovement(false)) or (op.player.pressedCancelAction and op.player:pressedCancelAction()) then return false end
    if B47ANCEDQuartermaster.Movement.carrier(op.player,op.offer.carrierID)~=op.carrier then return false end
    if leg=='take' and not alive(op.source,op.player) then return false end
    local square=(leg=='take' and op.source or op.destination).obj:getSquare()
    if not T.sameFloor(op.player,square) or math.max(math.abs(op.player:getX()-square:getX()),math.abs(op.player:getY()-square:getY()))>2 then return false end
    if item~=op.item or item:getID()~=op.itemID or item:getContainer()~=source or (not (op.source and op.source.ground and leg=='take') and source:getItemWithID(op.itemID)~=item) then return false end
    if item:isFavorite() or item:isEquipped() or item:getAttachedSlot()~=-1 or item:getIsCraftingConsumed() then return false end
    local expectedSource=leg=='take' and op.source.container or op.carrier
    local expectedDest=leg=='take' and op.carrier or op.destination.container
    return source==expectedSource and destination==expectedDest
        and source:isRemoveItemAllowed(item) and destination:isItemAllowed(item) and destination:hasRoomFor(op.player,item)
        and (op.offer.withdrawal or alive(op.destination,op.player)) and (leg~='take' or alive(op.source,op.player))
end
-- Networked timed actions serialize their metatable Type and that class's raw
-- constructor. Client-only derived classes cannot be reconstructed by a
-- dedicated server. Keep native metatables and add local guards per instance.
local function guardedTransfer(op,leg,source,dest)
    local action=ISInventoryTransferAction:new(op.player,op.item,source,dest)
    action.op,action.leg=op,leg
    action.traceQueuedAt=Trace.begin()
    function action:canMergeAction() return false end
    function action:isValid()
        if self.dispatched and isClient() then return ISInventoryTransferAction.isValid(self) end
        return check(op,leg,self.item,self.srcContainer,self.destContainer) and ISInventoryTransferAction.isValid(self)
    end
    function action:checkQueueList()
        -- Vanilla start calls this immediately before native submission.
        if self.finalCheck and not check(op,leg,self.item,self.srcContainer,self.destContainer) then self.rejectedBeforeDispatch=true;error('B47 rejected dispatch') end
    end
    function action:start()
        if not self:isValid() then finish(op,'invalid');self:forceStop();return end
        Trace.emit(op.trace or op.id,'ACTION_STARTED',leg,nil,op.id,self.traceQueuedAt)
        self.finalCheck=true
        local ok,err=pcall(ISInventoryTransferAction.start,self)
        self.finalCheck=false
        if not ok then
            if self.rejectedBeforeDispatch then Trace.emit(op.trace or op.id,'DISPATCH_REJECTED','invalid');finish(op,'invalid')
            else Trace.failure(op.trace or op.id,'ACTION_DISPATCH_FAILED',err);finish(op,'uncertain') end
            self:forceStop();return
        end
        self.dispatched=isClient()
        if self.dispatched then Trace.emit(op.trace or op.id,'TRANSFER_REQUESTED',leg) end
    end
    function action:perform()
        -- SP mutation occurs in vanilla perform, so its final boundary is here.
        if not isClient() and not self:isValid() then finish(op,'invalid');self:forceStop();return end
        self.finalCheck=not isClient()
        local ok,err=pcall(ISInventoryTransferAction.perform,self)
        self.finalCheck=false
        if not ok then Trace.failure(op.trace or op.id,'NATIVE_PERFORM_FAILED',err);finish(op,'uncertain');self:forceStop() end
    end
    function action:stop() finish(op,'cancelled');ISInventoryTransferAction.stop(self) end
    function action:forceCancel() finish(op,'cancelled') end
    return action
end
local function guardedWalk(op,square)
    local walk=ISWalkToTimedAction:new(op.player,square)
    walk.op=op
    walk.traceQueuedAt=Trace.begin()
    function walk:start()
        Trace.emit(op.trace or op.id,'ACTION_STARTED','walk',nil,op.id,self.traceQueuedAt)
        ISWalkToTimedAction.start(self)
    end
    function walk:stop() finish(op,'cancelled');ISWalkToTimedAction.stop(self) end
    function walk:forceCancel() finish(op,'cancelled') end
    return walk
end
local function transfer(op,leg)
    local source=leg=='take' and op.source.container or op.carrier
    local dest=leg=='take' and op.carrier or op.destination.container
    if not check(op,leg,op.item,source,dest) then finish(op,'invalid');return end
    local action=guardedTransfer(op,leg,source,dest)
    action:setOnComplete(function()
        if not op.closed then op.phase=leg=='take' and 'confirmCarried' or 'confirmDone';op.phaseTime=getTimestampMs() end
    end)
    op.phase=leg=='take' and 'taking' or 'putting'
    ISTimedActionQueue.add(action)
    Trace.emit(op.trace or op.id,'ACTION_QUEUED',leg)
end
function E.acceptOffer(playerNum,offer,callback,onLoaded)
    local player=getSpecificPlayer(playerNum)
    if E.active[playerNum] or E.batches[playerNum] or #queue(player)>0 then return false end
    E.active[playerNum]={player=player,playerNum=playerNum,time=getTimestampMs(),callback=callback,trace=offer.trace,
        id=offer.operation,itemID=offer.itemID,offer=offer,phase='resolve',onLoaded=onLoaded,traceResolveAt=Trace.begin()}
    return true
end
local function grant(op,command,leg)
    local time=getTimestampMs()
    if op.arrivalCommand~=command then op.arrivalCommand=command;op.arrivalStarted=time;op.nextArrivalPoll=nil end
    if time-op.arrivalStarted>=15000 then finish(op,'uncertain');return end
    if op.nextArrivalPoll and time<op.nextArrivalPoll then return end
    request(op,command,function(r)
        if r.status=='waiting' then op.nextArrivalPoll=getTimestampMs()+250;return end
        if r.status~='ok' then finish(op,r.status);return end
        if #queue(op.player)>0 then finish(op,'cancelled');return end
        transfer(op,leg)
    end)
end
function E.resume(op)
    if op.closed or E.active[op.playerNum] or #queue(op.player)>0 then return false end
    op.onLoaded=nil;op.phase='confirmCarried';op.phaseTime=getTimestampMs();E.active[op.playerNum]=op;return true
end
function E.start(playerNum,session,sourceToken,itemID,callback)
    local player=getSpecificPlayer(playerNum)
    if not player or E.active[playerNum] or E.batches[playerNum] or #queue(player)>0 then return false,'busy' end
    local op={player=player,playerNum=playerNum,time=getTimestampMs(),callback=callback,pending=true,phase='planning'}
    E.active[playerNum]=op
    A.request(playerNum,'movePlan',{session=session,source=sourceToken,itemID=itemID},function(result)
        op.pending=false
        if op.closed then
            if result.operation then A.request(playerNum,'moveCancel',{operation=result.operation},function() end) end
            return
        end
        if result.status~='ok' then finish(op,result.status);return end
        op.id,op.itemID,op.offer=result.operation,result.itemID,result
        op.phase='resolve'
    end)
    return true
end
function E.cancel(playerNum)
    if E.cancelBatch then E.cancelBatch(playerNum) end
    local op=E.active[playerNum]
    if not op then return end
    finish(op,'cancelled')
    local current=queue(op.player)[1]
    if current and current.op==op then current:forceStop() end
end
function E.tick()
    if E.tickBatches then E.tickBatches() end
    for _,op in pairs(E.active) do
        Trace.observe(op.trace or op.id,op.player)
        if B47ANCEDQuartermaster.SortTraceEnabled==true then
            local state=op.phase..':'..tostring(op.pending)
            if op.traceState~=state then
                Trace.emit(op.trace or op.id,'EXECUTOR_STATE',state,nil,op.id,op.traceStateAt)
                op.traceState,op.traceStateAt=state,Trace.begin()
            end
        end
        if getTimestampMs()-op.time>=1800000 then E.cancel(op.playerNum)
        elseif not op.pending then
            if op.phase=='resolve' then
                if getTimestampMs()-op.time>15000 then finish(op,'uncertain');return end
                op.destination=op.destination or resolve(op.offer.destination,op.player)
                op.source=op.source or (op.offer.source and resolve(op.offer.source,op.player))
                op.carrier=op.carrier or B47ANCEDQuartermaster.Movement.carrier(op.player,op.offer.carrierID)
                if (op.destination or op.offer.withdrawal) and op.carrier and (not op.offer.source or op.source) then
                    Trace.emit(op.trace or op.id,'RESPONSE_ACCEPTED','references-resolved')
                    Trace.emit(op.trace or op.id,'EXECUTOR_HANDLES','resolved',nil,op.id,op.traceResolveAt)
                    local source=op.source and op.source.container or op.carrier
                    op.item=op.source and op.source.ground and op.source.item or source:getItemWithID(op.itemID)
                    if not op.item then finish(op,'invalid')
                    elseif op.offer.withdrawal then
                        local stand=AdjacentFreeTileFinder.Find(op.source.obj:getSquare(),op.player)
                        if not stand or #queue(op.player)>0 then finish(op,'unreachable')
                        else
                            local walk=guardedWalk(op,stand)
                            op.phase='walkingTake'
                            walk:setOnComplete(function() if not op.closed then op.phase='grantTake' end end)
                            ISTimedActionQueue.add(walk)
                            Trace.emit(op.trace or op.id,'ACTION_QUEUED','walk-take')
                        end
                    else op.phase=op.source and 'grantTake' or 'confirmCarried';op.phaseTime=getTimestampMs() end
                end
            elseif op.phase=='grantTake' and #queue(op.player)==0 then
                grant(op,'moveTake','take')
            elseif op.phase=='confirmCarried' and #queue(op.player)==0 then
                if getTimestampMs()-(op.phaseTime or op.time)>15000 then finish(op,'uncertain');return end
                request(op,'moveCarried',function(r)
                    if r.status=='waiting' then return end
                    if op.offer.withdrawal then finish(op,r.status);return end
                    if r.status~='ok' or not alive(op.destination,op.player) then finish(op,'invalid');return end
                    -- MP may deserialize a new client reference; server has confirmed
                    -- the exact original server item. Reacquire only this native ID.
                    op.item=op.carrier:getItemWithID(op.itemID)
                    if not op.item then return end
                    if op.onLoaded then
                        op.phase='loaded';E.active[op.playerNum]=nil;op.onLoaded(op);return
                    end
                    local stand=AdjacentFreeTileFinder.Find(op.destination.obj:getSquare(),op.player)
                    if not stand or #queue(op.player)>0 then finish(op,'unreachable');return end
                    local walk=guardedWalk(op,stand)
                    op.phase='walking'
                    walk:setOnComplete(function() if not op.closed then op.phase='grantPut' end end)
                    ISTimedActionQueue.add(walk)
                    Trace.emit(op.trace or op.id,'ACTION_QUEUED','walk-put')
                end)
            elseif op.phase=='grantPut' and #queue(op.player)==0 then
                grant(op,'movePut','put')
            elseif op.phase=='confirmDone' and #queue(op.player)==0 then
                if getTimestampMs()-(op.phaseTime or op.time)>15000 then finish(op,'uncertain');return end
                request(op,'moveDone',function(r)
                    if r.status~='waiting' then finish(op,r.status) end
                end)
            end
        end
    end
end
E.check=check
E.resolve=resolve
E.alive=alive
if Events and Events.OnTick then
    local nextPoll=0
    Events.OnTick.Add(function()
        if getTimestampMs()>=nextPoll then
            nextPoll=getTimestampMs()+250
            local ok,err=pcall(E.tick)
            if not ok then
                local players={};for playerNum in pairs(E.active) do players[#players+1]=playerNum end
                for _,playerNum in ipairs(players) do
                    local op=E.active[playerNum]
                    if op then
                        Trace.failure(op.trace or op.id,op.phase,err)
                        finish(op,'uncertain')
                        local current=queue(op.player)[1]
                        if current and current.op==op then current:forceStop() end
                    end
                end
            end
        end
    end)
end
require 'B47ANCEDQuartermaster/BatchExecutor'
return E
