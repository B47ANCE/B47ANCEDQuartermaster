local M=dofile(TEST_ROOT..'/../experiments/supply-ledger/Model.lua')
local store={};local actor={};local other={};local paper={id='paper'};local disc={id='cd',cd=true};local output={id='out'}
local allowed,power,unchanged=true,true,true;local converts=0;local present={[paper]=true,[disc]=true}
local port={server=function() return true end,owns=function(a,item) return a==actor and present[item] end,
 id=function(item) return item.id end,now=function() return 42 end,scope=function() return {building='native:1'} end,
 scopeValid=function() return true end,discoveryReceipt=function(_,_,_,r) return r=='native' end,
 canInspect=function() return allowed end,inspect=function() return {{name='5.56mm Rounds',fullType='Base.ExactAmmo',quantity=200,room='Armory'}} end,
 timing=function() return {base=10,container=5,entry=1} end,inspectionReceipt=function(_,_,r) return r=='native' end,
 sameContents=function() return unchanged end,canView=function() return allowed end,poweredComputer=function() return power end,
 compatibleCD=function(item) return item.cd end,burnReceipt=function(_,_,_,_,r) return r=='native' end,
 atomicConversionVerified=false,convert=function() converts=converts+1;present[disc]=nil;present[output]=true;return output end}
local api=assert(M.new(store,port));local binding,status=api.begin(actor,paper);assert(status=='ok')
binding.snapshot='forged';assert(store.bindings.paper.snapshot~='forged','caller changed authoritative snapshot binding')
assert(select(2,api.begin(other,paper))=='denied')
local revision=assert(api.discovered(actor,paper,0,{'crate'},'native'))
local offer=assert(api.prepare(actor,paper,revision,'crate'));assert(offer.seconds==16 and not offer.rows)
assert(select(2,api.complete(actor,paper,offer.token,'client'))=='denied')
unchanged=false;assert(select(2,api.complete(actor,paper,offer.token,'native'))=='reinspect');unchanged=true
offer=api.prepare(actor,paper,revision,'crate');revision=assert(api.complete(actor,paper,offer.token,'native'))
assert(select(2,api.complete(actor,paper,offer.token,'native'))=='denied','inspection receipt replay')
local pages=assert(api.view(actor,paper,false));assert(pages.status=='complete' and pages.rows[1].item.quantity==200)
assert(select(2,api.view(actor,paper,false,'5.56'))=='paperHasNoSearch')
pages.rows[1].item.quantity=0;assert(api.view(actor,paper,false).rows[1].item.quantity==200,'view mutated snapshot')
allowed=false;local hidden=api.view(actor,paper,false);assert(hidden.permissionLimited and hidden.total==0);allowed=true
assert(select(2,api.burn(actor,paper,disc,'burn1','native'))=='nativeConversionUnverified' and converts==0 and present[disc] and present[paper])
port.atomicConversionVerified=true;power=false;assert(select(2,api.burn(actor,paper,disc,'burn1','native'))=='denied');power=true
local made=assert(api.burn(actor,paper,disc,'burn1','native'));assert(made==output and converts==1 and present[paper] and not present[disc])
local digital=assert(api.view(actor,output,true,'5.56'));assert(digital.total==1 and digital.rows[1].item.quantity==200)
assert(api.view(actor,output,true,'5X56').total==0,'digital search treated punctuation as pattern syntax')
power=false;assert(select(2,api.view(actor,output,true))=='powerOrMedia');power=true
local reloaded=assert(M.new(store,port));assert(reloaded.view(actor,paper,false).revision==revision,'reload lost snapshot')
local future={schema=99};assert(not M.new(future,port) and future.schema==99)
local secondDisc={id='cd2',cd=true};present[secondDisc]=true
port.convert=function() converts=converts+1;error('native outcome unknown') end
assert(select(2,api.burn(actor,paper,secondDisc,'burn2','native'))=='outcomeUnknown')
assert(select(2,api.burn(actor,paper,secondDisc,'burn3','native'))=='discLocked','uncertain conversion replayed under another request ID')
print('PASS OFFLINE ledger DOMAIN prototype only: immutable/static snapshots, quantity/timing, reinspection, receipt/actor/replay guards, paper/digital search distinction, privacy/power, persistence and unresolved-conversion locks; native port UNIMPLEMENTED')
