-- Execute the owned standalone Picker against a minimal host ISUI surface.
-- This tests callback binding/delegation, not native rendering or networking.
local Widget = {}
Widget.__index = Widget
function Widget:derive(name)
    local c = { Type = name }; c.__index = c
    return setmetatable(c, {__index=self})
end
function Widget:new(x,y,w,h)
    return setmetatable({x=x,y=y,width=w,height=h,children={},items={},itemheight=22,
        selected=1,count=0,scroll=0,scrollHeight=0,visible=true,
        backgroundColor={r=0,g=0,b=0,a=1},vscroll={x=-6,width=17,height=10,
            setAnchorsTBLR=function(s,t,b,l,r) s.anchorTop,s.anchorBottom,s.anchorLeft,s.anchorRight=t,b,l,r end,
            getWidth=function(s) return s.width end, getHeight=function(s) return s.height end,
            setX=function(s,v) s.x=v end, setY=function(s,v) s.y=v end,
            setHeight=function(s,v) s.height=v end,setWidth=function(s,v) s.width=v end}}, self)
end
function Widget:initialise() end
function Widget:isVisible() return self.visible end
function Widget:isFocused() return self.focused or false end
function Widget:setWantKeyEvents(on) self.wantKeyEvents=on end
function Widget:removeChild(child)
    for i,v in ipairs(self.children) do if v==child then table.remove(self.children,i); break end end
