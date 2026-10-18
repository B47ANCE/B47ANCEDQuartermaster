local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
-- Original standalone ISUI shell. Tree behavior lives in the owned Adapter/Model.
require 'ISUI/ISCollapsableWindowJoypad'
require 'ISUI/ISButton'
require 'ISUI/ISScrollingListBox'
require 'ISUI/ISTextEntryBox'
require 'ISUI/ISLabel'
require 'ISUI/ISPanel'
require 'ISUI/ISTextBox'
require 'ISUI/ISModalDialog'
require 'ISUI/ISContextMenu'
require 'B47ANCEDQuartermaster/Catalog'
require 'B47ANCEDQuartermaster/Presets'
require 'B47ANCEDQuartermaster/ShoppingUI'
require 'B47ANCEDQuartermaster/UI'
require 'B47ANCEDQuartermaster/WindowLayout'
local Q=B47ANCEDQuartermaster
local S=Q.Schema
local Picker=ISCollapsableWindowJoypad:derive('B47SortingPicker')
Q.Picker=Picker
local function tr(key,...) return getText('UI_QMSS_'..key,...) end
local textures={}
function Picker.itemTexture(fullType)
    if not fullType then return end
    if textures[fullType]==nil then
        local ok,item=pcall(function() return instanceItem(fullType) end)
        textures[fullType]=ok and item and item:getTex() or false
    end
    return textures[fullType] or nil
end
function Picker:new(obj,ci,playerNum,options)
    local w,h=1120,780
    local metrics=SharedUI.Theme.metrics()
    local minimumWidth=math.max(640,metrics.rail+math.max(560,metrics.font*18)+32)
    local minimumHeight=math.max(460,metrics.header+metrics.tab+5*metrics.button+2*metrics.treeRow+metrics.font+9*metrics.gap)
    if getPlayerScreenWidth then
        minimumWidth=math.min(minimumWidth,getPlayerScreenWidth(playerNum or 0)-40)
        minimumHeight=math.min(minimumHeight,getPlayerScreenHeight(playerNum or 0)-40)
        w=math.max(minimumWidth,math.min(w,getPlayerScreenWidth(playerNum or 0)-40))
        h=math.max(minimumHeight,math.min(h,getPlayerScreenHeight(playerNum or 0)-40))
    end
    local o=ISCollapsableWindowJoypad.new(self,100,80,w,h)
    o.minimumWidth,o.minimumHeight=minimumWidth,minimumHeight
    o.playerNum,o.targetObj,o.targetCI=playerNum or 0,obj,ci
    o.options=options or {};o.targetKind=o.options.presetName and 'preset' or 'box'
    o.api=o.options.api or Q.Catalog.build()
    local config=S.copy(o.options.config or S.empty())
    o.selectedCats,o.selectedItems,o.selectedPresets=config.cats,config.items,config.presets
    o.allocation=config.allocation
    o.priority,o.mode=config.priority,'cats';o.selection=o.selectedCats
    o.presetLibrary=o.options.library or {revision=0,definitions={}}
    o.title=tr('EditorTitle');o.resizable=true
    Q.WindowLayout.restore(o)
    return o
end
function Picker:getPresetStore() return self.presetLibrary.definitions end
function Picker:currentFilter() return self.filter:getInternalText() or '' end
function Picker:contentsSet() return self._contents and self._contents.items or {} end
function Picker:setPriority(value)
    value=tonumber(value) or 0
    if value~=value or value==math.huge or value==-math.huge then value=0 end
    self.priority=math.max(-999999,math.min(999999,math.floor(value)))
    self.priorityEntry:setText(tostring(self.priority))
end
function Picker:closePicker()
    if self.removed then return end
    self.removed=true;self:removeFromUIManager()
    if self.childPicker and not self.childPicker.removed then self.childPicker:closePicker() end
    if Q.presetEditor and Q.presetEditor.options.parent==self then Q.presetEditor:closePicker() end
    if self.options.parent then
        local parent=self.options.parent
        if parent.childPicker==self then parent.childPicker=nil end
        parent.dimmer:setVisible(false)
        if not parent.removed then parent:refreshPresets();setJoypadFocus(self.playerNum,parent) end
    elseif self.grabbedJoypad then setJoypadFocus(self.playerNum,nil) end
