-- Actual Framework CDPrograms/DriveService + Quartermaster native grant paths.
dofile(TEST_ROOT..'/test_ledger.lua')
local Q=B47ANCEDQuartermaster;local L=Q.Ledger;local F=LEDGER_FIXTURE;local f=CONTAINER_FIXTURE;local actor=f.player
local P=require 'B47ANCEDQuartermaster/LedgerProgram';local C=require 'B47ANCEDQuartermaster/LedgerAction'
local store=ModData.getOrCreate('B47ANCEDQuartermasterLedger');store.schema=1
SandboxVars.B47ANCEDQuartermaster.RequireComputerApplication=nil -- default must require installation
local computer=F.computer;actor.square=computer:getSquare();local pos=F.position
local blank=F.inv:AddItem(F.item('Base.Disc_Retail'))
assert(not P.has(actor,computer,true))
computer:getModData().B47QMProgramVersion=P.version
assert(P.localInstalled(computer) and not P.has(actor,computer,true),'client-visible version flag authorized server access')
computer:getModData().B47QMProgramVersion=nil
assert(L.handle(actor,'ledgerBurn',{item=F.paper:getID(),cd=blank:getID(),computer=pos}).status=='ProgramRequired')
assert(L.handle(actor,'ledgerRead',{item=F.disc:getID(),computer=pos}).status=='ProgramRequired')
assert(L.handle(actor,'ledgerRead',{item=F.paper:getID()}).status=='ok','paper reading gained an installation gate')
local storage=f.a;local container=storage.containers[1];local cd=container:AddItem(F.item(P.disc))
local count=#container.items
local response=L.handle(actor,'ledgerSetupList',{computer=pos});assert(response.status=='ok' and #response.choices==1)
local mount=L.handle(actor,'ledgerSetupMount',{computer=pos,token=response.choices[1].token});assert(mount.status=='ok')
local args={computer=pos,program=P.id,media=cd:getID(),drive=mount.mounted.drive}
local auth=L.handle(actor,'ledgerProgramRun',args);assert(auth.status=='ok' and auth.media.id==cd:getID() and auth.program.version==P.version)
local wrong={computer=pos,program=P.id,media=cd:getID()+999,drive=args.drive}
assert(L.handle(actor,'ledgerProgramRun',wrong).status~='ok')
local function begin() local offer=L.handle(actor,'ledgerProgramInstall',args);assert(offer.status=='action',offer.status);return offer end
local offer=begin();assert(offer.seconds==20 and not P.has(actor,computer,true),'intent installed immediately')
L.stop(actor,offer.token);assert(not P.has(actor,computer,true),'cancel installed software')
offer=begin();F.setPower(false);assert(not L.valid(actor,offer.token,L.grants[offer.token].action));L.stop(actor,offer.token);F.setPower(true)
offer=begin();container:Remove(cd);assert(not L.valid(actor,offer.token,L.grants[offer.token].action));L.stop(actor,offer.token);container:AddItem(cd)
local can=Q.RoomAccess.can;Q.RoomAccess.can=function() return false end
assert(L.handle(actor,'ledgerProgramInstall',args).status~='action');Q.RoomAccess.can=can
offer=begin();Q.RoomAccess.can=function(a,t,kind) return kind~='configure' and can(a,t,kind) end
assert(not L.valid(actor,offer.token,L.grants[offer.token].action),'revoked configuration permission left install valid')
L.stop(actor,offer.token);Q.RoomAccess.can=can
-- Dedicated-shaped native completion requires sender challenge and full progress.
f.network(false,true);local messages={};sendServerCommand=function(p,_,command,data) messages[#messages+1]={player=p,command=command,data=data} end
offer=begin();local action=assert(C:new(actor,offer.token));local progress=0
action.netAction={getProgress=function() return progress end};assert(action:serverStart())
local challenge=messages[#messages].data.challenge
assert(not action:complete() and not P.has(actor,computer,true),'unconfirmed action installed')
-- The refusal retired that grant. Start a new, confirmed action.
offer=begin();action=assert(C:new(actor,offer.token));action.netAction={getProgress=function() return progress end};assert(action:serverStart())
challenge=messages[#messages].data.challenge
assert(L.handle(actor,'ledgerConfirm',{token=offer.token,challenge=challenge}).status=='ok')
progress=1;assert(action:complete() and P.has(actor,computer,true));assert(not action:complete(),'duplicate install completion accepted')
assert(#container.items==count and container:getItemWithID(cd:getID())==cd,'installation moved/consumed the application CD')
assert(not P.occupied(computer),'finished installer retained the setup drive lock')
-- Moving the reusable setup disc away must not block the installed application.
container:Remove(cd);F.inv:AddItem(cd)
assert(P.has(actor,computer,true) and L.handle(actor,'ledgerRead',{item=F.disc:getID(),computer=pos}).status=='ok')
local burnAfter=L.handle(actor,'ledgerBurn',{item=F.paper:getID(),cd=blank:getID(),computer=pos})
assert(burnAfter.status=='action',burnAfter.status);L.stop(actor,burnAfter.token)
local receipt=computer:getModData().B47QMProgram
local saved=ModData.getOrCreate('B47ANCEDQuartermasterPrograms');assert(saved.count==1)
assert(P.install(actor,computer,args)=='ProgramInstalled' and saved.count==1,'repeat install created another receipt')
local other=f.object(computer:getSquare(),f.grid,nil,false);other.getSprite=computer.getSprite
other:getModData().B47QMProgram=receipt;other:getModData().B47QMProgramVersion=P.version
assert(not P.has(actor,other,true),'receipt copied to another PC authorized access')
local setup=L.handle(actor,'ledgerSetupEject',{computer=pos,drive=args.drive});assert(setup.status=='ok')
assert(P.has(actor,computer,true),'application CD was required after installation')
package.loaded['B47ANCEDQuartermaster/LedgerProgram']=nil
local reloaded=require 'B47ANCEDQuartermaster/LedgerProgram';assert(reloaded.has(actor,computer,true),'persisted installation did not survive service reload')
saved.schema=99;assert(not reloaded.has(actor,computer,true) and saved.schema==99,'future installation data failed open/reset')
saved.schema=1
f.network(true,false);assert(not reloaded.has(actor,computer,true),'client resolved authoritative installation')
f.network(false,false)
SandboxVars.B47ANCEDQuartermaster.RequireComputerApplication=false
assert(reloaded.has(actor,other,true),'server opt-out did not preserve existing computer workflow')
-- Loot is idempotent and respects zero/malformed settings without inventory writes.
local targets={'OfficeDesk','OfficeDeskSecretary','OfficeDeskStressed','OfficeCounter','OfficeShelfSupplies','CrateOfficeSupplies','ElectronicStoreComputers','CrateComputer'}
local pools={ElectronicStoreMisc={items={P.disc,1,'Base.Battery',2,P.disc,1}},CrateElectronics={items={P.disc,1}},OfficeDeskHome={items={'Base.Pen',2}},CrateTools={items={'Base.Hammer',2}}}
for _,name in ipairs(targets) do pools[name]={items={'Base.Pen',2}} end
ProceduralDistributions={list=pools};package.loaded['Items/ProceduralDistributions']=true
local callback;Events={OnPreDistributionMerge={Add=function(fn) callback=fn end}}
dofile(TEST_ROOT..'/../src/B47ANCEDQuartermaster/42/media/lua/server/B47ANCEDQuartermaster/ApplicationLoot.lua')
callback();callback();assert(#pools.OfficeDesk.items==4 and pools.OfficeDesk.items[3]==P.disc)
for _,name in ipairs(targets) do assert(#pools[name].items==4 and pools[name].items[3]==P.disc and pools[name].items[4]==1,name) end
assert(#pools.ElectronicStoreMisc.items==2 and pools.ElectronicStoreMisc.items[1]=='Base.Battery' and #pools.CrateElectronics.items==0,'old generic electronics entry retained')
assert(#pools.OfficeDeskHome.items==2 and #pools.CrateTools.items==2,'unrelated home/cargo loot changed')
SandboxVars.B47ANCEDQuartermaster.ApplicationCDLootWeight=2.5;callback()
for _,name in ipairs(targets) do assert(#pools[name].items==4 and pools[name].items[4]==2.5,name) end
SandboxVars.B47ANCEDQuartermaster.ApplicationCDLootWeight=0;callback()
for _,name in ipairs(targets) do assert(#pools[name].items==2,name) end
SandboxVars.B47ANCEDQuartermaster.ApplicationCDLootWeight=0/0;callback();assert(pools.OfficeDesk.items[4]==1)
SandboxVars.B47ANCEDQuartermaster.LedgerMode=2;callback();assert(#pools.OfficeDesk.items==2,'disabled ledger mode still added application loot')
SandboxVars.B47ANCEDQuartermaster.LedgerMode=1
pools.OfficeDesk=nil;pools.OfficeCounter={};pools.CrateComputer={items={'malformed'}}
callback();assert(#pools.CrateComputer.items==1,'malformed pool modified')
print('PASS OFFLINE Quartermaster program installation: real CD API, default gate, paper unaffected, missing/forged media, cancel/power/permission/media loss, native challenge, retained CD, duplicate/reload/future schema, exact PC receipt, client refusal, opt-out and idempotent loot')
