-- Multi-source orchestration only; existing Sorter/Trips/Movement own each move.
require 'B47ANCEDQuartermaster/Sorter'
local Q=B47ANCEDQuartermaster
local R={active={}};Q.RoomSort=R
local serial=0
local function close(run,status)
 if run.closed then return end
 run.closed=true;R.active[run.playerNum]=nil
 if run.callback then run.callback(status,run.completed,run.skipped) end
end
function R.cancel(playerNum)
 local run=R.active[playerNum];if not run then return end
 close(run,'cancelled');Q.Sorter.cancel(playerNum)
end
function R.start(playerNum,view,callback)
 local player=getSpecificPlayer(playerNum)
 if not player or R.active[playerNum] or Q.Sorter.active[playerNum] or Q.Executor.active[playerNum] or Q.Executor.batches[playerNum]
  or #ISTimedActionQueue.getTimedActionQueue(player).queue>0 or not view or view.kind~='customRoom' or isGamePaused and isGamePaused() then return false end
 serial=serial+1
 R.active[playerNum]={playerNum=playerNum,player=player,view=view,nonce=tostring(getTimestampMs())..':'..serial,
  callback=callback,time=getTimestampMs(),completed=0,skipped=0,index=1,nextAt=0};return true
end
function R.tick()
 for num,run in pairs(R.active) do
  if not run.busy and getTimestampMs()>=run.nextAt then
   if run.player~=getSpecificPlayer(num) or run.player:isDead() or getTimestampMs()-run.time>1800000 then R.cancel(num)
   elseif not run.discovery then
    run.busy=true;run.nextAt=getTimestampMs()+500
    local sq=run.player:getCurrentSquare()
    Q.Authority.request(num,'roomDiscover',{customRoom=run.view.room,roomRevision=run.view.revision,roomScan=run.nonce,sources=true,scope={x=sq:getX(),y=sq:getY(),z=sq:getZ()}},function(r)
     run.busy=false;if run.closed then return end
     if r.status=='waiting' or r.status=='rateLimited' then return end
     if r.status~='ok' then close(run,r.status);return end
     run.discovery=r;run.sources={};local seen={}
     for _,m in ipairs(r.sources or {}) do local identity=m.identity;local key=identity.instance..':'..identity.ci
      if not seen[key] then seen[key]=true;run.sources[#run.sources+1]=m end
     end
    end)
   else
    local meta=run.sources[run.index]
    if not meta then close(run,'ok') else
     local target=Q.Executor.resolve(meta.identity,run.player)
     if not target then
      run.waitStarted=run.waitStarted or getTimestampMs();if getTimestampMs()-run.waitStarted>15000 then close(run,'invalid') end
     else
      run.waitStarted=nil;run.busy=true
      local started=Q.Sorter.start(num,target.container,function(status,completed,skipped)
       if run.closed then return end
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
