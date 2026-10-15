-- Reuse the allocation picker; Rooms remains the owner of geometry/roles/access.
require 'B47ANCEDQuartermaster/Picker'
local Profile=require 'B47ANCEDQuartermaster/AllocationProfile'
local Allocation=require 'B47ANCEDQuartermaster/AllocationUI'
local Q=B47ANCEDQuartermaster;local U={};Q.RoomAllocationUI=U
local serial=0
local function tr(key,...) return getText('UI_QMSS_'..key,...) end
local function request(p,command,args,done)
 Q.Authority.request(p.playerNum,command,args,function(result) if not p.removed then done(result) end end)
end
local function thresholds(p)
 local menu=B47ANCEDUI.menu(ISContextMenu.get(p.playerNum,getMouseX(),getMouseY()))
 for _,key in ipairs({'primaryAt','secondaryAt'}) do local field=key
  menu:addOption(tr(field=='primaryAt' and 'AllocationPrimaryAt' or 'AllocationSecondaryAt',p.roomWorking[field]),p,function()
   local dialog=ISTextBox:new(0,0,400,190,tr('AllocationExactPrompt'),tostring(p.roomWorking[field]),p,function(owner,b)
    if b.internal~='OK' or owner.removed then return end
    local value=tonumber(b.parent.entry:getInternalText());if Profile.percent(value) then owner.roomWorking[field]=value else owner.title=tr('AllocationInvalid') end
   end,p.playerNum)
   dialog:initialise();dialog:addToUIManager();B47ANCEDUI.Dialog.decorate(dialog,p.playerNum,p);setJoypadFocus(p.playerNum,dialog)
  end)
 end
 if p.grabbedJoypad then setJoypadFocus(p.playerNum,menu) end
end
function U.open(parent,room,profileKey)
 request(parent,'allocationRoomGet',{room=room.id,roomRevision=room.revision,profileKey=profileKey},function(result)
  if result.status~='ok' then parent.title=tr(result.status);return end
  local record=result.record;parent.dimmer:setVisible(true)
  local p=Q.Picker:new(nil,nil,parent.playerNum,{presetName='room',parent=parent,api=parent.api,library=parent.presetLibrary,
   config={cats={},items={},presets=record.presets,priority=record.priority,allocation=record.profile}})
  p.allocationOnly=true;p.requiresAllocationInfo=true;p.allocationInfo=parent.allocationInfo
  parent.childPicker=p
  p.roomWorking=Q.Configuration.clone(record);p.roomDefinition=result.room
  p.allocationRoomArgs={room=result.room.id,roomRevision=result.room.revision,profileKey=result.profileKey,revision=record.revision,libraryRevision=result.libraryRevision}
  local original=Q.Configuration.clone(record)
  p.options.save=function(owner,config)
   if owner.roomPending then return end
   local args=Q.Configuration.clone(owner.allocationRoomArgs);serial=serial+1
   args.nonce=tostring(getTimestampMs())..':room:'..serial;args.profile=config.allocation or Profile.empty();args.presets=config.presets
   args.active=owner.roomWorking.active;args.priority=config.priority;args.primaryAt=owner.roomWorking.primaryAt;args.secondaryAt=owner.roomWorking.secondaryAt
   owner.roomPending=true;owner.btnSave:setEnable(false)
   request(owner,'allocationRoomCommit',args,function(reply)
    owner.roomPending=false;owner.btnSave:setEnable(true)
    if reply.status=='ok' then owner:closePicker() else owner.title=tr(reply.status) end
   end)
  end
  p.allocationRoomDefaults=function()
   request(p,'allocationPreset',{roomType=p.roomDefinition.roomType},function(reply)
    if reply.status=='ok' then Allocation.apply(p,reply.profile) else p.title=tr(reply.status) end
   end)
  end
  p.allocationRoomMenu=function(menu)
   menu:addOption(tr('AllocationThresholds'),p,function() thresholds(p) end)
   menu:addOption(tr('AllocationCancelPending'),p,function()
    p.allocation=Profile.copy(original.profile);p.allocationCacheReady=false;p.roomWorking=Q.Configuration.clone(original)
    p.selectedPresets=Q.Configuration.clone(original.presets);p:setPriority(original.priority);p:rebuild()
   end)
  end
  p:initialise();p:addToUIManager();Q.adapt(p);Q.UI.attach(p);Q.presetEditor=p
  p.title=tr('AllocationRoomTitle',room.name)
  p.chkChecked.onclick=function() p.roomWorking.active=not p.roomWorking.active end
  p.chkContents.onclick=function() thresholds(p) end
  local prerender=p.prerender
  p.prerender=function(self,...)
   prerender(self,...)
   self.chkChecked:setTitle((self.roomWorking.active and '[x] ' or '[ ] ')..tr('AllocationRoomActive'))
   self.chkContents:setTitle(tostring(self.roomWorking.primaryAt)..'% / '..tostring(self.roomWorking.secondaryAt)..'%')
   self.chkContents:setTooltip(tr('AllocationThresholdsTip'));self.priorityLabel:setNameWithoutMoving(tr('AllocationRoomPriority'))
   self.btnModeCat:setTitle(tr('AllocationControl'))
  end
  p:rebuild();p:configJoypad();setJoypadFocus(parent.playerNum,p)
 end)
end
function U.menu(parent)
 request(parent,'allocationRoomList',{},function(result)
  if result.status~='ok' then parent.title=tr(result.status);return end
  local menu=B47ANCEDUI.menu(ISContextMenu.get(parent.playerNum,getMouseX(),getMouseY()))
  for _,room in ipairs(result.rooms) do local r=room
   if #(r.profileKeys or {})>1 then
    local sub=ISContextMenu:getNew(menu);menu:addSubMenu(menu:addOption(r.name),sub)
    for _,key in ipairs(r.profileKeys) do local id=key;sub:addOption(id,parent,function() U.open(parent,r,id) end) end
   else menu:addOption(r.name,parent,function() U.open(parent,r,r.profileKeys and r.profileKeys[1]) end) end
  end
  if #result.rooms==0 then local option=menu:addOption(tr('AllocationNoRooms'));option.notAvailable=true end
  if result.preparing then local option=menu:addOption(tr('AllocationPreparing'));option.notAvailable=true end
  if parent.grabbedJoypad then setJoypadFocus(parent.playerNum,menu) end
 end)
end
return U
