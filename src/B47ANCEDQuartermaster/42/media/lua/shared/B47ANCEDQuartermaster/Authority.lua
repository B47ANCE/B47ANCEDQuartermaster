local Identity=require 'B47ANCEDQuartermaster/Identity'
local Compatibility=require 'B47ANCEDQuartermaster/Compatibility'
require 'B47ANCEDQuartermaster/Bindings'
require 'B47ANCEDQuartermaster/Store'
require 'B47ANCEDQuartermaster/Catalog'
require 'B47ANCEDQuartermaster/Movement'
require 'B47ANCEDQuartermaster/Trips'
require 'B47ANCEDQuartermaster/Presets'
require 'B47ANCEDQuartermaster/Dibs'
require 'B47ANCEDQuartermaster/Shopping'
require 'B47ANCEDQuartermaster/ShoppingAdds'
local S,B,Store=B47ANCEDQuartermaster.Schema,B47ANCEDQuartermaster.Bindings,B47ANCEDQuartermaster.Store
local A={pending={}}
B47ANCEDQuartermaster.Authority=A
local requestID=0
local SortTrace=require 'B47ANCEDQuartermaster/SortTrace'
local Protocol=require 'B47ANCEDQuartermaster/Protocol'
local peers=setmetatable({},{__mode='k'})
local negotiations=setmetatable({},{__mode='k'})
local readOnly={hello=true,discover=true,load=true,presetsList=true,personalList=true,dibsInspect=true}
local tracked={discover=true,load=true,commit=true}
local lastTick
-- Technical admission limits bound expensive read work, not discovery gameplay
-- range. Only the authenticated server player is used as the bucket owner.
local budgets=setmetatable({},{__mode='k'})
local limits={discover={2,0.5},tripDiscover={2,0.5},tripNext={2,4},dibsInspect={2,1},personalList={4,2},shoppingBegin={2,0.5}}
function A.admit(player,command)
    local limit=limits[command];if not limit then return true end
    local time=getTimestampMs();local owner=budgets[player] or {};budgets[player]=owner
    local bucket=owner[command] or {tokens=limit[1],time=time};owner[command]=bucket
    bucket.tokens=math.min(limit[1],bucket.tokens+math.max(0,time-bucket.time)*limit[2]/1000);bucket.time=time
    if bucket.tokens<1 then return false end
    bucket.tokens=bucket.tokens-1;return true
end
function A.cleanup(player)
    if isClient() then return end
    local M=B47ANCEDQuartermaster.Movement
    local run=M.runs[player]
    -- Preserve only an already-observable native withdrawal outcome. No retry,
    -- rollback or inferred credit for an item absent from the exact carrier.
    if run and run.kind=='shopping' then
        for _,op in pairs(run.operations) do
            if op.phase=='take' and op.item:getContainer()==op.carrier and op.carrier:getItemWithID(op.item:getID())==op.item then
                B47ANCEDQuartermaster.Shopping.confirm(player,op)
            end
        end
    end
    B.sessions[player]=nil;M.operations[player]=nil;M.runs[player]=nil
    B47ANCEDQuartermaster.Dibs.inspections[player]=nil;budgets[player]=nil
end
local function trace(message) print('[B47ANCEDQuartermaster] transport '..message) end
local function now() return getTimestampMs() end
local function contents(record)
    local set={}
    local items=record.target.container:getItems()
    for i=0,items:size()-1 do local item=items:get(i);set[item:getDisplayName()]=true end
    return set
