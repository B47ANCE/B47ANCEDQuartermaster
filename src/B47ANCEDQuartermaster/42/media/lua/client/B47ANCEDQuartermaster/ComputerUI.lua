-- Original Lua-drawn computer presentation. Mounts are local references, never
-- physical item moves or authority to read a snapshot / complete a CD write.
require 'B47ANCEDUI/Controls'
require 'ISUI/ISComboBox'
local U=B47ANCEDUI
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Art=require 'B47ANCEDQuartermaster/ComputerArt'
local C={active={}};B47ANCEDQuartermaster.ComputerUI=C
local function color(r,g,b) return {r=r,g=g,b=b,a=1} end
C.colors={case=color(.25,.24,.21),grey=color(.75,.75,.72),light=color(.96,.96,.91),shadow=color(.36,.36,.34),
 black=color(.04,.05,.05),white=color(1,1,.97),blue=color(.03,.07,.38),teal=color(0,.37,.36),muted=color(.3,.32,.32)}
local P=C.colors;local R=U.Renderer
local function tr(k,...) return getText('UI_QMSS_'..k,...) end
local function rect(w,x,y,a,b,c) R.rect(w,x,y,a,b,c) end
local function bevel(w,x,y,a,b,down)
 rect(w,x,y,a,2,down and P.shadow or P.light);rect(w,x,y,2,b,down and P.shadow or P.light)
 rect(w,x,y+b-2,a,2,down and P.light or P.shadow);rect(w,x+a-2,y,2,b,down and P.light or P.shadow)
end
local function text(w,s,x,y,width,c) R.text(w,R.fit(s,width),x,y,c or P.black) end
function C.decorate(w,kind)
 w.backgroundColor=U.Theme.copy(kind=='input' and P.white or P.grey)
 w.backgroundColorMouseOver=U.Theme.copy(P.light);w.borderColor=U.Theme.copy(P.shadow)
 w.textColor=U.Theme.copy(P.black);w.textColorDisabled=U.Theme.copy(P.muted)
 -- Native text entries paint their glyphs in UITextBox2, not Lua textColor.
 if kind=='input' and w.setTextRGBA then w:setTextRGBA(P.black.r,P.black.g,P.black.b,1) end
 if kind=='list' then w.selectionColor=U.Theme.copy(P.blue) end
 return w
end
local function button(owner,label,fn)
 local b=ISButton:new(0,0,120,U.Theme.metrics().button,label,owner,fn)
 b:initialise();b:instantiate();owner:addChild(b);C.decorate(b,'button');b.font=U.Theme.fonts.body
 b.prerender=function(self)
  rect(self,0,0,self:getWidth(),self:getHeight(),self.mouseOver and P.light or P.grey)
  bevel(self,0,0,self:getWidth(),self:getHeight(),self.pressed)
 end
 -- Use native input/controller handling, with original, clipped OS captions.
 b.render=function(self)
  local full=self.title or '';local caption=R.fit(full,self:getWidth()-12)
  self:drawTextCentre(caption,self:getWidth()/2,(self:getHeight()-U.Theme.metrics().font)/2,
   self.enable==false and P.muted.r or P.black.r,self.enable==false and P.muted.g or P.black.g,
   self.enable==false and P.muted.b or P.black.b,1,U.Theme.fonts.body)
  U.Renderer.focus(self)
 end
 U.Tooltip.attach(b,owner.playerNum);return b
end
local function box(owner,x,y,w,h)
 local p=ISPanelJoypad:new(x,y,w,h);p.playerNum=owner.playerNum;p:initialise();p:instantiate();owner:addChild(p);return p
end
local function initFocus(p)
 p.joypadButtonsY={};p.joypadButtons={};p.allJoypadButtons={};p.joypadIndexY=1;p.joypadIndex=1
end
function C.keyboard(panel,back)
 panel:setWantKeyEvents(true)
 panel.isKeyConsumed=function(self,key) return self.playerNum==0 and key==Keyboard.KEY_ESCAPE end
 panel.onKeyRelease=function(self,key) if self:isKeyConsumed(key) then back() end end
end
local function choice(owner)
 local b=ISComboBox:new(12,12,300,U.Theme.metrics().button,owner,function() end)
 b:initialise();b:instantiate();C.decorate(b,'input');owner:addChild(b);return b
