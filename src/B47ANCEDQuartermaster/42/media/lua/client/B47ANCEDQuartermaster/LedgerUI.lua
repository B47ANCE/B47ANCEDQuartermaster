local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
require 'ISUI/ISComboBox'
require 'TimedActions/ISTimedActionQueue'
require 'TimedActions/WalkToTimedAction'
require 'B47ANCEDQuartermaster/Authority'
local L=require 'B47ANCEDQuartermaster/Ledger'
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local Policy=require 'B47ANCEDQuartermaster/LedgerPolicy'
local Program=require 'B47ANCEDQuartermaster/LedgerProgram'
local Action=require 'B47ANCEDQuartermaster/LedgerAction'
local Computer=require 'B47ANCEDQuartermaster/ComputerUI'
local LedgerTable=require 'B47ANCEDQuartermaster/LedgerTable'
local Clipboard=require 'B47ANCEDQuartermaster/ClipboardArt'
local U,Q=SharedUI,B47ANCEDQuartermaster
local V={work={},readers={}};Q.LedgerUI=V
local function tr(key,...) return getText('UI_QMSS_'..key,...) end
local function note(actor,status) actor:setHaloNote(tr(status)) end
local function queue(actor) return ISTimedActionQueue.getTimedActionQueue(actor).queue end
function V.cancel(num)
 local op=V.work[num];if not op then return end
 V.work[num]=nil;op.closed=true
 if getSpecificPlayer(num)==op.actor then
  local current=queue(op.actor)[1]
  if current and current.b47LedgerWork==op and current.action then current:forceStop() end
  if not op.install or op.token then Q.Authority.request(num,'ledgerCancel',{token=op.token},function() end) end
 end
 if op.token then L.clientOffers[op.token]=nil end
end
local function finish(op,status,abortNative)
 if op.closed then return end
 op.closed=true;V.work[op.num]=nil
 if op.token then L.clientOffers[op.token]=nil end
 if not op.install and status~='ok' and status~='done' and status~='ShoppingPaperCreated' and status~='ShoppingPaperSyncPending' and status~='LedgerDiscUpdated' and status~='LedgerDiscSyncPending' then Q.Authority.request(op.num,'ledgerCancel',{},function() end) end
 if abortNative then
  -- Close first so native stop/result callbacks cannot complete work twice.
  if op.install and op.token then Q.Authority.request(op.num,'ledgerCancel',{token=op.token},function() end) end
  local current=queue(op.actor)[1]
  if current and current.b47LedgerWork==op and current.action then current:forceStop() end
 end
 local key=status=='ok' and 'LedgerSaved' or status=='done' and (op.summary or 'LedgerComplete') or status
 local screen=op.host or Computer.active[op.num]
 if (op.burn or op.install) and screen and not screen.closed and screen.application=='quartermaster' then screen:message(key) end
 note(op.actor,key)
 if op.callback then op.callback(status,key) end
end
local function atOrigin(op)
 local sq=op.actor:getCurrentSquare();local p=op.origin
 return sq and sq:getX()==p.x and sq:getY()==p.y and sq:getZ()==p.z
end
local function resumeSort(op)
 op.returning=nil;op.sortPreparing=false;op.sorting=true
 local ok,status=op.continueSort()
 if not ok then finish(op,status or 'busy') end
