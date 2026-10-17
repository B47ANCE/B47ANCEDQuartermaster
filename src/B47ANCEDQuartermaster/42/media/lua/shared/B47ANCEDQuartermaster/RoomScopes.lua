local Access=require 'B47ANCEDQuartermaster/RoomAccess'
local Q=B47ANCEDQuartermaster
local R={scans=setmetatable({},{__mode='k'})};Q.RoomScopes=R
local function nativeRoom(sq) return sq and (sq.getRoomDef and sq:getRoomDef() or sq.getRoom and sq:getRoom() and sq:getRoom():getRoomDef()) end
function R.playerWithinArea(player,session)
 local sq=player:getCurrentSquare();if not sq then return false end
 if nativeRoom(sq)==session.areaRoom then return true end
 local building=sq:getBuilding()
 return session.areaBuildingDef and building and building:getDef()==session.areaBuildingDef or false
end
function R.includes(player,session,target)
 local view=session.areaView;if not view then return true end
 local sq=target.obj:getSquare()
 if view.kind=='building' then local b=sq:getBuilding();return b and b:getDef()==session.buildingDef or false end
 if view.kind=='nativeRoom' then return nativeRoom(sq)==session.areaRoom end
 return true -- External geometry is separately enforced by Bindings.target.
end
function R.discover(player,id,revision,nonce)
 if type(nonce)~='string' or #nonce<1 or #nonce>96 then return nil,'invalid' end
 local room,e=Access.resolve(player,id,revision);if not room then return nil,e end
 local job=R.scans[player]
 if not job or job.id~=id or job.revision~=revision or job.nonce~=nonce then
  local active=0;for _,j in pairs(R.scans) do if not j.done then active=active+1 end end;if active>=16 then return nil,'busy' end
  local api=Access.service();local result=api.tiles(player,id,revision)
  if result.status~='ok' then return nil,result.status end
  job={id=id,revision=revision,nonce=nonce,tiles=result.tiles,index=1,objectIndex=0,ci=0,targets={},seen={},time=getTimestampMs()};R.scans[player]=job
 end
 if job.failed then return nil,job.failed end
 if job.done then return job.targets end
 return nil,'waiting'
