local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
require 'B47ANCEDQuartermaster/Session'
require 'ISUI/ISContextMenu'
require 'ISUI/ISScrollingListBox'
require 'Definitions/ContainerButtonIcons'
require 'B47ANCEDQuartermaster/Catalog'
require 'B47ANCEDQuartermaster/WorldHighlight'
require 'B47ANCEDQuartermaster/ContainerSprite'
require 'B47ANCEDQuartermaster/RoomAccess'
local Q=B47ANCEDQuartermaster
local T,C=Q.Targets,Q.Configuration
local M={}; Q.MultiContainer=M
local active={}
local observed=false
function Q.onConfigurationChanged() for picker,session in pairs(active) do if not picker.removed and not session.closed then picker.discoveryDirty=true end end end
Q.onRoomsChanged=Q.onConfigurationChanged
local function observeWorld()
    if observed or not Events or not Events.LoadGridsquare then return end
    observed=true
    Events.LoadGridsquare.Add(function(square)
        if not square then return end
        for picker,session in pairs(active) do
            if not picker.removed and not session.closed then
                local player=getSpecificPlayer(session.playerNum)
                local origin=player and player.getCurrentSquare and player:getCurrentSquare()
                    or session.origin and session.origin.obj and session.origin.obj:getSquare()
                if origin then
                    local range,whole=T.options()
                    local building=whole and origin:getBuilding()
                    local inScope=building and square:getBuilding() and square:getBuilding():getDef()==building:getDef()
                        or not building and square:getZ()==origin:getZ()
                        and math.max(math.abs(square:getX()-origin:getX()),math.abs(square:getY()-origin:getY()))<=range
                    if inScope then picker.discoveryDirty=true end
                end
            end
        end
    end)
end
local function tr(k,...) return getText('UI_QMSS_'..k,...) end
local function name(t)
    return t.name or (t.container and t.container:getCustomName()) or getTextOrNull('IGUI_ContainerTitle_'..(t.kind or t.container:getType())) or t.kind
