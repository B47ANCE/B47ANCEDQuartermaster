-- Lightweight server metadata preparation. Reuses the canonical resolver;
-- never instantiates inventory items or builds a second classification tree.
local R=require 'B47ANCEDQuartermaster/Categorizer'
local C={};B47ANCEDQuartermaster.AllocationCatalog=C
local prepared,job;local observed=setmetatable({},{__mode='k'})
function C.invalidate() prepared=nil;job=nil;observed=setmetatable({},{__mode='k'}) end
function C.record(player,entries)
 local values=observed[player] or {};observed[player]=values
 for _,entry in ipairs(entries or {}) do if R.known(entry.category) then values[entry.category]=true end end
end
function C.get(player)
 if not prepared then
  if not job then
   local catalog=B47ANCEDQuartermaster.Catalog
   local ready=catalog and catalog.ready and catalog.ready()
   if ready then
    job={entries=ready.entries,index=0,categories={},started=getTimestampMs()}
    return nil,'waiting'
   end
   if type(getScriptManager)~='function' then return nil,'AllocationCatalogUnavailable' end
   local scripts=getScriptManager():getAllItems();if not scripts or scripts:size()==0 or scripts:size()>100000 then return nil,'AllocationCatalogUnavailable' end
   job={scripts=scripts,index=0,categories={},started=getTimestampMs()}
  end
  return nil,'waiting'
 end
 local out={};for key in pairs(prepared.categories) do out[key]=true end
 for key in pairs(observed[player] or {}) do out[key]=true end
 return out,nil,prepared.elapsed
end
function C.step()
 if not job or isClient() then return end
 local now=getTimestampMs();local n=0
 local count=job.entries and #job.entries or job.scripts:size()
 while job.index<count and n<64 and getTimestampMs()-now<4 do
  local item=job.entries and job.entries[job.index+1] or job.scripts:get(job.index);job.index=job.index+1;n=n+1
  if job.entries or R.catalogEligible(item) then local category=job.entries and item.category or R.resolve(item)
   if not job.categories[category] then job.count=(job.count or 0)+1;if job.count>1024 then job=nil;return end;job.categories[category]=true end
  end
 end
 if job.index==count then prepared={categories=job.categories,elapsed=getTimestampMs()-job.started};job=nil end
end
if Events and Events.OnTick then Events.OnTick.Add(C.step) end
if Events and Events.OnGameStart then Events.OnGameStart.Add(C.invalidate) end
return C
