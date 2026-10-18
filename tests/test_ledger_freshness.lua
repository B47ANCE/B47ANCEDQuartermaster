-- Real production records/native-action fixtures, never fabricated media bindings.
dofile(TEST_ROOT..'/test_ledger.lua')
local Q=B47ANCEDQuartermaster;local F,f=LEDGER_FIXTURE,CONTAINER_FIXTURE
local L=Q.Ledger;local G=require 'B47ANCEDQuartermaster/LedgerRequirement'
local P=require 'B47ANCEDQuartermaster/LedgerPolicy';local D=require 'B47ANCEDQuartermaster/LedgerDrives'
local opts=SandboxVars.B47ANCEDQuartermaster;local actor=f.player
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
assert(Scope.signature(Scope.capture(actor,'building'))=='building:77|0:0:2:2:0:0','scope policy invalidated existing building ledger coverage')
local unassigned=Scope.room(actor,{getX=function() return 0 end,getY=function() return 0 end,getZ=function() return 0 end,getRoom=function() error('native room used as organization') end})
assert(unassigned=='unassigned:0','native room became a current ledger grouping')
local root=ModData.getOrCreate('B47ANCEDQuartermasterLedger');root.schema=1
local age=42.5;getGameTime=function() return {getWorldAgeHours=function() return age end} end
opts.LedgerMode=nil;opts.LedgerUpdateDays=nil;opts.RequireLedgerForSorting=true;opts.RequireLedgerForCollecting=true
assert(P.mode()==1 and P.days()==7 and P.manualComputer())
assert(not G.enabled('sort') and G.enabled('area'))
local saved={};for _,it in ipairs(F.inv.items) do saved[#saved+1]=it end
F.inv.items={}
assert(G.check(actor,actor.square,'sort'),'manual Sort required a filled ledger')
assert(not G.check(actor,actor.square,'area'))
assert(Q.RoomScopes.handle(actor,'areaDiscover',{}).status=='LedgerRequired','area discovery bypassed knowledge')
assert(Q.Trips.handle(actor,'tripBegin',{area=true}).status=='LedgerRequired')
assert(Q.Trips.handle(actor,'tripBegin',{}).status~='LedgerRequired','single-inventory job still gated')
F.inv.items=saved;f.advance(1100)
local original=L.snapshotFor(F.paper);local cdOriginal=L.snapshotFor(F.disc)
assert(P.fresh(original) and G.check(actor,actor.square,'area'))
local function read(args)
 for _=1,200 do
  local out=L.handle(actor,'ledgerRead',args)
  if out.status~='waiting' then return out end
  f.advance(251);L.tick()
 end
 error('bounded live reader did not finish')
end
local function quantity(view,t)
 local n=0;for _,row in ipairs(view.rows or {}) do if row.fullType==t then n=n+row.quantity end end;return n
end
local first=read({item=F.paper:getID()});assert(first.status=='ok' and first.live and first.fresh,first.status)
local add=F.item('Fixture.LiveOnly','Live only',3);f.a.containers[1]:AddItem(add);f.advance(5100)
local current=read({item=F.paper:getID()})
assert(current.status=='ok' and current.live and quantity(current,'Fixture.LiveOnly')==3,current.status)
assert(original==L.snapshotFor(F.paper) and quantity({rows=original.entries[original.order[1]].rows},'Fixture.LiveOnly')==0,'live read rewrote history')
local permission=Q.RoomAccess.can
Q.RoomAccess.can=function() return false end
local denied=L.handle(actor,'ledgerRead',{item=F.paper:getID()});assert(denied.status=='ok' and #denied.rows==0 and denied.redacted,'live cache disclosed revoked storage')
Q.RoomAccess.can=permission
age=original.finished+7*24-0.01;assert(P.fresh(original))
age=original.finished+7*24;assert(not P.fresh(original) and not G.check(actor,actor.square,'area'),'expiry boundary is not exact')
local expired=read({item=F.paper:getID()});assert(expired.status=='ok' and not expired.live and not expired.fresh and quantity(expired,'Fixture.LiveOnly')==0)
assert(G.check(actor,actor.square,'sort'),'expired ledger blocked manual Sort')
opts.LedgerMode=3;assert(P.fresh(original) and G.check(actor,actor.square,'area'))
assert(read({item=F.paper:getID()}).live,'no-update mode was not live')
opts.LedgerMode=4;age=original.finished
local historical=read({item=F.paper:getID()});assert(not historical.live and historical.fresh and quantity(historical,'Fixture.LiveOnly')==0,'historical mode used live counts')
age=original.finished+169;assert(not P.fresh(original))
-- Renew through the actual walking/inspection/native completion path. Old CD frozen.
L.cleanup(actor);F.run(F.paper)
local renewed=L.snapshotFor(F.paper)
assert(renewed~=original and renewed.finished==age and root.snapshots[original.id]==original)
assert(L.snapshotFor(F.disc)==cdOriginal and cdOriginal~=renewed,'paper renewal silently rewrote existing CD')
assert(quantity(read({item=F.paper:getID()}),'Fixture.LiveOnly')==3)
assert(G.check(actor,actor.square,'area'))
-- A loaded, powered real CD can automatically provide current knowledge.
F.inv:Remove(F.paper)
local storage=f.unrelatedObject.containers[1];F.inv:Remove(F.disc);storage:AddItem(F.disc)
local offers=L.handle(actor,'ledgerDriveList',{computer=F.position});assert(offers.status=='ok' and #offers.choices==1)
local mount=L.handle(actor,'ledgerDriveMount',{computer=F.position,token=offers.choices[1].token});assert(mount.status=='ok')
local drive=mount.mounted.drive
assert(not G.check(actor,actor.square,'area'),'expired manual CD granted room sort')
opts.LedgerComputerManualUpdates=false
assert(G.check(actor,actor.square,'area'),'automatic computer did not renew knowledge')
local digital=read({drive=drive,computer=F.position,item=F.disc:getID()})
assert(digital.status=='ok' and digital.live and digital.fresh and quantity(digital,'Fixture.LiveOnly')==3,digital.status)
-- A real mounted CD in a different native building remains historical. Match
-- the complete signature, not just its native room-ID key or proximity.
local computerSquare=F.computer:getSquare();local originalBuilding=computerSquare.building
local otherDef={getRooms=function() return f.list({{getID=function() return 77 end,getX=function() return 50 end,getY=function() return 50 end,getX2=function() return 52 end,getY2=function() return 52 end,getZ=function() return 0 end}}) end}
local otherBuilding={getDef=function() return otherDef end}
local workSquare;for _,sq in pairs(f.squares) do if sq~=computerSquare and sq:getBuilding()==originalBuilding then workSquare=sq;break end end
assert(workSquare,'fixture needs a separate recorded square')
computerSquare.building=otherBuilding;f.advance(5100)
local Analysis=require 'B47ANCEDQuartermaster/ContentAnalysis';local begin=Analysis.begin;local scans=0
Analysis.begin=function(...) scans=scans+1;return begin(...) end
local offsite=read({drive=drive,computer=F.position,item=F.disc:getID(),buildingSignature=cdOriginal.signature})
assert(offsite.status=='ok' and offsite.computerOffsite and not offsite.live and not offsite.fresh and offsite.expires==cdOriginal.finished+P.days()*24,'offsite computer used automatic freshness')
assert(quantity(offsite,'Fixture.LiveOnly')==0 and scans==0,'offsite computer scanned/refreshed remote inventory')
assert(not G.check(actor,workSquare,'area'),'nearby offsite computer granted expired building knowledge')
assert(G.check(actor,workSquare,'sort'),'offsite CD blocked ordinary inventory Sort')
local oldAge=age;age=cdOriginal.finished;opts.LedgerMode=1;f.advance(1100)
local freshOffsite=read({drive=drive,computer=F.position,item=F.disc:getID()})
assert(freshOffsite.fresh and not freshOffsite.live and freshOffsite.computerOffsite,'unexpired offsite CD became live')
assert(G.check(actor,workSquare,'area'),'fresh nearby historical CD lost existing coverage')
opts.LedgerMode=3;local noExpiry=read({drive=drive,computer=F.position,item=F.disc:getID()})
assert(noExpiry.fresh and not noExpiry.live and noExpiry.computerOffsite,'No updates mode refreshed a remote building')
computerSquare.building=nil;f.advance(1100)
assert(read({drive=drive,computer=F.position,item=F.disc:getID()}).computerOffsite,'outdoor computer refreshed a building')
computerSquare.building=originalBuilding;opts.LedgerMode=4;age=oldAge;f.advance(5100)
local localAgain=read({drive=drive,computer=F.position,item=F.disc:getID()})
assert(localAgain.live and localAgain.fresh and not localAgain.computerOffsite,'returning to exact building did not restore automatic refresh')
local kind=cdOriginal.scope.kind;cdOriginal.scope.kind='safehouse';f.advance(5100)
local broad=read({drive=drive,computer=F.position,item=F.disc:getID()})
assert(broad.computerOffsite and not broad.live and not broad.fresh,'safehouse-wide snapshot received a building-specific exemption')
cdOriginal.scope.kind=kind;Analysis.begin=begin;f.advance(5100)
assert(G.check(actor,workSquare,'area'),'matching building provider failed to recover')
print('PASS OFFLINE computer building scope: exact full signature, offsite/outdoor/safehouse-shaped snapshots, no remote inventory analysis, ignored client signature, ordinary expiry/No updates, nearby fresh history, automatic recovery and manual Sort preserved')
F.setPower(false);assert(not G.check(actor,actor.square,'area'));F.setPower(true)
storage:Remove(F.disc);assert(not G.check(actor,actor.square,'area'),'automatic computer accepted a removed CD');storage:AddItem(F.disc)
opts.LedgerComputerManualUpdates=true;assert(not G.check(actor,actor.square,'area'))
-- Disabled means no ledger work/drive authority, not destroyed records or papers.
opts.LedgerMode=2
assert(G.check(actor,actor.square,'area') and G.check(actor,actor.square,'shopping') and B47SupplyLedgerEnabled()==false)
assert(L.handle(actor,'ledgerRead',{item=F.paper:getID()}).status=='LedgerDisabled')
assert(L.handle(actor,'ledgerBegin',{}).status=='LedgerDisabled')
assert(D.handle(actor,'ledgerDriveList',{computer=F.position}).status=='LedgerDisabled')
assert(not D.provider(actor,drive) and root.snapshots[original.id]==original)
opts.LedgerMode=4;assert(D.provider(actor,drive),'re-enabling lost persisted drive data')
opts.LedgerUpdateDays=1;age=renewed.finished+24;assert(not P.fresh(renewed))
for _,bad in ipairs({0,366,1.5,'3',math.huge}) do opts.LedgerUpdateDays=bad;assert(P.days()==7) end
opts.LedgerMode=99;assert(P.mode()==1);opts.LedgerMode=3
age=renewed.finished-1;assert(not P.fresh(renewed),'future inspection time qualified')
-- A slow initial analysis must not expire its own unfinished cache epoch.
opts.LedgerMode=3;age=renewed.finished;F.inv:AddItem(F.paper);L.cleanup(actor)
for n=1,900 do f.a.containers[1]:AddItem(F.item('Fixture.BigLive','Big live')) end
local before=getTimestampMs();local large=read({item=F.paper:getID()})
assert(large.status=='ok' and quantity(large,'Fixture.BigLive')==900 and getTimestampMs()-before>5000,'large live analysis restarted before its first response')
-- Disable during active inspection: no stale actor lock may block Shopping Paper.
L.cleanup(actor);assert(L.handle(actor,'ledgerBegin',{item=F.paper:getID(),scopeKind='building'}).status=='ok')
assert(L.jobs[actor]);opts.LedgerMode=2;f.advance(251);L.tick();assert(not L.jobs[actor] and not L.actors[actor])
opts.LedgerMode=3
-- Corrupt or incomplete old completion metadata cannot crash a historical read.
opts.LedgerMode=4
local currentPaper=L.snapshotFor(F.paper)
local finished=currentPaper.finished;currentPaper.finished='bad'
assert(not P.fresh(currentPaper) and P.deadline(currentPaper)==nil)
assert(L.handle(actor,'ledgerRead',{item=F.paper:getID()}).status=='ok')
currentPaper.finished=finished
-- Independent compatibility families prevent silently mixing old scope semantics.
local Protocol=require 'B47ANCEDQuartermaster/Protocol'
assert(Protocol.version('ledgerRead')==5 and not Protocol.accepts('ledgerRead',{protocol=3}))
assert(Protocol.version('areaDiscover')==4 and not Protocol.accepts('areaDiscover',{protocol=3}) and Protocol.version('movePut')==12)
print('PASS OFFLINE ledger modes: manual Sort without knowledge, area gate, default/expiry boundary/world time, live/historical statistics, privacy revocation, native renewal/CD immutability, powered automatic computer and real CD/power loss, disabled/re-enable preservation and mixed-peer refusal; native/dedicated NOT TESTED')