end
local function response(op,result)
 if op.closed or getSpecificPlayer(op.num)~=op.actor then
  if result.status=='pickup' and result.offer then Q.Authority.request(op.num,'moveCancel',{operation=result.offer.operation,outcome='notSubmitted'},function() end) end
  if result.status=='action' and result.token then Q.Authority.request(op.num,'ledgerCancel',{token=result.token},function() end) end
  return
 end
 op.pending=false;op.at=getTimestampMs()+250
 if op.sort and result.status=='ready' then
  if atOrigin(op) then resumeSort(op)
  elseif not op.pickedUp then finish(op,'LedgerChanged')
  else
   local p=op.origin;local sq=getCell():getGridSquare(p.x,p.y,p.z)
   if not sq or #queue(op.actor)>0 then finish(op,'LedgerUnreachable');return end
   op.returning=true;op.returnStarted=getTimestampMs()
   local walk=ISWalkToTimedAction:new(op.actor,sq);walk.b47LedgerWork=op
   function walk:isValid() return not op.closed and ISWalkToTimedAction.isValid(self) end
   walk:setOnComplete(function() if not op.closed then op.returned=true end end)
   function walk:stop() finish(op,'cancelled');ISWalkToTimedAction.stop(self) end
   function walk:forceCancel() finish(op,'cancelled') end
   ISTimedActionQueue.add(walk)
  end
  return
 end
 if op.sort and result.status=='pickup' then
  op.actionPending=true
  if not Q.Executor.acceptOffer(op.num,result.offer,function(status)
   if op.closed then return end
   op.actionPending=false;op.at=getTimestampMs()+250
   if status~='ok' then finish(op,status) else op.pickedUp=true end
  end) then op.actionPending=false;finish(op,'busy') end
  return
 end
 if result.status=='ok' or result.status=='waiting' then if result.target then op.target=result.target end;return end
 if result.status=='walk' then
  if op.lastWalk==result.target then op.walks=op.walks+1 else op.lastWalk=result.target;op.walks=1 end
  if op.walks>3 then finish(op,'LedgerUnreachable');return end
  local p=result.position;local sq=getCell():getGridSquare(p.x,p.y,p.z)
  if not sq then finish(op,'LedgerUnreachable');return end
  local before=#queue(op.actor)
  if not luautils.walkAdj(op.actor,sq) then finish(op,'LedgerUnreachable');return end
  for n=before+1,#queue(op.actor) do queue(op.actor)[n].b47LedgerWork=op end
  op.target=result.target;return
 end
 if result.status=='action' then
  if #queue(op.actor)>0 then finish(op,'busy');return end
  op.token=result.token;op.actionPending=true
  L.clientOffers[result.token]={actor=op.actor,seconds=result.seconds,kind=result.kind,paper=result.paper}
  local action=Action:new(op.actor,result.token)
  if not action then finish(op,'failed');return end
  action.b47LedgerWork=op;ISTimedActionQueue.add(action);return
 end
 if result.status=='LedgerChanged' and not op.sort then
  op.changed=(op.changed or 0)+1
  if op.changed<=3 then return end
 end
 op.summary=result.summary;finish(op,result.status)
end
local function nativeResult(actor,result)
 local num=actor:getPlayerNum();local op=V.work[num]
 if not op or op.token~=result.token then return end
 L.clientOffers[result.token]=nil;op.token=nil;op.actionPending=false;op.target=nil;op.at=getTimestampMs()+250
 if op.sort then finish(op,result.status);return end
 if result.status=='LedgerChanged' then op.changed=(op.changed or 0)+1;if op.changed<=3 then return end end
 if result.status=='ShoppingPaperCreated' then finish(op,result.status) elseif result.status~='ok' then finish(op,result.status) elseif op.burn then finish(op,'ok') end
end
L.clientResult=nativeResult
function V.prepareSort(num,continueSort,failed)
 if V.work[num] then return false,'busy' end
 local actor=getSpecificPlayer(num);if not actor or #queue(actor)>0 then return false,'busy' end
 local sq=actor:getCurrentSquare();if not sq then return false,'LedgerScopeUnavailable' end
 V.work[num]={actor=actor,num=num,origin={x=sq:getX(),y=sq:getY(),z=sq:getZ()},sort=true,sortPreparing=true,continueSort=continueSort,callback=failed,at=0}
 note(actor,'SortLedgerSearching');return true
end
function V.sortFinished(num,status,callback)
 local op=V.work[num]
 if not op or not op.sort then callback(status);return end
 op.callback=function(result,key)
  -- Native item moves have already completed. Report the later writing outcome
  -- separately; a canceled/failed note does not undo successful transfers.
  callback(op.sortWriting and 'ok' or result,op.sortWriting and (key or result) or nil)
 end
 if status~='ok' then finish(op,status);return end
 op.sorting=false;op.sortWriting=true;op.at=0;note(op.actor,'SortLedgerWriting')
end
function V.cancelSort(num)
 local op=V.work[num];if not op or not op.sort then return end
 V.cancel(num)
 Q.Executor.cancel(num)
 if op.callback then op.callback('cancelled') end
end
function V.record(num,item,scope)
 if V.work[num] then return end
 local actor=getSpecificPlayer(num);if not actor or #queue(actor)>0 then return end
 local op={actor=actor,num=num,pending=true,at=getTimestampMs()};V.work[num]=op
 Q.Authority.request(num,'ledgerBegin',{item=item:getID(),scopeKind=scope},function(r) response(op,r) end)
