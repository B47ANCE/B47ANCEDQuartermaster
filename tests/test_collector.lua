-- Client orchestration only; server authority tested in test_consolidated.
B47ANCEDQuartermaster={}
local Q=B47ANCEDQuartermaster
local calls,completions={},{}
local nextCount,progress=0,0
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
    if command=='shoppingBegin' then assert(args.wish=='Base.Nails');callback({status='ok',run='run1'})
    elseif command=='shoppingNext' then
        nextCount=nextCount+1
        callback(nextCount<=2 and {status='ok',operation='op'..nextCount,withdrawal=true} or {status='done'})
    else callback({status='ok'}) end
end}
local C=require 'B47ANCEDQuartermaster/Collector'
local result
assert(C.start(0,function(status) result=status end,function() progress=progress+1 end,'Base.Nails'))
assert(not C.start(0,function() end),'concurrent collector accepted')
assert(#completions==1)
completions[1]('ok');assert(#completions==2 and progress==1)
completions[2]('ok');assert(result=='done' and progress==2 and not C.active[0])
nextCount=0;completions={};result=nil
assert(C.start(0,function(status) result=status end,nil,'Base.Nails'))
C.cancel(0);assert(result=='cancelled' and not C.active[0])
completions[1]('ok');assert(nextCount==1,'cancelled collector continued')
local beginReply
Q.Authority.request=function(_,command,args,callback)
    calls[#calls+1]=command
    if command=='shoppingBegin' then beginReply=callback else callback({status='ok'}) end
end
assert(C.start(0,function() end));C.cancel(0);beginReply({status='ok',run='late'})
assert(calls[#calls]=='shoppingCancel','cancelled pending begin leaked server run')
print('PASS OFFLINE collector driver: sequential withdrawals, authoritative progress notification, cancellation and late begin cleanup')
