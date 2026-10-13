dofile(TEST_ROOT..'/test_shopping_ui.lua')
local Q=B47ANCEDQuartermaster;local U=Q.ShoppingAddUI
local clock=50000;getTimestampMs=function() return clock end
local owner={};local focus;setJoypadFocus=function(_,p) focus=p;if p and p.onGainJoypadFocus then p:onGainJoypadFocus({}) end end
function ISButton:forceClick() if self.enable~=false then self.onclick(self.target,self) end end
local new=ISPanelJoypad.new
ISPanelJoypad.new=function(self,...)
 local p=new(self,...);p.joypadButtonsY={};p.allJoypadButtons={};return p
end
-- Reproduce the installed Modal's callback/delegation surface. Its native
-- onGain maps A directly to Yes; the owned confirmation must override it.
function ISModalDialog:new(x,y,w,h,text,yesno,target,callback,player)
 local p=ISPanelJoypad.new(self,x,y,w,h);p.onclick=callback;p.target=target;p.player=player
 p.yes=ISButton:new(0,h-30,90,24,'Yes',p,function(s,b) s:destroy();s.onclick(s.target,b) end);p.yes.internal='YES'
 p.no=ISButton:new(100,h-30,90,24,'No',p,function(s,b) s:destroy();s.onclick(s.target,b) end);p.no.internal='NO'
 return p
end
function ISModalDialog:destroy() self:removeFromUIManager() end
function ISModalDialog:onGainJoypadFocus() error('unsafe native Yes mapping used') end
function ISModalDialog:onJoypadDown(key)
 if key==Joypad.AButton then self.joypadButtonsY[self.joypadIndexY][self.joypadIndex]:forceClick() end
end
local chosen;local modal=U.confirm(0,'duplicate',function(mode) chosen=mode end,owner,true)
assert(modal.joypadButtonsY[1][1]==modal.no and focus==modal)
modal.joypadIndex=2;modal:onJoypadDown(Joypad.AButton);modal.yes:forceClick();assert(not chosen,'opening input accepted duplicate')
clock=clock+300;modal.joypadIndex=1;modal:onJoypadDown(Joypad.AButton);assert(chosen=='cancel' and focus==owner)
chosen=nil;modal=U.confirm(0,'duplicate',function(mode) chosen=mode end,owner)
clock=clock+300;modal.joypadIndex=2;modal:onJoypadDown(Joypad.AButton);assert(chosen=='again' and focus==owner)
chosen=nil;modal=U.confirm(0,'duplicate',function(mode) chosen=mode end,owner)
clock=clock+300;modal:onJoypadDown(Joypad.BButton);assert(chosen=='cancel')
chosen=nil;modal=U.confirm(0,'mixed',function(mode) chosen=mode end,owner,true)
clock=clock+300;modal.joypadIndexY=2;modal.joypadIndex=1;modal:onJoypadDown(Joypad.AButton);assert(chosen=='newOnly')
-- Every caller uses one pending pipeline; repeated callback/UI events cannot
-- send an additional operation while awaiting snapshot or confirmation.
local calls,reply={},nil;Q.Authority.request=function(_,command,args,cb) calls[#calls+1]={command=command,args=args};reply=cb end
U.pending={};U.recent={};clock=clock+1000
local result;assert(U.send(0,{kind='shopping',fullType='Base.Nails',quantity=4},function(s) result=s end,owner))
assert(not U.send(0,{kind='shopping',fullType='Base.Nails',quantity=4},nil,owner) and #calls==1)
reply({status='ok',revision=3});assert(#calls==2 and calls[2].command=='shoppingAdd' and calls[2].args.operation and calls[2].args.revision==3)
reply({status='duplicate',confirmation='token',new=0,duplicate=1});modal=focus;assert(#calls==2)
clock=clock+300;modal:onJoypadDown(Joypad.AButton);assert(result.status=='cancelled' and #calls==2)
clock=clock+1000;assert(U.send(0,{kind='shopping',fullType='Base.Nails',quantity=4},function(s) result=s end,owner))
reply({status='ok',revision=3});reply({status='duplicate',confirmation='token',new=0,duplicate=1});modal=focus
clock=clock+300;modal.joypadIndex=2;modal:onJoypadDown(Joypad.AButton)
assert(#calls==5 and calls[5].args.mode=='again' and calls[5].args.confirmation=='token')
reply({status='ok'});assert(result.status=='ok')
print('PASS OFFLINE duplicate UI: safe Cancel/default B, distinct confirmation arming, one mixed-bulk choice, focus restoration, asynchronous double-fire coalescing and shared protected intent')
