-- Read-only, bounded actual-content analysis. Callers own authorization and lifetime.
local Categories=require 'B47ANCEDQuartermaster/Categorizer'
local A={}
local function number(n) return type(n)=='number' and n==n and n>=0 and n<math.huge end
function A.begin(container,actor,valid)
 if not container or type(valid)~='function' or not valid() then return nil,'unavailable' end
 local items=container:getItems();local size=items:size()
 if size>4096 then return nil,'tooLarge' end -- bounded analysis, never truncate a snapshot
 local job={index=0,count=size,items={},refs={},categories={},quantity=0,weight=0,phase='read'}
 function job.step()
  if not valid() or container:getItems()~=items or items:size()~=size then return nil,'changed' end
  for _=1,64 do
   if job.phase=='verify' then
    if job.index>=size then
     local used=container:getCapacityWeight();local capacity=container:getEffectiveCapacity(actor)
     if not number(used) or not number(capacity) or capacity<=0 then return nil,'capacityUnknown' end
     return {items=job.items,categories=job.categories,instances=size,quantity=job.quantity,used=used,capacity=capacity},'done'
    end
    local item=items:get(job.index);local row=job.items[job.index+1]
    if item~=job.refs[job.index+1] or item:getContainer()~=container or item:getID()~=row.id
     or item:getFullType()~=row.fullType or item:getCount()~=row.quantity or item:getDisplayName()~=row.name
     or item:getActualWeight()~=row.actualWeight or item:getUnequippedWeight()~=row.weight
     or Categories.resolve(item)~=row.category then return nil,'changed' end
   else
    if job.index>=size then job.index=0;job.phase='verify';return nil,'waiting' end
    local item=items:get(job.index)
    if item:getContainer()~=container then return nil,'changed' end
    local count=item:getCount();local weight=item:getUnequippedWeight();local actual=item:getActualWeight()
    if not number(count) or count<1 or count%1~=0 or count>1000000 or not number(weight) or not number(actual) then return nil,'invalidItem' end
    local category=Categories.resolve(item)
    local row={id=item:getID(),fullType=item:getFullType(),name=item:getDisplayName(),quantity=count,category=category,weight=weight,actualWeight=actual}
    if type(row.fullType)~='string' or #row.fullType>256 or type(row.name)~='string' or #row.name>512 then return nil,'invalidItem' end
    job.items[#job.items+1]=row;job.refs[#job.refs+1]=item;job.quantity=job.quantity+count;job.weight=job.weight+weight
    local group=job.categories[category] or {weight=0,quantity=0};job.categories[category]=group
    group.weight=group.weight+weight;group.quantity=group.quantity+count
   end
   job.index=job.index+1
  end
  return nil,'waiting'
 end
 return job
end
return A