end
Picker.close=Picker.closePicker
function Picker:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)
    local function add(widget) widget:initialise();widget:instantiate();self:addChild(widget);return widget end
    local function button(title,fn) return add(ISButton:new(0,0,100,26,title,self,fn)) end
    self.filter=add(ISTextEntryBox:new('',0,0,200,24))
    self.filter.onTextChangeFunction=function() self:rebuild() end
    self.btnModeCat=button(tr('Combined'),function(p) p:setMode('cats') end)
    self.btnModeItem=button(tr('Combined'),function(p) p:setMode('cats') end)
    self.btnModePreset=button(tr('Presets'),function(p) p:setMode('presets') end)
    self.chkChecked=button(tr('OnlyChecked'),function(p) p.onlyChecked=not p.onlyChecked;p:rebuild() end)
    self.chkContents=button(tr('OnlyContents'),function(p) p.onlyContents=not p.onlyContents;p:rebuild() end)
    self.priorityLabel=add(ISLabel:new(0,0,24,tr('Priority'),1,1,1,1,UIFont.Small,true))
    self.btnPriorityDown=button('-',function(p) p:setPriority(p.priority-1) end)
    self.btnPriorityUp=button('+',function(p) p:setPriority(p.priority+1) end)
    self.priorityEntry=add(ISTextEntryBox:new(tostring(self.priority),0,0,64,24))
    self.priorityEntry.onTextChangeFunction=function() self:setPriority(self.priorityEntry:getInternalText()) end
    self.listbox=add(ISScrollingListBox:new(0,0,200,200))
    local lb=self.listbox;lb.itemheight=22;lb.drawBorder=true;lb.target=self
    lb.onmousedown=function(p,name)
        local def=p:getPresetStore()[name]
        if p.selectedPresets[name] then p.selectedPresets[name]=nil
        elseif def then p.selectedPresets[name]=S.link(def) end
        p:rebuild()
    end
    lb.doDrawItem=function(list,y,entry)
        local selected=self.selectedPresets[entry.item]
        local missing=not S.resolves(self:getPresetStore()[entry.item],selected)
        list:drawText((selected and '[x] ' or '[ ] ')..entry.text..(selected and missing and (' '..tr('Unresolved')) or ''),6,y+3,1,1,1,1,UIFont.Small)
        return y+entry.height
    end
    lb.onRightMouseUp=function() self:presetMenu() end
    lb.onJoypadDown=function(list,key)
        if key==Joypad.BButton then setJoypadFocus(self.playerNum,self)
        elseif key==Joypad.RBumper then self:cycleMode(1)
        elseif key==Joypad.LBumper then self:cycleMode(-1)
        elseif key==Joypad.AButton then local row=list.items[list.selected];if row then list.onmousedown(self,row.item) end end
    end
    self.btnAll=button(tr('SelectVisible'),function(p)
        for _,row in ipairs(p.listbox.items) do local def=p:getPresetStore()[row.item];if def then p.selectedPresets[row.item]=S.link(def) end end
        p:rebuild()
    end)
    self.btnClear=button(tr('ClearVisible'),function(p) for _,row in ipairs(p.listbox.items) do p.selectedPresets[row.item]=nil end;p:rebuild() end)
    self.btnSave=button(tr('Save'),function(p) p:onSave() end)
    self.dimmer=add(ISPanel:new(0,0,self.width,self.height));self.dimmer:setVisible(false)
    self:layout()
