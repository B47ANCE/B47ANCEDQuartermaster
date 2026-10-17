-- Server-interpreted comfort allowance. Native container capacity is never changed.
local Migration=require 'B47ANCEDQuartermaster/Migration'
local C={}
function C.allowance()
 local value=Migration.option('CarryAllowance');local n=tonumber(value) or 0
 if n~=n or n==math.huge or n==-math.huge then n=0 end
 return math.max(0,math.min(40,math.floor(n)))
end
function C.free(player)
 return math.max(0,C.limit(player)-player:getInventory():getCapacityWeight())
end
function C.limit(player)
 local service=B47ANCEDQuartermaster and B47ANCEDQuartermaster.LoadPolicy
 if service and not isClient() then
  local p=service.get(player)
  if not p then return 0 end -- corrupt/future preferences never relax admission
  if p.enabled then
   local inventory=player:getInventory()
   local hard=inventory.getEffectiveCapacity and inventory:getEffectiveCapacity(player)
   if type(hard)~='number' or hard~=hard or hard<=0 or hard==math.huge then return 0 end
   return hard*p.utilization/100
  end
 end
 return player:getMaxWeight()+C.allowance()
end
function C.weight(item)
 return math.max(0,item.getUnequippedWeight and item:getUnequippedWeight() or item:getActualWeight())
end
function C.factor(container)
 local bag=container.getContainingItem and container:getContainingItem()
 if bag and bag:isEquipped() then return math.max(0,math.min(1,1-bag:getWeightReduction()/100)) end
 return 1
end
function C.accepts(player,container,item)
 return C.weight(item)*C.factor(container)<=C.free(player)
end
return C
