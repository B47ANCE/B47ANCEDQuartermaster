-- Read-only use of Rooms' validated schema-2 registry, as LedgerAccess already
-- does for historical privacy. Never copies geometry or implements its policy.
local Access=require 'B47ANCEDQuartermaster/RoomAccess'
local R={}
local function context()
 if isClient() then return end
 local api,state=Access.service();if not api or state~='ready' then return end
 local ok,result=pcall(function()
  local Registry=require 'B47ANCEDRooms/Registry';local Geometry=require 'B47ANCEDRooms/Geometry'
  local Policy=require 'B47ANCEDRooms/Policy';local Identity=require 'B47ANCEDRooms/Identity'
  if type(Registry.library)~='function' or type(Registry.geometry)~='function' or type(Geometry.contains)~='function' or type(Policy.storage)~='function' then return end
  local lib=Registry.library();if not lib or lib.schema~=2 then return end
  return {registry=Registry,geometry=Geometry,policy=Policy,identity=Identity,library=lib}
 end)
 return ok and result or nil
end
local function visible(c,actor,record)
 if record.policy and record.policy.mode=='private' and c.identity.option('DelegatedRooms',true)~=true then return false end
 return c.policy.storage(actor,record,'inspect')==true
end
function R.one(actor,id)
 if not Access.designated({id=id}) then return end
 local c=context();local record=c and c.library.records[id]
 if record then
  if not visible(c,actor,record) then return end
  local geometry=c.registry.geometry(record);if not geometry then return end
  return {id=id,name=record.name,revision=record.revision,contains=function(p) return c.geometry.contains(geometry,p.x,p.y,p.z) end}
 end
 -- API-only providers retain the supported nearby path; unavailable or changed
 -- registry contracts never become unverified remote geometry.
 local room=Access.resolve(actor,id,nil);if not room then return end
 return {id=id,name=room.name,revision=room.revision,contains=function(p) return Access.contains(actor,id,room.revision,p.x,p.y,p.z) end}
end
function R.at(actor,square)
 local c=context()
 if not c then
  local api=Access.service();if not api then return end
  local result=api.roomsAt(actor,square:getX(),square:getY(),square:getZ())
  return result.status=='ok' and result.rooms or nil
 end
 local out={}
 for id,record in pairs(c.library.records) do
  if Access.designated({id=id}) and c.geometry.contains(c.registry.geometry(record),square:getX(),square:getY(),square:getZ()) then
   if not visible(c,actor,record) then return end
   out[#out+1]={id=id,name=record.name}
  end
 end
 table.sort(out,function(a,b) return a.id<b.id end);return out
end
return R