end
function Picker:rebuild()
    local lb=self.listbox;lb:clear();lb:setScrollHeight(0)
    local names={};for name in pairs(self:getPresetStore()) do names[name]=true end
    for name in pairs(self.selectedPresets) do names[name]=true end
    local sorted={};for name in pairs(names) do sorted[#sorted+1]=name end;table.sort(sorted)
    local filter=string.lower(self:currentFilter())
    local contents=self.onlyContents and self:contentsSet()
    local catalog=self.qmss and self.qmss.catalog or self.api
    local function matchesContents(def)
        if not contents then return true end
        if not def then return false end
        for key in pairs(def.items) do if contents[key] then return true end end
        for category in pairs(def.cats) do
            for _,item in ipairs(catalog.getItemsInCategory(category)) do if contents[item.name] then return true end end
        end
        return false
    end
    for _,name in ipairs(sorted) do
        local def=self:getPresetStore()[name];local label=def and def.label or name
        if string.find(string.lower(label),filter,1,true) and (not self.onlyChecked or self.selectedPresets[name])
            and matchesContents(def) then lb:addItem(label,name) end
    end
    lb:setScrollHeight(#lb.items*lb.itemheight)
    self.btnModePreset:setTitle(tr('Presets')..' ('..#sorted..')')
end
function Picker:layout()
    local w,h=self:getWidth(),self:getHeight()
    local function at(control,x,y,width,height) control:setX(x);control:setY(y);control:setWidth(width);control:setHeight(height or 24) end
    at(self.filter,10,30,w-20)
    at(self.btnModeCat,10,60,(w-26)/2);at(self.btnModeItem,10,60,1);at(self.btnModePreset,(w+6)/2,60,(w-26)/2)
    at(self.chkChecked,10,90,140);at(self.chkContents,156,90,140)
    at(self.priorityLabel,10,120,120);at(self.btnPriorityDown,138,120,28);at(self.btnPriorityUp,172,120,28);at(self.priorityEntry,206,120,80)
    at(self.listbox,10,150,w-20,math.max(22,h-198))
    at(self.btnAll,10,h-38,100,26);at(self.btnClear,116,h-38,100,26);at(self.btnSave,w-110,h-38,100,26)
    self.dimmer:setWidth(w);self.dimmer:setHeight(h)
    self.lastWidth,self.lastHeight=w,h
end
function Picker:prerender()
    ISCollapsableWindowJoypad.prerender(self)
    if self.lastWidth~=self:getWidth() or self.lastHeight~=self:getHeight() then self:layout() end
    self.chkChecked:setTitle((self.onlyChecked and '[x] ' or '[ ] ')..tr('OnlyChecked'))
    self.chkContents:setTitle((self.onlyContents and '[x] ' or '[ ] ')..tr('OnlyContents'))
end
function Picker:setMode(mode)
    self.modeFilters=self.modeFilters or {}
    self.modeFilters[self.mode]=self:currentFilter()
    self.mode=mode
    self.filter:setText(self.modeFilters[mode] or '')
    self.selection=mode=='presets' and self.selectedPresets or self.selectedCats
    if mode=='presets' then self:refreshPresets() end
    self:rebuild();self:configJoypad()
end
function Picker:cycleMode(direction) self:setMode(direction>0 and 'presets' or 'cats') end
function Picker:configJoypad()
    self.joypadButtonsY={};self.allJoypadButtons={};self.joypadButtons={};self.joypadIndexY=1;self.joypadIndex=1
    self:insertNewLineOfButtons(self.filter)
    self:insertNewLineOfButtons(self.btnModeCat,self.targetKind=='box' and self.btnModePreset or nil)
    self:insertNewLineOfButtons(self.chkChecked,self.chkContents)
    self:insertNewLineOfButtons(self.btnPriorityDown,self.btnPriorityUp,self.priorityEntry)
    self:insertNewLineOfButtons(self.listbox)
    self:insertNewLineOfButtons(self.btnAll,self.btnClear,self.btnSave)
    self.joypadConfigured=true
end
function Picker:onGainJoypadFocus(data) ISCollapsableWindowJoypad.onGainJoypadFocus(self,data);self.grabbedJoypad=true;self:configJoypad() end
function Picker:onJoypadDown(button,data)
    if button==Joypad.BButton then self:closePicker()
    else ISCollapsableWindowJoypad.onJoypadDown(self,button,data) end
end
function Picker:onSave()
    if self.options.save then self.options.save(self,{cats=self.selectedCats,items=self.selectedItems,presets=self.selectedPresets,priority=self.priority,allocation=self.allocation}) end
end
function Picker:refreshPresets()
    local session=self.qmsSession or (self.options.parent and self.options.parent.qmsSession)
    if not session or not session.id or session.closed or self.presetPending then return end
    self.presetPending=true
    session:request('presetsList',{},function(result)
        self.presetPending=false
        if result.status=='ok' and result.library and Q.Presets.validDefinitions(result.library.definitions) then
            if result.library.revision>=self.presetLibrary.revision then self.presetLibrary=result.library;self:rebuild() end
        else self.title=tr(result.status) end
    end)
end
function Picker:changePreset(name,config,remove,done,generation,revision,extra)
    local session=self.qmsSession or self.options.parent and self.options.parent.qmsSession
    if not session or not session.selected or session.busy then return end
    session.busy=true
    local args={token=session.selected.token,name=name,config=config,delete=remove,generation=generation,revision=revision}
    for key,value in pairs(extra or {}) do args[key]=value end
    session:request('presetChange',args,function(result)
        session.busy=false
        if result.status=='ok' and result.library.revision>=self.presetLibrary.revision then self.presetLibrary=result.library;self:rebuild() end
        self.title=tr(result.status);if done then done(result.status) end
    end)
end
function Picker:promptPreset(mode,name)
    local def=name and self:getPresetStore()[name]
    local dialog=ISTextBox:new(0,0,400,190,tr('PresetName'),mode=='rename' and (def.label or name) or '',self,function(owner,b)
        if b.internal~='OK' or owner.removed then return end
        local text=b.parent.entry:getInternalText()
        if mode=='new' then owner:editPreset(text,true)
        elseif mode=='rename' then owner:changePreset(name,nil,false,nil,def.gen,owner.presetLibrary.revision,{renameTo=text})
        else owner:changePreset(text,nil,false,nil,0,owner.presetLibrary.revision,{duplicateOf=name,sourceGeneration=def.gen}) end
    end,self.playerNum)
    dialog:initialise();dialog:addToUIManager();SharedUI.Dialog.decorate(dialog,self.playerNum,self);setJoypadFocus(self.playerNum,dialog)
end
function Picker:editPreset(name,isNew)
    local def=self:getPresetStore()[name]
    if (not isNew and not def) or (isNew and def) then self.title=tr('conflict');return end
    local revision=self.presetLibrary.revision
    local generation=def and def.gen or 0
    local config=def and {cats=def.cats,items=def.items,presets={},priority=0,allocation=def.allocation}
        or S.effective({cats=self.selectedCats,items=self.selectedItems,presets=self.selectedPresets,priority=0,allocation=self.allocation},self:getPresetStore())
    config.presets={}
    self.dimmer:setVisible(true)
    local parent=self
    local editor=Picker:new(nil,nil,self.playerNum,{presetName=name,config=config,parent=self,api=self.api,
        save=function(child,working)
            working.presets={};working.priority=0
            parent:changePreset(name,working,false,function(result) if result=='ok' then child:closePicker() else child.title=tr(result) end end,generation,revision)
        end})
    editor.requiresAllocationInfo=self.requiresAllocationInfo;editor.allocationInfo=self.allocationInfo
    self.childPicker=editor
    editor.title=tr('PresetEditor')..': '..name
    editor:initialise();editor:addToUIManager();Q.adapt(editor);Q.UI.attach(editor);Q.presetEditor=editor
    setJoypadFocus(self.playerNum,editor)
end
function Picker:presetMenu()
    if self.targetKind~='box' then return end
    local menu=SharedUI.menu(ISContextMenu.get(self.playerNum,getMouseX(),getMouseY()))
    menu:addOption(tr('PresetNew'),self,function(p) p:promptPreset('new') end)
    local row=self.listbox.items[self.listbox.selected]
    local name=row and type(row.item)=='string' and row.item
    local def=name and self:getPresetStore()[name]
    if def then
        menu:addOption(tr('AllocationRenamePreset'),self,function(p) p:promptPreset('rename',name) end)
        menu:addOption(tr('AllocationDuplicatePreset'),self,function(p) p:promptPreset('duplicate',name) end)
        menu:addOption(tr('PresetEdit'),self,function(p) p:editPreset(name,false) end)
        menu:addOption(tr('PresetDelete'),self,function(p)
            local revision,generation=p.presetLibrary.revision,def.gen
            SharedUI.Dialog.confirm(p.playerNum,tr('PresetDeleteConfirm')..' '..name,{accept=tr('PresetDelete'),cancel=tr('Cancel')},function(mode)
                if mode=='accept' then p:changePreset(name,nil,true,nil,generation,revision) end
            end,p)
        end)
    end
    menu:addOption(tr('Refresh'),self,function(p) p:refreshPresets() end)
    if self.grabbedJoypad then setJoypadFocus(self.playerNum,menu) end
    return menu
end
local function openPrepared(obj,ci,playerNum,api)
    Q.pickers=Q.pickers or {}
    local old=Q.pickers[playerNum]
    if old and not old.removed then old:closePicker();if not old.removed then return end end
    Q.ItemCatalog.seed(api.entries)
    local p=Picker:new(obj,ci,playerNum,{api=api,uiFramework=true})
    p:initialise();p:addToUIManager();Q.adapt(p);Q.picker=p;Q.pickers[playerNum]=p
    Q.ShoppingUI.attach(p)
    Q.UI.attach(p);SharedUI.bounds(p,playerNum)
    if getSpecificPlayer(playerNum):getJoypadBind()~=-1 then setJoypadFocus(playerNum,p) end
    return p
end
function Q.openPicker(obj,ci,playerNum)
    local allowed,id,name=require('B47ANCEDQuartermaster/Compatibility').allowed()
    if not allowed then
        local player=getSpecificPlayer(playerNum or 0)
        if player then player:setHaloNote(getText('UI_QMSS_IncompatibleMod',name)) end
        return nil
    end
    playerNum=playerNum or 0
    local old=Q.pickers and Q.pickers[playerNum]
    if old and not old.removed then old:closePicker();if not old.removed then return old end end
    Q.catalogWindows=Q.catalogWindows or {}
    local existing=Q.catalogWindows[playerNum]
    if existing and not existing.closed then return existing end
    local compatibility=require 'B47ANCEDQuartermaster/Compatibility'
    if compatibility.explicitCategorySelections and compatibility.explicitCategorySelections() then
        Q.Catalog.invalidate('external-category-refresh')
    end
    local loading,result
    local request=Q.Catalog.prepare(function(api,err)
        if loading then
            if loading.closed then return end
            loading:removeFromUIManager();loading.closed=true;Q.catalogWindows[playerNum]=nil
        end
        if api then result=openPrepared(obj,ci,playerNum,api)
        else print('[B47ANCEDQuartermaster] opening cancelled: '..tostring(err)) end
    end)
    if result then return result end
    local U=SharedUI;local metrics=U.Theme.metrics()
    loading=U.WindowShell:new(100,80,400,180);loading.playerNum=playerNum;loading.title=tr('ProductTitle');loading.resizable=false
    loading.drawFrame=false;loading.titleBarHeight=function() return U.Theme.metrics().header end
    loading:initialise();loading:addToUIManager();U.bounds(loading,playerNum)
    local function close()
        request.cancel();loading.closed=true;loading:removeFromUIManager();Q.catalogWindows[playerNum]=nil;setJoypadFocus(playerNum,nil)
    end
    loading.close=close;loading.closePicker=close
    local cancel=U.Button:new(12,132,376,metrics.button,tr('Cancel'),loading,close)
    cancel:initialise();cancel:instantiate();loading:addChild(cancel)
    loading.cancelButton=cancel
    U.skinChildren(loading)
    for _,key in ipairs({'pinButton','collapseButton'}) do if loading[key] then loading[key]:setVisible(false) end end
    loading.layout=function(self)
        local t=U.Theme.metrics();self:setHeight(t.header+t.font+t.button+64)
        cancel:setX(12);cancel:setY(self:getHeight()-t.button-12);cancel:setWidth(self:getWidth()-24);cancel:setHeight(t.button)
        if self.closeButton then
            self.closeButton:setX(self:getWidth()-40);self.closeButton:setY(6);self.closeButton:setWidth(30);self.closeButton:setHeight(t.header-12)
            self.closeButton.anchorRight=false
        end
        self.b47Font=t.font
    end
    loading:layout();U.bounds(loading,playerNum)
    loading.joypadButtonsY={};loading.allJoypadButtons={};loading:insertNewLineOfButtons(cancel)
    loading.onJoypadDown=function(self,button,data) if button==Joypad.BButton then close() else ISPanelJoypad.onJoypadDown(self,button,data) end end
    loading.prerender=function(self)
        local t=U.Theme.metrics();if self.b47Font~=t.font then self:layout();U.bounds(self,playerNum) end
        U.Appearance.prepare(self,'window')
        U.Renderer.background(self,0,0,self:getWidth(),self:getHeight(),U.Theme.colors.window)
        U.Renderer.border(self,0,0,self:getWidth(),self:getHeight(),U.Theme.colors.strong)
        U.Renderer.text(self,U.Renderer.fit(tr('ProductTitle'),self:getWidth()-64,U.Theme.fonts.title),12,10,U.Theme.colors.text,U.Theme.fonts.title)
        U.Renderer.text(self,U.Renderer.fit(tr('LoadingCatalog'),self:getWidth()-24),12,t.header+12,U.Theme.colors.text)
        U.Progress.draw(self,12,t.header+t.font+26,self:getWidth()-24,request.progress(),1,'accent')
    end
    Q.catalogWindows[playerNum]=loading
    if getSpecificPlayer(playerNum):getJoypadBind()~=-1 then setJoypadFocus(playerNum,loading) end
    return loading
end
function Q.onPresetsChanged()
    for _,p in pairs(Q.pickers or {}) do if not p.removed then p:refreshPresets() end end
end
return Picker
