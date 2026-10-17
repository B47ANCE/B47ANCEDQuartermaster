-- Application presentation consumes the embedded, state-free UI framework.
require 'B47ANCEDUI/Controls'
require 'B47ANCEDUI/Dialog'
local Q=B47ANCEDQuartermaster;local U=B47ANCEDUI;local T,R=U.Theme,U.Renderer
local V={};Q.UI=V
local function tr(k) return getText('UI_QMSS_'..k) end
local function at(w,x,y,width,height) U.Layout.place(w,x,y,width,height or T.metrics().button) end
local scrollbar=U.Layout.scrollbar
local function visible(w,value) if w then w:setVisible(value==true);if not value and w.tooltipUI and w.tooltipUI.setVisible then U.Tooltip.hide(w) end end end
local function title(w,text) if w then w:setTitle(text) end end
local function columns(goal)
 return goal and {{label=tr('ColumnItem'),share=.40},{label=tr('ColumnCurrentTarget'),share=.23},{label=tr('ColumnRemaining'),share=.16},{label=tr('ColumnStatus'),share=.21}}
  or {{label=tr('ColumnItem'),share=.34},{label=tr('ColumnRequested'),share=.17},{label=tr('ColumnCredit'),share=.13},{label=tr('ColumnRemaining'),share=.13},{label=tr('ColumnStatus'),share=.23}}
