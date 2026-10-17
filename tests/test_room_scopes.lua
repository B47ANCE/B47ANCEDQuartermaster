dofile(TEST_ROOT..'/fixtures/containers.lua')
dofile(TEST_ROOT..'/fixtures/catalog.lua')
local Session=require 'B47ANCEDQuartermaster/Session'
local Q=B47ANCEDQuartermaster
local f=CONTAINER_FIXTURE;local R=Q.Rooms;local A=Q.Authority;local G=Q.RoomGeometry
getRandomUUID=function() return '11111111-1111-1111-1111-111111111111' end
getTimestamp=function() return math.floor(getTimestampMs()/1000) end
function getText(k,...) return k end
local nonce=0
local function write(fields)
 local snap=A.handle(f.player,'roomList',{});nonce=nonce+1
 local args={nonce='write:'..nonce,editKey=snap.editKey,action='save',revision=snap.revision,name='Storage',rows={{0,0,0,0}}}
 for k,v in pairs(fields or {}) do args[k]=v end
 assert(A.handle(f.player,'roomChange',args).status=='pending')
 for _=1,20 do R.tick();f.advance(16);local r=A.handle(f.player,'roomPoll',{nonce=args.nonce});if r.status~='pending' then assert(r.status=='ok');return end end
 error('save did not complete')
end
write();local id=R.metadata(f.player)[1].id
local s=Session.new(Q.Targets.make(f.a,0,f.player),0);local status
s:open(function(r) status=r end);assert(status=='ok')
local originalSession=s.id;local hidden
for _,record in ipairs(s.targets) do if record.target.obj==f.b then hidden=record.token end end
s:setView({kind='customRoom',room=id,revision=1},function(r) status=r end)
for _=1,30 do s:pollRoomView();R.tick();f.advance(500);if not s.busy then break end end
assert(status=='ok' and s.id==originalSession and #s.targets==1 and not Q.Bindings.target(f.player,s.id,hidden))
local visible=Q.DiscoveryView.rows(s,f.player,{})
assert(#visible==1 and visible[1].target.whole and visible[1].partial,'cross-boundary furniture was not conservative')
local load=A.handle(f.player,'load',{session=s.id,token=visible[1].token,whole=true});assert(load.status=='ok')
assert(A.handle(f.player,'groupChange',{session=s.id,token=visible[1].token,whole=true,revision=load.revision,config=Q.Schema.empty()}).status=='invalid','hidden compartment accepted Whole Container apply')
local record=Q.Bindings.target(f.player,s.id,s.targets[1].token)
record.original=Q.Schema.empty();record.revision=0
local c=Q.Schema.empty();c.items.RoundA=true;assert(Q.Store.rawCommit(record,c))
local result=A.handle(f.player,'roomDiscover',{session=s.id,scope={x=0,y=0,z=0},customRoom=id,roomRevision=1,roomScan='sweep',sources=true})
for _=1,30 do if result.status=='ok' then break end;assert(result.status=='waiting');R.tick();f.advance(16);result=A.handle(f.player,'roomDiscover',{session=s.id,scope={x=0,y=0,z=0},customRoom=id,roomRevision=1,roomScan='sweep',sources=true}) end
assert(result.status=='ok' and #result.sources==1 and result.sources[1].identity and result.sweep)
-- Area intent cannot enumerate player/ground/bag inventories through a room sweep.
assert(A.handle(f.player,'tripBegin',{session=result.session,source='inventory',area=true,sweep=result.sweep}).status=='invalid')
assert(A.handle(f.player,'tripBegin',{session=result.session,source='ground',area=true,sweep=result.sweep}).status=='invalid')
assert(A.handle(f.player,'tripBegin',{session=result.session,source=record.token,area=true,sweep='forged'}).status=='invalid')
-- Changing room geometry invalidates the old scope; staged sorting edits survive.
local selected=s.records[s.targets[1].token];selected.original=c;selected.working=Q.Schema.copy(c);selected.working.items.keep=true
write({id=id,roomRevision=1,rows={{0,0,0,1}}})
s:setView({kind='customRoom',room=id,revision=2},function(r) status=r end)
for _=1,30 do s:pollRoomView();R.tick();f.advance(500);if not s.busy then break end end
assert(status=='RoomScopeConflict' and selected.working.items.keep,'expired room silently discarded staged sorting')
selected.working=Q.Schema.copy(selected.original)
s:setView({kind='customRoom',room=id,revision=2},function(r) status=r end)
for _=1,30 do s:pollRoomView();R.tick();f.advance(500);if not s.busy then break end end
assert(status=='ok' and #s.targets==2 and s.id~=originalSession)
local rows=Q.DiscoveryView.rows(s,f.player,{})
assert(#rows==1 and not rows[1].partial,'complete geometry still appeared as a partial furniture assembly')
-- Closing while asynchronous room discovery is in flight cannot leave a live view.
s:setView({kind='customRoom',room=id,revision=2},function() error('closed room query callback') end)
assert(s.roomQuery and s:close() and not s.roomQuery and s.closed)
print('PASS OFFLINE custom scope: cooperative discovery, stable handles, exact physical membership, partial furniture guard, configured sources only, ground/player rejection, revision invalidation and staged-edit preservation')
