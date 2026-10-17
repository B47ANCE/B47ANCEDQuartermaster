local value
package.loaded['B47ANCEDQuartermaster/Migration']={option=function() if value~=nil then return value end end}
local C=require 'B47ANCEDQuartermaster/CarryBudget'
local inventory={getCapacityWeight=function() return 18 end}
local player={getInventory=function() return inventory end,getMaxWeight=function() return 20 end}
assert(C.allowance()==0 and C.free(player)==2)
value=5;assert(C.free(player)==7)
value=100;assert(C.allowance()==40);value=-4;assert(C.allowance()==0)
value=0/0;assert(C.allowance()==0);value=math.huge;assert(C.allowance()==0)
value=2.9;assert(C.allowance()==2)
local item={getActualWeight=function() return 4 end}
value=0;assert(not C.accepts(player,inventory,item));value=2;assert(C.accepts(player,inventory,item))
local equipped=true;local bag={isEquipped=function() return equipped end,getWeightReduction=function() return 50 end}
local carrier={getContainingItem=function() return bag end}
value=0;assert(C.accepts(player,carrier,item));equipped=false;assert(not C.accepts(player,carrier,item))
print('PASS OFFLINE carry allowance: default/missing/invalid bounds, kilograms, equipped bag weight reduction and ordinary carried containers')
