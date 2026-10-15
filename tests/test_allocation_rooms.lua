-- Reuse the real paired production permission scenario, not a fake Rooms API.
dofile(TEST_ROOT..'/test_rooms_integration.lua')
local f=CONTAINER_FIXTURE;local Q=B47ANCEDQuartermaster;local API=B47ANCEDRooms.API
local Alloc=Q.RoomAllocation;local P=Q.AllocationProfile
local id=API.listRooms(f.player).rooms[1].id
local resolved=API.resolveRoom(f.player,id);assert(resolved.status=='ok')
local room=resolved.room
local reads=0;local oldItems=f.a.containers[1].getItems
f.a.containers[1].getItems=function() reads=reads+1;error('configuration read private contents') end
local get=Alloc.handle(f.player,'allocationRoomGet',{room=id,roomRevision=room.revision})
assert(get.status=='ok' and get.record.primaryAt==60 and get.record.secondaryAt==80 and not get.record.active)
local allowed=SafeHouse.isSafehouseAllowInteract;SafeHouse.isSafehouseAllowInteract=function() return false end
assert(Alloc.handle(f.player,'allocationRoomGet',{room=id,roomRevision=room.revision}).status=='RoomAccessDenied','room metadata ownership bypassed native safehouse configuration restrictions')
SafeHouse.isSafehouseAllowInteract=allowed
local category=Q.Categorizer.nativeID('Food');local profile=P.empty();profile.cats[category]=40
local args={room=id,roomRevision=room.revision,revision=0,libraryRevision=get.libraryRevision,profile=profile,presets={},active=true,priority=17,primaryAt=60,secondaryAt=80,nonce='room-profile:1'}
args.profile=nil;assert(Alloc.handle(f.player,'allocationRoomCommit',args).status=='invalid','missing required room profile was silently accepted');args.profile=profile
local result=Alloc.handle(f.player,'allocationRoomCommit',args)
assert(result.status=='ok' and result.record.owner=='fixture-player' and result.record.revision==1 and reads==0)
assert(Alloc.handle(f.player,'allocationRoomCommit',args).status=='ok','exact replay repeated mutation')
args.primaryAt=61;assert(Alloc.handle(f.player,'allocationRoomCommit',args).status=='invalid','nonce changed thresholds')
args.primaryAt=60;args.nonce='room-profile:2';assert(Alloc.handle(f.player,'allocationRoomCommit',args).status=='conflict')
local preview=Alloc.preview(f.player,{room=id,roomRevision=room.revision,revision=1,libraryRevision=result.libraryRevision,profile=P.empty()})
assert(preview.status=='ok' and preview.preview.categories==1 and preview.preview.prioritiesUnchanged and not preview.preview.movesItems and reads==0)
assert(Alloc.handle(f.player,'allocationRoomGet',{room=id,roomRevision=room.revision-1}).status=='conflict')
f.a.containers[1].getItems=oldItems
-- Room configuration grants no gameplay deposit access.
local forbidden=Alloc.forTarget(f.player,{obj=f.a,container=f.a.containers[1],ci=0})
assert(not forbidden,'room profile created a gameplay access grant')
local data=ModData.getOrCreate('B47ANCEDQuartermaster')
local saved=data.roomAllocations;package.loaded['B47ANCEDQuartermaster/RoomAllocation']=nil
local reloaded=require 'B47ANCEDQuartermaster/RoomAllocation'
assert(reloaded.library().profiles[id].profile.cats[category]==40 and data.roomAllocations==saved,'reload rewrote/misread profile')
local Defaults=require 'B47ANCEDQuartermaster/RoomTypePresets'
local builtin=assert(Defaults.build('kitchen',{{category=category}}))
assert(builtin.cats[category]==100 and builtin.default==0 and builtin.cats.Invented==nil)
assert(not Defaults.build('kitchen',{{category=Q.Categorizer.nativeID('Unrelated')}}))
assert(Defaults.build('storage',{}).default==100)
-- Consumer membership remains authoritative outside editor range.
local lease=API.beginEdit(f.player)
local changed=API.change(f.player,{action='save',name='Storage',rows={{0,0,1,2}},revision=lease.revision,editKey=lease.editKey,nonce='new-storage'})
for _=1,100 do if changed.status~='pending' then break end;B47ANCEDRooms.Registry.tick();f.advance(16);changed=B47ANCEDRooms.Registry.handle(f.player,'roomPoll',{nonce='new-storage'}) end
assert(changed.status=='ok')
local target={obj=f.b,container=f.b.containers[1],ci=0}
local scopes=API.storageScopes(f.player,target);assert(scopes.status=='ok' and #scopes.rooms==1)
local storage=scopes.rooms[1];local oldX=f.player.getX
f.player.getX=function() return 1000 end
f.player.getCurrentSquare=function() return {getX=function() return 1000 end,getY=function() return 1000 end} end
assert(API.resolveRoom(f.player,storage.id).status=='RoomOutOfRange')
assert(API.storageScopes(f.player,target).rooms[1].id==storage.id,'editor range silently bypassed room membership')
local tiles=API.storageTiles(f.player,storage.id,storage.revision,target)
assert(tiles.status=='ok' and #tiles.tiles==2)
assert(API.storageTiles(f.player,storage.id,storage.revision+1,target).status=='conflict')
print('PASS OFFLINE actual Rooms profiles: configure-only zero inventory reads, CAS, exact replay, nonce substitution, persisted reload, actual-category defaults, no gameplay grants and far-target authoritative membership')
