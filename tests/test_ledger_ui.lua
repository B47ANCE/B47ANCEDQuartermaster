-- Existing owned UI surface plus the native base-action class; no pixel proof.
dofile(TEST_ROOT..'/test_load_settings_ui.lua')
local Q,U=B47ANCEDQuartermaster,B47ANCEDUI;SandboxVars.B47ANCEDQuartermaster.RequireComputerApplication=false;local f=CONTAINER_FIXTURE;local actor=f.player
local callbacks={};LEDGER_UI_COMMANDS={};Events={}
for _,name in ipairs({'OnTick','OnFillInventoryObjectContextMenu','OnFillWorldObjectContextMenu','OnServerCommand'}) do Events[name]={Add=function(fn) callbacks[name]=fn;if name=='OnServerCommand' then LEDGER_UI_COMMANDS[#LEDGER_UI_COMMANDS+1]=fn end end} end
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
assert(panel.ledgerClipboard and panel.ledgerTable.paper,'paper lost clipboard presentation')
panel:prerender();assert(#panel.ledgerControls.list.items==1)
panel:setWidth(800);panel:setHeight(620);panel:prerender()
assert(panel.ledgerControls.list.y+panel.ledgerControls.list.height<=panel.ledgerControls.close.y,'paper list overlaps footer')
panel.ledgerControls.more.onclick();assert(sent[#sent].args.cursor=='next-page')
panel.ledgerControls.previous.onclick();assert(sent[#sent].args.cursor==nil)
panel:onJoypadDown(Joypad.BButton);assert(not V.readers[0])
local before=readCount()
local C=require 'B47ANCEDQuartermaster/ComputerUI'
local screen=assert(V.computer(0,computer));assert(not screen.content and readCount()==before,'computer auto-ran the ledger')
assert(V.computer(0,computer)==screen,'duplicate computer screen')
local drive=screen:openDrive();assert(readCount()==before and not V.readers[0],'drive browser auto-read the CD')
drive.insert.onclick();assert(screen.mounted:getID()==901 and readCount()==before,'inserting CD auto-ran it')
assert(not V.readers[0]);screen.content.run.onclick()
panel=assert(V.readers[0]);assert(screen.content==panel and panel.parent and not panel.removed,'reader is not embedded')
assert(readCount()==before+1 and panel.ledgerControls.search and panel.ledgerControls.rooms)
assert(panel.ledgerControls.search.nativeTextColor[1]<.1,'native text-entry glyphs stayed white on white')
assert(#panel.ledgerControls.rooms.options==2,'digital room browser missing')
panel:prerender();assert(panel.ledgerTable and #panel.ledgerTable.columns==3,'approved computer table/detail controls missing')
for _,size in ipairs({{700,404},{1100,700}}) do
 screen:setWidth(size[1]);screen:setHeight(size[2]);screen:prerender();panel:prerender()
 assert(panel.ledgerControls.list.y+panel.ledgerControls.list.height<=panel.ledgerControls.close.y,'computer reader overlaps footer')
 assert(panel.ledgerTable.headerY+U.Theme.metrics().button<=panel.ledgerControls.list.y,'table header overlaps rows')
 assert(panel.ledgerControls.list.y+panel.ledgerControls.list.height<=panel.ledgerTable.detailsY,'table overlaps selected record details')
 assert(panel.ledgerTable.detailsY+panel.ledgerTable.detailsHeight<=panel.ledgerControls.close.y,'record details overlap footer')
 assert(screen.start.x+screen.start.width<screen.task.x and screen.task.x+screen.task.width<screen.off.x,'taskbar overlap')
end
panel.ledgerControls.search:setText('5.56');panel.ledgerControls.search.onTextChangeFunction();f.advance(400);panel:prerender()
assert(sent[#sent].args.query=='5.56' and sent[#sent].args.cursor==nil)
screen:desktop();assert(screen.content==panel and V.readers[0]==panel,'minimize discarded application state')
screen.task.onclick();assert(screen.content==panel)
screen:eject();assert(not V.readers[0] and not screen.mounted,'eject left application running')
local afterEject=#sent;screen:runDisc();assert(#sent==afterEject,'empty drive ran application')
local writer=screen:openWriter();local beforeWrite=#sent
local reusable=false;for _,option in ipairs(writer.cd.options) do if option.data==disc then reusable=true end end
assert(reusable,'existing ledger CD was not selectable for an in-place update')
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
storageCD=false;f.advance(2100);screen:prerender();assert(not screen.mounted and not V.readers[0] and not screen.content,'lost media retained application/data')
storageCD=true;serverMounted=false;screen:close()
-- Large font minimums leave the warning text above the writer footer.
local measure=getTextManager;local width,height=getPlayerScreenWidth,getPlayerScreenHeight
getPlayerScreenWidth=function() return 3840 end;getPlayerScreenHeight=function() return 2160 end
for _,font in ipairs({24,32,42}) do
 getTextManager=function() return {getFontHeight=function() return font end,MeasureStringX=function(_,_,s) return #s*font/2 end} end
 screen=assert(V.computer(0,computer));screen:setWidth(screen.minimumWidth);screen:setHeight(screen.minimumHeight);screen:prerender()
 drive=screen:openDrive();if not screen.mounted then drive.insert.onclick() end;screen:runDisc();panel=assert(V.readers[0]);panel:prerender()
 assert(panel.ledgerControls.list.y+panel.ledgerControls.list.height<=panel.ledgerTable.detailsY,'large-font table overlaps details')
 assert(panel.ledgerTable.detailsY+panel.ledgerTable.detailsHeight<=panel.ledgerControls.close.y,'large-font details overlap footer')
 writer=screen:openWriter();writer:prerender();local metrics=U.Theme.metrics()
 assert(writer.write.y>=48+3*metrics.font+2*metrics.button,'large-font writer warning overlaps action')
 assert(writer.write.y+writer.write.height<=writer:getHeight()-8)
 screen:onJoypadDown(Joypad.BButton);assert(screen.content==writer,'controller minimize lost application')
 screen:close()
end
getTextManager=measure;getPlayerScreenWidth,getPlayerScreenHeight=width,height
Keyboard=Keyboard or {};Keyboard.KEY_ESCAPE=1
screen=assert(V.computer(0,computer));screen:openWriter();screen:onKeyRelease(Keyboard.KEY_ESCAPE)
assert(not screen.content and C.active[0]==screen,'Escape did not return to desktop')
screen:onKeyRelease(Keyboard.KEY_ESCAPE);assert(not C.active[0],'desktop Escape did not shut down')
print('PASS OFFLINE Windows 93 ledger UI: desktop has no automatic reads, explicit CD insert/run and EXE double-click, embedded literal search/rooms, resize/footer/taskbar at 14/24/32/42 font heights, minimize/eject, exact media-loss cleanup, explicit writer choices, shutdown cancellation, Escape/controller and power-loss close; paper navigation preserved; native visual acceptance NOT TESTED')

-- Server-disabled mode removes ledger/computer entry points and closes screens.
screen=assert(V.computer(0,computer));SandboxVars.B47ANCEDQuartermaster.LedgerMode=2
screen:prerender();assert(not C.isLive(screen) and not V.readers[0] and C.desktops[0],'disabling Quartermaster logged off the independent desktop')
assert(not V.computer(0,computer))
local entries={addOption=function() error('disabled ledger action was offered') end}
V.inventoryMenu(0,entries,{paper});V.worldMenu(0,entries,{computer},false)
SandboxVars.B47ANCEDQuartermaster.LedgerMode=1
print('PASS OFFLINE disabled ledger UI: menus suppressed, computer open refused, active screen closed')

-- Writer and ledger use separate taskbar windows; completion stays with its owner.
local PC=require 'B47ANCEDPCFramework/API'
screen=assert(V.computer(0,computer));drive=screen:openDrive();drive.insert.onclick();screen:runDisc();panel=assert(V.readers[0])
local d=C.desktops[0];local tool
for _,entry in ipairs(d.entries) do if entry.id=='quartermaster' and entry.kind=='tool' then tool=entry end end
assert(tool,'writer missing from the shared launcher');d:launch(tool)
local writerHost=C.active[0];assert(writerHost~=screen and writerHost.root==screen.root and screen.content==panel,'writer replaced the ledger window')
local oldMessage=writerHost.message;local messages=0
writerHost.message=function(self,key) messages=messages+1;return oldMessage(self,key) end
V.burn(0,paper,cd,computer,writerHost);V.work[0].token='writer-result'
local mines=assert(PC.open(0,computer,'b47pc.minesweeper'));mines.message=function() error('writer status crossed into another app') end
require('B47ANCEDQuartermaster/Ledger').clientResult(actor,{token='writer-result',status='ok'})
assert(messages==1 and not V.work[0] and V.readers[0]==panel,'background writer completion lost its window/ledger')
screen:close();assert(not C.active[0] and not C.desktops[0])
print('PASS OFFLINE approved ledger table: independent writer/ledger tasks, selected details and owner-bound writer completion while another app is active')

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