end
function M.attach(p)
    local player=getSpecificPlayer(p.playerNum)
    local origin=p.targetObj and T.make(p.targetObj,p.targetCI,player)
    -- If the opener exposed an unsupported target, fail closed instead of retaining native writes.
    if p.targetObj and not origin then
        print('[B47ANCEDQuartermaster] opener rejected: unsupported or inaccessible target')
        p.btnSave.onclick=function() end; p.onSave=function() end
        p.btnSave:setEnable(false); p.btnSave:setTooltip(tr('TargetUnavailable')); return
    end
    local s=Q.Session.new(origin,p.playerNum); p.qmsSession=s;p.requiresAllocationInfo=true
    active[p]=s;observeWorld()
    local highlight=Q.WorldHighlight.new(p.playerNum);p.worldHighlight=highlight
    local rail=ISScrollingListBox:new(8,30,54,200)
    rail:initialise(); rail:instantiate(); rail.itemheight=SharedUI.Theme.metrics().railRow; rail.drawBorder=true
    p:addChild(rail)
    SharedUI.RowTooltip.attach(rail,p.playerNum)
    local sprites=Q.ContainerSprite.new(p.playerNum)
    local buttons={};local expanded={}
    local function editable(r) return r and not r.partial and (r.configMode~='inherit' or r.pendingAction=='custom') and r.pendingAction~='remove' and r.pendingAction~='reset' end
    p.containerUI={rail=rail,buttons=buttons,session=s,name=name}
    local function status(key) s.status=key; p.title=tr('EditorTitle')..(s.selected and ' — '..name(s.selected.target) or origin and ' — '..name(origin) or '')..' — '..tr(key) end
    local function capture()
        local r=s.selected
        if not r or s.binding or not editable(r) then return end
        r.working={cats=p.selectedCats,items=p.selectedItems,presets=p.selectedPresets,priority=p.priority,allocation=p.allocation}
        r.introduced=p.qmss.model.introduced
        r.dirty=s:dirty(r)
    end
    local Catalog=B47ANCEDQuartermaster.Catalog
    local baseCatalog=p.api
    local function bind()
        local r=s.selected; if not r then return end
        s.binding=true
        p.targetObj,p.targetCI=r.target.obj,r.target.ci
        local displayed=editable(r) and r.working or C.clone(r.working)
        p.selectedCats,p.selectedItems,p.selectedPresets=displayed.cats,displayed.items,displayed.presets
        p.allocation=displayed.allocation
        p.selection=p.mode=='presets' and p.selectedPresets or p.selectedCats
        p:setPriority(r.working.priority)
        p._contents=nil
        r.catalog=r.catalog or Catalog.forObserved(baseCatalog,r.observed)
        p.qmss.catalog=r.catalog
        local modelStarted=getTimestampMs()
        p.qmss.model=Q.Model.new(p,r.catalog,tr('Other'),r.catalog.owner)
        Catalog.modelBuilt(getTimestampMs()-modelStarted)
        p.qmss.model.readOnly=not editable(r)
        p.qmss.model.introduced=r.introduced or {}
        p.qmss.rangeAnchor,p.qmss.filterKey,p.qmss.presetSignature=nil,nil,nil
        p.listbox:setYScroll(0)
        s.binding=false
        s.siblings=r.target.siblings or {}
        p.btnSave:setEnable(true); p.listbox:setVisible(true)
        buttons.whole:setVisible(#s.siblings>=2)
        buttons.whole:setTitle(r.configMode=='inherit' and tr('CustomizeSection') or tr('WholeContainer'))
        buttons.whole:setEnable(not r.partial)
        buttons.apply:setTitle(r.target.whole and tr('RemoveWhole') or tr('ResetWhole'))
        buttons.apply:setEnable(not r.partial and (r.target.whole and r.groupActive==true or r.configMode=='custom' or r.pendingAction=='custom'))
        local enabled=editable(r)
        for _,control in ipairs({p.listbox,p.btnPriorityDown,p.btnPriorityUp,p.priorityEntry,p.btnModePreset}) do if control.setEnable then control:setEnable(enabled) end end
        p.btnSave:setEnable(not r.partial)
        status(r.configMode=='inherit' and r.pendingAction~='custom' and 'InheritedWhole' or 'Ready')
        buttons.apply:setVisible(#s.siblings>=2)
        buttons.whole:setTooltip(tr(r.partial and 'PartialGroupTip' or r.configMode=='inherit' and 'CustomizeTip' or 'ParentRulesTip'))
        buttons.apply:setTooltip(tr(r.partial and 'PartialGroupTip' or r.target.whole and 'RemoveWholeTip' or 'ResetWholeTip'))
        buttons.containers:setTooltip(tr('ScopeTip'))
        p:rebuild(); status(r.configMode=='inherit' and r.pendingAction~='custom' and 'InheritedWhole' or 'Ready'); p:configJoypad();p:refreshPresets()
        highlight:select(r.target)
    end
    -- Rail entries describe server-issued handles. Coordinates are labels, never target lookup.
    p.contentsSet=function() return s.selected and s.selected.contents or {} end
    local function refreshRail()
        local scroll=rail.getYScroll and rail:getYScroll() or 0
        rail:clear()
        sprites:clear()
        if not s.viewInfo then return true end
        if s.selected and s.selected.target.group and expanded[s.selected.target.group]==nil then expanded[s.selected.target.group]=true end
        for _,r in ipairs(Q.DiscoveryView.rows(s,player,expanded)) do
            local text=name(r.target)
            if r.target.whole then text=tr('WholeParent',text,#(r.visibleChildren or {}))
            elseif r.nested then text='    '..tr('SectionLabel',text,r.target.groupSection or r.target.ci+1)..' · '..tr((r.configMode or r.target.configMode)=='inherit' and 'Inherited' or (r.configMode or r.target.configMode)=='custom' and 'Custom' or 'Independent') end
            if r.partial then text=text..' · '..tr('PartialGroup') end
            local e=rail:addItem(text,r)
            local d=r.target
            e.tooltip=tr('ContainerNameTip',SharedUI.Tooltip.plain(name(d)))..' <LINE> '..tr('ContainerPositionTip',d.x,d.y,d.z)..' <LINE> '..tr('ContainerSectionTip',d.groupSection or d.ci+1)..' <LINE> '..tr(r.partial and 'PartialGroupTip' or r.target.whole and 'ParentRulesTip' or (r.configMode or d.configMode)=='inherit' and 'InheritedTip' or (r.configMode or d.configMode)=='custom' and 'CustomTip' or 'IndependentTip')
            if r==s.selected then rail.selected=#rail.items end
        end
        if rail.setYScroll then rail:setYScroll(math.max(math.min(0,rail:getHeight()-#rail.items*rail.itemheight),math.min(0,scroll))) end
        if buttons.containers then buttons.containers:setTitle(Q.DiscoveryView.label(s)..' v') end
        return true
    end
    local shelfIcon=getTexture('media/ui/Container_Shelf.png')
    rail.doDrawItem=function(self,y,item)
        if y+self:getYScroll()+item.height<=0 or y+self:getYScroll()>=self:getHeight() then return y+item.height end
        local r=item.item
        SharedUI.Renderer.row(self,y,item.height,item.index,r==s.selected,self.mouseoverselected==item.index)
        local icon=ContainerButtonIcons[r.target.kind] or shelfIcon
        if r.target.whole then SharedUI.Renderer.text(self,expanded[r.target.group] and 'v' or '>',5,y+(item.height-SharedUI.Theme.metrics().font)/2,SharedUI.Theme.colors.text) end
        local indent=r.target.whole and 22 or r.nested and 14 or 0
        sprites:draw(self,r.target,icon,5+indent,y+(item.height-32)/2,32)
        if self:getWidth()>80 then SharedUI.Renderer.text(self,SharedUI.Renderer.fit(item.text,self:getWidth()-48-indent),43+indent,y+(item.height-SharedUI.Theme.metrics().font)/2,SharedUI.Theme.colors.text) end
        if r.dirty then SharedUI.Badge.draw(self,'*',2,y+1,'warning') end
        if r.error then item.tooltip=SharedUI.Tooltip.plain(name(r.target))..' <LINE> '..tr(r.error) end
        return y+item.height
    end
    local function choose(r)
        if s.busy then return end
        SharedUI.RowTooltip.hide(rail)
        capture(); status('Loading')
        s:select(r.target,function(result) if result=='ok' then bind() else status(result);highlight:clear() end end)
    end
    local function toggle(r)
        capture();expanded[r.target.group]=not expanded[r.target.group]
        if not expanded[r.target.group] and s.selected and s.selected.target.group==r.target.group and not s.selected.target.whole then choose(r) end
        refreshRail()
    end
    rail:setOnMouseDownFunction(p,function(_,r) if r.target.whole and rail.getMouseX and rail:getMouseX()<24 then toggle(r) else choose(r) end end)
    rail.onJoypadDown=function(self,button)
        if button==Joypad.AButton then local item=self.items[self.selected]; if item then choose(item.item) end
        elseif button==Joypad.XButton then local item=self.items[self.selected];if item and item.item.target.whole then toggle(item.item) end
        elseif button==Joypad.YButton then
            local item=self.items[self.selected];if item then SharedUI.Tooltip.inspect(p.playerNum,item.tooltip,p) end
        elseif button==Joypad.BButton then setJoypadFocus(p.playerNum,p) end
    end
    local function button(key,action)
        local b=ISButton:new(0,0,90,24,tr(key),p,function() if not s.busy and (s.id or key=='Refresh') then action() end end)
        b:initialise(); b:instantiate(); p:addChild(b); return b
    end
    buttons.whole=button('WholeContainer',function()
        local r=s.selected;if not r then return end
        if r.configMode=='inherit' then s:customize();bind()
        elseif r.target.whole then r.pendingAction='activate';bind()
        elseif r.target.group then choose(s:parent(r.target.group)) end
    end)
    buttons.apply=button('ResetWhole',function()
        local r=s.selected;if not r then return end
        if not r.confirmReset then r.confirmReset=true;buttons.apply:setTitle(tr('ConfirmReset'));return end
        r.confirmReset=nil
        if r.target.whole then r.pendingAction='remove';r.working=Q.Schema.empty()
        elseif r.pendingAction=='custom' and r.configMode=='inherit' then r.pendingAction=nil;r.working=C.clone(r.original)
        else s:reset() end
        bind();refreshRail();status('Staged')
    end)
    buttons.copy=button('Copy',function() if s.selected then capture(); Q.workingClipboard=C.clone(s.selected.working); status('Copied') end end)
    buttons.paste=button('Paste',function()
        if not s.selected then return end
        local clip=Q.workingClipboard
        if not clip then status('NoClipboard'); return end
        local config={cats=C.clone(clip.cats or {}),items=C.clone(clip.items or {}),presets=C.clone(clip.presets or {}),priority=clip.priority or 0,allocation=C.clone(clip.allocation)}
        if not C.valid(config) then status('invalid'); return end
        if s.selected.partial then status('invalid');return end
        if s.selected.configMode=='inherit' then s:customize() end
        s.selected.working=config; s.selected.introduced={}; bind(); capture(); status('Staged')
    end)
    local function clearSelection()
        local empty=Q.Schema.empty()
        p.selectedCats,p.selectedItems,p.selectedPresets=empty.cats,empty.items,empty.presets
        p.allocation=empty.allocation
        p.selection=p.mode=='presets' and p.selectedPresets or p.selectedCats;p:setPriority(0)
        p.qmss.catalog=Catalog.build({},{});p.qmss.model=Q.Model.new(p,p.qmss.catalog,tr('Other'),p.qmss.catalog.owner)
        p.qmss.model.readOnly=true;p.qmss.rangeAnchor=nil
        s.siblings={};buttons.whole:setVisible(false);buttons.apply:setVisible(false)
        for _,control in ipairs({p.btnSave,p.btnPriorityDown,p.btnPriorityUp,p.priorityEntry,p.btnModePreset}) do control:setEnable(false) end
        p:rebuild();p:configJoypad()
    end
    local function refreshDiscovery()
        if Q.RoomSort and Q.RoomSort.active[p.playerNum] then status('busy');return end
        capture();status('DiscoveringContainers')
        local refresh=s.id and s.refresh or s.open;refresh(s,function(result)
        if p.removed then return end
        if result=='ok' then
            baseCatalog=Catalog.build()
            for _,r in pairs(s.records) do r.catalog=nil end
            if s.selected then bind() end
        end
        local present=false
        for _,r in ipairs(s.targets) do if r==s.selected then present=true;break end end
        if result~='ok' or not present then highlight:clear() end
        if not s.selected then clearSelection() end
        refreshRail(); status(result=='ok' and (#s.targets==0 and 'NoContainers' or 'LoadedOnly')
            or result=='TaxonomyPeerMismatch' and result or 'ContainersFailed')
    end)
    end
    buttons.refresh=button('Refresh',refreshDiscovery)
    local function selectView(view)
        capture();s:setView(view,function(result)
            refreshRail()
            if s.selected then bind()
            elseif result=='ok' then
                -- Retain staged records, but never keep a hidden target editable.
                clearSelection()
            end
            status(result=='ok' and (s.selected and 'Ready' or 'ChooseTarget') or result)
        end)
    end
    local function scopeMenu()
        if not s.viewInfo then return end
        local x=getMouseX and getMouseX() or p.x;local y=getMouseY and getMouseY() or p.y
        local menu=SharedUI.menu(ISContextMenu.get(p.playerNum,x,y))
        local building=menu:addOption(tr('ScopeBuilding'),p,function() selectView({kind='building'}) end);building.notAvailable=not s.viewInfo.buildingAvailable
        SharedUI.Tooltip.context(building,tr(s.viewInfo.buildingAvailable and 'ScopeTip' or 'BuildingDisabledTip'),p.playerNum,menu)
        local rooms=menu:addOption(tr('RoomScope'));local roomMenu=SharedUI.menu(ISContextMenu:getNew(menu));menu:addSubMenu(rooms,roomMenu)
        local customCount=0
        for _,room in ipairs(s.viewInfo.customRooms or {}) do if Q.RoomAccess.designated(room) then
            local selected=room;customCount=customCount+1;roomMenu:addOption(room.label or room.name,p,function() selectView({kind='customRoom',room=selected.id,revision=selected.revision}) end)
        end end
        if customCount==0 then local empty=roomMenu:addOption(tr('AllocationNoRooms'));empty.notAvailable=true end
        if select(2,Q.RoomAccess.service())=='ready' then
        menu:addOption(tr('DesignateRoom'),p,function() capture();highlight:clear();Q.RoomAccess.openEditor(p.playerNum,p,function() if not p.removed then p.discoveryDirty=true end end) end)
        if p.allocationInfo and p.allocationInfo.roomProfiles then
            menu:addOption(tr('AllocationRooms'),p,function() require('B47ANCEDQuartermaster/RoomAllocationUI').menu(p) end)
        end
        end
        local sorting=Q.RoomSort and Q.RoomSort.active[p.playerNum]
        local sort=roomMenu:addOption(tr(sorting and 'RoomStopSorting' or 'RoomSort'),p,function()
            local engine=require 'B47ANCEDQuartermaster/RoomSort'
            if engine.active[p.playerNum] then engine.cancel(p.playerNum);return end
            if s.busy then status('busy');return end
            capture()
            for _,r in pairs(s.records) do if s:dirty(r) then status('RoomSaveSortingFirst');return end end
            local ok=engine.start(p.playerNum,s.view,function(result,moved,skipped)
                if player.setHaloNote then player:setHaloNote(tr('RoomSortSummary',tr(result=='ok' and 'RoomSortComplete' or result=='cancelled' and 'RoomSortCancelled' or result),moved,skipped)) end
                if not p.removed then
                    s.id=nil;s.records={};s.targets={};s.selected=nil;s.preferredAttempt=false;s.discoveryState='uninitialized';p.discoveryDirty=true
                end
            end)
            if not ok then status('busy') else s.selected=nil;clearSelection();highlight:clear();status('RoomSorting') end
        end)
        sort.notAvailable=s.busy or not sorting and (not s.view or s.view.kind~='customRoom')
        local proximity=menu:addOption(tr('ProximityScope'));local radiusMenu=SharedUI.menu(ISContextMenu:getNew(menu));menu:addSubMenu(proximity,radiusMenu)
        for radius=1,s.viewInfo.maxRadius do local n=radius;radiusMenu:addOption(tr('ScopeProximity',n),p,function() selectView({kind='proximity',radius=n}) end) end
        local copy=menu:addOption(tr('CopyWhole'),p,function()
            capture();s.whole=true;s:applyWhole(function(result) s.whole=false;refreshRail();if s.selected then bind() end;status(result=='ok' and 'Staged' or result) end)
        end)
        local selected=s.selected;local parent=selected and selected.target.group and s:parent(selected.target.group)
        copy.notAvailable=not selected or selected.target.whole or not parent or parent.partial or #(selected.target.siblings or {})<2
        SharedUI.Tooltip.context(copy,tr(copy.notAvailable and 'PartialGroupTip' or 'CopyWholeTip'),p.playerNum,menu)
        menu:addOption(tr('Containers'),p,function() setJoypadFocus(p.playerNum,rail) end)
        if p.joyfocus then setJoypadFocus(p.playerNum,menu) end
    end
    buttons.containers=button('Containers',function()
        if Q.RoomSort and Q.RoomSort.active[p.playerNum] then
            local menu=SharedUI.menu(ISContextMenu.get(p.playerNum,getMouseX(),getMouseY()))
            menu:addOption(tr('RoomStopSorting'),p,function() Q.RoomSort.cancel(p.playerNum) end);return
        end
        s:request('roomList',{},function(result)
            if p.removed then return end
            if result.status=='ok' then s.viewInfo.customRooms=result.rooms elseif result.status=='RoomServiceAbsent' then s.viewInfo.customRooms={} end
            scopeMenu()
        end)
    end)
    buttons.cancel=button('Cancel',function() p:closePicker() end)
    local oldClose=p.closePicker
    p.closePicker=function(self)
        if s:close() then active[self]=nil;sprites:clear();SharedUI.RowTooltip.hide(rail);highlight:clear();return oldClose(self) end
    end
    p.close=p.closePicker
    local oldRemove=p.removeFromUIManager
    p.removeFromUIManager=function(self,...)
        active[self]=nil
        sprites:clear()
        SharedUI.RowTooltip.hide(rail)
        highlight:clear()
        return oldRemove(self,...)
    end
    p.onSave=function()
        if not s.selected or s.busy then return end
        capture(); status('Saving')
        s:save(function(result)
            local function showSaved()
                for _,r in pairs(s.records) do r.dirty=s:dirty(r) end
                if s.selected and s.selected.working then bind() end
                refreshRail();status(result)
            end
            if s.selected and not s.selected.working then
                -- A saved Whole Container may invalidate this inherited child.
                s:select(s.selected.target,function(loaded)
                    if loaded=='ok' then showSaved()
                    else s.selected=nil;clearSelection();refreshRail();status(loaded) end
                end)
            else showSaved() end
        end)
    end
    p.btnSave.onclick=p.onSave
    local rebuild=p.rebuild
    p.rebuild=function(self) rebuild(self); capture() end
    local typed=p.priorityEntry.onTextChangeFunction
    p.priorityEntry.onTextChangeFunction=function(self,...) typed(self,...); capture() end
    for _,b in ipairs({p.btnPriorityDown,p.btnPriorityUp}) do
        local click=b.onclick; b.onclick=function(self,...) click(self,...); capture() end
    end
    local layout=p.layout
    p.layout=function(self)
        local getWidth,getHeight=self.getWidth,self.getHeight
        local w,h=getWidth(self),getHeight(self)
        -- Native ISUI getters read Java dimensions, not the Lua width/height fields.
        -- Give the inherited layout a content viewport without resizing the window.
        self.getWidth=function() return w-64 end
        self.getHeight=function() return h-60 end
        local ok,err=pcall(layout,self)
        self.getWidth,self.getHeight=getWidth,getHeight
        if not ok then error(err) end
        self.lastWidth,self.lastHeight=w,h
        rail.itemheight=SharedUI.Theme.metrics().railRow
        for _,entry in ipairs(rail.items) do entry.height=rail.itemheight end
        rail:setScrollHeight(#rail.items*rail.itemheight)
        local controls={'filter','btnModeCat','btnModeItem','btnModePreset','chkChecked','chkContents','btnPriorityDown','btnPriorityUp','priorityEntry','priorityLabel','listbox','btnAll','btnClear','btnSave'}
        for _,key in ipairs(controls) do local c=self[key]; c:setX(c.x+64) end
        self.qmss.bulkButton:setX(self.qmss.bulkButton.x+64)
        rail:setHeight(h-48)
        if rail.vscroll then rail.vscroll:setX(rail.width-rail.vscroll:getWidth()); rail.vscroll:setHeight(rail.height) end
        local row1={buttons.whole,buttons.apply,buttons.copy,buttons.paste}
        local row2={buttons.containers,buttons.refresh,buttons.cancel}
        for ri,row in ipairs({row1,row2}) do
            local width=(w-84-6*(#row-1))/#row
            for i,b in ipairs(row) do b:setX(74+(i-1)*(width+6)); b:setY(h-64+(ri-1)*28); b:setWidth(width) end
        end
        if self.dimmer then self.dimmer:setWidth(w); self.dimmer:setHeight(h) end
    end
    local joy=p.configJoypad
    p.configJoypad=function(self)
        joy(self)
        if # (s.siblings or {})>=2 then self:insertNewLineOfButtons(buttons.whole,buttons.apply) end
        self:insertNewLineOfButtons(buttons.containers,buttons.copy,buttons.paste,buttons.refresh,buttons.cancel)
    end
    -- Retain the font-aware shell minimum. Constrained viewports cannot be made
    -- larger than the player's screen by an adapter.
    local screenW=getPlayerScreenWidth and getPlayerScreenWidth(p.playerNum)-40 or math.huge
    local screenH=getPlayerScreenHeight and getPlayerScreenHeight(p.playerNum)-40 or math.huge
    p.minimumWidth=math.min(screenW,math.max(p.minimumWidth,640))
    p.minimumHeight=math.min(screenH,math.max(p.minimumHeight,460))
    if p.width<p.minimumWidth then p:setWidth(p.minimumWidth) end
    if p.height<p.minimumHeight then p:setHeight(p.minimumHeight) end
    if p.dimmer then p:removeChild(p.dimmer); p:addChild(p.dimmer) end
    buttons.whole:setVisible(false); buttons.apply:setVisible(false)
    local nextCheck=0
    local oldUpdate=p.update
    p.update=function(self,...)
        if oldUpdate then oldUpdate(self,...) end
        if not self.removed and getTimestampMs()>=nextCheck then
            nextCheck=getTimestampMs()+500
            Q.AllocationUI.info(self)
            highlight:tick(s.selected and s.selected.target)
        end
        if not self.removed and self.discoveryDirty and not s.busy and s.discoveryState~='discovering' and not (Q.RoomSort and Q.RoomSort.active[self.playerNum]) then
            self.discoveryDirty=false
            refreshDiscovery()
        end
    end
    p:layout(); refreshRail(); status('DiscoveringContainers')
    p.listbox:setVisible(false)
    p.btnSave:setEnable(false)
    s:open(function(result)
        refreshRail()
        if result=='ok' then bind()
        elseif result=='ChooseTarget' and #s.targets==0 then status('NoContainers')
        elseif result=='ChooseTarget' then status(result)
        else clearSelection();status((result=='TaxonomyPeerMismatch' or result=='RoomUnavailable') and result or 'ContainersFailed') end
    end)
end
return M
