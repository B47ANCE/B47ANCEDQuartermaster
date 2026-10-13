-- Focused offline regression; does not certify native rendering or MP.
dofile(TEST_ROOT..'/fixtures/containers.lua')
local f=CONTAINER_FIXTURE
local T=require 'B47ANCEDQuartermaster/Targets'
for _,z in ipairs({0,.1,.99}) do f.player.getZ=function() return z end;assert(T.sameFloor(f.player,f.a.sq)) end
for _,z in ipairs({-0.1,1,1.1,math.huge,0/0}) do f.player.getZ=function() return z end;assert(not T.sameFloor(f.player,f.a.sq)) end
f.player.getZ=function() return 0 end
local handlers={}
Events=setmetatable({}, {__index=function(t,k) local e={Add=function(fn) handlers[k]=fn end};rawset(t,k,e);return e end})
local A=require 'B47ANCEDQuartermaster/Authority'
local Q=B47ANCEDQuartermaster;local Protocol=require 'B47ANCEDQuartermaster/Protocol'
f.network(false,true)
local reply
sendServerCommand=function(_,_,_,result) reply=result end
handlers.OnClientCommand('B47ANCEDQuartermaster','discover',f.player,{scope={x=0,y=0,z=0},protocol=999,request=1})
assert(reply.status=='ProtocolMismatch' and not Q.Bindings.sessions[f.player])
local args={scope={x=0,y=0,z=0},protocol=Protocol.version('discover'),request=2}
handlers.OnClientCommand('B47ANCEDQuartermaster','discover',f.player,args);assert(reply.status=='ok')
handlers.OnClientCommand('B47ANCEDQuartermaster','discover',f.player,args);assert(reply.status=='ok')
handlers.OnClientCommand('B47ANCEDQuartermaster','discover',f.player,args);assert(reply.status=='rateLimited')
assert(A.admit({},'discover'),'another player inherited rate bucket')
f.advance(2000);assert(A.admit(f.player,'discover'),'budget did not recover')
assert(Protocol.accepts('movePut',{protocol=Protocol.version('movePut')}) and not Protocol.accepts('movePut',{protocol=1}) and not Protocol.accepts('movePut',{}) and not Protocol.accepts('bad',{protocol=1}))
local C=require 'B47ANCEDQuartermaster/Compatibility'
local active=getActivatedMods;getActivatedMods=nil;C.invalidate()
assert(not C.allowed() and A.handle(f.player,'discover',args).status=='CompatibilityUnknown')
getActivatedMods=active;C.invalidate();assert(C.allowed())
local persistent=ModData.getOrCreate('B47ANCEDQuartermaster');persistent.testSentinel=true
Q.Dibs.inspections[f.player]={token='old'};Q.Movement.runs[f.player]={kind='sort',operations={}};Q.Movement.operations[f.player]={}
getOnlinePlayers=function() return f.list({}) end
f.advance(1000);handlers.OnTick()
assert(not Q.Bindings.sessions[f.player] and not Q.Dibs.inspections[f.player] and not Q.Movement.runs[f.player] and not Q.Movement.operations[f.player])
assert(persistent.testSentinel,'cleanup erased persistent lists/root')
print('PASS OFFLINE dev.18 floor boundaries, network protocol rejection, read admission/fairness/recovery, unknown compatibility and disconnected ephemeral cleanup')

