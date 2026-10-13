-- ISOLATED MANUAL DIAGNOSTIC, NOT PRODUCTION SORTING OR AN AUTHORIZATION LAYER.
-- Load only in a disposable native test environment. No auto-transfer, networking,
-- world writes, spawning, hooks or timers are installed by loading this file.
-- The operator arms matching observations on server/client, then explicitly calls
-- transfer() on the client (or SP). Vanilla owns the actual transfer protocol.
B47NativeTransferProbe = B47NativeTransferProbe or {watches={}}
local P=B47NativeTransferProbe

local function capture(container)
    assert(container and container:getType()~='floor','Use player root or fixed world storage, not floor')
    assert(not container:getContainingItem(),'Nested bags are outside this minimal probe')
    local parent=container:getParent()
    assert(parent,'Container needs a live parent')
    assert(not instanceof(parent,'BaseVehicle') and not instanceof(parent,'IsoDeadBody'),'Use fixed world storage, not vehicles or corpses')
    if instanceof(parent,'IsoPlayer') then
        assert(parent:getInventory()==container,'Use the player root inventory')
        return {container=container,parent=parent,player=true}
    end
    local square=parent:getSquare()
    assert(square,'World container must be loaded')
    local index=parent:getContainerIndex(container)
    assert(index>=0 and parent:getContainerByIndex(index)==container,'Exact section required')
    return {container=container,parent=parent,square=square,section=index,
        x=square:getX(),y=square:getY(),z=square:getZ()}
end

local function live(bound)
    if bound.player then return bound.parent:getInventory()==bound.container end
    if getCell():getGridSquare(bound.x,bound.y,bound.z)~=bound.square then return false end
    if bound.parent:getSquare()~=bound.square or bound.parent:getContainerByIndex(bound.section)~=bound.container then return false end
    local objects=bound.square:getObjects()
    for i=0,objects:size()-1 do if objects:get(i)==bound.parent then return true end end
    return false
end

local function count(container,id)
    local n=0
    local items=container:getItems()
    for i=0,items:size()-1 do if items:get(i):getID()==id then n=n+1 end end
    return n
end

function P.watch(label,source,itemID,destination)
    assert(type(label)=='string' and label~='' and not P.watches[label],'Use a fresh label per attempt')
    assert(source~=destination,'Self-transfer is not a probe')
    local item=source:getItemWithID(itemID)
    assert(item and item:getID()==itemID and item:getContainer()==source,'Exact item must be in source')
    assert(not instanceof(item,'InventoryContainer') and not item:isHumanCorpse(),'Use one ordinary item, not a bag or corpse')
    local watch={source=capture(source),destination=capture(destination),item=item,id=itemID,type=item:getFullType(),used=false}
    assert(live(watch.source) and live(watch.destination),'Target is not live')
    assert(count(source,itemID)==1 and count(destination,itemID)==0,'Item ID baseline is ambiguous')
    P.watches[label]=watch
    return P.snapshot(label)
end

function P.snapshot(label)
    local watch=assert(P.watches[label],'Arm observation first')
    local source,destination=watch.source.container,watch.destination.container
    local src,dst=count(source,watch.id),count(destination,watch.id)
    local arrived=destination:getItemWithID(watch.id)
    local result={itemID=watch.id,fullType=watch.type,sourceCount=src,destinationCount=dst,
        sourceLive=live(watch.source),destinationLive=live(watch.destination),
        destinationSameReference=arrived==watch.item,
        destinationSameType=arrived~=nil and arrived:getFullType()==watch.type,
        side=isServer() and 'server' or (isClient() and 'client' or 'SP')}
    -- Counts cover the two held references only; this is not a global duplication scan.
    print('[B47NativeTransferProbe] '..label..' side='..result.side..' item='..watch.id..
        ' source='..src..' destination='..dst..' sourceLive='..tostring(result.sourceLive)..
        ' destinationLive='..tostring(result.destinationLive)..' sameReference='..tostring(result.destinationSameReference))
    return result
end

function P.transfer(label,player)
    assert(not isServer(),'The normal native timed-action initiation is client/SP only')
    local watch=assert(P.watches[label],'Arm observation first')
    assert(not watch.used,'No retries: inspect both peers and use a fresh attempt after reset')
    assert(live(watch.source) and live(watch.destination),'Exact held target became stale')
    local source,destination=watch.source.container,watch.destination.container
    assert(source:getItemWithID(watch.id)==watch.item and watch.item:getContainer()==source,'Exact source item changed')
    assert(not watch.item:isFavorite() and not player:isEquipped(watch.item),'Use an unequipped, non-favorite test item')
    assert(source:isRemoveItemAllowed(watch.item) and destination:isItemAllowed(watch.item),'Vanilla admission rules rejected')
    assert(destination:hasRoomFor(player,watch.item),'No capacity')
    require 'TimedActions/ISTimedActionQueue'
    require 'TimedActions/ISInventoryTransferUtil'
    local queue=ISTimedActionQueue.getTimedActionQueue(player)
    assert(queue and #queue.queue==0,'Stop other timed actions before this one-item experiment')
    local action=ISInventoryTransferUtil.newInventoryTransferAction(player,watch.item,source,destination)
    watch.used=true;watch.action=action
    ISTimedActionQueue.add(action)
    return action
end

return P
