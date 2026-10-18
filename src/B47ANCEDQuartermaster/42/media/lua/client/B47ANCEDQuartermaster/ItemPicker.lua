require 'ISUI/ISPanelJoypad'
require 'ISUI/ISScrollingListBox'
require 'ISUI/ISTextEntryBox'
require 'ISUI/ISButton'
require 'B47ANCEDQuartermaster/Authority'
require 'B47ANCEDQuartermaster/ShoppingAddUI'
require 'B47ANCEDQuartermaster/UI'
local Q=B47ANCEDQuartermaster
local P={};Q.ItemPicker=P
require 'B47ANCEDQuartermaster/ItemCatalog'
P.catalog=Q.ItemCatalog.catalog;P.search=Q.ItemCatalog.search
local Window=ISPanelJoypad:derive('B47ItemPicker')
function P.open(playerNum,kind,onChanged,parent)
    if kind~='wish' and kind~='wanted' and kind~='needed' and kind~='shopping' and kind~='override' and kind~='stock' then return end
    local x,y,w,h=0,0,540,430
    if getPlayerScreenWidth then
        w=math.max(260,math.min(w,getPlayerScreenWidth(playerNum)-20))
        h=math.max(220,math.min(h,getPlayerScreenHeight(playerNum)-20))
        x=getPlayerScreenLeft(playerNum)+(getPlayerScreenWidth(playerNum)-w)/2
        y=getPlayerScreenTop(playerNum)+(getPlayerScreenHeight(playerNum)-h)/2
    end
    local p=Window:new(x,y,w,h);p.playerNum=playerNum;p.kind=kind;p.onChanged=onChanged;p.owner=parent;p.moveWithMouse=true
    p:initialise();p:instantiate();p:addToUIManager();p:build()
    Q.UI.itemPicker(p)
    if kind~='stock' then Q.Authority.request(playerNum,'personalList',{},function(snapshot)
        if not p.closed and snapshot.status=='ok' then p.existingWish=kind=='needed' and snapshot.needed or snapshot.wish;p:updateAdd() end
    end) end
    if JoypadState and JoypadState.players[playerNum+1] then setJoypadFocus(playerNum,p) end
    return p
end
function Window:build()
    local function child(w) w:initialise();w:instantiate();self:addChild(w);return w end
    local w,h=self:getWidth(),self:getHeight()
    self.search=child(ISTextEntryBox:new('',12,34,w-24,24))
    self.list=child(ISScrollingListBox:new(12,64,w-24,h-164));self.list.itemheight=32
    self.list.doDrawItem=function(lb,y,row)
        if ISInventoryItem then ISInventoryItem.renderScriptItemIcon(lb,row.item.script,4,y+2,1,26,26) end
        lb:drawText(row.item.displayLabel or row.item.name,36,y+5,1,1,1,1,UIFont.Small)
        return y+row.height
    end
    self.list.target=self
    local function enable()
        local n=tonumber(self.quantity and self.quantity:getInternalText())
        local isGoal=self.kind=='wish' or self.kind=='wanted' or self.kind=='needed'
        local duplicate=isGoal and self.existingWish and self.existingWish[self.selectedType]
        self.add:setEnable(not duplicate and self.selectedType~=nil and n~=nil and n==math.floor(n) and n>0 and n<=1000000)
        self.add:setTooltip(getText('UI_QMSS_'..(duplicate and (self.kind=='needed' and 'NeededExists' or 'WishExists') or self.kind=='override' and 'AddOverride' or self.kind=='stock' and 'StockAdd' or self.kind=='needed' and 'NeededAdd' or isGoal and 'WishAdd' or 'ShoppingAdd')))
    end
    self.updateAdd=enable
    self.list.onmousedown=function(_,row) self.selectedType=row.fullType;enable() end
    self.list.onJoypadDown=function(lb,key)
        if key==Joypad.AButton then local row=lb.items[lb.selected];if row then lb.onmousedown(self,row.item) end
        elseif key==Joypad.BButton then self:close() end
    end
    self.quantity=child(ISTextEntryBox:new('1',12,h-88,100,24))
    self.quantity:setTooltip(getText('UI_QMSS_'..(self.kind=='stock' and 'StockQuantityHelp' or 'PhysicalQuantity')))
    self.quantity.onTextChangeFunction=enable
    self.add=child(ISButton:new(124,h-88,w-226,24,getText('UI_QMSS_'..(w<480 and 'Add' or self.kind=='stock' and 'StockAdd' or self.kind=='needed' and 'NeededAdd' or (self.kind=='wish' or self.kind=='wanted') and 'WishAdd' or 'ShoppingAdd')),self,function(owner) owner:submit() end));self.add:setEnable(false)
    self.cancel=child(ISButton:new(w-90,h-88,78,24,getText('UI_QMSS_Cancel'),self,function(owner) owner:close() end))
    if self.kind=='override' then self.quantity:setVisible(false);self.add:setTitle(getText('UI_QMSS_AddOverride')) end
    local function search()
        self.list:clear();self.selectedType=nil;self.add:setEnable(false)
        local results=P.search(self.search:getInternalText())
        local counts={}
        for _,row in ipairs(results) do counts[row.name]=(counts[row.name] or 0)+1 end
        for _,row in ipairs(results) do
            row.displayLabel=row.name..(counts[row.name]>1 and (' ('..row.fullType..')') or '')
            self.list:addItem(row.displayLabel,row)
        end
    end
    self.search.onTextChangeFunction=search;search()
    self:insertNewLineOfButtons(self.search);self:insertNewLineOfButtons(self.list)
    if self.kind=='override' then self:insertNewLineOfButtons(self.add,self.cancel) else self:insertNewLineOfButtons(self.quantity,self.add,self.cancel) end
