dofile(TEST_ROOT..'/fixtures/containers.lua')
require 'B47ANCEDQuartermaster/Targets'
local f=CONTAINER_FIXTURE
local authority=require 'B47ANCEDQuartermaster/Authority'
local handlers={}
Events=setmetatable({}, {__index=function(t,k)
    local e={Add=function(fn) handlers[k]=fn end};rawset(t,k,e);return e
end})
-- Simulate shared Lua loaded before the connection activates.
f.network(false,false)
package.loaded['B47ANCEDQuartermaster/Authority']=nil
local clientAPI=require 'B47ANCEDQuartermaster/Authority'
assert(handlers.OnClientCommand and handlers.OnServerCommand)
f.network(true,false)
local queue={}
function sendClientCommand(player,module,command,args)
    assert(module=='B47ANCEDQuartermaster' and player==f.player)
    queue[#queue+1]={command=command,args=args}
end
local function receive()
    local request=table.remove(queue,1)
    f.network(false,true)
    local result=authority.handle(f.player,request.command,request.args)
    f.network(true,false)
    result.request=request.args.request
    result.protocol=request.args.protocol;result.protocolFamily=require('B47ANCEDQuartermaster/Protocol').family(request.command)
    handlers.OnServerCommand('B47ANCEDQuartermaster','result',result)
    if request.command=='hello' then receive() end
end
local result
-- Wrong-side delivery must not turn client intent into gameplay mutation.
handlers.OnClientCommand('B47ANCEDQuartermaster','commit',f.player,{config={}})
f.network(false,true);handlers.OnServerCommand('B47ANCEDQuartermaster','result',{request=1,status='ok'});f.network(true,false)
clientAPI.request(0,'discover',{scope={x=0,y=0,z=0}},function(r) result=r end)
assert(not result,'client must wait for server discovery')
receive();assert(result.status=='ok')
local session,token=result.session,result.targets[1].token
result=nil
clientAPI.request(0,'load',{session=session,token=token},function(r) result=r end)
assert(not result);receive();assert(result.status=='ok')
local config=B47ANCEDQuartermaster.Schema.copy(result.config);config.priority=6
local before=f.sent();result=nil
clientAPI.request(0,'commit',{session=session,token=token,config=config,revision=0},function(r) result=r end)
assert(not result and f.sent()==before,'intent mutated world locally')
receive();assert(result.status=='ok' and f.sent()==before+1 and f.a.md.B47ANCEDQuartermaster.containers['0'].config.priority==6)
clientAPI.request(0,'load',{session=session,token=token},function(r) result=r end)
f.advance(16000);handlers.OnTick();assert(result.status=='ok','read expired before queued reply grace')
receive();assert(result.status=='ok','queued read acknowledgement dropped after stall')
result=nil
clientAPI.request(0,'load',{session=session,token=token},function(r) result=r end)
for i=1,16 do f.advance(1000);handlers.OnTick() end
assert(result.status=='timeout','genuine read timeout did not expire')
queue={}
result=nil
clientAPI.request(0,'commit',{session=session,token=token,config=config,revision=1},function(r) result=r end)
f.advance(16000);handlers.OnTick();assert(result.status=='uncertain','write timeout falsely established outcome')
queue={}
-- Client session never auto-binds the old local object by coordinates.
require 'B47ANCEDQuartermaster/Session'
local origin=B47ANCEDQuartermaster.Targets.make(f.a,0,f.player)
local s=B47ANCEDQuartermaster.Session.new(origin,0)
s:open(function(r) result=r end);receive()
assert(result=='ChooseTarget' and not s.selected and s.id,'MP auto-bound an unproven local target')
s:select(s.targets[1].target,function(r) result=r end);receive()
assert(result=='ok' and s.selected)
s.selected.working.priority=10
s:save(function(r) result=r end)
assert(s:dirty(s.selected),'clean before ack')
receive();assert(result=='ok' and not s:dirty(s.selected))
local notifications=0
B47ANCEDQuartermaster.onPresetsChanged=function() notifications=notifications+1 end
handlers.OnServerCommand('B47ANCEDQuartermaster','presetsChanged',{revision=3})
handlers.OnServerCommand('foreign','presetsChanged',{revision=4})
assert(notifications==1,'preset invalidation crossed module boundary or was dropped')
f.network(false,false)
print('PASS transport: server discovery, explicit MP selection, deferred writes, ack, timeout, staged clean-after-ack')
-- A fresh connection to an old server must not send a write before discovering
-- compatibility. A rejected HELLO has no gameplay side effect.
local reconnectPlayer={};getSpecificPlayer=function() return reconnectPlayer end
queue={};result=nil;f.network(true,false)
sendClientCommand=function(player,module,command,args)
    assert(player==reconnectPlayer and module=='B47ANCEDQuartermaster')
    queue[#queue+1]={command=command,args=args}
end
clientAPI.request(0,'commit',{session='old',token='old',config=config,revision=0},function(r) result=r end)
assert(#queue==1 and queue[1].command=='hello','write sent before capability negotiation')
local hello=table.remove(queue,1)
handlers.OnServerCommand('B47ANCEDQuartermaster','result',{request=hello.args.request,status='invalid'})
assert(result.status=='ProtocolMismatch' and #queue==0,'old server rejection allowed queued write')
f.network(false,false)
print('PASS OFFLINE protocol handshake prevents writes to an unsupported old server')
