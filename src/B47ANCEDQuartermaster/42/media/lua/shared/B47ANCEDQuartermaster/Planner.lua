require 'B47ANCEDQuartermaster/Bindings'
require 'B47ANCEDQuartermaster/Store'
require 'B47ANCEDQuartermaster/Catalog'
local P={}
local Trace=require 'B47ANCEDQuartermaster/SortTrace'
B47ANCEDQuartermaster.Planner=P
-- Server/SP planning primitive, not a network command or movement implementation.
-- Callers provide an authoritative inventory item, authoritative preset definitions,
-- and the transfer-specific access/capacity predicate. No client rule/category input.
function P.prepare(player,sessionID,presets,trace)
    if isClient() then return nil,'invalid' end
    local B,Store=B47ANCEDQuartermaster.Bindings,B47ANCEDQuartermaster.Store
    local session=B.session(player,sessionID)
    if not session then return nil,'expired' end
    local candidates={}
    local measured=Trace.begin()
    for token in pairs(session.records) do
        local record=B.target(player,sessionID,token)
        if record and B47ANCEDQuartermaster.RoomAccess.can(player,record.target,'deposit') then
            local config=Store.routing(record.target,player)
            if config then
                local rulesReady=true
                for key,link in pairs(config.presets) do
                    if not B47ANCEDQuartermaster.Schema.resolves((presets or {})[key],link) then rulesReady=false;break end
                end
                local t=record.target
                local sq=t.obj:getSquare()
                local dx,dy=sq:getX()-player:getX(),sq:getY()-player:getY()
                local dz=sq:getZ()-player:getZ()
                candidates[#candidates+1]={key=token,target=t,container=t.container,config=config,
                    effective=B47ANCEDQuartermaster.Schema.effective(config,presets or {}),rulesReady=rulesReady,distance=dx*dx+dy*dy+dz*dz}
            end
        end
    end
    Trace.emit(trace,'CANDIDATE_VALIDATION','complete',nil,nil,measured,#candidates,'uncached')
    return {player=player,session=sessionID,candidates=candidates}
end
function P.choose(player,sessionID,item,presets,accepts,trace,prepared)
    if isClient() or type(accepts)~='function' or not item then return nil,'invalid' end
    local B=B47ANCEDQuartermaster.Bindings
    -- Prepared data is server-local and lives only for one synchronous batch.
    -- Never retain permission/capacity decisions or accept it from network args.
    if prepared and (prepared.player~=player or prepared.session~=sessionID) then return nil,'invalid' end
    local batch,err=prepared,nil
    if not batch then batch,err=P.prepare(player,sessionID,presets,trace) end
    if not batch then return nil,err end
    local candidates=batch.candidates
    local rulesAt=Trace.begin()
    local choice,matched=B47ANCEDQuartermaster.Catalog.destination(item,candidates,presets,function(candidate,actualItem)
        -- Recheck identity and authorization immediately before eligibility evaluation.
        return B.target(player,sessionID,candidate.key)~=nil and B47ANCEDQuartermaster.RoomAccess.can(player,candidate.target,'deposit') and accepts(candidate.target,actualItem,candidate)==true
    end)
    Trace.emit(trace,'RULE_RESOLUTION',choice and 'matched' or 'no-match',nil,nil,rulesAt,#candidates)
    return choice,not choice and (matched==0 and 'noMatchingRule' or 'destinationRejected') or nil
end
return P
