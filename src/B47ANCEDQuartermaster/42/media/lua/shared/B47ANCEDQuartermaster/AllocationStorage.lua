-- Physical membership and native snapshots only. Rooms owns all geometry.
local Access=require 'B47ANCEDQuartermaster/RoomAccess'
local Profile=require 'B47ANCEDQuartermaster/AllocationProfile'
local Capacity=require 'B47ANCEDQuartermaster/AllocationCapacity'
local float=require('B47ANCEDQuartermaster/NativeFloat').round
local Q=B47ANCEDQuartermaster;local S={};Q.AllocationStorage=S
local function number(v) return type(v)=='number' and v==v and v>=0 and v<1e12 end
function S.item(item)
 if not item or type(item.getFullType)~='function' or type(item.getUnequippedWeight)~='function' then return nil,'AllocationIdentityUnavailable' end
 local full,weight=item:getFullType(),item:getUnequippedWeight()
 local category=Q.Categorizer.resolve(item);local path=Profile.path(category,Q.Categorizer)
 if not Profile.fullType(full) or not number(weight) or not path or #path==0 then return nil,'AllocationIdentityUnavailable' end
 return {ref=item,fullType=full,weight=weight,path=path,source=item:getContainer()}
end
function S.startRoom(player,descriptor,target)
 return {player=player,room=descriptor,target=target,stage='geometry',index=1,objectIndex=0,ci=0,targets={},tiles={},objects={},seen={}}
