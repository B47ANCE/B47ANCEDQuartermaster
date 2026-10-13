-- Ephemeral exact world references; never persistent item decoration markers.
local G={};B47ANCEDQuartermaster.GroundSources=G
local T=B47ANCEDQuartermaster.Targets
local function integer(n) return type(n)=='number' and n==n and math.abs(n)<=2147483648 and n==math.floor(n) end
function G.valid(t,player)
 local ok,value=pcall(function()
  if not t or not t.ground or not t.obj or not t.item then return false end
  local sq=t.obj:getSquare();if not sq or not T.sameFloor(player,sq) or getCell():getGridSquare(sq:getX(),sq:getY(),sq:getZ())~=sq then return false end
  if not sq:getWorldObjects():contains(t.obj) or t.obj:getItem()~=t.item or t.item:getWorldItem()~=t.obj then return false end
  if sq:isBlockedTo(player:getCurrentSquare()) then return false end
  if (isClient() or isServer()) and (not SafeHouse or not SafeHouse.isSafehouseAllowLoot(sq,player)) then return false end
  return t.item:getContainer()==t.container
 end)
 return ok and value==true
end
local function resolve(meta,player)
 if type(meta)~='table' or meta.ground~=true then return end
 for _,k in ipairs({'x','y','z','itemID'}) do if not integer(meta[k]) then return end end
 if math.abs(meta.x)>10000000 or math.abs(meta.y)>10000000 or math.abs(meta.z)>10000000 then return end
 local sq=getCell():getGridSquare(meta.x,meta.y,meta.z);if not sq then return end
 local found;local objects=sq:getWorldObjects();if objects:size()>4096 then return end
 for i=0,objects:size()-1 do
  local obj=objects:get(i);local it=obj:getItem()
  if it and it:getID()==meta.itemID then
   if found then return end
   found={ground=true,obj=obj,item=it,container=it:getContainer(),ci=0}
  end
 end
 if G.valid(found,player) then return found end
end
function G.resolve(meta,player)
 local ok,t=pcall(resolve,meta,player);if ok then return t end
end
function G.descriptor(t)
 local s=t.obj:getSquare();return {ground=true,x=s:getX(),y=s:getY(),z=s:getZ(),itemID=t.item:getID()}
end
local function hints(container,player)
 local items=container:getItems();if items:size()>4096 then return end
 local hints,seen={},{}
 for i=0,items:size()-1 do
  local it=items:get(i);local world=it:getWorldItem()
  if not seen[it] then
   local hint
   if world and world:getSquare() then hint=G.descriptor({obj=world,item=it})
   else
    local c=it:getContainer();local obj=c and c:getParent();local t=obj and T.make(obj,obj:getContainerIndex(c),player)
    if not t then return end
    hint=T.descriptor(t);hint.itemID=it:getID();hint.physical=true
   end
   hints[#hints+1]=hint;seen[it]=true
  end
 end
 return hints
end
function G.hints(container,player)
 local ok,result=pcall(hints,container,player);if ok then return result end
end
function G.snapshot(player,hints,session)
 if isClient() then return end
 if type(hints)~='table' or #hints<1 or #hints>4096 then return end
 local count=0;for k in pairs(hints) do if not integer(k) or k<1 or k>#hints then return end;count=count+1 end
 if count~=#hints then return end
 local bound=B47ANCEDQuartermaster.Bindings.session(player,session)
 local physical={};local squareCache={}
 local function key(h) return h.x..':'..h.y..':'..h.z..':'..h.index..':'..h.ci end
 if bound then
  for _,record in pairs(bound.records) do
   if not record.revoked and T.valid(record.target,player) then physical[key(T.descriptor(record.target))]=record end
  end
 end
 local records,items={},{}
 for _,hint in ipairs(hints) do
  if type(hint)~='table' or not integer(hint.itemID) then return end
  for _,k in ipairs({'x','y','z'}) do if not integer(hint[k]) or math.abs(hint[k])>10000000 then return end end
  local t
  if hint.physical==true then
   if not integer(hint.index) or not integer(hint.ci) then return end
   local record=physical[key(hint)]
   local it=record and record.target.container:getItemWithID(hint.itemID)
   if it then t={obj=record.target.obj,ci=record.target.ci,container=record.target.container,item=it,record=record} end
  elseif hint.ground==true then
   local squareKey=hint.x..':'..hint.y..':'..hint.z
   local index=squareCache[squareKey]
   if not index then
    local sq=getCell():getGridSquare(hint.x,hint.y,hint.z);if not sq then return end
    local objects=sq:getWorldObjects();if objects:size()>4096 then return end
    index={};squareCache[squareKey]=index
    for i=0,objects:size()-1 do
     local obj=objects:get(i);local it=obj:getItem()
     if it then local id=it:getID();if index[id]~=nil then index[id]=false else index[id]={ground=true,obj=obj,item=it,container=it:getContainer(),ci=0} end end
    end
   end
   t=index[hint.itemID]
   if t and not G.valid(t,player) then return end
  end
  if not t then return end
  local s=t.obj:getSquare()
  local range=T.options()
  if t.ground and math.max(math.abs(player:getX()-s:getX()),math.abs(player:getY()-s:getY()))>range then return end
  local id=t.item:getID();if records[id] and records[id].obj~=t.obj then return end
  if not records[id] then records[id]=t;items[#items+1]=t.item end
 end
 local proxy={groundRecords=records}
 function proxy:getItems() return {size=function() return #items end,get=function(_,i) return items[i+1] end} end
 function proxy:getItemWithID(id) local t=records[id];return t and (t.ground and G.valid(t,player) or not t.ground and T.valid(t,player) and t.container:getItemWithID(id)==t.item) and t.item or nil end
 return proxy
end
return G