end
local function filterRows(list,query,policy,selected)
 local rows={};local found
 for _,entry in ipairs(list.items) do
  local row=entry.item;local text=string.lower((row.fullType or '')..' '..entry.text)
  if string.find(text,query,1,true) and (not policy or policy==1 or policy==2 and row.remaining and row.remaining>0 or policy==3 and row.remaining==0) then
   rows[#rows+1]=entry;entry.index=#rows;entry.height=list.itemheight
   if row.fullType==selected and selected then found=#rows end
  end
 end
 list.items=rows;list.count=#rows;list.selected=found or math.min(list.selected or 1,math.max(1,#rows));list:setScrollHeight(#rows*list.itemheight)
end
function V.shoppingRows(p)
 local u=p.shoppingUI;local query=string.lower(u.search:getInternalText() or '')
 local requirements={};for _,row in ipairs(u.lists.requirements or {}) do requirements[row.key]=row end
 local goalKind=u.goalKind;local goals=(goalKind=='needed' and u.lists.neededGoals or u.lists.wishGoals) or {}
 for _,entry in ipairs(u.wish.items) do
  local row=entry.item;local goal=goals[row.fullType];local script=getScriptManager():FindItem(row.fullType)
  row.remaining=goal and goal.remaining or row.quantity;row.current=goal and goal.current or 0;row.target=row.quantity
  row.name=script and script:getDisplayName() or row.fullType;row.texture=Q.Picker.itemTexture(row.fullType)
  row.role=row.remaining==0 and 'success' or goalKind=='needed' and 'needed' or 'warning'
  row.cells={row.name,tostring(row.current)..' / '..row.target,tostring(row.remaining),row.remaining==0 and tr('fulfilled') or getText('UI_QMSS_WishNeed',row.remaining)}
  row.sourceLabel=tr(goalKind=='needed' and 'NeededList' or 'WishList')
 end
 -- Preserve independently editable provenance rows; allocation rows are details.
 local rows={}
 for _,entry in ipairs(u.shopping.items) do
  local row=entry.item
  if row.fullType or row.project or row.source or row.requirement then
   local key;local label
   if row.requirement then
    local requirement=row.requirement;local names={}
    for i,t in ipairs(requirement.alternatives or {}) do if i<=3 then local script=getScriptManager():FindItem(t);names[#names+1]=script and script:getDisplayName() or t end end
    row.name=tr('RequirementSource')..': '..table.concat(names,' / ');row.sourceLabel=tr('SharedAllocation');row.fullType=#requirement.alternatives==1 and requirement.alternatives[1] or nil
    row.texture=Q.Picker.itemTexture(row.fullType);row.remaining=requirement.outstanding;row.credit=requirement.carried
    row.cells={row.name,tostring(requirement.gross),tostring(requirement.carried),tostring(requirement.outstanding)};row.detail=tr('SharedCreditExplanation')
   elseif row.project then
    key=row.project.key;label=tr(row.project.origin=='cook' and 'ProjectCookSource' or row.project.kind=='build' and 'BuildingSource' or 'CraftingSource')
    row.name=row.project.recipe;row.sourceLabel=label;row.cells={row.name,tostring(row.project.quantity)..' '..tr('Executions'),'', ''}
    -- Pooled native allocations cannot safely be attributed to an individual
    -- project execution. Expose the actual server allocation rows separately.
    row.cells[3]='—';row.cells[4]='—';row.detail=label..': '..row.project.recipe..' — '..tr('SharedCreditExplanation')
   elseif row.source then
    local source=row.source;row.fullType=source.fullType
    label=tr(source.kind=='needed' and 'Needed' or source.kind=='wanted' and 'Wanted' or 'ExtraDemand')
    row.sourceLabel=label
    if source.kind=='extra' then
     key='extra:'..source.key
     for _,extra in ipairs(u.lists.extras or {}) do if extra.key==source.key then row.fullType=extra.fullType;row.quantity=extra.quantity end end
    else
     key='dibs:'..row.fullType
     local g=(source.kind=='needed' and u.lists.neededGoals or u.lists.wishGoals) or {};local goal=g[row.fullType]
     row.quantity=goal and goal.target or 0
    end
   else key='manual:'..row.fullType;label=tr('ManualSource');row.sourceLabel=label end
   if not row.project and not row.requirement then
    local script=row.fullType and getScriptManager():FindItem(row.fullType)
    row.name=script and script:getDisplayName() or row.fullType or entry.text;row.texture=Q.Picker.itemTexture(row.fullType)
    local requirement=requirements[key];row.remaining=requirement and requirement.outstanding or nil;row.credit=requirement and requirement.carried or nil
    if row.source and row.source.kind~='extra' then
     local g=row.source.kind=='needed' and u.lists.neededGoals or u.lists.wishGoals;local goal=g and g[row.fullType]
     row.remaining=goal and goal.remaining or nil;row.credit=goal and goal.current or nil
    end
    row.cells={row.name,tostring(row.quantity or 0),row.credit and tostring(row.credit) or '—',row.remaining and tostring(row.remaining) or '—'}
    row.detail=(label or '')..'\n'..tr('SharedCreditExplanation')
   end
   row.role=row.remaining==0 and 'success' or row.remaining and 'warning' or 'muted'
   row.cells[5]=row.remaining==0 and tr('fulfilled') or row.remaining and getText('UI_QMSS_WishNeed',row.remaining) or tr('SeeRequirements')
   entry.tooltip=(row.sourceLabel or '')..'\n'..U.Tooltip.plain(row.fullType or row.name);entry.index=#rows+1;rows[#rows+1]=entry
  end
 end
 u.shopping.items=rows;u.shopping.count=#rows
 filterRows(u.wish,query,u.stateFilter.selected,u.selected);filterRows(u.shopping,query,nil,u.selected)
 U.Table.prepare(u.wish,columns(true));U.Table.prepare(u.shopping,columns(false))
 u.wish.doDrawItem=U.Table.draw;u.shopping.doDrawItem=U.Table.draw
 u.selectedDetails=nil
 local list
 -- Explicit branch avoids Lua and/or turning Wanted into a boolean.
 if u.view=='wanted' or u.view=='needed' then list=u.wish else list=u.shopping end
 for _,entry in ipairs(list.items) do
  if u.selectedRequirement and entry.item.requirement and entry.item.requirement.key==u.selectedRequirement.key or u.selectedProject and entry.item.project and entry.item.project.key==u.selectedProject.key or u.selectedSource and entry.item.source and entry.item.source.kind==u.selectedSource.kind and entry.item.source.key==u.selectedSource.key and entry.item.source.fullType==u.selectedSource.fullType
    or not u.selectedSource and not u.selectedProject and not u.selectedRequirement and u.selected and entry.item.fullType==u.selected then u.selectedDetails=entry.item;break end
 end
 p:layout();p:configJoypad()
end
function V.attach(p)
 if p.b47UI then return end
 local m=T.metrics();local u=p.shoppingUI;local v={};p.b47UI=v
 U.skin(p,'window');U.skinChildren(p)
 -- The owned shell paints its header/footer. Keep native drag/resize/collapse
 -- callbacks and widgets, but omit their duplicate frame/title/status paint.
 p.drawFrame=false
 p.titleBarHeight=function() return T.metrics().header end
 local function tab(label,fn) local b=U.TabBar.add(p,tr(label),fn);if u then u.owned[b]=true end;return b end
 v.sorting=tab('Sorting',function() if u then Q.ShoppingUI.switch(p,'sorting') end;p:layout();p:configJoypad() end)
 v.shopping=tab('Shopping',function() Q.ShoppingUI.switch(p,'shopping');p:layout();p:configJoypad() end)
 v.help=tab('Help',function()
  U.Tooltip.inspect(p.playerNum,tr('HelpText')..' <LINE> '..tr('RulesTip')..' <LINE> '..tr('ControlsTip'),p)
 end)
 v.sortSearch=U.SearchField.attach(p,p.filter,tr('SearchItems'));if u then u.owned[v.sortSearch.clear]=true end
 v.sortSearch.clear:setTooltip(tr('ClearSearch'))
 if not u then v.cancel=U.Button:new(0,0,100,m.button,tr('Cancel'),p,function(owner) owner:closePicker() end);v.cancel:initialise();v.cancel:instantiate();p:addChild(v.cancel) end
 if u then
  u.view='shopping';u.shoppingTab=tab('ShoppingList',function() u.view='shopping';u.selected=nil;u.selectedProject=nil;u.selectedSource=nil;u.selectedRequirement=nil;u.rebuild();p:configJoypad() end)
  local function goal(view,original) return function() u.view=view;u.selectedRequirement=nil;original(p);p:layout();p:configJoypad() end end
  u.wantedTab.onclick=goal('wanted',u.wantedTab.onclick);u.neededTab.onclick=goal('needed',u.neededTab.onclick)
  title(u.wantedTab,tr('WishAdd'));title(u.neededTab,tr('NeededAdd'));title(u.preferences,tr('ShoppingSettings'))
  title(u.addWish,tr('AddWantedItem'));title(u.addNeeded,tr('AddNeededItem'))
  u.shoppingSearch=U.SearchField.attach(p,u.search,tr('SearchItems'));u.owned[u.shoppingSearch.clear]=true;u.shoppingSearch.clear:setTooltip(tr('ClearSearch'))
  require 'ISUI/ISComboBox'
  u.stateFilter=ISComboBox:new(0,0,120,m.button,p,function() u.rebuild() end)
  u.stateFilter:initialise();u.stateFilter:instantiate();p:addChild(u.stateFilter);U.Dropdown.style(u.stateFilter);u.owned[u.stateFilter]=true
  for _,key in ipairs({'AllItems','UnfulfilledItems','FulfilledItems'}) do u.stateFilter:addOption(tr(key)) end
  u.details=U.Panel:new(0,0,100,100);u.details:initialise();u.details:instantiate();p:addChild(u.details);u.owned[u.details]=true
  local old=u.details.prerender
  u.details.prerender=function(self)
   if old then old(self) end
   local row=u.selectedDetails
   U.SectionHeader.draw(self,tr('ItemDetails'),12,8)
   if not row then R.text(self,tr('NoSelection'),12,38,T.colors.muted);return end
   R.icon(self,row.texture,12,40,48)
   R.text(self,R.fit(row.name,self:getWidth()-90,T.fonts.section),72,38,T.colors.text,T.fonts.section)
   R.text(self,R.fit(row.sourceLabel or '',self:getWidth()-90),72,62,T.colors.muted)
   if row.target then
    R.text(self,getText('UI_QMSS_GoalDetails',row.current,row.target,row.remaining),72,84,T.colors.text)
    U.Progress.draw(self,72,112,self:getWidth()-90,row.current,row.target,row.role)
   else R.text(self,R.fit(string.gsub(row.detail or row.sourceLabel or '', '\n', ' — '),self:getWidth()-90),72,84,T.colors.muted) end
  end
  u.bulk:setTooltip(tr('BulkAllExplanation'));u.onRebuild=function() V.shoppingRows(p) end
 end
 local layout=p.layout
 p.layout=function(self)
  layout(self);local w,h=self:getWidth(),self:getHeight();local t=T.metrics();local gap=h<520 and 6 or t.gap;v.gap=gap;local statusHeight=t.font+12;local y=t.header+gap
  local personal=u and u.mode=='shopping'
  local rail=self.containerUI;local railWidth=not personal and rail and Q.WindowLayout.railWidth(self) or 0
  local left=railWidth>0 and railWidth+20 or 12;local width=w-left-12
  at(v.sorting,left,y,math.min(160,width/3),t.tab);at(v.shopping,left+math.min(160,width/3)+gap,y,math.min(160,width/3),t.tab)
  visible(v.shopping,u~=nil);visible(v.sorting,true);at(v.help,w-116,6,30,t.header-12)
  if self.b47LayoutButton then at(self.b47LayoutButton,w-154,6,30,t.header-12) end
  at(self.pinButton,w-78,6,30,t.header-12);at(self.collapseButton,w-78,6,30,t.header-12)
  if self.closeButton then at(self.closeButton,w-40,6,30,t.header-12);U.skin(self.closeButton,'button') end
  visible(u and u.toggle,false);U.TabBar.select(v.sorting,not personal);U.TabBar.select(v.shopping,personal)
  local body=y+t.tab+gap
  if not personal then
   if u then
    for _,b in ipairs(u.widgets) do visible(b,false) end
    visible(u.shoppingTab,false);visible(u.stateFilter,false);visible(u.details,false);visible(u.shoppingSearch.clear,false)
   end
   visible(self.filter,true);visible(self.listbox,true)
   at(self.filter,left,body,width,t.button);v.sortSearch:layout()
   local modes=body+t.button+gap
   at(self.btnModeCat,left,modes,width*.70-gap,t.button);at(self.btnModePreset,left+width*.70,modes,width*.30,t.button)
   local filters=modes+t.button+gap
   at(self.chkChecked,left,filters,width*.48,t.button);at(self.chkContents,left+width*.50,filters,width*.50,t.button)
   local priority=filters+t.button+gap
   at(self.priorityLabel,left,priority,120,t.button);at(self.btnPriorityDown,left+126,priority,28,t.button);at(self.btnPriorityUp,left+158,priority,28,t.button);at(self.priorityEntry,left+192,priority,math.min(90,width-192),t.button)
   local tree=priority+t.button+gap;local footer=h-2*(t.button+gap)-statusHeight
   if tree+t.treeRow+gap>footer then
    if rail then
     at(self.chkChecked,12,body+t.button+gap,railWidth-12,t.button)
     at(self.chkContents,12,body+2*(t.button+gap),railWidth-12,t.button)
     priority=filters
     at(self.priorityLabel,left,priority,120,t.button);at(self.btnPriorityDown,left+126,priority,28,t.button);at(self.btnPriorityUp,left+158,priority,28,t.button);at(self.priorityEntry,left+192,priority,math.min(90,width-192),t.button)
    else
     visible(self.priorityLabel,false)
     at(self.chkChecked,left,filters,width*.28,t.button);at(self.chkContents,left+width*.29,filters,width*.28,t.button)
     at(self.btnPriorityDown,left+width*.59,filters,28,t.button);at(self.btnPriorityUp,left+width*.59+32,filters,28,t.button);at(self.priorityEntry,left+width*.59+64,filters,width*.41-64,t.button)
     priority=filters
    end
    tree=priority+t.button+gap
   else visible(self.priorityLabel,true) end
   at(self.listbox,left,tree,width,math.max(t.treeRow,footer-tree-8));self.listbox.itemheight=t.treeRow
   for _,entry in ipairs(self.listbox.items) do entry.height=t.treeRow end;self.listbox:setScrollHeight(#self.listbox.items*t.treeRow);scrollbar(self.listbox)
   local controls={self.btnAll,self.btnClear,self.qmss.bulkButton,self.btnSave};local each=(width-3*gap)/4
   for i,b in ipairs(controls) do at(b,left+(i-1)*(each+gap),footer,each,t.button);U.skin(b,'button',b==self.btnSave and 'primary' or nil);visible(b,true) end
   if Q.updateActionVisibility then Q.updateActionVisibility(self) end
   if rail then
    visible(rail.rail,true);at(rail.rail,12,body+t.button+gap,railWidth-12,math.max(48,h-body-5*t.button-6*gap-statusHeight));scrollbar(rail.rail)
    if tree<filters+2*(t.button+gap) then
     local start=body+3*(t.button+gap);local bottom=h-3*(t.button+gap)-statusHeight-gap
     at(rail.rail,12,start,railWidth-12,math.max(t.row,bottom-start));scrollbar(rail.rail)
    end
    local b=rail.buttons;at(b.containers,12,body,railWidth-12,t.button)
    at(b.whole,12,h-3*(t.button+gap)-statusHeight,railWidth-12,t.button);at(b.apply,12,h-2*(t.button+gap)-statusHeight,railWidth-12,t.button);at(b.refresh,12,h-t.button-statusHeight,railWidth-12,t.button)
    visible(b.whole,#(rail.session.siblings or {})>=2);visible(b.apply,#(rail.session.siblings or {})>=2)
    local row={b.copy,b.paste,b.cancel};local cw=(width-2*gap)/3
    for i,b in ipairs(row) do at(b,left+(i-1)*(cw+gap),h-t.button-statusHeight,cw,t.button);visible(b,true) end
    visible(b.refresh,true);visible(b.containers,true)
   elseif v.cancel then at(v.cancel,left+width*.66,h-t.button-statusHeight,width*.34,t.button);visible(v.cancel,true) end
  else
   -- Personal supply state has no selected-container/Whole Container ownership.
   if rail then visible(rail.rail,false);for _,b in pairs(rail.buttons) do visible(b,false) end end
   visible(self.filter,false);visible(v.sortSearch.clear,false)
   for _,b in ipairs(u.widgets) do visible(b,false) end
   local goal=u.view=='wanted' or u.view=='needed'
   local tabs={u.shoppingTab,u.wantedTab,u.neededTab,u.preferences};local tw=(width-3*gap)/4
   for i,b in ipairs(tabs) do at(b,left+(i-1)*(tw+gap),body,tw,t.tab);visible(b,true) end
   U.TabBar.select(u.shoppingTab,not goal);U.TabBar.select(u.wantedTab,u.view=='wanted');U.TabBar.select(u.neededTab,u.view=='needed')
   local heading=body+t.tab+gap;local search=heading+2*t.font+gap+8
   at(u.search,left,search,width*.48,t.button);visible(u.search,true);u.shoppingSearch:layout()
   at(u.stateFilter,left+width*.49,search,width*.23,t.button);visible(u.stateFilter,goal)
   local add=goal and (u.view=='needed' and u.addNeeded or u.addWish) or u.pickerShopping
   at(add,left+width*.74,search,width*.26,t.button);visible(add,true)
   local top=search+t.button+gap+t.font+8;local footer=h-t.button-statusHeight
   local details=h>=640 and math.min(140,math.floor(h*.20)) or 0
   local actions=footer-t.button-gap;local listBottom=details>0 and actions-details-8 or actions-8
   local list=goal and u.wish or u.shopping
   at(list,left,top,width,math.max(t.row,listBottom-top));list.itemheight=t.row;for _,entry in ipairs(list.items) do entry.height=t.row end
   list:setScrollHeight(#list.items*t.row);visible(list,true);scrollbar(list);U.Table.prepare(list,columns(goal))
   -- Hidden lists retain bounded geometry for stable callbacks and restoration.
   at(goal and u.shopping or u.wish,left,top,width,math.max(t.row,listBottom-top));at(u.catalogList,left,top,width,math.max(t.row,listBottom-top));scrollbar(u.catalogList);scrollbar(goal and u.shopping or u.wish)
   local buttons=goal and {u.removeWish,u.editGoal,u.remaining,u.collectRemaining} or {u.removeShopping,u.addShopping,u.collect,u.cancel}
   local bw=(width-3*gap)/4
   for i,b in ipairs(buttons) do at(b,left+(i-1)*(bw+gap),actions,bw,t.button);visible(b,true) end
   if goal then
    visible(u.removeWish,u.selectedDetails~=nil);visible(u.editGoal,u.selectedDetails~=nil)
    visible(u.remaining,u.selectedDetails~=nil and u.remaining.enable~=false);visible(u.collectRemaining,u.selectedDetails~=nil and u.collectRemaining.enable~=false)
    at(u.bulk,left+width*.50,footer,width*.50,t.button);visible(u.bulk,u.bulk.enable~=false)
   else
    visible(u.removeShopping,u.selectedDetails~=nil and not u.selectedRequirement);visible(u.addShopping,u.selectedDetails~=nil and not u.selectedSource and not u.selectedRequirement)
    at(u.quantity,left,footer,90,t.button);visible(u.quantity,u.selectedDetails~=nil and not u.selectedSource and not u.selectedRequirement)
   end
   at(u.status,left,h-statusHeight+4,width,t.font+4);visible(u.status,true)
   at(u.details,left,listBottom+gap,width,details);visible(u.details,details>0)
   visible(u.wishTitle,false);visible(u.shopTitle,false)
  end
  self.lastWidth,self.lastHeight=w,h;self.b47Font=t.font
  if self.resizeWidget then
   local grip=self.resizeWidgetHeight and self:resizeWidgetHeight() or 16
   at(self.resizeWidget,w-grip,h-grip,grip,grip);self.resizeWidget.anchorRight=false;self.resizeWidget.anchorBottom=false
   if self.resizeWidget2 then at(self.resizeWidget2,0,h-grip,w-grip,grip);self.resizeWidget2.anchorRight=false;self.resizeWidget2.anchorBottom=false end
  end
  if self.b47DividerWidget then at(self.b47DividerWidget,railWidth+12,body,8,math.max(20,h-body-statusHeight-t.button-gap));visible(self.b47DividerWidget,railWidth>0) end
 end
 local pre=p.prerender
 p.prerender=function(self,...)
  R.background(self,0,0,self:getWidth(),self:getHeight(),T.colors.window)
  pre(self,...)
  if self.b47Font~=T.metrics().font then self:layout() end
  -- Header shares the single translucent root backing.
  R.border(self,0,0,self:getWidth(),self:getHeight(),T.colors.strong)
  if self.resizable and not self.isCollapsed and self.resizeimage then
   local grip=self.resizeWidgetHeight and self:resizeWidgetHeight() or 16
   self:drawTextureScaled(self.resizeimage,self:getWidth()-grip+1,self:getHeight()-grip+1,grip-2,grip-2,1,1,1,1)
  end
  local product=self.targetKind=='preset' and self.title or tr('ProductTitle')
  R.text(self,R.fit(product,self:getWidth()-180,T.fonts.title),14,10,T.colors.text,T.fonts.title)
  local personal=u and u.mode=='shopping'
  local left=personal or not self.containerUI and 12 or Q.WindowLayout.railWidth(self)+20
  if personal then left=12 end
  local y=T.metrics().header+T.metrics().tab+2*(v.gap or T.metrics().gap)
  if personal then
   local goal=u.view=='wanted' or u.view=='needed'
   local heading=y+T.metrics().tab+(v.gap or T.metrics().gap)
   local label=goal and tr(u.view=='needed' and 'NeededList' or 'WishList') or tr('ShoppingList')
   U.SectionHeader.draw(self,(u.view=='needed' and '! ' or '')..label,left,heading)
   local summary=goal and u.lists.summaries and u.lists.summaries[u.goalKind]
   local subtitle=summary and getText('UI_QMSS_ListSummary',tr(u.goalKind=='needed' and 'Needed' or 'Wanted'),summary.fulfilled,summary.total,summary.remaining) or tr('PersonalScope')
   R.text(self,R.fit(subtitle,self:getWidth()-left-16),left,heading+T.metrics().font+8,T.colors.muted)
   local list=goal and u.wish or u.shopping
   for _,c in ipairs(list.b47Columns or {}) do R.text(self,c.headerText or c.label,list.x+c.x,list.y-T.metrics().font-6,T.colors.muted) end
  elseif self.containerUI then
   R.text(self,R.fit(self.title,self:getWidth()-left-28),left,self:getHeight()-T.metrics().font-8,T.colors.muted)
  end
  v.sortSearch:layout();if personal then u.shoppingSearch:layout() end
 end
 local joy=p.configJoypad
 p.configJoypad=function(self)
  U.Focus.visibleRows(self,function(owner)
   joy(owner);owner:insertNewLineOfButtons(v.sorting,u and v.shopping or nil,v.help,self.b47LayoutButton)
   if u and u.mode=='shopping' then owner:insertNewLineOfButtons(u.shoppingTab,u.wantedTab,u.neededTab,u.preferences,u.stateFilter,u.shoppingSearch.clear) else owner:insertNewLineOfButtons(v.sortSearch.clear,v.cancel) end
  end)
 end
 Q.WindowLayout.attach(p)
 if u then u.rebuild() else p:layout() end
end
function V.popup(p,label)
 U.skin(p,'window');U.skinChildren(p)
 if type(p.title)=='table' and p.title.setVisible then p.title:setVisible(false) end
 local old=p.prerender
 p.prerender=function(self,...)
  if old then old(self,...) end
  local heading=self.fullType and getText('UI_QMSS_ItemPreferences',self.fullType) or label
  R.text(self,R.fit(heading,self:getWidth()-24,T.fonts.title),12,8,T.colors.text,T.fonts.title)
 end
 U.bounds(p,p.playerNum)
end
function V.itemPicker(p)
 p.b47PickerShell=true
 V.popup(p,tr(p.kind=='needed' and 'AddNeededItem' or (p.kind=='wanted' or p.kind=='wish') and 'AddWantedItem' or p.kind=='override' and 'AddOverride' or 'ShoppingAdd'))
 local search=U.SearchField.attach(p,p.search,tr('SearchItems'));search.clear:setTooltip(tr('ClearSearch'))
 p:insertNewLineOfButtons(search.clear)
 local old=p.prerender
 p.prerender=function(self,...)
  local t=T.metrics();local w,h=self:getWidth(),self:getHeight()
  at(self.search,12,t.header+8,w-24,t.button);search:layout()
  at(self.list,12,self.search.y+t.button+8,w-24,math.max(t.row,h-self.search.y-2*t.button-48));scrollbar(self.list)
  local footer=h-t.button-20
  at(self.quantity,12,footer,math.min(80,w*.22),t.button);at(self.add,w*.28,footer,w*.44-8,t.button);at(self.cancel,w*.72,footer,w*.28-12,t.button)
  if old then old(self,...) end
 end
end
function V.preferences(p)
 if getPlayerScreenWidth then p:setWidth(math.min(p:getWidth(),getPlayerScreenWidth(p.playerNum)-20));p:setHeight(math.min(p:getHeight(),getPlayerScreenHeight(p.playerNum)-20)) end
 V.popup(p,tr('ShoppingPreferences'))
 local refresh=p.refresh
 local function layout(self)
  local t=T.metrics();local w,h=self:getWidth(),self:getHeight();local side=math.min(180,w*.34);local left=side+24;local width=w-left-12
  at(self.global,12,t.header+8,side,t.button);at(self.overrides,12,t.header+t.button+16,side,math.max(t.row,h-t.header-4*t.button-64));scrollbar(self.overrides)
  at(self.addOverride,12,h-3*t.button-44,side,t.button)
  local mini=(side-8)/3
  for i,b in ipairs({self.editOverride,self.removeOverride,self.resetItem}) do at(b,12+(i-1)*(mini+4),h-2*t.button-36,mini,t.button) end
  local index=0;local cols=h<t.header+3*(t.font+t.button+20)+3*t.button+52 and 3 or 2
  for _,k in ipairs({'condition','freshness','cooked','frozen','rotten','uses'}) do
   if self.controls[k]:isVisible() then
    local col=index%cols;local row=math.floor(index/cols);local cell=(width-(cols-1)*8)/cols;local y=t.header+8+row*(t.font+t.button+20)
    at(self.labels[k],left+col*(cell+8),y,cell,t.font+4);at(self.controls[k],left+col*(cell+8),y+t.font+8,cell,t.button);index=index+1
   end
  end
  at(self.confirm,left,h-3*t.button-44,width,t.button);at(self.save,left,h-2*t.button-36,width,t.button)
  at(self.reset,12,h-t.button-16,w*.70-16,t.button);at(self.cancel,w*.70,h-t.button-16,w*.30-12,t.button)
 end
 p.refresh=function(self,...) refresh(self,...);layout(self) end
 p:refresh();U.skin(p.save,'button','primary');U.skin(p.reset,'button','destructive')
end
return V
