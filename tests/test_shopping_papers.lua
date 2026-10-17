-- Production server handlers/native timed action, engine-shaped host fixtures.
dofile(TEST_ROOT..'/test_ledger.lua')
local f=CONTAINER_FIXTURE;local x=LEDGER_FIXTURE;local actor=f.player;local inv=x.inv
local Q=B47ANCEDQuartermaster;local F=Q.ShoppingLists;local A=Q.Authority;local L=Q.Ledger
local manager=getScriptManager();manager.FindItem=function(_,t) return {getDisplayName=function() return t end} end
getScriptManager=function() return manager end
ModData.getOrCreate('B47ANCEDQuartermasterLedger').schema=1
SandboxVars.B47ANCEDQuartermaster.PhysicalShoppingLists=true
local _,account=Q.Personal.account(actor)
account.shopping={['Base.Nails']=40};account.shoppingSchema=2;account.projects={}
local function added(t) local it=x.item(t);function it:isEmptyPages() return not self.written end;function it:setName(n) self.name=n end;function it:setCustomName(v) self.custom=v end;function it:syncItemFields() end;return inv:AddItem(it) end
function instanceItem(t) local it=x.item(t);function it:setName(n) self.name=n end;function it:setCustomName(v) self.custom=v end;function it:syncItemFields() end;return it end
local function complete(offer)
 assert(offer.status=='action',offer.status)
 local c=require 'B47ANCEDQuartermaster/LedgerAction'
 local a=assert(c:new(actor,offer.token));assert(not c:new(actor,offer.token));a.action={setActionAnim=function() end};a:start()
 local ok=a:complete();assert(not a:complete(),'native completion replay accepted');return ok