end
function A.handle(player,command,args)
    local allowed,_,_,compatibilityStatus=Compatibility.allowed()
    if not allowed then return {status=compatibilityStatus} end
    if isClient() or not player or type(args)~='table' then return {status='invalid'} end
    if command=='hello' then
        local capabilities={};for family,version in pairs(Protocol.versions) do capabilities[family]=version end
        return {status='ok',capabilities=capabilities}
    end
    if isServer() and (command=='commit' or command=='groupChange' or command=='presetChange') and args.taxonomyVersion~=B47ANCEDQuartermaster.Categorizer.version then return {status='TaxonomyPeerMismatch'} end
    if command=='personalList' then return B47ANCEDQuartermaster.Personal.snapshot(player) end
    if command=='shoppingAdd' or command=='shoppingSourceRemove' or command=='shoppingPreference' then
        if B47ANCEDQuartermaster.Movement.runs[player] then return {status='busy'} end
        if command=='shoppingAdd' then return B47ANCEDQuartermaster.ShoppingAdds.handle(player,args) end
        if command=='shoppingSourceRemove' then return B47ANCEDQuartermaster.ShoppingAdds.remove(player,args) end
        return B47ANCEDQuartermaster.ShoppingPreferences.edit(player,args)
    end
    if command=='wishToShopping' then
        if B47ANCEDQuartermaster.Movement.runs[player] then return {status='busy'} end
        return B47ANCEDQuartermaster.Personal.wishToShopping(player,args)
    end
    if command=='personalProject' then
        if B47ANCEDQuartermaster.Movement.runs[player] then return {status='busy'} end
        if args.add then return B47ANCEDQuartermaster.ShoppingAdds.handle(player,args) end
        return B47ANCEDQuartermaster.Personal.project(player,args)
    end
    if command=='personalChange' then
        if B47ANCEDQuartermaster.Movement.runs[player] then return {status='busy'} end
        return B47ANCEDQuartermaster.Personal.change(player,args)
    end
    if type(command)=='string' and command:sub(1,4)=='dibs' then return B47ANCEDQuartermaster.Dibs.handle(player,command,args) end
    if type(command)=='string' and command:sub(1,8)=='shopping' then return B47ANCEDQuartermaster.Shopping.handle(player,command,args) end
    if type(command)=='string' and command:sub(1,4)=='trip' then return B47ANCEDQuartermaster.Trips.handle(player,command,args) end
    if type(command)=='string' and command:sub(1,4)=='move' then
        return B47ANCEDQuartermaster.Movement.handle(player,command,args)
    end
    -- Coordinate/object descriptors are never accepted as target identities.
    if args.target~=nil or args.index~=nil or args.ci~=nil then return {status='invalid'} end
    if command=='discover' then
        local result,err=B.discover(player,args)
        return result or {status=err}
    end
    local session=B.session(player,args.session)
    if not session then return {status='expired'} end
    if command=='presetsList' then
        local library=B47ANCEDQuartermaster.Presets.snapshot()
        return library and {status='ok',library=library} or {status='schema'}
    end
    if command=='close' then B.sessions[player]=nil;return {status='ok'} end
    if command=='viewSelect' then
        local session=B.session(player,args.session);local view=args.view
        if not session or type(view)~='table' then return {status='invalid'} end
        local valid=view.kind=='room' and session.rooms[view.room]~=nil or view.kind=='building' and session.viewInfo.buildingAvailable
            or view.kind=='proximity' and type(view.radius)=='number' and view.radius==math.floor(view.radius) and view.radius>=1 and view.radius<=session.viewInfo.maxRadius
        if not valid then return {status='invalid'} end
        session.appliedView={kind=view.kind,room=view.kind=='room' and view.room or nil,radius=view.kind=='proximity' and view.radius or nil}
        return {status='ok',view=session.appliedView}
    end
    local record=B.target(player,args.session,args.token)
    if not record then return {status='invalid'} end
    if command=='presetChange' then
        local result=B47ANCEDQuartermaster.Presets.change(args,player)
        if result.status=='ok' and isServer() then
            for participant in pairs(B.sessions) do
                sendServerCommand(participant,'B47ANCEDQuartermaster','presetsChanged',{revision=result.library.revision})
            end
        end
        return result
    end
    if command=='groupChange' then
        local result=B47ANCEDQuartermaster.Furniture.change(player,record,args)
        if result.status=='ok' then
            if isServer() and sendServerCommand then for participant in pairs(B.sessions) do sendServerCommand(participant,'B47ANCEDQuartermaster','configurationChanged',{}) end end
            if B47ANCEDQuartermaster.onConfigurationChanged then B47ANCEDQuartermaster.onConfigurationChanged() end
        end
        return result
    end
    if command=='load' then
        if args.whole or B47ANCEDQuartermaster.Furniture.state(record.target) then
            local config,err,revision,info=B47ANCEDQuartermaster.Furniture.load(record.target,player,args.whole==true,true)
            if not config then return {status=err} end
            local observed,error=B47ANCEDQuartermaster.Catalog.observed(record.target.container);if not observed then return {status=error} end
            return {status='ok',config=config,revision=revision,mode=info.mode,groupActive=info.active,parentConfig=info.parentConfig,contents=contents(record),observed=observed}
        end
        local config,err,revision=Store.load(record.target,player)
        if not config then return {status=err} end
        record.original,record.revision=config,revision
        local observed,err=B47ANCEDQuartermaster.Catalog.observed(record.target.container)
        if not observed then return {status=err} end
        return {status='ok',token=record.token,config=S.copy(record.original),revision=record.revision,contents=contents(record),observed=observed}
    elseif command=='commit' then
        if not record.original or not S.valid(args.config) then return {status='invalid'} end
        if args.revision~=record.revision then return {status='conflict'} end
        local config,err=Store.commit(record,args.config,player)
        return config and {status='ok',config=config,revision=record.revision} or {status=err}
    end
    return {status='invalid'}
