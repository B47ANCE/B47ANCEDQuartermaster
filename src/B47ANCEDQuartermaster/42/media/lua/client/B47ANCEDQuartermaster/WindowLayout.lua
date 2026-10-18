local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
-- Player-local presentation geometry. No ModData, taxonomy or network access.
require 'ISUI/ISPanel'
local Q,U=B47ANCEDQuartermaster,SharedUI
local G={};Q.WindowLayout=G
local function valid(n) return type(n)=='number' and n==n and n~=math.huge and n~=-math.huge end
local function clamp(n,a,b) return math.max(a,math.min(b,n)) end
local function tr(k) return getText('UI_QMSS_'..k) end
function G.viewport(p)
 local i=p.playerNum or 0
 return getPlayerScreenLeft and getPlayerScreenLeft(i) or 0,getPlayerScreenTop and getPlayerScreenTop(i) or 0,
  getPlayerScreenWidth and getPlayerScreenWidth(i) or 1280,getPlayerScreenHeight and getPlayerScreenHeight(i) or 900
end
function G.minimum()
 local t=U.Theme.metrics()
 -- Rail includes scope/three actions; main panel includes priority and four action cells.
 return math.max(640,t.rail+math.max(420,t.font*18)+32),math.max(460,t.header+2*t.tab+5*t.button+2*t.row+t.font+10*t.gap)
end
function G.railWidth(p,width)
 local w=width or p:getWidth();local t=U.Theme.metrics();local main=math.max(300,t.font*12)
 local lo=math.min(t.rail,math.max(80,w-main-32));local hi=math.max(lo,w-main-32)
 local ratio=valid(p.b47Divider) and p.b47Divider or t.rail/math.max(1,w)
 return clamp(w*ratio,lo,hi)
end
function G.save(p)
 local x,y=(p.getX and p:getX() or p.x),(p.getY and p:getY() or p.y);local w,h=p:getWidth(),p:getHeight()
 if not valid(x) or not valid(y) or not valid(w) or not valid(h) then return end
 if getFileWriter then
  local ok,writer=pcall(getFileWriter,'B47ANCEDQuartermasterWindow'..(p.playerNum or 0)..'.txt',true,false)
  if ok and writer then pcall(function() writer:write(table.concat({x,y,w,h,p.b47Divider or U.Theme.metrics().rail/w},'\n')..'\n');writer:close() end) end
 end
end
function G.bounds(p,w,h,x,y)
 local vx,vy,vw,vh=G.viewport(p);local mw,mh=G.minimum()
 p.minimumWidth,p.minimumHeight=math.min(mw,vw),math.min(mh,vh)
 w=clamp(valid(w) and w or 1120,p.minimumWidth,vw);h=clamp(valid(h) and h or 780,p.minimumHeight,vh)
 x=clamp(valid(x) and x or vx+20,vx,vx+vw-w);y=clamp(valid(y) and y or vy+20,vy,vy+vh-h)
 p:setWidth(w);p:setHeight(h);p:setX(x);p:setY(y)
 p.b47Divider=G.railWidth(p,w)/w
end
function G.restore(p)
 local values={}
 if getFileReader then
  local ok,reader=pcall(getFileReader,'B47ANCEDQuartermasterWindow'..(p.playerNum or 0)..'.txt',true)
  if ok and reader then pcall(function() for i=1,5 do values[i]=tonumber(reader:readLine()) end;reader:close() end) end
 end
 p.b47Divider=valid(values[5]) and values[5] or U.Theme.metrics().rail/1120
 G.bounds(p,values[3],values[4],values[1],values[2])
end
function G.change(p,action)
 if action=='reset' then p.b47Divider=U.Theme.metrics().rail/1120;G.bounds(p,1120,780,nil,nil)
 elseif action=='railLess' or action=='railMore' then
  p.b47Divider=(G.railWidth(p)+(action=='railMore' and 32 or -32))/p:getWidth();p.b47Divider=G.railWidth(p)/p:getWidth()
 else
  local d=action=='smaller' and -64 or 64
  G.bounds(p,p:getWidth()+d,p:getHeight()+d,(p.getX and p:getX() or p.x),(p.getY and p:getY() or p.y))
 end
 p:layout();p:configJoypad();G.save(p)
