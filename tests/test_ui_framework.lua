-- Host ISUI geometry and contracts; no native rendering proof.
dofile(TEST_ROOT..'/test_shopping_ui.lua')
local Q,U=B47ANCEDQuartermaster,B47ANCEDUI
local t=U.Theme
local original=ISButton.prerender
local b=U.Button:new(0,0,90,28,'long caption',nil,function() end)
local pre=b.prerender;U.skin(b,'button');assert(pre==b.prerender and ISButton.prerender==original,'instance-only idempotent styling')
b.backgroundColor.r=1;assert(t.colors.raised.r~=1,'widget changed theme')
local p=Q.openPicker(CONTAINER_FIXTURE.a,0,0);local u=p.shoppingUI
local function reach(widget) for _,w in ipairs(p.allJoypadButtons) do if w==widget then return true end end return false end
Q.ShoppingUI.switch(p,'shopping');u.neededTab.onclick(p)
u.selected='Base.Nails';u.lists.needed={['Base.Nails']=3};u.lists.neededGoals={['Base.Nails']={current=1,remaining=2,target=3}}
u.rebuild();assert(reach(u.editGoal) and reach(u.removeWish),'selection actions missing from refreshed controller rows')
-- Native frame must not repaint the custom title/status strip; only this instance changes.
assert(p.drawFrame==false,'native frame still overlaps custom header/footer')
for _,key in ipairs({'pinButton','collapseButton','closeButton'}) do
 if not p[key] then p[key]=U.Button:new(0,0,20,20,key);p:addChild(p[key]) end
end
local items=p.selectedItems;items.keep=true
-- Simulate delayed native right/bottom anchoring following parent resize.
local function delayedResize(widget,dx,dy)
 if widget.anchorRight then widget.x=widget.x+dx end
 if widget.anchorBottom then widget.height=widget.height+dy end
end
local function explicitScrollbar(list)
 local bar=list.vscroll
 assert(bar.x==list:getWidth()-17 and bar.width==17 and bar.height==list:getHeight(),'scrollbar geometry drift')
 assert(bar.anchorRight==false and bar.anchorBottom==false,'native anchors can move explicit scrollbar')
 local x,h=bar.x,bar.height;delayedResize(bar,150,75)
 assert(bar.x==x and bar.height==h,'deferred anchoring moved scrollbar')
