require 'ISUI/ISPanelJoypad'
require 'ISUI/ISComboBox'
require 'ISUI/ISLabel'
require 'ISUI/ISButton'
require 'ISUI/ISScrollingListBox'
require 'B47ANCEDQuartermaster/ItemPicker'
require 'B47ANCEDQuartermaster/ShoppingAddUI'
require 'B47ANCEDQuartermaster/UI'
local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
local Q=B47ANCEDQuartermaster;local U={};Q.PreferencesUI=U
local Window=ISPanelJoypad:derive('B47ShoppingPreferences')
local function tr(k) return getText('UI_QMSS_'..k) end
local fields={'condition','freshness','cooked','frozen','rotten','uses'}
local choices={condition={0,25,50,75,100},uses={0,25,50,75,100},freshness={'any','fresh','nonrotten'},cooked={'any','yes','no'},frozen={'any','yes','no'},rotten={'any','allow','exclude'}}
function U.open(playerNum,callback,owner)
    local p=Window:new(80,60,560,540);p.playerNum=playerNum;p.callback=callback;p.owner=owner;p.moveWithMouse=true
    p:initialise();p:instantiate();p:addToUIManager();p:build()
    Q.Authority.request(playerNum,'personalList',{},function(snapshot) if not p.closed and snapshot.status=='ok' then p.snapshot=snapshot;p:refresh() end end)
    Q.UI.preferences(p)
    setJoypadFocus(playerNum,p);return p
end
function Window:close()
    self.closed=true;self:removeFromUIManager();setJoypadFocus(self.playerNum,self.owner and not self.owner.removed and self.owner or nil)
end
function Window:build()
    local function child(w) w:initialise();w:instantiate();self:addChild(w);return w end
    local function button(key,x,y,w,fn) return child(SharedUI.Button:new(x,y,w,24,tr(key),self,fn)) end
    self.title=child(SharedUI.skin(ISLabel:new(10,10,24,tr('ShoppingPreferences'),1,1,1,1,UIFont.Small,true),'label'))
    self.global=button('GlobalDefaults',10,42,190,function(p) p.fullType=nil;p:refresh() end)
    self.overrides=child(SharedUI.ScrollList:new(10,76,190,270));self.overrides.itemheight=24
    self.overrides.onmousedown=function(_,row) self.fullType=row.fullType;self:refresh() end
    self.overrides.target=self
    self.addOverride=button('AddOverride',10,352,190,function(p)
        Q.ItemPicker.open(p.playerNum,'override',function(result) p.fullType=result.fullType;p:refresh() end,p)
    end)
    self.editOverride=button('EditOverride',10,382,190,function(p) p:refresh() end)
    self.removeOverride=button('RemoveOverride',10,412,190,function(p) p:edit({action='remove',fullType=p.fullType}) end)
    self.resetItem=button('ResetItemOverride',10,442,190,function(p) p:edit({action='remove',fullType=p.fullType}) end)
    self.labels={};self.controls={}
    for i,k in ipairs(fields) do
        self.labels[k]=child(SharedUI.skin(ISLabel:new(214,50+(i-1)*58,22,tr('Preference_'..k),1,1,1,1,UIFont.Small,true),'label'))
        self.controls[k]=child(SharedUI.Dropdown.style(ISComboBox:new(214,74+(i-1)*58,334,24,self,function() end)))
    end
    self.confirm=button('DuplicateConfirmation',214,410,334,function(p)
        p:edit({action='confirm',value=not p.snapshot.preferences.confirm})
    end)
    self.save=button('Save',214,442,334,function(p)
        local rule={}
        for _,k in ipairs(fields) do
            local control=p.controls[k]
            if control:isVisible() then
                local value=control.values[control.selected]
                if value~='inherit' and (p.fullType or value~=0 and value~='any' and value~='allow') then rule[k]=value end
            end
        end
        p:edit({action=p.fullType and 'override' or 'global',fullType=p.fullType,rule=rule})
    end)
    self.reset=button('ResetAllPreferences',10,486,350,function(p)
        local dialog=Q.ShoppingAddUI.confirm(p.playerNum,tr('ResetPreferencesWarning'),function(mode) if mode=='again' then p:edit({action='resetAll'}) end end,p)
        dialog.yes:setTitle(tr('ResetAllPreferences'))
    end)
    self.cancel=button('Close',370,486,178,function(p) p:close() end)
    self.save:setEnable(false);self.confirm:setEnable(false);self.reset:setEnable(false)
