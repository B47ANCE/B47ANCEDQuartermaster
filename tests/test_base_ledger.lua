dofile(TEST_ROOT..'/test_ledger.lua')
local Q=B47ANCEDQuartermaster;local F,f=LEDGER_FIXTURE,CONTAINER_FIXTURE;local actor=f.player
local oldTime=getGameTime;getGameTime=function() return {getWorldAgeHours=function() return 100 end} end
local L=Q.Ledger;local root=ModData.getOrCreate('B47ANCEDQuartermasterLedger');root.schema=1
local Media=require 'B47ANCEDQuartermaster/LedgerMedia';local V=require 'B47ANCEDQuartermaster/BaseLedger'
local old=L.snapshotFor(F.disc);assert(old and old.complete)
local function clone(x) if type(x)~='table' then return x end;local out={};for k,v in pairs(x) do out[k]=clone(v) end;return out end
local newer=clone(old);newer.id='fixture-newer';newer.revision=old.revision+1;newer.finished=old.finished+1
root.snapshots[newer.id]=newer;root.count=root.count+1
local copy=F.item(Media.disc);root.media[tostring(copy:getID())]=newer.id
local storage=f.b.containers[1];F.inv:Remove(F.disc);storage:AddItem(F.disc);storage:AddItem(copy)
local originalSquare=actor.square;actor.square=F.computer:getSquare()
local function resolve(mode)
 for _=1,500 do local view,status=V.resolve(actor,F.computer,mode);if view or status~='waiting' then return view,status end;f.advance(100) end
 error('base view did not finish')
