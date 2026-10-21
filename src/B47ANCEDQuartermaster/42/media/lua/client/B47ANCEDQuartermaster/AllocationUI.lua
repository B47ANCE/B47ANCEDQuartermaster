local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
-- Virtual allocation controls: draw only visible rows; one drag/dialog at a time.
local Profile=require 'B47ANCEDQuartermaster/AllocationProfile'
local Migration=require 'B47ANCEDQuartermaster/Migration'
local Q=B47ANCEDQuartermaster;local U={};Q.AllocationUI=U
local indexes=setmetatable({},{__mode='k'})
local function tr(key,...) return getText('UI_QMSS_'..key,...) end
function U.index(p)
 local api=p.qmss and p.qmss.catalog or p.api
 if not api or type(api.entries)~='table' then return end
 if not indexes[api] then
  local index=Profile.index(api.entries,Q.Categorizer)
  if not index then return end
  index.names={}
  for full,row in pairs(index.items) do local category=row.path[#row.path];local key=category..'\0'..(row.name or '')
   index.names[key]=index.names[key] or {};table.insert(index.names[key],full)
  end
  for _,values in pairs(index.names) do table.sort(values) end
  indexes[api]=index
 end
 return indexes[api]
end
function U.rows(p,rows)
 local index=U.index(p);if not index then return rows end
 local out={}
 for _,row in ipairs(rows) do
  local types=row.kind=='item' and index.names[(row.group.key or '')..'\0'..row.key]
  if types and #types>0 then
   for _,full in ipairs(types) do
    local exact={};for k,v in pairs(row) do exact[k]=v end
    exact.allocationFullType=full;exact.id=row.id..'\0type:'..full
    exact.allocationLabel=#types>1 and row.key..' ['..full..']' or row.key
    out[#out+1]=exact
   end
  else out[#out+1]=row end
 end
 return out
end
local function effective(p)
 local signature=p.qmss and p.qmss.presetSignature
 if p.allocationCacheProfile~=p.allocation or p.allocationCacheSignature~=signature or not p.allocationCacheReady then
  p.allocationCacheProfile=p.allocation;p.allocationCacheSignature=signature;p.allocationCacheReady=true;p.allocationStates={}
  p.allocationEffective=Q.Schema.effective({cats={},items={},presets=p.selectedPresets or {},priority=0,allocation=p.allocation},p:getPresetStore()).allocation
 end
 return p.allocationEffective
end
function U.state(p,row)
 local index=U.index(p);if not index or row.kind=='mod' then return nil,'unavailable' end
 if p.requiresAllocationInfo then
  local info=p.allocationInfo or p.options.parent and p.options.parent.allocationInfo
  if not info then return nil,'unavailable' end
  if row.kind~='item' and not info.categories[row.group.key] then return nil,'unavailable' end
 end
 local profile=effective(p)
 if row.kind=='item' then
  local full=row.allocationFullType;local entry=full and index.items[full]
  if not entry then return nil,'unavailable' end
  return Profile.value(profile,full,entry.path)
 end
 local key=row.group and row.group.key;if not key then return nil,'unavailable' end
 local cached=p.allocationStates[key]
 if not cached then local value,state=Profile.state(profile,key,index);cached={value=value,state=state};p.allocationStates[key]=cached end
 return cached.value,cached.state
end
function U.geometry(list)
 local right=list:getWidth()-(list:isVScrollBarVisible() and list.vscroll:getWidth() or 0)
 local font=getTextManager():getFontHeight(UIFont.Small)
 local label=getTextManager():MeasureStringX(UIFont.Small,'~ 100%')+10
 label=math.max(label,getTextManager():MeasureStringX(UIFont.Small,tr('AllocationMixed'))+10)
 local width=math.min(280,math.max(150,font*10,label+55));local left=math.max(100,right-width-29)
 return left,right-29,math.max(20,right-29-left-label-8)
end
function U.draw(p,list,y,height,row)
 local value,state=U.state(p,row);if state=='unavailable' then
  if row.kind~='mod' and p.requiresAllocationInfo then local left=U.geometry(list)
   SharedUI.Renderer.text(list,tr('AllocationUnavailable'),left,y+3,SharedUI.Theme.colors.muted,UIFont.Small)
  end
  return
 end
 local left,right,track=U.geometry(list);local renderer=SharedUI.Renderer;local colors=SharedUI.Theme.colors
 renderer.rect(list,left-3,y,right-left+6,height-1,colors.raised)
 local lineY=y+height/2;renderer.rect(list,left,lineY-1,track,2,colors.border)
 if value~=nil then
  renderer.rect(list,left,lineY-1,track*value/100,2,colors.accent)
  renderer.rect(list,left+track*value/100-2,lineY-5,4,10,colors.accent)
 end
 local text=state=='mixed' and tr('AllocationMixed') or (state=='legacy' and 'L ' or state=='explicit' and '= ' or '~ ')..tostring(value)..'%'
 renderer.text(list,renderer.fit(text,right-left-track-4,UIFont.Small),left+track+6,y+(height-getTextManager():getFontHeight(UIFont.Small))/2,state=='explicit' and colors.accent or colors.text,UIFont.Small)
end
function U.set(p,row,value,base)
 if p.qmss and p.qmss.model.readOnly or not Profile.percent(value) then return false end
 local _,state=U.state(p,row);if state=='unavailable' then return false end
 local index=U.index(p);if not index then return false end
 local original=base or p.allocation or Profile.empty();local changed,e
 if row.kind=='item' then
  local full=row.allocationFullType;local entry=full and index.items[full]
  if not entry then return false end
  changed,e=Profile.setItem(original,full,value,entry.path)
 elseif row.kind=='category' or row.kind=='subcategory' then changed,e=Profile.setCategory(original,row.group.key,value,index)
 else return false end
 if not changed then p.title=tr(e or 'invalid');return false end
 p.allocation=changed;p.allocationCacheReady=false
 local session=p.containerUI and p.containerUI.session
 if session and session.selected and not session.binding then session.selected.working.allocation=changed;session.selected.dirty=session:dirty(session.selected) end
 return true
end
function U.reset(p,row)
 if p.qmss.model.readOnly or not p.allocation then return end
 p.allocation=row.kind=='item' and Profile.reset(p.allocation,'item',row.allocationFullType) or Profile.resetBranch(p.allocation,row.group.key,U.index(p))
 p.allocationCacheReady=false
 local session=p.containerUI and p.containerUI.session
 if session and session.selected then session.selected.working.allocation=p.allocation;session.selected.dirty=session:dirty(session.selected) end
end
function U.exact(p,row)
 local value,state=U.state(p,row);if state=='unavailable' or p.qmss.model.readOnly then return end
 local dialog=ISTextBox:new(0,0,380,190,tr('AllocationExactPrompt'),tostring(value or 100),p,function(owner,button)
  if button.internal~='OK' or owner.removed then return end
  local input=tonumber(button.parent.entry:getInternalText())
  if not Profile.percent(input) then owner.title=tr('AllocationInvalid');return end
  U.set(owner,row,input)
 end,p.playerNum)
 dialog:initialise();dialog:addToUIManager();SharedUI.Dialog.decorate(dialog,p.playerNum,p);setJoypadFocus(p.playerNum,dialog)
end
function U.context(p,row,menu)
 if not row or row.kind=='mod' or not U.index(p) then return end
 local value,state=U.state(p,row);if state=='unavailable' then return end
 local option=menu:addOption(tr('AllocationControl'));local sub=SharedUI.menu(ISContextMenu:getNew(menu));menu:addSubMenu(option,sub);option.notAvailable=p.qmss.model.readOnly==true
 sub:addOption(tr('AllocationExact'),p,function() U.exact(p,row) end)
 sub:addOption(tr('AllocationDetails'),p,function() SharedUI.Tooltip.inspect(p.playerNum,tr('AllocationCeilingsTip')..'\n'..tr('AllocationKeyboardTip'),p) end)
 for _,delta in ipairs({-5,5}) do local step=delta
  local nextValue=math.max(0,math.min(100,(value or 100)+step))
  if nextValue~=value then sub:addOption(tr(step<0 and 'AllocationDecrease' or 'AllocationIncrease'),p,function() U.set(p,row,nextValue) end) end
 end
 if p.allocation and (state=='explicit' or state=='mixed') then sub:addOption(tr('AllocationInherit'),p,function() U.reset(p,row) end) end
 SharedUI.menu(sub)
end
function U.info(p)
 if not p.requiresAllocationInfo or p.allocationInfo or p.allocationInfoPending or not Q.Authority then return end
 if p.options.parent and p.options.parent.allocationInfo then p.allocationInfo=p.options.parent.allocationInfo;return end
 local time=getTimestampMs();if time<(p.allocationInfoRetry or 0) then return end
 if (p.allocationInfoAttempts or 0)>=30 then return end;p.allocationInfoAttempts=(p.allocationInfoAttempts or 0)+1
 p.allocationInfoPending=true
 Q.Authority.request(p.playerNum,'allocationInfo',{},function(result)
  p.allocationInfoPending=false;if p.removed then return end
  if result.status=='ok' and type(result.categories)=='table' then p.allocationInfo=result;p.allocationCacheReady=false
  else p.allocationInfoRetry=getTimestampMs()+2000;if result.status=='ProtocolMismatch' then p.allocationInfoAttempts=30 end end
 end)
end
local function apply(p,profile,done)
 if p.qmss.model.readOnly or type(profile)~='table' or not Profile.valid(profile) then return end
 local session=p.qmsSession or p.options.parent and p.options.parent.qmsSession
 local selected=session and session.selected
 local args={profile=profile}
 if p.allocationRoomArgs then for key,value in pairs(p.allocationRoomArgs) do args[key]=value end
 elseif session and session.selected then args.session=session.id;args.token=session.selected.token
 elseif p.targetKind~='preset' then return end
 local function acceptPreview(result)
  if p.removed then return end
  if not p.allocationOnly and session and session.selected~=selected then p.title=tr('conflict');return end
  if result.status~='ok' then p.title=tr(result.status);return end
  local preview=result.preview
  if not p.allocationOnly and p.targetKind=='box' and p.containerUI and selected then preview.scope=p.containerUI.name(selected.target) end
  local text=tr('AllocationPreviewText',preview.scope,preview.categories,preview.items)..'\n'..tr('AllocationPreviewPreserved')
  if preview.defaultChanged then text=text..'\n'..tr('AllocationDefaultPreview',preview.oldDefault,preview.newDefault) end
  SharedUI.Dialog.confirm(p.playerNum,text,{accept=tr('Apply'),cancel=tr('Cancel')},function(mode)
   if mode=='accept' and not p.removed and (p.allocationOnly or not session or session.selected==selected) then p.allocation=Profile.copy(profile);p.allocationCacheReady=false
    if session and session.selected and not p.allocationOnly then session.selected.working.allocation=p.allocation;session.selected.dirty=session:dirty(session.selected) end
    if done then done() end
   end
  end,p)
 end
 if p.targetKind=='preset' and not p.allocationOnly then
  local before=p.allocation or Profile.empty();local keys={cats={},items={}};local counts={cats=0,items=0}
  for _,kind in ipairs({'cats','items'}) do
   for key in pairs(before[kind]) do keys[kind][key]=true end;for key in pairs(profile[kind]) do keys[kind][key]=true end
   for key in pairs(keys[kind]) do if before[kind][key]~=profile[kind][key] then counts[kind]=counts[kind]+1 end end
  end
  acceptPreview({status='ok',preview={scope=p.options.presetName,categories=counts.cats,items=counts.items,defaultChanged=before.default~=profile.default,oldDefault=before.default,newDefault=profile.default}})
 else Q.Authority.request(p.playerNum,'allocationPreview',args,acceptPreview) end
end
U.apply=apply
function U.actions(p,menu)
 if not U.index(p) then return end
 local option=menu:addOption(tr('AllocationActions'));local sub=SharedUI.menu(ISContextMenu:getNew(menu));menu:addSubMenu(option,sub)
 if p.requiresAllocationInfo and not p.allocationInfo then sub:addOption(tr('AllocationRefreshMetadata'),p,function() p.allocationInfoAttempts=0;p.allocationInfoRetry=0;U.info(p) end) end
 local session=p.qmsSession;local selected=session and session.selected
 if selected and not selected.target.whole then sub:addOption(tr('AllocationInspect'),p,function()
  Q.Authority.request(p.playerNum,'allocationInspect',{session=session.id,token=selected.token,profile=effective(p)},function(result)
   if p.removed then return end
   if result.status~='ok' then p.title=tr(result.status);return end
   local lines={tr('AllocationCapacityStatus',string.format('%.2f',result.used),string.format('%.2f',result.capacity))}
   for _,row in ipairs(result.over or {}) do lines[#lines+1]=tr('AllocationOverLimit',row.key,string.format('%.2f',row.used),string.format('%.2f',row.limit)) end
   if #(result.over or {})==0 then lines[#lines+1]=tr('AllocationNoOverLimit') end
   if result.truncated then lines[#lines+1]=tr('AllocationTruncated') end
   SharedUI.Tooltip.inspect(p.playerNum,table.concat(lines,'\n')..'\n'..tr('AllocationShadow'),p)
  end)
 end) end
 if p.qmss.model.readOnly then SharedUI.menu(sub);return end
 local reset=sub:addOption(tr('AllocationResetAll'),p,function() apply(p,Profile.empty()) end)
 reset.notAvailable=p.allocation==nil
 if p.allocationRoomDefaults and p.roomDefinition and p.roomDefinition.roomType~='unassigned' then sub:addOption(tr('AllocationRoomDefaults'),p,function() p.allocationRoomDefaults() end) end
 if p.qmsSession or p.options.parent and p.options.parent.qmsSession then sub:addOption(tr('AllocationSavePreset'),p,function() p:promptPreset('new') end) end
 local defs=p:getPresetStore();local keys={};for key,def in pairs(defs) do if def.allocation then keys[#keys+1]=key end end;table.sort(keys)
 if #keys>0 then
  local presets=SharedUI.menu(ISContextMenu:getNew(sub));sub:addSubMenu(sub:addOption(tr('AllocationApplyPreset')),presets)
  for _,key in ipairs(keys) do local name=key;presets:addOption(defs[name].label or name,p,function() apply(p,defs[name].allocation) end) end
 end
 local index=U.index(p);local orphans={}
 for _,kind in ipairs({'cats','items'}) do for key in pairs((p.allocation or {})[kind] or {}) do
  if not (kind=='cats' and index.categories[key] or kind=='items' and index.items[key]) then orphans[#orphans+1]={kind=kind,key=key} end
 end end
 if #orphans>0 then
  table.sort(orphans,function(a,b) return a.kind..a.key<b.kind..b.key end)
  local orphanMenu=SharedUI.menu(ISContextMenu:getNew(sub));sub:addSubMenu(sub:addOption(tr('AllocationOrphans',#orphans)),orphanMenu)
  for n=1,math.min(#orphans,32) do local orphan=orphans[n]
   orphanMenu:addOption(tr('AllocationRemoveOrphan',orphan.key),p,function()
    local changed=Profile.reset(p.allocation,orphan.kind=='cats' and 'category' or 'item',orphan.key);apply(p,changed)
   end)
  end
 end
 SharedUI.menu(sub)
end
function U.press(p,list,row,x)
 if not row or row.kind=='mod' or not U.index(p) then return false end
 local _,state=U.state(p,row);if state=='unavailable' then return false end
 local left,right,track=U.geometry(list);if x<left or x>right then return false end
 if p.qmss.model.readOnly then return true end
 if x>left+track+4 then U.exact(p,row);return true end
 local drag={row=row,base=Profile.copy(p.allocation or Profile.empty()),left=left,track=track}
 p.allocationDrag=drag;list:setCapture(true);U.move(p,list,x);return true
end
function U.move(p,list,x)
 local drag=p.allocationDrag;if not drag then return false end
 local value=math.max(0,math.min(100,math.floor((x-drag.left)/drag.track*20+.5)*5))
 if value~=drag.value then drag.value=value;U.set(p,drag.row,value,drag.base) end
 return true
end
function U.release(p)
 if p.allocationDrag then p.allocationDrag=nil;p.listbox:setCapture(false) end
end
function U.notice(p)
 if p.mode=='presets' or not p.priorityEntry or not U.index(p) then return end
 local entry=p.priorityEntry;local left=entry.x+entry:getWidth()+10;local right=p.listbox.x+p.listbox:getWidth()
 local mode=p.allocationInfo and p.allocationInfo.mode or Migration.option('AllocationMode') or 2
 local text=tr(p.requiresAllocationInfo and not p.allocationInfo and ((p.allocationInfoAttempts or 0)>=30 and 'AllocationUnavailable' or 'AllocationPreparing') or mode==1 and 'AllocationOff' or 'AllocationShadow')
 if right-left>30 then SharedUI.Renderer.text(p,SharedUI.Renderer.fit(text,right-left,UIFont.Small),left,entry.y+3,SharedUI.Theme.colors.accent,UIFont.Small) end
end
return U
