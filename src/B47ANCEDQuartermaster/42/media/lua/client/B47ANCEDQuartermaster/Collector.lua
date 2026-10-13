require 'B47ANCEDQuartermaster/Executor'
local Q=B47ANCEDQuartermaster
local C={active={}};Q.Collector=C
local function endRun(run,status)
    if run.closed then return end
    run.closed=true;C.active[run.playerNum]=nil
    Q.Executor.cancel(run.playerNum)
    if run.id then Q.Authority.request(run.playerNum,'shoppingCancel',{run=run.id},function() end) end
    if run.callback then run.callback(status) end
end
function C.cancel(playerNum) local run=C.active[playerNum];if run then endRun(run,'cancelled') end end
local function nextItem(run)
    if run.closed then return end
    Q.Authority.request(run.playerNum,'shoppingNext',{run=run.id},function(result)
        if run.closed then
            if result.operation then Q.Authority.request(run.playerNum,'moveCancel',{operation=result.operation},function() end) end
            return
        end
        if result.status~='ok' then endRun(run,result.status);return end
        if not Q.Executor.acceptOffer(run.playerNum,result,function(status)
            if status=='cancelled' or status=='uncertain' then endRun(run,status)
            else
                if status=='ok' and run.onProgress then run.onProgress() end
                nextItem(run)
            end
        end) then
            Q.Authority.request(run.playerNum,'moveCancel',{operation=result.operation},function() end)
            endRun(run,'busy')
        end
    end)
end
function C.start(playerNum,callback,onProgress,wish,list)
    if C.active[playerNum] or Q.Executor.active[playerNum] or (Q.Sorter and Q.Sorter.active[playerNum]) then return false end
    local run={playerNum=playerNum,callback=callback,onProgress=onProgress};C.active[playerNum]=run
    Q.Authority.request(playerNum,'shoppingBegin',{wish=wish,list=list},function(result)
        if run.closed then
            if result.run then Q.Authority.request(playerNum,'shoppingCancel',{run=result.run},function() end) end
            return
        end
        if result.status~='ok' then endRun(run,result.status);return end
        run.id=result.run;nextItem(run)
    end)
    return true
end
return C
