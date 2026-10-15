-- Presentation scope over one server-discovered physical target set.
local V={};B47ANCEDQuartermaster.DiscoveryView=V
local function tr(key,...) return getText('UI_QMSS_'..key,...) end
local function roomDef(sq) local room=sq and sq.getRoom and sq:getRoom();return room and room:getRoomDef() end
function V.metadata(session,targets,player,buildingAllowed)
 local sq=player:getCurrentSquare();local building=sq and sq:getBuilding();local def=building and building:getDef()
 local rooms={};session.roomLookup=session.roomLookup or {};session.rooms={}
 local defs=def and def:getRooms()
 if defs then for i=0,defs:size()-1 do
  local rd=defs:get(i)
  if rd.getID and rd.getName and rd.getZ and rd.getX and rd.getY then
  local token=session.roomLookup[rd]
  if not token then session.roomSerial=(session.roomSerial or 0)+1;token=session.id..':room:'..session.roomSerial;session.roomLookup[rd]=token end
  local name=rd.getName and rd:getName() or tr('UnnamedRoom')
  local localized=getTextOrNull and getTextOrNull('IGUI_RoomType_'..name)
  local meta={token=token,name=localized or name,z=rd:getZ(),x=rd:getX(),y=rd:getY(),physicalID=tostring(rd:getID())}
  rooms[#rooms+1]=meta;session.rooms[token]=rd
 end end end
 table.sort(rooms,function(a,b) for _,k in ipairs({'z','y','x','physicalID'}) do if a[k]~=b[k] then return a[k]<b[k] end end;return a.token<b.token end)
 local counts,number={},{};for _,m in ipairs(rooms) do counts[m.name]=(counts[m.name] or 0)+1 end
 for _,m in ipairs(rooms) do number[m.name]=(number[m.name] or 0)+1;m.label=counts[m.name]>1 and tr('RoomNumber',m.name,number[m.name]) or m.name end
 local current=roomDef(sq);local currentRoom=current and session.roomLookup[current]
 for _,meta in ipairs(targets) do
  local t=session.records[meta.token].target;local ts=t.obj:getSquare();local tb=ts:getBuilding()
  local rd=roomDef(ts);meta.room=rd and session.roomLookup[rd] or nil;meta.inBuilding=def~=nil and tb~=nil and tb:getDef()==def
 end
 local range=B47ANCEDQuartermaster.Targets.options()
 local custom,revision,world={},0,nil;local R=B47ANCEDQuartermaster.Rooms
 if R and not isClient() then
  custom,revision,world=R.metadata(player);custom=custom or {}
  for _,r in ipairs(custom) do local room,g=R.resolve(player,r.id,r.revision)
   if room then for _,meta in ipairs(targets) do
    if B47ANCEDQuartermaster.RoomGeometry.contains(g,meta.x,meta.y,meta.z) then meta.customRooms=meta.customRooms or {};meta.customRooms[r.id]=r.revision end
   end end
  end
 end
 local _,whole=B47ANCEDQuartermaster.Targets.options()
 return {rooms=rooms,customRooms=custom,roomsRevision=revision,roomWorld=world,currentRoom=currentRoom,maxRadius=range,buildingAvailable=def~=nil and (buildingAllowed==true or session.customRoom~=nil and whole)}
end
function V.accept(session,result)
 session.viewInfo=result.viewInfo or {rooms={},maxRadius=B47ANCEDQuartermaster.Targets.options(),buildingAvailable=false}
 if result.view then session.view=result.view end
 if not session.view then session.view=session.viewInfo.currentRoom and {kind='room',room=session.viewInfo.currentRoom} or {kind='proximity',radius=session.viewInfo.maxRadius} end
end
function V.includes(meta,view,info,player)
 if view.kind=='customRoom' then return meta.customRooms and meta.customRooms[view.room]==view.revision or false end
 if view.kind=='room' then return meta.room~=nil and meta.room==view.room end
 if view.kind=='building' then return info.buildingAvailable and meta.inBuilding==true end
 if view.kind=='proximity' then local radius=tonumber(view.radius);return radius and radius==math.floor(radius) and radius>=1 and radius<=info.maxRadius and meta.z==math.floor(player:getZ()) and math.max(math.abs(meta.x-player:getX()),math.abs(meta.y-player:getY()))<=radius end
 return false
end
function V.label(session)
 local v,i=session.view,session.viewInfo
 if not v then return tr('Containers') end
 if v.kind=='customRoom' then for _,room in ipairs(i.customRooms or {}) do if room.id==v.room and room.revision==v.revision then return tr('ScopeRoom',room.label) end end;return tr('RoomUnavailable') end
 if v.kind=='room' then for _,room in ipairs(i.rooms) do if room.token==v.room then return tr('ScopeRoom',room.label) end end;return tr('RoomUnavailable') end
 return v.kind=='building' and tr('ScopeBuilding') or tr('ScopeProximity',v.radius)
end
function V.rows(session,player,expanded)
 local groups,order={},{}
 for _,r in ipairs(session.targets) do r.nested=false;if V.includes(r.target,session.view,session.viewInfo,player) then
  local key=r.target.group or r.token;local group=groups[key]
  if not group then group={key=key,children={},distance=math.huge,sameFloor=false};groups[key]=group;order[#order+1]=group end
  group.children[#group.children+1]=r
  local m=r.target;local same=m.z==math.floor(player:getZ());local distance=(m.x-player:getX())^2+(m.y-player:getY())^2
  if same and not group.sameFloor then group.sameFloor=true;group.distance=distance elseif same==group.sameFloor then group.distance=math.min(group.distance,distance) end
 end end
 table.sort(order,function(a,b) if a.sameFloor~=b.sameFloor then return a.sameFloor end;if a.distance~=b.distance then return a.distance<b.distance end;return a.key<b.key end)
 local rows={}
 for _,group in ipairs(order) do
  table.sort(group.children,function(a,b) local x,y=a.target,b.target;for _,k in ipairs({'z','y','x','index','ci'}) do if x[k]~=y[k] then return x[k]<y[k] end end;return a.token<b.token end)
  local first=group.children[1]
  if first.target.group then
   local parent=session:parent(first.target.group)
   parent.partial=#group.children<(first.target.groupCount or #group.children);parent.visibleChildren=group.children
   rows[#rows+1]=parent
   if expanded[group.key] then for _,r in ipairs(group.children) do r.nested=true;rows[#rows+1]=r end end
  else rows[#rows+1]=first end
 end
 return rows
end
return V
