-- Actual standalone API and Quartermaster production paths, disposable host only.
dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
package.path=ROOMS_SOURCE..'/shared/?.lua;'..package.path
local f=CONTAINER_FIXTURE;f.network(false,true)
getActivatedMods=function() return f.list({'B47ANCEDQuartermaster','B47ANCEDRooms'}) end
local notifications={};sendServerCommand=function(player,module,command,args) notifications[#notifications+1]={player=player,module=module,command=command,args=args} end
getTimestamp=function() return math.floor(getTimestampMs()/1000) end
local serial=0;getRandomUUID=function() serial=serial+1;return '12345678-1234-1234-1234-'..string.format('%012d',serial) end
local owner='fixture-player';local members={B=true,C=true}
local h={getId=function() return 'H1' end,getOwner=function() return owner end,getX=function() return -1 end,getY=function() return -1 end,getX2=function() return 10 end,getY2=function() return 10 end}
function h:getPlayers() local t={};for who in pairs(members) do t[#t+1]=who end;local a=f.list(t);a.contains=function(_,who) return members[who] end;return a end
SafeHouse.getSafehouseList=function() return f.list({h}) end
SafeHouse.getSafeHouse=function() error('stable house IDs cannot use title overload') end
local API=require 'B47ANCEDRooms/API';local R=B47ANCEDRooms.Registry
local A=require 'B47ANCEDQuartermaster/Authority';local Q=B47ANCEDQuartermaster
getOnlinePlayers=function() return f.list({f.player}) end
local nonce=0
local function write(args)
 local lease=API.beginEdit(f.player);nonce=nonce+1;args.revision=lease.revision;args.editKey=lease.editKey;args.nonce='integration:'..nonce;args.confirm=true
 local r=API.change(f.player,args)
 for _=1,100 do if r.status~='pending' then assert(r.status=='ok',r.status);return end;R.tick();f.advance(16);r=R.handle(f.player,'roomPoll',{nonce=args.nonce}) end
 error('integration room write stalled')
end
write({action='save',name='Private',rows={{0,0,0,0}}})
local id=API.listRooms(f.player).rooms[1].id
write({action='assign',id=id,roomRevision=1,assigned='B'})
write({action='policy',id=id,roomRevision=2,policy={mode='private',rules={},grants={}}})
assert(not Q.Targets.make(f.a,0,f.player),'private target descriptor disclosed to parent owner')
local result=assert(Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}}))
for _,m in ipairs(result.targets) do assert(m.x~=0 or m.y~=0,'hidden target exposed') end
assert(result.discoveryStats.candidateObjects==#result.targets,'aggregate leaked hidden world counts')
-- Deposit-only users can route through server-owned settings without inspecting
-- private contents; configure-only users can edit settings without item counts.
local policy={mode='private',rules={},grants={['fixture-player']={discover=true,deposit=true}}}
write({action='policy',id=id,roomRevision=3,policy=policy})
result=assert(Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}}))
local target,record
for _,m in ipairs(result.targets) do local r=Q.Bindings.target(f.player,result.session,m.token);if r.target.obj==f.a then record=r;target=r.target end end
assert(target and Q.Store.routing(target,f.player))
assert(not Q.Store.load(target,f.player) and not Q.RoomAccess.can(f.player,target,'withdraw'))
assert(A.handle(f.player,'load',{session=result.session,token=record.token}).status=='RoomAccessDenied')
policy.grants['fixture-player'].configure=true
write({action='policy',id=id,roomRevision=4,policy=policy})
local reads=0;local container=target.container;local items=container.getItems
container.getItems=function() reads=reads+1;return items() end
local loaded=A.handle(f.player,'load',{session=result.session,token=record.token})
assert(loaded.status=='ok' and loaded.restrictedContents and reads==0,'configuration action exposed private contents')
assert(not Q.RoomAccess.can(f.player,target,'withdraw'))
local begin=Q.Trips.handle(f.player,'tripBegin',{session=result.session,source=record.token})
assert(begin.status=='RoomAccessDenied' and reads==0,'ordinary container Sort inspected restricted contents before authorization')
-- A stale permission grant cannot survive the next authoritative validation.
policy.grants['fixture-player'].deposit=false
write({action='policy',id=id,roomRevision=5,policy=policy})
assert(not Q.Store.routing(target,f.player))
assert(#notifications>0 and notifications[#notifications].command=='roomsChanged','Quartermaster-only UI subscription missed Rooms invalidation')
local stale=Q.Movement.withdraw(f.player,record,0,{item={}})
assert(stale.status=='invalid','Shopping withdrawal bypassed room action check')
-- Service mismatch fails closed, while absence retains ordinary vanilla behavior.
local saved=B47ANCEDRooms.API;B47ANCEDRooms.API={version=99,ready=true}
assert(not Q.Targets.make(f.a,0,f.player))
B47ANCEDRooms.API=saved
assert(Q.RoomAccess.can(f.player,{obj=f.b,container=f.b.containers[1]},'deposit'),'unprotected storage was blocked')
print('PASS OFFLINE actual Rooms integration: descriptor privacy, hidden-count filtering, deposit-only routing, configure-only/no contents, withdrawal denial, live revocation, service mismatch and authorized outside storage')
