require 'B47ANCEDUI/Controls'
require 'ISUI/ISCollapsableWindowJoypad'
require 'RadioCom/ISUIRadio/ISSliderPanel'
local Q,U=B47ANCEDQuartermaster,B47ANCEDUI
local V={active={},pending={}}
local function tr(key,...) return getText('UI_QMSS_'..key,...) end
function V.open(num,owner)
 if V.active[num] then return V.active[num] end
 local actor=getSpecificPlayer(num);if not actor or V.pending[num] then return end
 V.pending[num]=actor
 Q.Authority.request(num,'loadGet',{},function(result)
  V.pending[num]=nil
  if getSpecificPlayer(num)~=actor or owner and owner.removed then return end
  if result.status~='ok' then actor:setHaloNote(getText('UI_QMSS_'..result.status));return end
  local p=result.policy;local metrics=U.Theme.metrics();local h=metrics.header+6*metrics.button+76
  if getPlayerScreenWidth(num)<260 or getPlayerScreenHeight(num)<h+20 then actor:setHaloNote(tr('LoadScreenTooSmall'));return end
  local panel=ISCollapsableWindowJoypad:new(0,0,math.min(560,getPlayerScreenWidth(num)-20),h)
  panel.playerNum=num;panel.resizable=true;panel.minimumWidth=240;panel.minimumHeight=h;panel.title=tr('DangerousLoadTitle')
  panel:initialise();panel:instantiate();U.skin(panel,'panel')
  V.active[num]=panel
  local focusRows
  local pending=false;local enabled=p.enabled;local value=p.utilization
  local function close()
   if panel.closed then return end;panel.closed=true;V.active[num]=nil;panel:removeFromUIManager();U.Focus.restore(num,owner)
  end
  panel.close=close
  local toggle=U.Button:new(12,metrics.header,panel:getWidth()-24,metrics.button,'',panel,function()
   if not pending then enabled=not enabled;if focusRows then focusRows() end end
  end)
  local slider=ISSliderPanel:new(12,metrics.header+metrics.button+8,panel:getWidth()-24,metrics.button,panel,function(_,n) value=n end)
  slider:initialise();slider:instantiate();slider:setValues(50,100,5,5,true);slider.currentValue=value
  local save;save=U.Button:new(12,panel:getHeight()-metrics.button-12,(panel:getWidth()-32)/2,metrics.button,tr('SaveLoadPolicy'),panel,function()
   if pending then return end;pending=true;save:setEnable(false)
   Q.Authority.request(num,'loadChange',{revision=p.revision,enabled=enabled,utilization=value},function(reply)
    if panel.closed then return end;pending=false;save:setEnable(true)
    if reply.status=='ok' then close() else actor:setHaloNote(getText('UI_QMSS_'..reply.status)) end
   end)
  end)
  local cancel=U.Button:new(20+(panel:getWidth()-32)/2,panel:getHeight()-metrics.button-12,(panel:getWidth()-32)/2,metrics.button,tr('CancelLoadPolicy'),panel,close)
  for _,b in ipairs({toggle,save,cancel}) do b:initialise();b:instantiate();panel:addChild(b) end
  panel:addChild(slider)
  local function fit(text) return U.Renderer.fit(text,panel:getWidth()-24) end
  local lastW,lastH
  local function layout()
   if lastW==panel:getWidth() and lastH==panel:getHeight() then return end
   lastW,lastH=panel:getWidth(),panel:getHeight()
   toggle:setWidth(lastW-24);slider:setWidth(lastW-24)
   local width=(lastW-32)/2
   save:setWidth(width);save:setY(lastH-metrics.button-12)
   cancel:setX(20+width);cancel:setWidth(width);cancel:setY(lastH-metrics.button-12)
  end
  local pre=panel.prerender
  panel.prerender=function(self,...)
   if getSpecificPlayer(num)~=actor or actor:isDead() then close();return end
   layout();pre(self,...)
   toggle:setTitle(tr(enabled and 'DangerousLoadOn' or 'DangerousLoadOff'))
   slider:setVisible(enabled)
   local y=metrics.header+2*metrics.button+22
   U.Renderer.text(self,tr('LoadUtilization',value),12,y,U.Theme.colors.text)
   U.Renderer.text(self,fit(tr('LoadNativeSnapshot',result.current,result.hard)),12,y+metrics.font+6,U.Theme.colors.text)
   U.Renderer.text(self,fit(tr('LoadPenalties')),12,y+2*(metrics.font+6),U.Theme.colors.text)
  end
  toggle.tooltip=tr('DangerousLoadHelp');slider.tooltip=tr('LoadUtilizationHelp')
  panel.toggle,panel.slider,panel.save,panel.cancel=toggle,slider,save,cancel
  focusRows=function()
  slider:setVisible(enabled)
  panel.joypadButtonsY={};panel.allJoypadButtons={};panel.joypadButtons={};panel.joypadIndexY=1;panel.joypadIndex=1
  panel:insertNewLineOfButtons(toggle);if enabled then panel:insertNewLineOfButtons(slider) end;panel:insertNewLineOfButtons(save,cancel)
  end
  focusRows()
  local joy=panel.onJoypadDown
  panel.onJoypadDown=function(self,key,...) if key==Joypad.BButton then close() elseif joy then joy(self,key,...) end end
  panel:setX(getPlayerScreenLeft(num)+10);panel:setY(getPlayerScreenTop(num)+10)
  U.bounds(panel,num);panel:addToUIManager();setJoypadFocus(num,panel)
 end)
end
return V