end
function G.menu(p)
 local menu=ISContextMenu.get(p.playerNum,(p.getX and p:getX() or p.x)+p:getWidth()-160,(p.getY and p:getY() or p.y)+U.Theme.metrics().header)
 menu.origin=p -- Native context-menu B/action restoration uses origin.
 for _,row in ipairs({{'WindowLarger','larger'},{'WindowSmaller','smaller'},{'ContainerPanelWider','railMore'},{'ContainerPanelNarrower','railLess'},{'ResetWindowLayout','reset'},{'WindowAppearance','appearance'}}) do
  menu:addOption(tr(row[1]),p,function(owner) if row[2]=='appearance' then require 'B47ANCEDQuartermaster/AppearanceUI';Q.AppearanceUI.open(owner) else G.change(owner,row[2]) end end)
 end
 if setJoypadFocus then setJoypadFocus(p.playerNum,menu) end
end
function G.attach(p)
 if p.b47Geometry then return end;p.b47Geometry=true
 local b=U.Button:new(0,0,30,30,tr('LayoutShort'),p,function(owner) G.menu(owner) end)
 b:initialise();b:instantiate();p:addChild(b);b:setTooltip(tr('WindowLayoutTip'));p.b47LayoutButton=b
 local divider=ISPanel:new(0,0,8,100);divider:initialise();divider:instantiate();p:addChild(divider);p.b47DividerWidget=divider
 divider.prerender=function(self) if self:getIsVisible() then U.Renderer.rect(self,3,0,2,self:getHeight(),U.Theme.colors.border) end end
 divider.onMouseDown=function(self) self.dragging=true;self.down=self:getMouseX()+self.x;self.start=G.railWidth(p);if self.setCapture then self:setCapture(true) end;return true end
 local function move(self) if self.dragging then p.b47Divider=(self.start+self:getMouseX()+self.x-self.down)/p:getWidth();p.b47Divider=G.railWidth(p)/p:getWidth();p:layout() end end
 divider.onMouseMove=move;divider.onMouseMoveOutside=move
 local function finish(self) self.dragging=false;if self.setCapture then self:setCapture(false) end;G.save(p);return true end
 divider.onMouseUp=finish;divider.onMouseUpOutside=finish
 for _,widget in ipairs({p.resizeWidget or false,p.resizeWidget2 or false}) do
  if widget then
   widget.resizeFunction=function(owner,w,h) G.bounds(owner,w,h,owner:getX(),owner:getY());owner:layout() end
   local up,out=widget.onMouseUp,widget.onMouseUpOutside
   widget.onMouseUp=function(self,...) local result=up(self,...);G.save(p);return result end
   widget.onMouseUpOutside=function(self,...) local result=out(self,...);G.save(p);return result end
  end
 end
 local close=p.closePicker
 p.closePicker=function(self,...) if self.b47AppearanceDialog and not self.b47AppearanceDialog.closed then self.b47AppearanceDialog.close() end;G.save(self);divider.dragging=false;if divider.setCapture then divider:setCapture(false) end;return close(self,...) end
 p.close=p.closePicker
 local pre=p.prerender
 p.prerender=function(self,...)
  local vx,vy,vw,vh=G.viewport(self);local font=U.Theme.metrics().font
  if self.b47VX~=vx or self.b47VY~=vy or self.b47VW~=vw or self.b47VH~=vh or self.b47VF~=font then G.bounds(self,self:getWidth(),self:getHeight(),(self.getX and self:getX() or self.x),(self.getY and self:getY() or self.y));self.b47VX,self.b47VY,self.b47VW,self.b47VH,self.b47VF=vx,vy,vw,vh,font;self:layout() end
  -- Native title dragging may leave the owning split-screen viewport.
  local x=clamp((self.getX and self:getX() or self.x),vx,vx+vw-self:getWidth());local y=clamp((self.getY and self:getY() or self.y),vy,vy+vh-self:getHeight())
  if x~=(self.getX and self:getX() or self.x) then self:setX(x) end;if y~=(self.getY and self:getY() or self.y) then self:setY(y) end
  return pre(self,...)
 end
end
return G
