require 'B47ANCEDQuartermaster/Authority'
require 'B47ANCEDQuartermaster/ItemCatalog'
require 'B47ANCEDQuartermaster/ShoppingAddUI'
local Q=B47ANCEDQuartermaster
local U={};Q.ShoppingUI=U
local function tr(k) return getText('UI_QMSS_'..k) end
function U.attach(p)
    if p.targetKind~='box' or p.shoppingUI then return end
    local u={mode='sorting',goalKind='wanted',widgets={},owned={},catalog={},lists={shopping={},wish={},needed={},revision=0}}
    p.shoppingUI=u
    local function hideSorting(self)
        for _,c in pairs(self.children) do
            if not u.owned[c] and c~=u.toggle and c~=self.closeButton and c~=self.infoButton and c~=self.pinButton
                and c~=self.collapseButton and c~=self.resizeWidget and c~=self.resizeWidget2 then c:setVisible(false) end
        end
        if not self.b47UI then for _,c in ipairs(u.widgets) do if not c:isVisible() then c:setVisible(true) end end end
    end
    local function add(w) w:initialise();w:instantiate();p:addChild(w);u.widgets[#u.widgets+1]=w;u.owned[w]=true;w:setVisible(false);return w end
    local function button(label,fn) return add(ISButton:new(0,0,100,24,tr(label),p,fn)) end
    -- Dedicated views use the shared Add Item picker; never populate the hidden
    -- legacy catalog on menu opening or periodic possession refresh.
    u.catalog=p.options.uiFramework and {} or Q.ItemCatalog.catalog()
    local nameCount={};for _,item in ipairs(u.catalog) do nameCount[item.name]=(nameCount[item.name] or 0)+1 end
    table.sort(u.catalog,function(a,b) return a.name==b.name and a.fullType<b.fullType or a.name<b.name end)
    u.search=add(ISTextEntryBox:new('',0,0,100,24))
    u.quantity=add(ISTextEntryBox:new('1',0,0,80,24))
    u.quantity:setTooltip(tr('PhysicalQuantity'))
    u.catalogList=add(ISScrollingListBox:new(0,0,200,200));u.catalogList.itemheight=22
    u.shopping=add(ISScrollingListBox:new(0,0,200,100));u.shopping.itemheight=22
    u.wish=add(ISScrollingListBox:new(0,0,200,100));u.wish.itemheight=22
    for _,lb in ipairs({u.catalogList,u.shopping,u.wish}) do
        lb.drawBorder=true;lb.target=p
        lb.doDrawItem=function(list,y,row) list:drawText(row.text,6,y+3,1,1,1,1,UIFont.Small);return y+row.height end
        lb.onmousedown=function(_,item) u.selected=item.fullType;u.selectedProject=item.project;u.selectedSource=item.source;u.selectedRequirement=item.requirement;u.selectedFrom=lb;u.quantity:setText(tostring(item.quantity or 1));if u.rebuild then u.rebuild() end end
        lb.onJoypadDown=function(list,key)
            if key==Joypad.BButton then setJoypadFocus(p.playerNum,p)
            elseif key==Joypad.AButton then
                local row=list.items[list.selected];if row then list.onmousedown(p,row.item) end
            end
        end
    end
    u.status=add(ISLabel:new(0,0,24,'',1,1,1,1,UIFont.Small,true))
    u.shopTitle=add(ISLabel:new(0,0,24,tr('ShoppingList'),1,1,1,1,UIFont.Small,true))
    u.wishTitle=add(ISLabel:new(0,0,24,tr('WishList'),1,1,1,1,UIFont.Small,true))
    local function rebuild()
        local filter=string.lower(u.search:getInternalText() or '')
        if u.lastFilter~=filter then
            u.lastFilter=filter;u.catalogList:clear()
            for _,item in ipairs(u.catalog) do
                if string.find(item.search,filter,1,true) then
                    u.catalogList:addItem(item.name..(nameCount[item.name]>1 and (' ('..item.fullType..')') or ''),item)
                end
            end
        end
        for _,kind in ipairs({'shopping','wish'}) do
            local values=kind=='shopping' and (u.lists.manual or u.lists.shopping) or (u.goalKind=='needed' and u.lists.needed or u.lists.wish)
            values=values or {}
            u[kind]:clear();local names={};for t in pairs(values) do names[#names+1]=t end;table.sort(names)
            for _,t in ipairs(names) do
                local script=getScriptManager():FindItem(t);local name=script and script:getDisplayName() or t
                local n=values[t]
                local goals=u.goalKind=='needed' and u.lists.neededGoals or u.lists.wishGoals
                local goal=kind=='wish' and goals and goals[t]
                local current=goal and goal.current or 0
                local text=kind=='wish' and getText('UI_QMSS_WishCurrentRow',name,current,n,
                    goal and goal.fulfilled and tr('fulfilled') or getText('UI_QMSS_WishNeed',goal and goal.remaining or n)) or getText('UI_QMSS_ManualRow',name,n)
                u[kind]:addItem(text,{fullType=t,quantity=n})
            end
        end
        for _,project in ipairs(u.lists.projects or {}) do
            local provenance=project.origin=='cook' and 'ProjectCookSource' or project.kind=='build' and 'BuildingSource' or 'CraftingSource'
            u.shopping:addItem(getText('UI_QMSS_ProjectRow',tr(provenance)..': '..project.recipe,project.quantity),{project=project,quantity=project.quantity})
        end
        for t,n in pairs(u.lists.neededDemand or {}) do
            local script=getScriptManager():FindItem(t)
            u.shopping:addItem(getText('UI_QMSS_NeededDemandRow',script and script:getDisplayName() or t,n),{source={kind='needed',fullType=t}})
        end
        for t,n in pairs(u.lists.wishDemand or {}) do
            local script=getScriptManager():FindItem(t)
            u.shopping:addItem(getText('UI_QMSS_WishDemandRow',script and script:getDisplayName() or t,n),{source={kind='wanted',fullType=t}})
        end
        for _,extra in ipairs(u.lists.extras or {}) do
            u.shopping:addItem(getText('UI_QMSS_ExtraRow',extra.fullType,extra.quantity,tr(extra.source=='needed' and 'Needed' or 'Wanted')),{source={kind='extra',key=extra.key}})
        end
        local summary=u.lists.summaries and u.lists.summaries[u.goalKind]
        if summary then
            u.wishTitle:setName(getText('UI_QMSS_ListSummary',tr(u.goalKind=='needed' and 'Needed' or 'Wanted'),summary.fulfilled,summary.total,summary.remaining))
            u.wishTitle:setTooltip(tr(u.goalKind=='needed' and 'NeededList' or 'WishList'))
        end
        for _,row in ipairs(u.lists.requirements or {}) do
            local names={}
            for i,t in ipairs(row.alternatives) do
                if i<=3 then local script=getScriptManager():FindItem(t);names[#names+1]=script and script:getDisplayName() or t end
            end
            if #row.alternatives>3 then names[#names+1]=getText('UI_QMSS_MoreAlternatives',#row.alternatives-3) end
            local label=table.concat(names,' / ')..(row.reusable and (' '..tr('Reusable')) or '')
            if row.class then label=label..' ('..tr('Requirement_'..row.class)..')' end
            u.shopping:addItem(getText('UI_QMSS_RequirementRow',label,row.gross,row.carried,row.outstanding),{requirement=row})
        end
        if u.lists.gross then
            local totals=getText('UI_QMSS_ShoppingTotals',u.lists.gross,u.lists.carried,u.lists.outstanding,u.lists.collected or 0)
            local result=u.collectionResult
            if result=='done' and (u.lists.outstanding or 0)>0 then result='NoSources' end
            if Q.Collector and Q.Collector.active[p.playerNum] then u.status:setName(tr('Collecting'))
            elseif result then u.status:setName(getText('UI_QMSS_CollectionResult',tr(result),u.lists.outstanding or 0))
            else u.status:setName(totals) end
            u.status:setTooltip(totals)
        end
        u.cancel:setEnable(Q.Collector and Q.Collector.active[p.playerNum]~=nil or false)
        u.collect:setEnable(not u.lists.shoppingBlocked and (u.lists.outstanding or #u.shopping.items)>0 and not (Q.Collector and Q.Collector.active[p.playerNum]))
        if u.lists.shoppingBlocked then u.status:setName(tr(u.lists.shoppingBlocked)) end
        local editing=u.selectedFrom==u.shopping and (u.selectedProject or u.selected and (u.lists.manual or {})[u.selected])
        u.addShopping:setTitle(tr(editing and 'SetQuantity' or 'ShoppingAdd'))
        u.addShopping:setEnable(not u.selectedSource and (u.selected~=nil or u.selectedProject~=nil))
        u.removeShopping:setEnable(u.selectedFrom==u.shopping and (u.selectedSource~=nil or editing~=nil and editing~=false))
        local goals=u.goalKind=='needed' and u.lists.neededGoals or u.lists.wishGoals
        local goal=u.selected and goals and goals[u.selected]
        u.removeWish:setTitle(tr(u.goalKind=='needed' and 'NeededRemove' or 'WishRemove'))
        u.removeWish:setEnable(goal~=nil);u.editGoal:setEnable(goal~=nil)
        local enabled=goal and goal.remaining>0 and not (Q.Collector and Q.Collector.active[p.playerNum]) or false
        u.remaining:setEnable(enabled);u.collectRemaining:setEnable(enabled)
        u.bulk:setEnable(summary and summary.remaining>0 and not (Q.Collector and Q.Collector.active[p.playerNum]) or false)
        if u.onRebuild then u.onRebuild() end
    end
    local function refresh()
        u.refreshInFlight=(u.refreshInFlight or 0)+1
        u.refreshSerial=(u.refreshSerial or 0)+1;local serial=u.refreshSerial
        Q.Authority.request(p.playerNum,'personalList',{},function(result)
            u.refreshInFlight=math.max(0,(u.refreshInFlight or 1)-1)
            if p.removed then return end
            if serial<(u.appliedRefresh or 0) then return end
            u.appliedRefresh=serial
            if result.status=='ok' then
                if result.revision>=u.lists.revision then u.lists=result;rebuild() end
            else u.status:setName(tr(result.status)) end
        end)
    end
    local function change(kind,remove,quantity)
        u.collectionResult=nil
        if kind=='wish' then kind=u.goalKind=='needed' and 'needed' or 'wanted' end
        if kind=='shopping' and remove and u.selectedSource then
            local args={revision=u.lists.revision};for k,v in pairs(u.selectedSource) do args[k]=v end
            Q.Authority.request(p.playerNum,'shoppingSourceRemove',args,function(result)
                if p.removed then return end
                if result.status=='ok' then u.lists=result;rebuild()
                else u.collectionResult=result.status;u.status:setName(tr(result.status));refresh() end
            end);return
        end
        if kind=='shopping' and not remove and u.selectedFrom~=u.shopping and u.selected then
            Q.ShoppingAddUI.send(p.playerNum,{kind='shopping',fullType=u.selected,quantity=tonumber(u.quantity:getInternalText())},function(result)
                if result.status=='ok' then u.lists=result;rebuild() else u.status:setName(tr(result.status)) end
            end,p);return
        end
        if kind=='shopping' and u.selectedProject then
            local project=u.selectedProject
            Q.Authority.request(p.playerNum,'personalProject',{kind=project.kind,recipe=project.recipe,
                quantity=remove and 0 or tonumber(u.quantity:getInternalText()),revision=u.lists.revision,intent=project.intent,origin=project.origin},function(result)
                if p.removed then return end
                if result.status=='ok' then u.lists=result;rebuild() else u.status:setName(tr(result.status));refresh() end
            end)
            return
        end
        if not u.selected then return end
        local n=remove and 0 or quantity or tonumber(u.quantity:getInternalText())
        Q.Authority.request(p.playerNum,'personalChange',{kind=kind,fullType=u.selected,quantity=n,revision=u.lists.revision},function(result)
            if p.removed then return end
            if result.status=='ok' then u.lists=result;rebuild() else u.collectionResult=result.status;u.status:setName(tr(result.status));refresh() end
        end)
    end
    local function picker(kind)
        require 'B47ANCEDQuartermaster/ItemPicker'
        Q.ItemPicker.open(p.playerNum,kind,function(result) if not p.removed then u.lists=result;rebuild() end end,p)
    end
    u.pickerShopping=button('AddItem',function() picker('shopping') end)
    u.addShopping=button('ShoppingAdd',function() change('shopping') end)
    u.addWish=button('WishAdd',function() picker('wanted') end)
    u.pickerWish=u.addWish -- legacy UI reference, one actual Wanted control
    u.addNeeded=button('NeededAdd',function() picker('needed') end)
    u.removeShopping=button('ShoppingRemove',function() change('shopping',true) end)
    u.removeWish=button('WishRemove',function() change('wish',true) end)
    local function bridge(collect)
        local goals=u.goalKind=='needed' and u.lists.neededGoals or u.lists.wishGoals
        if not u.selected or not (goals and goals[u.selected]) then return end
        local t=u.selected
        local function complete(result)
            if p.removed then return end
            if result.status~='ok' then u.status:setName(tr(result.status));refresh();return end
            u.lists=result;rebuild()
            if collect then
                require 'B47ANCEDQuartermaster/Collector'
                u.collectionResult=nil
                if Q.Collector.start(p.playerNum,function(status) if not p.removed then u.collectionResult=status;refresh() end end,
                    function() if not p.removed then refresh() end end,t,u.goalKind=='needed' and 'needed' or 'wish') and Q.Collector.active[p.playerNum] then
                    u.status:setName(tr('Collecting'));u.collect:setEnable(false);u.remaining:setEnable(false)
                    u.collectRemaining:setEnable(false);u.cancel:setEnable(true)
                end
            end
        end
        local linked=u.goalKind=='needed' and u.lists.neededDemand or u.lists.wishDemand
        if collect and linked and linked[t]~=nil then complete(u.lists)
        else Q.ShoppingAddUI.send(p.playerNum,{kind=u.goalKind,fullType=t},complete,p) end
    end
    u.remaining=button('AddRemaining',function() bridge(false) end)
    u.collectRemaining=button('CollectRemaining',function() bridge(true) end)
    u.collect=button('CollectItems',function()
        require 'B47ANCEDQuartermaster/Collector'
        u.collectionResult=nil
        if Q.Collector.start(p.playerNum,function(status) if not p.removed then u.collectionResult=status;refresh() end end,
            function() if not p.removed then refresh() end end) and Q.Collector.active[p.playerNum] then
            u.status:setName(tr('Collecting'));u.collect:setEnable(false);u.cancel:setEnable(true)
        end
    end)
    u.cancel=button('Cancel',function() if Q.Collector then Q.Collector.cancel(p.playerNum) end;refresh() end)
    u.bulk=button('BulkDibsAdd',function()
        Q.ShoppingAddUI.send(p.playerNum,{kind=u.goalKind,bulk=true},function(result)
            if result.status=='ok' then u.lists=result;rebuild() else u.status:setName(tr(result.status)) end
        end,p)
    end)
    u.editGoal=button('SetTarget',function()
        local goals=u.goalKind=='needed' and u.lists.neededGoals or u.lists.wishGoals
        local goal=u.selected and goals and goals[u.selected]
        if not goal then return end
        local selected,kind=u.selected,u.goalKind
        local dialog=ISTextBox:new(0,0,360,180,tr('SetTarget'),tostring(goal.target),nil,function(_,b)
            if b.internal~='OK' or p.removed or u.selected~=selected or u.goalKind~=kind then return end
            local n=tonumber(b.parent.entry:getInternalText())
            if not n or n~=math.floor(n) or n<1 or n>1000000 then
                u.collectionResult='invalid';u.status:setName(tr('invalid'));return
            end
            change('wish',false,n)
        end,p.playerNum)
        dialog:initialise();dialog:addToUIManager();B47ANCEDUI.Dialog.decorate(dialog,p.playerNum,p)
        setJoypadFocus(p.playerNum,dialog)
    end)
    local function goalKind(kind) u.goalKind=kind;u.selected=nil;u.selectedProject=nil;u.selectedSource=nil;rebuild();p:configJoypad() end
    u.wantedTab=button('Wanted',function() goalKind('wanted') end)
    u.neededTab=button('Needed',function() goalKind('needed') end)
    u.preferences=button('PreferencesShort',function()
        require 'B47ANCEDQuartermaster/PreferencesUI'
        Q.PreferencesUI.open(p.playerNum,function(result) if result.status=='ok' then u.lists=result;rebuild() end end,p)
    end)
    u.search.onTextChangeFunction=rebuild
    -- Shopping's current carried credit may change without a transfer here.
    -- One authoritative snapshot also refreshes current-inventory Wish goals.
    local update=p.update
    p.update=function(self,...)
        if update then update(self,...) end
        local now=getTimestampMs()
        if u.mode=='shopping' and (u.refreshInFlight or 0)==0 and now>=(u.creditRefresh or 0) then u.creditRefresh=now+1000;refresh() end
    end
    local toggle=ISButton:new(0,0,26,24,'',p,function() U.switch(p,u.mode=='sorting' and 'shopping' or 'sorting') end)
    toggle:initialise();toggle:instantiate();p:addChild(toggle);u.toggle=toggle
    toggle:setTooltip(tr('Shopping'))
    -- Original geometric icons; no asset dependency or third-party artwork.
    local render=toggle.prerender
    toggle.prerender=function(self)
        render(self)
        if u.mode=='sorting' then
            self:drawRect(3,5,3,2,1,0.85,0.85,0.7);self:drawRectBorder(7,7,14,10,1,0.85,0.85,0.7)
            self:drawRect(8,19,3,3,1,0.85,0.85,0.7);self:drawRect(18,19,3,3,1,0.85,0.85,0.7)
        else
            self:drawRectBorder(5,5,17,16,1,0.85,0.75,0.5)
            self:drawRect(7,9,13,2,1,0.85,0.75,0.5);self:drawRect(7,16,13,2,1,0.85,0.75,0.5)
        end
    end
    local layout=p.layout
    p.layout=function(self)
        layout(self)
        local w,h=self:getWidth(),self:getHeight()
        toggle:setX(w-64);toggle:setY(3)
        local function at(c,x,y,width,height) c:setX(x);c:setY(y);c:setWidth(width);c:setHeight(height or 24) end
        local half=math.floor((w-36)/2)
        at(u.search,10,34,half);at(u.quantity,10,h-110,80)
        at(u.catalogList,10,64,half,h-240)
        local listHeight=math.floor((h-282)/2)
        at(u.shopTitle,half+22,34,half-80);at(u.pickerShopping,w-88,34,78);at(u.shopping,half+22,64,half,listHeight)
        local wishY=78+listHeight
        at(u.neededTab,half+22,wishY,half/2-2);at(u.wantedTab,half+24+half/2,wishY,half/2-2)
        at(u.wishTitle,half+22,wishY+26,half)
        at(u.wish,half+22,wishY+52,half,listHeight-24)
        at(u.addShopping,96,h-110,half-86);at(u.addWish,10,h-80,half)
        at(u.removeShopping,half+22,h-110,half/2-2);at(u.bulk,half+24+half/2,h-110,half/2-2)
        at(u.addWish,10,h-80,half/2-2);at(u.addNeeded,12+half/2,h-80,half/2-2)
        at(u.editGoal,half+22,h-80,half/2-2);at(u.removeWish,half+24+half/2,h-80,half/2-2)
        at(u.preferences,w-124,3,56)
        at(u.collect,10,h-46,half);at(u.cancel,half+22,h-46,half)
        at(u.status,10,h-166,w-20)
        at(u.remaining,10,h-140,half);at(u.collectRemaining,half+22,h-140,half)
        if u.mode=='shopping' then
            hideSorting(self)
        end
    end
    local close=p.closePicker
    p.closePicker=function(self) if Q.Collector then Q.Collector.cancel(self.playerNum) end;close(self) end;p.close=p.closePicker
    local prerender=p.prerender
    p.prerender=function(self)
        if u.mode=='shopping' then
            hideSorting(self)
        end
        prerender(self)
    end
    local joy=p.configJoypad
    p.configJoypad=function(self)
        if u.mode=='sorting' then joy(self);self:insertNewLineOfButtons(toggle);return end
        self.joypadButtonsY={};self.allJoypadButtons={};self.joypadButtons={};self.joypadIndexY=1;self.joypadIndex=1
        self:insertNewLineOfButtons(toggle,u.search,u.quantity)
        self:insertNewLineOfButtons(u.catalogList,u.addShopping,u.addWish,u.addNeeded,u.preferences)
        self:insertNewLineOfButtons(u.shopping,u.pickerShopping,u.removeShopping)
        self:insertNewLineOfButtons(u.neededTab,u.wantedTab,u.wish,u.editGoal,u.removeWish,u.bulk)
        self:insertNewLineOfButtons(u.remaining,u.collectRemaining)
        self:insertNewLineOfButtons(u.collect,u.cancel)
    end
    local key=p.onKeyPress
    p.onKeyPress=function(self,...) if u.mode=='sorting' and key then return key(self,...) end end
    local consumed=p.isKeyConsumed
    p.isKeyConsumed=function(self,...) if u.mode=='shopping' then return false end;if consumed then return consumed(self,...) end end
    u.refresh=refresh;u.rebuild=rebuild
    p:layout()
end
function U.switch(p,mode)
    -- Personal Shopping has its own authoritative snapshot. It remains usable
    -- while physical-container discovery is still in flight on the first open.
    local u=p.shoppingUI;if not u or p.dimmer:isVisible() then return end
    if mode==u.mode then return end
    if mode=='shopping' then
        if p.worldHighlight then p.worldHighlight:setEnabled(false) end
        u.visible={};for _,c in pairs(p.children) do u.visible[c]=c:isVisible() end
        u.mode=mode;u.toggle:setTooltip(tr('Sorting'));p:layout();u.refresh()
    else
        u.mode='sorting'
        for _,c in ipairs(u.widgets) do c:setVisible(false) end
        for c,visible in pairs(u.visible or {}) do c:setVisible(visible) end
        u.toggle:setTooltip(tr('Shopping'));p:layout()
        if p.worldHighlight then p.worldHighlight:setEnabled(true,p.qmsSession and p.qmsSession.selected and p.qmsSession.selected.target) end
    end
    p:configJoypad()
end
return U
