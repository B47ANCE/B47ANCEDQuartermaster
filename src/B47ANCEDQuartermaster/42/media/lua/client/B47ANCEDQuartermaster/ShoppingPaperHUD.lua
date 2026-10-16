-- Local held-paper presentation. Only the server supplies list contents/counts.
require 'ISUI/ISPanel'
require 'B47ANCEDQuartermaster/Authority'
local Q=B47ANCEDQuartermaster
local H={active={},nextTick=0};Q.ShoppingPaperHUD=H
local kind='B47ANCEDQuartermaster.ShoppingPaper'
local function tr(k,...) return getText('UI_QMSS_'..k,...) end
function H.held(actor)
 if require('B47ANCEDQuartermaster/ShoppingLists').enabled()==false or not actor or actor:isDead() then return end
 local a,b=actor:getPrimaryHandItem(),actor:getSecondaryHandItem()
 if a and a:getFullType()==kind then return a end
 if b and b:getFullType()==kind then return b end
end
function H.clear(num)
 local e=H.active[num];if e and e.panel then e.panel:removeFromUIManager() end;H.active[num]=nil
end
local function valid(num,e) return getSpecificPlayer(num)==e.actor and H.held(e.actor)==e.item end
local function panel(num,e)
 local p=ISPanel:new(0,0,300,220);p:initialise();p:instantiate()
 p.background=false;p.border=false;p:setWantMouseEvents(false);p:setWantKeyEvents(false);p:setCapture(false);p:setRenderThisPlayerOnly(num)
 function p:prerender()
  if not valid(num,e) then return end
  local U=B47ANCEDUI;local font=UIFont.Small;local fh=getTextManager():getFontHeight(font);local row=fh+9
  local vw,vh=getPlayerScreenWidth(num),getPlayerScreenHeight(num)
  local width=math.min(350,vw-20);local available=math.max(1,math.min(8,math.floor((vh-160)/row)))
  local state=e.snapshot;local rows=state and state.requirements or {};local page=math.floor(getTimestampMs()/6000)%math.max(1,math.ceil(#rows/available))
  local first=page*available+1;local count=math.max(1,math.min(available,#rows-first+1));local height=(count+3)*row+16
  self:setX(getPlayerScreenLeft(num)+vw-width-18);self:setY(getPlayerScreenTop(num)+math.max(10,vh-height-92));self:setWidth(width);self:setHeight(height)
  self:drawRect(0,0,width,height,.96,.91,.88,.73)
  -- Uneven cut edges and notebook ruling are original Lua geometry.
  for x=0,width-6,6 do self:drawRect(x,x%12==0 and -3 or -1,6,4,.96,.91,.88,.73) end
  self:drawRect(24,8,1,height-16,.45,.64,.24,.22)
  local name=state and state.paper and state.paper.lists or {};local title=tr('ShoppingList')
  for _,v in ipairs(name) do if v.item==e.item:getID() then title=v.name end end
  local function text(s,y,color) self:drawText(U.Renderer.fit(s,width-45,font),32,y,color or .18,.18,.15,1,font) end
  text(title,10)
  if not state then text(tr(e.status or 'ShoppingPaperLoading'),10+row)
  elseif #rows==0 then text(tr(state.shoppingBlocked or 'ShoppingPaperEmpty'),10+row)
  else
   for i=first,math.min(#rows,first+available-1) do
    local data=rows[i];local names={}
    for n,t in ipairs(data.alternatives or {}) do if n<=2 then local s=getScriptManager():FindItem(t);names[#names+1]=s and s:getDisplayName() or t end end
    local y=10+(i-first+1)*row
    self:drawRect(28,y+fh+3,width-40,1,.23,.29,.43,.54)
    text(tr('ShoppingPaperHUDRow',table.concat(names,' / '),data.carried,data.gross,data.outstanding),y)
   end
  end
  if state then text(tr('ShoppingPaperHUDTotal',state.carried or 0,state.gross or 0,state.outstanding or 0),height-2*row)
   if #rows>available then text(tr('ShoppingPaperHUDPage',page+1,math.ceil(#rows/available)),height-row) end
  end
 end
 p:addToUIManager();return p
end
function H.tick()
 local now=getTimestampMs();if now<H.nextTick then return end;H.nextTick=now+250
 for num=0,3 do
  local actor=getSpecificPlayer(num);local item=H.held(actor);local e=H.active[num]
  if e and (e.actor~=actor or e.item~=item) then H.clear(num);e=nil end
  if item then
   if not e then e={actor=actor,item=item,nextRead=0};H.active[num]=e;e.panel=panel(num,e) end
   if not e.pending and now>=e.nextRead then
    e.pending=true;e.nextRead=now+1500
    Q.Authority.request(num,'shoppingPaperRead',{item=item:getID()},function(result)
     if H.active[num]~=e or not valid(num,e) then return end
     e.pending=false
     if result.status=='ok' then e.snapshot=result;e.status=nil
     else e.snapshot=nil;e.status=result.status end
    end)
   end
  end
 end
end
function H.close() for num in pairs(H.active) do H.clear(num) end end
if Events then
 if Events.OnTick then Events.OnTick.Add(H.tick) end
 if Events.OnDisconnect then Events.OnDisconnect.Add(H.close) end
 if Events.OnMainMenuEnter then Events.OnMainMenuEnter.Add(H.close) end
end
return H
