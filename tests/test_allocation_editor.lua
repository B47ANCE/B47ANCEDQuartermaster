-- Native-shaped UI fixtures only; this is not rendered/native acceptance.
dofile(TEST_ROOT..'/test_shopping_ui.lua')
local Q=B47ANCEDQuartermaster;local f=CONTAINER_FIXTURE
local parent=Q.openPicker(f.a,0,0)
local category=Q.Categorizer.nativeID('Food');local P=Q.AllocationProfile
parent.allocationInfo={categories={[category]=true},mode=2,roomProfiles=true}
local requests=0;local commits=0;local selectedFull
local old=Q.Authority.request
Q.Authority.request=function(_,command,args,done)
 requests=requests+1
 if command=='allocationRoomGet' then done({status='ok',room={id='room-test',name='Kitchen',revision=4,roomType='kitchen'},profileKey='room-test',libraryRevision=7,
  record={profile=P.empty(),presets={},priority=11,primaryAt=60,secondaryAt=80,active=true,revision=2}})
 elseif command=='allocationRoomCommit' then
  commits=commits+1;assert(args.roomRevision==4 and args.revision==2 and args.libraryRevision==7 and args.priority==11 and args.primaryAt==60 and args.secondaryAt==80)
  assert(args.active==false and args.profile.items[selectedFull]==35 and args.nonce);done({status='ok'})
 elseif command=='presetsList' then done({status='ok',library={revision=0,definitions={}}})
 else error('unexpected editor request '..command) end
end
require('B47ANCEDQuartermaster/RoomAllocationUI').open(parent,{id='room-test',name='Kitchen',revision=4})
local p=parent.childPicker;assert(p and p.allocationOnly and parent.dimmer:isVisible())
for full in pairs(Q.AllocationUI.index(p).items) do if not selectedFull or full<selectedFull then selectedFull=full end end
local row={kind='item',allocationFullType=selectedFull,group={key=category}}
-- Synthetic catalog in this fixture has no explicit Food category: exact item
-- allocation still uses its canonical Generic path, independent of this label.
assert(Q.AllocationUI.set(p,row,35))
assert(commits==0 and requests==1,'drag/local preview submitted a room write')
p.chkChecked.onclick(p);p:onSave()
assert(commits==1 and p.removed and not parent.dimmer:isVisible() and parent.childPicker==nil)
Q.Authority.request=old
parent:closePicker()
print('PASS OFFLINE shared room allocation editor: existing picker/modal lifecycle, local staging, exact item, active toggle, revision-bound single Save and parent focus/dimmer cleanup')
