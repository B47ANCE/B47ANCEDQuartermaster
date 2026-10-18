-- Actual native challenge handler and client coordinator, with controlled replies.
dofile(TEST_ROOT..'/test_ledger_ui.lua')
local Q=B47ANCEDQuartermaster;local V=Q.LedgerUI;local f=CONTAINER_FIXTURE;local actor=f.player
local queue=ISTimedActionQueue.getTimedActionQueue(actor)
local function challenge(token)
 for _,handler in ipairs(LEDGER_UI_COMMANDS) do handler('B47ANCEDQuartermasterLedger','challenge',{token=token,challenge='fixture'}) end
end
local serial=0;local sent={};local confirmation='denied';local delayed
Q.Authority.request=function(_,command,args,reply)
 sent[#sent+1]={command=command,args=args}
 if command=='ledgerSortPrepare' then reply({status='ready'})
 elseif command=='ledgerSortNext' or command=='ledgerProgramInstall' or command=='ledgerBurn' then
  serial=serial+1;reply({status='action',token='failure-'..serial,kind=command=='ledgerSortNext' and 'sortWrite' or command=='ledgerBurn' and 'burn' or 'programInstall',seconds=12})
 elseif command=='ledgerConfirm' then if confirmation=='delay' then delayed=reply else reply({status=confirmation}) end
 else reply({status='ok'}) end
end
for _,mode in ipairs({'install','sort','burn'}) do for _,status in ipairs({'denied','rateLimited','uncertain'}) do
 queue.queue={};V.work={};confirmation=status;local calls=0;local outcome,detail
 local function done(s,d) calls=calls+1;outcome=s;detail=d end
 if mode=='install' then V.installProgram(0,f.a,{id=1,drive='fixture'},done)
 elseif mode=='burn' then
  V.burn(0,{getID=function() return 1 end},{getID=function() return 2 end},f.a);V.work[0].callback=done
 else
  assert(V.prepareSort(0,function() return true end,done));V.tick();V.sortFinished(0,'ok',done);V.tick()
 end
 local op=assert(V.work[0]);local token=op.token;local action=queue.queue[1];local stopped=0
 action.action={forceStop=function() stopped=stopped+1 end}
 challenge(token)
 assert(calls==1 and not V.work[0] and not Q.Ledger.clientOffers[token],'confirmation failure lost caller or work')
 assert(stopped==1,'tagged native action remained running')
 if mode=='sort' then assert(outcome=='ok' and detail==status,'completed movement lost writing error')
 else assert(outcome==status,'specific confirmation error replaced') end
 challenge(token);Q.Ledger.clientResult(actor,{token=token,status='cancelled'})
 assert(calls==1,'duplicate/late native failure repeated completion')
 if mode=='install' then
  local canceled=false;for _,r in ipairs(sent) do if r.command=='ledgerCancel' and r.args.token==token then canceled=true end end
  assert(canceled,'installer grant not canceled by exact token')
 end
end end
-- A delayed denial must not close a replacement operation.
queue.queue={};confirmation='delay';local oldCalls=0
V.installProgram(0,f.a,{id=1,drive='fixture'},function() oldCalls=oldCalls+1 end)
local old=V.work[0];challenge(old.token);assert(delayed)
V.cancel(0);queue.queue={}
V.installProgram(0,f.a,{id=1,drive='fixture'},function() error('late denial reached new work') end)
local replacement=V.work[0];delayed({status='denied'})
assert(V.work[0]==replacement and oldCalls==0,'late denial affected replacement')
V.cancel(0);queue.queue={}
print('PASS OFFLINE native confirmation failures: install/burn/write denial, rate limit and uncertainty; one callback, exact error, preserved movement outcome, stopped native action and duplicate/late/replacement guards; native/dedicated NOT TESTED')
