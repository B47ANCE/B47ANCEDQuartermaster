-- Real client coordinator; native results supplied by a host transport fixture.
dofile(TEST_ROOT..'/test_ledger_ui.lua')
local Q=B47ANCEDQuartermaster;local V=Q.LedgerUI
local f=CONTAINER_FIXTURE;local actor=f.player
local q=ISTimedActionQueue.getTimedActionQueue(actor);q.queue={};V.work={}
dofile(GAME_ROOT..'/media/lua/client/TimedActions/WalkToTimedAction.lua')
local origin=actor:getCurrentSquare()
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
actor.square=f.square(origin:getX()+1,origin:getY(),origin:getZ())
loaded('ok');f.advance(300);V.tick()
assert(continued==0 and #q.queue==1,'sorting began at the ledger pickup location')
local walk=q.queue[1];assert(walk.location==origin and walk.b47LedgerWork==V.work[0])
actor.square=origin;q.queue={};walk.onCompleteFunc(unpack(walk.onCompleteArgs));V.tick()
assert(continued==1 and V.work[0].sorting)
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
-- A sync warning is an outcome of writing, not a failed/uncertain movement.
q.queue={};final=nil;stage=2;local outcome
assert(V.prepareSort(0,function() return true end,function() end));V.tick()
V.sortFinished(0,'ok',function(s,w) final=s;outcome=w end);V.tick()
Q.Ledger.clientResult(actor,{token='sort-write-1',status='SortLedgerSyncPending'})
assert(final=='ok' and outcome=='SortLedgerSyncPending','write warning lost at callback')
q.queue={};final=nil;stage=2
assert(V.prepareSort(0,function() return true end,function() end));V.tick()
V.sortFinished(0,'ok',function(s,w) final=s;outcome=w end);V.tick()
q.queue[1]:forceCancel()
assert(final=='ok' and outcome=='cancelled','write cancellation mislabeled completed movement')
q.queue={} -- native queue removal invokes forceCancel before releasing the slot
-- Failed/canceled return travel never starts a different source or replays.
local function returning()
 q.queue={};stage=0;actor.square=origin;final=nil
 assert(V.prepareSort(0,function() continued=continued+1;return true end,function(s) final=s end))
 V.tick();f.advance(300);V.tick()
 actor.square=f.square(origin:getX()+1,origin:getY(),origin:getZ());loaded('ok');f.advance(300);V.tick()
 assert(V.work[0].returning and #q.queue==1);return q.queue[1]
end
local count=continued
walk=returning();q.queue={};V.tick()
assert(final=='LedgerUnreachable' and continued==count and not V.work[0])
walk=returning();V.cancelSort(0);q.queue={}
assert(final=='cancelled' and not walk:isValid())
walk.onCompleteFunc(unpack(walk.onCompleteArgs));V.tick()
assert(continued==count and not V.work[0],'late return completed canceled Sort')
actor.square=origin;stage=2;final=nil
assert(V.prepareSort(0,function() return false,'invalid' end,function(s) final=s end));V.tick()
assert(final=='invalid' and not V.work[0],'specific source failure became busy')
q.queue={}
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
