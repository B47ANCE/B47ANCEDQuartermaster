-- Versioned, authority-only extension surface. No command handler or callback
-- supplied over the network can call this API. Consumers submit intent to their
-- own authenticated authority and retain their job/timing guards on returned actions.
B47ANCEDQuartermaster=B47ANCEDQuartermaster or {}
local I=require 'B47ANCEDQuartermaster/Identity'
local C=require 'B47ANCEDQuartermaster/Compatibility'
local A={version=1,ready=true}
B47ANCEDQuartermaster.SupplyAPI=A
local function boolean(fn,...)
 local ok,result=pcall(fn,...);return ok and result==true
end
function A.capabilities() return {api=1,version=I.version,configuredStorage=1,nativeTransfer=1} end
function A.prepare()
 local allowed,_,_,why=C.allowed();if not allowed then return false,why end
 if not isClient() then require 'B47ANCEDQuartermaster/Authority' end
 return true
end
local function actorAvailable(actor)
 if isClient() or not actor or actor:isDead() then return false end
 if isServer() then
  local online=getOnlinePlayers();local found=false
  if online:size()>1024 then return false end
  for n=0,online:size()-1 do if online:get(n)==actor then found=true;break end end
  if not found then return false end
 elseif getSpecificPlayer(actor:getPlayerNum())~=actor then return false end
 local q=B47ANCEDQuartermaster;local movement=q and q.Movement
 return not (movement and (movement.runs and movement.runs[actor] or movement.operations and movement.operations[actor]))
end
function A.actorAvailable(actor) return boolean(actorAvailable,actor) end
local function configured(actor,record)
 if not actorAvailable(actor) or type(record)~='table' then return false end
 local q=B47ANCEDQuartermaster
 if not q or not q.Targets or not q.Store or not q.Presets or not q.Targets.valid(record,actor) then return false end
 local config=q.Store.load(record,actor);local effective=config and q.Presets.resolve(config)
 if not effective then return false end
 for _,field in ipairs({'cats','items'}) do for _ in pairs(effective[field] or {}) do return true end end
 return false
end
function A.configuredStorage(actor,record) return boolean(configured,actor,record) end
local function storage(actor,r,action)
 if not actorAvailable(actor) or type(r)~='table' or action~='withdraw' and action~='deposit' then return false end
 local sq=r.obj and r.obj:getSquare()
 if not sq or sq~=r.square or getCell():getGridSquare(sq:getX(),sq:getY(),sq:getZ())~=sq or r.obj:getObjectIndex()<0
  or type(r.ci)~='number' or r.ci~=math.floor(r.ci) or r.ci<0 or r.ci>=r.obj:getContainerCount()
  or r.obj:getContainerByIndex(r.ci)~=r.container or r.container:getType()=='floor' or r.container:getContainingItem()
  or not configured(actor,r) then return false end
 local rooms=require 'B47ANCEDRooms/API'
 if rooms.canAccessAt(actor,sq:getX(),sq:getY(),sq:getZ(),action).state~='allow' then return false end
 if action=='withdraw' and rooms.canAccessAt(actor,sq:getX(),sq:getY(),sq:getZ(),'inspect').state~='allow' then return false end
 return true
end
local function cleanItem(item)
 return item and not item:isFavorite() and not item:getIsCraftingConsumed() and item:getAttachedSlot()==-1
  and item:getType()~='CandleLit' and item:getType()~='Lantern_HurricaneLit'
end
local function contains(container,item)
 return container and item and container:getItemWithID(item:getID())==item and item:getContainer()==container
end
local function allowed(actor,r,action)
 if not storage(actor,r,action) or not cleanItem(r.item) then return false end
 local src=action=='withdraw' and r.container or actor:getInventory()
 local dst=action=='withdraw' and actor:getInventory() or r.container
 return contains(src,r.item) and not r.item:isEquipped() and src:isRemoveItemAllowed(r.item)
  and dst:isItemAllowed(r.item) and dst:hasRoomFor(actor,r.item)
end
function A.storageAllowed(actor,record,action) return boolean(allowed,actor,record,action) end
function A.storageItems(actor,record)
 local ok,items,why=pcall(function()
  if not storage(actor,record,'withdraw') then return nil,'unavailable' end
  local list=record.container:getItems()
  if list:size()>4096 then return nil,'inventoryTooLarge' end -- technical traversal bound
  return list
 end)
 if not ok then return nil,'unavailable' end
 return items,why
end
function A.transferAction(actor,record,direction,seconds)
 if direction~='fetch' and direction~='return' or type(seconds)~='number' or seconds~=math.floor(seconds) or seconds<1 or seconds>10 then return nil,'invalid' end
 local access=direction=='fetch' and 'withdraw' or 'deposit'
 if not A.storageAllowed(actor,record,access) then return nil,'unavailable' end
 require 'TimedActions/ISTransferAction'
 require 'TimedActions/ISBaseTimedAction'
 -- Retain exact original references; edits to the caller's table cannot rebind a grant.
 local r={obj=record.obj,square=record.square,ci=record.ci,container=record.container,item=record.item}
 local source=direction=='fetch' and r.container or actor:getInventory()
 local destination=direction=='fetch' and actor:getInventory() or r.container
 local created=getTimestampMs();local started,closed=false,false
 local a=ISBaseTimedAction:new(actor);a.maxTime=seconds*50;a.item=r.item;a.srcContainer=source;a.destContainer=destination
 local function valid(self)
  if closed or self~=a or self.character~=actor or self.item~=r.item or self.srcContainer~=source or self.destContainer~=destination
   or getTimestampMs()-created>=120000 or not A.storageAllowed(actor,r,access) then return false end
  local stand=actor:getCurrentSquare();local sq=r.square
  return stand and stand:getZ()==sq:getZ() and math.max(math.abs(stand:getX()-sq:getX()),math.abs(stand:getY()-sq:getY()))<=1
   and (stand==sq or not stand:isBlockedTo(sq))
 end
 function a:isValid() return boolean(valid,self) end
 function a:serverStart()
  if started or not self:isValid() then return false end
  started=true;return true
 end
 function a:start()
  if not started or not self:isValid() then return end
  self.character:faceThisObject(r.obj);self:setActionAnim('Loot');self.character:reportEvent('EventLootItem')
 end
 function a:complete()
  if not started or not self:isValid() then return false end
  closed=true -- latch before native mutation; no replay, substitution or reentry
  local item=ISTransferAction:transferItem(actor,r.item,source,destination,nil)
  if item~=r.item or source:getItemWithID(item:getID())~=nil or not contains(destination,item) then return false end
  if isServer() then sendAddItemToContainer(destination,item) end
  return true
 end
 function a:serverStop() closed=true end
 function a:stop() closed=true;ISBaseTimedAction.stop(self) end
 function a:forceCancel() closed=true end
 return a
end
return A
