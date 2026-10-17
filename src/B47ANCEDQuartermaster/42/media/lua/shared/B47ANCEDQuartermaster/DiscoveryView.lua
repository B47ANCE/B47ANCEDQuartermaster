-- Presentation scope uses designated Rooms geometry and native buildings only.
local V={};B47ANCEDQuartermaster.DiscoveryView=V
local function tr(key,...) return getText('UI_QMSS_'..key,...) end
function V.metadata(session,targets,player,buildingAllowed)
 local sq=player:getCurrentSquare();local building=sq and sq:getBuilding();local def=building and building:getDef()
 session.rooms={};session.roomLookup=nil
 for _,meta in ipairs(targets) do
  local ts=session.records[meta.token].target.obj:getSquare();local tb=ts:getBuilding()
  meta.room=nil;meta.customRooms=nil;meta.inBuilding=def~=nil and tb~=nil and tb:getDef()==def
 end
 local range=B47ANCEDQuartermaster.Targets.options()
 local custom,revision,world={},0,nil;local current;local R=B47ANCEDQuartermaster.Rooms
 if R and not isClient() then
  custom,revision,world=R.metadata(player);custom=custom or {}
  table.sort(custom,function(a,b) return a.id<b.id end)
  for _,r in ipairs(custom) do local room=R.resolve(player,r.id,r.revision)
   if room then
    if sq and not current and R.contains(player,r.id,r.revision,sq:getX(),sq:getY(),sq:getZ()) then current={id=r.id,revision=r.revision} end
    for _,meta in ipairs(targets) do
     if R.contains(player,r.id,r.revision,meta.x,meta.y,meta.z) then meta.customRooms=meta.customRooms or {};meta.customRooms[r.id]=r.revision end
    end
   end
  end
 end
 local _,whole=B47ANCEDQuartermaster.Targets.options()
 return {rooms={},customRooms=custom,roomsRevision=revision,roomWorld=world,currentCustomRoom=current,maxRadius=range,buildingAvailable=def~=nil and (buildingAllowed==true or session.customRoom~=nil and whole)}
end
function V.default(info)
 local room=info.currentCustomRoom
 return room and {kind='customRoom',room=room.id,revision=room.revision} or {kind='proximity',radius=info.maxRadius}
end
function V.accept(session,result)
 session.viewInfo=result.viewInfo or {rooms={},maxRadius=B47ANCEDQuartermaster.Targets.options(),buildingAvailable=false}
 if result.view then session.view=result.view end
 if not session.view then session.view=V.default(session.viewInfo) end
 if session.view.kind=='room' or session.view.kind=='nativeRoom' then session.view={kind='invalid'} end
end
function V.includes(meta,view,info,player)
 if view.kind=='customRoom' then return meta.customRooms and meta.customRooms[view.room]==view.revision or false end
 if view.kind=='building' then return info.buildingAvailable and meta.inBuilding==true end
 if view.kind=='proximity' then local radius=tonumber(view.radius);return radius and radius==math.floor(radius) and radius>=1 and radius<=info.maxRadius and meta.z==math.floor(player:getZ()) and math.max(math.abs(meta.x-player:getX()),math.abs(meta.y-player:getY()))<=radius end
 return false
end
function V.label(session)
 local v,i=session.view,session.viewInfo
 if not v then return tr('Containers') end
 if v.kind=='customRoom' then for _,room in ipairs(i.customRooms or {}) do if room.id==v.room and room.revision==v.revision then return tr('ScopeRoom',room.label) end end;return tr('RoomUnavailable') end
 if v.kind=='invalid' then return tr('RoomUnavailable') end
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
