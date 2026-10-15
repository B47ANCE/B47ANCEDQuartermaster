-- Server-only advisory evaluator and admission primitives. Activation is gated:
-- no native acceptance evidence exists for the new quota path in this build.
local Profile=require 'B47ANCEDQuartermaster/AllocationProfile'
local Capacity=require 'B47ANCEDQuartermaster/AllocationCapacity'
local Storage=require 'B47ANCEDQuartermaster/AllocationStorage'
local Rooms=require 'B47ANCEDQuartermaster/RoomAllocation'
local Migration=require 'B47ANCEDQuartermaster/Migration'
local Q=B47ANCEDQuartermaster;local R={};Q.AllocationRuntime=R
local function now() return getTimestampMs() end
local ledger=Capacity.ledger(now)
local jobs=setmetatable({},{__mode='k'});local queue={};local sampled=setmetatable({},{__mode='k'})
local stats={samples=0,legacyEligible=0,newEligible=0,legacyRejected=0,newRejected=0,allocationRejected=0,capacityRejected=0,permissionRejected=0,unknown=0,expectedDifferences=0,unexpectedDifferences=0,priorityDifferences=0,elapsedMs=0,cacheHits=0,cacheMisses=0,maxPending=0}
function R.mode() return Migration.option('AllocationMode')==1 and 1 or 2 end
function R.enforcing() return false end -- RUNTIME GATE: native and dedicated acceptance.
function R.diagnostics()
 local out={mode=R.mode(),enforcing=false,gate='AllocationActivationBlocked',pending=#queue,reservations=ledger.count}
 for key,value in pairs(stats) do out[key]=value end;return out
end
function R.context(player,definitions)
 return {player=player,definitions=definitions or {},parts={},rooms={},deadline=now()+8}
end
local function roomJob(player,entry,target)
 local owner=jobs[player] or {};jobs[player]=owner
 for key,old in pairs(owner) do if now()-old.started>10000 then owner[key]=nil end end
 local key=entry.room.id;local job=owner[key]
 if job and (now()-job.started>10000 or job.room.revision~=entry.room.revision or job.reason) then owner[key]=nil;job=nil end
 if not job then
  local count=0;for _ in pairs(owner) do count=count+1 end
  if count>=16 then return nil,'AllocationScopeLimit' end
  job=Storage.startRoom(player,entry.room,target);job.started=now();owner[key]=job;stats.cacheMisses=stats.cacheMisses+1
 else stats.cacheHits=stats.cacheHits+1 end
 return job
end
local function effective(candidate,definitions)
 if not candidate.config then return nil,'configurationChanged' end
 for key,link in pairs(candidate.config.presets) do if not Q.Schema.resolves(definitions[key],link) then return nil,'AllocationPresetUnavailable' end end
 return candidate.effective or Q.Schema.effective(candidate.config,definitions)
end
function R.evaluate(player,item,candidate,context)
 if isClient() or context.player~=player or now()>=context.deadline then return nil,'AllocationSnapshotBudget' end
 local target=candidate.target
 if not Q.Targets.valid(target,player) or not Q.RoomAccess.can(player,target,'deposit') then return false,'RoomAccessDenied' end
 if not Q.Schema.equal(candidate.config,Q.Store.routing(target,player)) then return nil,'configurationChanged' end
 local config,why=effective(candidate,context.definitions);if not config then return nil,why end
 local incoming,e=Storage.item(item);if not incoming then return nil,e end;incoming.destination=target.container
 local part=context.parts[target.container]
 if not part then
  local parts,reason=Storage.atomic(player,{target},context.deadline);if not parts then return nil,reason end
  part=parts[1];context.parts[target.container]=part
 end
 local pending=ledger:pending()
 local ok,reason=Capacity.check(config.allocation,part.scope,pending,incoming)
 if not ok then return ok,reason end
 if not target.container:isItemAllowed(item) or not target.container:hasRoomFor(player,item) then return false,'AllocationPhysicalCapacity' end
 local rooms,errorReason,revision=Rooms.forTarget(player,target);if not rooms then return nil,errorReason end
 local checks={{profile=config.allocation,scope=part.scope}}
 local memberships={}
 for _,entry in ipairs(rooms) do
  if entry.record.roomRevision~=entry.room.revision then return nil,'RoomScopeChanged' end
  local profile,errorProfile=Rooms.effective(entry.record,context.definitions);if not profile then return nil,errorProfile end
  local job,errorJob=roomJob(player,entry,target);if not job then return nil,errorJob end
  local ready,errorReady=Storage.validateRoom(job,context.deadline);if not ready then return nil,errorReady end
  local roomParts=context.rooms[job]
  if not roomParts then
   roomParts,errorReason=Storage.atomic(player,job.targets,context.deadline,true);if not roomParts then return nil,errorReason end
   context.rooms[job]=roomParts
  end
  local scope,errorScope=Storage.scope(player,item,roomParts,context.definitions,context.deadline);if not scope then return nil,errorScope end
  ok,reason=Capacity.check(profile,scope,pending,incoming);if not ok then return ok,reason end
  checks[#checks+1]={profile=profile,scope=scope}
  local fillParts={}
  for _,physical in ipairs(scope.parts) do
   if now()>=context.deadline then return nil,'AllocationSnapshotBudget' end
   local fill,errorFill=Capacity.project(physical.scope,pending,nil);if not fill then return nil,errorFill end
   fillParts[#fillParts+1]={container=physical.container,capacity=physical.capacity,used=fill.used}
  end
  memberships[#memberships+1]={key=entry.key,room=entry.room,record=entry.record,scope=scope,fillParts=fillParts}
 end
 return true,nil,{incoming=incoming,checks=checks,rooms=memberships,libraryRevision=revision}
end
-- Internal admission function: accepts only retained server operation refs.
-- All scopes must pass before one global reservation is installed atomically.
function R.admit(player,op,context)
 if isClient() or not op or op.withdrawal or not op.id or not op.destination then return nil,'invalid' end
 if op.allocationStamp then
  local library,why=Rooms.library();if not library then return nil,why end
  if library.revision~=op.allocationStamp.libraryRevision then return false,'configurationChanged' end
  local rooms,e=Rooms.forTarget(player,op.destination);if not rooms then return nil,e end
  local seen={};for _,entry in ipairs(rooms) do
   local stamp=op.allocationStamp.rooms[entry.key]
   if not stamp or stamp.revision~=entry.record.revision or stamp.roomRevision~=entry.room.revision then return false,'RoomScopeChanged' end
   seen[entry.key]=true
  end
  for key in pairs(op.allocationStamp.rooms) do if not seen[key] then return false,'RoomScopeChanged' end end
  local _,err,revision=Q.Store.routing(op.destination,player)
  if err or revision~=op.allocationStamp.containerRevision then return false,'configurationChanged' end
 end
 local candidate={target=op.destination,config=op.config,effective=op.effective}
 local ok,reason,result=R.evaluate(player,op.item,candidate,context or R.context(player,(Q.Presets.snapshot() or {}).definitions))
 if not ok then return ok,reason end
 local key=op.id;local existing=ledger.entries[key]
 if existing and (existing.ref~=op.item or existing.destination~=op.destination.container) then return false,'AllocationReservationConflict' end
 local pending=ledger:pending()
 for _,check in ipairs(result.checks) do local valid,errorCheck=Capacity.check(check.profile,check.scope,pending,result.incoming);if not valid then return valid,errorCheck end end
 local first=result.checks[1]
 local reserved,errorReserve=ledger:reserve(key,result.incoming,first.profile,first.scope)
 if not reserved then return reserved,errorReserve end
 local _,_,containerRevision=Q.Store.routing(op.destination,player)
 op.allocationStamp={libraryRevision=result.libraryRevision,containerRevision=containerRevision,rooms={}}
 for _,room in ipairs(result.rooms) do op.allocationStamp.rooms[room.key]={revision=room.record.revision,roomRevision=room.room.revision} end
 stats.maxPending=math.max(stats.maxPending,ledger.count);return true
end
function R.release(op,outcome)
 if not op then return end
 -- Unknown already-issued PUTs retain capacity until actual destination
 -- observation or the grant's fixed expiry. Never retry/rollback native moves.
 if op.phase~='put' or outcome=='notSubmitted' or outcome=='rejected' or op.item:getContainer()==op.destination.container then ledger:release(op.id) end
end
function R.cleanup(player)
 jobs[player]=nil;sampled[player]=nil
 for n=#queue,1,-1 do if queue[n].player==player then table.remove(queue,n) end end
end
function R.observe(player,batch,item,choice,definitions)
 if isClient() or R.mode()==1 or not batch or #batch.candidates>256 then return end
 local previous=sampled[player]
 if previous and now()-previous<2000 or #queue>=8 then return end
 sampled[player]=now()
 local candidates={};for _,candidate in ipairs(batch.candidates) do candidates[#candidates+1]=candidate end
 queue[#queue+1]={player=player,item=item,source=item:getContainer(),candidates=candidates,definitions=definitions,legacy=choice and choice.key,index=1,started=now(),results={},eligible=0,legacyEligible=0,rejected=0,unknown=0,explicit=0}
end
function R.rank(item,results,definitions)
 local groups,roomSeen={},{ }
 for _,result in ipairs(results) do for _,entry in ipairs(result.detail.rooms) do
  local room=entry.room;local family=room.roomType or 'unassigned';local role=room.designation or 'unassigned'
  local key=family..'\0'..room.id
  if not roomSeen[key] then
   roomSeen[key]=true;groups[family]=groups[family] or {};local group=groups[family]
   group[role]=group[role] or {capacity=0,used=0,containers={}}
   local pool=group[role]
   for _,part in ipairs(entry.fillParts or entry.scope.parts or {}) do if not pool.containers[part.container] then
    pool.containers[part.container]=true;pool.capacity=pool.capacity+part.capacity;pool.used=pool.used+part.used
   end end
   if role=='primary' then group.primaryAt=math.min(group.primaryAt or 100,entry.record.primaryAt) end
   if role=='secondary' then group.secondaryAt=math.min(group.secondaryAt or 100,entry.record.secondaryAt) end
  end
 end end
 local candidates={}
 for _,result in ipairs(results) do
  local rank,priority=0,-999999
  for _,entry in ipairs(result.detail.rooms) do
   local group=groups[entry.room.roomType or 'unassigned'];local preferred=Capacity.rolePreference(group,group.primaryAt,group.secondaryAt)
   local role=entry.room.designation or 'unassigned';local score=role==preferred and 2 or role~='unassigned' and 1 or 0
   rank=math.max(rank,score);priority=math.max(priority,entry.record.priority)
  end
  local c={};for key,value in pairs(result.candidate) do c[key]=value end
  c.allocationRank=rank;c.allocationPriority=priority;c.allocationRoomKey=result.detail.rooms[1] and result.detail.rooms[1].key or ''
  candidates[#candidates+1]=c
 end
 return Q.Catalog.destination(item,candidates,definitions,nil,true)
end
local function finish(sample)
 local new=R.rank(sample.item,sample.results,sample.definitions)
 stats.samples=stats.samples+1;stats.elapsedMs=stats.elapsedMs+now()-sample.started
 stats.legacyEligible=stats.legacyEligible+sample.legacyEligible;stats.legacyRejected=stats.legacyRejected+sample.rejected
 stats.newEligible=stats.newEligible+sample.eligible;stats.newRejected=stats.newRejected+sample.legacyEligible-sample.eligible-sample.unknown;stats.unknown=stats.unknown+sample.unknown
 if sample.unknown==0 and (new and new.key or nil)~=sample.legacy then
  if sample.explicit>0 then stats.expectedDifferences=stats.expectedDifferences+1 else stats.unexpectedDifferences=stats.unexpectedDifferences+1 end
  if new then stats.priorityDifferences=stats.priorityDifferences+1 end
 end
end
function R.tick()
 if isClient() or R.mode()==1 then return end
 local deadline=now()+4;local work=0
 for _,owner in pairs(jobs) do for _,job in pairs(owner) do
  if not job.done and work<4 and now()<deadline then Storage.stepRoom(job,deadline);work=work+1 end
 end end
 local sample=queue[1];if not sample or now()>=deadline then return end
 if sample.item:getContainer()~=sample.source then stats.unknown=stats.unknown+1;table.remove(queue,1);return end
 if now()-sample.started>10000 then stats.unknown=stats.unknown+1;table.remove(queue,1);return end
 local candidate=sample.candidates[sample.index]
 if not candidate then finish(sample);table.remove(queue,1);return end
 local item=sample.item
 if Q.Catalog.matchesItem(item,candidate.config,sample.definitions) and candidate.container~=item:getContainer() then
  local native=Q.Targets.valid(candidate.target,sample.player) and Q.RoomAccess.can(sample.player,candidate.target,'deposit')
   and candidate.container:isItemAllowed(item) and candidate.container:hasRoomFor(sample.player,item)
  if native then
   local context=R.context(sample.player,sample.definitions);context.deadline=deadline
   local ok,reason,detail=R.evaluate(sample.player,item,candidate,context)
   if reason=='AllocationPreparing' then return end
   sample.legacyEligible=sample.legacyEligible+1
   if ok then sample.eligible=sample.eligible+1;sample.results[#sample.results+1]={candidate=candidate,detail=detail}
   elseif ok==nil then sample.unknown=sample.unknown+1
   elseif reason=='AllocationQuotaExceeded' then stats.allocationRejected=stats.allocationRejected+1;sample.explicit=sample.explicit+1
   elseif reason=='AllocationPhysicalCapacity' then stats.capacityRejected=stats.capacityRejected+1
   else stats.permissionRejected=stats.permissionRejected+1 end
  else sample.rejected=sample.rejected+1 end
 end
 sample.index=sample.index+1
end
if Events and Events.OnTick then Events.OnTick.Add(R.tick) end
return R
