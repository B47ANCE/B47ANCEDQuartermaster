-- Quartermaster-owned profiles reference Rooms identities; no geometry is saved.
local Profile=require 'B47ANCEDQuartermaster/AllocationProfile'
local Access=require 'B47ANCEDQuartermaster/RoomAccess'
require 'B47ANCEDQuartermaster/Configuration'
local S=B47ANCEDQuartermaster.Schema
local R={};B47ANCEDQuartermaster.RoomAllocation=R
local replays=setmetatable({},{__mode='k'})
local validated=setmetatable({},{__mode='k'})
local function integer(v) return type(v)=='number' and v==v and v>=0 and v<2^53-1 and v==math.floor(v) end
local function account(player) return isServer() and player:getUsername() or 'local:'..player:getPlayerNum() end
function R.library()
 if isClient() then return nil,'invalid' end
 local data=ModData.getOrCreate('B47ANCEDQuartermaster');local lib=data.roomAllocations
 if lib==nil then return {schema=1,revision=0,profiles={}},data end
 if validated[lib] then return lib,data end
 if type(lib)~='table' or lib.schema~=1 or not integer(lib.revision) or type(lib.profiles)~='table' then return nil,'schema' end
 local count,total=0,0
 for id,row in pairs(lib.profiles) do
  if type(id)~='string' or #id<1 or #id>180 or id:find('%c') or type(row)~='table' or not integer(row.revision)
   or not integer(row.roomRevision) or type(row.active)~='boolean' or type(row.owner)~='string' or #row.owner<1 or #row.owner>256
   or type(row.profile)~='table' or not Profile.valid(row.profile) or not Profile.percent(row.primaryAt) or not Profile.percent(row.secondaryAt)
   or type(row.priority)~='number' or row.priority~=math.floor(row.priority) or math.abs(row.priority)>999999
   or not S.valid({cats={},items={},presets=row.presets,priority=0}) then return nil,'schema' end
  count=count+1;if count>256 then return nil,'schema' end
  for _,kind in ipairs({'cats','items'}) do for key in pairs(row.profile[kind]) do total=total+#key+16 end end
  for full,path in pairs(row.profile.paths) do total=total+#full;for _,cat in ipairs(path) do total=total+#cat+8 end end
  if total>4194304 then return nil,'schema' end
 end
 validated[lib]=true;return lib,data
end
local function service()
 local api,status=Access.service()
 if not api then return nil,status=='absent' and 'RoomServiceAbsent' or 'RoomPermissionUnavailable' end
 if type(api.roomTypes)~='function' or type(api.canAccess)~='function' or type(api.storageScopes)~='function' or type(api.storageTiles)~='function' then return nil,'RoomPermissionUnavailable' end
 return api
end
R.service=service
function R.definition(player,id,revision)
 local api,e=service();if not api then return nil,e end
 if type(id)~='string' or #id<1 or #id>180 or id:find('%c') then return nil,'invalid' end
 local result=api.resolveRoom(player,id,revision)
 if result.status~='ok' then return nil,result.status end
 local permission=api.canAccess(player,result.room.id,'configureRoom')
 if permission.state~='allow' then return nil,permission.reason or 'RoomAccessDenied' end
 return result.room
end
function R.effective(row,definitions)
 for key,link in pairs(row.presets) do if not S.resolves(definitions[key],link) then return nil,'AllocationPresetUnavailable' end end
 return S.effective({cats={},items={},presets=row.presets,priority=0,allocation=row.profile},definitions).allocation
