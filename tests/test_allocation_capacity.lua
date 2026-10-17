local A=require 'B47ANCEDQuartermaster/AllocationProfile';local C=require 'B47ANCEDQuartermaster/AllocationCapacity'
local storage={};local existing={ref={},fullType='Base.Steak',path={'Food','Meat'},weight=5}
local scope=assert(C.measure({{container=storage,capacity=50,used=5,items={existing}},{container=storage,capacity=50,used=5,items={existing}}}))
assert(scope.capacity==50 and scope.used==5 and scope.categories.Food==5 and scope.categories.Meat==5)
local p=A.empty();p.cats.Food=60;p.cats.Meat=60;p.items['Base.Steak']=25
local function incoming(weight,kind) return {destination=storage,ref={},fullType=kind or 'Base.Steak',path={'Food','Meat'},weight=weight} end
assert(C.check(p,scope,{},incoming(7.5)))
assert(not C.check(p,scope,{},incoming(7.50001)),'item ceiling rounded upwards')
assert(C.check(p,scope,{},incoming(25,'Base.Chicken')))
assert(not C.check(p,scope,{},incoming(25.01,'Base.Chicken')),'aggregate ancestor ceiling was lost')
local zero=A.empty();zero.cats.Food=0;assert(not C.check(zero,scope,{},incoming(0)),'zero-weight item bypassed 0%')
local time=0;local ledger=C.ledger(function() return time end)
local first=incoming(5);assert(ledger:reserve('client-a',first,p,scope))
assert(not ledger:reserve('client-b',incoming(5),p,scope),'concurrent admission double-spent remaining quota')
assert(ledger:reserve('client-a',first,p,scope) and ledger.count==1,'reservation replay counted twice')
assert(not ledger:reserve('duplicate-item',first,p,scope))
-- Once observed natively, reservations do not double-count the same instance.
local delivered=assert(C.measure({{container=storage,capacity=50,used=10,items={existing,first}}}))
assert(C.check(p,delivered,ledger:pending(),incoming(2.5)))
assert(not C.check(p,delivered,ledger:pending(),incoming(2.50001)))
ledger:release('client-a');assert(ledger.count==0)
assert(ledger:reserve('expiring',incoming(5),p,scope));time=1800000;assert(#ledger:pending()==0 and ledger.count==0)
local nested={ref={},fullType='Base.Bag',path={'Container'},weight=12}
local bags=assert(C.measure({{container={},capacity=50,used=12,items={nested}}}))
assert(bags.categories.Container==12 and bags.used==12,'nested weight recursively counted twice')
local pScope={primary={capacity=100,used=59.999},secondary={capacity=100,used=0}}
assert(C.rolePreference(pScope,60,80)=='primary');pScope.primary.used=60
assert(C.rolePreference(pScope,60,80)=='secondary');pScope.secondary.used=80
assert(C.rolePreference(pScope,60,80)=='primary')
assert(C.rolePreference({secondary={capacity=100,used=90}},60,80)=='secondary')
assert(C.rolePreference({},60,80)=='unassigned')
print('PASS OFFLINE allocation capacity: exact ceilings, aggregate/non-multiplicative quotas, physical dedupe, nested units, zero limits, concurrent/replayed/expired reservations, observed completion and threshold edges')
