local function empty(t) for _ in pairs(t) do return false end;return true end
-- Shared organizational goals. No reservations, transfers or inventory mutation.
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local Access=require 'B47ANCEDQuartermaster/RoomAccess'
local Options=require 'B47ANCEDQuartermaster/Migration'
local S={work=setmetatable({},{__mode='k'})};B47ANCEDQuartermaster.Stock=S
local function int(n,lo,hi) return type(n)=='number' and n==n and n%1==0 and n>=lo and n<=hi end
local function enabled() return Options.option('StockEnabled')~=false end
function S.interval() local n=Options.option('StockCheckSeconds');return int(n,5,300) and n or 30 end
local function library()
 if isClient() then return end
 local r=ModData.getOrCreate('B47ANCEDQuartermasterStock')
 if empty(r) then r.schema=1;r.profiles={} end
 if r.schema~=1 or type(r.profiles)~='table' then return end
 local count=0
 for key,p in pairs(r.profiles) do
  if type(key)~='string' or #key>32768 or type(p)~='table' or not int(p.revision,0,9007199254740000) or type(p.targets)~='table' then return end
  local items=0;for t,n in pairs(p.targets) do if type(t)~='string' or #t>256 or not int(n,1,1000000) then return end;items=items+1 end
  if items>64 then return end;count=count+1;if count>256 then return end
 end
 return r
end
local function copy(p)
 local out={};for t,n in pairs(p and p.targets or {}) do out[t]=n end;return out
end
local function room(actor,id,revision,edit)
 if not Access.designated({id=id}) then return end
 local api=Access.service();if not api or type(api.canAccess)~='function' then return end
 local result=api.resolveRoom(actor,id,revision);if result.status~='ok' then return end
 if edit and api.canAccess(actor,id,'configureRoom').state~='allow' then return end
 return result.room
end
local function selected(actor,args,edit)
 if args.kind=='room' then
  local r=room(actor,args.id,args.roomRevision,edit)
  return r and {key='room:'..r.id,kind='room',id=r.id,roomRevision=r.revision,label=r.name}
 end
 if args.kind~='building' then return end
 local scope=Scope.capture(actor,'building');if not scope then return end
 local sq=actor:getCurrentSquare()
 if not Access.can(actor,{obj={getSquare=function() return sq end}},edit and 'configure' or 'inspect') then return end
 return {key=Scope.signature(scope),kind='building',label=scope.label}