end
function Window:submit()
    if not self.selectedType then return end
    local t,n=self.selectedType,tonumber(self.quantity:getInternalText())
    if not n or n~=math.floor(n) or n<1 or n>1000000 then return end
    if self.kind=='stock' then if self.onChanged then self.onChanged({fullType=t,quantity=n}) end;self:close();return end
    if self.kind=='override' then if self.onChanged then self.onChanged({fullType=t}) end;self:close();return end
    if self.kind=='shopping' then
        Q.ShoppingAddUI.send(self.playerNum,{kind='shopping',fullType=t,quantity=n},function(result)
            if self.closed then return end
            if result.status=='ok' then if self.onChanged then self.onChanged(result) end;self:close()
            else self.add:setTooltip(getText('UI_QMSS_'..result.status)) end
        end,self)
        return
    end
    Q.Authority.request(self.playerNum,'personalList',{},function(snapshot)
        if self.closed or snapshot.status~='ok' then return end
        local targets=self.kind=='needed' and snapshot.needed or snapshot.wish
        if targets[t] then
            self.add:setEnable(false);self.add:setTooltip(getText('UI_QMSS_'..(self.kind=='needed' and 'NeededExists' or 'WishExists')));return
        end
        Q.Authority.request(self.playerNum,'personalChange',{kind=self.kind,fullType=t,quantity=n,revision=snapshot.revision},function(result)
            if self.closed then return end
            if result.status=='ok' then if self.onChanged then self.onChanged(result) end;self:close()
            else self.add:setTooltip(getText('UI_QMSS_'..result.status)) end
        end)
    end)
end
function Window:close()
    self.closed=true;self:removeFromUIManager()
    if self.joyfocus then setJoypadFocus(self.playerNum,self.owner and not self.owner.removed and self.owner or nil) end
end
function Window:onGainJoypadFocus(data) ISPanelJoypad.onGainJoypadFocus(self,data);self:restoreJoypadFocus() end
function Window:render()
    ISPanelJoypad.render(self)
    if not self.b47PickerShell then
        self:drawText(getText('UI_QMSS_'..(self.kind=='stock' and 'StockAdd' or self.kind=='needed' and 'NeededAdd' or (self.kind=='wish' or self.kind=='wanted') and 'WishAdd' or self.kind=='override' and 'AddOverride' or 'ShoppingAdd')),12,10,1,1,1,1,UIFont.Small)
        self:drawText(getText('UI_QMSS_SelectedType',self.selectedType or ''),12,self:getHeight()-44,1,1,1,1,UIFont.Small)
    end
    self:renderJoypadFocus()
end
return P
