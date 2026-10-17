-- Personal intent, persisted/validated by authority. Never alters native capacities.
require 'B47ANCEDQuartermaster/Personal'
local Q=B47ANCEDQuartermaster
local L={};Q.LoadPolicy=L
local cache=setmetatable({},{__mode="k"})
local function integer(n,min,max) return type(n)=='number' and n==n and n%1==0 and n>=min and n<=max end
local function policy(player)
 if isClient() then return end
 local entry=cache[player]
 local data=entry and entry.server==isServer() and entry.data
 if not data then local _,found=Q.Personal.identity(player);data=found
  if not data then return end;cache[player]={data=data,server=isServer()} end
 local p=data.loadPolicy
 if p==nil then p={schema=1,revision=0,enabled=false,utilization=100};data.loadPolicy=p end
 if type(p)~='table' or p.schema~=1 or not integer(p.revision,0,9007199254740990)
  or type(p.enabled)~='boolean' or not integer(p.utilization,50,100) then return end
 return p
end
function L.cleanup(player) cache[player]=nil end
function L.get(player)
 local p=policy(player)
 return p and {schema=1,revision=p.revision,enabled=p.enabled,utilization=p.utilization}
end
function L.handle(player,command,args)
 if isClient() or not player or type(args)~='table' then return {status='invalid'} end
 local p=policy(player);if not p then return {status='schema'} end
 local inventory=player:getInventory()
 local hard=inventory.getEffectiveCapacity and inventory:getEffectiveCapacity(player)
 if type(hard)~='number' or hard~=hard or hard<=0 or hard==math.huge then return {status='unsupported'} end
 if command=='loadChange' then
  if Q.Movement.runs[player] or Q.Movement.operations[player] then return {status='busy'} end
  if args.revision~=p.revision then return {status='conflict'} end
  if type(args.enabled)~='boolean' or not integer(args.utilization,50,100) then return {status='invalid'} end
  if p.revision>=9007199254740990 then return {status='schema'} end
  p.enabled=args.enabled;p.utilization=args.utilization;p.revision=p.revision+1
 elseif command~='loadGet' then return {status='invalid'} end
 return {status='ok',policy=L.get(player),hard=hard,comfortable=player:getMaxWeight(),current=inventory:getCapacityWeight()}
end
return L
