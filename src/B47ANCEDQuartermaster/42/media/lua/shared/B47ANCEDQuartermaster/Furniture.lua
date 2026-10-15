-- Verified native assemblies only; owned object ModData persists settings.
require 'B47ANCEDQuartermaster/Targets'
local F={key='B47WholeContainer'};B47ANCEDQuartermaster.Furniture=F
local T,S=B47ANCEDQuartermaster.Targets,B47ANCEDQuartermaster.Schema
local serial=0
local function fresh() serial=serial+1;return tostring(getTimestampMs())..':'..serial end
local function revision(n) return type(n)=='number' and n==n and n>=0 and n<2^53 and n==math.floor(n) end
local function root(t) local data=t.obj:getModData()[F.key];if data~=nil and (type(data)~='table' or data.schema~=1 or type(data.children)~='table' or type(data.parents)~='table' or type(data.id)~='string') then return nil,'schema' end;return data end
local function slot(t) return tostring(t.ci) end
local function memberKey(t) local r=root(t);return r and r.id..':'..slot(t) end
function F.members(t,player)
 if not player then return end
 local members=T.siblings(t,player);if #members<2 or #members>64 then return end
 local set={};for _,v in ipairs(members) do set[v.container]=true end
 for _,v in ipairs(members) do
  local back=T.siblings(v,player);if #back~=#members then return end
  for _,b in ipairs(back) do if not set[b.container] then return end end
 end
 table.sort(members,function(a,b) local x,y=T.descriptor(a),T.descriptor(b);for _,k in ipairs({'z','y','x','index','ci'}) do if x[k]~=y[k] then return x[k]<y[k] end end;return false end)
 return members
end
function F.group(t,player)
 local members=F.members(t,player);if not members then return end
 local anchor=members[1];local r,err=root(anchor);if err then return nil,err end
 local parent=r and r.parents[slot(anchor)]
 if parent then
  if type(parent)~='table' or parent.schema~=1 or not S.valid(parent.config) or not revision(parent.revision) or type(parent.id)~='string' or type(parent.members)~='table' then return nil,'schema' end
  local count=0;for _ in pairs(parent.members) do count=count+1 end
  if count~=#members then return nil,'invalid' end
  for _,v in ipairs(members) do
   local saved=parent.members[memberKey(v)];local pos=T.descriptor(v)
   if type(saved)~='table' or saved.x~=pos.x or saved.y~=pos.y or saved.z~=pos.z or saved.ci~=v.ci or saved.kind~=v.container:getType() or saved.count~=v.obj:getContainerCount() then return nil,'invalid' end
  end
 end
 return {anchor=anchor,members=members,parent=parent}
end
function F.state(t)
 local r,err=root(t);if err then return nil,err end
 return r and r.children[slot(t)]
end
function F.load(t,player,whole,details)
 local Store=B47ANCEDQuartermaster.Store
 local state,stateError=F.state(t);if stateError then return nil,stateError end
 if state and (type(state)~='table' or not revision(state.revision) or type(state.group)~='string' or (state.mode~='custom' and state.mode~='inherit')) then return nil,'schema' end
 if not whole and not state then return Store.rawLoad(t) end
 if not whole and state and state.mode=='custom' and not details then local c,e,revision=Store.rawLoad(t);return c,e,revision,{mode='custom'} end
 local group,err=F.group(t,player)
 if group and group.parent and not isClient() then
  local data=root(group.anchor)
  local cleaned,cleanupError=require('B47ANCEDQuartermaster/SortingData').furniture(group.anchor.obj,data)
  if not cleaned then return nil,cleanupError end
  if cleaned~=data then group,err=F.group(t,player) end
 end
 if whole then
  if not group then return nil,err or 'invalid' end
  local p=group.parent;return p and S.copy(p.config) or S.empty(),nil,p and p.revision or 0,{mode='whole',active=p~=nil}
 end
 if type(state)~='table' or (state.mode~='custom' and state.mode~='inherit') or type(state.revision)~='number' then return nil,'schema' end
 if state.mode=='custom' then local c,e,revision=Store.rawLoad(t);return c,e,revision,{mode='custom',parentConfig=group and group.parent and S.copy(group.parent.config)} end
 if not group or not group.parent or group.parent.id~=state.group then return nil,err or 'invalid' end
 return S.copy(group.parent.config),nil,'parent:'..group.parent.revision..':child:'..state.revision,{mode='inherit',parentConfig=S.copy(group.parent.config)}
