-- Actual ledger and shared-target services in disposable engine-shaped fixtures.
dofile(TEST_ROOT..'/test_ledger.lua')
local Q=B47ANCEDQuartermaster;local F,f=LEDGER_FIXTURE,CONTAINER_FIXTURE;local actor=f.player;local L=Q.Ledger
ModData.getOrCreate('B47ANCEDQuartermasterLedger').schema=1
local S=require 'B47ANCEDQuartermaster/Stock';local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local scriptManager=getScriptManager;getScriptManager=function() return {FindItem=function(_,t) if t:sub(1,8)=='Fixture.' then return {getDisplayName=function() return 'Same name' end} end end} end
local function change(args) args.scopeKey=Scope.signature(Scope.capture(actor,'building'));return S.handle(actor,'stockSet',args) end
local opts=S.options(actor);assert(#opts>=1 and opts[1].kind=='building')
local state=S.handle(actor,'stockGet',{kind='building'});assert(state.status=='ok' and state.canEdit and state.revision==0)
local t=next(L.snapshotFor(F.disc).entries);local first=L.snapshotFor(F.disc).entries[t].rows[1]
if not first then for _,entry in pairs(L.snapshotFor(F.disc).entries) do if entry.rows[1] then first=entry.rows[1];break end end end
assert(first);local fullType=first.fullType
state=change({kind='building',revision=state.revision,fullType=fullType,quantity=300});assert(state.status=='ok')
assert(change({kind='building',revision=0,fullType=fullType,quantity=1}).status=='conflict')
assert(change({kind='building',revision=state.revision,fullType=fullType,quantity=0/0}).status=='invalid')
state=change({kind='building',revision=state.revision,fullType='Fixture.Absent',quantity=10});assert(state.status=='ok' and state.targets[fullType]==300)
state.targets[fullType]=999;assert(S.handle(actor,'stockGet',{kind='building'}).targets[fullType]==300,'client snapshot changed saved targets')
local function read(args)
 for _=1,500 do
  local result=L.handle(actor,'ledgerStock',args)
  if result.status~='waiting' then return result end
  f.advance(251);L.tick()
 end;error('stock did not finish')
end
local result=read({item=F.disc:getID(),computer=F.position})
assert(result.status=='ok' and #result.rows==2 and not result.canNotify,'historical stock became a live notification')
local found={};for _,row in ipairs(result.rows) do found[row.fullType]=row end
assert(found[fullType].current==first.quantity and found[fullType].remaining==300-first.quantity and found['Fixture.Absent'].current==0,'stock counts/zero target wrong')
assert(found[fullType].name==found['Fixture.Absent'].name and found[fullType].fullType~=found['Fixture.Absent'].fullType,'same-name types were merged')
local access=Q.RoomAccess.can;Q.RoomAccess.can=function() return false end
assert(read({item=F.disc:getID(),computer=F.position}).status~='ok','private totals were disclosed')
Q.RoomAccess.can=access
local snapshot=L.snapshotFor(F.disc);local complete,status=snapshot.complete,snapshot.status
snapshot.complete=false;snapshot.status='LedgerPartial';result=read({item=F.disc:getID(),computer=F.position})
assert(result.status=='ok' and not result.complete and not result.canNotify)
snapshot.complete=complete;snapshot.status=status
SandboxVars.B47ANCEDQuartermaster.StockEnabled=false;assert(S.handle(actor,'stockOptions',{}).status=='StockDisabled');assert(read({item=F.disc:getID(),computer=F.position}).status=='StockDisabled')
SandboxVars.B47ANCEDQuartermaster.StockEnabled=true
local r=ModData.getOrCreate('B47ANCEDQuartermasterStock');r.schema=99;assert(S.handle(actor,'stockGet',{kind='building'}).status=='schema' and r.schema==99);r.schema=1
-- Reload is idempotent and does not merge these shared goals into personal Dibs.
package.loaded['B47ANCEDQuartermaster/Stock']=nil;local rebuilt=require 'B47ANCEDQuartermaster/Stock'
state=rebuilt.handle(actor,'stockGet',{kind='building'});assert(state.targets[fullType]==300 and state.targets['Fixture.Absent']==10)
assert(rebuilt.handle(actor,'stockSet',{kind='building',scopeKey=Scope.signature(Scope.capture(actor,'building')),revision=state.revision,fullType='Fixture.Absent',quantity=0}).status=='ok')
-- Completed live stock rounds must discard their old projection cache.
SandboxVars.B47ANCEDQuartermaster.LedgerMode=3
local function current(result)
 for _,row in ipairs(result.rows or {}) do if row.fullType==fullType then return row.current end end
end
local before=read({item=F.disc:getID(),computer=F.position});assert(before.status=='ok' and before.canNotify)
local changed
for _,object in ipairs({f.a,f.b,f.unrelatedObject}) do for _,container in ipairs(object.containers) do for _,it in ipairs(container.items or {}) do
 if it:getFullType()==fullType then changed=it;break end
end end end
assert(changed);local amount=changed.count;changed.count=amount+5
local after=read({item=F.disc:getID(),computer=F.position});assert(after.status=='ok' and current(after)==current(before)+5,'completed stock round reused stale live quantities')
changed.count=amount
getScriptManager=scriptManager
print('PASS OFFLINE stock: shared FullType goals/CAS, invalid amounts, defensive snapshots, real authorized ledger totals/missing items, historical/partial suppression, privacy, disabled/future-schema preservation and reload')