end
function Widget:instantiate() end
function Widget:addChild(child) self.children[#self.children+1]=child; child.parent=self end
function Widget:addToUIManager() if not self.created and self.createChildren then self.created=true; self:createChildren() end end
function Widget:removeFromUIManager() self.removed=true end
function Widget:createChildren() end
function Widget:prerender() end
function Widget:close() self.closed=true end
function Widget:getWidth() return self.width end
function Widget:getHeight() return self.height end
function Widget:setAnchorsTBLR(t,b,l,r) self.anchorTop,self.anchorBottom,self.anchorLeft,self.anchorRight=t,b,l,r end
function Widget:setWidth(v) self.width=v end
function Widget:setHeight(v) self.height=v end
function Widget:setX(v) self.x=v end
function Widget:setY(v) self.y=v end
function Widget:getAbsoluteX() return self.x end
function Widget:getAbsoluteY() return self.y end
function Widget:titleBarHeight() return 20 end
function Widget:setVisible(v) self.visible=v end
function Widget:setTitle(v) self.title=v end
function Widget:setEnable(v) self.enable=v end
function Widget:setTooltip(v) self.tooltip=v end
function Widget:setText(v) self.text=v end
function Widget:getInternalText() return self.text or '' end
function Widget:setMaxTextLength(v) end
function Widget:clear() self.items={}; self.count=0; self.selected=1 end
function Widget:addItem(text,data)
    local row={text=text,item=data,height=self.itemheight,index=#self.items+1}
    table.insert(self.items,row); self.count=#self.items
    self.scrollHeight=self.scrollHeight+self.itemheight
    return row
end
function Widget:getYScroll() return self.scroll end
function Widget:setYScroll(v) self.scroll=v end
function Widget:getScrollHeight() return self.scrollHeight end
function Widget:setScrollHeight(v) self.scrollHeight=v end
function Widget:isVScrollBarVisible() return self.scrollHeight>self.height end
function Widget:rowAt(x,y) local n=math.floor(y/self.itemheight)+1; return self.items[n] and n or -1 end
function Widget:onMouseDown(x,y)
    self.selected=self:rowAt(x,y)
    if self.items[self.selected] then self.onmousedown(self.target,self.items[self.selected].item) end
end
function Widget:prevVisibleIndex(n) return math.max(1,n-1) end
function Widget:nextVisibleIndex(n) return math.min(#self.items,n+1) end
function Widget:ensureVisible(n) end
function Widget:isMouseOver() return false end
function Widget:drawRect(...) end
function Widget:drawRectBorder(...) end
function Widget:drawTextureScaled(...) end
function Widget:drawText(...) end
function Widget:drawTextRight(...) end
function Widget:clearISButtons() end
function Widget:clearJoypadFocus() end
function Widget:restoreJoypadFocus() end
function Widget:getMinVisibleRow() return 1 end
function Widget:insertNewLineOfButtons(...)
    local row={...}; self.joypadButtonsY[#self.joypadButtonsY+1]=row
    for _,button in ipairs(row) do table.insert(self.allJoypadButtons,button) end
end
function Widget:onJoypadDown() end
function Widget:onGainJoypadFocus() end
ISCollapsableWindow=Widget:derive('Window')
ISCollapsableWindowJoypad=ISCollapsableWindow:derive('JoypadWindow')
ISPanelJoypad=Widget:derive('PanelJoypad')
ISPanel=Widget:derive('Panel')
ISScrollingListBox=Widget:derive('List')
ISButton=Widget:derive('Button')
function ISButton:new(x,y,w,h,title,target,onclick)
    local b=Widget.new(self,x,y,w,h); b.title,b.target,b.onclick=title,target,onclick; return b
end
ISTextEntryBox=Widget:derive('Entry')
function ISTextEntryBox:new(text,x,y,w,h)
    local b=Widget.new(self,x,y,w,h); b.text=text; return b
end
ISLabel=Widget:derive('Label')
ISComboBox=Widget:derive('ComboBox')
function ISComboBox:clear() self.options={};self.selected=1 end
function ISComboBox:addOption(text) self.options=self.options or {};self.options[#self.options+1]=text end
ISTextBox=Widget:derive('TextBox')
ISModalDialog=Widget:derive('Modal')
ISContextMenu={}
local lastMenu
function ISContextMenu.get(player)
    local menu={options={},player=player or 0}
    function menu:addOption(name,target,callback,...)
        local o={name=name,target=target,callback=callback,args={...}}
        self.options[#self.options+1]=o; return o
    end
    function menu:addSubMenu(option,sub) option.sub=sub end
    lastMenu=menu; return menu
end
function ISContextMenu:getNew(parent)
    -- B42.21 colon method requires a distinct parentContext argument.
    assert(type(parent)=='table' and parent.player~=nil,'native getNew requires parentContext')
    local menu=ISContextMenu.get(parent.player);menu.parent=parent;return menu
end
for _,name in ipairs({'ISCollapsableWindow','ISCollapsableWindowJoypad','ISPanel','ISScrollingListBox',
    'ISTextEntryBox','ISTextBox','ISModalDialog','ISContextMenu','ISButton','ISLabel','ISComboBox','ISPanelJoypad'}) do
    package.loaded['ISUI/'..name]=true
end
UIFont={Small=1,Medium=2}
Joypad={AButton=1,BButton=2,XButton=3,YButton=4,LBumper=5,RBumper=6}
function getText(key) return key end
function getTexture(path) return path end
function getTextManager() return {getFontHeight=function() return 14 end,MeasureStringX=function(_,_,s) return #s*7 end} end
function getCore() return {getScreenWidth=function() return 1600 end,getScreenHeight=function() return 900 end} end
local joypad={}
function getJoypadData() return joypad end
function getSpecificPlayer() return {getJoypadBind=function() return 0 end} end
function setJoypadFocus(_,value) joypad.focus=value end
function updateJoypadFocus() end
function getSoundManager() return {playUISound=function() end} end
function getMouseX() return 1 end
function getMouseY() return 1 end
local shiftDown,ctrlDown=false,false
Keyboard={KEY_A=30}
function isCtrlKeyDown() return ctrlDown end
function isShiftKeyDown() return shiftDown end

local stored={cats={Food=true},items={OldName=true},presets={Kit='b47:7'},priority=8}
local saves=0
local api={
    getCategories=function() return {'Food','Medical'} end,
    getItemNames=function() return {'Apple','Bread','Pills'} end,
    getItemsInCategory=function(cat)
        if cat=='Food' then return {{name='Apple'},{name='Bread'}} end
        if cat=='Medical' then return {{name='Pills'}} end
        return {}
    end,
    getBoxCats=function() return stored.cats end,
    getBoxItems=function() return stored.items end,
    getBoxPresets=function() return stored.presets end,
    getBoxPriority=function() return stored.priority end,
    setBoxCats=function(_,_,v) stored.cats=v; saves=saves+1 end,
    setBoxItems=function(_,_,v) stored.items=v; saves=saves+1 end,
    setBoxPresets=function(_,_,v) stored.presets=v; saves=saves+1 end,
    setBoxPriority=function(_,_,v) stored.priority=v; saves=saves+1 end,
    getPresetStore=function() return {Kit={owned=true,cats={Medical=true},items={},gen=7,rev=2}} end,
    presetNames=function() return {'Kit'} end,
    getItemFullType=function() return nil end,
    itemTexture=function() return nil end,
}
function isClient() return false end
function isServer() return false end
local Q=require 'B47ANCEDQuartermaster/Adapter'
Q.UIOptions.setGroupByMod(true) -- legacy grouped-tree assertions opt in
local function open()
    local p=Q.Picker:new({},0,0,{api=api,config=stored,
        library={revision=1,definitions=api.getPresetStore()},save=function(_,config) stored=Q.Schema.copy(config);saves=saves+1 end})
    p.getPresetStore=function() return api.getPresetStore() end
    p:initialise();p:addToUIManager();assert(Q.adapt(p));return p
end
local p=open()
local lb=p.listbox
local function find(kind,key)
    for i,entry in ipairs(lb.items) do
        local r=entry.item
        if r.kind==kind and (r.key==key or r.id==key or (r.mod and r.mod.label==key)) then return r,i end
    end
    error('Row absent: '..kind..' '..tostring(key))
end
local function click(kind,key,label)
    local r,i=find(kind,key)
    lb:onMouseDown(label and 180 or 8+(r.depth or 0)*20,(i-1)*22+5)
end
local function search(text) p.filter:setText(text); p:rebuild() end
local function allOpen() Q.expandAll(p,true) end
local function reset()
    shiftDown,ctrlDown=false,false
    p.onlyChecked,p.onlyContents=false,false
    p.qmss.model:clear(); search(''); allOpen()
end
local function runOption(menu,label)
    for _,o in ipairs(menu.options) do
        if o.name=='UI_QMSS_'..label then assert(o.callback); o.callback(o.target,unpack(o.args)); return end
    end
    error('Menu option absent: '..label)
end
assert(p.qmss.count==4, 'effective count must include Food, OldName and preset Medical')
assert(p.btnModeCat.title=='UI_QMSS_Combined (4)')
assert(not p.btnModeItem.visible and p.wantKeyEvents)
assert(lb.vscroll.x==lb:getWidth()-17 and lb.vscroll.height==lb:getHeight())
p:setWidth(570); p:setHeight(680); p:prerender()
assert(lb.vscroll.x==lb:getWidth()-17 and lb.vscroll.height==lb:getHeight())
p:onGainJoypadFocus(joypad);p:prerender()
local hasBulk=false
for _,button in ipairs(p.allJoypadButtons) do
    assert(button~=p.btnModeItem)
    if button==p.qmss.bulkButton then hasBulk=true end
end
assert(hasBulk, 'controller cannot reach bulk actions')
p.btnSave.onclick(p)
assert(stored.cats.Food and stored.items.OldName and stored.presets.Kit=='b47:7' and saves==1)
p=open();lb=p.listbox
assert(Q.adapt(p)==false)
click('category','Food',true)
assert(#lb.items==4 and lb.items[2].item.kind=='mod')
local modId=lb.items[2].item.id
click('mod',modId,true)
assert(#lb.items==6)
for _,entry in ipairs(lb.items) do
    assert(entry.tooltip==nil, 'ordinary category, mod and item rows must not show instructional hover popups')
end
assert(p.btnModeCat.tooltip=='UI_QMSS_SortingSummaryTip', 'mode tooltip must remain concise; controls belong in Help')
click('item','Apple')
assert(not p.selectedCats.Food and p.selectedItems.Bread and not p.selectedItems.Apple)
assert(p.qmss.count==3)
click('item','Apple')
assert(p.selectedCats.Food and not p.selectedItems.Bread and p.qmss.count==4)
-- Existing icon API, indentation, offscreen skipping and missing texture alignment.
local oldType,oldTexture=api.getItemFullType,Q.Picker.itemTexture
local calls,drawn,positions=0,{},{}
api.getItemFullType=function(name) calls=calls+1; return name=='Apple' and 'Base.Apple' end
Q.Picker.itemTexture=function(t) return t=='Base.Apple' and 'apple-texture' end
lb.drawTextureScaled=function(self,texture,x,y,w,h) drawn[texture]={x=x,w=w,h=h} end
lb.drawText=function(self,text,x) positions[text]=x end
local _,ai=find('item','Apple');local _,bi=find('item','Bread')
lb:doDrawItem((ai-1)*22,lb.items[ai],false);lb:doDrawItem((bi-1)*22,lb.items[bi],false)
assert(drawn['apple-texture'].w==18 and positions.Apple==93 and positions.Bread==93)
lb:doDrawItem(100000,lb.items[ai],false);assert(calls==2)
api.getItemFullType,Q.Picker.itemTexture=oldType,oldTexture
lb.drawTextureScaled,lb.drawText=Widget.drawTextureScaled,Widget.drawText
search('bread');p.btnAll.onclick(p)
assert(p.selectedCats.Food and not p.selectedItems.Bread, 'selecting covered item changed precedence')
p:cycleMode(1);assert(p.mode=='presets' and p.qmss.bulkButton.visible)
local manageReachable=false
for _,button in ipairs(p.allJoypadButtons) do if button==p.qmss.bulkButton then manageReachable=true end end
assert(manageReachable,'controller cannot reach preset management')
lb.selected=1;lb:onJoypadDown(Joypad.AButton,joypad);p:prerender()
assert(not p.selectedPresets.Kit and p.qmss.count==3)
p.btnAll.onclick(p);p:prerender();assert(p.selectedPresets.Kit=='b47:7' and p.qmss.count==4)
local originalStore=api.getPresetStore
api.getPresetStore=function() return {Kit={owned=true,cats={},items={},gen=7,rev=3}} end
p:prerender();assert(p.qmss.count==3,'preset revision did not refresh effective count')
api.getPresetStore=originalStore;p:prerender();assert(p.qmss.count==4)
p:cycleMode(-1)
assert(p.filter:getInternalText()=='bread')
p.btnClear.onclick(p)
assert(not p.selectedCats.Food and p.selectedItems.Apple and not p.selectedItems.Bread)
p.btnSave.onclick(p);p=open();lb=p.listbox
assert(p.selectedItems.Apple and not p.selectedItems.Bread and p.selectedItems.OldName)
reset();p:closePicker();assert(stored.items.Apple, 'cancel leaked mutations')
-- Group provenance is tested separately. This deterministic resolver gives two mods per category.
local scans=0
api.getCategories=function() scans=scans+1;return {'A','B','C'} end
api.getItemNames=function() scans=scans+1;return {'a1','a2','a3','b1','b2','b3','c1','c2','c3'} end
api.getItemsInCategory=function(cat)
    scans=scans+1;local n=string.lower(cat)
    return {{name=n..'1'},{name=n..'2'},{name=n..'3'}}
end
Q.Ownership.build=function() return function(cat,name)
    return name:sub(-1)=='3' and 'mod' or 'pz-vanilla',name:sub(-1)=='3' and 'Cooking Mod' or 'Vanilla'
end end
stored={cats={},items={},presets={},priority=0}
p=open();lb=p.listbox;allOpen()
-- Forward target select, then checked target clears inclusive range. Ctrl keeps anchor.
click('item','a1');local anchor=p.qmss.rangeAnchor
ctrlDown=true;click('item','c3');assert(p.qmss.rangeAnchor==anchor);ctrlDown=false
shiftDown=true;click('item','b2');assert(p.selectedCats.A and p.selectedItems.b1 and p.selectedItems.b2)
assert(not p.selectedItems.b3 and p.selectedItems.c3)
click('item','b2');assert(not p.selectedCats.A and not p.selectedItems.b1 and not p.selectedItems.b2)
shiftDown=false
-- Reverse range, with an intermediate collapsed category left untouched.
reset();click('category','B',true)
click('item','c2');shiftDown=true;click('item','a1');shiftDown=false
assert(p.selectedCats.A and not p.selectedCats.B and not p.selectedItems.b1)
assert(p.selectedItems.c1 and p.selectedItems.c2 and not p.selectedItems.c3)
-- A direct checkbox retains whole-category semantics; ranges touch rendered items only.
reset();Q.expandAll(p,false)
click('category','A');shiftDown=true;click('category','C');shiftDown=false
assert(p.selectedCats.A and not p.selectedCats.B and not p.selectedCats.C and p.qmss.count==3)
allOpen();shiftDown=true;click('category','C');shiftDown=false
assert(p.selectedCats.A and p.selectedCats.B and p.selectedCats.C and p.qmss.count==9)
shiftDown=true;click('category','C');shiftDown=false
assert(not p.selectedCats.A and not p.selectedCats.B and not p.selectedCats.C and p.qmss.count==0)
-- Mixed-type endpoints act as normal target actions and establish a new anchor.
allOpen();click('category','A');shiftDown=true;click('item','b1');shiftDown=false
assert(p.qmss.rangeAnchor==find('item','b1').id and p.selectedItems.b1)
-- Mod ranges preserve collapsed children, then affect them once actually expanded.
reset();Q.expandAll(p,false);click('category','A',true);click('category','B',true)
local aMod=p.qmss.model.byId['c:A'].mods[1]
local bMod=p.qmss.model.byId['c:B'].mods[1]
click('mod',aMod.id);shiftDown=true;click('mod',bMod.id);shiftDown=false
assert(not p.selectedCats.A and p.selectedItems.a1 and p.selectedItems.a2 and not p.selectedItems.b1)
allOpen();shiftDown=true;click('mod',bMod.id);shiftDown=false
assert(p.selectedCats.A and p.selectedItems.b1 and p.selectedItems.b2 and not p.selectedItems.b3)
-- Item-only filtering also bounds category ranges, rather than selecting entire groups.
reset();search('1')
p.qmss.rangeAnchor=find('category','A').id
shiftDown=true;click('category','C');shiftDown=false
assert(p.selectedItems.a1 and p.selectedItems.b1 and p.selectedItems.c1 and p.qmss.count==3)
assert(not p.selectedCats.A and not p.selectedItems.a2 and not p.selectedItems.b2 and not p.selectedItems.c2)
shiftDown=true;click('category','C');shiftDown=false;assert(p.qmss.count==0)
search('')
-- Visible commands see only item rows, not collapsed category or mod descendants.
reset();click('category','B',true)
local hiddenMod=p.qmss.model.byId['c:A'].mods[2]
click('mod',hiddenMod.id,true)
ctrlDown=true;p:onKeyPress(Keyboard.KEY_A);ctrlDown=false
assert(not p.selectedItems.a3 and not p.selectedCats.A and p.selectedItems.a1 and p.selectedItems.a2)
assert(not p.selectedCats.B and not p.selectedItems.b1 and p.selectedCats.C)
ctrlDown,shiftDown=true,true;p:onKeyPress(Keyboard.KEY_A);ctrlDown,shiftDown=false,false
assert(p.qmss.count==0)
-- Search matches broadest ancestor and restores prior expansion after clearing.
reset();Q.expandAll(p,false)
search('a');assert(#lb.items==14) -- category A + Vanilla matches in B/C
search('A');assert(#lb.items==14)
search('Cooking Mod');assert(#lb.items==9)
Q.visibleAction(p,'select');assert(p.selectedItems.a3 and p.selectedItems.b3 and p.selectedItems.c3 and p.qmss.count==3)
search('a1');assert(#lb.items==3)
ctrlDown=true;p:onKeyPress(Keyboard.KEY_A);ctrlDown=false
assert(p.selectedItems.a1 and not p.selectedItems.a2 and p.qmss.count==4)
Q.visibleAction(p,'invert');assert(not p.selectedItems.a1 and p.qmss.count==3)
search('');assert(#lb.items==3,'normal collapsed state lost')
search('b');Q.visibleAction(p,'select');assert(p.selectedCats.B)
p.onlyChecked=true;search('Cooking Mod');assert(#lb.items==9)
p._contents={items={a3=true}};p.onlyContents=true;p:rebuild();assert(#lb.items==3)
Q.visibleAction(p,'clear');assert(not p.selectedItems.a3 and p.selectedItems.c3 and p.selectedCats.B)
-- Focus guards: Ctrl+A in the search/priority entry must select text, never modify rules.
reset();search('a1');ctrlDown=true;p.filter.focused=true
assert(not p:isKeyConsumed(Keyboard.KEY_A));p:onKeyPress(Keyboard.KEY_A);assert(p.qmss.count==0)
p.filter.focused=false;p.priorityEntry.focused=true;p:onKeyPress(Keyboard.KEY_A);assert(p.qmss.count==0)
p.priorityEntry.focused=false;p.dimmer:setVisible(true);p:onKeyPress(Keyboard.KEY_A);assert(p.qmss.count==0)
p.dimmer:setVisible(false);ctrlDown=false
-- Context commands are explicit group operations; list commands remain visible-only.
reset();Q.expandAll(p,false)
local row=find('category','A')
local menu=Q.context(p,row,0,0);runOption(menu,'SelectItems');assert(p.selectedCats.A)
menu=Q.context(p,find('category','A'),0,0);runOption(menu,'InvertItems');assert(not p.selectedCats.A)
menu=Q.context(p,find('category','A'),0,0);runOption(menu,'ExpandCategory')
menu=Q.context(p,find('mod',aMod.id),0,0);runOption(menu,'SelectItems');assert(p.selectedItems.a1 and p.selectedItems.a2)
menu=Q.context(p,find('mod',aMod.id),0,0);runOption(menu,'InvertItems');assert(not p.selectedItems.a1 and not p.selectedItems.a2)
menu=Q.context(p,nil,0,0);runOption(menu,'SelectVisible');assert(p.qmss.count==0)
runOption(menu,'ExpandAll');runOption(menu,'SelectVisible');assert(p.qmss.count==9)
runOption(menu,'InvertVisible');assert(p.qmss.count==0)
runOption(menu,'CollapseAll');assert(#lb.items==3)
shiftDown=true;click('category','A',true);shiftDown=false;assert(#lb.items==18)
shiftDown=true;click('category','A',true);shiftDown=false;assert(#lb.items==3)
-- Controller retains A/B/X/Y/bumpers; Bulk actions exposes range anchoring and apply.
reset();p:onGainJoypadFocus(joypad);p:prerender()
local r,i=find('item','a1');lb.selected=i;p.qmss.bulkButton.onclick(p)
local rangeMenu=lastMenu -- stub's last submenu is range controls
runOption(rangeMenu,'SetAnchor');assert(p.qmss.rangeAnchor==r.id)
local target,ti=find('item','a2');lb.selected=ti
menu=Q.context(p,target,0,0)
runOption(lastMenu,'ApplyRange');assert(p.selectedItems.a1 and p.selectedItems.a2)
assert(joypad.focus==menu)
lb:onJoypadDown(Joypad.BButton,joypad);assert(joypad.focus==p)
local _,ci=find('category','A');lb.selected=ci
lb:onJoypadDown(Joypad.XButton,joypad);assert(p.qmss.rangeAnchor==nil,'hidden anchor retained')
lb:onJoypadDown(Joypad.YButton,joypad)
lb:onJoypadDown(Joypad.RBumper,joypad);assert(p.mode=='presets')
lb:onJoypadDown(Joypad.LBumper,joypad);assert(p.mode=='cats')
-- Content filters and checked filters must invalidate vanished stable anchors.
reset();click('item','a1');assert(p.qmss.rangeAnchor)
p._contents={items={b1=true}};p.onlyContents=true;p:rebuild();assert(not p.qmss.rangeAnchor)
p.onlyContents=false;p:rebuild();p.onlyChecked=true;p:rebuild()
click('item','a1');assert(not p.qmss.rangeAnchor and #lb.items==0)
-- 20k-item stress: bounded transaction and rebuild, no repeated catalog scans in rendering.
api.getCategories=function() scans=scans+1;local c={};for i=1,200 do c[i]=string.format('Cat%03d',i) end;return c end
api.getItemsInCategory=function(cat) scans=scans+1;local a={};for i=1,100 do a[i]={name=cat..' Item'..i} end;return a end
api.getItemNames=function() scans=scans+1;return {} end
stored={cats={},items={},presets={},priority=0};p=open();lb=p.listbox;allOpen()
lb:setYScroll(-2200);local initial=scans
local n=0;local normalize=p.qmss.model.normalize
p.qmss.model.normalize=function(self,...) n=n+1;return normalize(self,...) end
Q.visibleAction(p,'select');assert(n==1 and p.qmss.count==20000 and lb:getYScroll()==-2200)
Q.visibleAction(p,'invert');assert(n==2 and p.qmss.count==0 and lb:getYScroll()==-2200)
for i=1,5 do p:prerender() end;assert(scans==initial)
p:cycleMode(1);p:cycleMode(-1);assert(lb:getYScroll()==-2200)
assert(LootSorter==nil, 'standalone UI introduced a foreign global')
print('PASS owned UI: tree/icons/counts, visible bulk/ranges, filters, controller, staged callbacks and 20k items; no upstream loaded')

-- Group menus expose only meaningful selection operations.
api.getCategories=function() return {'Empty','One'} end
api.getItemsInCategory=function(cat) return cat=='One' and {{name='single'}} or {} end
api.getItemNames=function() return {'single'} end
stored={cats={},items={},presets={},priority=0};p=open();lb=p.listbox
local function hasOption(menu,key) for _,o in ipairs(menu.options) do if o.name=='UI_QMSS_'..key then return true end end return false end
local one=find('category','One');local menu=Q.context(p,one,0,0)
assert(hasOption(menu,'SelectItems') and not hasOption(menu,'ClearItems'))
p.qmss.model:setGroup(one.group,true);p:rebuild()
menu=Q.context(p,find('category','One'),0,0)
assert(not hasOption(menu,'SelectItems') and hasOption(menu,'ClearItems'))
menu=Q.context(p,find('category','Empty'),0,0)
assert(not hasOption(menu,'SelectItems') and not hasOption(menu,'ClearItems') and not hasOption(menu,'InvertItems'))
print('PASS OFFLINE state-aware category menus: none/full/empty')
