require 'B47ANCEDUI/Controls'
require 'ISUI/ISComboBox'
require 'TimedActions/ISTimedActionQueue'
require 'TimedActions/WalkToTimedAction'
require 'B47ANCEDQuartermaster/Authority'
local L=require 'B47ANCEDQuartermaster/Ledger'
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local Action=require 'B47ANCEDQuartermaster/LedgerAction'
local Computer=require 'B47ANCEDQuartermaster/ComputerUI'
local U,Q=B47ANCEDUI,B47ANCEDQuartermaster
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
  Q.Authority.request(num,'ledgerCancel',{},function() end)
 end
 if op.token then L.clientOffers[op.token]=nil end
end
local function finish(op,status)
 if op.closed then return end
 op.closed=true;V.work[op.num]=nil
 if op.token then L.clientOffers[op.token]=nil end
 if status~='ok' and status~='done' and status~='ShoppingPaperCreated' and status~='ShoppingPaperSyncPending' then Q.Authority.request(op.num,'ledgerCancel',{},function() end) end
 local key=status=='ok' and 'LedgerSaved' or status=='done' and (op.summary or 'LedgerComplete') or status
 local screen=Computer.active[op.num];if op.burn and screen then screen:message(key) end
 note(op.actor,key)
 if op.callback then op.callback(status) end
end
local function response(op,result)
 if op.closed or getSpecificPlayer(op.num)~=op.actor then return end
 op.pending=false;op.at=getTimestampMs()+250
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
  L.clientOffers[result.token]={actor=op.actor,seconds=result.seconds}
  local action=Action:new(op.actor,result.token)
  if not action then finish(op,'failed');return end
  action.b47LedgerWork=op;ISTimedActionQueue.add(action);return
 end
 if result.status=='LedgerChanged' then
  op.changed=(op.changed or 0)+1
  if op.changed<=3 then return end
 end
 op.summary=result.summary;finish(op,result.status)
end
local function nativeResult(actor,result)
 local num=actor:getPlayerNum();local op=V.work[num]
 if not op or op.token~=result.token then return end
 L.clientOffers[result.token]=nil;op.token=nil;op.actionPending=false;op.target=nil;op.at=getTimestampMs()+250
 if result.status=='LedgerChanged' then op.changed=(op.changed or 0)+1;if op.changed<=3 then return end end
 if result.status=='ShoppingPaperCreated' then finish(op,result.status) elseif result.status~='ok' then finish(op,result.status) elseif op.burn then finish(op,'ok') end
