-- Real production inspection/conversion generates the accepted server bindings.
dofile(TEST_ROOT..'/test_ledger.lua')
local F,f=LEDGER_FIXTURE,CONTAINER_FIXTURE;local actor=f.player
local Q=B47ANCEDQuartermaster;local L=Q.Ledger;local G=require 'B47ANCEDQuartermaster/LedgerRequirement'
local D=require 'B47ANCEDQuartermaster/LedgerDrives';local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local data=ModData.getOrCreate('B47ANCEDQuartermasterLedger');data.schema=1 -- disposable future-schema test ends here
local opts=SandboxVars.B47ANCEDQuartermaster;opts.RequireLedgerForSorting=nil;opts.RequireLedgerForCollecting=nil
assert(G.enabled('area') and G.enabled('shopping'),'new default was not enabled')
local home=actor.square;local saved={};for _,v in ipairs(F.inv.items) do saved[#saved+1]=v end
F.inv.items={};F.inv:AddItem(F.item('Base.Pen'));local forged=F.inv:AddItem(F.item(Media.sheet));forged.md.B47Ledger={schema=1,complete=true,snapshot=F.paper.md.B47Ledger.snapshot}
local why;local ok;ok,why=G.check(actor,home,'area');assert(not ok and why=='LedgerRequired','forged metadata bypassed server binding')
assert(Q.Trips.handle(actor,'tripBegin',{area=true}).status=='LedgerRequired')
assert(Q.Shopping.handle(actor,'shoppingBegin',{}).status=='LedgerRequired')
assert(Q.Authority.handle(actor,'personalList',{}).status=='ok','shopping planning/list access was gated')
F.inv:AddItem(F.paper);f.advance(1100);assert(G.check(actor,home,'area'))
assert(not Q.Movement.eligible(actor,F.paper),'sorting could remove its own carried proof')
-- Positive production TAKE, loss before PUT, and a safe native return.
actor.getMaxWeight=function() return 100 end
local round=F.item('Fixture.RoundA','RoundA');round.getScriptItem=function() return CATALOG_FIXTURE.items[1] end
f.a.containers[1]:AddItem(round)
local discovery=assert(Q.Bindings.discover(actor,{scope={x=home:getX(),y=home:getY(),z=home:getZ()}}));local records={}
for _,r in pairs(Q.Bindings.sessions[actor].records) do records[r.target.obj]=r end
local dest=records[f.b];dest.original=Q.Schema.empty();dest.revision=0
local config=Q.Schema.empty();config.items.RoundA=true;assert(Q.Store.commit(dest,config))
-- Manual selected-container Sort succeeds without knowledge even when the
-- server's scoped requirement is enabled. Only a real area context is retained.
F.inv:Remove(F.paper)
local args={session=discovery.session,source=records[f.a].token,itemID=round:getID()}
local manual=Q.Movement.handle(actor,'movePlan',args);assert(manual.status=='ok',manual.status)
assert(not Q.Movement.operations[actor].area)
assert(Q.Movement.handle(actor,'moveTake',{operation=manual.operation}).status=='ok')
assert(Q.Movement.handle(actor,'moveCancel',{operation=manual.operation}).status=='ok')
F.inv:AddItem(F.paper)
local planned,areaOperation=Q.Movement.planOne(actor,args,{area=true,accepts=function() return true end})
assert(planned.status=='ok' and areaOperation and areaOperation.area,'area context was not retained on the actual operation')
Q.Movement.operations[actor]=areaOperation
local function move(command) return Q.Movement.handle(actor,command,{operation=planned.operation}) end
assert(move('moveTake').status=='ok');f.a.containers[1]:Remove(round);F.inv:AddItem(round)
assert(move('moveCarried').status=='ok');F.inv:Remove(F.paper)
assert(move('movePut').status=='LedgerRequired' and F.inv:getItemWithID(round:getID())==round)
assert(move('moveRevert').status=='ok','ledger loss blocked safe native return')
F.inv:Remove(round);f.a.containers[1]:AddItem(round);assert(move('moveReverted').status=='ok')
F.inv:AddItem(F.paper)
-- Collection's exact native withdrawal grant also accepts genuine carried proof.
local collection={item=round,collected=0};local offer,op=Q.Movement.withdraw(actor,records[f.a],0,collection)
assert(offer.status=='ok' and op and op.withdrawal);Q.Movement.operations[actor]=op
assert(Q.Movement.handle(actor,'moveTake',{operation=op.id}).status=='ok')
f.a.containers[1]:Remove(round);F.inv:AddItem(round)
assert(Q.Movement.handle(actor,'moveCarried',{operation=op.id}).collected and collection.collected==1)
F.inv:Remove(round);f.a.containers[1]:AddItem(round)
local s=L.snapshotFor(F.paper);local prior=s.status;s.status='LedgerPartial';assert(not G.check(actor,home,'area'),'partial ledger qualified');s.status=prior
F.inv:Remove(F.paper);assert(not G.check(actor,home,'area'),'stale candidate cache accepted a removed paper')
-- A genuine completed record for a different native building does not qualify.
local rd=setmetatable({getID=function() return 88 end,getX=function() return 20 end,getX2=function() return 21 end,getY=function() return 0 end,getY2=function() return 1 end},{__index=F.definition})
local bd={getRooms=function() return f.list({rd}) end};local other={getDef=function() return bd end}
local elsewhere=f.square(20,0,0,other);actor.square=elsewhere
local wrong=F.inv:AddItem(F.item(Media.sheet));F.run(wrong);actor.square=home;f.advance(1100)
assert(not G.check(actor,home,'area'),'same display label / wrong building qualified')
-- The CD stays a real item in existing adjacent storage. No attach/eject mutation.
local storage=f.unrelatedObject;local c=storage.containers[1];c:AddItem(F.disc)
assert(not G.check(actor,home,'area'),'unloaded CD in storage qualified')
local list=L.handle(actor,'ledgerDriveList',{computer=F.position});assert(list.status=='ok' and #list.choices==1)
local stranger=setmetatable({getUsername=function() return 'other-player' end},{__index=actor})
assert(D.handle(stranger,'ledgerDriveMount',{computer=F.position,token=list.choices[1].token}).status=='LedgerDriveChanged','offer was not sender bound')
local permission=Q.RoomAccess.can
Q.RoomAccess.can=function(a,t,action) if t.obj==F.computer and action=='configure' then return false end;return permission(a,t,action) end
assert(L.handle(actor,'ledgerDriveMount',{computer=F.position,token=list.choices[1].token}).status=='RoomAccessDenied','inspect access granted configuration')
Q.RoomAccess.can=permission
local n=#c.items;local loaded=L.handle(actor,'ledgerDriveMount',{computer=F.position,token=list.choices[1].token})
assert(loaded.status=='ok' and #c.items==n and c:getItemWithID(F.disc:getID())==F.disc)
assert(G.check(actor,home,'area') and D.protected(F.disc))
assert(not Q.Movement.eligible(actor,F.disc),'mounted storage CD was not protected from automatic movement')
assert(L.handle(actor,'ledgerRead',{computer=F.position,drive=loaded.mounted.drive,item=F.disc:getID()}).status=='ok')
assert(L.handle(actor,'ledgerBurn',{computer=F.position,item=F.paper:getID(),cd=1}).status~='action')
-- Closing a client UI / reconnecting does not clear the persistent binding.
D.offers[actor]=nil;package.loaded['B47ANCEDQuartermaster/LedgerDrives']=nil
local reloaded=require 'B47ANCEDQuartermaster/LedgerDrives'
assert(reloaded.provider(actor,loaded.mounted.drive),'saved drive could not re-resolve real native storage')
F.setPower(false);assert(not G.check(actor,home,'area'),'unpowered computer qualified');F.setPower(true)
local access=Q.RoomAccess.can;Q.RoomAccess.can=function() return false end
assert(not G.check(actor,home,'area'),'private computer/storage permission was cached');Q.RoomAccess.can=access
local far=f.square(40,0,0,F.building);actor.square=far
assert(G.check(actor,far,'area'),'same-building computer incorrectly used near distance limit');actor.square=home
c:Remove(F.disc);assert(not G.check(actor,home,'area'),'stale native container pointer accepted absent CD');c:AddItem(F.disc)
assert(G.check(actor,home,'area'))
assert(L.handle(actor,'ledgerDriveEject',{computer=F.position,drive='stale'}).status=='LedgerDriveChanged')
assert(L.handle(actor,'ledgerDriveEject',{computer=F.position,drive=loaded.mounted.drive}).status=='ok' and #c.items==n)
assert(not G.check(actor,home,'area') and not reloaded.protected(F.disc))
-- A nearby computer outside the work building can qualify, within server range.
local outside=f.square(3,0,0);outside.haveElectricity=function() return true end;outside.hasGridPower=function() return false end;outside.getRoom=function() end;outside.canReachTo=function() return true end
local terminal=f.object(outside,f.grid,nil,false);terminal.getSprite=function() return {name='appliances_com_01_72'} end
local desk=f.object(outside,f.grid);desk.containers={F.container()};c:Remove(F.disc);desk.containers[1]:AddItem(F.disc)
local p={x=3,y=0,z=0,index=terminal:getObjectIndex()};actor.square=outside
list=L.handle(actor,'ledgerDriveList',{computer=p});assert(#list.choices==1)
local near=L.handle(actor,'ledgerDriveMount',{computer=p,token=list.choices[1].token});assert(near.status=='ok');actor.square=home
opts.LedgerComputerRange=2;assert(not G.check(actor,home,'area'),'outside-building computer exceeded configured range')
opts.LedgerComputerRange=3;assert(G.check(actor,home,'area'),'nearby powered computer was not recognized')
actor.square=outside;L.handle(actor,'ledgerDriveEject',{computer=p,drive=near.mounted.drive});actor.square=home;opts.LedgerComputerRange=nil
-- Lost knowledge rejects NEW grants, while observing completed native PUT is safe.
local moved=F.inv:AddItem(F.item('Fixture.Moved'));local M=Q.Movement
local op={area=true,id='lost-proof',time=getTimestampMs(),item=moved,carrier=F.inv,carrierID=0,destination={obj=f.b,container=f.b.containers[1]},phase='carried'}
M.operations[actor]=op
assert(M.handle(actor,'movePut',{operation=op.id}).status=='LedgerRequired' and F.inv:getItemWithID(moved:getID())==moved)
F.inv:Remove(moved);f.b.containers[1]:AddItem(moved);op.phase='put'
assert(M.handle(actor,'moveDone',{operation=op.id}).status=='ok' and not M.operations[actor],'completed native movement was discarded after proof loss')
opts.RequireLedgerForSorting=false;assert(G.check(actor,home,'area') and not G.check(actor,home,'shopping'))
opts.RequireLedgerForCollecting=false;assert(G.check(actor,home,'shopping'))
opts.RequireLedgerForSorting=true;opts.RequireLedgerForCollecting=true
F.inv:AddItem(F.paper);f.advance(1100);assert(G.check(actor,home,'area'))
local oldID=F.definition.getID;F.definition.getID=function() return 99 end;f.advance(1100)
assert(not G.check(actor,home,'area'),'native building classification cache never invalidated')
F.definition.getID=oldID;f.advance(1100);assert(G.check(actor,home,'area'))
local drives=ModData.getOrCreate('B47ANCEDQuartermasterLedgerDrives');drives.schema=99
assert(D.handle(actor,'ledgerDriveList',{computer=F.position}).status=='schema' and drives.schema==99,'future drive data was reset')
print('PASS OFFLINE knowledge gate: real completed bindings, forged/partial/wrong-location refusal, planning without proof, opt-outs, adjacent stored-CD load/eject with no item mutation, sender binding, persisted re-resolution, power/private/media-loss rechecks, same-building distance, new PUT denial and completed native observation')
