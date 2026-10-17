require 'B47ANCEDQuartermaster/Schema'
local A={};B47ANCEDQuartermaster.RoomAccess=A;B47ANCEDQuartermaster.Rooms=A
local present,subscribed,unsubscribe
local reported={}
local function invoke(api,method,...)
 local ok,value=pcall(api[method],...)
 if not ok and not reported[method] then
  reported[method]=true;print('[B47ANCEDQuartermaster] Rooms API '..method..' failed: '..tostring(value):sub(1,512))
 end
 return ok,value
end
local function installed()
 if B47ANCEDRooms and B47ANCEDRooms.API then return true end
 if present~=nil then return present end
 if type(getActivatedMods)~='function' then return nil end
 local ok,mods=pcall(getActivatedMods);if not ok or not mods or mods:size()>8192 then return nil end
 present=false;for n=0,mods:size()-1 do if mods:get(n)=='B47ANCEDRooms' then present=true;break end end
 return present
end
function A.service()
 local enabled=installed();if enabled==false then return nil,'absent' end
 if enabled==nil then return nil,'unknown' end
 if not B47ANCEDRooms or not B47ANCEDRooms.API then pcall(require,'B47ANCEDRooms/API') end
 local api=B47ANCEDRooms and B47ANCEDRooms.API
 if not api or api.version~=1 or api.ready~=true then return nil,'unknown' end
 for _,method in ipairs({'canAccessAt','listRooms','resolveRoom','containsTile','tiles','roomsAt','openEditor','subscribe'}) do if type(api[method])~='function' then return nil,'unknown' end end
 if subscribed~=api and type(api.subscribe)=='function' then
  if unsubscribe then pcall(unsubscribe) end
  local ok,subscription=invoke(api,'subscribe',function()
   if B47ANCEDQuartermaster.onRoomsChanged then B47ANCEDQuartermaster.onRoomsChanged() end
   if isServer() and B47ANCEDQuartermaster.Bindings then for player in pairs(B47ANCEDQuartermaster.Bindings.sessions) do sendServerCommand(player,'B47ANCEDQuartermaster','roomsChanged',{}) end end
  end)
  if not ok or type(subscription)~='function' then return nil,'unknown' end
  unsubscribe=subscription;subscribed=api
 end
 return api,'ready'
end
function A.can(player,target,action)
 -- Client preflight is presentation only; server entry/grant paths repeat this
 -- check with the authenticated actor and never trust a client decision.
 if isClient() then return true end
 local sq=target and target.obj and target.obj:getSquare();if not sq then return false,'RoomPermissionUnavailable' end
 local api,status=A.service()
 if status=='absent' then
  if not isServer() then return true end
  if not SafeHouse or not SafeHouse.isSafehouseAllowLoot then return false,'RoomPermissionUnavailable' end
  if not SafeHouse.isSafehouseAllowLoot(sq,player) then return false,'RoomAccessDenied' end
  if action=='configure' and (not SafeHouse.isSafehouseAllowInteract or not SafeHouse.isSafehouseAllowInteract(sq,player)) then return false,'RoomAccessDenied' end
  return true
 end
 if not api then return false,'RoomPermissionUnavailable' end
 local ok,result=invoke(api,'canAccessAt',player,sq:getX(),sq:getY(),sq:getZ(),action)
 if not ok or type(result)~='table' or result.state~='allow' then return false,type(result)=='table' and result.reason or 'RoomPermissionUnavailable' end
 return true,nil,result.revision
end
function A.designated(room)
 return type(room)=='table' and type(room.id)=='string' and room.id:sub(1,7)~='native:' and not room.native and not room.nativeId
end
function A.metadata(player)
 local api,status=A.service();if not api then return {},0,nil,status end
 local ok,result=invoke(api,'listRooms',player)
 if not ok or type(result)~='table' or result.status~='ok' then return {},0,nil,type(result)=='table' and result.status or 'RoomPermissionUnavailable' end
 if type(result.rooms)~='table' or result.nativeRooms~=nil and type(result.nativeRooms)~='table' or #result.rooms>128 or result.nativeRooms and #result.nativeRooms>128 then return {},0,nil,'RoomPermissionUnavailable' end
 local all={};for _,r in ipairs(result.rooms) do if A.designated(r) then all[#all+1]=r end end
 return all,result.revision,result.world,'ready'
end
function A.resolve(player,id,revision)
 if not A.designated({id=id}) then return nil,'RoomUnavailable' end
 local api=A.service();if not api then return nil,'RoomPermissionUnavailable' end
 local ok,result=invoke(api,'resolveRoom',player,id,revision)
 if not ok or type(result)~='table' then return nil,'RoomPermissionUnavailable' end
 if result.status=='ok' and not A.designated(result.room) then return nil,'RoomUnavailable' end
 return result.status=='ok' and result.room or nil,result.status
end
function A.contains(player,id,revision,x,y,z)
 if not A.designated({id=id}) then return false end
 local api=A.service();if not api then return false end
 local ok,value=invoke(api,'containsTile',player,id,revision,x,y,z);return ok and value==true
end
function A.openEditor(num,owner,done)
 local api=A.service();if not api then return nil,'RoomPermissionUnavailable' end
 return api.openEditor(num,owner,done)
end
if Events and Events.OnGameStart then Events.OnGameStart.Add(function() present=nil end) end
return A
