-- Provider tests use the actual native transfer helper with disposable engine doubles.
local cases=0;local server,client,clock=false,false,0
isServer=function() return server end;isClient=function() return client end
getTimestampMs=function() return clock end
getActivatedMods=function() return {size=function() return 2 end,get=function(_,n) return n==0 and 'B47ANCEDQuartermaster' or 'B47ANCEDRooms' end} end
instanceof=function() return false end
triggerEvent=function() end
package.loaded['B47ANCEDQuartermaster/Authority']=true
local rooms={canAccessAt=function(_,x,y,z,action) return {state='allow'} end}
package.loaded['B47ANCEDRooms/API']=rooms
ISBaseObject={derive=function(self,name) local t={Type=name};t.__index=t;setmetatable(t,{__index=self});return t end}
package.loaded['ISBaseObject']=ISBaseObject
ISBaseTimedAction={new=function(self,actor) return setmetatable({character=actor},{__index=self}) end,
 stop=function(self) self.stopped=true end}
package.loaded['TimedActions/ISBaseTimedAction']=true
dofile(GAME_ROOT..'/media/lua/shared/TimedActions/ISTransferAction.lua')
package.loaded['TimedActions/ISTransferAction']=true
local A=require 'B47ANCEDQuartermaster/SupplyAPI'
local C=require 'B47ANCEDQuartermaster/Compatibility'
local function list(t) return {size=function() return #t end,get=function(_,n) return t[n+1] end} end
local function check(name,fn) local ok,e=pcall(fn);assert(ok,name..': '..tostring(e));cases=cases+1 end
local function fixture()
 server=false;client=false;clock=0
 local sq={getX=function() return 10 end,getY=function() return 10 end,getZ=function() return 0 end,isBlockedTo=function() return false end}
 local function container()
  local c={items={}}
  function c:getItems() local t={};for _,v in pairs(self.items) do t[#t+1]=v end;return list(t) end
  function c:getItemWithID(id) return self.items[id] end
  function c:getType() return self.kind or 'crate' end
  function c:getContainingItem() return self.containing end
  function c:getParent() return nil end
  function c:isRemoveItemAllowed() return not self.denyRemove end
  function c:isItemAllowed() return not self.denyAdd end
  function c:hasRoomFor() return not self.full end
  function c:DoRemoveItem(i) self.items[i:getID()]=nil;i.container=nil end
  function c:AddItem(i) self.items[i:getID()]=i;i.container=self;return i end
  return c
 end
 local storage,inventory=container(),container()
 local item={id=1,container=storage}
 function item:getID() return self.id end
 function item:getContainer() return self.container end
 function item:isFavorite() return self.favorite==true end
 function item:getIsCraftingConsumed() return self.consumed==true end
 function item:getAttachedSlot() return self.attached or -1 end
 function item:isEquipped() return self.equipped==true end
 function item:getType() return self.kind or 'Bleach' end
 storage.items[1]=item
 local actor={}
 function actor:isDead() return self.dead==true end
 function actor:getPlayerNum() return 0 end
 function actor:getInventory() return inventory end
 function actor:getCurrentSquare() return self.stand or sq end
 function actor:removeAttachedItem() end
 function actor:isEquipped() return false end
 local obj={}
 function obj:getSquare() return self.removed and nil or sq end
 function obj:getObjectIndex() return self.removed and -1 or 0 end
 function obj:getContainerCount() return 1 end
 function obj:getContainerByIndex(n) return n==0 and (self.replacement or storage) or nil end
 local record={obj=obj,square=sq,container=storage,ci=0,item=item}
 local f={actor=actor,item=item,storage=storage,inventory=inventory,obj=obj,square=sq,record=record,adds=0,removes=0}
 getSpecificPlayer=function() return actor end;getOnlinePlayers=function() return list({actor}) end
 getCell=function() return {getGridSquare=function() return sq end} end
 rooms.canAccessAt=function(_,x,y,z,action) return {state=f.denied==action and 'deny' or 'allow'} end
 B47ANCEDQuartermaster={Movement={runs={},operations={}},Targets={valid=function(r,a) return r.obj==obj and r.container==storage end},
 Store={load=function() if not f.unconfigured then return {cats={supplies=true}} end end},Presets={resolve=function(c) return c end}}
 sendAddItemToContainer=function() f.adds=f.adds+1 end
 sendRemoveItemFromContainer=function() f.removes=f.removes+1 end
 return f
end
check('API capabilities and normal local fetch/return retain exact item and avoid network synchronization',function()
 local f=fixture();assert(A.version==1 and A.capabilities().configuredStorage==1 and A.capabilities().nativeTransfer==1)
 assert(A.prepare() and A.actorAvailable(f.actor) and A.configuredStorage(f.actor,f.record))
 assert(A.storageItems(f.actor,f.record):size()==1)
 local a=assert(A.transferAction(f.actor,f.record,'fetch',1));assert(not a:complete());assert(a:serverStart());assert(a:complete());assert(not a:complete())
 assert(f.inventory:getItemWithID(1)==f.item and not f.storage:getItemWithID(1) and f.adds==0 and f.removes==0)
 a=assert(A.transferAction(f.actor,f.record,'return',1));assert(a:serverStart() and a:complete());assert(f.storage:getItemWithID(1)==f.item)
end)
check('server binding uses online player identity and native synchronization exactly once',function()
 local f=fixture();server=true;local a=assert(A.transferAction(f.actor,f.record,'fetch',1));assert(a:serverStart() and a:complete());assert(not a:complete())
 assert(f.adds==1 and f.removes==1)
end)
for _,kind in ipairs({'client','combined','foreign','offlinePlayer','dead','movement','permission','inspect','configuration','removed','replacement','unloaded','floor','itemOwned','favorite','consumed','equipped','attached','capacity','removeDenied','addDenied','substitution','expired','cancelled','volatile'}) do
 check('transfer admission/completion fails closed on '..kind,function()
  local f=fixture();local a=assert(A.transferAction(f.actor,f.record,'fetch',1));assert(a:serverStart())
  if kind=='client' then client=true
  elseif kind=='combined' then client=true;server=true
  elseif kind=='foreign' then server=true;getOnlinePlayers=function() return list({{}}) end
  elseif kind=='offlinePlayer' then getSpecificPlayer=function() return {} end
  elseif kind=='dead' then f.actor.dead=true
  elseif kind=='movement' then B47ANCEDQuartermaster.Movement.operations[f.actor]={}
  elseif kind=='permission' then f.denied='withdraw'
  elseif kind=='inspect' then f.denied='inspect'
  elseif kind=='configuration' then f.unconfigured=true
  elseif kind=='removed' then f.obj.removed=true
  elseif kind=='replacement' then f.obj.replacement={}
  elseif kind=='unloaded' then getCell=function() return {getGridSquare=function() return nil end} end
  elseif kind=='floor' then f.storage.kind='floor'
  elseif kind=='itemOwned' then f.storage.containing={}
  elseif kind=='favorite' then f.item.favorite=true
  elseif kind=='consumed' then f.item.consumed=true
  elseif kind=='equipped' then f.item.equipped=true
  elseif kind=='attached' then f.item.attached=0
  elseif kind=='capacity' then f.inventory.full=true
  elseif kind=='removeDenied' then f.storage.denyRemove=true
  elseif kind=='addDenied' then f.inventory.denyAdd=true
  elseif kind=='substitution' then a.item={}
  elseif kind=='expired' then clock=120000
  elseif kind=='cancelled' then a:forceCancel()
  elseif kind=='volatile' then f.item.kind='CandleLit' end
  assert(not a:complete());assert(f.storage:getItemWithID(1)==f.item and not f.inventory:getItemWithID(1) and f.adds==0 and f.removes==0)
 end)
end
check('malformed requests and excessive inventories never expose or mutate storage',function()
 local f=fixture();assert(not A.storageAllowed(f.actor,nil,'withdraw') and not A.configuredStorage(nil,f.record))
 for _,s in ipairs({0,11,1.5}) do assert(not A.transferAction(f.actor,f.record,'fetch',s)) end
 assert(not A.transferAction(f.actor,f.record,'destroy',1))
 f.storage.getItems=function() return {size=function() return 4097 end} end
 local items,why=A.storageItems(f.actor,f.record);assert(not items and why=='inventoryTooLarge')
end)
check('unrelated sorting compatibility blocks provider preparation',function()
 fixture();getActivatedMods=function() return list({'Quartermaster'}) end;C.invalidate()
 local ok,why=A.prepare();assert(not ok and why=='IncompatibleMod')
end)
print('PASS OFFLINE SupplyAPI: '..cases..' provider authority, permissions, exact-item, replay and native-helper scenarios')
return cases