end
function V.shoppingPaper(num,args,callback)
 if V.work[num] then if callback then callback('busy') end;return end
 local actor=getSpecificPlayer(num);if not actor or #queue(actor)>0 then if callback then callback('busy') end;return end
 local op={actor=actor,num=num,pending=true,single=true,callback=callback};V.work[num]=op
 Q.Authority.request(num,'shoppingPaperCreate',args,function(r) response(op,r) end)
end
function V.burn(num,paper,cd,computer,host)
 if V.work[num] then return end
 local actor=getSpecificPlayer(num);if not actor or #queue(actor)>0 then return end
 local op={actor=actor,num=num,pending=true,burn=true,host=host};V.work[num]=op
 local sq=computer:getSquare();local d={x=sq:getX(),y=sq:getY(),z=sq:getZ(),index=computer:getObjectIndex()}
 Q.Authority.request(num,'ledgerBurn',{item=paper:getID(),cd=cd:getID(),computer=d},function(r) response(op,r) end)
end
function V.installProgram(num,computer,media,callback)
 local actor=getSpecificPlayer(num)
 if not actor or V.work[num] or #queue(actor)>0 then if callback then callback('busy') end;return end
 local op={actor=actor,num=num,pending=true,install=true,single=true,callback=callback};V.work[num]=op
 local sq=computer:getSquare();if not sq then finish(op,'LedgerPower');return end
 Q.Authority.request(num,'ledgerProgramInstall',{program=Program.id,media=media.id,drive=media.drive,
  computer={x=sq:getX(),y=sq:getY(),z=sq:getZ(),index=computer:getObjectIndex()}},function(r) response(op,r) end)
end
function V.atComputer(num,computer,done)
 local actor=getSpecificPlayer(num);if not actor or V.work[num] or #queue(actor)>0 then return end
 if Media.computer(actor,computer,true) then done();return end
 local op={actor=actor,num=num,navigation=true,computer=computer,done=done,started=getTimestampMs()};V.work[num]=op
 if not luautils.walkAdj(actor,computer:getSquare()) then finish(op,'LedgerUnreachable');return end
 for _,action in ipairs(queue(actor)) do action.b47LedgerWork=op end