end
L.clientResult=nativeResult
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
function V.burn(num,paper,cd,computer)
 if V.work[num] then return end
 local actor=getSpecificPlayer(num);if not actor or #queue(actor)>0 then return end
 local op={actor=actor,num=num,pending=true,burn=true};V.work[num]=op
 local sq=computer:getSquare();local d={x=sq:getX(),y=sq:getY(),z=sq:getZ(),index=computer:getObjectIndex()}
 Q.Authority.request(num,'ledgerBurn',{item=paper:getID(),cd=cd:getID(),computer=d},function(r) response(op,r) end)
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
 if getPlayerScreenWidth(num)<500 or getPlayerScreenHeight(num)<minimum then note(actor,'LedgerScreenSmall');return end
 local panel
 if host then panel=ISPanelJoypad:new(0,0,host:getWidth()-64,host:getHeight()-200)
 else panel=U.WindowShell:new(0,0,math.min(960,getPlayerScreenWidth(num)-20),math.min(680,getPlayerScreenHeight(num)-20)) end
 local colors=host and Computer.colors or U.Theme.colors
 local header=host and 0 or m.header
 panel.playerNum=num;panel.minimumWidth=480;panel.minimumHeight=minimum;panel.resizable=true;panel.title=tr(digital and 'LedgerDigitalTitle' or 'LedgerPaperTitle')
 panel:initialise();panel:instantiate();V.readers[num]=panel
 local requestSerial=0;local pending=false;local page={};local cursor;local history={};local summary='';local lastRead=0;local due;local closed=false;local revision
 local selectedRoom='';local roomNames={};local query=''
 local list=U.ScrollList:new(12,header+3*m.button+24,panel:getWidth()-24,240);list:initialise();list:instantiate();panel:addChild(list)
 list.itemheight=3*(m.font+4);list.drawBorder=true
 list.doDrawItem=function(self,y,row,alt)
  local data=row.item;local text=host and colors.black or colors.text
  if row.ledgerWidth~=self:getWidth() then
   local full={data.empty and tr('LedgerEmpty') or tr('LedgerItemLine',data.name,data.quantity),
    tr('LedgerLocationLine',data.room,data.container,data.position.x,data.position.y,data.position.z,data.position.ci+1),
    tr('LedgerRecordedLine',data.recorded,data.fullType,data.condition)}
   row.ledgerLines={};local clipped=false
   for n,line in ipairs(full) do full[n]=U.Tooltip.plain(line);row.ledgerLines[n]=U.Renderer.fit(full[n],self:getWidth()-22);clipped=clipped or full[n]~=row.ledgerLines[n] end
   row.tooltip=clipped and table.concat(full,'<LINE>') or nil;row.ledgerWidth=self:getWidth()
  end
  U.Renderer.text(self,row.ledgerLines[1],8,y+2,text)
  U.Renderer.text(self,row.ledgerLines[2],8,y+m.font+6,(host and colors.muted or U.Theme.colors.muted))
  U.Renderer.text(self,row.ledgerLines[3],8,y+2*(m.font+4),(host and colors.muted or U.Theme.colors.muted))
  return y+self.itemheight
 end
 local search,rooms
 local fetch
 if digital then
  search=U.TextInput:new('',12,header+8,400,m.button);search:initialise();search:instantiate();panel:addChild(search)
  search.tooltip=tr('LedgerSearch')
  search.onTextChangeFunction=function() query=search:getInternalText();page={};history={};due=getTimestampMs()+350;requestSerial=requestSerial+1;pending=false end
  rooms=ISComboBox:new(420,header+8,200,m.button,panel,function(_,box)
   local option=box.options[box.selected];selectedRoom=option and option.data or '';page={};history={};due=getTimestampMs();requestSerial=requestSerial+1;pending=false
  end)
  rooms:initialise();rooms:instantiate();U.skin(rooms,'dropdown');rooms:addOptionWithData(tr('LedgerAllRooms'),'');panel:addChild(rooms)
 end
 local previous=U.Button:new(12,0,120,m.button,tr('LedgerPrevious'),panel,function()
  if pending or #history==0 then return end;page=table.remove(history);fetch()
 end)
 local more=U.Button:new(140,0,120,m.button,tr('LedgerNextPage'),panel,function()
  if pending or not cursor then return end;history[#history+1]=page;page={cursor=cursor};fetch()
 end)
 local close=U.Button:new(0,0,120,m.button,tr('LedgerClose'),panel,function() panel:close() end)
 for _,b in ipairs({previous,more,close}) do b:initialise();b:instantiate();panel:addChild(b) end
 panel.ledgerControls={list=list,search=search,rooms=rooms,previous=previous,more=more,close=close}
 if host then
  for _,entry in ipairs({{list,'list'},{search,'input'},{rooms,'input'},{previous,'button'},{more,'button'},{close,'button'}}) do if entry[1] then Computer.decorate(entry[1],entry[2]) end end
 end
 function panel:close()
  if closed then return end;closed=true;requestSerial=requestSerial+1;V.readers[num]=nil;U.Tooltip.dispose(self)
  if host then host:release(self) else self:removeFromUIManager();U.Focus.restore(num) end
 end
 if host then Computer.keyboard(panel,function() panel:close() end) end
 fetch=function()
  if pending or closed then return end
  requestSerial=requestSerial+1;local serial=requestSerial;pending=true;lastRead=getTimestampMs()
  local d
  if digital then local sq=computer and computer:getSquare();if not sq then panel:close();return end;d={x=sq:getX(),y=sq:getY(),z=sq:getZ(),index=computer:getObjectIndex()} end
  Q.Authority.request(num,'ledgerRead',{item=item:getID(),drive=item.drive,computer=d,query=query,room=selectedRoom,cursor=page.cursor},function(r)
   if closed or serial~=requestSerial or getSpecificPlayer(num)~=actor then return end
   pending=false;U.RowTooltip.hide(list);list:clear();cursor=nil
   if r.status=='LedgerPageChanged' then page={};history={};due=getTimestampMs()+250;return end
   if r.status=='LedgerBlank' then summary=tr('LedgerBlank');return end
   if r.status~='ok' then summary=tr(r.status);if digital then panel:close();note(actor,r.status) end;return end
   if revision and revision~=r.revision and page.cursor~=nil then revision=r.revision;page={};history={};due=getTimestampMs()+250;return end
   revision=r.revision
   summary=tr(r.summary)..' - '..r.scope..' - '..tr('LedgerStatic')
   for _,row in ipairs(r.rows) do list:addItem(row.name,row) end
   cursor=r.cursor
   if rooms then
    if r.redacted then
     rooms:clear();roomNames={};rooms:addOptionWithData(tr('LedgerAllRooms'),'')
     if selectedRoom~='' then selectedRoom='';page={};history={};due=getTimestampMs()+250 end
    end
    for _,room in ipairs(r.rooms) do if not roomNames[room.id] then roomNames[room.id]=true;rooms:addOptionWithData(room.name,room.id) end end
   end
   if #r.rows==0 and cursor and digital and (query~='' or selectedRoom~='') then page={cursor=cursor};due=getTimestampMs()+250 end
  end)
 end
 local pre=panel.prerender
 panel.prerender=function(self,...)
  if getSpecificPlayer(num)~=actor or actor:isDead() or (not digital and Media.owned(actor,item:getID())~=item) or digital and not Media.computer(actor,computer,true) then self:close();return end
  if host then U.Renderer.rect(self,0,0,self:getWidth(),self:getHeight(),colors.white) else pre(self,...) end
  local w,h=self:getWidth(),self:getHeight();local top=header+(digital and m.button+16 or 8)
  list:setX(12);list:setY(top+2*m.button);list:setWidth(w-24);list:setHeight(math.max(m.button,h-top-3*m.button-24))
  if search then search:setWidth(math.max(140,w*.60-20));rooms:setX(12+w*.60);rooms:setWidth(w*.40-24) end
  previous:setY(h-m.button-12);more:setY(h-m.button-12);close:setY(h-m.button-12);close:setX(w-132)
  previous:setEnable(not pending and #history>0);more:setEnable(not pending and cursor~=nil)
  U.Renderer.text(self,U.Renderer.fit(summary,w-24),12,top,host and colors.black or U.Theme.colors.text)
  if pending then U.Renderer.text(self,tr('LedgerLoading'),12,top+m.button,(host and colors.muted or U.Theme.colors.muted)) end
  local now=getTimestampMs()
  if not pending and (due and now>=due or now-lastRead>=2000) then due=nil;fetch() end
 end
 panel.joypadButtonsY={};panel.joypadButtons={};panel.allJoypadButtons={};panel.joypadIndexY=1;panel.joypadIndex=1
 if search then panel:insertNewLineOfButtons(search,rooms) end;panel:insertNewLineOfButtons(previous,more,close)
 local joy=panel.onJoypadDown;panel.onJoypadDown=function(self,key,...)
  if key==Joypad.BButton then self:close() elseif joy then joy(self,key,...) end
 end
 if host then host:showApp(panel,tr('LedgerDigitalTitle')) else U.bounds(panel,num);panel:addToUIManager();setJoypadFocus(num,panel) end
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
 local actor=getSpecificPlayer(num);if not actor then return end
 local seen={}
 for n=1,math.min(64,#items) do
  local item=items[n];if type(item)=='table' and item.items then item=item.items[1] end
  if item and type(item.getFullType)=='function' and item:getFullType()==Media.sheet and not seen[item] and Media.owned(actor,item:getID(),Media.sheet)==item then
   seen[item]=true
   menu:addOption(tr('LedgerReadPaper'),nil,function() V.read(num,item) end)
   if V.work[num] then menu:addOption(tr('LedgerCancel'),nil,function() V.cancel(num) end)
   else local md=item:getModData().B47Ledger
    if not md or md.complete~=true then
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
function V.computer(num,computer)
 if not computer then return end
 return Computer.open(num,computer,{inventory=inventory,
  drive=function(command,args,reply)
   local sq=computer:getSquare();if not sq then reply({status='LedgerPower'});return end
   args.computer={x=sq:getX(),y=sq:getY(),z=sq:getZ(),index=computer:getObjectIndex()}
   Q.Authority.request(num,command,args,reply)
  end,
  read=function(item,host) return V.read(num,item,computer,host) end,
  burn=function(paper,cd) V.burn(num,paper,cd,computer) end,
  busy=function() return V.work[num]~=nil end,
  close=function() local op=V.work[num];if op and op.burn then V.cancel(num) end end})
end
function V.worldMenu(num,menu,objects,test)
 if test then return end
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
  elseif op.navigation and #queue(op.actor)==0 then
   V.work[num]=nil;op.closed=true
   if Media.computer(op.actor,op.computer,true) and getTimestampMs()-op.started<120000 then op.done() else note(op.actor,'LedgerUnreachable') end
  elseif not op.pending and not op.actionPending and #queue(op.actor)==0 and getTimestampMs()>=(op.at or 0) then
   op.pending=true;Q.Authority.request(num,'ledgerNext',{target=op.target},function(r) response(op,r) end)
  end
 end
end
if Events then
 Events.OnFillInventoryObjectContextMenu.Add(V.inventoryMenu)
 Events.OnFillWorldObjectContextMenu.Add(V.worldMenu)
 Events.OnTick.Add(V.tick)
 Events.OnServerCommand.Add(function(module,command,args)
  if module~='B47ANCEDQuartermasterLedger' or type(args)~='table' then return end
  local offer=L.clientOffers[args.token];if not offer then return end
  if command=='challenge' then Q.Authority.request(offer.actor:getPlayerNum(),'ledgerConfirm',{token=args.token,challenge=args.challenge},function(r)
   local op=V.work[offer.actor:getPlayerNum()]
   if r.status~='ok' and op and op.token==args.token then V.cancel(offer.actor:getPlayerNum()) end
  end)
  elseif command=='result' then nativeResult(offer.actor,args) end
 end)
end
return V