end
function R.forTarget(player,target)
 local lib,e=R.library();if not lib then return nil,e end
 local any=false;for _,row in pairs(lib.profiles) do if row.active then any=true;break end end
 if not any then return {},nil,lib.revision end
 local api,status=service();if not api then if status=='RoomServiceAbsent' then return {},nil,lib.revision end;return nil,status end
 local result=api.storageScopes(player,target);if result.status~='ok' then return nil,result.status end
 local out={}
 for _,room in ipairs(result.rooms) do
  local ids={room.id};for _,alias in ipairs(room.aliases or {}) do ids[#ids+1]=alias end
  for _,id in ipairs(ids) do local row=lib.profiles[id]
   if row and row.active then out[#out+1]={key=id,record=row,room=room} end
  end
 end
 if #out>16 then return nil,'AllocationScopeLimit' end
 return out,nil,lib.revision
end
local function snapshot(row)
 if not row then return nil end
 local out={};for k,v in pairs(row) do out[k]=v end;out.profile=Profile.copy(row.profile);out.presets={}
 for k,v in pairs(row.presets) do out.presets[k]=v end
 return out
end
local function changed(revision)
 if isServer() and sendServerCommand and B47ANCEDQuartermaster.Bindings then
  for player in pairs(B47ANCEDQuartermaster.Bindings.sessions) do sendServerCommand(player,'B47ANCEDQuartermaster','allocationChanged',{revision=revision}) end
 end
 if B47ANCEDQuartermaster.onConfigurationChanged then B47ANCEDQuartermaster.onConfigurationChanged() end
end
function R.handle(player,command,args)
 if isClient() or not player or type(args)~='table' then return {status='invalid'} end
 local api,e=service();if not api then return {status=e} end
 if command=='allocationRoomList' then
  local result=api.listRooms(player);if result.status~='ok' then return result end
  local lib,e=R.library();if not lib then return {status=e} end
  local out={};local pending=false;for _,rows in ipairs({result.rooms,result.nativeRooms}) do for _,room in ipairs(rows or {}) do
   local permission=api.canAccess(player,room.id,'configureRoom')
   if permission.reason=='waiting' or permission.reason=='busy' then pending=true end
   if permission.state=='allow' then
    local entry={};for key,value in pairs(room) do entry[key]=value end;entry.profileKeys={}
    local ids={room.id};for _,alias in ipairs(room.aliases or {}) do ids[#ids+1]=alias end
    for _,id in ipairs(ids) do if lib.profiles[id] then entry.profileKeys[#entry.profileKeys+1]=id end end
    out[#out+1]=entry
   end
  end end
  return {status='ok',rooms=out,types=api.roomTypes(),preparing=pending}
 end
 local room,reason=R.definition(player,args.room,args.roomRevision);if not room then return {status=reason} end
 local lib,data=R.library();if not lib then return {status=data} end
 local profileKey=room.id;local allowedKeys={[room.id]=true}
 for _,id in ipairs(room.aliases or {}) do allowedKeys[id]=true end
 if args.profileKey~=nil then
  if not allowedKeys[args.profileKey] then return {status='invalid'} end
  profileKey=args.profileKey
 elseif not lib.profiles[profileKey] then
  local aliases={};for id in pairs(allowedKeys) do if lib.profiles[id] then aliases[#aliases+1]=id end end;table.sort(aliases)
  if #aliases>0 then profileKey=aliases[1] end
 end
 local old=lib.profiles[profileKey]
 if command=='allocationRoomGet' then
  local Migration=require 'B47ANCEDQuartermaster/Migration'
  local primary=Migration.option('PrimaryOverflowAt');local secondary=Migration.option('SecondaryReturnAt')
  return {status='ok',room=room,record=snapshot(old) or {revision=0,roomRevision=room.revision,active=false,profile=Profile.empty(),presets={},priority=0,
   primaryAt=Profile.percent(primary) and primary or 60,secondaryAt=Profile.percent(secondary) and secondary or 80},libraryRevision=lib.revision,profileKey=profileKey}
 end
 if command~='allocationRoomCommit' then return {status='invalid'} end
 if type(args.nonce)~='string' or #args.nonce<1 or #args.nonce>96 or args.nonce:find('%c') then return {status='invalid'} end
 local replay=replays[player]
 if replay and getTimestampMs()-replay.time<300000 and replay.nonce==args.nonce then
  if replay.room~=room.id or replay.profileKey~=profileKey or not Profile.equal(replay.profile,args.profile) or replay.active~=args.active
   or replay.primaryAt~=args.primaryAt or replay.secondaryAt~=args.secondaryAt or replay.priority~=args.priority
   or not B47ANCEDQuartermaster.Configuration.equal(replay.presets,args.presets) then return {status='invalid'} end
  return replay.result
 end
 if args.revision~=(old and old.revision or 0) or args.libraryRevision~=lib.revision then return {status='conflict'} end
 if type(args.profile)~='table' or not Profile.valid(args.profile) or type(args.active)~='boolean' or not Profile.percent(args.primaryAt) or not Profile.percent(args.secondaryAt)
  or type(args.priority)~='number' or args.priority~=math.floor(args.priority) or math.abs(args.priority)>999999
  or not S.valid({cats={},items={},presets=args.presets,priority=0}) then return {status='invalid'} end
 local definitions=B47ANCEDQuartermaster.Presets.snapshot()
 if not definitions then return {status='schema'} end
 local row={revision=(old and old.revision or 0)+1,roomRevision=room.revision,profile=Profile.copy(args.profile),active=args.active,primaryAt=args.primaryAt,secondaryAt=args.secondaryAt,
  priority=args.priority,presets={},owner=old and old.owner or account(player)}
 for key,link in pairs(args.presets) do row.presets[key]=link end
 if not R.effective(row,definitions.definitions) then return {status='AllocationPresetUnavailable'} end
 -- Pure metadata replacement: no container scan, access grant or item movement.
 local profiles={};for id,record in pairs(lib.profiles) do profiles[id]=record end;profiles[profileKey]=row
 local replacement={schema=1,revision=lib.revision+1,profiles=profiles}
 local previous=data.roomAllocations;data.roomAllocations=replacement
 local validated=R.library();if not validated then data.roomAllocations=previous;return {status='invalid'} end
 local result={status='ok',room=room,record=snapshot(row),libraryRevision=replacement.revision,profileKey=profileKey}
 replays[player]={nonce=args.nonce,room=room.id,profileKey=profileKey,profile=Profile.copy(args.profile),presets=B47ANCEDQuartermaster.Configuration.clone(args.presets),active=args.active,
  primaryAt=args.primaryAt,secondaryAt=args.secondaryAt,priority=args.priority,time=getTimestampMs(),result=result}
 changed(replacement.revision);return result
end
function R.preview(player,args)
 if isClient() or not player or type(args.profile)~='table' or not Profile.valid(args.profile) then return {status='invalid'} end
 local old,mode,scope
 if args.room then
  local result=R.handle(player,'allocationRoomGet',args);if result.status~='ok' then return result end
  if args.revision~=result.record.revision or args.libraryRevision~=result.libraryRevision then return {status='conflict'} end
  old=result.record.profile;scope=result.room.name;mode='room'
 else
  local record=B47ANCEDQuartermaster.Bindings.target(player,args.session,args.token)
  if not record or not Access.can(player,record.target,'configure') then return {status='RoomAccessDenied'} end
  local config=B47ANCEDQuartermaster.Store.configuration(record.target,player);if not config then return {status='invalid'} end
  old=config.allocation;mode=record.target.whole and 'whole' or 'container';scope=mode
 end
 local categories,items=0,0;local before=old or Profile.empty();local catKeys,itemKeys={},{}
 for key in pairs(before.cats) do catKeys[key]=true end;for key in pairs(args.profile.cats) do catKeys[key]=true end
 for key in pairs(before.items) do itemKeys[key]=true end;for key in pairs(args.profile.items) do itemKeys[key]=true end
 for key in pairs(catKeys) do if before.cats[key]~=args.profile.cats[key] then categories=categories+1 end end
 for key in pairs(itemKeys) do if before.items[key]~=args.profile.items[key] then items=items+1 end end
 return {status='ok',preview={scope=scope,mode=mode,configured=old~=nil,categories=categories,items=items,defaultChanged=before.default~=args.profile.default,oldDefault=before.default,newDefault=args.profile.default,
  prioritiesUnchanged=true,legacySelectionsUnchanged=true,childInheritanceUnchanged=true,movesItems=false}}
end
return R
