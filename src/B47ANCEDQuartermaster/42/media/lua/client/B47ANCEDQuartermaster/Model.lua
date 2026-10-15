-- Owned tree model. Selection tables belong to the standalone B47 picker.
B47ANCEDQuartermaster = B47ANCEDQuartermaster or {}
local Model = {}
B47ANCEDQuartermaster.Model = Model

function Model.new(picker, api, otherLabel, ownerFor)
    local m = { api=api, picker = picker, groups = {}, byId = {}, memberships = {}, introduced = {} }
    setmetatable(m, { __index = Model })
    local cats = {}
    for _, cat in ipairs(api.getCategories()) do cats[cat] = true end
    for cat, on in pairs(picker.selectedCats) do if on then cats[cat] = true end end
    local families=not api.nativeCategories and B47ANCEDQuartermaster.Categorizer and B47ANCEDQuartermaster.Categorizer.families
    if families then
        local function ancestors(cat,seen)
            seen=seen or {};if seen[cat] then return end;seen[cat]=true
            local parents=families.displayParents and families.displayParents[cat]
            for _,parent in ipairs(parents and {parents} or families.parents[cat] or {}) do
                if families.children[parent] then cats[parent]=true;ancestors(parent,seen) end
            end
        end
        local initial={};for cat in pairs(cats) do initial[#initial+1]=cat end
        for _,cat in ipairs(initial) do ancestors(cat) end
        if cats.B47_Weapons then
            for id in pairs(families.displayParents or {}) do cats[id]=true end
        end
    end
    local names = {}
    for cat in pairs(cats) do names[#names + 1] = cat end
    table.sort(names)
    local known = {}
    for _, cat in ipairs(names) do
        local group = { id = 'c:' .. cat, key = cat, label = api.categoryLabel and api.categoryLabel(cat) or cat, children = {}, synthetic=api.explicitCategories==true }
        local seen = {}
        for _, entry in ipairs(api.getItemsInCategory(cat)) do
            local name = entry.name
            if name and not seen[name] then
                seen[name], known[name] = true, true
                group.children[#group.children + 1] = name
                m.memberships[name] = m.memberships[name] or {}
                table.insert(m.memberships[name], group)
            end
        end
        table.sort(group.children)
        m.groups[#m.groups + 1], m.byId[group.id] = group, group
    end
    local others = {}
    for _, name in ipairs(api.getItemNames()) do if not known[name] then others[name] = true end end
    for name, on in pairs(picker.selectedItems) do
        if on and not known[name] then others[name] = true end
    end
    local other = { id = 'other:', label = otherLabel, children = {}, synthetic = true }
    for name in pairs(others) do
        other.children[#other.children + 1] = name
        m.memberships[name] = { other }
    end
    if #other.children > 0 then
        table.sort(other.children)
        m.groups[#m.groups + 1], m.byId[other.id] = other, other
    end
    ownerFor = ownerFor or function() return 'unknown:', 'Other / Unknown' end
    -- Tests without the client preference adapter keep their explicit legacy
    -- tree fixture; the shipped client adapter defaults this setting to OFF.
    m.groupByMod=B47ANCEDQuartermaster.UIOptions and B47ANCEDQuartermaster.UIOptions.groupByMod()==true or B47ANCEDQuartermaster.UIOptions==nil
    for _, group in ipairs(m.groups) do
        group.mods = {};group.ownerLabels={}
        local byMod = {}
        for _, name in ipairs(group.children) do
            local id, label = ownerFor(group.key, name)
            group.ownerLabels[name]=label
            if m.groupByMod and not byMod[id] then
                local mod = { id = group.id .. '\0m:' .. id, ownerId = id, label = label, parent = group, children = {} }
                byMod[id] = mod
                group.mods[#group.mods + 1] = mod
            end
            if m.groupByMod then table.insert(byMod[id].children, name) end
        end
        table.sort(group.mods, function(a, b)
            if (a.ownerId == 'pz-vanilla') ~= (b.ownerId == 'pz-vanilla') then return a.ownerId == 'pz-vanilla' end
            if a.label == b.label then return a.id < b.id end
            return string.lower(a.label) < string.lower(b.label)
        end)
    end
    m.displayRoots={}
    for _,group in ipairs(m.groups) do
        local parent
        if families and group.key then
            local display=families.displayParents and families.displayParents[group.key]
            if display then parent=m.byId['c:'..display]
            elseif not families.children[group.key] then
                for _,id in ipairs(families.parents[group.key] or {}) do
                    if families.children[id] and m.byId['c:'..id] then parent=m.byId['c:'..id];break end
                end
            end
        end
        if families and families.displayHidden and families.displayHidden[group.key] then
            -- Retain saved-rule groups for coverage without showing obsolete branches.
        elseif parent then
            parent.subgroups=parent.subgroups or {}
            parent.subgroups[#parent.subgroups+1]=group
            group.displayParent=parent
        else m.displayRoots[#m.displayRoots+1]=group end
    end
    for _,root in ipairs(m.groups) do
        local order={}
        if families and (root.key=='B47_Weapons' or families.displayParents and families.displayParents[root.key]) then
            for i,id in ipairs(families.children[root.key] or {}) do order[id]=i end
        end
        table.sort(root.subgroups or {},function(a,b)
            if order[a.key] or order[b.key] then return (order[a.key] or math.huge)<(order[b.key] or math.huge) end
            return a.label==b.label and a.id<b.id or a.label<b.label
        end)
    end
    m:refresh()
    return m
end

function Model:covered(group, name, cats, items)
    cats,items=cats or self.picker.selectedCats,items or self.picker.selectedItems
    if self.api.covered then return items[name] or self.api.covered(group.key,name,cats) end
    if (group.key and cats[group.key]) or items[name] then return true end
    for _,membership in ipairs(self.memberships[name] or {}) do
        if self.api.isFamily and self.api.isFamily(membership.key) and cats[membership.key] then return true end
    end
    return false
end

function Model:refresh()
    local selected = {}
    for _, group in ipairs(self.groups) do
        local count = 0
        for _, name in ipairs(group.children) do
            if self:covered(group, name) then count = count + 1; selected[name] = true end
        end
        group.count = count
        if group.key and self.picker.selectedCats[group.key] then group.state = 'full'
        elseif count == 0 then group.state = 'none'
        elseif count == #group.children then group.state = 'full'
        else group.state = 'partial' end
        for _, mod in ipairs(group.mods) do
            local n = 0
            for _, name in ipairs(mod.children) do if self:covered(group, name) then n = n + 1 end end
            mod.state = n == 0 and 'none' or (n == #mod.children and 'full' or 'partial')
        end
    end
    for name, on in pairs(self.picker.selectedItems) do if on then selected[name] = true end end
    self.selectedCount = 0
    for _ in pairs(selected) do self.selectedCount = self.selectedCount + 1 end
end

function Model:effectiveCount(cats, items)
    local selected = {}
    for name, on in pairs(items) do if on then selected[name] = true end end
    for _, group in ipairs(self.groups) do
        for _,name in ipairs(group.children) do if self:covered(group,name,cats,items) then selected[name]=true end end
    end
    local count = 0
    for _ in pairs(selected) do count = count + 1 end
    return count
end

function Model:addName(name)
    if not self.picker.selectedItems[name] then
        self.picker.selectedItems[name] = true
        self.introduced[name] = true
    end
end

-- Only normalize groups affected by this user operation, never pre-existing rules on open.
function Model:normalize(affected)
    for _, group in ipairs(self.groups) do
        if affected[group.id] and group.key and not group.synthetic and #group.children > 0 then
            local full = true
            for _, name in ipairs(group.children) do
                if not (self.picker.selectedCats[group.key] or self.picker.selectedItems[name]) then full = false; break end
            end
            if full and not (self.api.isFamily and self.api.isFamily(group.key)) then self.picker.selectedCats[group.key] = true end
        end
    end
    for name in pairs(self.introduced) do
        local safe = true
        for _, group in ipairs(self.memberships[name] or {}) do
            if not group.key or not (self.api.covered and self.api.covered(group.key,name,self.picker.selectedCats) or (not self.api.covered and self.picker.selectedCats[group.key])) then safe = false; break end
        end
        if safe then self.picker.selectedItems[name] = nil; self.introduced[name] = nil end
    end
    self:refresh()
end

function Model:affectName(affected, name)
    for _, group in ipairs(self.memberships[name] or {}) do affected[group.id] = true end
end

-- Every UI mutation uses this transaction. Snapshot intended states before changing any
-- table; convert each affected full category once, then normalize once at the end.
function Model:applyRows(rows, action)
    if self.readOnly then return end
    if #rows == 0 then return end
    local whole, edits, affected, clearNames = {}, {}, {}, {}
    for _, row in ipairs(rows) do
        local group = row.group
        affected[group.id] = true
        if (row.kind == 'category' or row.kind=='subcategory') and action ~= 'invert' then
            whole[group.id] = { group = group, on = action == 'select' }
            if action=='clear' then for _,name in ipairs(group.children) do clearNames[name]=true end end
        else
            local names = row.kind == 'item' and { row.key } or
                (row.kind == 'mod' and row.mod.children or group.children)
            for _, name in ipairs(names) do
                local on = action == 'select'
                if action == 'invert' then on = not self:covered(group, name) end
                edits[#edits + 1] = { group = group, name = name, on = on }
                if not on then clearNames[name] = true end
            end
        end
    end
    -- Preserve untouched members of selected parent/compatibility families.
    -- Independent leaf-category rules retain their existing additive semantics.
    local split={}
    for name in pairs(clearNames) do
        for _,membership in ipairs(self.memberships[name] or {}) do
            if self.api.isFamily and self.api.isFamily(membership.key) and self.picker.selectedCats[membership.key] then split[membership.id]=membership end
        end
    end
    for _,family in pairs(split) do
        self.picker.selectedCats[family.key]=nil
        for _,name in ipairs(family.children) do self:addName(name);self:affectName(affected,name) end
    end
    for _, command in pairs(whole) do
        local group, on = command.group, command.on
        if group.key then self.picker.selectedCats[group.key] = on and not group.synthetic or nil end
        for _, name in ipairs(group.children) do
            if not on then clearNames[name] = true
            elseif group.synthetic then self:addName(name) end
        end
    end
    for _, edit in ipairs(edits) do
        local group = edit.group
        if not edit.on and group.key and self.picker.selectedCats[group.key] then
            self.picker.selectedCats[group.key] = nil
            for _, name in ipairs(group.children) do
                self:addName(name)
                self:affectName(affected, name)
            end
        end
    end
    for _, edit in ipairs(edits) do
        if edit.on and not clearNames[edit.name] and not self:covered(edit.group, edit.name) then
            self:addName(edit.name)
        end
        self:affectName(affected, edit.name)
    end
    for name in pairs(clearNames) do
        self.picker.selectedItems[name], self.introduced[name] = nil, nil
        self:affectName(affected, name)
    end
    self:normalize(affected)
end

function Model:setItem(group, name, on)
    self:applyRows({{kind='item',group=group,key=name}}, on and 'select' or 'clear')
end

function Model:setGroup(group, on)
    self:applyRows({{kind='category',group=group}}, on and 'select' or 'clear')
end

function Model:selectFiltered(matches)
    local rows = {}
    for _, match in ipairs(matches) do
        if match.all then rows[#rows + 1] = { kind='category',group=match.group }
        else
            for _, name in ipairs(match.names) do
                rows[#rows + 1] = {kind='item',group=match.group,key=name}
            end
        end
    end
    self:applyRows(rows, 'select')
end

function Model:clear()
    if self.readOnly then return end
    -- Preserve the table identities captured by the original picker.
    for key in pairs(self.picker.selectedCats) do self.picker.selectedCats[key] = nil end
    for key in pairs(self.picker.selectedItems) do self.picker.selectedItems[key] = nil end
    self.introduced = {}
    self:refresh()
end

function Model:rows(text, checked, contents, expanded, filterExpanded)
    text = string.lower(text or '')
    local rows, matches = {}, {}
    local filtering = text ~= '' or checked or contents ~= nil
    local function match(label) return text == '' or string.find(string.lower(label), text, 1, true) end
    local function isOpen(id)
        if filtering then return not filterExpanded or filterExpanded[id] ~= false end
        return expanded[id] == true
    end
    local function collect(group,parentMatches)
        local categoryMatches=parentMatches or match(group.label)
        local modRows,childNames={},{}
        for _,mod in ipairs(group.mods) do
            local children={}
            local ancestorMatches=categoryMatches or match(mod.label)
            for _,name in ipairs(mod.children) do
                local visible=ancestorMatches or match(name)
                if checked and not self:covered(group,name) then visible=false end
                if contents and not contents[name] then visible=false end
                if visible then children[#children+1]=name;childNames[#childNames+1]=name end
            end
            if #children>0 then modRows[#modRows+1]={mod=mod,children=children} end
        end
        if not self.groupByMod then
            local children={}
            for _,name in ipairs(group.children) do
                local visible=categoryMatches or match(name) or match(group.ownerLabels[name] or '')
                if checked and not self:covered(group,name) then visible=false end
                if contents and not contents[name] then visible=false end
                if visible then children[#children+1]=name;childNames[#childNames+1]=name end
            end
            return children,childNames,#childNames>0 or (#group.children==0 and categoryMatches and not contents and (not checked or group.state~='none'))
        end
        local empty=#group.children==0 and categoryMatches and not contents and (not checked or group.state~='none')
        return modRows,childNames,#childNames>0 or empty
    end
    local function appendMods(group,modRows,depth)
        if not self.groupByMod then
            for _,name in ipairs(modRows) do
                rows[#rows+1]={kind='item',group=group,key=name,id=group.id..'\0'..name,depth=depth}
            end
            return
        end
        for _,entry in ipairs(modRows) do
            local mod=entry.mod;local modOpen=isOpen(mod.id)
            rows[#rows+1]={kind='mod',group=group,mod=mod,id=mod.id,open=modOpen,depth=depth}
            if modOpen then for _,name in ipairs(entry.children) do
                rows[#rows+1]={kind='item',group=group,mod=mod,key=name,id=group.id..'\0'..name,depth=depth+1}
            end end
        end
    end
    local function collectTree(group,ancestorMatches)
        local inherited=ancestorMatches or match(group.label)
        if group.subgroups and #group.subgroups>0 then
            local entries={}
            for _,child in ipairs(group.subgroups) do
                local entry=collectTree(child,inherited)
                if entry then entries[#entries+1]=entry end
            end
            if #entries>0 then return {group=group,entries=entries} end
            if #group.children==0 and inherited and not contents and (not checked or group.state~='none') then
                return {group=group,entries={}}
            end
            return nil
        end
        local mods,names,visible=collect(group,ancestorMatches)
        if not visible then return nil end
        matches[#matches+1]={group=group,names=names,all=#names==#group.children}
        return {group=group,mods=mods}
    end
    local function appendTree(entry,depth)
        local group=entry.group;local open=isOpen(group.id)
        rows[#rows+1]={kind=depth==0 and 'category' or 'subcategory',group=group,key=group.key,id=group.id,open=open,depth=depth}
        if not open then return end
        if entry.entries then for _,child in ipairs(entry.entries) do appendTree(child,depth+1) end
        else appendMods(group,entry.mods,depth+1) end
    end
    for _,root in ipairs(self.displayRoots) do
        local entry=collectTree(root,false)
        if entry then appendTree(entry,0) end
    end
    return rows, matches
end

return Model
