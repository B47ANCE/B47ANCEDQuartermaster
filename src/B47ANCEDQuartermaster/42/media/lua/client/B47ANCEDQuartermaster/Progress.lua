-- Local presentation only: the native current-action bar and job execution are untouched.
require 'ISUI/ISProgressBar'
local P={active={},bars={}}
local function finite(n) return type(n)=='number' and n==n and n>=0 and n<math.huge end
local function valid(entry,num)
 return getSpecificPlayer(num)==entry.actor and not entry.actor:isDead() and entry.owns(entry.record)
end
function P.clear(num,record)
 local entry=P.active[num]
 if not entry or record and entry.record~=record then return end
 P.active[num]=nil
 local bar=P.bars[num];P.bars[num]=nil
 if bar then bar.closed=true;bar:removeFromUIManager() end
end
function P.start(num,record,read,owns)
 P.clear(num)
 local actor=getSpecificPlayer(num)
 if actor then P.active[num]={actor=actor,record=record,read=read,owns=owns} end
end
local function create(num,entry)
 local actor=entry.actor
 local bar=ISProgressBar:new(0,0,180,20,nil,UIFont.Small)
 bar:initialise();bar:setWantMouseEvents(false);bar:setWantKeyEvents(false)
 function bar:prerender()
  if self.closed then return end
  if P.active[num]~=entry or not valid(entry,num) then P.clear(num,entry.record);return end
  local zoom=getCore():getZoom(num)
  if not finite(zoom) or zoom==0 then return end
  local tm=getTextManager();local line=tm:getFontFromEnum(self.font):getLineHeight()
  self.textH=line;self.textW=tm:MeasureStringX(self.font,self.text or '')
  local vw,vh=getPlayerScreenWidth(num),getPlayerScreenHeight(num)
  local width=math.min(vw-8,math.max(180,self.textW+16));local height=line+6
  local x=isoToScreenX(num,actor:getX(),actor:getY(),actor:getZ())-getPlayerScreenLeft(num)-width/2
  local y=isoToScreenY(num,actor:getX(),actor:getY(),actor:getZ())-getPlayerScreenTop(num)-140/zoom-3*line-height
  if width<=0 or x<0 or x+width>vw or y<0 or y+height>vh then return end
  self:setX(x);self:setY(y);self:setWidth(width);self:setHeight(height)
  self:setStencilRect(0,0,width,height);ISProgressBar.prerender(self);self:clearStencilRect()
 end
 bar:addToUIManager();bar:setCapture(false);bar:setFollowGameWorld(true);bar:setRenderThisPlayerOnly(num)
 P.bars[num]=bar;return bar
end
function P.tick()
 for num,entry in pairs(P.active) do
  if not valid(entry,num) then P.clear(num,entry.record)
  else
   local state=entry.read(entry.record) or {};local bar=P.bars[num] or create(num,entry)
   local known=state.known==true and finite(state.total) and finite(state.completed) and state.completed<=state.total
   local fraction=known and state.total>0 and state.completed/state.total or 0
   local name=getText(state.label or 'UI_B47_ProgressSort')
   bar:setText(known and getText('UI_B47_ProgressCount',name,math.floor(100*fraction)) or getText('UI_B47_ProgressPreparing',name))
   bar:setProgress(fraction)
  end
 end
end
function P.close() for num in pairs(P.active) do P.clear(num) end end
if Events and Events.OnTick then Events.OnTick.Add(P.tick) end
if Events and Events.OnDisconnect then Events.OnDisconnect.Add(P.close) end
if Events and Events.OnMainMenuEnter then Events.OnMainMenuEnter.Add(P.close) end
return P
