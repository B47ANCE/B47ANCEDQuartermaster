-- Explicit, read-only inspection of one already-bound physical compartment.
-- Configuration permission alone never authorizes an inventory read.
local Profile=require 'B47ANCEDQuartermaster/AllocationProfile'
local Storage=require 'B47ANCEDQuartermaster/AllocationStorage'
local Q=B47ANCEDQuartermaster;local I={}
function I.handle(player,args)
 if isClient() or not player or type(args)~='table' or not Profile.valid(args.profile) then return {status='invalid'} end
 local record=Q.Bindings.target(player,args.session,args.token)
 if not record or not Q.RoomAccess.can(player,record.target,'inspect') then return {status='RoomAccessDenied'} end
 local parts,reason=Storage.atomic(player,{record.target},getTimestampMs()+8)
 if not parts then return {status=reason} end
 local profile=args.profile or Profile.empty();local scope=parts[1].scope
 local over={};local seen={}
 for _,item in ipairs(parts[1].items) do
  for _,ceiling in ipairs(Profile.ceilings(profile,item.fullType,item.path)) do
   local key=ceiling.kind..'\0'..ceiling.key
   if not seen[key] then
    seen[key]=true;local used=scope[ceiling.kind=='category' and 'categories' or 'items'][ceiling.key] or 0
    local limit=scope.capacity*ceiling.percent/100
    if used>limit or ceiling.percent==0 then over[#over+1]={key=ceiling.key,kind=ceiling.kind,used=used,limit=limit} end
   end
  end
 end
 table.sort(over,function(a,b) return a.kind..a.key<b.kind..b.key end)
 local truncated=#over>32;for n=#over,33,-1 do over[n]=nil end
 return {status='ok',capacity=scope.capacity,used=scope.used,over=over,truncated=truncated,advisory=true}
end
return I