end
function V.read(num,item,computer,host)
 local actor=getSpecificPlayer(num);if not actor then return end
 local digital=item:getFullType()==Media.disc
 if digital and (not host or host~=Computer.active[num] or host.mounted~=item) then return V.computer(num,computer) end
 if V.readers[num] then V.readers[num]:close() end
 local m=U.Theme.metrics();local minimum=m.header+7*m.button+80
 if not digital then minimum=math.max(minimum,6*m.font+2*m.button+160) end
 local minimumWidth=digital and 480 or math.max(500,m.font*22+72)
 if getPlayerScreenWidth(num)<minimumWidth+20 or getPlayerScreenHeight(num)<minimum+20 then note(actor,'LedgerScreenSmall');return end
 local panel
 if host then panel=ISPanelJoypad:new(0,0,host:getWidth()-64,host:getHeight()-200)
 else
  local height=math.max(minimum,math.min(math.max(800,m.font*25),getPlayerScreenHeight(num)-40))
  local width=math.max(minimumWidth,math.min(640,math.floor(height*.78),getPlayerScreenWidth(num)-40))
  panel=U.WindowShell:new(0,0,width,height)
 end
 local colors=host and Computer.colors or Clipboard.colors
 local header=host and 0 or m.header
 panel.playerNum=num;panel.minimumWidth=minimumWidth;panel.minimumHeight=minimum;panel.resizable=true;panel.title=tr(digital and 'LedgerDigitalTitle' or 'LedgerPaperTitle')
 panel:initialise();panel:instantiate();V.readers[num]=panel
 if not host then
  panel.drawFrame=false;panel.clearStentil=false;panel.titleBarHeight=function() return 52 end
  for _,key in ipairs({'closeButton','pinButton','collapseButton','infoButton'}) do if panel[key] then panel[key]:setVisible(false) end end
 end
 local requestSerial=0;local pending=false;local page={};local cursor;local history={};local summary='';local lastRead=0;local due;local closed=false;local revision
 local selectedRoom='';local roomNames={};local query='';local ledgerMode='single';local knownStockAreas={}
 local stockWatch;local stockSource
 local tableView;local resetSelection=true;local selectedKey;local savedScroll=0
 local list=U.ScrollList:new(12,header+3*m.button+24,panel:getWidth()-24,240);list:initialise();list:instantiate();panel:addChild(list)
 list.drawBorder=true
 local search,rooms,networkMode
 local knownStockRooms={}
 local function stockRooms() local out={};for _,row in ipairs(knownStockRooms) do out[#out+1]=row end;for _,area in ipairs(knownStockAreas) do out[#out+1]={building=area.id,name=area.label} end;return out end
 local fetch
 if digital then
  search=U.TextInput:new('',12,header+8,400,m.button);search:initialise();search:instantiate();panel:addChild(search)
  search.tooltip=tr('LedgerSearch')
  search.onTextChangeFunction=function() query=search:getInternalText();page={};history={};resetSelection=true;due=getTimestampMs()+350;requestSerial=requestSerial+1;pending=false end
  rooms=ISComboBox:new(420,header+8,200,m.button,panel,function(_,box)
   local option=box.options[box.selected];selectedRoom=option and option.data or '';page={};history={};resetSelection=true;due=getTimestampMs();requestSerial=requestSerial+1;pending=false
  end)
  rooms:initialise();rooms:instantiate();U.skin(rooms,'dropdown');rooms:addOptionWithData(tr('LedgerAllRooms'),'');panel:addChild(rooms)
  networkMode=ISComboBox:new(0,0,180,m.button,panel,function(_,box)
   local option=box.options[box.selected];ledgerMode=option and option.data or 'single';page={};history={};roomNames={};knownStockRooms={};knownStockAreas={};selectedRoom='';resetSelection=true;due=getTimestampMs();requestSerial=requestSerial+1;pending=false
   if stockWatch then stockWatch:close();stockWatch=nil end
  end)
  networkMode:initialise();networkMode:instantiate();U.skin(networkMode,'dropdown');panel:addChild(networkMode)
  for _,mode in ipairs({'single','local','base'}) do networkMode:addOptionWithData(tr('LedgerView_'..mode),mode) end
  networkMode.tooltip=tr('BaseLedgerHelp')
 end
 local previous=U.Button:new(12,0,120,m.button,tr(host and 'LedgerPrevious' or 'LedgerClipboardPrevious'),panel,function()
  if pending or #history==0 then return end;page=table.remove(history);resetSelection=true;fetch()
 end)
 local more=U.Button:new(140,0,120,m.button,tr(host and 'LedgerNextPage' or 'LedgerClipboardNext'),panel,function()
  if pending or not cursor then return end;history[#history+1]=page;page={cursor=cursor};resetSelection=true;fetch()
 end)
 local stock=U.Button:new(0,0,120,m.button,tr('StockTitle'),panel,function() require('B47ANCEDQuartermaster/StockUI').open(num,panel,stockSource,host,stockRooms()) end)
 local close=U.Button:new(0,0,120,m.button,tr('LedgerClose'),panel,function() panel:close() end)
 for _,b in ipairs({previous,more,stock,close}) do b:initialise();b:instantiate();panel:addChild(b) end
 panel.ledgerControls={list=list,search=search,rooms=rooms,previous=previous,more=more,close=close,stock=stock,networkMode=networkMode}
 if host then
  for _,entry in ipairs({{list,'list'},{search,'input'},{rooms,'input'},{previous,'button'},{more,'button'},{stock,'button'},{networkMode,'input'},{close,'button'}}) do if entry[1] then Computer.decorate(entry[1],entry[2]) end end
  tableView=LedgerTable.new(panel,list,search,rooms,previous,more,close,m,colors);panel.ledgerTable=tableView
 else
  for _,w in ipairs({previous,more,stock,close}) do w.backgroundColor=U.Theme.copy(colors.grey);w.backgroundColorMouseOver=U.Theme.copy(colors.light);w.borderColor=U.Theme.copy(colors.shadow);w.textColor=U.Theme.copy(colors.black);w.textColorDisabled=U.Theme.copy(colors.muted) end
  tableView=LedgerTable.new(panel,list,nil,nil,previous,more,close,m,colors,Clipboard);panel.ledgerTable=tableView;panel.ledgerClipboard=true
 end
 local function rememberSelection()
  if not tableView or resetSelection or #list.items==0 then return end
  local row=list.items[list.selected];selectedKey=LedgerTable.key(row and row.item);savedScroll=list:getYScroll()
 end
 function panel:close()
  if closed then return end;closed=true;if stockWatch then stockWatch:close() end;requestSerial=requestSerial+1;V.readers[num]=nil;U.Tooltip.dispose(self)
  if host then host:release(self) else self:removeFromUIManager();U.Focus.restore(num) end
 end
 if host then Computer.keyboard(panel,function() panel:close() end)
 else
  panel:setWantKeyEvents(true)
  panel.isKeyConsumed=function(self,key) return not closed and self:isVisible() and num==0 and key==Keyboard.KEY_ESCAPE end
  panel.onKeyRelease=function(self,key) if self:isKeyConsumed(key) then self:close() end end
 end
 fetch=function()
  if pending or closed then return end
  requestSerial=requestSerial+1;local serial=requestSerial;pending=true;lastRead=getTimestampMs()
  local d
  if digital then local sq=computer and computer:getSquare();if not sq then panel:close();return end;d={x=sq:getX(),y=sq:getY(),z=sq:getZ(),index=computer:getObjectIndex()} end
  stockSource={item=item:getID(),drive=item.drive,computer=d,ledgerMode=ledgerMode}
  Q.Authority.request(num,ledgerMode~='single' and 'ledgerBaseRead' or 'ledgerRead',{ledgerMode=ledgerMode,item=item:getID(),drive=item.drive,computer=d,query=query,room=selectedRoom,cursor=page.cursor},function(r)
   if closed or serial~=requestSerial or getSpecificPlayer(num)~=actor then return end
   rememberSelection();pending=false;U.RowTooltip.hide(list);list:clear();cursor=nil
   if tableView then tableView.count=0;tableView.status=tr('LedgerLoading');tableView.emptyLabel=tableView.status;tableView.summary='';list:setYScroll(0) end
   if r.status=='LedgerPageChanged' then page={};history={};resetSelection=true;due=getTimestampMs()+250;return end
   if r.status=='waiting' then summary=tr(r.summary or 'LedgerLoading');if tableView then tableView.status=summary;tableView.emptyLabel=summary end;due=getTimestampMs()+250;return end
   if r.status=='LedgerChanged' then page={};history={};resetSelection=true;due=getTimestampMs()+500;return end
   if r.status=='LedgerBlank' then summary=tr('LedgerBlank');if tableView then tableView.status=summary;tableView.emptyLabel=summary end;return end
   if r.status~='ok' then summary=tr(r.status);tableView.status=summary;tableView.emptyLabel=summary;if digital then panel:close();note(actor,r.status) end;return end
   if revision and revision~=r.revision and page.cursor~=nil then revision=r.revision;page={};history={};resetSelection=true;due=getTimestampMs()+250;return end
   revision=r.revision;knownStockAreas=r.stockAreas or {}
   for _,room in ipairs(r.rooms or {}) do local found=false;for _,old in ipairs(knownStockRooms) do if old.id==room.id then found=true end end;if not found then knownStockRooms[#knownStockRooms+1]=room end end
   if r.redacted then knownStockRooms={} end
   summary=tr(r.summary)..' - '..r.scope..' - '..tr(r.live and 'LedgerLive' or r.fresh==false and r.summary=='LedgerComplete' and 'LedgerExpired' or 'LedgerStatic')
   if r.expires and r.fresh then summary=summary..' - '..tr('LedgerExpires',r.expires) end
   if r.computerOffsite then summary=summary..' - '..tr('LedgerComputerOffsite') end
   for _,row in ipairs(r.rows) do list:addItem(row.name,row) end
   cursor=r.cursor
   if rooms then
    if r.redacted then
     rooms:clear();roomNames={};rooms:addOptionWithData(tr('LedgerAllRooms'),'')
     if selectedRoom~='' then selectedRoom='';page={};history={};resetSelection=true;due=getTimestampMs()+250 end
    end
    for _,room in ipairs(r.rooms) do if not roomNames[room.id] then roomNames[room.id]=true;rooms:addOptionWithData(room.name,room.id) end end
   end
   if tableView then
    tableView.count=#r.rows;tableView.page=#history+1;tableView.summary=summary;tableView.emptyLabel=tr('LedgerTableNoEntries')
    tableView.status=r.scope..' | '..tr(r.live and 'LedgerTableLive' or r.fresh==false and r.summary=='LedgerComplete' and 'LedgerTableExpired' or 'LedgerTableSnapshot')
    if r.computerOffsite then tableView.status=tr('LedgerTableOffsite')..' | '..tableView.status end
    if r.expires and r.fresh then tableView.status=tableView.status..' | '..tr('LedgerTableExpires',r.expires) end
    if r.summary~='LedgerComplete' then tableView.status=tr(r.summary)..' | '..tableView.status end
    if resetSelection then selectedKey=nil;savedScroll=0 end
    list.selected=#list.items>0 and 1 or -1
    if selectedKey then for n,row in ipairs(list.items) do if LedgerTable.key(row.item)==selectedKey then list.selected=n;break end end end
    list:setYScroll(math.max(math.min(0,list:getHeight()-#list.items*list.itemheight),math.min(0,savedScroll)))
    resetSelection=false
   end
   if #r.rows==0 and cursor and digital and (query~='' or selectedRoom~='') then page={cursor=cursor};resetSelection=true;due=getTimestampMs()+250 end
  end)
 end
 if host then function panel:updateComputer()
  if not stockWatch and stockSource then stockWatch=require('B47ANCEDQuartermaster/StockWatch').new(num,host,stockSource,panel,stockRooms) end
  if stockWatch then stockWatch:update() end
 end end
 panel.prerender=function(self,...)
  if not Policy.enabled() or getSpecificPlayer(num)~=actor or actor:isDead() or (not digital and Media.owned(actor,item:getID())~=item) or digital and not Media.computer(actor,computer,true) then self:close();return end
  tableView:layout();tableView:draw()
  if panel.updateComputer then panel:updateComputer() end
  previous:setEnable(not pending and #history>0);more:setEnable(not pending and cursor~=nil)
  local now=getTimestampMs()
  if not pending and (due and now>=due or now-lastRead>=2000) then due=nil;fetch() end
 end
 panel.joypadButtonsY={};panel.joypadButtons={};panel.allJoypadButtons={};panel.joypadIndexY=1;panel.joypadIndex=1
 if search then panel:insertNewLineOfButtons(search,rooms,networkMode) end;panel:insertNewLineOfButtons(list);panel:insertNewLineOfButtons(previous,more,stock,close)
 local joy=panel.onJoypadDown;panel.onJoypadDown=function(self,key,...)
  if key==Joypad.BButton then if host then host:minimizeApp('ledger');setJoypadFocus(num,host) else self:close() end elseif joy then joy(self,key,...) end
 end
 if host then
  function panel:onComputerResume()
   if closed then return end
   rememberSelection();requestSerial=requestSerial+1;pending=false;due=nil;list:clear();summary=tr('LedgerLoading')
   tableView.status=summary;tableView.emptyLabel=summary;tableView.summary='';tableView.count=0;fetch()
  end
 end
 if host then host:showApp(panel,tr('LedgerDigitalTitle'),'ledger') else U.bounds(panel,num);panel:addToUIManager();setJoypadFocus(num,panel) end
 fetch();return panel
end
local function inventory(actor)
 local sheets,discs,cds={},{},{};local visited={};local count=0
 local function visit(c,depth)
  if visited[c] or depth>16 then return end;visited[c]=true
  local items=c:getItems()
  for n=0,items:size()-1 do
   count=count+1;if count>4096 then return end
   local item=items:get(n);local t=item:getFullType()
   if t==Media.sheet and #sheets<16 then sheets[#sheets+1]=item elseif t==Media.disc and #discs<16 then discs[#discs+1]=item elseif Media.cd(item) and Media.usable(item) and #cds<16 then cds[#cds+1]=item end
   if instanceof(item,'InventoryContainer') then visit(item:getInventory(),depth+1) end
  end
 end
 visit(actor:getInventory(),0);return sheets,discs,cds
end
function V.inventoryMenu(num,menu,items)
 if not Policy.enabled() then return end
 local actor=getSpecificPlayer(num);if not actor then return end
 local seen={}
 for n=1,math.min(64,#items) do
  local item=items[n];if type(item)=='table' and item.items then item=item.items[1] end
  if item and type(item.getFullType)=='function' and item:getFullType()==Media.sheet and not seen[item] and Media.owned(actor,item:getID(),Media.sheet)==item then
   seen[item]=true
   menu:addOption(tr('LedgerReadPaper'),nil,function() V.read(num,item) end)
   if V.work[num] then menu:addOption(tr('LedgerCancel'),nil,function() V.cancel(num) end)
   else
    do -- Completed sheets can be renewed into a new historical generation.
     local inv=actor:getInventory();local writing=inv:containsTypeRecurse('Base.Pen') or inv:containsTypeRecurse('Base.Pencil')
     if writing and actor:getCurrentSquare():getBuilding() then menu:addOption(tr('LedgerRecordBuilding'),nil,function() V.record(num,item,'building') end) end
     if writing and Scope.capture(actor,'safehouse') then menu:addOption(tr('LedgerRecordSafehouse'),nil,function() V.record(num,item,'safehouse') end) end
    end
   end
   break
  end
 end
 U.menu(menu)
end
local PC=require 'B47ANCEDPCFramework/API'
PC.registerApplication('quartermaster',function(num,computer)
 if not Policy.enabled() or not computer or not Program.localInstalled(computer) then return end
 return {inventory=inventory,enabled=Policy.enabled,canUse=Media.computer,launcherTitle=tr('ComputerAppTitle'),
  text=tr,file='QUARTERMASTER.EXE',toolTitle=tr('ComputerWriter'),
  canRun=function(item) return item and item:getFullType()==Media.disc end,
  writer=require 'B47ANCEDQuartermaster/ComputerWriter',
  drive=function(command,args,reply)
   local sq=computer:getSquare();if not sq then reply({status='LedgerPower'});return end
   args.computer={x=sq:getX(),y=sq:getY(),z=sq:getZ(),index=computer:getObjectIndex()}
   Q.Authority.request(num,({list='ledgerDriveList',mount='ledgerDriveMount',eject='ledgerDriveEject'})[command],args,reply)
  end,
  read=function(item,host) return V.read(num,item,computer,host) end,
  burn=function(paper,cd,host) V.burn(num,paper,cd,computer,host) end,
  busy=function() return V.work[num]~=nil end,
  close=function() local op=V.work[num];if op and op.burn then V.cancel(num) end end}
end,tr('LedgerDigitalTitle'))
require('B47ANCEDQuartermaster/ProgramInstaller')(PC,V)
function V.computer(num,computer) return PC.open(num,computer,Program.localInstalled(computer) and 'quartermaster' or Program.id) end
function V.worldMenu(num,menu,objects,test)
 if test or not Policy.enabled() then return end
 local actor=getSpecificPlayer(num);if not actor then return end
 for n=1,math.min(#objects,64) do local obj=objects[n]
  if Media.computer(actor,obj,false) then
   menu:addOption(tr('ComputerUse'),nil,function() V.atComputer(num,obj,function() V.computer(num,obj) end) end)
   break
  end
 end
 U.menu(menu)
end
function V.tick()
 for num,op in pairs(V.work) do
  if getSpecificPlayer(num)~=op.actor or op.actor:isDead() then V.cancel(num)
  elseif op.returning then
   if #queue(op.actor)==0 then
    if op.returned and atOrigin(op) then resumeSort(op) else finish(op,'LedgerUnreachable') end
   elseif getTimestampMs()-op.returnStarted>=120000 then V.cancelSort(num) end
  elseif op.navigation and #queue(op.actor)==0 then
   V.work[num]=nil;op.closed=true
   if Media.computer(op.actor,op.computer,true) and getTimestampMs()-op.started<120000 then op.done() else note(op.actor,'LedgerUnreachable') end
  elseif not op.sorting and not op.pending and not op.actionPending and #queue(op.actor)==0 and getTimestampMs()>=(op.at or 0) then
   local command=op.sortPreparing and 'ledgerSortPrepare' or op.sortWriting and 'ledgerSortNext' or 'ledgerNext'
   op.pending=true;Q.Authority.request(num,command,{target=op.target},function(r) response(op,r) end)
  end
 end
end
if Events then
 Events.OnFillInventoryObjectContextMenu.Add(V.inventoryMenu)
 -- PC Framework owns the world computer entry point.
 Events.OnTick.Add(V.tick)
 Events.OnServerCommand.Add(function(module,command,args)
  if module~='B47ANCEDQuartermasterLedger' or type(args)~='table' then return end
  local offer=L.clientOffers[args.token];if not offer then return end
  if command=='challenge' then Q.Authority.request(offer.actor:getPlayerNum(),'ledgerConfirm',{token=args.token,challenge=args.challenge},function(r)
   local op=V.work[offer.actor:getPlayerNum()]
   if r.status~='ok' and op and op.token==args.token then finish(op,r.status,true) end
  end)
  elseif command=='result' then nativeResult(offer.actor,args) end
 end)
end
return V
