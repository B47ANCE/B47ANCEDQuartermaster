-- Historical records may outlive their loaded world squares. This is a stricter
-- read-only disclosure policy, never permission for native inventory operations.
local A={}
local Access=require 'B47ANCEDQuartermaster/RoomAccess'
function A.read(actor,entry,context)
 local p=entry.position;local sq=getCell():getGridSquare(p.x,p.y,p.z)
 if sq then
  if isServer() and (not SafeHouse or not SafeHouse.isSafehouseAllowLoot(sq,actor)) then return false end
  return Access.can(actor,{obj={getSquare=function() return sq end}},'inspect')
 end
 if isClient() then return false end
 if isServer() then
  if not SafeHouse or not SafeHouse.getSafehouseList then return false end
  context.houses=context.houses or SafeHouse.getSafehouseList()
  if context.houses:size()>1024 then return false end
  local found
  for n=0,context.houses:size()-1 do local h=context.houses:get(n)
   if p.x>=h:getX() and p.x<h:getX2() and p.y>=h:getY() and p.y<h:getY2() then if found then return false end;found=h end
  end
  if found then
   local who=actor:getUsername()
   if who~=found:getOwner() and not found:getPlayers():contains(who) then return false end
   if not found:playerAllowed(actor) then return false end
  end
 end
 local _,state=Access.service()
 if state=='absent' then return true end
 if state~='ready' then return false end
 -- Reuse Rooms' own validated server registry and private-storage policy.
 -- No policy tables or custom-room registry are recreated in Quartermaster.
 if not context.rooms then
  local ok,result=pcall(function()
   local R=require 'B47ANCEDRooms/Registry';local P=require 'B47ANCEDRooms/Policy'
   local I=require 'B47ANCEDRooms/Identity';local G=require 'B47ANCEDRooms/Geometry'
   if type(R.library)~='function' or type(R.geometry)~='function' or type(P.storage)~='function' or not R.options().enabled then return false end
   local lib=R.library();if not lib or lib.schema~=2 then return false end
   return {registry=R,policy=P,identity=I,geometry=G,library=lib}
  end)
  context.rooms=ok and result or false
 end
 local c=context.rooms;if not c then return false end
 local matched=0
 for _,room in pairs(c.library.records) do
  if room.policy and room.policy.mode=='private' and c.geometry.contains(c.registry.geometry(room),p.x,p.y,p.z) then
   matched=matched+1
   if matched>1 or c.identity.option('DelegatedRooms',true)~=true or not c.policy.storage(actor,room,'inspect') then return false end
  end
 end
 return true
end
return A
