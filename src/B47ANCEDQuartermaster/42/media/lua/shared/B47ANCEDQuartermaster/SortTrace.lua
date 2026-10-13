B47ANCEDQuartermaster = B47ANCEDQuartermaster or {}
local Trace={}
-- Diagnostics only. These are output/memory safety limits, not gameplay settings.
local records,order={},{}
local window,lines=0,0
local function clock() return getTimestampMs() end
function Trace.begin()
    if B47ANCEDQuartermaster.SortTraceEnabled==true then return clock() end
end
local function clean(value)
    return tostring(value or '-'):gsub('[^%w_:%.-]','?'):sub(1,160)
end
function Trace.emit(id,stage,outcome,reason,target,started,count,cache)
    if B47ANCEDQuartermaster.SortTraceEnabled~=true then return end
    local now=clock()
    if now<window or now-window>=1000 then window,lines=now,0 end
    if lines>=512 then return end
    id=clean(id)
    local record=records[id]
    if not record then
        if #order>=32 then records[table.remove(order,1)]=nil end
        record={origin=now,lines=0};records[id]=record;order[#order+1]=id
    end
    if record.lines>=192 then return end
    record.lines=record.lines+1;lines=lines+1
    if record.lines==192 then stage,outcome='TRACE_LIMIT','operation'
    elseif lines==512 then stage,outcome='TRACE_LIMIT','aggregate' end
    local elapsed=now-record.origin
    local duration=type(started)=='number' and now-started or nil
    -- GlobalObject.getTimestampMs uses System.currentTimeMillis in the installed
    -- runtime. Label it honestly; negative elapsed values are invalid evidence.
    local clockState=(elapsed<0 or duration and duration<0) and 'discontinuity' or 'wall'
    local side=isServer() and 'server' or isClient() and 'client' or 'local'
    print('[B47QM SORT TRACE] '..side..' operation='..id..' stage='..clean(stage)..' outcome='..clean(outcome)..' reason='..clean(reason)..' target='..clean(target)..' elapsedMs='..clean(elapsed>=0 and elapsed or 'unknown')..' durationMs='..clean(duration and duration>=0 and duration or 'unknown')..' clock='..clockState..' count='..clean(count)..' cache='..clean(cache))
end
function Trace.observe(id,player)
    if B47ANCEDQuartermaster.SortTraceEnabled~=true then return end
    local record=records[clean(id)]
    if not record or record.moved then return end
    local x,y=player:getX(),player:getY()
    if not record.x then record.x,record.y=x,y
    elseif (x-record.x)^2+(y-record.y)^2>0.0001 then
        record.moved=true;Trace.emit(id,'FIRST_POSITION_CHANGE','observed')
    end
end
-- A terminal programming error is recorded once even when verbose tracing is
-- disabled. No item/player labels, payload dump or repeated per-frame output.
function Trace.failure(id,stage,err)
    local side=isServer() and 'server' or isClient() and 'client' or 'local'
    print('[B47QM ERROR] '..side..' operation='..clean(id)..' stage='..clean(stage)..' reason='..clean(err))
end
return Trace
