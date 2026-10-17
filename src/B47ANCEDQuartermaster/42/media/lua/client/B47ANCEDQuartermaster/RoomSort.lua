-- Multi-source orchestration only; existing Sorter/Trips/Movement own each move.
require 'B47ANCEDQuartermaster/Sorter'
local Q=B47ANCEDQuartermaster
local R={active={}};Q.RoomSort=R
local Progress=require 'B47ANCEDQuartermaster/Progress'
local function progress(run)
 local total=run.sources and #run.sources or 0;local completed=run.index-1
 local child=Q.Sorter.active[run.playerNum]
 if child and child.area then
  local state=Q.Sorter.progress(child)
  if state.known and state.total>0 then completed=completed+state.completed/state.total end
 end
 return {known=run.sources~=nil,total=total,completed=math.min(total,completed),
  label=run.view.kind=='building' and 'UI_B47_ProgressSortBuilding' or 'UI_B47_ProgressSortRoom'}
end
local serial=0
local function close(run,status)
 if run.closed then return end
 run.closed=true;R.active[run.playerNum]=nil
 Progress.clear(run.playerNum,run)
 if run.callback then run.callback(status,run.completed,run.skipped,run.skipReasons) end
end
function R.cancel(playerNum)
 local run=R.active[playerNum];if not run then return end
 close(run,'cancelled');Q.Sorter.cancel(playerNum)
end
function R.start(playerNum,view,callback)
 local player=getSpecificPlayer(playerNum)
 if Q.Collector and Q.Collector.active[playerNum] then return false end
 if not player or R.active[playerNum] or Q.Sorter.active[playerNum] or Q.Executor.active[playerNum] or Q.Executor.batches[playerNum]
  or #ISTimedActionQueue.getTimedActionQueue(player).queue>0 or not view or (view.kind~='customRoom' and view.kind~='building') or isGamePaused and isGamePaused() then return false end
 serial=serial+1
 R.active[playerNum]={playerNum=playerNum,player=player,view=view,nonce=tostring(getTimestampMs())..':'..serial,
  callback=callback,time=getTimestampMs(),completed=0,skipped=0,index=1,nextAt=0}
 Progress.start(playerNum,R.active[playerNum],progress,function(r) return R.active[playerNum]==r end)
 return true
end
function R.tick()
 for num,run in pairs(R.active) do
  if run.player~=getSpecificPlayer(num) or run.player:isDead() or getTimestampMs()-run.time>1800000 then R.cancel(num)
  elseif not run.busy and getTimestampMs()>=run.nextAt then
   if not run.discovery then
    run.busy=true;run.nextAt=getTimestampMs()+500
    local sq=run.player:getCurrentSquare()
    Q.Authority.request(num,'areaDiscover',{areaView=run.view,roomScan=run.nonce,sources=true,scope={x=sq:getX(),y=sq:getY(),z=sq:getZ()}},function(r)
     run.busy=false;if run.closed then return end
     if r.status=='waiting' or r.status=='rateLimited' or r.status=='busy' then
      if getTimestampMs()-run.time>30000 then close(run,'RoomPermissionUnavailable') end;return
     end
     if r.status~='ok' then close(run,r.status);return end
     run.discovery=r;run.sources={};local seen={}
     for _,m in ipairs(r.sources or {}) do local identity=m.identity;local key=m.source or identity and (identity.instance..':'..identity.ci)
      if not key then close(run,'invalid');return end
      if not seen[key] then seen[key]=true;run.sources[#run.sources+1]=m end
     end
    end)
   else
    local meta=run.sources[run.index]
    if not meta then close(run,'ok') else
     local source
     if meta.source=='inventory' then source=run.player:getInventory()
     elseif meta.source then local id=meta.source:match('^bag:(%d+)$');source=id and Q.Movement.carrier(run.player,tonumber(id))
     else local target=Q.Executor.resolve(meta.identity,run.player);source=target and target.container end
     if not source then
      run.waitStarted=run.waitStarted or getTimestampMs();if getTimestampMs()-run.waitStarted>15000 then close(run,'invalid') end
     else
      run.waitStarted=nil;run.busy=true
      local started=Q.Sorter.start(num,source,function(status,completed,skipped,reasons)
       if run.closed then return end
       run.skipReasons=run.skipReasons or {}
       for key,n in pairs(reasons or {}) do run.skipReasons[key]=(run.skipReasons[key] or 0)+n end
       run.completed=run.completed+completed;run.skipped=run.skipped+skipped;run.busy=false;run.index=run.index+1
       if status~='ok' then close(run,status) end
      end,{area=true,sweep=run.discovery.sweep,discovery=run.discovery})
      if not started then close(run,'busy') end
     end
    end
   end
  end
 end
end
if Events and Events.OnTick then Events.OnTick.Add(R.tick) end
if Events and Events.OnDisconnect then Events.OnDisconnect.Add(function() for num in pairs(R.active) do R.cancel(num) end end) end
return R
