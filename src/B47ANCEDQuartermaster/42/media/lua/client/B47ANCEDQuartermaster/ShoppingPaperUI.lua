require 'ISUI/ISComboBox'
require 'ISUI/ISTextBox'
local Q=B47ANCEDQuartermaster
local V={};Q.ShoppingPaperUI=V
local serial=0
local function tr(k,...) return getText('UI_QMSS_'..k,...) end
function V.attach(p,u,add,button)
 local function message(status) u.collectionResult=status;u.status:setName(tr(status)) end
 local function changed(result)
  if p.removed then return end
  if result.status=='ok' then u.lists=result;u.selected=nil;u.selectedProject=nil;u.selectedSource=nil;u.selectedRequirement=nil;u.selectedFrom=nil;u.rebuild()
  else message(result.status) end
 end
 u.paperPicker=add(ISComboBox:new(0,0,200,28,p,function(_,combo)
  local item=u.paperOptions and u.paperOptions[combo.selected]
  if item and not u.paperUpdating then Q.Authority.request(p.playerNum,'shoppingPaperSelect',{item=item},changed) end
 end))
 u.paperPicker:setTooltip(tr('ShoppingPaperSelectTip'))
 local function prompt(import,rename)
  local meta=u.lists.paper or {};local current
  for _,entry in ipairs(meta.lists or {}) do if entry.item==meta.selected then current=entry end end
  local item,revision=current and current.item,current and current.revision
  local dialog=ISTextBox:new(0,0,380,190,tr(rename and 'ShoppingPaperRename' or import and 'ShoppingPaperImport' or 'ShoppingPaperNew'),
   rename and current and current.name or tr('ShoppingPaperDefault'),nil,function(_,b)
    if b.internal~='OK' or p.removed then return end
    local label=b.parent.entry:getInternalText()
    if rename then Q.Authority.request(p.playerNum,'shoppingPaperRename',{item=item,revision=revision,name=label},changed)
    else
     require 'B47ANCEDQuartermaster/LedgerUI';serial=serial+1
     Q.LedgerUI.shoppingPaper(p.playerNum,{name=label,import=import,operation=tostring(getTimestampMs())..':'..serial},function(status)
      if p.removed then return end
      message(status);u.refresh()
     end)
    end
   end,p.playerNum)
  dialog:initialise();dialog:addToUIManager();B47ANCEDUI.Dialog.decorate(dialog,p.playerNum,p);setJoypadFocus(p.playerNum,dialog)
 end
 u.paperNew=button('ShoppingPaperNew',function() prompt(false,false) end)
 u.paperRename=button('ShoppingPaperRename',function() prompt(false,true) end)
 u.paperImport=button('ShoppingPaperImport',function() prompt(true,false) end)
 u.paperNew:setTooltip(tr('ShoppingPaperMaterials'))
 u.paperImport:setTooltip(tr('ShoppingPaperImportTip'))
 function u:refreshPaperControls()
  local meta=self.lists.paper or {};local signature=meta.selected==nil and 'choose:' or ''
  for _,entry in ipairs(meta.lists or {}) do signature=signature..entry.item..':'..entry.name..'\0' end
  if signature~=self.paperSignature then
   self.paperUpdating=true;self.paperSignature=signature;self.paperPicker:clear();self.paperOptions={}
   if meta.selected==nil then self.paperPicker:addOption(tr('ShoppingPaperChoose'));self.paperOptions[1]=false end
   for _,entry in ipairs(meta.lists or {}) do self.paperPicker:addOption(entry.name);self.paperOptions[#self.paperOptions+1]=entry.item end
   self.paperUpdating=false
  end
  self.paperPicker.selected=1
  for i,id in ipairs(self.paperOptions or {}) do if id==meta.selected then self.paperPicker.selected=i end end
  local physical=meta.enabled==true;local busy=Q.Collector and Q.Collector.active[p.playerNum]~=nil
  self.paperNew:setEnable(not busy and meta.writable==true);self.paperImport:setEnable(not busy and meta.legacy==true and meta.writable==true)
  self.paperRename:setEnable(not busy and meta.selected~=nil and meta.writable==true);self.paperPicker:setEnabled(not busy)
  self.pickerShopping:setEnable(not physical or meta.selected~=nil and meta.writable==true)
  self.preferences:setEnable(not physical or meta.selected~=nil and meta.writable==true)
  if physical and (not meta.selected or not meta.writable) then
   for _,b in ipairs({self.pickerShopping,self.addShopping,self.removeShopping,self.remaining,self.bulk,self.preferences}) do b:setEnable(false) end
  end
  if physical and not meta.selected then
   self.collect:setEnable(false);self.collectRemaining:setEnable(false)
   self.status:setName(tr('ShoppingPaperNone'))
  elseif physical and not meta.writable then self.status:setTooltip(tr(meta.writingStatus or 'ShoppingWritingRequired')) end
  if not physical or self.mode~='shopping' then
   for _,b in ipairs({self.paperPicker,self.paperNew,self.paperRename,self.paperImport}) do b:setVisible(false) end
  end
 end
end
return V
