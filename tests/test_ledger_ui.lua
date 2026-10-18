-- Existing owned UI surface plus the native base-action class; no pixel proof.
dofile(TEST_ROOT..'/test_load_settings_ui.lua')
local Q,U=B47ANCEDQuartermaster,B47ANCEDUI;SandboxVars.B47ANCEDQuartermaster.RequireComputerApplication=false -- existing UI behavior; installer is tested separately
local f=CONTAINER_FIXTURE;local actor=f.player
local callbacks={};Events={}
for _,name in ipairs({'OnTick','OnFillInventoryObjectContextMenu','OnFillWorldObjectContextMenu','OnServerCommand'}) do Events[name]={Add=function(fn) callbacks[name]=fn end} end
local q={queue={}};ISTimedActionQueue={getTimedActionQueue=function() return q end,add=function(a) q.queue[#q.queue+1]=a end}
package.loaded['TimedActions/ISTimedActionQueue']=ISTimedActionQueue;package.loaded['TimedActions/WalkToTimedAction']=true
ISBaseObject=ISPanel;package.loaded.ISBaseObject=ISBaseObject
dofile(GAME_ROOT..'/media/lua/shared/TimedActions/ISBaseTimedAction.lua');package.loaded['TimedActions/ISBaseTimedAction']=ISBaseTimedAction
UITransition={new=function() return {} end}
dofile(GAME_ROOT..'/media/lua/client/ISUI/ISComboBox.lua')
local function item(id,t)
 return {getID=function() return id end,getFullType=function() return t end,getModData=function() return {B47Ledger={complete=true}} end,getDisplayName=function() return t end,
 isFavorite=function() return false end,isEquipped=function() return false end,getAttachedSlot=function() return -1 end,getIsCraftingConsumed=function() return false end}
end
local paper=item(900,'B47ANCEDQuartermaster.SupplySheet');local disc=item(901,'B47ANCEDQuartermaster.SupplyDisc');local cd=item(902,'Base.Disc_Retail')
local inv={getItemWithIDRecursiv=function(_,id) return id==900 and paper or id==901 and disc or id==902 and cd end,getItems=function() return f.list({paper,disc,cd}) end,containsTypeRecurse=function() return true end}
actor.getInventory=function() return inv end
f.network(true,false)
local sq=actor:getCurrentSquare();sq.haveElectricity=function() return true end;sq.hasGridPower=function() return false end;sq.getRoom=function() return {} end;sq.canReachTo=function() return true end
local computer=f.a;computer.getSprite=function() return {name='appliances_com_01_72'} end
local sent={};local serverMounted=false;local storageCD=true
local function driveDisc() return {id=901,name='Fixture ledger CD',fullType='B47ANCEDQuartermaster.SupplyDisc',drive='fixture-drive'} end
local function readCount() local n=0;for _,r in ipairs(sent) do if r.command=='ledgerRead' then n=n+1 end end;return n end
Q.Authority.request=function(num,command,args,reply)
 sent[#sent+1]={command=command,args=args}
 if command=='ledgerDriveList' then reply({status='ok',choices=storageCD and {{id=901,name='Fixture ledger CD',fullType='B47ANCEDQuartermaster.SupplyDisc',token='fixture-choice'}} or {},mounted=serverMounted and storageCD and driveDisc() or nil})
 elseif command=='ledgerDriveMount' then serverMounted=true;reply({status='ok',mounted=driveDisc()})
 elseif command=='ledgerDriveEject' then serverMounted=false;reply({status='ok'})
 elseif command=='ledgerRead' then reply({status='ok',rows={{name='Fixture item',quantity=5,fullType='Fixture.Item',condition=10,room='Fixture room',roomID='fixture-room',container='Fixture crate',position={x=0,y=0,z=0,ci=0},recorded=42}},rooms={{id='fixture-room',name='Fixture room'}},scope='Fixture building',summary='LedgerComplete',cursor=args.cursor==nil and 'next-page' or nil})
 else reply({status='ok'}) end
end
-- Native methods omitted by the shared geometry-only host fixture.
function ISPanelJoypad:bringToTop() self.raised=true end
function ISPanel:drawTextCentre() end
function ISTextEntryBox:setTextRGBA(r,g,b,a) self.nativeTextColor={r,g,b,a} end
local V=require 'B47ANCEDQuartermaster/LedgerUI'
require 'B47ANCEDPCFramework/Startup'
local panel=assert(V.read(0,paper));assert(not panel.ledgerControls.search and not panel.ledgerControls.rooms,'paper exposes digital controls')
assert(panel:getWidth()<panel:getHeight(),'paper clipboard opens as a wide desktop window')
panel:prerender();assert(#panel.ledgerControls.list.items==1)
panel:setWidth(800);panel:setHeight(620);panel:prerender()
assert(panel.ledgerControls.list.y+panel.ledgerControls.list.height<=panel.ledgerControls.close.y,'paper list overlaps footer')
panel.ledgerControls.more.onclick();assert(sent[#sent].args.cursor=='next-page')
panel.ledgerControls.previous.onclick();assert(sent[#sent].args.cursor==nil)
panel:onJoypadDown(Joypad.BButton);assert(not V.readers[0])
local before=readCount()
local C=require 'B47ANCEDQuartermaster/ComputerUI'
local art=require 'B47ANCEDPCFramework/ComputerArt'
-- The shared grid is original artwork, not a texture/foreign-asset dependency.
for kind,layers in pairs(art.icons) do
 assert(#layers>0)
 for _,v in ipairs(layers) do assert(v[1]>=0 and v[2]>=0 and v[3]>0 and v[4]>0 and v[1]+v[3]<=32 and v[2]+v[4]<=32 and art.colors[v[5]],'icon outside authoring grid: '..kind) end
end
local screen=assert(V.computer(0,computer));assert(not screen.content and readCount()==before,'computer auto-ran the ledger')
assert(V.computer(0,computer)==screen,'duplicate computer screen')
local drive=screen:openDrive();assert(readCount()==before and not V.readers[0],'drive browser auto-read the CD')
assert(screen:openDrive()==drive and #screen.taskOrder==1,'opening the same app duplicated a task')
drive.insert.onclick();assert(screen.mounted:getID()==901 and readCount()==before,'inserting CD auto-ran it')
assert(not V.readers[0]);drive:prerender()
local exeReachable=false;for _,widget in ipairs(drive.allJoypadButtons) do if widget==drive.file then exeReachable=true end end
assert(exeReachable,'retained drive did not refresh controller rows after mounting')
screen.content.run.onclick()
panel=assert(V.readers[0]);assert(screen.content==panel and panel.parent and not panel.removed,'reader is not embedded')
assert(readCount()==before+1 and panel.ledgerControls.search and panel.ledgerControls.rooms)
assert(panel.ledgerControls.search.nativeTextColor[1]<.1,'native text-entry glyphs stayed white on white')
assert(#panel.ledgerControls.rooms.options==2,'digital room browser missing')
for _,size in ipairs({{screen.minimumWidth,screen.minimumHeight},{1100,700}}) do
 screen:setWidth(size[1]);screen:setHeight(size[2]);screen:prerender();panel:prerender()
 assert(panel.ledgerControls.list.y+panel.ledgerControls.list.height<=panel.ledgerControls.close.y,'computer reader overlaps footer')
 local right=screen.showDesktop.x+screen.showDesktop.width
 for _,key in ipairs(screen.taskOrder) do local task=screen.apps[key].task
  assert(task.x>right and task.x+task.width<=screen.crt.x+screen.crt.width,'taskbar overlap')
  right=task.x+task.width
 end
end
panel.ledgerControls.search:setText('5.56');panel.ledgerControls.search.onTextChangeFunction();f.advance(400);panel:prerender()
assert(sent[#sent].args.query=='5.56' and sent[#sent].args.cursor==nil)
local writerTask=screen:openWriter()
assert(V.readers[0]==panel and screen.apps.ledger.content==panel and #screen.taskOrder==3,'app switch closed another task')
local writerChoice=writerTask.cd.selected
local tipHidden=false;writerTask.tooltipUI={setVisible=function(_,shown) tipHidden=not shown end,removeFromUIManager=function() end}
screen.apps.writer.task.onclick()
assert(tipHidden,'minimized task left a tooltip above desktop');writerTask.tooltipUI=nil
writerTask:onKeyRelease(Keyboard.KEY_ESCAPE);assert(screen.apps.writer,'hidden task consumed Escape')
local tipUpdated=false;screen.apps.writer.task.updateTooltip=function() tipUpdated=true end
screen.apps.writer.task:update();assert(tipUpdated,'custom task button lost native full-title tooltip lifecycle')
assert(screen.apps.writer.minimized and screen.content==panel,'active task did not minimize to previous app')
screen.apps.writer.task.onclick()
assert(screen.content==writerTask and writerTask.cd.selected==writerChoice and screen.apps.writer.task.osActive,'minimized task did not restore its state')
screen.apps.ledger.task.onclick()
assert(screen.content==panel and panel.ledgerControls.search:getInternalText()=='5.56','inactive task did not restore query')
panel.ledgerControls.more.onclick();assert(sent[#sent].args.cursor=='next-page')
screen:openWriter();screen.apps.writer.task.onclick()
assert(sent[#sent].args.cursor=='next-page' and sent[#sent].args.query=='5.56','task switch reset ledger pagination/query')
screen.showDesktop.onclick()
assert(not screen.content and V.readers[0]==panel and screen.apps.ledger.minimized,'Show Desktop discarded application state')
screen.showDesktop.onclick()
assert(screen.content==panel and screen.apps.writer.minimized,'Show Desktop restored an individually minimized app')
local beforeClose=readCount();screen:closeApp('writer')
assert(screen.content==panel and V.readers[0]==panel and readCount()==beforeClose and #screen.taskOrder==2,'closing inactive task stole focus or closed ledger')
assert(screen:openWriter()~=writerTask,'closed app task was reused')
screen.apps.ledger.task.onclick()
screen:eject();assert(not V.readers[0] and not screen.mounted and not screen.apps.ledger and screen.apps.writer and screen.apps.drive,'eject closed unrelated tasks or left ledger running')
local afterEject=#sent;screen:runDisc();assert(#sent==afterEject,'empty drive ran application')
writerTask.write.onclick();assert(#sent==afterEject,'closed writer submitted stale burn intent')
local writer=screen:openWriter();local beforeWrite=#sent
assert(#sent==beforeWrite);writer.write.onclick()
assert(sent[#sent].command=='ledgerBurn' and sent[#sent].args.item==900 and sent[#sent].args.cd==902,'writer did not require explicit native media choices')
screen:close();assert(not C.active[0] and not V.work[0],'shutdown left CD conversion active')
screen=assert(V.computer(0,computer));drive=screen:openDrive();drive.insert.onclick();screen.content.file:onMouseDoubleClick()
assert(V.readers[0],'EXE double-click did not run application')
sq.haveElectricity=function() return false end;screen:prerender()
assert(not V.readers[0] and not C.active[0],'power loss left a computer/application open')
sq.haveElectricity=function() return true end
local menu=ISContextMenu.get(0);local first=#menu.options;V.worldMenu(0,menu,{computer},false)
assert(#menu.options==first+1 and not menu.options[#menu.options].sub,'computer context bypasses the OS')
assert(callbacks.OnFillInventoryObjectContextMenu and callbacks.OnFillWorldObjectContextMenu and callbacks.OnServerCommand)
-- Mounted media cannot survive loss of the exact native instance.
screen=assert(V.computer(0,computer));drive=screen:openDrive();drive.insert.onclick();screen:runDisc()
local retainedWriter=screen:openWriter();screen:desktop()
storageCD=false;f.advance(2100);screen:prerender();assert(not screen.mounted and not V.readers[0] and not screen.apps.ledger and not screen.content and screen.apps.writer.content==retainedWriter,'lost media retained hidden ledger or closed unrelated apps')
storageCD=true;serverMounted=false;screen:close()
-- Large font minimums leave the warning text above the writer footer.
local measure=getTextManager;local width,height=getPlayerScreenWidth,getPlayerScreenHeight
getPlayerScreenWidth=function() return 3840 end;getPlayerScreenHeight=function() return 2160 end
for _,font in ipairs({24,32,42}) do
 getTextManager=function() return {getFontHeight=function() return font end,MeasureStringX=function(_,_,s) return #s*font/2 end} end
 screen=assert(V.computer(0,computer));screen:setWidth(screen.minimumWidth);screen:setHeight(screen.minimumHeight);screen:prerender()
 writer=screen:openWriter();writer:prerender();local metrics=U.Theme.metrics()
 assert(writer.write.y>=48+3*metrics.font+2*metrics.button,'large-font writer warning overlaps action')
 assert(writer.write.y+writer.write.height<=writer:getHeight()-8)
 local glass=screen.crt
 assert(glass.x>=80 and glass.y>=64 and glass.x+glass.width<=screen:getWidth()-80,'CRT lost recessed surround')
 local driveApp=screen:openDrive();if not screen.mounted then driveApp.insert.onclick() end
 screen:runDisc();screen:openWriter()
 local right=screen.showDesktop.x+screen.showDesktop.width
 for _,key in ipairs(screen.taskOrder) do local task=screen.apps[key].task
  assert(task.x>right and task.x+task.width<=glass.x+glass.width and task.width>32,'taskbar escaped glass')
  assert(task.osActive==(key==screen.activeKey),'task pressed state mismatched active app')
  right=task.x+task.width
 end
 assert(screen.start.y+screen.start.height<=glass.y+glass.height,'taskbar escaped glass bottom')
 local horizontal=false;for _,line in ipairs(screen.joypadButtonsY) do if line[1]==screen.start then horizontal=#line==2+#screen.taskOrder and line[2]==screen.showDesktop end end
 assert(horizontal,'controller taskbar order does not match its horizontal layout')
 assert(screen.driveIcon.y+screen.driveIcon.height<=screen.writerIcon.y,'desktop icon captions overlap')
 assert(screen.writerIcon.y+screen.writerIcon.height<=screen.writerIcon.parent.height,'desktop icons escaped glass')
 assert(screen.power.y>=glass.panelY and screen.power.y+screen.power.height<=glass.panelY+glass.panelHeight and glass.panelY+glass.panelHeight<=screen:getHeight()-86,'power control overlaps glass/stand')
 local reachable=false;for _,widget in ipairs(screen.allJoypadButtons) do if widget==screen.power then reachable=true end end
 assert(reachable,'physical power control unreachable with controller')
 screen:onJoypadDown(Joypad.BButton);assert(screen.apps.writer.content==writer and screen.apps.writer.minimized,'controller minimize lost application')
 screen:close()
end
getTextManager=measure;getPlayerScreenWidth,getPlayerScreenHeight=width,height
Keyboard=Keyboard or {};Keyboard.KEY_ESCAPE=1
screen=assert(V.computer(0,computer));local activeWriter=screen:openWriter()
screen.start.onclick();activeWriter:onKeyRelease(Keyboard.KEY_ESCAPE)
assert(screen.apps.writer and screen.menuOpen,'background app consumed Start-menu Escape')
screen:onKeyRelease(Keyboard.KEY_ESCAPE)
assert(screen.content==activeWriter and not screen.menuOpen,'Escape closed app instead of dismissing Start')
screen:onKeyRelease(Keyboard.KEY_ESCAPE)
assert(not screen.content and C.active[0]==screen,'Escape did not return to desktop')
screen:onKeyRelease(Keyboard.KEY_ESCAPE);assert(not C.active[0],'desktop Escape did not shut down')
print('PASS OFFLINE Windows 93 ledger UI: desktop has no automatic reads, explicit CD insert/run and EXE double-click, embedded literal search/rooms, resize/footer/taskbar at 14/24/32/42 font heights, minimize/eject, exact media-loss cleanup, explicit writer choices, shutdown cancellation, Escape/controller and power-loss close; paper navigation preserved; native visual acceptance NOT TESTED')

-- Late mount replies must not resurrect closed windows or steal app focus.
serverMounted=false;storageCD=true
screen=assert(V.computer(0,computer));drive=screen:openDrive()
local request=Q.Authority.request;local delayedMount
Q.Authority.request=function(num,command,args,reply)
 if command=='ledgerDriveMount' then delayedMount=function() request(num,command,args,reply) end
 else request(num,command,args,reply) end
end
drive.insert.onclick();local stableWriter=screen:openWriter();screen:closeApp('drive')
assert(delayedMount);delayedMount()
assert(not screen.apps.drive and screen.content==stableWriter and screen.mounted,'late mount resurrected drive or stole focus')
Q.Authority.request=request;screen:close()
-- Resuming a cached reader clears old rows and revalidates without losing query.
screen=assert(V.computer(0,computer));screen:openDrive();screen:runDisc();panel=V.readers[0]
panel.ledgerControls.search:setText('5.56');panel.ledgerControls.search.onTextChangeFunction();f.advance(400);panel:prerender()
screen:openWriter();local delayedRead
Q.Authority.request=function(num,command,args,reply)
 if command=='ledgerRead' then delayedRead=function() request(num,command,args,reply) end
 else request(num,command,args,reply) end
end
screen.apps.ledger.task.onclick()
assert(delayedRead and #panel.ledgerControls.list.items==0 and panel.ledgerControls.search:getInternalText()=='5.56','resume exposed stale rows or lost query')
local frame=panel.parent;frame.exit.onclick();assert(not screen.apps.ledger and not V.readers[0],'X did not close only the active task')
delayedRead();assert(not screen.apps.ledger and not V.readers[0],'late read resurrected a closed task')
Q.Authority.request=request;screen:close();serverMounted=false
print('PASS OFFLINE computer taskbar: independent tasks, preserved query/page/choices, active toggle, MRU switch, Show Desktop restore, close/X, large fonts, hidden media invalidation, fresh resume and late-reply cleanup')

-- Physical power closes only the UI and uses the same cancellation path as Log Off.
screen=assert(V.computer(0,computer))
local pending={actor=actor,burn=true};V.work[0]=pending
local oldQueue=q.queue;local stopped=false;local beforePower=#sent
q.queue={{b47LedgerWork=pending,action=true,forceStop=function() stopped=true end}}
screen.power.onclick()
assert(not C.active[0] and not V.work[0] and pending.closed and stopped,'physical power left screen or writing active')
assert(#sent==beforePower+1 and sent[#sent].command=='ledgerCancel','power did not cancel pending authoritative write')
q.queue=oldQueue

-- Server-disabled mode removes ledger/computer entry points and closes screens.
screen=assert(V.computer(0,computer));SandboxVars.B47ANCEDQuartermaster.LedgerMode=2
screen:prerender();assert(not C.active[0] and not V.readers[0])
assert(not V.computer(0,computer))
local entries={addOption=function() error('disabled ledger action was offered') end}
V.inventoryMenu(0,entries,{paper});V.worldMenu(0,entries,{computer},false)
SandboxVars.B47ANCEDQuartermaster.LedgerMode=1
print('PASS OFFLINE disabled ledger UI: menus suppressed, computer open refused, active screen closed')

-- Actual table production path: distinct identities, columns, details, native
-- selection/scroll, empty/redacted refreshes and minimum geometry. No pixel proof.
local rows={};local reads=0;local empty=false;local waiting=false;local redacted=false
local oldText=getText
getText=function(key,...)
 local values={...}
 if key=='UI_QMSS_LedgerItemLine' or key=='UI_QMSS_LedgerLocationLine' or key=='UI_QMSS_LedgerRecordedLine' then
  for n,v in ipairs(values) do values[n]=tostring(v) end;return table.concat(values,' | ')
 end
 local labels={UI_QMSS_LedgerTableItem='Item',UI_QMSS_LedgerTableQuantity='Quantity',UI_QMSS_LedgerTableLocation='Location'}
 return labels[key] or oldText(key,...)
end
for n=1,40 do rows[n]={name=n==2 and ('Long item '..string.rep('name ',60)) or 'Same display name',quantity=n*100,
 fullType='Fixture.Type'..n,condition=10,room='Workshop',roomID='fixture-room',container='Crate '..n,
 position={x=n,y=0,z=0,ci=0},recorded=42} end
local baseRequest=Q.Authority.request
Q.Authority.request=function(num,command,args,reply)
 if command~='ledgerRead' then return baseRequest(num,command,args,reply) end
 reads=reads+1
 reply(waiting and {status='waiting',summary='LedgerLoading'} or {status='ok',rows=empty and {} or rows,
  rooms=redacted and {} or {{id='fixture-room',name='Workshop'}},redacted=redacted,
  scope='Fixture building',summary='LedgerComplete',live=true,fresh=true,revision=1,cursor=args.cursor==nil and 'page-two' or nil})
end
getPlayerScreenWidth=function() return 3840 end;getPlayerScreenHeight=function() return 2160 end
for _,font in ipairs({14,24,32,42}) do
 getTextManager=function() return {getFontHeight=function() return font end,MeasureStringX=function(_,_,s) return #s*font/2 end} end
 screen=assert(V.computer(0,computer));screen:openDrive();if not screen.mounted then screen.content.insert.onclick() end;screen:runDisc()
 panel=assert(V.readers[0]);local controls=panel.ledgerControls;local list=controls.list;local tableView=assert(panel.ledgerTable)
 for _,size in ipairs({{screen.minimumWidth,screen.minimumHeight},{screen.minimumWidth+300,screen.minimumHeight+250}}) do
  screen:setWidth(size[1]);screen:setHeight(size[2]);screen:prerender();panel:prerender()
  assert(#tableView.columns==3 and list.itemheight==font+10,'ledger is still a multi-line list')
  assert(list.y>=tableView.headerY+U.Theme.metrics().button and list.height>=list.itemheight,'header overlaps first row')
  assert(list.y+list.height<=tableView.detailsY-8,'table overlaps details at font '..font)
  assert(tableView.detailsY+tableView.detailsHeight<=controls.close.y-8,'details overlap footer')
  assert(controls.previous.x+controls.previous.width<controls.more.x and controls.more.x+controls.more.width<controls.close.x,'footer buttons overlap')
  assert(list.vscroll.x+list.vscroll.width<=list.width and list.vscroll.height==list.height,'native scrollbar escaped table')
  local columns=tableView.columns
  assert(columns[1].x+columns[1].width==columns[2].x and columns[2].x+columns[2].width==columns[3].x)
  assert(columns[3].x+columns[3].width<=list.width-U.Theme.metrics().scrollbar,'Location overlaps scrollbar')
  local drawn={};list.drawText=function(_,s,x,y,r,g,b) drawn[#drawn+1]={s=s,x=x,y=y,r=r,g=g,b=b} end
  list.selected=2;list:setYScroll(0);list:doDrawItem(0,list.items[2],false)
  assert(#drawn==3 and drawn[2].s=='200' and drawn[1].r==C.colors.white.r,'columns/selection contrast lost')
  for i,cell in ipairs(drawn) do assert(cell.x>=columns[i].x and cell.x+#cell.s*font/2<=columns[i].x+columns[i].width-8,'cell overflows column') end
  assert(list.items[2].tooltip and list.items[2].tooltip:find('Fixture.Type2',1,true),'clipped item lost full detail tooltip')
  drawn={};list:doDrawItem(list.height+1,list.items[2],false);assert(#drawn==0,'offscreen row did formatting/drawing')
 end
 local reachable=false;for _,widget in ipairs(panel.allJoypadButtons) do if widget==list then reachable=true end end
 assert(reachable and list.joypadParent==panel and list.resetSelectionOnChangeFocus==false,'controller cannot select rows and return')
 list.selected=30;list:setYScroll(-150);rows[1],rows[30]=rows[30],rows[1];f.advance(2100);panel:prerender()
 assert(list.selected==1 and list.items[1].item.fullType=='Fixture.Type30' and list:getYScroll()==-150,'reordered live refresh lost exact item identity/scroll')
 local details={};panel.drawText=function(_,text) details[#details+1]=text end;panel:prerender()
 local found=false;for _,text in ipairs(details) do if text:find('Fixture.Type30',1,true) then found=true end end
 assert(found,'selected row metadata is missing from the details area')
 local T=require 'B47ANCEDQuartermaster/LedgerTable'
 assert(T.key(list.items[list.selected].item)==T.key(rows[1]) and T.key(rows[1])~=T.key(rows[2]))
 rows[1],rows[30]=rows[30],rows[1]
 controls.more.onclick();assert(tableView.page==2 and list.selected==1 and list:getYScroll()==0,'new page retained an unrelated selection')
 controls.previous.onclick();assert(tableView.page==1)
 local before=reads;for n=1,10 do panel:prerender() end;assert(reads==before,'table redraw emitted server requests')
 controls.search:setText('literal [item]');controls.search.onTextChangeFunction();f.advance(400);panel:prerender()
 assert(list.selected==1 and list:getYScroll()==0,'query change kept old page position')
 controls.rooms.selected=2;controls.rooms.onChange(panel,controls.rooms);f.advance(1);panel:prerender()
 empty=true;redacted=true;f.advance(2100);panel:prerender()
 assert(#list.items==0 and list.selected==-1 and tableView.count==0 and #controls.rooms.options==1,'redaction retained private rows/room choices')
 waiting=true;f.advance(2100);panel:prerender();assert(tableView.emptyLabel=='UI_QMSS_LedgerLoading','waiting result displayed an empty-success state')
 empty=false;waiting=false;redacted=false;screen:close()
end
for _,font in ipairs({14,24,32,42}) do
 getTextManager=function() return {getFontHeight=function() return font end,MeasureStringX=function(_,_,s) return #s*font/2 end} end
 panel=assert(V.read(0,paper));local controls=panel.ledgerControls;local list=controls.list;local tableView=panel.ledgerTable
 assert(panel.ledgerClipboard and tableView.paper and not controls.search and not controls.rooms,'paper is not a clipboard-only reader')
 assert(controls.previous.title=='UI_QMSS_LedgerClipboardPrevious' and controls.more.title=='UI_QMSS_LedgerClipboardNext','paper has no page-turn controls')
 for _,size in ipairs({{panel.minimumWidth,panel.minimumHeight},{panel.minimumWidth+280,panel.minimumHeight+230}}) do
  panel:setWidth(size[1]);panel:setHeight(size[2]);panel:prerender()
  assert(list.height>=list.itemheight and list.y+list.height<=tableView.detailsY-8,'clipboard table/details overlap')
  assert(tableView.detailsY+tableView.detailsHeight<=controls.close.y-8,'clipboard details/footer overlap')
  assert(controls.more.x+controls.more.width<controls.close.x and controls.close.y+controls.close.height<=panel.height-20,'page controls escape paper')
  assert(tableView.left>=38 and tableView.headerY>=66+2*font,'clip/title/header overlap')
  local lines={};local color=require('B47ANCEDQuartermaster/ClipboardArt').colors.shadow
  panel.drawRect=function(_,x,y,w,h,a,r,g,b)
   if h==1 and x==list.x+1 and w==list.width-2 and r==color.r and g==color.g then lines[#lines+1]=y end
  end
  list:setYScroll(-5);panel:prerender()
  assert(#lines>0 and lines[1]==list.y+list.itemheight-6,'paper ruling does not align with scrolled row boundaries')
  list:setYScroll(0)
 end
 assert(list.joypadParent==panel and panel.allJoypadButtons[1]==list,'paper rows unreachable by controller')
 assert(tableView.detailsHeight>=3*font+12,'paper details omit the selected item name')
 list.selected=2;local draw={};list.drawText=function(_,s,x,y,r,g,b) draw[#draw+1]={r=r,g=g,b=b} end
 list:doDrawItem(0,list.items[2],false);assert(draw[1].r==require('B47ANCEDQuartermaster/ClipboardArt').colors.black.r,'paper uses white screen text')
 controls.more.onclick();assert(tableView.page==2 and not controls.search,'paper page attempted digital search')
 controls.previous.onclick();assert(tableView.page==1)
 panel:onKeyRelease(Keyboard.KEY_ESCAPE);assert(not V.readers[0] and panel.removed,'clipboard Escape did not close local reader')
 panel=assert(V.read(0,paper));panel:onJoypadDown(Joypad.BButton);assert(not V.readers[0],'clipboard B did not close reader')
end
-- Ordinary reader errors must be visible on paper, not an eternal Loading line.
Q.Authority.request=function(_,command,_,reply) assert(command=='ledgerRead');reply({status='LedgerLiveUnavailable'}) end
panel=assert(V.read(0,paper));assert(panel.ledgerTable.status=='UI_QMSS_LedgerLiveUnavailable' and #panel.ledgerControls.list.items==0)
panel:close()
Q.Authority.request=baseRequest;getText=oldText;getTextManager=measure;getPlayerScreenWidth,getPlayerScreenHeight=width,height
print('PASS OFFLINE ledger table: columns, numeric alignment, clipping, selection contrast/details, exact row identity, live refresh/scroll, pages/query reset, redaction/empty/waiting states, controller access and 14/24/32/42 minimum layouts; native visual acceptance NOT TESTED')
print('PASS OFFLINE paper clipboard: original board/clip/ruled-sheet layout, three columns and ink contrast, details/page footer bounds at four font sizes, next/previous sheet, no digital query controls, Escape/B close and visible read failure')