end
local view,status=resolve('local');assert(view,status)
assert(view.base and #view.stockAreas==1 and #view.order==#newer.order,'same area was counted twice')
assert(view.entries[newer.order[1]].recorded==newer.entries[newer.order[1]].recorded)
local chosen=false;for _,source in ipairs(V.jobs[actor].sources) do if source.snapshot==newer then chosen=true end end;assert(chosen)
assert(V.jobs[actor].chosen[newer.signature].snapshot==newer,'newest same-area snapshot not selected')
-- Losing a physical CD invalidates the cached virtual view before another read.
storage:Remove(copy);copy.container=nil
local after=resolve('local');assert(after and after.id~=view.id and V.jobs[actor].chosen[old.signature].snapshot==old)
F.setPower(false);assert(not V.resolve(actor,F.computer,'local'));F.setPower(true)
SandboxVars.B47ANCEDQuartermaster.LedgerMultipleCDs=false;local missing,why=V.resolve(actor,F.computer,'base');assert(not missing and why=='BaseLedgerDisabled');SandboxVars.B47ANCEDQuartermaster.LedgerMultipleCDs=true
-- A completed foreign CD beside this PC supplies recorded history when its
-- building is unreachable. It cannot make a Base view live or complete.
local foreign=clone(old);foreign.id='fixture-foreign';foreign.signature='another-building';foreign.scope.key='another-building'
root.snapshots[foreign.id]=foreign;root.count=root.count+1
local disc=F.item(Media.disc);root.media[tostring(disc:getID())]=foreign.id;storage:AddItem(disc)
V.cleanup(actor);view=assert(resolve('base'));assert(#view.stockAreas==2 and not view.complete and not view.baseLive and not view.baseFresh)
local offlineArea;for _,area in ipairs(view.stockAreas) do if area.offline then offlineArea=area end end
assert(V.jobs[actor].chosen[foreign.signature].offline and offlineArea,'foreign CD was not labelled as recorded history')
assert(offlineArea.label:find('UI_QMSS_BaseLedgerOfflineCD',1,true),'foreign area omitted its recording label')
assert(storage:getItemWithID(F.disc:getID())==F.disc and storage:getItemWithID(disc:getID())==disc,'base view moved real CDs')
-- A second native building contributes only through its paired powered PC
-- and its own genuine local CD. Distinct physical compartments are unioned.
local rd={getID=function() return 88 end,getX=function() return 20 end,getY=function() return 0 end,getX2=function() return 22 end,getY2=function() return 2 end,getZ=function() return 0 end}
local bd={getRooms=function() return f.list({rd}) end};local building={getDef=function() return bd end}
local rs=f.square(20,0,0,building);local remotePower=true
rs.haveElectricity=function() return remotePower end;rs.hasGridPower=function() return false end;rs.getRoom=function() return {} end;rs.canReachTo=function() return true end
local remote=f.object(rs,f.grid,nil,false);remote.getSprite=function() return {name='appliances_com_01_72'} end
local remoteStore=f.object(rs,f.grid);remoteStore.containers={F.container()};remoteStore:getModData().B47LedgerPhysical='fixture-remote'
storage:Remove(disc);remoteStore.containers[1]:AddItem(disc)
local scope=require('B47ANCEDQuartermaster/LedgerScope').capture({getCurrentSquare=function() return rs end},'building')
foreign.scope=scope;foreign.signature=require('B47ANCEDQuartermaster/LedgerScope').signature(scope)
local entry=clone(old.entries[old.order[1]]);entry.key='fixture-remote:20:0:0:0';entry.position={x=20,y=0,z=0,index=remoteStore:getObjectIndex(),ci=0};entry.rows={clone(old.entries[old.order[1]].rows[1])}
if not entry.rows[1] then for _,v in pairs(old.entries) do if v.rows[1] then entry.rows[1]=clone(v.rows[1]);break end end end
entry.rows[1].quantity=77;foreign.entries={[entry.key]=entry};foreign.order={entry.key};foreign.totalRows=1;foreign.revision=foreign.revision+1
local Network=require 'B47ANCEDPCFramework/Connections'
local firstPC=Network.handle(actor,'list',{computer=F.position});assert(firstPC.status=='ok')
firstPC=Network.handle(actor,'pair',{computer=F.position,revision=firstPC.revision});assert(firstPC.status=='ok')
actor.square=rs;local position={x=20,y=0,z=0,index=remote:getObjectIndex()}
local secondPC=Network.handle(actor,'list',{computer=position});assert(secondPC.status=='ok')
assert(Network.handle(actor,'connect',{computer=position,revision=secondPC.revision,peer=firstPC.id}).status=='ok')
actor.square=F.computer:getSquare();V.cleanup(actor);view=assert(resolve('base'))
assert(#view.stockAreas==2 and #view.order==#old.order+1,'paired buildings did not form a deduplicated Base Ledger')
assert(not V.jobs[actor].chosen[foreign.signature].offline,'available remote PC did not replace the carried fallback')
local media=Q.LedgerDrives.handle(actor,'ledgerDriveList',{computer=F.position});assert(media.status=='ok')
local token;for _,choice in ipairs(media.choices) do if choice.id==F.disc:getID() then token=choice.token end end;assert(token)
local mounted=Q.LedgerDrives.handle(actor,'ledgerDriveMount',{computer=F.position,token=token});assert(mounted.status=='ok')
local page=Q.Ledger.handle(actor,'ledgerBaseRead',{drive=mounted.mounted.drive,computer=F.position,ledgerMode='base'})
assert(page.status=='ok' and #page.stockAreas==2,'public Base read did not use the virtual union')
local remoteCount=0;for _,row in ipairs(page.rows) do if row.position.x==20 then remoteCount=remoteCount+row.quantity;assert(row.stockArea) end end
assert(remoteCount==77,'Base page lost remote quantities/area identity')
remotePower=false;V.cleanup(actor);view=assert(resolve('base'));assert(#view.stockAreas==1 and not view.complete,'offline building was included as live/complete')
remoteStore.containers[1]:Remove(disc);storage:AddItem(disc)
V.cleanup(actor);view=assert(resolve('base'))
assert(#view.stockAreas==2 and not view.complete and not view.baseLive,'carried remote CD failed as an offline fallback')
local snapshot=clone(foreign);snapshot.id='fixture-foreign-updated';snapshot.finished=foreign.finished+2;snapshot.revision=foreign.revision+1
root.snapshots[snapshot.id]=snapshot;root.count=root.count+1
local updated=F.item(Media.disc);root.media[tostring(updated:getID())]=snapshot.id;storage:AddItem(updated)
V.cleanup(actor);view=assert(resolve('base'))
assert(V.jobs[actor].chosen[foreign.signature].snapshot==snapshot,'newly recorded CD did not replace older offline history')
storage:Remove(updated);updated.container=nil;V.cleanup(actor);view=assert(resolve('base'))
assert(V.jobs[actor].chosen[foreign.signature].snapshot==foreign,'removed updated CD remained cached')
remotePower=true;storage:Remove(disc);disc.container=nil;V.cleanup(actor);view=assert(resolve('base'));assert(#view.stockAreas==1 and not view.complete,'missing local and remote CD contributed an area')

actor.square=originalSquare;getGameTime=oldTime
print('PASS OFFLINE multi-CD/base: real adjacent-media scan, newest complete same-area copy, no double counting, cache invalidation on media loss, power/server setting and dated foreign-area fallback; no inventory mutation')