end
function S.options(actor)
 local scopes={};local building=selected(actor,{kind='building'},false);if building then scopes[#scopes+1]=building end
 local api=Access.service()
 if api then
  local values,_,_,state=Access.metadata(actor);local result=state=='ready' and {status='ok',rooms=values}
  if result and result.status=='ok' then for _,r in ipairs(result.rooms) do if Access.designated(r) then
   scopes[#scopes+1]={kind='room',id=r.id,roomRevision=r.revision,label=r.label or r.name}
  end end end
 end
 return scopes
end
function S.handle(actor,command,args)
 if isClient() or not actor or actor:isDead() or type(args)~='table' then return {status='invalid'} end
 if not enabled() then return {status='StockDisabled'} end
 if command=='stockOptions' then return {status='ok',scopes=S.options(actor)} end
 local scope=selected(actor,args,command=='stockSet');if not scope then return {status='RoomAccessDenied'} end
 if args.scopeKey~=nil and args.scopeKey~=scope.key or command=='stockSet' and args.scopeKey~=scope.key then return {status='conflict'} end
 local r=library();if not r then return {status='schema'} end
 local p=r.profiles[scope.key] or {revision=0,targets={}}
 if command=='stockSet' then
  if args.revision~=p.revision then return {status='conflict'} end
  if type(args.fullType)~='string' or #args.fullType>256 or not int(args.quantity,0,1000000)
   or args.quantity>0 and not getScriptManager():FindItem(args.fullType) then return {status='invalid'} end
  local count=0;for _ in pairs(p.targets) do count=count+1 end
  if count>=64 and not p.targets[args.fullType] and args.quantity>0 then return {status='tooLarge'} end
  if not r.profiles[scope.key] then local profiles=0;for _ in pairs(r.profiles) do profiles=profiles+1 end;if profiles>=256 then return {status='tooLarge'} end end
  p.targets[args.fullType]=args.quantity>0 and args.quantity or nil;p.revision=p.revision+1;r.profiles[scope.key]=p
 elseif command~='stockGet' then return {status='invalid'} end
 return {status='ok',scope=scope,targets=copy(p),revision=p.revision,canEdit=selected(actor,args,true)~=nil}
end
function S.profile(scope)
 local r=library();if not r then return end
 local p=r.profiles[scope];return copy(p),p and p.revision or 0
end
-- Consume the same paginated, permission-checked server ledger reader as paper
-- and PC views. Separate reader state prevents changing the user's item page.
function S.read(actor,args,readPage)
 if isClient() or not actor or actor:isDead() or type(args)~='table' then return {status='invalid'} end
 if not enabled() then return {status='StockDisabled'} end
 if args.stockKind~=nil and args.stockKind~='building' and args.stockKind~='room' then return {status='invalid'} end
 local kind=args.stockKind or 'building';local rid=args.stockRoom
 local definition=kind=='room' and require('B47ANCEDQuartermaster/LedgerRooms').one(actor,rid)
 if kind=='room' and (type(rid)~='string' or #rid>180 or not definition) then return {status='RoomAccessDenied'} end
 local signature=tostring(args.item)..':'..tostring(args.drive)..':'..kind..':'..tostring(rid)..':'..tostring(args.ledgerMode)..':'..tostring(args.stockBuilding)
 local metadata,ctx=readPage(actor,{item=args.item,drive=args.drive,computer=args.computer,ledgerMode=args.ledgerMode,query='',room='',metadataOnly=true})
 if metadata.status~='ok' or not ctx then return metadata end
 local area=ctx.snapshot.stockAreas and (args.stockBuilding and ctx.snapshot.areaTokens[args.stockBuilding] or ctx.snapshot.stockAreas[1])
 if args.stockBuilding and not area then return {status='StockUnavailable'} end
 local key=kind=='room' and 'room:'..rid or area and area.key or ctx.snapshot.signature
 local targets,profileRevision=S.profile(key);if not targets then return {status='schema'} end
 if empty(targets) then S.cleanup(actor);return {status='ok',rows={},stockAreas=metadata.stockAreas,scope=ctx.snapshot.scope.label,revision=profileRevision,live=metadata.live,fresh=metadata.fresh,complete=metadata.summary=='LedgerComplete',canNotify=ctx.digital and metadata.live and metadata.fresh and metadata.summary=='LedgerComplete',interval=S.interval()} end
 local w=S.work[actor]
 if not w or w.signature~=signature then
  local count=0;for _ in pairs(S.work) do count=count+1 end;if not w and count>=16 then return {status='busy'} end
  w={signature=signature,counts={},checks={},at=getTimestampMs()};S.work[actor]=w end
 if kind=='room' then
  if not definition or w.roomRevision and w.roomRevision~=definition.revision then S.cleanup(actor);return {status='conflict'} end
  w.roomRevision=definition.revision
 end
 if getTimestampMs()-w.at>120000 then S.cleanup(actor);return {status='StockUnavailable'} end
 for _=1,(w.finishedRows and 0 or 4) do
  local request={item=args.item,drive=args.drive,computer=args.computer,ledgerMode=args.ledgerMode,cursor=w.cursor,query='',room=''}
  local result,context=readPage(actor,request)
  if result.status=='waiting' then return result end
  if result.status~='ok' then S.cleanup(actor);return result end
  if result.redacted then S.cleanup(actor);return {status='StockUnavailable'} end
  if not context or not context.snapshot then S.cleanup(actor);return {status='StockUnavailable'} end
  if w.revision and w.revision~=result.revision then S.cleanup(actor);return {status='waiting',summary='StockLoading'} end
  w.revision=result.revision;w.context=context;w.live=result.live==true;w.fresh=result.fresh==true;w.complete=result.summary=='LedgerComplete'
  for _,row in ipairs(result.rows) do
   local area=context.snapshot.stockAreas and (args.stockBuilding and context.snapshot.areaTokens[args.stockBuilding] or context.snapshot.stockAreas[1])
   if args.stockBuilding and not area then S.cleanup(actor);return {status='StockUnavailable'} end
   local include=kind=='building' and (not area or row.stockArea==area.id)
   if kind=='room' then
    local p=row.position
    include=definition and definition.contains(p)
   end
   if include and not row.empty then w.counts[row.fullType]=(w.counts[row.fullType] or 0)+row.quantity end
   local p=row.position;w.checks[p.x..':'..p.y..':'..p.z]={position=p}
  end
  w.cursor=result.cursor
  if not w.cursor then
   w.finishedRows=true;w.result=result;w.checkOrder={};w.checkIndex=1
   for _,entry in pairs(w.checks) do w.checkOrder[#w.checkOrder+1]=entry end
   break
  end
 end
 if w.finishedRows then
  local context=w.context;local result=w.result
  w.visibility=w.visibility or {}
  for _=1,64 do
   local entry=w.checkOrder[w.checkIndex];if not entry then break end
   if not require('B47ANCEDQuartermaster/LedgerAccess').read(actor,entry,w.visibility) then S.cleanup(actor);return {status='StockUnavailable'} end
   w.checkIndex=w.checkIndex+1
  end
  if w.checkOrder[w.checkIndex] then return {status='waiting',summary='StockLoading'} end
  local verified,ctx=readPage(actor,{item=args.item,drive=args.drive,computer=args.computer,ledgerMode=args.ledgerMode,query='',room=''})
  if verified.status~='ok' or not ctx or ctx.snapshot.id~=context.snapshot.id then S.cleanup(actor);return {status=verified.status=='ok' and 'StockUnavailable' or verified.status} end
   local area=context.snapshot.stockAreas and (args.stockBuilding and context.snapshot.areaTokens[args.stockBuilding] or context.snapshot.stockAreas[1])
   local key=kind=='room' and 'room:'..rid or area and area.key or context.snapshot.signature
   local targets,revision=S.profile(key);if not targets then S.cleanup(actor);return {status='schema'} end
   local rows={};for t,target in pairs(targets) do
    local script=getScriptManager():FindItem(t);local n=w.counts[t] or 0
    rows[#rows+1]={fullType=t,name=script and script:getDisplayName() or t,current=n,target=target,remaining=math.max(0,target-n)}
   end;table.sort(rows,function(a,b) return a.fullType<b.fullType end)
   local alert=w.live and w.fresh and w.complete and context.digital==true
   local out={status='ok',rows=rows,scope=context.snapshot.scope.label,scopeKey=kind=='room' and rid or args.stockBuilding or context.snapshot.id,stockAreas=result.stockAreas,revision=revision,live=w.live,fresh=w.fresh,complete=w.complete,canNotify=alert,interval=S.interval()}
   S.cleanup(actor);return out
 end
 return {status='waiting',summary='StockLoading'}
end
function S.cleanup(actor) S.work[actor]=nil;if B47ANCEDQuartermaster.Ledger then B47ANCEDQuartermaster.Ledger.stockReaders[actor]=nil end end
if not isClient() then
 local ok,connections=pcall(require,'B47ANCEDPCFramework/Connections')
 if ok and not connections.policies.quartermaster then connections.registerPolicy('quartermaster',function(actor,pc,action) return Access.can(actor,{obj=pc},action)==true end) end
end
return S
