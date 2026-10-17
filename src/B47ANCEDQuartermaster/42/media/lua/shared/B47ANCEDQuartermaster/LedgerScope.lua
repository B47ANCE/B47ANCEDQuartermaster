local S={}
local function coord(sq) return {x=sq:getX(),y=sq:getY(),z=sq:getZ()} end
function S.capture(actor,kind)
 local sq=actor:getCurrentSquare();if not sq then return end
 if kind=='safehouse' then
  if not SafeHouse or not SafeHouse.getSafehouseList then return end
  local houses=SafeHouse.getSafehouseList();if houses:size()>1024 then return end
  local found
  for i=0,houses:size()-1 do local h=houses:get(i)
   if sq:getX()>=h:getX() and sq:getX()<h:getX2() and sq:getY()>=h:getY() and sq:getY()<h:getY2() then if found then return end;found=h end
  end
  local cell=getCell()
  if not found or not cell.getMinZ or not cell.getMaxZ then return end
  local min,max=cell:getMinZ(),cell:getMaxZ()
  if max-min>64 then return end
  return {key='safehouse:'..tostring(found:getId()),kind=kind,label=found:getTitle(),origin=coord(sq),bounds={{x1=found:getX(),y1=found:getY(),x2=found:getX2(),y2=found:getY2(),z1=min,z2=max}},house=found}
 end
 if kind~='building' then return end
 local building=sq:getBuilding();local def=building and building:getDef();if not def then return end
 local rooms=def:getRooms();if rooms:size()>256 then return end
 local bounds,ids={},{}
 for i=0,rooms:size()-1 do local rd=rooms:get(i)
  bounds[#bounds+1]={x1=rd:getX(),y1=rd:getY(),x2=rd:getX2(),y2=rd:getY2(),z1=rd:getZ(),z2=rd:getZ()};ids[#ids+1]=tostring(rd:getID())
 end
 table.sort(ids)
 return {key='building:'..table.concat(ids,','),kind=kind,label=getText('UI_QMSS_LedgerBuilding'),origin=coord(sq),bounds=bounds,building=def}
end
function S.signature(scope)
 local out={scope.key};for _,b in ipairs(scope.bounds) do out[#out+1]=table.concat({b.x1,b.y1,b.x2,b.y2,b.z1,b.z2},':') end
 return table.concat(out,'|')
end
function S.includes(scope,sq)
 if not sq then return false end
 if scope.kind=='building' then local b=sq:getBuilding();return b and b:getDef()==scope.building end
 local h=scope.house
 return h and sq:getX()>=h:getX() and sq:getX()<h:getX2() and sq:getY()>=h:getY() and sq:getY()<h:getY2()
end
function S.cursor(scope)
 local cells=0
 for _,b in ipairs(scope.bounds) do cells=cells+(b.x2-b.x1)*(b.y2-b.y1)*(b.z2-b.z1+1) end
 if cells<1 or cells>262144 then return nil end
 local c={i=1,visited={},count=0}
 -- Visit the character's floor before unused upper/basement levels.
 local function levels(b)
  local a={};for z=b.z1,b.z2 do a[#a+1]=z end
  table.sort(a,function(x,y) local dx,dy=math.abs(x-scope.origin.z),math.abs(y-scope.origin.z);return dx==dy and x<y or dx<dy end)
  return a
 end
 function c.next()
  local b=scope.bounds[c.i];if not b then return end
  if not c.x then c.x,c.y=b.x1,b.y1;c.levels=levels(b);c.level=1;c.z=c.levels[1] end
  local p={x=c.x,y=c.y,z=c.z};c.x=c.x+1
  if c.x>=b.x2 then c.x=b.x1;c.y=c.y+1 end
  if c.y>=b.y2 then c.y=b.y1;c.level=c.level+1;c.z=c.levels[c.level] end
  if not c.z then c.i=c.i+1;c.x=nil end
  c.count=c.count+1;return p
 end
 return c
end
function S.room(actor,sq)
 local api,state=B47ANCEDQuartermaster.RoomAccess.service()
 if state=='unknown' then return end
 if api then
  local result=api.roomsAt(actor,sq:getX(),sq:getY(),sq:getZ())
  if result.status~='ok' then return end
  local rooms={};for _,room in ipairs(result.rooms) do if B47ANCEDQuartermaster.RoomAccess.designated(room) then rooms[#rooms+1]=room end end
  table.sort(rooms,function(a,b) return a.id<b.id end)
  if rooms[1] then return rooms[1].id,rooms[1].name or rooms[1].label end
 end
 -- Building capture/signatures retain internal native geometry for existing ledgers.
 -- These row labels are presentation only and never establish access or scope.
 return 'unassigned:'..sq:getZ(),getText('UI_QMSS_LedgerUnassigned')
end
return S
