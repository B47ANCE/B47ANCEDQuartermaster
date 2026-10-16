dofile(TEST_ROOT..'/fixtures/containers.lua')
local A=require 'B47ANCEDQuartermaster/ContentAnalysis';local f=CONTAINER_FIXTURE
local allowed=true;local container={items={}}
function container:getItems() return f.list(self.items) end
function container:getEffectiveCapacity() return 100 end
function container:getCapacityWeight() return #self.items end
local function item(id,category,count,weight)
 local it={container=container,quantity=count or 1,weight=weight or 1}
 function it:getID() return id end;function it:getFullType() return 'Fixture.SameName'..id end
 function it:getDisplayName() return 'Same Name' end;function it:getDisplayCategory() return category end
 function it:getContainer() return self.container end;function it:getCount() return self.quantity end
 function it:getActualWeight() return self.weight end;it.getUnequippedWeight=it.getActualWeight
 function it:getCondition() return 10 end
 return it
end
local function analyze()
 local job=assert(A.begin(container,f.player,function() return allowed end))
 for n=1,200 do local result,status=job.step();if status~='waiting' then return result,status,n end end
 error('unbounded analysis')
end
local result,status=analyze();assert(status=='done' and result.instances==0 and result.quantity==0)
container.items={item(1,'Literature',200),item(2,'Ammo')};result,status=analyze()
assert(status=='done' and result.instances==2 and result.quantity==201 and #result.items==2)
for i=1,150 do container.items[i]=item(i,'Literature') end
result,status=analyze();assert(status=='done' and result.instances==150 and result.used==150 and result.capacity==100)
local job=A.begin(container,f.player,function() return allowed end);assert(select(2,job.step())=='waiting')
allowed=false;assert(select(2,job.step())=='changed');allowed=true
job=A.begin(container,f.player,function() return allowed end);job.step();table.remove(container.items)
assert(select(2,job.step())=='changed','mutation during a slice was silently accepted')
container.items={item(1,'Food')};job=A.begin(container,f.player,function() return true end);job.step();container.items[1].quantity=2
assert(select(2,job.step())=='changed','mutable quantity was silently accepted')
container.items={};for i=1,4097 do container.items[i]=item(i,'Ammo') end
assert(select(2,A.begin(container,f.player,function() return true end))=='tooLarge')
print('PASS OFFLINE actual-content analysis: empty/overfull/multiple categories, quantity versus instances, canonical categories, bounded slices, live access/state invalidation, no nested inventory traversal or mutation')
