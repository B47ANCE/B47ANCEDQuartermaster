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
local inv={getItemWithIDRecursiv=function(_,id) return id==900 and paper or id==901 and disc end,getItems=function() return f.list({paper,disc,cd}) end,containsTypeRecurse=function() return true end}
actor.getInventory=function() return inv end
f.network(true,false)
local sq=actor:getCurrentSquare();sq.haveElectricity=function() return true end;sq.hasGridPower=function() return false end;sq.getRoom=function() return {} end;sq.canReachTo=function() return true end
local computer=f.a;computer.getSprite=function() return {name='appliances_com_01_72'} end
local sent={}
Q.Authority.request=function(num,command,args,reply)
 sent[#sent+1]={command=command,args=args}
 if command=='ledgerRead' then reply({status='ok',rows={{name='Fixture item',quantity=5,fullType='Fixture.Item',condition=10,room='Fixture room',roomID='fixture-room',container='Fixture crate',position={x=0,y=0,z=0,ci=0},recorded=42}},rooms={{id='fixture-room',name='Fixture room'}},scope='Fixture building',summary='LedgerComplete',cursor=args.cursor==nil and 'next-page' or nil})
 else reply({status='ok'}) end
end
local V=require 'B47ANCEDQuartermaster/LedgerUI'
local panel=assert(V.read(0,paper));assert(not panel.ledgerControls.search and not panel.ledgerControls.rooms,'paper exposes digital controls')
panel:prerender();assert(#panel.ledgerControls.list.items==1)
panel:setWidth(800);panel:setHeight(620);panel:prerender()
assert(panel.ledgerControls.list.y+panel.ledgerControls.list.height<=panel.ledgerControls.close.y,'paper list overlaps footer')
panel.ledgerControls.more.onclick();assert(sent[#sent].args.cursor=='next-page')
panel.ledgerControls.previous.onclick();assert(sent[#sent].args.cursor==nil)
panel:onJoypadDown(Joypad.BButton);assert(not V.readers[0])
panel=assert(V.read(0,disc,computer));assert(panel.ledgerControls.search and panel.ledgerControls.rooms)
assert(#panel.ledgerControls.rooms.options==2,'digital room browser missing')
panel.ledgerControls.search:setText('5.56');panel.ledgerControls.search.onTextChangeFunction();f.advance(400);panel:prerender()
assert(sent[#sent].args.query=='5.56' and sent[#sent].args.cursor==nil)
sq.haveElectricity=function() return false end;panel:prerender();assert(not V.readers[0],'power loss left a digital reader open')
sq.haveElectricity=function() return true end
local menu=ISContextMenu.get(0);V.worldMenu(0,menu,{computer},false)
local burn
for _,option in ipairs(menu.options) do if option.sub then burn=option.sub end end
assert(burn and #burn.options==1 and burn.options[1].args,'CD selection menu missing')
assert(callbacks.OnFillInventoryObjectContextMenu and callbacks.OnFillWorldObjectContextMenu and callbacks.OnServerCommand)
print('PASS OFFLINE ledger UI: paper has no digital controls, pagination, footer bounds, controller close, digital literal query/room browser, power-loss close and explicit CD-choice context; native visual acceptance NOT TESTED')
