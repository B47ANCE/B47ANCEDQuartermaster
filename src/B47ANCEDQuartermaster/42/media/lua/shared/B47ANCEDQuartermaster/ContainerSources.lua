-- Selected native vehicle parts and bags inside discovered physical storage.
-- Hints are intent only; authority captures exact native references before enumeration.
local Q=B47ANCEDQuartermaster
local C={};local markers=setmetatable({},{__mode='k'})
local function copyIds(ids) local out={};for n,id in ipairs(ids) do out[n]=id end;return out end
local function integer(n) return type(n)=='number' and n==n and n>=0 and n<=2147483647 and n%1==0 end
local function itemId(n) return type(n)=='number' and n==n and n>=-2147483648 and n<=2147483647 and n%1==0 end
local function path(root,ids,expected)
 if type(ids)~='table' or getmetatable(ids) or #ids>16 then return end
 local container=root;local refs={};local count=0
 for k,id in pairs(ids) do if not integer(k) or k<1 or k>#ids or not itemId(id) then return end;count=count+1 end
 if count~=#ids then return end
 for n,id in ipairs(ids) do
  local bag=container:getItemWithID(id)
  if not bag or not instanceof(bag,'InventoryContainer') or expected and bag~=expected[n] then return end
  refs[n]=bag;container=bag:getInventory()
 end
 return container,refs
end
function C.hint(container,player)
 if not container or not container.getOutermostContainer then return end
 local root=container:getOutermostContainer();if not root then return end
 local part=root.getVehiclePart and root:getVehiclePart()
 local ids={};local current=container
 while current~=root do
  if #ids>=16 then return end
  local bag=current:getContainingItem();if not bag then return end
  table.insert(ids,1,bag:getID());current=bag:getContainer();if not current then return end
 end
 if part then
  local vehicle=part:getVehicle()
  if not vehicle or not vehicle:canAccessContainer(part:getIndex(),player) then return end
  return {vehicle=vehicle:getId(),part=part:getId(),index=part:getIndex(),bags=ids}
 end
 if #ids==0 then return end -- ordinary physical containers retain their existing path
 local obj=root:getParent();local target=obj and obj.getContainerIndex and Q.Targets.make(obj,obj:getContainerIndex(root),player)
 if target then return {object=Q.Targets.descriptor(target),bags=ids} end
end
local function vehicleRoot(hint)
 if not integer(hint.vehicle) or not integer(hint.index) or hint.index>2048 or type(hint.part)~='string' or #hint.part<1 or #hint.part>128 or hint.part:find('%c') then return end
 if type(getVehicleById)~='function' then return end
 local vehicle=getVehicleById(hint.vehicle)
 if not vehicle or not vehicle.getPartByIndex then return end
 local part=vehicle:getPartByIndex(hint.index)
 if not part or part:getVehicle()~=vehicle or part:getId()~=hint.part or not part:getItemContainer() then return end
 return {obj=vehicle,part=part,ci=hint.index,container=part:getItemContainer()}
end
function C.valid(t,player,access)
 if not t or not t.external or not t.root or not t.square then return false end
 local root=t.root;local sq=root.obj:getSquare()
 if sq~=t.square or not sq or getCell():getGridSquare(sq:getX(),sq:getY(),sq:getZ())~=sq then return false end
 if root.part then
  if getVehicleById(root.obj:getId())~=root.obj or root.obj:getPartByIndex(root.ci)~=root.part
   or root.part:getItemContainer()~=root.container then return false end
  if t.instance and root.part:getModData().B47QMSourceInstance~=t.instance then return false end
  if access and (not root.part:getArea() or not Q.Targets.sameFloor(player,sq)
   or not root.obj:isInArea(root.part:getArea(),player) or not root.obj:canAccessContainer(root.ci,player)) then return false end
  if (isClient() or isServer()) and (not SafeHouse or not SafeHouse.isSafehouseAllowLoot(sq,player)) then return false end
 elseif not Q.Targets.valid(root,player) or t.instance and root.obj:getModData().B47MovementInstance~=t.instance then return false end
 if path(root.container,t.bags,t.refs)~=t.container then return false end
 return Q.RoomAccess.can(player,root,'inspect') and Q.RoomAccess.can(player,root,'withdraw')
end
function C.capture(player,hint,session)
 if isClient() or type(hint)~='table' or getmetatable(hint) then return end
 local root
 if hint.vehicle~=nil then root=vehicleRoot(hint)
 elseif type(hint.object)=='table' then
  local wanted=Q.Targets.resolve(hint.object,player)
  if wanted then for token,record in pairs(session.records) do
   local live=Q.Bindings.target(player,session.id,token)
   if live and live.target.obj==wanted.obj and live.target.container==wanted.container then root=live.target;break end
  end end
 end
 if not root then return end
 local container,refs=path(root.container,hint.bags)
 if not container then return end
 local t={external=true,obj=root.obj,ci=root.ci,container=container,root=root,bags=copyIds(hint.bags),refs=refs,square=root.obj:getSquare()}
 if not C.valid(t,player,true) then return end
 if not root.part then
  local sq=t.square
  if not Q.Targets.sameFloor(player,sq) or math.max(math.abs(player:getX()-sq:getX()),math.abs(player:getY()-sq:getY()))>2 then return end
 end
 return t
end
function C.identity(t,fresh)
 local root=t.root;local meta
 if root.part then
  local marker=markers[root.part]
  if not marker then marker=fresh();markers[root.part]=marker end
  if root.part:getModData().B47QMSourceInstance~=marker then
   root.part:getModData().B47QMSourceInstance=marker;root.obj:transmitPartModData(root.part)
  end
  meta={vehicle=root.obj:getId(),part=root.part:getId(),index=root.ci,ci=root.ci,instance=marker,
   x=t.square:getX(),y=t.square:getY(),z=t.square:getZ()}
 else meta=Q.Movement.identity(root) end
 t.instance=meta.instance;meta.external=true;meta.bags=copyIds(t.bags);return meta
end
function C.resolve(meta,player)
 if type(meta)~='table' or type(meta.instance)~='string' then return end
 for _,key in ipairs({'x','y','z','ci'}) do
  local n=meta[key];if type(n)~='number' or n~=n or math.abs(n)>10000000 or n%1~=0 then return end
 end
 if meta.ci<0 or meta.ci>2048 then return end
 local root
 if meta.vehicle~=nil then root=vehicleRoot(meta)
 else
  local sq=getCell():getGridSquare(meta.x,meta.y,meta.z)
  if sq then local objects=sq:getObjects()
   for n=0,objects:size()-1 do
    local obj=objects:get(n)
    if obj:getModData().B47MovementInstance==meta.instance then
     if root then return end
     root=Q.Targets.make(obj,meta.ci,player)
    end
   end
  end
 end
 if not root then return end
 local sq=root.obj:getSquare()
 if not sq or sq:getX()~=meta.x or sq:getY()~=meta.y or sq:getZ()~=meta.z then return end
 local container,refs=path(root.container,meta.bags);if not container then return end
 local t={external=true,obj=root.obj,ci=root.ci,container=container,root=root,bags=meta.bags,refs=refs,square=sq,instance=meta.instance}
 if C.valid(t,player,false) then return t end
end
function C.reachable(t,player)
 if not C.valid(t,player,true) then return false end
 if t.root.part then return Q.Targets.sameFloor(player,t.square) end
 return Q.Targets.sameFloor(player,t.square) and math.max(math.abs(player:getX()-t.square:getX()),math.abs(player:getY()-t.square:getY()))<=2
end
return C
