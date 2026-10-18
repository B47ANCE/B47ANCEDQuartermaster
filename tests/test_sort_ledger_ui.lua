-- Real client coordinator; native results supplied by a host transport fixture.
dofile(TEST_ROOT..'/test_ledger_ui.lua')
local Q=B47ANCEDQuartermaster;local V=Q.LedgerUI
local f=CONTAINER_FIXTURE;local actor=f.player
local q=ISTimedActionQueue.getTimedActionQueue(actor);q.queue={};V.work={}
local sent={};local stage=0;local loaded;local continued=0;local final
Q.Executor=Q.Executor or {}
Q.Executor.acceptOffer=function(num,offer,callback) assert(num==0 and offer.operation=='pickup-1');loaded=callback;return true end
Q.Executor.cancel=function() end
Q.Authority.request=function(_,command,args,reply)
 sent[#sent+1]={command=command,args=args}
 if command=='ledgerSortPrepare' then
  stage=stage+1
  reply(stage==1 and {status='waiting'} or stage==2 and {status='pickup',offer={operation='pickup-1'}} or {status='ready'})
 elseif command=='ledgerSortNext' then reply({status='action',token='sort-write-1',kind='sortWrite',seconds=12})
 else reply({status='ok'}) end
end
assert(V.prepareSort(0,function() continued=continued+1;return true end,function(s) final=s end))
assert(not V.prepareSort(0,function() error('double-start') end,function() end),'second preflight replaced the first')
V.tick();assert(stage==1 and continued==0)
f.advance(300);V.tick();assert(loaded and continued==0 and V.work[0].actionPending)
loaded('ok');f.advance(300);V.tick();assert(continued==1 and V.work[0].sorting)
local before=#sent;f.advance(1000);V.tick();assert(#sent==before,'coordinator wrote during sorting')
V.sortFinished(0,'ok',function(s) final=s end);V.tick()
assert(q.queue[1] and V.work[0].actionPending and not final,'sort callback completed before native writing')
Q.Ledger.clientResult(actor,{token='sort-write-1',status='SortLedgerSaved'})
assert(final=='ok' and not V.work[0],'write completion did not finish the whole workflow')
-- Failed sorting cancels bookkeeping and never starts a writing action.
q.queue={};final=nil;stage=2
assert(V.prepareSort(0,function() return true end,function(s) final=s end));V.tick()
before=#sent;V.sortFinished(0,'uncertain',function(s) final=s end)
assert(final=='uncertain' and not V.work[0])
for n=before+1,#sent do assert(sent[n].command~='ledgerSortNext','uncertain job started writing') end
-- A canceled preflight rejects late offers and relinquishes their native grant.
local late
Q.Authority.request=function(_,command,args,reply)
 sent[#sent+1]={command=command,args=args}
 if command=='ledgerSortPrepare' then late=reply else reply({status='ok'}) end
end
assert(V.prepareSort(0,function() error('canceled preflight continued') end,function() end));V.tick();V.cancelSort(0)
late({status='pickup',offer={operation='late-pickup'}})
assert(sent[#sent].command=='moveCancel' and sent[#sent].args.operation=='late-pickup' and sent[#sent].args.outcome=='notSubmitted')
print('PASS OFFLINE sort-ledger client: bounded preflight polling, pickup before sorting, single-start/late-offer guards, no write during movement, native completion before callback, failure/cancel cleanup; native UI/MP NOT TESTED')