end
function R.tick()
 if isClient() then return end
 local active=false;for _ in pairs(R.scans) do active=true;break end;if not active then return end
 local now=getTimestampMs();local deadline=now+4;local jobs={}
 local online
 if isServer() then
  online={};local players=getOnlinePlayers();for n=0,players:size()-1 do online[players:get(n)]=true end
 end
 for player,j in pairs(R.scans) do
  local connected=isServer() and online[player] or not isServer() and getSpecificPlayer(player:getPlayerNum())==player
  if not connected or now-j.time>30000 then R.scans[player]=nil elseif not j.done and not j.failed then jobs[#jobs+1]={player,j} end
 end
 table.sort(jobs,function(a,b) return (a[2].last or 0)<(b[2].last or 0) end)
 for n=1,math.min(4,#jobs) do
  if getTimestampMs()>=deadline then break end
  local player,j=unpack(jobs[n]);j.last=now
  if not Access.resolve(player,j.id,j.revision) then j.failed='RoomScopeChanged'
  else for _=1,32 do
   if getTimestampMs()>=deadline then break end
   local tile=j.tiles[j.index];if not tile then j.done=true;break end
   if not j.objects then
    local sq=getCell():getGridSquare(tile.x,tile.y,tile.z);if not sq then j.failed='RoomUnloaded';break end
    j.objects=sq:getObjects();j.objectIndex=0;j.ci=0;if j.objects:size()>512 then j.failed='tooLarge';break end
   end
   if j.objectIndex>=j.objects:size() then j.objects=nil;j.index=j.index+1
   else local obj=j.objects:get(j.objectIndex);local count=obj:getContainerCount() or 0
    if count>100 then j.failed='tooLarge';break end
    if j.ci>=count then j.ci=0;j.objectIndex=j.objectIndex+1
    else local target=Q.Targets.make(obj,j.ci,player);j.ci=j.ci+1
     if target and not j.seen[target.container] then
      if #j.targets>=4096 then j.failed='tooLarge';break end
      j.seen[target.container]=true;j.targets[#j.targets+1]=target
     end
    end
   end
  end end
 end
end
function R.carriedSources(player)
 local sources,seen={},{};local count,bags=0,0
 local function visit(container,token,depth)
  if seen[container] or depth>16 then return false end;seen[container]=true
  local items=container:getItems()
  for n=0,items:size()-1 do
   count=count+1;if count>4096 then return false end
   local item=items:get(n)
   if instanceof(item,'InventoryContainer') then
    bags=bags+1;if bags>128 or not visit(item:getInventory(),'bag:'..item:getID(),depth+1) then return false end
   end
  end
  -- Descendants first: never put away a full bag before sorting its contents.
  sources[#sources+1]={source=token};return true
 end
 if not visit(player:getInventory(),'inventory',0) then return nil,'tooLarge' end
 return sources
end
function R.options(player)
 local sq=player:getCurrentSquare();if not sq then return {status='invalid'} end
 local _,whole=Q.Targets.options();local rooms={};local api,state=Access.service()
 if state=='unknown' then return {status='RoomPermissionUnavailable'} end
 if api then
  local result=api.roomsAt(player,sq:getX(),sq:getY(),sq:getZ());if result.status=='ok' then rooms=result.rooms end
 elseif state=='absent' and nativeRoom(sq) then rooms={{nativeFallback=true,label=nativeRoom(sq):getName(),revision=0}} end
 return {status='ok',building=whole and sq:getBuilding()~=nil or false,rooms=rooms,roomsAvailable=state=='ready'}
end
function R.handle(player,command,args)
 if isClient() then return {status='invalid'} end
 if command=='areaOptions' then return R.options(player) end
 if command=='roomList' then
  local rooms,revision,world,state=Access.metadata(player)
  return {status=state=='ready' and 'ok' or state=='absent' and 'RoomServiceAbsent' or 'RoomPermissionUnavailable',rooms=rooms,revision=revision,world=world}
 end
 if command=='roomGet' then local api=Access.service();return api and api.geometry(player,args.id,args.roomRevision) or {status='RoomPermissionUnavailable'} end
 if command~='roomDiscover' and command~='areaDiscover' then return {status='invalid'} end
 if Q.Movement.runs[player] then return {status='busy'} end
 local sq=player:getCurrentSquare();if not sq then return {status='invalid'} end
 local view=args.areaView
 if view and (type(view)~='table' or (view.kind~='building' and view.kind~='nativeRoom' and view.kind~='customRoom')) then return {status='invalid'} end
 if view and view.kind=='building' and not R.options(player).building then return {status='RoomBuildingUnavailable'} end
 if view and view.kind=='nativeRoom' and (select(2,Access.service())~='absent' or not nativeRoom(sq)) then return {status='RoomUnavailable'} end
 local request={session=args.session,scope=args.scope,customRoom=args.customRoom or view and view.kind=='customRoom' and view.room,
  roomRevision=args.roomRevision or view and view.revision,roomScan=args.roomScan}
 local result,e=Q.Bindings.discover(player,request);if not result then return {status=e} end
 local session=Q.Bindings.session(player,result.session)
 if view then
  session.areaView={kind=view.kind};session.areaRoom=view.kind=='nativeRoom' and nativeRoom(sq) or nil
  local building=sq:getBuilding();session.areaBuildingDef=building and building:getDef() or nil
 end
 if args.sources==true or command=='areaDiscover' then
  session.areaSweep=Q.Movement.fresh();session.areaSeen={};session.areaSources={};result.sweep=session.areaSweep;result.sources={}
  local carried,err=R.carriedSources(player);if not carried then return {status=err} end
  for _,source in ipairs(carried) do result.sources[#result.sources+1]=source;session.areaSources[source.source]=true end
  local visible={}
  for _,meta in ipairs(result.targets) do
   local record=Q.Bindings.target(player,result.session,meta.token)
   if record and R.includes(player,session,record.target) then
    visible[#visible+1]=meta
    if Access.can(player,record.target,'inspect') and Access.can(player,record.target,'withdraw') then
     local config=Q.Store.load(record.target,player);local effective=config and Q.Presets.resolve(config);local configured=false
     if effective then for _,field in ipairs({'cats','items'}) do for _ in pairs(effective[field]) do configured=true;break end end end
     if configured then meta.identity=Q.Movement.identity(record.target);result.sources[#result.sources+1]=meta;session.areaSources[meta.token]=true end
    end
   end
  end
  result.targets=visible
 end
 return result
end
function R.cleanup(player) R.scans[player]=nil end
if Events and Events.OnTick then Events.OnTick.Add(R.tick) end
return R