end
function A.request(playerNum,command,args,callback)
    local allowed,_,_,compatibilityStatus=Compatibility.allowed()
    if not allowed then callback({status=compatibilityStatus});return end
    local player=getSpecificPlayer(playerNum)
    if isClient() and command~='hello' then
        if not player then callback({status='invalid'});return end
        if not peers[player] then
            local waiting=negotiations[player]
            if waiting then waiting[#waiting+1]={command=command,args=args,callback=callback};return end
            waiting={{command=command,args=args,callback=callback}};negotiations[player]=waiting
            A.request(playerNum,'hello',{trace=args and args.trace},function(result)
                negotiations[player]=nil
                if result.status=='ok' and type(result.capabilities)=='table' and getSpecificPlayer(playerNum)==player then peers[player]=result.capabilities end
                for _,request in ipairs(waiting) do
                    if peers[player] then A.request(playerNum,request.command,request.args,request.callback)
                    else request.callback({status=result.status=='timeout' and 'timeout' or 'ProtocolMismatch'}) end
                end
            end)
            return
        end
        local family=Protocol.family(command)
        if not family or peers[player][family]~=Protocol.version(command) then callback({status='ProtocolMismatch'});return end
    end
    requestID=requestID+1
    -- Payloads are created by our client session, never arbitrary recursive UI tables.
    args=args or {};args.request=requestID;args.taxonomyVersion=B47ANCEDQuartermaster.Categorizer.version;args.protocol=Protocol.version(command)
    if not isClient() then
        local measured=SortTrace.begin()
        local ok,result=pcall(A.handle,getSpecificPlayer(playerNum),command,args)
        if args.trace then SortTrace.emit(args.trace,'LOCAL_HANDLER',command,nil,nil,measured) end
        if tracked[command] then trace('local '..command..' status='..tostring(ok and result.status or 'failed')) end
        if not ok then trace('local handler failed '..tostring(command)..' error='..tostring(result)) end
        callback(ok and result or {status='failed'});return
    end
    A.pending[requestID]={callback=callback,time=now(),command=command,protocol=Protocol.version(command),trace=args.trace,measured=SortTrace.begin()}
    if not lastTick then lastTick=now() end
    if tracked[command] then trace('send '..command..' request='..requestID) end
    local ok=pcall(sendClientCommand,getSpecificPlayer(playerNum),'B47ANCEDQuartermaster',command,args)
    if not ok then A.pending[requestID]=nil;callback({status='failed'}) end
end
-- This is deliberately unavailable in MP; Lua/Java object references are not portable identities.
function A.localTarget(playerNum,session,token)
    if isClient() then return end
    local record=B.target(getSpecificPlayer(playerNum),session,token)
    return record and record.target
end
if Events and not select(2,Compatibility.allowed()) then
    -- Shared Lua may load before a connection. Register both event contracts;
    -- determine the execution side at dispatch, never grant client authority.
    Events.OnClientCommand.Add(function(module,command,player,args)
            if isClient() or module~='B47ANCEDQuartermaster' then return end
            local started=now()
            local measured=SortTrace.begin()
            local operation=type(args)=='table' and (args.trace or args.operation or args.run)
            SortTrace.emit(operation,'REQUEST_RECEIVED',command)
            if tracked[command] then trace('receive '..command..' request='..tostring(type(args)=='table' and args.request)) end
            local ok,result=true,{status='rateLimited'}
            if not Protocol.accepts(command,args) then result={status='ProtocolMismatch'}
            elseif player and A.admit(player,command) then
                SortTrace.emit(operation,'SERVER_ADMISSION','accepted',command,nil,measured)
                measured=SortTrace.begin()
                ok,result=pcall(A.handle,player,command,args)
            else SortTrace.emit(operation,'SERVER_ADMISSION','rateLimited',command,nil,measured) end
            if not ok then trace('handler failed '..tostring(command)..': '..tostring(result)) end
            result=ok and result or {status='failed'}
            result.serverVersion=Identity.version
            result.protocol=Protocol.version(command);result.protocolFamily=Protocol.family(command)
            SortTrace.emit(operation,'SERVER_HANDLER',result.status,command,nil,measured)
            SortTrace.emit(operation,'RESPONSE_SENT',result.status,command)
            if tracked[command] then trace('reply '..command..' status='..tostring(result.status)..' elapsedMs='..(now()-started)) end
            result.request=type(args)=='table' and args.request or nil
            sendServerCommand(player,'B47ANCEDQuartermaster','result',result)
        end)
    Events.OnServerCommand.Add(function(module,command,args)
            if not isClient() or module~='B47ANCEDQuartermaster' or type(args)~='table' then return end
            if command=='configurationChanged' then
                if B47ANCEDQuartermaster.onConfigurationChanged then B47ANCEDQuartermaster.onConfigurationChanged() end
                return
            end
            if command=='presetsChanged' then
                if B47ANCEDQuartermaster.onPresetsChanged then B47ANCEDQuartermaster.onPresetsChanged() end
                return
            end
            if command~='result' then return end
            local waiting=A.pending[args.request]
            if waiting then
                A.pending[args.request]=nil
                if waiting.trace then SortTrace.emit(waiting.trace,'TRANSPORT_ROUNDTRIP',args.status,waiting.command,args.request,waiting.measured) end
                if args.status=='ok' and (args.protocol~=waiting.protocol or args.protocolFamily~=Protocol.family(waiting.command)) then
                    args.status='ProtocolMismatch'
                end
                if tracked[waiting.command] then trace('ack '..waiting.command..' request='..args.request..' status='..tostring(args.status)..' elapsedMs='..(now()-waiting.time)..' serverVersion='..tostring(args.serverVersion or 'legacy')) end
                waiting.callback(args)
            end
        end)
    trace('handlers registered version='..Identity.version)
    local nextSweep=0
    Events.OnTick.Add(function()
        local tick=now();local gap=lastTick and tick-lastTick or 0;lastTick=tick
        if tick<nextSweep then return end
        nextSweep=tick+1000
        if isServer() and type(getOnlinePlayers)=='function' then
            local online=getOnlinePlayers();local live={}
            for i=0,online:size()-1 do live[online:get(i)]=true end
            local stale={}
            for _,state in ipairs({B.sessions,B47ANCEDQuartermaster.Movement.operations,B47ANCEDQuartermaster.Movement.runs,B47ANCEDQuartermaster.Dibs.inspections}) do
                for player in pairs(state) do
                    if not live[player] or (player.isDead and player:isDead()) then stale[player]=true end
                end
            end
            for player in pairs(stale) do A.cleanup(player) end
        end
        local expired={}
        for id,r in pairs(A.pending) do
            if tick-r.time>15000 then
                -- One read-only grace after a blocked event loop allows queued
                -- acknowledgements to dispatch. Never replay a write or infer success.
                if readOnly[r.command] and gap>2000 and not r.grace then r.grace=tick+1000
                elseif not r.grace or tick>=r.grace then expired[#expired+1]=id end
            end
        end
        for _,id in ipairs(expired) do
            local r=A.pending[id];A.pending[id]=nil
            if r.trace then SortTrace.emit(r.trace,'TRANSPORT_TIMEOUT',r.command,nil,id,r.measured) end
            local status=readOnly[r.command] and 'timeout' or 'uncertain'
            trace('timeout '..tostring(r.command)..' request='..id..' elapsedMs='..(tick-r.time)..' status='..status)
            r.callback({status=status})
        end
        for player,s in pairs(B.sessions) do if now()-s.time>1800000 then B.sessions[player]=nil end end
    end)
end
return A
