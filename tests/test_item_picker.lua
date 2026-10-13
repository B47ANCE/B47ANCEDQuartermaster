dofile(TEST_ROOT..'/test_shopping_ui.lua')
package.loaded['ISUI/ISPanelJoypad']=true
local Q=B47ANCEDQuartermaster
local C=Q.ItemCatalog;C.cache=nil
local enumerations=0
local function definition(t,name,hidden,obsolete)
 return {getFullName=function() return t end,getDisplayName=function() return name end,getModuleName=function() return t:match('^([^.]+)') end,
 isHidden=function() return hidden or false end,getObsolete=function() return obsolete or false end}
end
local scripts={definition('Base.Nails','Nails'),definition('Mod.CustomNails','Nails'),definition('Mod.Literal[thing]','Literal[thing]'),definition('Base.Internal','Internal',true),definition('Base.Obsolete','Old',false,true)}
getAllItems=function() enumerations=enumerations+1;return CONTAINER_FIXTURE.list(scripts) end
assert(#C.catalog()==3 and enumerations==1)
assert(#C.search('NAILS')==2 and C.search('mod.customnails')[1].fullType=='Mod.CustomNails')
assert(#C.search('[thing]')==1 and #C.search('Internal')==0 and enumerations==1)
for i=1,20 do C.search('mod') end;assert(enumerations==1,'catalog rebuilt during search')
local calls={};Q.Authority.request=function(_,command,args,cb)
 if command=='personalList' then cb({status='ok',revision=7,wish={},manual={['Base.Nails']=5}})
 else calls[#calls+1]={command=command,args=args};cb({status='ok'}) end
end
local new=ISPanelJoypad.new
ISPanelJoypad.new=function(self,...)
 local w=new(self,...);w.joypadButtonsY={};w.allJoypadButtons={};return w
end
local P=require 'B47ANCEDQuartermaster/ItemPicker'
local changed=0;local w=P.open(0,'wish',function() changed=changed+1 end)
assert(not w.add.enable and #w.list.items==3)
w.list.onmousedown(w,{fullType='Base.Nails'});w.quantity:setText('222');w:submit()
assert(calls[1].command=='personalChange' and calls[1].args.kind=='wish' and calls[1].args.fullType=='Base.Nails' and calls[1].args.quantity==222 and changed==1 and w.closed)
w=P.open(0,'shopping');w.list.onmousedown(w,{fullType='Base.Nails'});w.quantity:setText('40');w:submit()
assert(calls[2].command=='shoppingAdd' and calls[2].args.kind=='shopping' and calls[2].args.quantity==40 and calls[2].args.operation,'manual add must send incremental intent through replay protection')
w=P.open(0,'shopping');w.quantity:setText('0.5');w.list.onmousedown(w,{fullType='Base.Nails'});assert(not w.add.enable);w:submit();assert(#calls==2)
Q.Authority.request=function(_,command,args,cb) cb({status='ok',revision=8,wish={['Base.Nails']=222},manual={}}) end
w=P.open(0,'wish');w.quantity:setText('1');w.list.onmousedown(w,{fullType='Base.Nails'});assert(not w.add.enable,'duplicate Wish offered')
-- Native recipe wrappers retain original handlers and geometry; only intent sent.
local U=require 'B47ANCEDQuartermaster/RecipeShoppingUI'
local createCount,layoutCount,updateCount=0,0,0
local class=ISPanelJoypad:derive('FakeNativeControl')
function class:createChildren() createCount=createCount+1;self.buttonCraft=ISButton:new(5,10,200,24,'Craft',self,function() end);self.entryBox=ISTextEntryBox:new('3',0,0,1,1);self.entryBox:setText('3');self:addChild(self.buttonCraft) end
function class:calculateLayout() layoutCount=layoutCount+1;self.buttonCraft:setWidth(200);self.joypadButtonsY={};self.allJoypadButtons={} end
function class:update() updateCount=updateCount+1 end
function class:getX() return self.x end;function class:getY() return self.y end
function ISButton:getX() return self.x end;function ISButton:getY() return self.y end
U.install(class,'craft');U.install(class,'craft')
local control=class:new(0,0,210,50);control.player={getPlayerNum=function() return 0 end};control.logic={getRecipe=function() return {getName=function() return 'NativeRecipe' end} end}
Q.ShoppingRequirements.resolve=function() return {{}} end
control:createChildren();control:calculateLayout();control:update()
assert(createCount==1 and layoutCount==1 and updateCount==1 and control.b47Shopping.enable)
assert(control.buttonCraft:getWidth()==166 and control.b47Shopping.x+control.b47Shopping.width==205)
control:calculateLayout();assert(control.buttonCraft:getWidth()==166,'wrapper shrank native geometry repeatedly')
local received;Q.Authority.request=function(_,command,args,cb)
 if command=='personalList' then cb({status='ok',revision=22}) else received={command=command,args=args};cb({status='ok'}) end
end
U.submit(0,'craft','NativeRecipe',3,function() end)
assert(received.command=='shoppingAdd' and received.args.operation and received.args.recipe=='NativeRecipe' and received.args.quantity==3 and received.args.revision==22 and received.args.items==nil and received.args.player==nil)
print('PASS OFFLINE shared manual picker: native-shaped loaded catalog/filter/cache/literal identity, no-spawn intent, quantity/duplicate validation; native recipe wrappers preserve geometry and handlers')

getPlayerScreenWidth=function() return 320 end;getPlayerScreenHeight=function() return 240 end
getPlayerScreenLeft=function() return 320 end;getPlayerScreenTop=function() return 240 end
local owner={};local small=P.open(1,'shopping',nil,owner)
assert(small.x>=320 and small.y>=240 and small.x+small.width<=640 and small.y+small.height<=480)
assert(small.list.y+small.list.height<small.add.y and small.add.y+small.add.height<small.height)
local focus;setJoypadFocus=function(_,p) focus=p end;small.joyfocus={};small:close();assert(focus==owner)
print('PASS OFFLINE viewport bounds and native joyfocus restoration')
