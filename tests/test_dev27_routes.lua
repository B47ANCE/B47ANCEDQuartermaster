dofile(TEST_ROOT..'/fixtures/containers.lua')
local Q=B47ANCEDQuartermaster or {};B47ANCEDQuartermaster=Q
local R=require 'B47ANCEDQuartermaster/Route';local grid={}
for x=-6,6 do for y=-6,6 do local sx,sy=x,y;local sq={getX=function() return sx end,getY=function() return sy end,getZ=function() return 0 end}
 function sq:isFree() return true end;function sq:TreatAsSolidFloor() return true end
 function sq:isBlockedTo(other) local ox,oy=other:getX(),other:getY();return (sx<=0 and ox>=1 or sx>=1 and ox<=0) and math.min(sy,oy)<=2 and math.max(sy,oy)>=-2 end
 grid[x..':'..y]=sq end end
getCell=function() return {getGridSquare=function(_,x,y,z) return z==0 and grid[x..':'..y] end} end
local player={getX=function() return 0 end,getY=function() return 0 end,getZ=function() return 0 end,getCurrentSquare=function() return grid['0:0'] end}
local offers={{itemID=1,destination={instance='close',ci=0,x=2,y=0,z=0}},{itemID=2,destination={instance='open',ci=0,x=0,y=4,z=0}}}
local first,info=R.order(offers,player);assert(first=='open:0','geometric shortcut ignored wall route')
assert(info.examined<=512 and info.pathRequests==0)
local inRange={itemID=3,destination={instance='here',ci=0,x=0,y=1,z=0}};offers[#offers+1]=inRange
first=R.order(offers,player);assert(first=='here:0','current-position work lost preference')
local source={x=0,y=4,z=0,instance='pickup',ci=0};local trip=R.tripEstimate(grid['0:0'],{d={x=0,y=1,z=0},sources={source},carried=false},{left=128});assert(trip.known and trip.length>0,'pickup leg omitted from current-destination cost')
local cost=R.estimate(grid['0:0'],{x=0,y=0,z=1},{left=64});assert(not cost.known,'invented cross-floor route')
local empty={left=0};assert(not R.estimate(grid['0:0'],{x=5,y=5,z=0},empty).known,'bounded exhaustion claimed unreachable/reachable')
local original=grid['0:0'].isBlockedTo;grid['0:0'].isBlockedTo=function() return true end
assert(not R.estimate(grid['0:0'],{x=2,y=0,z=0},{left=64}).known,'world change reused old estimate');grid['0:0'].isBlockedTo=original
local many={};for i=1,100 do many[i]={itemID=i,destination={instance=tostring(i),ci=0,x=i%6,y=4,z=0}} end
local _,bounded=R.order(many,player);assert(bounded.examined<=512 and #many==100,'candidate set exceeded bound or lost exact offers')
SandboxVars.B47ANCEDQuartermaster.RouteOptimization=false;assert(not R.enabled());SandboxVars.B47ANCEDQuartermaster.RouteOptimization=nil;assert(R.enabled())
print('PASS OFFLINE dev27 routes: current-position preference, wall-aware ordering, uncertain floors, bounded horizon, fresh world state and authoritative sandbox switch')