end
local snap=A.handle(actor,'personalList',{});assert(snap.status=='ok' and snap.paper.enabled and snap.paper.legacy and snap.gross==0,'legacy silently used without paper')
local blank=added('Base.SheetPaper2')
assert(A.handle(actor,'shoppingPaperCreate',{name='Run A',operation='missing-book'}).status=='ShoppingWritingRequired')
local book=added('Base.Notebook')
blank.written=true;assert(A.handle(actor,'shoppingPaperCreate',{name='Run A',operation='written'}).status=='ShoppingBlankRequired');blank.written=false
local before=#inv.items
local offer=A.handle(actor,'shoppingPaperCreate',{name='Hardware run',operation='create-a'})
assert(offer.status=='action');assert(not L.complete(actor,offer.token,{}),'forged timed completion')
-- The forged call retired that grant without converting inventory.
assert(#inv.items==before)
offer=A.handle(actor,'shoppingPaperCreate',{name='Hardware run',operation='create-a2'});assert(complete(offer))
assert(#inv.items==before and not inv:getItemWithID(blank:getID()) and inv:getItemWithID(book:getID())==book,'paper/tool conservation')
snap=A.handle(actor,'personalList',{});local paperID=assert(snap.paper.selected);local paper,record=F.binding(actor,paperID)
assert(paper and paper:getFullType()==F.itemType and record.name=='Hardware run' and snap.gross==0)
assert(A.handle(actor,'shoppingPaperCreate',{name='Hardware run',operation='create-a2'}).status=='ShoppingPaperCreated','replay minted another paper')
assert(#inv.items==before)
assert(A.handle(actor,'personalChange',{kind='shopping',fullType='Base.Nails',quantity=12,revision=snap.revision}).status=='ShoppingPaperMissing','missing exact paper accepted')
snap=A.handle(actor,'personalChange',{kind='shopping',fullType='Base.Nails',quantity=12,revision=snap.revision,paper=paperID});assert(snap.status=='ok' and snap.manual['Base.Nails']==12)
local stale=snap.revision
snap=A.handle(actor,'shoppingPaperRename',{item=paperID,name='Tool run',revision=stale});assert(snap.status=='ok' and record.name=='Tool run')
assert(A.handle(actor,'shoppingPaperRename',{item=paperID,name='Stale',revision=stale}).status=='conflict')
inv:Remove(book)
assert(A.handle(actor,'shoppingPaperRead',{item=paperID}).status=='ok','reading required writing supplies')
assert(A.handle(actor,'personalChange',{kind='shopping',fullType='Base.Nails',quantity=13,revision=snap.revision,paper=paperID}).status=='ShoppingWritingRequired')
inv:AddItem(book)
-- A second independent list; old IDs cannot accidentally edit the newly selected list.
added('Base.SheetPaper2');assert(complete(A.handle(actor,'shoppingPaperCreate',{name='Food run',operation='create-b'})))
local b=A.handle(actor,'personalList',{});local second=assert(b.paper.selected);assert(second~=paperID and #b.paper.lists==2 and b.gross==0)
assert(A.handle(actor,'personalChange',{kind='shopping',fullType='Base.Nails',quantity=1,revision=b.revision,paper=paperID}).status=='ShoppingPaperMissing')
snap=A.handle(actor,'shoppingPaperSelect',{item=paperID});assert(snap.status=='ok' and snap.manual['Base.Nails']==12)
assert(A.handle(actor,'shoppingPaperRead',{item=second}).manual['Base.Nails']==nil)
assert(A.handle(actor,'personalList',{}).paper.selected==paperID,'HUD read changed active list')
-- Loss while walking stops the next native TAKE grant; cancellation still works.
actor.getMaxWeight=function() return 100 end;actor.getWornItems=function() return f.list() end
actor.getPrimaryHandItem=function() end;actor.getSecondaryHandItem=function() end
actor.square=f.a:getSquare()
local sourceNail=x.item('Base.Nails');f.a.containers[1]:AddItem(sourceNail)
local started=A.handle(actor,'shoppingBegin',{paper=paperID});assert(started.status=='ok',started.status)
local nextItem=A.handle(actor,'shoppingNext',{run=started.run});assert(nextItem.status=='ok',nextItem.status)
inv:Remove(paper)
assert(A.handle(actor,'moveTake',{operation=nextItem.operation}).status=='ShoppingPaperMissing','lost paper granted new withdrawal')
assert(A.handle(actor,'shoppingCancel',{run=started.run}).status=='ok');inv:AddItem(paper)
started=A.handle(actor,'shoppingBegin',{paper=paperID});assert(started.status=='ok')
nextItem=A.handle(actor,'shoppingNext',{run=started.run});assert(nextItem.status=='ok')
assert(A.handle(actor,'moveTake',{operation=nextItem.operation}).status=='ok')
f.a.containers[1]:Remove(sourceNail);inv:AddItem(sourceNail)
assert(A.handle(actor,'moveCarried',{operation=nextItem.operation}).status=='ok','completed native observation lost credit')
assert(A.handle(actor,'personalList',{}).carried==1)
assert(A.handle(actor,'shoppingCancel',{run=started.run}).status=='ok')
-- Real paper moves to another actor; source loses read/edit/collection rights.
local otherInv=x.container();local other=setmetatable({ownMD={}}, {__index=actor})
function other:getInventory() return otherInv end;function other:getModData() return self.ownMD end
function other:getUsername() return 'friend' end
inv:Remove(paper);otherInv:AddItem(paper)
assert(A.handle(actor,'shoppingPaperRead',{item=paperID}).status=='ShoppingPaperMissing')
local friend=A.handle(other,'shoppingPaperRead',{item=paperID});assert(friend.status=='ok' and friend.manual['Base.Nails']==12,'hand-off lost plan')
assert(A.handle(other,'shoppingPaperSelect',{item=paperID}).status=='ok')
assert(F.runValid(other,{paper=paperID}) and not F.runValid(actor,{paper=paperID}),'run capability survived hand-off')
assert(A.handle(other,'personalChange',{kind='shopping',fullType='Base.Nails',quantity=4,revision=friend.revision,paper=paperID}).status=='ShoppingWritingRequired')
-- Forging the visible item marker on another native paper cannot clone the list.
local forged=added(F.itemType);forged:getModData().B47ShoppingPaper=paper:getModData().B47ShoppingPaper
assert(not F.binding(actor,forged:getID()))
-- Import once; keep the account backup, and preserve a snapshot of personal goal intent.
added('Base.SheetPaper2');account.wish={['Base.Nails']=50};account.wishDemand={['Base.Nails']=true}
assert(complete(A.handle(actor,'shoppingPaperCreate',{name='Old plan',operation='import-a',import=true})))
local imported=A.handle(actor,'personalList',{});assert(imported.manual['Base.Nails']==40 and account.shopping['Base.Nails']==40 and not imported.paper.legacy)
local importedID=imported.paper.selected;local importedItem,importedRecord=F.binding(actor,importedID);assert(importedRecord.paperTargets.wish['Base.Nails']==50)
assert(A.handle(actor,'shoppingPaperCreate',{name='Duplicate import',operation='import-b',import=true}).status=='ShoppingAlreadyImported')
-- Each holder's carried quantity is allocated independently; linked targets travel with paper.
local nails=added('Base.Nails');local beforeCredit=A.handle(actor,'personalList',{})
inv:Remove(importedItem);otherInv:AddItem(importedItem);otherInv:AddItem(x.item('Base.Nails'))
friend=A.handle(other,'shoppingPaperRead',{item=importedID});assert(friend.gross==beforeCredit.gross and friend.carried==1,'portable linked demand followed recipient personal goals')
assert(friend.wishDemand['Base.Nails']==49 and friend.linkedGoals.wanted['Base.Nails'].target==50,'portable provenance row disappeared for recipient')
assert(A.handle(other,'shoppingPaperSelect',{item=importedID}).status=='ok')
otherInv:AddItem(x.item('Base.Notebook'));otherInv:AddItem(x.item('Base.Pencil'))
local removed=A.handle(other,'shoppingSourceRemove',{kind='wanted',fullType='Base.Nails',paper=importedID,revision=friend.revision})
assert(removed.status=='ok' and removed.gross==40 and removed.wishDemand['Base.Nails']==nil and account.wishDemand['Base.Nails'],'recipient could not remove portable provenance independently')
-- Future/corrupt roots are preserved and denied, never reset.
local root=ModData.getOrCreate('B47ANCEDQuartermasterShoppingPapers');root.schema=99
assert(A.handle(other,'shoppingPaperRead',{item=importedID}).status~='ok' and root.schema==99);root.schema=1
-- Rollback when native Remove leaves input present; no duplicate output survives.
local failedBlank=added('Base.SheetPaper2');local count=#inv.items;inv.failRemove=failedBlank
offer=A.handle(actor,'shoppingPaperCreate',{name='Fails safely',operation='failure'});assert(not complete(offer));assert(#inv.items==count and inv:getItemWithID(failedBlank:getID())==failedBlank)
inv.failRemove=nil
-- Dedicated-shaped native action requires the authenticated challenge AND native clock.
SandboxVars.B47ANCEDQuartermaster.LedgerMode=2 -- Supply ledgers off must not disable native Shopping Paper confirmation.
f.network(false,true);local challenge
function sendServerCommand(_,_,command,data) if command=='challenge' then challenge=data.challenge end end
offer=A.handle(actor,'shoppingPaperCreate',{name='Server paper',operation='server-create'});assert(offer.status=='action')
local cls=require 'B47ANCEDQuartermaster/LedgerAction';local action=assert(cls:new(actor,offer.token));local progress=0
action.netAction={getProgress=function() return progress end};assert(action:serverStart() and challenge)
assert(L.handle(actor,'ledgerConfirm',{token=offer.token,challenge='forged'}).status=='denied')
assert(L.handle(actor,'ledgerConfirm',{token=offer.token,challenge=challenge}).status=='ok');progress=1
assert(action:complete() and not action:complete());f.network(false,false)
SandboxVars.B47ANCEDQuartermaster.LedgerMode=4
-- Server option restores the untouched legacy personal plan; paper root remains.
SandboxVars.B47ANCEDQuartermaster.PhysicalShoppingLists=false
local legacy=A.handle(actor,'personalList',{});assert(not legacy.paper.enabled and legacy.manual['Base.Nails']==40 and root.schema==1)
print('PASS OFFLINE physical shopping papers: material conservation, native grant/challenge boundary, replay/stale refusal, separate lists, trade capability, carried credit, frozen linked demand, non-destructive import, rollback and future-schema refusal; not PZ runtime')
