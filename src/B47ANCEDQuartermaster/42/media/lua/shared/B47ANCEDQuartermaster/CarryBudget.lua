-- Server-interpreted comfort allowance. Native container capacity is never changed.
local Migration=require 'B47ANCEDQuartermaster/Migration'
local C={}
function C.allowance()
 local value=Migration.option('CarryAllowance');local n=tonumber(value) or 0
 if n~=n or n==math.huge or n==-math.huge then n=0 end
 return math.max(0,math.min(40,math.floor(n)))
end
function C.free(player)
 return math.max(0,player:getMaxWeight()+C.allowance()-player:getInventory():getCapacityWeight())
end
function C.factor(container)
 local bag=container.getContainingItem and container:getContainingItem()
 if bag and bag:isEquipped() then return math.max(0,math.min(1,1-bag:getWeightReduction()/100)) end
 return 1
end
function C.accepts(player,container,item)
 return math.max(0,item:getActualWeight())*C.factor(container)<=C.free(player)
end
return C
