-- Server-owned logical regions. Never mutate vanilla geometry or container data.
require 'B47ANCEDQuartermaster/Schema'
local G=require 'B47ANCEDQuartermaster/RoomGeometry'
local Migration=require 'B47ANCEDQuartermaster/Migration'
local R={jobs=setmetatable({},{__mode='k'}),scans=setmetatable({},{__mode='k'})};B47ANCEDQuartermaster.Rooms=R
local checked=setmetatable({},{__mode='k'});local shapes=setmetatable({},{__mode='k'})
local tickets=setmetatable({},{__mode='k'});local ticketSerial=0
local function geometry(room)
 local g=shapes[room];if not g then g=G.normalize(room.rows);if g then shapes[room]=g end end
 return g
end
local function integer(n) return type(n)=='number' and n==n and n>=0 and n<2^53 and n==math.floor(n) end
local function owner(p) return isServer() and p:getUsername() or 'local:'..p:getPlayerNum() end
local function admin(p) return p.getAccessLevel and tostring(p:getAccessLevel()):lower()=='admin' end
local function name(s)
 if type(s)~='string' or #s>192 then return end
 s=s:match('^%s*(.-)%s*$')
 if #s<1 or #s>96 or s:find('%c') or s:find('[<>]') then return end
 return s
end
function R.options()
 local max=tonumber((Migration.option('RoomTileLimit'))) or 1024
 if not G.integer(max) then max=1024 end
 local distance=tonumber((Migration.option('RoomEditRange'))) or 30
 if not G.integer(distance) then distance=30 end
 local enabled=Migration.option('CustomRooms')
 return {enabled=enabled==nil or enabled==true,maxTiles=math.max(64,math.min(G.tileLimit,max)),
  range=math.max(5,math.min(128,distance)),doorways=Migration.option('RoomDoorways')~=false}
