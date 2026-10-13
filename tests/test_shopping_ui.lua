dofile(TEST_ROOT..'/test_container_ui.lua')
local Q=B47ANCEDQuartermaster
local f=CONTAINER_FIXTURE
function f.player:getModData() self.md=self.md or {};return self.md end
function ISLabel:setName(value) self.name=value end
local manager=getScriptManager()
manager.FindItem=function(_,t) return {getDisplayName=function() return t end} end
getScriptManager=function() return manager end
local p=Q.openPicker(f.a,0,0)
local u=p.shoppingUI;assert(u and u.mode=='sorting')
p.closeButton=ISButton:new(0,0,20,20,'',p,function() end);p:addChild(p.closeButton)
p.resizeWidget=ISPanel:new(0,0,16,16);p:addChild(p.resizeWidget)
local initial=p.selectedItems;initial.TEST=true
local width,height=p:getWidth(),p:getHeight()
Q.ShoppingUI.switch(p,'shopping')
assert(u.mode=='shopping' and not p.listbox:isVisible() and u.shopping:isVisible())
assert(p.closeButton:isVisible() and p.resizeWidget:isVisible(),'mode hid native window controls')
assert(u.toggle.tooltip==getText('UI_QMSS_Sorting'))
assert(not u.collect.enable,'empty Shopping enabled collection')
p:layout();assert(u.collect.y+u.collect.height<=p:getHeight()-10,'Shopping footer clipped')
assert(u.wish.y+u.wish.height<u.status.y and u.catalogList.y+u.catalogList.height<u.status.y,'lists overlap footer status')
for _,size in ipairs({{640,460},{1100,800}}) do
    p:setWidth(size[1]);p:setHeight(size[2]);p:layout()
    assert(u.wish.y+u.wish.height<u.status.y and u.catalogList.y+u.catalogList.height<u.status.y)
    assert(u.collect.y+u.collect.height<=p:getHeight()-10)