end
function Window:edit(args)
    if not self.snapshot or self.pending then return end
    self.pending=true;args.revision=self.snapshot.revision
    Q.Authority.request(self.playerNum,'shoppingPreference',args,function(result)
        self.pending=false;if self.closed then return end
        if result.status=='ok' then self.snapshot=result;self:refresh();if self.callback then self.callback(result) end
        else self.save:setTooltip(tr(result.status)) end
    end)
end
function Window:refresh()
    if not self.snapshot then return end
    self.confirm:setEnable(true);self.reset:setEnable(true)
    local prefs=self.snapshot.preferences
    local applicable={condition=true,food=true,uses=true}
    if self.fullType then
        applicable=Q.ShoppingPreferences.forScript(getScriptManager():FindItem(self.fullType))
    end
    local rule
    if self.fullType then rule=prefs.overrides[self.fullType] else rule=prefs.global end
    rule=rule or {};local count=0
    for _,k in ipairs(fields) do
        local show=(k=='condition' and applicable.condition) or (k=='uses' and applicable.uses) or (k~='condition' and k~='uses' and applicable.food)
        self.labels[k]:setVisible(show);local control=self.controls[k];control:setVisible(show)
        control:clear();control.values={}
        local function option(v)
            control.values[#control.values+1]=v
            local label=type(v)=='number' and (v==0 and tr('Any') or getText('UI_QMSS_MinimumPercent',v)) or tr(v=='inherit' and 'Inherited' or 'Value_'..v)
            control:addOption(label)
            if v==(rule[k]~=nil and rule[k] or self.fullType and 'inherit' or type(choices[k][1])=='number' and 0 or 'any') then control.selected=#control.values end
        end
        if self.fullType then option('inherit') end
        for _,v in ipairs(choices[k]) do option(v) end
        if show then count=count+1 end
    end
    self.title:setName(self.fullType and getText('UI_QMSS_ItemPreferences',self.fullType) or tr('ShoppingPreferences'))
    self.save:setEnable(count>0);self.save:setTooltip(count>0 and tr('Save') or tr('NoApplicablePreferences'))
    local exists=self.fullType and prefs.overrides[self.fullType]~=nil
    self.removeOverride:setEnable(exists or false);self.resetItem:setEnable(exists or false);self.editOverride:setEnable(exists or false)
    self.removeOverride:setVisible(exists or false);self.resetItem:setVisible(exists or false);self.editOverride:setVisible(exists or false)
    self.confirm:setTitle((prefs.confirm and '[x] ' or '[ ] ')..tr('DuplicateConfirmation'))
    self.overrides:clear();local names={};for t in pairs(prefs.overrides) do names[#names+1]=t end;table.sort(names)
    for _,t in ipairs(names) do self.overrides:addItem(t,{fullType=t}) end
    self.joypadButtonsY={};self.allJoypadButtons={};self.joypadButtons={}
    self:insertNewLineOfButtons(self.global,self.overrides,self.addOverride)
    for _,k in ipairs(fields) do if self.controls[k]:isVisible() then self:insertNewLineOfButtons(self.controls[k]) end end
    if exists then self:insertNewLineOfButtons(self.editOverride,self.removeOverride,self.resetItem) end
    self:insertNewLineOfButtons(self.save,self.confirm,self.reset,self.cancel)
    self.joypadIndexY=1;self.joypadIndex=1
    if self.joyfocus then self:restoreJoypadFocus() end
end
function Window:onGainJoypadFocus(data) ISPanelJoypad.onGainJoypadFocus(self,data);self:restoreJoypadFocus() end
function Window:onJoypadDown(key)
    if key==Joypad.BButton then self:close() else ISPanelJoypad.onJoypadDown(self,key) end
end
return U