end
local function library()
 if isClient() then return nil,'invalid' end
 local data=ModData.getOrCreate('B47ANCEDQuartermaster');local lib=data.customRooms
 if lib==nil then return {schema=1,revision=0,serial=0,records={}},data end
 if type(lib)~='table' or lib.schema~=1 or not integer(lib.revision) or not integer(lib.serial) or lib.serial>=10000000 or type(lib.records)~='table' then return nil,'schema' end
 if type(lib.world)~='string' or #lib.world~=36 or not lib.world:match('^[%x%-]+$') then return nil,'schema' end
 if checked[lib] then return lib,data end
 local n,total=0,0;local ordinals={}
 for id,room in pairs(lib.records) do
  if type(id)~='string' or #id~=73 or id:sub(1,37)~=lib.world..':' or not id:sub(38):match('^[%x%-]+$') or type(room)~='table' or room.id~=id
   or not name(room.name) or type(room.owner)~='string' or #room.owner<1 or #room.owner>256
   or not integer(room.revision) or not integer(room.createdAt) or not integer(room.updatedAt)
   or (room.safehouse~=nil and (type(room.safehouse)~='string' or #room.safehouse>256)) then return nil,'schema' end
  if not integer(room.ordinal) or room.ordinal<1 or room.ordinal>lib.serial then return nil,'schema' end
  if ordinals[room.ordinal] then return nil,'schema' end;ordinals[room.ordinal]=true
  local g=geometry(room);if not g or g.count<1 then return nil,'schema' end
  n=n+1;total=total+g.count;if n>128 or total>16384 then return nil,'schema' end
 end
 checked[lib]=true;return lib,data
end
local function house(id)
 return id and SafeHouse and SafeHouse.getSafeHouse and SafeHouse.getSafeHouse(id) or nil
end
local function houseMember(player,h)
 local who=player:getUsername()
 return admin(player) or h:getOwner()==who or h:getPlayers():contains(who)
end
local function member(player,room)
 if owner(player)==room.owner or admin(player) then return true end
 local h=house(room.safehouse)
 return h and houseMember(player,h) or false
end
local function nearby(player,g)
 local sq=player:getCurrentSquare();local b=g.bounds;if not sq or not b then return false end
 local range=R.options().range
 return sq:getX()>=b.x1-range and sq:getX()<=b.x2+range and sq:getY()>=b.y1-range and sq:getY()<=b.y2+range
end
local function copyRoom(room)
 local g=G.normalize(room.rows);local out={id=room.id,ordinal=room.ordinal,name=room.name,revision=room.revision,rows=g.rows,safehouse=room.safehouse,createdAt=room.createdAt,updatedAt=room.updatedAt}
 return out
end
function R.resolve(player,id,revision)
 if not R.options().enabled then return nil,'RoomDisabled' end
 if type(id)~='string' or #id~=73 then return nil,'RoomDenied' end
 local lib,e=library();if not lib then return nil,e end
 local room=type(id)=='string' and lib.records[id]
 if not room or not member(player,room) then return nil,'RoomDenied' end
 if revision~=nil and room.revision~=revision then return nil,'conflict' end
 local g=geometry(room)
 if not nearby(player,g) then return nil,'RoomOutOfRange' end
 return room,g
end
function R.contains(player,id,revision,x,y,z)
 local room,g=R.resolve(player,id,revision);return room and G.contains(g,x,y,z) or false
end
function R.metadata(player)
 local lib,e=library();if not lib then return nil,e end
 local out={}
 if not R.options().enabled then return out,lib.revision end
 for id,room in pairs(lib.records) do
  if member(player,room) then local g=geometry(room)
   if nearby(player,g) then out[#out+1]={id=id,name=room.name,label=room.name..' [r'..room.ordinal..']',revision=room.revision,count=g.count,bounds=g.bounds} end
  end
 end
 table.sort(out,function(a,b) return a.id<b.id end)
 return out,lib.revision,lib.world
end
local function currentPermission(player,sq)
 if not sq then return false,'RoomUnloaded' end
 if (isClient() or isServer()) and (not SafeHouse or not SafeHouse.isSafehouseAllowInteract
  or not SafeHouse.isSafehouseAllowInteract(sq,player) or not SafeHouse.isSafehouseAllowLoot(sq,player)) then return false,'RoomDenied' end
 return true
end
local function plainArgs(args) return type(args)=='table' and getmetatable(args)==nil end
function R.cleanup(player) R.jobs[player]=nil;R.scans[player]=nil;tickets[player]=nil end
function R.discover(player,id,revision,nonce)
 local room,g=R.resolve(player,id,revision);if not room then return nil,g end
 if type(nonce)~='string' or #nonce>96 then return nil,'invalid' end
 local j=R.scans[player]
 if not j or j.id~=id or j.revision~=room.revision or j.nonce~=nonce then
  local n=0;for participant,scan in pairs(R.scans) do if participant~=player and not scan.done and not scan.failed then n=n+1 end end;if n>=16 then return nil,'busy' end
  j={id=id,revision=room.revision,nonce=nonce,tiles=g.tiles,index=1,targets={},seen={},time=getTimestampMs()};R.scans[player]=j
 end
 if j.failed then return nil,j.failed end
 if j.done then return j.targets end
 return nil,'waiting'
end
local function finish(job,status,reason) job.done=true;job.result={status=status,reason=reason};return job.result end
function R.handle(player,command,args)
 if isClient() or not player or not plainArgs(args) then return {status='invalid'} end
 local who=owner(player);if type(who)~='string' or #who<1 or #who>256 then return {status='invalid'} end
 if not R.options().enabled then return {status='RoomDisabled'} end
 if command=='roomDiscover' then
  if not args.customRoom then return {status='invalid'} end
  if B47ANCEDQuartermaster.Movement.runs[player] then return {status='busy'} end
  local result,e=B47ANCEDQuartermaster.Bindings.discover(player,args)
  if result and args.sources==true then
   local B,M,Store=B47ANCEDQuartermaster.Bindings,B47ANCEDQuartermaster.Movement,B47ANCEDQuartermaster.Store
   local session=B.session(player,result.session);session.areaSweep=M.fresh();session.areaSeen={};result.sweep=session.areaSweep;result.sources={}
   for _,meta in ipairs(result.targets) do
    local record=B.target(player,result.session,meta.token);local config=record and Store.load(record.target,player)
    local rules=config and B47ANCEDQuartermaster.Presets.resolve(config);local configured=false
    if rules then for _,field in ipairs({'cats','items'}) do for _ in pairs(rules[field]) do configured=true;break end end end
    if configured then meta.identity=M.identity(record.target);result.sources[#result.sources+1]=meta end
   end
  end
  return result or {status=e}
 end
 if command=='roomList' then
  local rooms,revision,world=R.metadata(player);if not rooms then return {status=revision} end
  local t=tickets[player]
  local pending=R.jobs[player] and not R.jobs[player].done
  if not t or not pending and (args.renew==true or t.used or getTimestampMs()-t.time>120000) then ticketSerial=ticketSerial+1;t={key=tostring(getTimestampMs())..':'..ticketSerial,time=getTimestampMs()};tickets[player]=t end
  return {status='ok',rooms=rooms,revision=revision,world=world,options=R.options(),editKey=t.key}
 end
 if command=='roomGet' then
  local room,e=R.resolve(player,args.id,args.roomRevision);if not room then return {status=e} end
  return {status='ok',room=copyRoom(room)}
 end
 if command=='roomPoll' then
  local j=R.jobs[player]
  if not j or j.nonce~=args.nonce then return {status='expired'} end
  return j.result or {status='pending'}
 end
 if command=='roomCancel' then
  local current=R.jobs[player]
  if current and current.nonce==args.nonce and current.editKey==args.editKey then return current.result or finish(current,'cancelled') end
  local t=tickets[player];if not t or t.key~=args.editKey then return {status='expired'} end
  t.used=true;local j=R.jobs[player]
  if j and j.nonce==args.nonce then return j.result or finish(j,'cancelled') end
  return {status='cancelled'}
 end
 if command~='roomChange' or type(args.nonce)~='string' or #args.nonce<1 or #args.nonce>96 or args.nonce:find('%c') then return {status='invalid'} end
 local prior=R.jobs[player]
 if prior and prior.nonce==args.nonce then
  if prior.editKey~=args.editKey then return {status='invalid'} end
  return prior.result or {status='pending'}
 end
 if prior and not prior.done then return {status='busy'} end
 local ticket=tickets[player]
 if not ticket or ticket.used or ticket.key~=args.editKey or getTimestampMs()-ticket.time>120000 then return {status='expired'} end
 local lib,data=library();if not lib then return {status=data} end
 if args.revision~=lib.revision then return {status='conflict'} end
 local pending=0;for _,j in pairs(R.jobs) do if not j.done then pending=pending+1 end end;if pending>=16 then return {status='busy'} end
 local changed,removed={},{};local serial=lib.serial
 local world=lib.world or getRandomUUID()
 if args.id~=nil and (type(args.id)~='string' or #args.id~=73) then return {status='invalid'} end
 local old=args.id and lib.records[args.id]
 if args.id and (not old or not member(player,old)) then return {status='RoomDenied'} end
 if old and args.roomRevision~=old.revision then return {status='conflict'} end
 local action=args.action
 if action=='delete' then
  if not old or args.confirm~=true then return {status='invalid'} end;removed[old.id]=true
 elseif action=='save' or action=='split' or action=='merge' then
  local title=name(args.name);if not title then return {status='RoomNameInvalid'} end
  local geometry,e=G.normalize(args.rows,R.options().maxTiles)
  if not geometry or geometry.count<1 then return {status=e or 'RoomGeometryInvalid'} end
  if G.components(geometry)>1 and args.disconnected~=true then return {status='RoomDisconnected'} end
  local id=old and old.id
  if not id then serial=serial+1;id=world..':'..getRandomUUID();if lib.records[id] then return {status='failed'} end end
  changed[id]={id=id,ordinal=old and old.ordinal or serial,name=title,owner=old and old.owner or owner(player),revision=old and old.revision+1 or 1,
   safehouse=old and old.safehouse,rows=geometry.rows,createdAt=old and old.createdAt or getTimestamp(),updatedAt=getTimestamp()}
  if action=='merge' then
   if not old or not G.array(args.ids,128) or #args.ids<2 or args.confirm~=true then return {status='invalid'} end
   local merged=G.normalize({});local seen={}
   for _,other in ipairs(args.ids) do
    if type(other)~='string' or #other~=73 or seen[other] then return {status='invalid'} end;seen[other]=true
    local r=lib.records[other];if not r or not member(player,r) then return {status='RoomDenied'} end
    if r.safehouse~=old.safehouse then return {status='RoomAssociationConflict'} end
    merged,e=G.edit(merged.rows,r.rows,false,R.options().maxTiles);if not merged then return {status=e} end
    if other~=old.id then removed[other]=true end
   end
   if not seen[old.id] then return {status='invalid'} end
   local a,b=G.normalize(changed[id].rows),merged
   if a.count~=b.count then return {status='RoomGeometryInvalid'} end
   for key in pairs(a.set) do if not b.set[key] then return {status='RoomGeometryInvalid'} end end
  elseif action=='split' then
   if not old or args.confirm~=true then return {status='invalid'} end
   local title2=name(args.secondName);local second;second,e=G.normalize(args.secondRows,R.options().maxTiles)
   if not title2 or not second or second.count<1 then return {status=e or 'RoomNameInvalid'} end
   if G.components(second)>1 and args.disconnected~=true then return {status='RoomDisconnected'} end
   local original=G.normalize(old.rows)
   if geometry.count+second.count~=original.count then return {status='RoomGeometryInvalid'} end
   for key in pairs(geometry.set) do if not original.set[key] or second.set[key] then return {status='RoomGeometryInvalid'} end end
   for key in pairs(second.set) do if not original.set[key] then return {status='RoomGeometryInvalid'} end end
   serial=serial+1;local other=world..':'..getRandomUUID();if lib.records[other] or changed[other] then return {status='failed'} end
   changed[other]={id=other,ordinal=serial,name=title2,owner=old.owner,revision=1,safehouse=old.safehouse,rows=second.rows,createdAt=getTimestamp(),updatedAt=getTimestamp()}
  end
 else return {status='invalid'} end
 local count,total=0,0
 for id,r in pairs(lib.records) do if not removed[id] and not changed[id] then count=count+1;total=total+G.normalize(r.rows).count end end
 local work={}
 for _,r in pairs(changed) do
  local g=G.normalize(r.rows);count=count+1;total=total+g.count
  for _,tile in ipairs(g.tiles) do work[#work+1]={tile=tile,room=r} end
 end
 if count>128 or total>16384 or not integer(serial) or serial>=10000000 or not integer(lib.revision+1) then return {status='RoomTooLarge'} end
 -- A deletion still validates access to the old room cooperatively.
 if action=='delete' then local validation={id=old.id,safehouse=old.safehouse};for _,t in ipairs(G.normalize(old.rows).tiles) do work[#work+1]={tile=t,room=validation} end end
 local j={nonce=args.nonce,editKey=args.editKey,world=world,revision=lib.revision,changed=changed,removed=removed,serial=serial,work=work,index=1,time=getTimestampMs(),original=lib}
 ticket.used=true;R.jobs[player]=j;return {status='pending'}
end
function R.tick()
 if isClient() then return end
 if not R.options().enabled then
  for _,j in pairs(R.jobs) do if not j.done then finish(j,'RoomDisabled') end end
  R.scans=setmetatable({},{__mode='k'});return
 end
 local scanDeadline=getTimestampMs()+4;local deadline=getTimestampMs()+2
 local online
 local function connected(player)
  if not isServer() then return getSpecificPlayer(player:getPlayerNum())==player end
  if type(getOnlinePlayers)~='function' then return false end
  if not online then online={};local players=getOnlinePlayers();for i=0,players:size()-1 do online[players:get(i)]=true end end
  return online[player]==true
 end
 -- At most four jobs per tick and 32 native tile checks/job. Every job expires.
 local active={};for player,j in pairs(R.jobs) do
  if getTimestampMs()-j.time>30000 then R.jobs[player]=nil elseif not j.done then active[#active+1]={player,j} end
 end
 table.sort(active,function(a,b) return (a[2].lastStep or 0)<(b[2].lastStep or 0) end)
 for n=1,math.min(4,#active) do
  if getTimestampMs()>=deadline then break end
  local player,j=unpack(active[n]);j.lastStep=getTimestampMs()
  local ok,err=pcall(function()
   if not connected(player) or not player:getCurrentSquare() or (player.isDead and player:isDead()) then finish(j,'cancelled');return end
   local lib,data=library();if not lib or lib.revision~=j.revision then finish(j,'conflict');return end
   for id in pairs(j.removed) do if not lib.records[id] or not member(player,lib.records[id]) then finish(j,'RoomDenied');return end end
   for id in pairs(j.changed) do if lib.records[id] and not member(player,lib.records[id]) then finish(j,'RoomDenied');return end end
   for _=1,32 do
    if getTimestampMs()>=deadline then break end
    local row=j.work[j.index];if not row then break end;j.index=j.index+1
    local t=row.tile;local sq=getCell():getGridSquare(t.x,t.y,t.z);local allowed,reason=currentPermission(player,sq)
    if not allowed then finish(j,reason);return end
    local range=R.options().range
    if math.max(math.abs(t.x-player:getX()),math.abs(t.y-player:getY()))>range then finish(j,'RoomOutOfRange');return end
    -- The association is server-derived and must not span distinct safehouses.
    if SafeHouse and SafeHouse.getSafeHouse then
     local h=SafeHouse.getSafeHouse(sq)
     if h then
      if not houseMember(player,h) then finish(j,'RoomDenied');return end
      if row.room.safehouse and row.room.safehouse~=h:getId() then finish(j,'RoomAssociationConflict');return end
      row.room.safehouse=h:getId()
     end
    end
   end
   if j.index>#j.work then
    -- Membership can change after an earlier tile slice. Recheck associated
    -- native groups before the single authoritative library replacement.
    for _,r in pairs(j.changed) do local h=house(r.safehouse);if h and not houseMember(player,h) then finish(j,'RoomDenied');return end end
    for id in pairs(j.removed) do local h=house(lib.records[id].safehouse);if h and not houseMember(player,h) then finish(j,'RoomDenied');return end end
    for _,r in pairs(j.changed) do if G.normalize(r.rows).count>R.options().maxTiles then finish(j,'RoomTooLarge');return end end
    -- No native calls or yields between revision check and replacing this library.
    local records={};for id,r in pairs(lib.records) do if not j.removed[id] then records[id]=r end end
    for id,r in pairs(j.changed) do records[id]=r end
    data.customRooms={schema=1,world=j.world,revision=lib.revision+1,serial=j.serial,records=records}
    j.done=true;j.result={status='ok',revision=lib.revision+1}
    if B47ANCEDQuartermaster.Bindings then for participant,s in pairs(B47ANCEDQuartermaster.Bindings.sessions) do
     s.roomsRevision=nil
     if isServer() and sendServerCommand then sendServerCommand(participant,'B47ANCEDQuartermaster','roomsChanged',{}) end
    end end
   end
  end)
  if not ok then if not j.done then finish(j,'failed') end;print('[B47ANCEDQuartermaster] room validation/notification failed '..tostring(err)) end
 end
 deadline=scanDeadline
 local scans={};for player,j in pairs(R.scans) do
  if getTimestampMs()-j.time>30000 then R.scans[player]=nil elseif not j.done and not j.failed then scans[#scans+1]={player,j} end
 end
 table.sort(scans,function(a,b) return (a[2].lastStep or 0)<(b[2].lastStep or 0) end)
 for n=1,math.min(4,#scans) do
  if getTimestampMs()>=deadline then break end
  local player,j=unpack(scans[n]);j.lastStep=getTimestampMs()
  local room,e
  if connected(player) then room,e=R.resolve(player,j.id,j.revision) else e='cancelled' end
  if not room then j.failed=e else
   for _=1,32 do
    if getTimestampMs()>=deadline then break end
    local t=j.tiles[j.index];if not t then j.done=true;break end
    if not j.objects then
     local sq=getCell():getGridSquare(t.x,t.y,t.z)
     if not sq then j.failed='RoomUnloaded';break end
     j.objects=sq:getObjects();j.objectIndex=0;j.ci=0
     if j.objects:size()>512 then j.failed='RoomTooLarge';break end
    end
    if j.objectIndex>=j.objects:size() then j.objects=nil;j.index=j.index+1
    else
     local obj=j.objects:get(j.objectIndex);local count=obj:getContainerCount() or 0
     if count>100 then j.failed='RoomTooLarge';break end
     if j.ci>=count then j.ci=0;j.objectIndex=j.objectIndex+1 else
      local target=B47ANCEDQuartermaster.Targets.make(obj,j.ci,player);j.ci=j.ci+1
      if target and not j.seen[target.container] then
       if #j.targets>=4096 then j.failed='RoomTooLarge';break end
       j.seen[target.container]=true;j.targets[#j.targets+1]=target
      end
     end
    end
   end
  end
 end
end
if Events and Events.OnTick then Events.OnTick.Add(R.tick) end
return R
