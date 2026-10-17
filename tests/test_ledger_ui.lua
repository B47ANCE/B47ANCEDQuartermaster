-- Existing owned UI surface plus the native base-action class; no pixel proof.
dofile(TEST_ROOT..'/test_load_settings_ui.lua')
local Q,U=B47ANCEDQuartermaster,B47ANCEDUI;local f=CONTAINER_FIXTURE;local actor=f.player
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
local panel=assert(V.read(0,paper));assert(not panel.ledgerControls.search and not panel.ledgerControls.rooms,'paper exposes digital controls')
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
for _,size in ipairs({{700,404},{1100,700}}) do
 screen:setWidth(size[1]);screen:setHeight(size[2]);screen:prerender();panel:prerender()
 assert(panel.ledgerControls.list.y+panel.ledgerControls.list.height<=panel.ledgerControls.close.y,'computer reader overlaps footer')
 assert(screen.start.x+screen.start.width<screen.task.x and screen.task.x+screen.task.width<screen.off.x,'taskbar overlap')
end
panel.ledgerControls.search:setText('5.56');panel.ledgerControls.search.onTextChangeFunction();f.advance(400);panel:prerender()
assert(sent[#sent].args.query=='5.56' and sent[#sent].args.cursor==nil)
screen:desktop();assert(screen.content==panel and V.readers[0]==panel,'minimize discarded application state')
screen.task.onclick();assert(screen.content==panel)
screen:eject();assert(not V.readers[0] and not screen.mounted,'eject left application running')
local afterEject=#sent;screen:runDisc();assert(#sent==afterEject,'empty drive ran application')
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
storageCD=false;f.advance(2100);screen:prerender();assert(not screen.mounted and not V.readers[0] and not screen.content,'lost media retained application/data')
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
screen:prerender();assert(not C.active[0] and not V.readers[0])
assert(not V.computer(0,computer))
local entries={addOption=function() error('disabled ledger action was offered') end}
V.inventoryMenu(0,entries,{paper});V.worldMenu(0,entries,{computer},false)
SandboxVars.B47ANCEDQuartermaster.LedgerMode=1
print('PASS OFFLINE disabled ledger UI: menus suppressed, computer open refused, active screen closed')
