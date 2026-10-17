require 'B47ANCEDQuartermaster/Personal'
require 'B47ANCEDQuartermaster/Movement'
local Q=B47ANCEDQuartermaster
local D={inspections={}}
Q.Dibs=D
local key='B47Dibs'
function D.state(item)
    local value=item:getModData()[key]
    if value==nil then return {schema=1,serial=0,players={}} end
    if type(value)~='table' or value.schema~=1 or type(value.serial)~='number' or type(value.players)~='table' then return end
    if value.serial~=math.floor(value.serial) or value.serial<0 or value.serial>=9007199254740991 then return end
    local count,orders=0,{}
    for id,record in pairs(value.players) do
        count=count+1
        if count>256 or type(id)~='string' or #id>80 or type(record)~='table' or type(record.label)~='string' or #record.label>80 then return end
        if record.state=='wanted' then
            local n=record.order
            if type(n)~='number' or n~=math.floor(n) or n<1 or n>value.serial or orders[n] then return end
            orders[n]=true
        elseif record.state~='needed' then return end
    end
    return value
end
function D.details(item)
    local state=D.state(item);if not state then return end
    local result={wanted={},needed={}}
    for id,record in pairs(state.players) do
        local row={identity=id,label=record.label,order=record.order}
        if record.state=='wanted' then result.wanted[#result.wanted+1]=row
        elseif record.state=='needed' then result.needed[#result.needed+1]=row end
    end
    table.sort(result.wanted,function(a,b) return a.order<b.order end)
    table.sort(result.needed,function(a,b) return a.identity<b.identity end)
    return result
end
-- Presentation only: no ownership, collection preference or crafting protection.
-- Needed is global to this item, including another player's entry.
function D.priority(details)
    if not details then return 'none' end
    if #(details.needed or {})>0 then return 'needed' end
    if #(details.wanted or {})>0 then return 'wanted' end
    return 'none'
end
local function reachable(player,item)
    if player:getInventory():getItemWithIDRecursiv(item:getID())==item then return true end
    local container=item:getContainer()
    local seen={}
    while container and container:getContainingItem() do
        if seen[container] then return false end;seen[container]=true
        container=container:getContainingItem():getContainer()
    end
    local obj=container and container:getParent()
    if not obj or not obj.getSquare or not obj.getContainerIndex or not obj.getContainerByIndex then return false end
    local sq=obj:getSquare()
    return container and container:getItemWithIDRecursiv(item:getID())==item and Q.Targets.sameFloor(player,sq) and math.max(math.abs(player:getX()-sq:getX()),math.abs(player:getY()-sq:getY()))<=2
        and Q.Targets.valid(Q.Targets.make(obj,obj:getContainerIndex(container),player),player)
        and Q.RoomAccess.can(player,{obj=obj,container=container},'inspect')
end
function D.transition(player,item,state)
    if isClient() or not reachable(player,item) or (state~='wanted' and state~='needed' and state~='none') then return false end
    local id=Q.Personal.identity(player);local data=D.state(item)
    if not id or not data then return false end
    local old=data.players[id]
    if old and old.state==state then
        if state=='wanted' or state=='needed' then return Q.Personal.establishWish(player,item:getFullType(),state) end
        return true
    end
    if state=='none' then data.players[id]=nil
    else
        local count=0;for _ in pairs(data.players) do count=count+1 end
        if not old and count>=256 then return false end
        local label=player:getDisplayName() or player:getUsername() or ''
        local record={state=state,label=tostring(label):gsub('[<>]',''):sub(1,80)}
        if not Q.Personal.establishWish(player,item:getFullType(),state) then return false end
        if state=='wanted' then
            if data.serial>=9007199254740990 then return false end
            data.serial=data.serial+1;record.order=data.serial
        end
        data.players[id]=record
    end
    item:getModData()[key]=data
    if isServer() then syncItemModData(player,item) end
    return true
end
function D.handle(player,command,args)
    if isClient() then return {status='invalid'} end
    local id=Q.Personal.identity(player);if not id then return {status='identity'} end
    if command=='dibsInspect' then
        if type(args.ids)~='table' or #args.ids==0 or #args.ids>256 then return {status='invalid'} end
        local targets=Q.Targets.reachableAt(player:getCurrentSquare(),player)
        local records={};local seen={}
        for _,nativeID in ipairs(args.ids) do
            if type(nativeID)~='number' or nativeID~=math.floor(nativeID) or seen[nativeID] then return {status='invalid'} end
            seen[nativeID]=true
            local item=player:getInventory():getItemWithIDRecursiv(nativeID)
            for _,target in ipairs(targets) do
                local candidate=target.container:getItemWithIDRecursiv(nativeID)
                if candidate and reachable(player,candidate) then
                    if item and candidate~=item then return {status='ambiguous'} end
                    item=candidate
                end
            end
            if not item or not reachable(player,item) or not D.state(item) then return {status='invalid'} end
            records[#records+1]=item
        end
        local token=Q.Movement.fresh();D.inspections[player]={token=token,time=getTimestampMs(),items=records}
        local rows={};for _,item in ipairs(records) do
            local own=D.state(item).players[id]
            rows[#rows+1]={state=own and own.state or 'none',details=D.details(item)}
        end
        return {status='ok',token=token,rows=rows}
    end
    local inspection=D.inspections[player]
    if command~='dibsChange' or not inspection or args.token~=inspection.token or getTimestampMs()-inspection.time>600000 then return {status='invalid'} end
    if args.state~='wanted' and args.state~='needed' and args.state~='none' then return {status='invalid'} end
    for _,item in ipairs(inspection.items) do if not reachable(player,item) or not D.state(item) then return {status='invalid'} end end
    local changed=0
    for _,item in ipairs(inspection.items) do if D.transition(player,item,args.state) then changed=changed+1 end end
    D.inspections[player]=nil
    return {status=changed==#inspection.items and 'ok' or 'partial',changed=changed}
end
if Events and Events.OnTick then Events.OnTick.Add(function()
    for player,inspection in pairs(D.inspections) do
        if getTimestampMs()-inspection.time>600000 then D.inspections[player]=nil end
    end
end) end
return D
