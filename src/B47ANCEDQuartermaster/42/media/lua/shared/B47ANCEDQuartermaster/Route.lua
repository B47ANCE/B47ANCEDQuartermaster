-- Server-side advisory navigation approximation; never grants access or changes assignments.
local R={};B47ANCEDQuartermaster.Route=R
local Migration=require 'B47ANCEDQuartermaster/Migration'
function R.enabled() return Migration.option('RouteOptimization')~=false end
function R.key(d) return tostring(d.instance or ('ground:'..tostring(d.x)..':'..tostring(d.y)..':'..tostring(d.z)))..':'..tostring(d.ci or 0) end
local function geometry(p,d) return (d.x-p:getX())^2+(d.y-p:getY())^2 end
function R.estimate(start,d,budget)
 local cell=getCell();local goal=cell:getGridSquare(d.x,d.y,d.z)
 if not start or not goal or not start.isBlockedTo or start:getZ()~=d.z then return {known=false} end
 local q={{square=start,length=0}};local seen={[start]=true};local index=1;local examined=0
 while index<=#q and budget.left>0 and examined<64 do
  local node=q[index];index=index+1;budget.left=budget.left-1;examined=examined+1;budget.examined=(budget.examined or 0)+1
  local square=node.square
  if math.max(math.abs(square:getX()-d.x),math.abs(square:getY()-d.y))<=1 and not square:isBlockedTo(goal) then return {known=true,length=node.length,stand=square,kind='loaded-cardinal-approximation'} end
  for _,delta in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
   local other=cell:getGridSquare(square:getX()+delta[1],square:getY()+delta[2],square:getZ())
   if other and not seen[other] and other.isBlockedTo and other.isFree and other:isFree(false) and other.TreatAsSolidFloor and other:TreatAsSolidFloor() and not square:isBlockedTo(other) and (not square.isWindowTo or not square:isWindowTo(other)) then seen[other]=true;q[#q+1]={square=other,length=node.length+1} end
  end
 end
 return {known=false,kind='uncertain-no-proof'} -- never treat bounded exhaustion as unreachable
end
function R.tripEstimate(start,stop,budget)
 if stop.carried or #stop.sources==0 then return R.estimate(start,stop.d,budget) end
 local sources={};for _,source in ipairs(stop.sources) do sources[#sources+1]=source end
 table.sort(sources,function(a,b)
  if not start then return R.key(a)<R.key(b) end
  local x=(a.x-start:getX())^2+(a.y-start:getY())^2;local y=(b.x-start:getX())^2+(b.y-start:getY())^2
  if x~=y then return x<y end;return R.key(a)<R.key(b)
 end)
 local best
 for i=1,math.min(2,#sources) do
  local pickup=R.estimate(start,sources[i],budget)
  if pickup.known then local delivery=R.estimate(pickup.stand,stop.d,budget)
   if delivery.known then delivery.length=pickup.length+delivery.length;if not best or delivery.length<best.length then best=delivery end end
  end
 end
 return best or {known=false,kind='uncertain-pickup-delivery'}
end
function R.order(offers,player,trace)
 local stops,map={},{}
 for _,offer in ipairs(offers) do local k=R.key(offer.destination);if not map[k] then map[k]={key=k,d=offer.destination,work=0,screen=geometry(player,offer.destination),sources={},sourceKeys={}};stops[#stops+1]=map[k] end;local stop=map[k];stop.work=stop.work+1
  if offer.carried or not offer.source then stop.carried=true
  else local source=offer.source;local sk=source.ground and ('ground:'..source.x..':'..source.y..':'..source.z) or R.key(source);if not stop.sourceKeys[sk] then stop.sourceKeys[sk]=true;stop.sources[#stop.sources+1]=source end end
 end
 table.sort(stops,function(a,b) if a.screen~=b.screen then return a.screen<b.screen end;return a.key<b.key end)
 local budget={left=512,examined=0};local start=player.getCurrentSquare and player:getCurrentSquare();local measured=require('B47ANCEDQuartermaster/SortTrace').begin()
 for i,stop in ipairs(stops) do if i<=8 then stop.cost=R.tripEstimate(start,stop,budget) else stop.cost={known=false} end end
 -- Evaluate bounded two-stop continuations; request-local estimates never survive world changes.
 for i=1,math.min(3,#stops) do
  local stop=stops[i];stop.score=stop.cost.length
  if stop.cost.known and stop.cost.length>0 then
   local nextCost
   for j=1,math.min(3,#stops) do if i~=j then local c=R.tripEstimate(stop.cost.stand,stops[j],budget);if c.known and (not nextCost or c.length<nextCost) then nextCost=c.length end end end
   if nextCost then stop.score=stop.score+nextCost end
  end
 end
 table.sort(stops,function(a,b)
  local ac,bc=a.cost,b.cost
  if ac.known and ac.length==0 or bc.known and bc.length==0 then if (ac.known and ac.length==0)~=(bc.known and bc.length==0) then return ac.known and ac.length==0 end end
  if ac.known~=bc.known then return ac.known end
  local x,y=a.score or a.screen,b.score or b.screen;if x~=y then return x<y end
  if a.work~=b.work then return a.work>b.work end;return a.key<b.key
 end)
 local ranks={};for i,stop in ipairs(stops) do ranks[stop.key]=i end
 table.sort(offers,function(a,b) local x,y=ranks[R.key(a.destination)],ranks[R.key(b.destination)];if x~=y then return x<y end;return a.itemID<b.itemID end)
 require('B47ANCEDQuartermaster/SortTrace').emit(trace,'ROUTE_PLANNING','bounded-approximation',nil,nil,measured,budget.examined,'request-local')
 return stops[1] and stops[1].key,{stops=#stops,examined=budget.examined,pathRequests=0,uncertain=true}
end
return R
