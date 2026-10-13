dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
require 'B47ANCEDQuartermaster/Session'
local f=CONTAINER_FIXTURE;local Q=B47ANCEDQuartermaster;local A,B,V=Q.Authority,Q.Bindings,Q.DiscoveryView
local player=f.player
function getText(key,...) local args={...};for i,v in ipairs(args) do key=key..':'..tostring(v) end;return key end
local definitions=f.list();local bd={getRooms=function() return definitions end,getID=function() return 1 end};local building={getDef=function() return bd end}
local function room(id,name,x,y,z,width,height,squares)
 local d={getID=function() return id end,getName=function() return name end,getX=function() return x end,getY=function() return y end,getZ=function() return z end,getX2=function() return x+width end,getY2=function() return y+height end}
 local physical={getRoomDef=function() return d end};for _,sq in ipairs(squares) do sq.building=building;sq.getRoom=function() return physical end end;definitions[#definitions+1]=d;return d
end
local r1=room(1,'Kitchen',0,0,0,1,1,{f.a.sq});local r2=room(2,'Kitchen',1,0,0,1,1,{f.b.sq});room(3,'Storage',0,1,0,1,1,{f.unrelatedObject.sq})
SandboxVars.B47ANCEDQuartermaster.WholeBuilding=nil
local range,whole=Q.Targets.options();assert(whole==true and range==10,'whole-building default missing')
local origin=Q.Targets.make(f.a,0,player);local session=Q.Session.new(origin,0);local status;session:open(function(s) status=s end);assert(status=='ok')
assert(session.view.kind=='room' and session.view.room==session.viewInfo.currentRoom,'default not current physical room')
assert(#session.viewInfo.rooms==3 and session.viewInfo.rooms[1].label~=session.viewInfo.rooms[2].label,'same-name rooms not distinguished')
local rows=V.rows(session,player,{});assert(#rows==1 and rows[1].target.whole and rows[1].partial,'partial group leaked hidden children')
local sectionNumbers={};for _,r in ipairs(session.targets) do if r.target.group then assert(not sectionNumbers[r.target.groupSection]);sectionNumbers[r.target.groupSection]=true end end
local parent=rows[1];local loaded=A.handle(player,'load',{session=session.id,token=parent.token,whole=true});assert(loaded.status=='ok')
local blocked=A.handle(player,'groupChange',{session=session.id,token=parent.token,whole=true,revision=loaded.revision,config=Q.Schema.empty(),taxonomyVersion=6});assert(blocked.status=='invalid','partial scope parent write authorized')
local function select(view) session:setView(view,function(s) assert(s=='ok') end) end
select({kind='building'});rows=V.rows(session,player,{[parent.target.group]=true});assert(#rows==4 and rows[1].target.whole and rows[2].target.group==rows[3].target.group,'nested group separated by distance order')
loaded=A.handle(player,'load',{session=session.id,token=parent.token,whole=true});assert(A.handle(player,'groupChange',{session=session.id,token=parent.token,whole=true,revision=loaded.revision,config=Q.Schema.empty(),taxonomyVersion=6}).status=='ok')
select({kind='room',room=session.viewInfo.rooms[2].token});rows=V.rows(session,player,{});assert(#rows==1 and rows[1].partial)
select({kind='proximity',radius=1});assert(#V.rows(session,player,{})==2)
local old=session.view.radius;local response=A.handle(player,'viewSelect',{session=session.id,view={kind='proximity',radius=31}});assert(response.status=='invalid' and session.view.radius==old)
assert(A.handle(player,'viewSelect',{session=session.id,view={kind='room',room='forged'}}).status=='invalid')
-- Scope filtering never modifies server gameplay discovery settings or the full handle set.
assert(SandboxVars.B47ANCEDQuartermaster.WholeBuilding==nil and #session.targets==3)
SandboxVars.B47ANCEDQuartermaster.WholeBuilding=false;local d=assert(B.discover(player,{scope={x=0,y=0,z=0}}));assert(not d.viewInfo.buildingAvailable and Q.Targets.options()==10)
assert(A.handle(player,'viewSelect',{session=d.session,view={kind='building'}}).status=='invalid')
-- A new building invalidates physical room tokens; no name-based rebinding.
local outside=f.square(20,20,0);player.square=outside;function player:getX() return self.square:getX() end;function player:getY() return self.square:getY() end
local fresh=assert(B.discover(player,{scope={x=20,y=20,z=0},invalidateView=true}));session:acceptDiscovery(fresh);assert(V.label(session)==getText('UI_QMSS_RoomUnavailable') and #V.rows(session,player,{})==0)
print('PASS OFFLINE dev26 scopes: room-first default, distinct rooms, partial-group authority, building/proximity choices, bounds, nearest grouping and invalidation')
