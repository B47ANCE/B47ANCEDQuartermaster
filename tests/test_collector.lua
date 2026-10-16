-- Client orchestration only; server authority tested in test_consolidated.
B47ANCEDQuartermaster={}
local Q=B47ANCEDQuartermaster
local calls,completions={},{}
local nextCount,progress=0,0
local hud
package.loaded['B47ANCEDQuartermaster/Progress']={
 start=function(num,run,read,owns) hud={num=num,run=run,read=read,owns=owns} end,
 clear=function(num,run) if hud and hud.num==num and hud.run==run then hud=nil end end}

Q.Executor={active={}}
package.loaded['B47ANCEDQuartermaster/Executor']=true
function Q.Executor.acceptOffer(playerNum,offer,callback)
    assert(offer.withdrawal and not offer.destination)
    Q.Executor.active[playerNum]=true
    completions[#completions+1]=function(status) Q.Executor.active[playerNum]=nil;callback(status) end
    return true
end
function Q.Executor.cancel(playerNum) Q.Executor.active[playerNum]=nil end
Q.Authority={request=function(_,command,args,callback)
    calls[#calls+1]=command
    if command=='shoppingBegin' then assert(args.wish=='Base.Nails');callback({status='ok',run='run1',progress={known=true,total=2,completed=0}})
    elseif command=='shoppingNext' then
        nextCount=nextCount+1
        callback(nextCount<=2 and {status='ok',operation='op'..nextCount,withdrawal=true,progress={known=true,total=2,completed=nextCount-1}} or {status='done'})
    else callback({status='ok'}) end
end}
local C=require 'B47ANCEDQuartermaster/Collector'
local result
assert(C.start(0,function(status) result=status end,function() progress=progress+1 end,'Base.Nails'))
assert(not C.start(0,function() end),'concurrent collector accepted')
assert(#completions==1 and hud.owns(hud.run) and hud.read(hud.run).completed==0)
completions[1]('ok');assert(#completions==2 and progress==1 and hud.read(hud.run).completed==1)
completions[2]('ok');assert(result=='done' and progress==2 and not C.active[0] and not hud)
nextCount=0;completions={};result=nil
assert(C.start(0,function(status) result=status end,nil,'Base.Nails'))
C.cancel(0);assert(result=='cancelled' and not C.active[0] and not hud)
completions[1]('ok');assert(nextCount==1,'cancelled collector continued')
local beginReply
Q.Authority.request=function(_,command,args,callback)
    calls[#calls+1]=command
    if command=='shoppingBegin' then beginReply=callback else callback({status='ok'}) end
end
assert(C.start(0,function() end));assert(not hud.read(hud.run).known);C.cancel(0);beginReply({status='ok',run='late'})
assert(calls[#calls]=='shoppingCancel','cancelled pending begin leaked server run')
Q.RoomSort={active={[0]={}}};assert(not C.start(0,function() end),'room sorting and shopping share an actor HUD/executor');Q.RoomSort=nil
assert(not hud,'cancel/late reply left stale HUD')
print('PASS OFFLINE collector driver: sequential withdrawals, authoritative progress notification, cancellation and late begin cleanup')