end
local function ensure(t)
 local md=t.obj:getModData();local data=md[F.key]
 if not data then data={schema=1,id=fresh(),children={},parents={}};md[F.key]=data end
 return data
end
local function authorized(group,player,session,view)
 local B=B47ANCEDQuartermaster.Bindings;local bound=B.session(player,session);if not bound then return false end
 local V=B47ANCEDQuartermaster.DiscoveryView
 for _,t in ipairs(group.members) do
  local record=bound.lookup[t.container]
  if not record or not B.target(player,session,record.token) then return false end
  local applied=bound.appliedView
  if applied then local found=false;for _,meta in ipairs(bound.viewTargets or {}) do if meta.token==record.token and V.includes(meta,applied,bound.viewInfo,player) then found=true;break end end;if not found then return false end end
 end
 return true
end
function F.change(player,record,args)
 if isClient() then return {status='invalid'} end
 local group,err=F.group(record.target,player);if not group then return {status=err or 'invalid'} end
 local whole=args.whole==true
 local current,status,revision=F.load(record.target,player,whole)
 if not current then return {status=status} end
 if args.revision~=revision then return {status='conflict'} end
 local Store=B47ANCEDQuartermaster.Store
 if whole then
  if not authorized(group,player,args.session,args.view) then return {status='invalid'} end
  if args.action=='remove' then
   if not group.parent or args.confirm~=true then return {status='invalid'} end
   local writes={}
   for _,t in ipairs(group.members) do
    local state=F.state(t)
    if state and state.mode=='inherit' then local old,e,rev=Store.rawLoad(t);if not old then return {status=e} end;writes[#writes+1]={target=t,original=old,revision=rev} end
   end
   for _,w in ipairs(writes) do local config,e=Store.rawCommit(w,group.parent.config);if not config then return {status=e} end end
   for _,t in ipairs(group.members) do local data=ensure(t);data.children[slot(t)]=nil;t.obj:transmitModData() end
   ensure(group.anchor).parents[slot(group.anchor)]=nil;group.anchor.obj:transmitModData()
   return {status='ok',config=S.empty(),revision=0,mode='whole'}
  end
  if not S.current(args.config) then return {status='invalid'} end
  if not group.parent then
   -- Explicit activation preserves every existing/imported per-section envelope.
   local existing={};local seenIDs={}
   for _,t in ipairs(group.members) do local c,e,rev,imported,native=Store.rawLoad(t);local _,re=root(t);if not c or re then return {status=e or re} end;local state=F.state(t);if state and state.mode=='inherit' then return {status='invalid'} end
    local identity=memberKey(t);if identity and seenIDs[identity] then return {status='invalid'} end;if identity then seenIDs[identity]=true end
    existing[t.container]=native~=nil or imported==true end
   local id=fresh();local keys={}
   for _,t in ipairs(group.members) do local data=ensure(t);local pos=T.descriptor(t);keys[memberKey(t)]={x=pos.x,y=pos.y,z=pos.z,ci=t.ci,kind=t.container:getType(),count=t.obj:getContainerCount()};data.children[slot(t)]={group=id,mode=existing[t.container] and 'custom' or 'inherit',revision=0} end
   group.parent={schema=1,id=id,revision=0,config=S.empty(),members=keys};ensure(group.anchor).parents[slot(group.anchor)]=group.parent
  end
  group.parent.config=S.copy(args.config);group.parent.revision=group.parent.revision+1
  for _,t in ipairs(group.members) do t.obj:transmitModData() end
  return {status='ok',config=S.copy(group.parent.config),revision=group.parent.revision,mode='whole'}
 end
 if not group.parent then return {status='invalid'} end
 local state=F.state(record.target);if not state or state.group~=group.parent.id then return {status='invalid'} end
 if args.action=='reset' then
  if args.confirm~=true then return {status='invalid'} end
  state.mode='inherit';state.revision=state.revision+1;record.target.obj:transmitModData()
 else
  if state.mode=='inherit' and args.action~='custom' then return {status='invalid'} end
  if not S.current(args.config) then return {status='invalid'} end
  local old,e,rev=Store.rawLoad(record.target);if not old then return {status=e} end
  local saved,error=Store.rawCommit({target=record.target,original=old,revision=rev},args.config);if not saved then return {status=error} end
  state.mode='custom';state.revision=state.revision+1;record.target.obj:transmitModData()
 end
 local c,e,rev,info=F.load(record.target,player,false);return c and {status='ok',config=c,revision=rev,mode=info.mode} or {status=e}
end
return F