end
p:setWidth(width);p:setHeight(height);p:layout()
ctrlDown=true;p:onKeyPress(Keyboard.KEY_A);ctrlDown=false
assert(p.selectedItems==initial and initial.TEST,'hidden sorting modified by Shopping hotkey')
assert(p:getWidth()==width and p:getHeight()==height,'mode switch resized main window')
Q.ShoppingUI.switch(p,'sorting')
assert(u.mode=='sorting' and p.listbox:isVisible() and not u.shopping:isVisible())
assert(p.selectedItems==initial and initial.TEST and u.toggle.tooltip==getText('UI_QMSS_Shopping'))
-- Async snapshots must not expose hidden sorting controls while Shopping active.
Q.ShoppingUI.switch(p,'shopping');p.listbox:setVisible(true);p:prerender();assert(not p.listbox:isVisible())
Q.ShoppingUI.switch(p,'sorting')
local D=Q.DibsUI
local wanted,needed,clear=D.options({{state='none'},{state='wanted'}});assert(wanted and needed and clear)
wanted,needed,clear=D.options({{state='wanted'},{state='wanted'}});assert(not wanted and needed and clear)
wanted,needed,clear=D.options({{state='needed'}});assert(wanted and not needed and clear)
wanted,needed,clear=D.options({{state='none'}});assert(wanted and needed and not clear)
-- Same pooled context can be reused, and the owned entry stays at the bottom.
local control=require 'B47ANCEDQuartermaster/ConfigureControls'
local context=ISContextMenu.get();context.prerender=function() end
control.fill(0,context,{f.a},false)
context:addOption('other-mod-action');context:prerender()
assert(context.options[#context.options].b47OpenMenu and context.options[1].name=='other-mod-action')
context.options={};control.fill(0,context,{f.a},false);assert(#context.options==1,'pooled context lost navigation')
-- Actual ISUI stores children by sparse element ID, not dense array position.
local sparse={};for i,child in ipairs(p.children) do sparse[1000+i*7]=child end;p.children=sparse
Q.ShoppingUI.switch(p,'shopping');assert(not p.listbox:isVisible() and p.closeButton:isVisible())
local setVisible=u.search.setVisible
u.search.setVisible=function(self,on) if not on then self.focused=false end;setVisible(self,on) end
u.search.focused=true;p:prerender();assert(u.search.focused,'Shopping render hid its own active text entry')
local function reachable(widget)
 for _,child in ipairs(p.allJoypadButtons) do if child==widget then return true end end
 return false
end
assert(reachable(u.pickerShopping) and not reachable(u.pickerWish),'Shopping controller visibility')
u.wantedTab.onclick(p)
assert(reachable(u.addWish) and not reachable(u.pickerShopping),'Wanted controller Add Item')
u.neededTab.onclick(p)
assert(reachable(u.addNeeded) and not reachable(u.addWish),'Needed controller Add Item')
Q.ShoppingUI.switch(p,'sorting');assert(p.listbox:isVisible() and p.closeButton:isVisible())
p:closePicker()
print('PASS OFFLINE Shopping UI: same-window mode, staged sorting preserved, footer bounds, hidden hotkey guard, Dibs menus and bottom pooled-context entry')

-- Needed presentation supersedes own Wanted without reordering Wanted callers.
local rows={{state='wanted',details={wanted={{label='first',order=1},{label='second',order=2}},needed={{label='other player'}}}}}
local label,lines,priority=D.presentation(rows)
assert(priority=='needed' and label:find('[!]',1,true))
assert(lines[1]:find('other player',1,true) and lines[2]:find('first',1,true) and lines[3]:find('second',1,true))
assert(rows[1].details.wanted[1].order==1 and rows[1].details.wanted[2].order==2)
assert(select(3,D.presentation({{details={wanted={{label='one'}},needed={}}}}))=='wanted')
assert(select(3,D.presentation({{details={wanted={},needed={}}}}))=='none')
assert(select(3,D.presentation({rows[1],{details={wanted={},needed={}}}}))=='needed')
local nativeCalls,badges=0,{}
ISInventoryItem={renderItemIcon=function() nativeCalls=nativeCalls+1;return 'native-result' end}
D.installIconHook();D.installIconHook()
local panel={drawRect=function() end,drawRectBorder=function() end,drawText=function(_,text) badges[#badges+1]=text end}
local item={getModData=function() return {B47Dibs={schema=1,serial=1,players={a={state='wanted',order=1,label='own'},b={state='needed',label='other'}}}} end}
assert(ISInventoryItem.renderItemIcon(panel,item,0,0,1,32,32)=='native-result')
assert(nativeCalls==1 and badges[1]=='!')
item.getModData=function() return {B47Dibs={schema=1,serial=1,players={a={state='wanted',order=1,label='own'}}}} end
ISInventoryItem.renderItemIcon(panel,item,0,0);assert(badges[2]==getText('UI_QMSS_WantedBadge'))
item.getModData=function() return {} end
ISInventoryItem.renderItemIcon(panel,item,0,0);assert(#badges==2 and nativeCalls==3)
print('PASS OFFLINE Needed-first Dibs: other-player priority, details order, mixed selection, non-color icon badges, native renderer preserved')

-- A Needed target created after opening must not be described as Wanted.
local initialise=ISPanelJoypad.initialise;ISPanelJoypad.initialise=function(self) initialise(self);self.joypadButtonsY={};self.allJoypadButtons={};self.joypadButtons={} end
local Picker=require 'B47ANCEDQuartermaster/ItemPicker';local request=Q.Authority.request;local lists=0
Q.Authority.request=function(_,command,args,done) assert(command=='personalList');lists=lists+1;done({status='ok',revision=1,wish={},needed=lists>1 and {['Fixture.RoundA']=2} or {}}) end
local picker=Picker.open(0,'needed',nil,nil);picker.selectedType='Fixture.RoundA';picker.quantity:setText('2');picker:submit()
assert(picker.add.tooltip==getText('UI_QMSS_NeededExists') and picker.add.enable==false,'Needed race explained as Wanted')
picker:close();Q.Authority.request=request;ISPanelJoypad.initialise=initialise
print('PASS OFFLINE dev27 Needed duplicate race preserves correct list explanation')

-- One heavily reserved item uses a bounded preview and deliberate full inspection.
ISInventoryPane=ISInventoryPane or {}
local request=Q.Authority.request;local tips=ISToolTip;local actual=ISInventoryPane.getActualItems
local addTip=ISWorldObjectContextMenu.addToolTip
ISToolTip={new=function() return {backgroundColor={a=1},initialise=function() end,setVisible=function() end,render=function() end} end}
ISInventoryPane.getActualItems=function(items) return items end;ISWorldObjectContextMenu.addToolTip=function() error('legacy uncapped tooltip') end
local participants={};for i=1,12 do participants[i]={label='participant'..i..'<IMAGE:bad>'} end
Q.Authority.request=function(_,command,args,done) assert(command=='dibsInspect');done({status='ok',token='fixture',rows={{state='none',details={needed=participants,wanted={}}}}}) end
local context=ISContextMenu.get();Q.DibsUI.fill(0,context,{{getID=function() return 1 end}})
local option=context.options[1];assert(option and option.toolTip)
local description=option.toolTip.description
assert(description:find('UI_QMSS_DibsMore',1,true) and not description:find('participant7',1,true) and not description:find('<IMAGE',1,true),'Dibs preview was uncapped or interpreted player markup')
Q.Authority.request=request;ISToolTip=tips;ISInventoryPane.getActualItems=actual;ISWorldObjectContextMenu.addToolTip=addTip
print('PASS OFFLINE dev27 Dibs preview: capped participants, explicit full-inspection option and plain-text names')
