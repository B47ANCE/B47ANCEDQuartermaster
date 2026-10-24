local U=require 'B47ANCEDQuartermaster/UIProvider'
require 'ISUI/ISComboBox'
local Q=B47ANCEDQuartermaster;local V={}
local function tr(k,...) return getText('UI_QMSS_'..k,...) end
function V.open(num,owner,source,host,knownRooms,preferred)
 local actor=getSpecificPlayer(num);if not actor then return end
 local m=U.Theme.metrics();local w=math.min(800,getPlayerScreenWidth(num)-24);local h=math.min(math.max(560,18*m.font),getPlayerScreenHeight(num)-24)
 if w<480 or h<8*m.button+4*m.font then actor:setHaloNote(tr('LedgerScreenSmall'));return end
 local p=host and host:view(tr('StockTitle')) or U.WindowShell:new(0,0,w,h)
 if not host then p.playerNum=num;p.title=tr('StockTitle');p.minimumWidth=480;p.minimumHeight=8*m.button+4*m.font;p.resizable=true;p:initialise();p:instantiate() end
 local pc=host and require('B47ANCEDPCFramework/ComputerUI')
 local colors=host and {text=pc.colors.black,selected=pc.colors.blue,selectedText=pc.colors.white,window=pc.colors.grey} or {text=U.Theme.colors.text,selected=U.Theme.colors.selected,selectedText=U.Theme.colors.text,window=U.Theme.colors.window}
 if not host then Q.UI.popup(p,tr('StockTitle')) end
 local originalPrerender=p.prerender
 local pending=false;local closed=false;local generation=0;local due=0;local current;local data={targets={},revision=0};local rows={};local selected
 local function add(widget,kind)
  widget:initialise();widget:instantiate();p:addChild(widget)
  if host then pc.decorate(widget,kind or 'panel') else U.skin(widget,kind) end
  return widget
 end
 local function button(key,fn) return add(U.Button:new(0,0,120,m.button,tr(key),p,fn),'button') end
 local status=add(ISLabel:new(0,0,m.font,'',colors.text.r,colors.text.g,colors.text.b,1,U.Theme.fonts.body,true))
 local refresh
 local scopes=add(ISComboBox:new(0,0,240,m.button,p,function(_,combo)
  local row=combo.options[combo.selected];current=row and row.data;selected=nil;generation=generation+1;pending=false;due=0;if refresh then refresh() end
 end))
 local list=add(U.ScrollList:new(0,0,w-24,220));list.itemheight=m.font+10;list.drawBorder=true
 list.doDrawItem=function(self,y,row)
  local t=row.item;local color=self.selected==row.index and colors.selectedText or colors.text
  if self.selected==row.index then U.Renderer.rect(self,0,y,self:getWidth()-m.scrollbar,self.itemheight,colors.selected) end
  local width=self:getWidth()-m.scrollbar;U.Renderer.text(self,U.Renderer.fit(t.name,width*.45-12),6,y+4,color)
  U.Renderer.text(self,t.current~=nil and tostring(t.current) or '—',width*.46,y+4,color)
  U.Renderer.text(self,tostring(t.target),width*.62,y+4,color)
  U.Renderer.text(self,t.remaining~=nil and tostring(t.remaining) or '—',width*.79,y+4,color)
  return y+self.itemheight
 end
 local quantity=host and require('B47ANCEDPCFramework/UI').textEntry(p,{value='1',width=100,height=m.button})
  or add(U.NumberInput:new('1',0,0,100,m.button),'input')
 quantity:setTooltip(tr('StockQuantityHelp'))
 list.onJoypadDown=function(self,key) if key==Joypad.AButton then local row=self.items[self.selected];if row then self.onmousedown(p,row.item) end elseif key==Joypad.BButton then setJoypadFocus(num,p) end end
 list.target=p;list.onmousedown=function(_,row) selected=row.fullType;quantity:setText(tostring(row.target)) end
 local function render(result)
  if host and source then
   local api=require('B47ANCEDPCFramework/API').Notifications
   if api then
    local lines={};for _,row in ipairs(result.rows or {}) do if row.remaining>0 and #lines<3 then lines[#lines+1]=tr('StockLowItem',row.name,row.current,row.target) end end
    local message=table.concat(lines,'; ');if #message>500 then local n=497;while n>0 and message:byte(n+1)>=128 and message:byte(n+1)<192 do n=n-1 end;message=message:sub(1,n)..'...' end
    if result.canNotify and #message>0 and #message<=512 then api.post(host,{id='stock.low',title=tr('StockLowTitle'),message=message,severity='warning',silent=p.stockLow==true,onOpen=function() if not closed then setJoypadFocus(num,list) end end});p.stockLow=true
    else api.dismiss(host,'stock.low');p.stockLow=false end
   end
  end
  data=result;if not source and result.scope then current=result.scope end;rows=result.rows or {};list:clear()
  if not source then for t,target in pairs(result.targets or {}) do local script=getScriptManager():FindItem(t);rows[#rows+1]={fullType=t,name=script and script:getDisplayName() or t,target=target} end end
  table.sort(rows,function(a,b) return a.name==b.name and a.fullType<b.fullType or a.name<b.name end)
  for _,row in ipairs(rows) do list:addItem(row.name,row) end
  status:setName(tr(source and (result.live and 'StockLive' or result.complete and 'StockSnapshot' or 'StockIncomplete') or 'StockSetupHelp'))
 end
 local function change(t,n)
  if source or pending or not current or not data.canEdit then return end
  pending=true;local token=generation
  local args={kind=current.kind,id=current.id,roomRevision=current.roomRevision,scopeKey=data.scope and data.scope.key or current.key,revision=data.revision,fullType=t,quantity=n}
  Q.Authority.request(num,'stockSet',args,function(r)
   if closed or token~=generation or getSpecificPlayer(num)~=actor then return end;pending=false
   if r.status=='ok' then render(r) else status:setName(tr(r.status));due=getTimestampMs()+1000 end
  end)
 end
 local addItem=button('StockAdd',function()
  require('B47ANCEDQuartermaster/ItemPicker').open(num,'stock',function(row) if not closed then change(row.fullType,row.quantity) end end,p)
 end)
 local save=button('StockSetMinimum',function() local n=tonumber(quantity:getInternalText());if selected and n and n%1==0 and n>=1 and n<=1000000 then change(selected,n) end end)
 local remove=button('RemoveSelected',function() if selected then change(selected,0) end end)
 local close=button('LedgerClose',function() p:close() end)
 refresh=function()
  if not current or pending or closed then return end;pending=true;local token=generation
  local args={kind=current.kind,id=current.id,roomRevision=current.roomRevision,scopeKey=current.key}
  if source then
   for k,v in pairs(source) do args[k]=v end;args.stockKind=current.kind;args.stockRoom=current.id;args.stockBuilding=current.building
  end
  Q.Authority.request(num,source and 'ledgerStock' or 'stockGet',args,function(result)
   if closed or token~=generation or getSpecificPlayer(num)~=actor then return end;pending=false
   if result.status=='waiting' then due=getTimestampMs()+500;status:setName(tr(result.summary or 'StockLoading'));return end
   due=getTimestampMs()+(result.interval or 30)*1000
   if result.status=='ok' then render(result) else
    list:clear();status:setName(tr(result.status))
    if host then local api=require('B47ANCEDPCFramework/API').Notifications;if api then api.dismiss(host,'stock.low') end end
   end
  end)
 end
 local function options(values)
  scopes:clear();for _,scope in ipairs(values) do scopes:addOptionWithData(scope.label or tr(scope.kind=='room' and 'StockRoom' or 'StockBuilding'),scope) end
  if preferred then for n,row in ipairs(scopes.options) do local value=row.data;if value.kind==preferred.kind and value.id==preferred.id and value.building==preferred.building then scopes.selected=n;break end end end
  current=scopes.options[scopes.selected] and scopes.options[scopes.selected].data;refresh()
 end
 local originalClose=p.close
 function p:updateComputer() if not closed and not pending and getTimestampMs()>=due then refresh() end end
 function p:close()
  if closed then return end;closed=true;if host then local api=require('B47ANCEDPCFramework/API').Notifications;if api then api.dismiss(host,'stock.low') end end;generation=generation+1;U.Tooltip.dispose(self)
  if host then originalClose(self) else self:removeFromUIManager();if owner and not owner.removed then setJoypadFocus(num,owner) else U.Focus.restore(num) end end;self.closed=true
 end
 p.prerender=function(self)
  if closed or getSpecificPlayer(num)~=actor or actor:isDead() or source and not host and not require('B47ANCEDQuartermaster/LedgerMedia').owned(actor,source.item) then self:close();return end
  local width,height=self:getWidth(),self:getHeight();local top=host and 8 or m.header+8
  if not host and originalPrerender then originalPrerender(self) end
  U.Layout.place(scopes,12,top,width-24,m.button);U.Layout.place(status,12,top+m.button+8,width-24,m.font+4)
  local header=top+m.button+m.font+20;local bottom=height-2*m.button-28
  local labels={'StockItem','StockCurrent','StockTarget','StockRemaining'};local xs={.01,.46,.62,.79}
  for n,key in ipairs(labels) do U.Renderer.text(self,U.Renderer.fit(tr(key),(width-24)*(n==1 and .43 or .15)),12+(width-24)*xs[n],header,colors.text) end
  U.Layout.place(list,12,header+m.font+8,width-24,math.max(m.button,bottom-header-m.font-16));U.Layout.scrollbar(list)
  local bw=(width-48)/3;U.Layout.place(addItem,12,bottom,bw,m.button);U.Layout.place(save,24+bw,bottom,bw,m.button);U.Layout.place(remove,36+2*bw,bottom,bw,m.button)
  U.Layout.place(quantity,12,height-m.button-12,math.min(140,width/3),m.button);U.Layout.place(close,width-132,height-m.button-12,120,m.button)
  for _,widget in ipairs({addItem,quantity,save,remove}) do widget:setVisible(not source) end
  addItem:setEnable(not pending and data.canEdit==true);save:setEnable(not pending and data.canEdit==true and selected~=nil);remove:setEnable(not pending and data.canEdit==true and selected~=nil)
  self:updateComputer()
 end
 p.joypadButtonsY={};p.joypadButtons={};p.allJoypadButtons={};p.joypadIndexY=1;p.joypadIndex=1
 p:insertNewLineOfButtons(scopes);p:insertNewLineOfButtons(list);if source then p:insertNewLineOfButtons(close) else p:insertNewLineOfButtons(addItem,quantity,save,remove,close) end
 p.onJoypadDown=function(self,key) if key==Joypad.BButton then self:close() else ISPanelJoypad.onJoypadDown(self,key) end end
 p:setWantKeyEvents(true);p.isKeyConsumed=function(_,key) return num==0 and key==Keyboard.KEY_ESCAPE end
 p.onKeyRelease=function(self,key) if self:isKeyConsumed(key) then self:close() end end
 p.stockControls={scopes=scopes,list=list,quantity=quantity,add=addItem,save=save,remove=remove,close=close,status=status}
 if source then
  local values={{kind='building',label=tr('StockBuilding')}}
  for _,row in ipairs(knownRooms or {}) do if row.building then values[#values+1]={kind='building',building=row.building,label=row.name} elseif row.id and row.id~='' and not row.id:find('^unassigned:') then values[#values+1]={kind='room',id=row.id,label=row.name} end end
  options(values)
 else Q.Authority.request(num,'stockOptions',{},function(r) if not closed then if r.status=='ok' then options(r.scopes or {}) else status:setName(tr(r.status)) end end end) end
 if not host then U.bounds(p,num);p:addToUIManager();setJoypadFocus(num,p) end
 return p
end
return V