end
local nativeText=getTextManager
local font=14
getTextManager=function() return {getFontHeight=function() return font end,MeasureStringX=function(_,_,s) return #s*font/2 end} end
for _,size in ipairs({{640,460},{1100,800},{1280,720}}) do
 for _,height in ipairs({14,24,32}) do
  font=height;p:setWidth(size[1]);p:setHeight(size[2]);Q.ShoppingUI.switch(p,'sorting');p:layout()
  explicitScrollbar(p.listbox);explicitScrollbar(p.containerUI.rail)
  assert(p.b47UI.help.x+p.b47UI.help.width<=p.collapseButton.x,'help overlaps collapse')
  assert(p.collapseButton.x+p.collapseButton.width<=p.closeButton.x,'collapse overlaps close')
  assert(p.pinButton.x==p.collapseButton.x,'native pin/collapse swap moved controls')
  assert(p.listbox.anchorRight==false and p.listbox.anchorBottom==false,'tree native anchor conflicts with explicit layout')
  assert(p.listbox.y+p.listbox.height<=p.btnSave.y-7,'tree covered sorting footer')
  assert(p.btnSave.y+p.btnSave.height<=p:getHeight()-8,'Save clipped')
  assert(p.b47UI.modGrouping:isVisible(),'mod grouping preference hidden in Sorting')
  assert(p.btnModeCat.x+p.btnModeCat.width<=p.btnModePreset.x and p.btnModePreset.x+p.btnModePreset.width<=p.b47UI.modGrouping.x,'sorting controls overlap')
  assert(p.b47UI.modGrouping.x+p.b47UI.modGrouping.width<=p:getWidth()-12,'mod grouping preference clipped')
  Q.ShoppingUI.switch(p,'shopping');p:layout()
  assert(not p.b47UI.modGrouping:isVisible(),'sorting preference leaked into Shopping')
  assert(not p.containerUI.rail:isVisible(),'personal view suggests container ownership')
  assert(u.shopping.y+u.shopping.height<=u.collect.y-7,'Shopping table covered actions')
  for _,button in ipairs({u.collect,u.collectRemaining,u.cancel,u.closePersonal}) do
   if button and button:isVisible() then assert(button.y+button.height<=u.status.y-4,'Shopping action/status overlap') end
  end
  assert(u.status.y+u.status.height<=p:getHeight()-4,'status clipped')
  explicitScrollbar(u.shopping);explicitScrollbar(u.wish)
  u.wantedTab.onclick(p);assert(u.wish:isVisible() and not u.shopping:isVisible())
  u.neededTab.onclick(p);assert(u.wish:isVisible() and not u.addWish:isVisible())
  assert(p.selectedItems==items and items.keep,'navigation changed staged Sorting')
 end
end
-- 2160p-like font metrics must drive the rail rows and minimum window size.
local oldScreenWidth,oldScreenHeight=getPlayerScreenWidth,getPlayerScreenHeight
getPlayerScreenWidth=function() return 3840 end
getPlayerScreenHeight=function() return 2160 end
for _,height in ipairs({33,42}) do
 font=height
 local candidate=Q.Picker:new(CONTAINER_FIXTURE.a,0,0,{api=p.api})
 assert(candidate.minimumHeight>=460 and candidate.minimumWidth>=640)
 assert(candidate:getHeight()>=candidate.minimumHeight and candidate:getWidth()>=candidate.minimumWidth)
 p:setWidth(math.max(1120,candidate.minimumWidth));p:setHeight(math.max(780,candidate.minimumHeight))
 Q.ShoppingUI.switch(p,'sorting');p:layout()
 assert(p.containerUI.rail.itemheight>=font+28,'container rail clipped scaled text')
 assert(p.listbox.y+p.listbox.height<=p.btnSave.y-7 and p.btnSave.y+p.btnSave.height<=p:getHeight()-8)
 Q.ShoppingUI.switch(p,'shopping');p:layout()
 assert(u.shopping.y+u.shopping.height<=u.collect.y-7 and u.status.y+u.status.height<=p:getHeight()-4)
end
getPlayerScreenWidth,getPlayerScreenHeight=oldScreenWidth,oldScreenHeight
font=14;p:setWidth(1100);p:setHeight(800);p:layout()
Q.ShoppingUI.switch(p,'sorting')
local groupedBefore=Q.UIOptions.groupByMod()
local selectedBefore=p.selectedItems
p.b47UI.modGrouping.onclick(p)
assert(Q.UIOptions.groupByMod()~=groupedBefore,'visible preference did not toggle')
assert(p.b47UI.modGrouping.title:find(Q.UIOptions.groupByMod() and '[x]' or '[ ]',1,true),'visible preference did not refresh')
assert(p.selectedItems==selectedBefore,'presentation preference changed selections')
p.b47UI.modGrouping.onclick(p)
assert(Q.UIOptions.groupByMod()==groupedBefore,'preference cannot toggle back')
local firstGroup=p.qmss.model.groups[1]
if firstGroup and firstGroup.mods[1] then
 p.qmss.expanded[firstGroup.id]=true;p.qmss.expanded[firstGroup.mods[1].id]=true;p:rebuild()
 local uncovered=false
 for _,entry in ipairs(p.listbox.items) do
  local row=entry.item
  if row.kind=='item' and not p.qmss.model:covered(row.group,row.key) then uncovered=true;break end
 end
 assert(not uncovered or p.btnAll:isVisible(),'Select All hidden with visible unselected items')
end
-- Cached table painting cannot consult gameplay/catalog/network state.
local requests=Q.Authority.request;local scripts=getScriptManager
Q.Authority.request=function() error('request from draw') end
getScriptManager=function() error('catalog from draw') end
local list=U.ScrollList:new(0,0,600,120);list:addItem('example',{cells={'item','1','0','1','need'},role='warning'})
U.Table.prepare(list,{{label='Name',share=.6},{label='Count',share=.4}})
U.Table.draw(list,0,list.items[1]);U.Table.draw(list,5000,list.items[1]);p:prerender()
Q.Authority.request=requests;getScriptManager=scripts;getTextManager=nativeText
p:closePicker()
print('PASS OFFLINE embedded UI: instance isolation, theme immutability, dedicated navigation, visible controller rows, staged-state preservation, 640/1100/1280 geometry at 14/24/32 font heights, cached draw without catalog/network')

-- Deliberate inspection keeps full long text in a scrollable, bounded surface.
local text=string.rep('Long item name ',60)
local inspect=U.Tooltip.inspect(0,text..'\nSecond field',nil);local details
for _,w in pairs(inspect.children) do if w.b47Kind=='list' then details=w end end
assert(details and #details.items==2 and table.concat(details.items[1].item)==text,'inspection discarded long content')
assert(details.items[1].height>details.itemheight and details:getScrollHeight()>0)
inspect:removeFromUIManager()
print('PASS OFFLINE dev27 full-text inspector: wrapped complete contents, bounded panel and scrollable details')

local full='An extremely long button caption with every word retained'
local recover=ISButton:new(0,0,40,28,full,nil,function() end)
recover.render=function() end;U.skin(recover,'button')
recover:render();assert(recover.tooltip==full,'truncated action lost full-title hover')
recover:setTooltip('explicit explanation');recover:render();assert(recover.tooltip=='explicit explanation','fallback replaced semantic explanation')
print('PASS OFFLINE dev27 tooltip fallback preserves full titles and explicit explanations')