end
function S.stepRoom(job,deadline)
 if job.done then return job end
 local api=Access.service();if not api or type(api.storageTiles)~='function' then job.done=true;job.reason='RoomPermissionUnavailable';return job end
 if job.stage=='geometry' then
  local result=api.storageTiles(job.player,job.room.id,job.room.revision,job.target)
  if result.status=='waiting' or result.status=='busy' then return job end
  if result.status~='ok' then job.done=true;job.reason=result.status;return job end
  job.tiles=result.tiles;job.stage='objects'
 end
 for _=1,64 do
  if getTimestampMs()>=deadline then break end
  local tile=job.tiles[job.index]
  if not tile then job.done=true;return job end
  local square=getCell():getGridSquare(tile.x,tile.y,tile.z)
  if not square then job.done=true;job.reason='RoomUnloaded';return job end
  local objects=square:getObjects()
  if not job.currentObjects then
   if objects:size()>512 then job.done=true;job.reason='AllocationScopeLimit';return job end
   job.currentObjects={square=square,refs={}};job.objects[#job.objects+1]=job.currentObjects
   for n=0,objects:size()-1 do job.currentObjects.refs[n+1]=objects:get(n) end
  end
  if job.objectIndex>=objects:size() then job.index=job.index+1;job.objectIndex=0;job.ci=0;job.currentObjects=nil
  else
   local object=objects:get(job.objectIndex);local count=object:getContainerCount() or 0
   if count>100 then job.done=true;job.reason='AllocationScopeLimit';return job end
   if job.ci>=count then job.objectIndex=job.objectIndex+1;job.ci=0
   else
    -- Server-internal occupancy only: inaccessible compartments add no capacity
    -- and are never bound, returned to clients or used as transfer destinations.
    local target={obj=object,ci=job.ci,container=object:getContainerByIndex(job.ci)};job.ci=job.ci+1
    if target.container and not target.ground and not target.container:getContainingItem() and not job.seen[target.container]
     and target.container:getType()~='floor' then
     if #job.targets>=256 then job.done=true;job.reason='AllocationScopeLimit';return job end
     job.seen[target.container]=true;job.targets[#job.targets+1]=target
    end
   end
  end
 end
 return job
end
function S.validateRoom(job,deadline)
 if not job.done or job.reason then return nil,job.reason or 'AllocationPreparing' end
 local api=Access.service();if not api then return nil,'RoomPermissionUnavailable' end
 local current=api.storageScopes(job.player,job.target)
 if current.status~='ok' then return nil,current.status end
 local found=false;for _,room in ipairs(current.rooms) do if room.id==job.room.id and room.revision==job.room.revision then found=true;break end end
 if not found then return nil,'RoomScopeChanged' end
 for _,row in ipairs(job.objects) do
  if getTimestampMs()>=deadline then return nil,'AllocationSnapshotBudget' end
  local square=row.square;local fresh=getCell():getGridSquare(square:getX(),square:getY(),square:getZ())
  if fresh~=square or square:getObjects():size()~=#row.refs then return nil,'RoomScopeChanged' end
  for n,object in ipairs(row.refs) do if square:getObjects():get(n-1)~=object then return nil,'RoomScopeChanged' end end
 end
 return true
end
local function physical(target)
 local square=target.obj:getSquare()
 if not square then return false end
 local found=false;for n=0,square:getObjects():size()-1 do if square:getObjects():get(n)==target.obj then found=true;break end end
 return found and getCell():getGridSquare(square:getX(),square:getY(),square:getZ())==square
  and target.obj:getContainerByIndex(target.ci)==target.container
  and not target.container:getContainingItem() and target.container:getType()~='floor'
end
function S.atomic(player,targets,deadline,internalOccupancy)
 local parts,seen,total={},{},0
 for _,target in ipairs(targets) do if not seen[target.container] then
  if getTimestampMs()>=deadline then return nil,'AllocationSnapshotBudget' end
  local permitted=Q.Targets.valid(target,player) and Access.can(player,target,'deposit')
  if not permitted and (not internalOccupancy or not physical(target)) then return nil,'RoomAccessChanged' end
  local container=target.container;seen[container]=true
  if type(container.getEffectiveCapacity)~='function' or type(container.getCapacityWeight)~='function' then return nil,'AllocationCapacityUnavailable' end
  local capacity,used=permitted and container:getEffectiveCapacity(player) or 0,container:getCapacityWeight()
  if not number(capacity) or not number(used) then return nil,'AllocationCapacityUnavailable' end
  local list=container:getItems();total=total+list:size()
  if list:size()>4096 or total>32768 or #parts>=256 then return nil,'AllocationScopeLimit' end
  local part={target=target,container=container,capacity=capacity,used=used,permitted=permitted,items={},scope=Capacity.empty()}
  part.scope.capacity=capacity;part.scope.used=used;part.scope.containers[container]=true;part.scope.count=1
  local nativeSum=0
  for n=0,list:size()-1 do
   if getTimestampMs()>=deadline then return nil,'AllocationSnapshotBudget' end
   local item=list:get(n)
   if not item or item:getContainer()~=container then return nil,'AllocationCapacityUnavailable' end
   local row,e=S.item(item);if not row then return nil,e end;part.items[#part.items+1]=row
   nativeSum=float(nativeSum+row.weight)
   local added,why=Capacity.add(part.scope,row);if not added then return nil,why end
  end
  if container:getItems():size()~=#part.items or container:getCapacityWeight()~=used then return nil,'AllocationPreparing' end
  if nativeSum~=used then return nil,'AllocationOccupancyUnavailable' end
  parts[#parts+1]=part
 end end
 return parts
end
function S.scope(player,item,parts,definitions,deadline)
 local compatible={}
 for _,part in ipairs(parts) do
  local config=part.permitted and (part.config or Q.Store.routing(part.target,player))
  local effective=part.effective
  if config and not effective then
   local valid=true;for key,link in pairs(config.presets) do if not Q.Schema.resolves(definitions[key],link) then valid=false;break end end
   if valid then effective=Q.Schema.effective(config,definitions);part.config=config;part.effective=effective end
  end
  if effective and Q.Catalog.matchesItem(item,config,definitions) and part.container:isItemAllowed(item) then
   local exact,e=S.item(item);if not exact then return nil,e end
   local zero=false;for _,ceiling in ipairs(Profile.ceilings(effective.allocation,exact.fullType,exact.path)) do if ceiling.percent==0 then zero=true;break end end
   if not zero then compatible[#compatible+1]=part end
  end
 end
 local expired=deadline and function() return getTimestampMs()>=deadline end
 local eligible,e=Capacity.combine(compatible,expired);if not eligible then return nil,e end
 local all,reason=Capacity.combine(parts,expired);if not all then return nil,reason end
 -- Denominator and fill use only permitted, compatible storage. Aggregate
 -- occupancy counts the whole room internally to prevent cross-actor double
 -- spending when actors have different authorized compartment subsets.
 local physicalRefs=eligible.hasRef
 eligible.categories=all.categories;eligible.items=all.items;eligible.hasRef=all.hasRef
 eligible.physicalHasRef=physicalRefs;eligible.reservationContainers=all.containers
 return eligible
end
return S
