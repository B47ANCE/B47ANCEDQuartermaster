require 'B47ANCEDQuartermaster/Picker'
require 'B47ANCEDQuartermaster/Model'
require 'B47ANCEDQuartermaster/Ownership'
require 'B47ANCEDQuartermaster/UIOptions'
require 'B47ANCEDUI/Controls'
local AllocationUI=require 'B47ANCEDQuartermaster/AllocationUI'

local Q = B47ANCEDQuartermaster
local function tr(key) return getText('UI_QMSS_' .. key) end
local function combined(p) return p.mode ~= 'presets' end

local function restoreScroll(lb, y)
    local minimum = -math.max(0, lb:getScrollHeight() - lb:getHeight())
    lb.smoothScrollTargetY, lb.smoothScrollY = nil, nil
    lb:setYScroll(math.max(minimum, math.min(0, y)))
end

local function capture(lb)
    local y = lb:getYScroll()
    local index = math.max(1, math.floor(-y / lb.itemheight) + 1)
    local row = lb.items[index] and lb.items[index].item
    local selected = lb.items[lb.selected] and lb.items[lb.selected].item
    return { y = y, id = row and row.id, group = row and row.group,
        offset = y + (index - 1) * lb.itemheight, selected = selected and selected.id }
end

local function rebuild(p)
    local a, lb = p.qmss, p.listbox
    if not combined(p) then
        local result = a.original.rebuild(p)
        Q.updateCount(p)
        return result
    end
    local anchor = capture(lb)
    local text = p:currentFilter()
    local filterKey = string.lower(text) .. '\0' .. tostring(p.onlyChecked) .. '\0' .. tostring(p.onlyContents)
    if a.filterKey ~= filterKey then
        a.filterKey, a.filterExpanded, a.rangeAnchor = filterKey, {}, nil
    end
    a.filtered = text ~= '' or p.onlyChecked or p.onlyContents
    -- Use the owned contents cache in item-name mode without changing the selection alias.
    local contents
    if p.onlyContents then
        local mode = p.mode
        p.mode = 'items'
        contents = p:contentsSet()
        p.mode = mode
    end
    a.model:refresh()
    local rows, matches = a.model:rows(text, p.onlyChecked, contents, a.expanded, a.filterExpanded)
    rows=AllocationUI.rows(p,rows)
    a.matches = matches
    lb:clear()
    lb:setScrollHeight(0)
    local anchorIndex, parentIndex, selectedIndex
    for index, row in ipairs(rows) do
        local label = (row.kind == 'category' or row.kind=='subcategory') and row.group.label or (row.kind == 'mod' and row.mod.label or row.allocationLabel or row.key)
        local entry = lb:addItem(label, row)
        if row.kind == 'item' and #(a.model.memberships[row.key] or {}) > 1 then
            entry.tooltip = tr('SharedTip')
        end
        if row.id == anchor.id then anchorIndex = index end
        if (row.kind == 'category' or row.kind=='subcategory') and row.group == anchor.group then parentIndex = index end
        if row.id == anchor.selected then selectedIndex = index end
    end
    lb:setScrollHeight(#rows * lb.itemheight)
    lb.selected = selectedIndex or parentIndex or math.min(lb.selected or 1, #rows)
    local at = anchorIndex or parentIndex
    restoreScroll(lb, at and (-(at - 1) * lb.itemheight + anchor.offset) or anchor.y)
    local foundAnchor = false
    for _, row in ipairs(rows) do if row.id == a.rangeAnchor then foundAnchor = true; break end end
    if not foundAnchor then a.rangeAnchor = nil end
    p.lastFilter, p.needRebuild = string.lower(text), false
    Q.updateCount(p)
    if Q.updateActionVisibility then Q.updateActionVisibility(p) end
end

local function rowState(p, row)
    if row.kind == 'category' or row.kind=='subcategory' then return row.group.state end
    if row.kind == 'mod' then return row.mod.state end
    return p.qmss.model:covered(row.group, row.key) and 'full' or 'none'
end
function Q.updateActionVisibility(p)
    if not p.qmss or not p.qmss.model or not combined(p) then return end
    if p.allocationOnly then p.btnAll:setVisible(false);p.btnClear:setVisible(false);return end
    local canSelect,canClear=false,false
    for _,entry in ipairs(p.listbox.items) do
        local row=entry.item
        if row.kind=='item' then
            if p.qmss.model:covered(row.group,row.key) then canClear=true else canSelect=true end
        end
    end
    p.btnAll:setVisible(canSelect)
    p.btnClear:setVisible(canClear)
end

local function rowById(p, id)
    for i, entry in ipairs(p.listbox.items) do
        if entry.item.id == id then return entry.item, i end
    end
end

local function expand(p, row)
    if row and row.kind ~= 'item' then
        local state = p.qmss.filtered and p.qmss.filterExpanded or p.qmss.expanded
        state[row.id] = not row.open
        p:rebuild()
    end
end

function Q.expandAll(p, on)
    local state = p.qmss.filtered and p.qmss.filterExpanded or p.qmss.expanded
    for _, group in ipairs(p.qmss.model.groups) do
        state[group.id] = on
        for _, mod in ipairs(group.mods) do state[mod.id] = on end
    end
    p:rebuild()
end

function Q.visibleAction(p, action)
    if p.allocationOnly then return end
    local rows = {}
    for _, entry in ipairs(p.listbox.items) do
        if entry.item.kind == 'item' then rows[#rows + 1] = entry.item end
    end
    p.qmss.rangeAnchor = nil
    p.qmss.model:applyRows(rows, action)
    p:rebuild()
end

function Q.rangeAction(p, row, preserveAnchor, range)
    if p.allocationOnly then return end
    if not row then return end
    local a = p.qmss
    local current, index = rowById(p, row.id)
    if not current then return end
    local anchor, first = rowById(p, a.rangeAnchor)
    local rows = {current}
    local useRange=range and anchor and anchor.kind==current.kind
    if useRange then
        rows = {}
        for i = math.min(first,index), math.max(first,index) do
            local candidate = p.listbox.items[i].item
            if candidate.kind == current.kind then rows[#rows + 1] = candidate end
        end
    elseif not preserveAnchor then a.rangeAnchor = current.id end
    local action = rowState(p, current) == 'none' and 'select' or 'clear'
    if useRange then
        -- Category/mod ranges affect only descendants actually rendered now.
        -- Direct checkbox clicks retain the existing whole-category transition.
        local selected,items={},{}
        for _,target in ipairs(rows) do selected[target.id]=true end
        for _,entry in ipairs(p.listbox.items) do
            local item=entry.item
            if item.kind=='item' then
                local include=selected[item.id] or (item.mod and selected[item.mod.id])
                local group=item.group
                while group and not include do include=selected[group.id];group=group.displayParent end
                if include then items[#items+1]=item end
            end
        end
        rows=items
    end
    a.model:applyRows(rows, action)
    p:rebuild()
end

local function selectRow(p, row)
    Q.rangeAction(p, row, false, false)
end

function Q.context(p, row, x, y)
    local menu = B47ANCEDUI.menu(ISContextMenu.get(p.playerNum or 0, x, y))
    AllocationUI.context(p,row,menu)
    AllocationUI.actions(p,menu)
    if p.allocationOnly then
        if row and row.kind~='item' then menu:addOption(tr(row.open and 'CollapseCategory' or 'ExpandCategory'),p,function() expand(p,row) end) end
        if p.allocationRoomMenu then p.allocationRoomMenu(menu) end
        if p.grabbedJoypad then setJoypadFocus(p.playerNum,menu) end
        return menu
    end
    local function add(target, key, fn) target:addOption(tr(key), p, fn) end
    local function visibleOptions(target)
        add(target, 'SelectVisible', function() Q.visibleAction(p, 'select') end)
        add(target, 'ClearVisible', function() Q.visibleAction(p, 'clear') end)
        add(target, 'InvertVisible', function() Q.visibleAction(p, 'invert') end)
        add(target, 'ExpandAll', function() Q.expandAll(p, true) end)
        add(target, 'CollapseAll', function() Q.expandAll(p, false) end)
    end
    if row and row.kind ~= 'item' then
        for _, entry in ipairs({{'SelectItems','select'},{'ClearItems','clear'},{'InvertItems','invert'}}) do
            local action = entry[2]
            local group=row.kind=='mod' and row.mod or row.group
            local eligible=#group.children>0 and ((action=='select' and group.state~='full') or (action=='clear' and group.state~='none') or action=='invert')
            if eligible then add(menu, entry[1], function()
                local current = rowById(p, row.id)
                if current then p.qmss.model:applyRows({current}, action); p:rebuild() end
            end) end
        end
        local key = row.kind == 'mod' and (row.open and 'CollapseMod' or 'ExpandMod')
            or (row.open and 'CollapseCategory' or 'ExpandCategory')
        add(menu, key, function() expand(p, rowById(p, row.id)) end)
        local submenu = B47ANCEDUI.menu(ISContextMenu:getNew(menu))
        menu:addSubMenu(menu:addOption(tr('VisibleList')), submenu)
        visibleOptions(submenu)
    else visibleOptions(menu) end
    menu:addOption((Q.UIOptions.groupByMod() and '[x] ' or '[ ] ')..tr('GroupItemsByMod'),p,function()
        Q.UIOptions.setGroupByMod(not Q.UIOptions.groupByMod())
    end)
    if row then
        local rangeMenu = B47ANCEDUI.menu(ISContextMenu:getNew(menu))
        menu:addSubMenu(menu:addOption(tr('Range')), rangeMenu)
        add(rangeMenu, 'SetAnchor', function() p.qmss.rangeAnchor = row.id end)
        local anchor = rowById(p, p.qmss.rangeAnchor)
        if anchor and anchor.kind == row.kind then
            add(rangeMenu, 'ApplyRange', function() Q.rangeAction(p, row, false, true) end)
        end
    end
    if p.grabbedJoypad then
        menu.origin = p
        menu.mouseOver = 1
        setJoypadFocus(p.playerNum, menu)
    end
    return menu
end

local function updateCount(p)
    local cats, items = p.selectedCats, p.selectedItems
    local effective=Q.Schema.effective({cats=cats,items=items,presets=p.selectedPresets,priority=0},p:getPresetStore())
    cats,items=effective.cats,effective.items
    p.qmss.count = p.qmss.model:effectiveCount(cats, items)
    p.btnModeCat:setTitle(p.allocationOnly and tr('AllocationControl') or tr('Combined') .. ' (' .. p.qmss.count .. ')')
end
Q.updateCount = updateCount

-- Only linked presets need monitoring between UI edits. Revision/generation changes
-- come from server snapshots; no item catalog scan occurs in prerender.
local function presetSignature(p)
    local store, parts = p:getPresetStore(), {}
    for name, link in pairs(p.selectedPresets or {}) do
        if link then
            local preset = store[name]
            parts[#parts + 1] = name .. ':' .. tostring(link) .. ':' ..
                tostring(preset and preset.gen) .. ':' .. tostring(preset and preset.rev)
        end
    end
    table.sort(parts)
    return table.concat(parts, '|')
end

local function drawRow(lb, y, entry, alt)
    local p = lb.target
    if not combined(p) then return p.qmss.original.draw(lb, y, entry, alt) end
    local row, height = entry.item, entry.height
    if y + lb:getYScroll() + height < 0 or y + lb:getYScroll() >= lb:getHeight() then return y + height end
    local state = rowState(p, row)
    local width = lb:getWidth()
    if lb:isVScrollBarVisible() then width = lb.vscroll.x end
    local UI=B47ANCEDUI
    UI.Renderer.row(lb,y,height,entry.index,lb.selected==entry.index,lb.mouseoverselected==entry.index and lb:isMouseOver())
    local x = UI.Tree.indent(row.depth)
    local by = y + (height - 16) / 2
    if not p.allocationOnly then UI.Tree.checkbox(lb,x,by,state) end
    local label = (row.kind == 'category' or row.kind=='subcategory') and row.group.label or (row.kind == 'mod' and row.mod.label or row.key)
    local font = UIFont.Small
    local fy = y + (height - getTextManager():getFontHeight(font)) / 2
    local textX = x + 23
    if row.kind == 'item' then
        local texture = Q.Picker.itemTexture(row.allocationFullType or (p.qmss.catalog or p.api).getItemFullType(row.key))
        if texture then
            UI.Renderer.icon(lb,texture,textX,y+(height-18)/2,18)
        end
        -- Keep names aligned even when a removed/modded item has no texture.
        textX = textX + 24
    end
    -- Vanilla's outer stencil clips long labels; reserve the disclosure area with an opaque backing.
    local allocationLeft=AllocationUI.index(p) and select(1,AllocationUI.geometry(lb)) or width-29
    UI.Renderer.text(lb,UI.Renderer.fit(row.allocationLabel or label,math.max(0,allocationLeft-textX-8),font),textX,fy,row.kind=='category' and UI.Theme.colors.text or row.kind=='mod' and UI.Theme.colors.muted or UI.Theme.colors.text,font)
    AllocationUI.draw(p,lb,y,height,row)
    if row.kind ~= 'item' then
        UI.Renderer.rect(lb,width-25,y,25,height-1,UI.Theme.colors.raised)
        UI.Renderer.text(lb,row.open and '-' or '+',width-18,fy,UI.Theme.colors.accent,font)
    end
    return y + height
end

local function layout(p)
    p.qmss.original.layout(p)
    -- The owned list starts with a small placeholder geometry. Native clipping reads scrollbar.x directly,
    -- so explicitly synchronize both Lua and Java geometry after sizing the list.
    local lb = p.listbox
    if lb.vscroll then
        lb.vscroll:setX(math.max(0, lb:getWidth() - lb.vscroll:getWidth()))
        lb.vscroll:setY(0)
        lb.vscroll:setHeight(lb:getHeight())
    end
    p.btnModeItem:setVisible(false)
    local gap, inner = 6, p:getWidth() - 20
    local presetWidth = math.min(85, inner / 3)
    p.btnModeCat:setWidth(inner - presetWidth - gap)
    p.btnModePreset:setX(10 + inner - presetWidth)
    p.btnModePreset:setWidth(presetWidth)
    p.btnModePreset:setVisible(p.targetKind=='box')
    p.btnModeCat:setTitle(p.allocationOnly and tr('AllocationControl') or tr('Combined') .. ' (' .. (p.qmss.count or 0) .. ')')
    local a = p.qmss
    if a.bulkButton then
        a.bulkButton:setVisible(p.targetKind=='box' or combined(p))
        a.bulkButton:setTitle(combined(p) and tr('Bulk') or tr('PresetManage'))
        local buttons = (combined(p) or p.targetKind=='box') and {p.btnAll,p.btnClear,p.btnSave,a.bulkButton}
            or {p.btnAll,p.btnClear,p.btnSave}
        local width = (inner - 6 * (#buttons-1)) / #buttons
        for i, button in ipairs(buttons) do
            button:setX(10 + (i-1)*(width+6)); button:setY(p.btnSave.y)
            button:setWidth(width); button:setHeight(26)
        end
        p.btnAll:setTitle(combined(p) and tr('SelectVisible') or a.allTitle)
        p.btnClear:setTitle(combined(p) and tr('ClearVisible') or a.clearTitle)
    end
end

local function configureJoypad(p)
    -- Preserve shell focus rows while excluding the obsolete hidden mode button.
    local insert = p.insertNewLineOfButtons
    p.insertNewLineOfButtons = function(self, ...)
        local buttons = {}
        for _, button in ipairs({ ... }) do
            if button ~= self.btnModeItem then buttons[#buttons + 1] = button end
        end
        if buttons[1] == self.btnAll and (combined(self) or self.targetKind=='box') then buttons[#buttons + 1] = self.qmss.bulkButton end
        return insert(self, unpack(buttons))
    end
    local ok, err = pcall(p.qmss.original.configJoypad, p)
    p.insertNewLineOfButtons = insert
    if not ok then error(err) end
end

function Q.adapt(p)
    if not p or p.qmss then return false end
    for _, method in ipairs({ 'rebuild', 'layout', 'prerender', 'setMode', 'configJoypad', 'currentFilter', 'contentsSet' }) do
        if type(p[method]) ~= 'function' then return false end
    end
    for _, field in ipairs({ 'listbox', 'btnModeCat', 'btnModeItem', 'btnModePreset', 'btnAll', 'btnClear' }) do
        if not p[field] then return false end
    end
    for _, name in ipairs({ 'getCategories', 'getItemNames', 'getItemsInCategory', 'getItemFullType' }) do
        if type(p.api[name]) ~= 'function' then return false end
    end
    if type(p.selectedCats) ~= 'table' or type(p.selectedItems) ~= 'table' then return false end
    -- Build the model before attaching callbacks: a catalog failure leaves the native picker intact.
    local ok, model = pcall(Q.Model.new, p, p.api, tr('Other'), p.api.owner or Q.Ownership.build())
    if not ok then print('[B47ANCEDQuartermaster] Catalog unavailable; editor not attached.'); return false end
    local lb = p.listbox
    local a = { allTitle = p.btnAll.title, clearTitle = p.btnClear.title, model = model, expanded = {}, matches = {}, scroll = {}, original = {
        rebuild = p.rebuild, layout = p.layout, prerender = p.prerender, setMode = p.setMode,
        configJoypad = p.configJoypad, draw = lb.doDrawItem, mouse = lb.onMouseDown,
        click = lb.onmousedown, right = lb.onRightMouseUp, joypad = lb.onJoypadDown,
        all = p.btnAll.onclick, clear = p.btnClear.onclick,
    } }
    p.qmss = a
    p.rebuild, p.layout, p.configJoypad = rebuild, layout, configureJoypad
    p.prerender = function(self)
        a.original.prerender(self)
        local signature = presetSignature(self)
        if a.presetSignature ~= signature then a.presetSignature = signature; updateCount(self) end
        self.btnModeCat:setTitle(tr('Combined') .. ' (' .. (a.count or 0) .. ')')
        self.btnModeItem:setVisible(false)
        AllocationUI.notice(self)
    end
    p.setMode = function(self, target)
        if self.targetKind~='box' then target='cats' end
        target = target == 'presets' and 'presets' or 'cats'
        if self.mode == target then return end
        a.rangeAnchor = nil
        a.scroll[self.mode] = lb:getYScroll()
        a.original.setMode(self, target)
        self:layout()
        self:rebuild()
        restoreScroll(lb, a.scroll[target] or 0)
    end
    p.cycleMode = function(self, direction)
        if direction > 0 then self:setMode('presets') else self:setMode('cats') end
    end
    p.btnModeCat.onclick = function(self) self:setMode('cats') end
    p.btnModeCat:setTooltip(tr('SortingSummaryTip'))
    p.btnAll:setTitle(tr('SelectVisible'))
    p.btnAll.onclick = function(self, ...)
        if not combined(self) then local result = a.original.all(self, ...); updateCount(self); return result end
        Q.visibleAction(self, 'select')
    end
    p.btnClear:setTitle(tr('ClearVisible'))
    p.btnClear.onclick = function(self, ...)
        if not combined(self) then local result = a.original.clear(self, ...); updateCount(self); return result end
        Q.visibleAction(self, 'clear')
    end
    a.bulkButton = ISButton:new(0, 0, 90, 26, tr('Bulk'), p, function(self)
        if not combined(self) then self:presetMenu();return end
        local entry = lb.items[lb.selected]
        Q.context(self, entry and entry.item, self:getAbsoluteX()+20, self:getAbsoluteY()+40)
    end)
    a.bulkButton:initialise(); a.bulkButton:instantiate(); p:addChild(a.bulkButton)
    -- Keep the modal dimmer above the new button, as it was above all original controls.
    if p.dimmer then p:removeChild(p.dimmer); p:addChild(p.dimmer) end
    local function shortcut(self, key)
        return key == Keyboard.KEY_A and isCtrlKeyDown() and combined(self)
            and self:isVisible() and not self.removed
            and not (self.dimmer and self.dimmer:isVisible())
            and not self.filter:isFocused() and not self.priorityEntry:isFocused()
    end
    local keyConsumed, keyPress = p.isKeyConsumed, p.onKeyPress
    local function allocationKey(self,key)
        return combined(self) and isAltKeyDown and isAltKeyDown() and (key==Keyboard.KEY_LEFT or key==Keyboard.KEY_RIGHT or key==Keyboard.KEY_RETURN)
            and self:isVisible() and not self.removed and not self.dimmer:isVisible() and not self.filter:isFocused() and not self.priorityEntry:isFocused()
    end
    p.isKeyConsumed = function(self, key)
        if shortcut(self, key) or allocationKey(self,key) then return true end
        return keyConsumed and keyConsumed(self, key) or false
    end
    p.onKeyPress = function(self, key)
        if allocationKey(self,key) then
            local entry=self.listbox.items[self.listbox.selected];if not entry then return end
            if key==Keyboard.KEY_RETURN then AllocationUI.exact(self,entry.item)
            else local value=AllocationUI.state(self,entry.item);AllocationUI.set(self,entry.item,math.max(0,math.min(100,(value or 100)+(key==Keyboard.KEY_LEFT and -5 or 5)))) end
            return true
        end
        if shortcut(self, key) then
            Q.visibleAction(self, isShiftKeyDown() and 'clear' or 'select')
        elseif keyPress then return keyPress(self, key) end
    end
    p:setWantKeyEvents(true)
    lb.doDrawItem = drawRow
    lb.onmousedown = function(self, row)
        if not combined(self) then local result = a.original.click(self, row); updateCount(self); return result end
        selectRow(self, row)
    end
    lb.onMouseDown = function(self, x, y)
        if not combined(p) then local result = a.original.mouse(self, x, y); updateCount(p); return result end
        -- Scrollbar is its own child; never treat its strip as a disclosure control.
        if self:isVScrollBarVisible() and x >= self.vscroll.x then return end
        local index = self:rowAt(x, y)
        local entry = self.items[index]
        if not entry then return end
        self.selected = index
        if AllocationUI.press(p,self,entry.item,x) then return true end
        if p.allocationOnly then if entry.item.kind~='item' then expand(p,entry.item) else AllocationUI.exact(p,entry.item) end;return true end
        getSoundManager():playUISound('UISelectListItem')
        if entry.item.kind ~= 'item' and x >= 30 + (entry.item.depth or 0) * 20 then
            if isShiftKeyDown() then Q.expandAll(p, not entry.item.open) else expand(p, entry.item) end
        else Q.rangeAction(p, entry.item, isCtrlKeyDown(), isShiftKeyDown()) end
    end
    lb.onRightMouseUp = function(self, x, y)
        if not combined(p) then return a.original.right(self, x, y) end
        local entry = self.items[self:rowAt(x, y)]
        return Q.context(p, entry and entry.item, getMouseX(), getMouseY())
    end
    local oldMove,oldMoveOutside,oldUp,oldUpOutside=lb.onMouseMove,lb.onMouseMoveOutside,lb.onMouseUp,lb.onMouseUpOutside
    lb.onMouseMove=function(self,x,y)
        if p.allocationDrag then return AllocationUI.move(p,self,self:getMouseX()) end
        if oldMove then return oldMove(self,x,y) end
    end
    lb.onMouseMoveOutside=function(self,x,y)
        if p.allocationDrag then return AllocationUI.move(p,self,self:getMouseX()) end
        if oldMoveOutside then return oldMoveOutside(self,x,y) end
    end
    lb.onMouseUp=function(self,x,y)
        if p.allocationDrag then AllocationUI.release(p);return true end
        if oldUp then return oldUp(self,x,y) end
    end
    lb.onMouseUpOutside=function(self,x,y)
        if p.allocationDrag then AllocationUI.release(p);return true end
        if oldUpOutside then return oldUpOutside(self,x,y) end
    end
    local close=p.closePicker
    p.closePicker=function(self,...) AllocationUI.release(self);return close(self,...) end
    p.close=function(self,...) return self:closePicker(...) end
    lb.onJoypadDown = function(self, button, data)
        if not combined(p) then local result = a.original.joypad(self, button, data); updateCount(p); return result end
        local entry = self.items[self.selected]
        if p.allocationOnly and button==Joypad.AButton then if entry then Q.context(p,entry.item,getMouseX(),getMouseY()) end;return end
        if button == Joypad.AButton then selectRow(p, entry and entry.item); return end
        if button == Joypad.XButton or button == Joypad.YButton then expand(p, entry and entry.item); return end
        return a.original.joypad(self, button, data)
    end
    p.minimumWidth = math.max(p.minimumWidth or 0, 440)
    if p:getWidth() < p.minimumWidth then p:setWidth(p.minimumWidth) end
    p:layout()
    p:rebuild()
    if p.joypadConfigured then p:configJoypad() end
    if p.targetKind=='box' and getCell then
        require 'B47ANCEDQuartermaster/MultiContainer'
        Q.MultiContainer.attach(p)
    end
    return true
end

function Q.onGroupByModChanged()
    for _,p in pairs(Q.pickers or {}) do
        if p and not p.removed and p.qmss then
            local a=p.qmss
            local introduced=a.model and a.model.introduced
            a.model=Q.Model.new(p,a.catalog or p.api,tr('Other'),(a.catalog or p.api).owner or Q.Ownership.build())
            a.model.introduced=introduced or {}
            a.rangeAnchor=nil
            p:rebuild()
            p:configJoypad()
        end
    end
end

return Q