end
local function picked(combo) local o=combo.options[combo.selected];return o and o.data end
local function options(combo,items,empty)
 local old=picked(combo);local signature=''
 for _,item in ipairs(items) do signature=signature..':'..item:getID()..':'..item:getDisplayName() end
 if signature==combo.mediaSignature then for i,item in ipairs(items) do if combo.options[i] then combo.options[i].data=item end end;return end
 combo.mediaSignature=signature;combo:clear()
 if #items==0 then combo:addOptionWithData(tr(empty),false) else
  for i,item in ipairs(items) do combo:addOptionWithData(item:getDisplayName()..' #'..item:getID(),item);if old and old.getID and item:getID()==old:getID() then combo.selected=i end end
 end
end
function C.open(num,computer,hooks)
 if not require('B47ANCEDQuartermaster/LedgerPolicy').enabled() then return end
 local actor=getSpecificPlayer(num);if not actor or not Media.computer(actor,computer,true) then return end
 local current=C.active[num];if current and not current.closed then if current.computer==computer then setJoypadFocus(num,current);return current end;current:close() end
 local m=U.Theme.metrics();local minW=math.max(840,m.font*28+172);local minH=math.max(180+8*m.button,160+5*m.font+5*m.button)+260+math.max(0,m.font-28)
 if getPlayerScreenWidth(num)<minW+20 or getPlayerScreenHeight(num)<minH+20 then actor:setHaloNote(tr('LedgerScreenSmall'));return end
 local screen=ISCollapsableWindowJoypad:new(0,0,math.max(minW,math.min(920,getPlayerScreenWidth(num)-20)),math.max(minH,math.min(800,getPlayerScreenHeight(num)-20)))
 screen.playerNum=num;screen.computer=computer;screen.minimumWidth=minW;screen.minimumHeight=minH;screen.resizable=true;screen.pin=true
 screen.drawFrame=false;screen.clearStentil=false;screen.title='Windows \'93';screen.titleBarHeight=function() return 32 end
 screen:initialise();screen:instantiate();C.active[num]=screen;initFocus(screen)
 local desktop=box(screen,18,34,screen:getWidth()-36,screen:getHeight()-100)
 local frame=box(desktop,12,12,desktop:getWidth()-24,desktop:getHeight()-24);frame:setVisible(false)
 local menu=box(desktop,4,4,math.max(230,m.font*15),4*m.button+16);menu:setVisible(false)
 local status='';local mediaAt=-10000;local sheets,discs,cds={},{},{}
 local driveAt=-10000;local drivePending=false;local available={};local driveReady=false
 local function media(row)
  return {token=row.token,drive=row.drive,getID=function() return row.id end,getDisplayName=function() return row.name end,getFullType=function() return row.fullType end}
 end
 function screen:applyDrive(result)
  local old=self.mounted;local current=result.mounted and media(result.mounted)
  if old and (not current or old.drive~=current.drive or old:getID()~=current:getID()) then self:closeApp();status=tr('ComputerMediaLost') end
  self.mounted=current;self.slot=result.slot or current and current.drive;self.occupied=result.occupied==true;available={}
  for _,row in ipairs(result.choices or {}) do available[#available+1]=media(row) end
 end
 function screen:refreshDrive()
  if drivePending or getTimestampMs()-driveAt<2000 then return end
  drivePending=true;driveAt=getTimestampMs()
  hooks.drive('ledgerDriveList',{},function(r)
   if self.closed or getSpecificPlayer(num)~=actor then return end
   drivePending=false;driveReady=r.status=='ok'
   if driveReady then self:applyDrive(r) else self.mounted=nil;self:closeApp();status=tr(r.status) end
  end)
 end
 function screen:message(key) status=tr(key);mediaAt=-10000 end
 local function scan()
  if getTimestampMs()-mediaAt<1000 then return end;mediaAt=getTimestampMs();sheets,discs,cds=hooks.inventory(actor)
 end
 function screen:refreshFocus()
  initFocus(self)
  if menu:isVisible() then self:insertNewLineOfButtons(self.start);self:insertNewLineOfButtons(menu.drive);self:insertNewLineOfButtons(menu.writer);self:insertNewLineOfButtons(menu.off)
  elseif frame:isVisible() then self:insertNewLineOfButtons(frame.minimize,frame.exit);self:insertNewLineOfButtons(self.start,self.task,self.off);self:insertNewLineOfButtons(self.power)
  else self:insertNewLineOfButtons(self.driveIcon,self.writerIcon);self:insertNewLineOfButtons(self.start,self.task,self.off);self:insertNewLineOfButtons(self.power) end
 end
 function screen:release(content)
  frame:removeChild(content)
  if self.content==content then self.content=nil;frame:setVisible(false);self.task.title=tr('ComputerDesktop') end
  self:refreshFocus();if not self.closed then setJoypadFocus(num,self) end
 end
 function screen:closeApp()
  local content=self.content
  if content then if content.close then content:close() else self:release(content) end end
 end
 function screen:showApp(content,title)
  self:closeApp();menu:setVisible(false);self.content=content;self.appTitle=title;self.task.title=title
  frame:addChild(content);frame:setVisible(true);frame:bringToTop();self:layoutComputer();self:refreshFocus();setJoypadFocus(num,content)
 end
 function screen:desktop()
  frame:setVisible(false);menu:setVisible(false);self:refreshFocus();setJoypadFocus(num,self)
 end
 function screen:close()
  if self.closed then return end;self.closed=true;self:closeApp();C.active[num]=nil;self.mounted=nil
  U.Tooltip.dispose(self);self:removeFromUIManager();hooks.close();U.Focus.restore(num)
 end
 function screen:eject()
  hooks.drive('ledgerDriveEject',{drive=self.slot},function(r)
   if self.closed then return end
   if r.status=='ok' then self:closeApp();self.mounted=nil;self.occupied=false;status=tr('ComputerEjected');driveAt=-10000;self:openDrive() else status=tr(r.status) end
  end)
 end
 function screen:runDisc()
  if self.closed or C.active[num]~=self then return end
  if hooks.busy() then status=tr('busy');return end
  local disc=self.mounted
  if not disc or not driveReady or drivePending or not disc.drive then status=tr('ComputerNoApplication');return end
  if not Media.computer(actor,computer,true) then self:close();return end
  hooks.read(disc,self)
 end
 local function view(title)
  local v=ISPanelJoypad:new(0,0,frame:getWidth()-8,frame:getHeight()-m.button-12);v.playerNum=num;v:initialise();v:instantiate();initFocus(v)
  v.close=function(self) U.Tooltip.dispose(self);screen:release(self) end
  C.keyboard(v,function() v:close() end)
  v.onJoypadDown=function(self,key) if key==Joypad.BButton then self:close() else ISPanelJoypad.onJoypadDown(self,key) end end
  screen:showApp(v,title);return v
 end
 function screen:openDrive()
  self:refreshDrive();local v=view(tr('ComputerDrive'));v.media=choice(v)
  v.insert=button(v,tr('ComputerInsert'),function()
   if hooks.busy() then return end
   local disc=picked(v.media);if not disc or not disc.token or drivePending then return end
   hooks.drive('ledgerDriveMount',{token=disc.token},function(r)
    if screen.closed then return end
    if r.status=='ok' then screen:closeApp();screen:applyDrive(r);status=tr('ComputerInserted',disc:getDisplayName());driveAt=-10000;screen:openDrive() else status=tr(r.status);driveAt=-10000 end
   end)
  end)
  v.run=button(v,tr('ComputerRun'),function() screen:runDisc() end)
  v.eject=button(v,tr('ComputerEject'),function() screen:eject() end)
  v.file=button(v,'QUARTERMASTER.EXE',function() status=tr('ComputerRunHint') end)
  v.file.onMouseDoubleClick=function() screen:runDisc();return true end
  v.file.render=function(self)
   local scale=m.button>=40 and 2 or 1;local size=32*scale
   Art.icon(self,'application',12,math.floor((self:getHeight()-size)/2),scale)
   text(self,self.title,24+size,math.floor((self:getHeight()-m.font)/2),self:getWidth()-36-size)
   R.focus(self)
  end
  v.prerender=function(self)
   screen:refreshDrive()
   options(self.media,available,'ComputerNoCD');local w,h=self:getWidth(),self:getHeight()
   U.Layout.place(self.media,12,12,w-24,m.button);U.Layout.place(self.insert,12,20+m.button,w-24,m.button)
   local runnable=driveReady and screen.mounted and screen.mounted:getFullType()==Media.disc
   U.Layout.place(self.file,12,40+2*m.button,w-24,2*m.button);self.file:setVisible(runnable==true)
   U.Layout.place(self.run,12,h-m.button-12,(w-36)/2,m.button);U.Layout.place(self.eject,24+(w-36)/2,h-m.button-12,(w-36)/2,m.button)
   self.run:setEnable(runnable==true and not hooks.busy() and not drivePending);self.eject:setEnable(screen.mounted~=nil or screen.occupied);self.insert:setEnable(driveReady and not drivePending and not screen.mounted and not screen.occupied and not hooks.busy() and picked(self.media)~=false and picked(self.media)~=nil)
   if not runnable then text(self,screen.mounted and tr('ComputerBlankCD') or tr('ComputerInsertHint'),12,40+2*m.button,w-24) end
  end
  v:insertNewLineOfButtons(v.media);v:insertNewLineOfButtons(v.insert)
  if screen.mounted and screen.mounted:getFullType()==Media.disc then v:insertNewLineOfButtons(v.file) end
  v:insertNewLineOfButtons(v.run,v.eject)
  v:prerender();self:refreshFocus();return v
 end
 function screen:openWriter()
  self:refreshDrive();scan();local v=view(tr('ComputerWriter'));v.paper=choice(v);v.cd=choice(v)
  v.write=button(v,tr('ComputerWrite'),function()
   local paper,cd=picked(v.paper),picked(v.cd)
   if not paper or not cd or hooks.busy() then return end
   if screen.mounted or screen.occupied or not driveReady or drivePending then status=tr('ComputerEjectFirst');return end
   if not Media.computer(actor,computer,true) then screen:close();return end
   hooks.burn(paper,cd);status=tr('ComputerWriting')
  end)
  v.prerender=function(self)
   screen:refreshDrive();scan();local complete={};for _,p in ipairs(sheets) do if p:getModData().B47Ledger and p:getModData().B47Ledger.complete then complete[#complete+1]=p end end
   options(self.paper,complete,'ComputerNoSheet');options(self.cd,cds,'ComputerNoCD')
   local w,h=self:getWidth(),self:getHeight();text(self,tr('ComputerSource'),12,8,w-24)
   U.Layout.place(self.paper,12,12+m.font,w-24,m.button);text(self,tr('ComputerDestination'),12,24+m.font+m.button,w-24)
   U.Layout.place(self.cd,12,28+2*m.font+m.button,w-24,m.button)
   text(self,tr('ComputerOverwrite'),12,40+2*m.font+2*m.button,w-24,P.muted)
   self.write:setEnable(driveReady and not drivePending and not screen.occupied and not hooks.busy() and not screen.mounted and picked(self.paper)~=false and picked(self.cd)~=false)
   U.Layout.place(self.write,12,h-m.button-12,w-24,m.button)
  end
  v:insertNewLineOfButtons(v.paper);v:insertNewLineOfButtons(v.cd);v:insertNewLineOfButtons(v.write);v:prerender();self:refreshFocus();return v
 end
 screen.driveIcon=button(desktop,tr('ComputerDrive'),function() screen:openDrive() end)
 screen.writerIcon=button(desktop,tr('ComputerWriter'),function() screen:openWriter() end)
 for _,entry in ipairs({{screen.driveIcon,'disc'},{screen.writerIcon,'writer'}}) do
  local b,kind=entry[1],entry[2]
  b.prerender=function(self) if self.mouseOver or self.joypadFocused then R.border(self,0,0,self:getWidth(),self:getHeight(),P.light) end end
  b.render=function(self)
   Art.icon(self,kind,math.floor((self:getWidth()-64)/2),8,2)
   local caption=R.fit(self.title,self:getWidth()-12);local x=math.floor((self:getWidth()-getTextManager():MeasureStringX(U.Theme.fonts.body,caption))/2)
   text(self,caption,x+1,81,self:getWidth()-12,P.black);text(self,caption,x,80,self:getWidth()-12,P.white);R.focus(self)
  end
 end
 screen.start=button(screen,tr('ComputerStart'),function() menu:setVisible(not menu:isVisible());if menu:isVisible() then menu:bringToTop() end;screen:refreshFocus();setJoypadFocus(num,screen) end)
 screen.task=button(screen,tr('ComputerDesktop'),function() if screen.content then frame:setVisible(not frame:isVisible()) end;menu:setVisible(false);screen:refreshFocus();setJoypadFocus(num,frame:isVisible() and screen.content or screen) end)
 screen.off=button(screen,tr('ComputerPowerOff'),function() screen:close() end)
 screen.power=button(screen,tr('ComputerPowerOff'),function() screen:close() end)
 screen.power.tooltip=tr('ComputerPowerOff');screen.power.prerender=Art.power;screen.power.render=function(self) R.focus(self) end
 frame.minimize=button(frame,'_',function() screen:desktop() end);frame.exit=button(frame,'X',function() screen:closeApp() end)
 menu.drive=button(menu,tr('ComputerDrive'),function() screen:openDrive() end)
 menu.writer=button(menu,tr('ComputerWriter'),function() screen:openWriter() end)
 menu.off=button(menu,tr('ComputerPowerOff'),function() screen:close() end)
 function screen:layoutComputer()
  local w,h=self:getWidth(),self:getHeight()
  if not self.crt or self.crt.windowWidth~=w or self.crt.windowHeight~=h then
   self.crt=Art.geometry(w,h,m.font,m.button);self.crt.windowWidth=w;self.crt.windowHeight=h
  end
  local g=self.crt
  U.Layout.place(desktop,g.x,g.y,g.width,g.desktopHeight)
  local dw,dh=desktop:getWidth(),desktop:getHeight();U.Layout.place(frame,10,10,dw-20,dh-20)
  U.Layout.place(frame.minimize,frame:getWidth()-2*m.button-8,4,m.button,m.button);U.Layout.place(frame.exit,frame:getWidth()-m.button-4,4,m.button,m.button)
  if self.content then U.Layout.place(self.content,4,m.button+8,frame:getWidth()-8,frame:getHeight()-m.button-12) end
  U.Layout.place(self.driveIcon,12,14,math.max(180,m.font*12),m.font+96);U.Layout.place(self.writerIcon,12,m.font+126,math.max(180,m.font*12),m.font+96)
  U.Layout.place(self.start,g.x+4,g.taskY,math.max(90,m.font*5),m.button)
  U.Layout.place(self.off,g.x+g.width-math.max(120,m.font*7)-4,g.taskY,math.max(120,m.font*7),m.button)
  U.Layout.place(self.task,self.start.x+self.start:getWidth()+8,g.taskY,self.off.x-self.start.x-self.start:getWidth()-16,m.button)
  U.Layout.place(self.power,g.powerX,g.powerY,36,34)
  U.Layout.place(menu,4,dh-menu:getHeight()-4,menu:getWidth(),menu:getHeight())
  for i,b in ipairs({menu.drive,menu.writer,menu.off}) do U.Layout.place(b,8,8+(i-1)*(m.button+4),menu:getWidth()-16,m.button) end
  for _,key in ipairs({'closeButton','pinButton','collapseButton','infoButton'}) do if self[key] then self[key]:setVisible(false) end end
 end
 desktop.prerender=Art.desktop
 frame.prerender=function(self)
  rect(self,0,0,self:getWidth(),self:getHeight(),P.grey);bevel(self,0,0,self:getWidth(),self:getHeight())
  rect(self,4,4,self:getWidth()-8,m.button,P.blue);text(self,screen.appTitle or '',10,7,self:getWidth()-2*m.button-26,P.white)
 end
 menu.prerender=function(self) rect(self,0,0,self:getWidth(),self:getHeight(),P.grey);bevel(self,0,0,self:getWidth(),self:getHeight()) end
 screen.prerender=function(self)
  if not require('B47ANCEDQuartermaster/LedgerPolicy').enabled() then self:close();return end
  if getSpecificPlayer(num)~=actor or actor:isDead() or not Media.computer(actor,computer,true) then self:close();return end
  if driveReady then self:refreshDrive() end
  self:layoutComputer();local w,h=self:getWidth(),self:getHeight()
  local g=self.crt;Art.monitor(self,g)
  Art.glass(self,g)
  rect(self,g.x,g.taskY-4,g.width,m.button+8,P.grey)
  rect(self,g.x,g.taskY-4,g.width,2,P.light)
  text(self,status,g.x+6,g.statusY,g.width-12,P.white)
  if self.content and self.content.updateComputer then self.content:updateComputer() end
 end
 screen.render=function(self) if self.resizeWidget then bevel(self,self:getWidth()-24,self:getHeight()-38,10,10) end end
 screen.onJoypadDown=function(self,key) if key==Joypad.BButton then if menu:isVisible() then menu:setVisible(false);self:refreshFocus() elseif frame:isVisible() then self:desktop() else self:close() end else ISPanelJoypad.onJoypadDown(self,key) end end
 C.keyboard(screen,function() if screen.content then screen:closeApp() else screen:onJoypadDown(Joypad.BButton) end end)
 U.bounds(screen,num);screen:addToUIManager();screen:layoutComputer();screen:refreshFocus();setJoypadFocus(num,screen)
 return screen
end
return C
