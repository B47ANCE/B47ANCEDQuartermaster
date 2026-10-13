-- Reuse the owned Picker host surface, then add container session fixtures.
dofile(TEST_ROOT..'/test_integration.lua')
dofile(TEST_ROOT..'/test_containers.lua')
function ISButton:setEnable(v) self.enable=v end
function ISScrollingListBox:setOnMouseDownFunction(target,fn) self.target=target;self.onmousedown=fn end
function getTextOrNull(k) return k end
ContainerButtonIcons={}
package.loaded['Definitions/ContainerButtonIcons']=true
local Q=B47ANCEDQuartermaster
local f=CONTAINER_FIXTURE
dofile(TEST_ROOT..'/fixtures/catalog.lua')
Q.openPicker(f.a,0,0)
local p=Q.picker
assert(p.qmsSession and p.qmsSession.id and p.qmsSession.selected)
local function button(key)
    for _,child in ipairs(p.children) do if child.title=='UI_QMSS_'..key then return child end end
    error('Missing button '..key)
end
local focused
setJoypadFocus=function(_,value) focused=value end
p.containerUI.buttons.containers.onclick(p)
-- Real picker callback: Building -> Room submenu -> chosen room; Proximity too.
do
 local originalGet=ISContextMenu.get;local menus={}
 ISContextMenu.get=function(...) local m=originalGet(...);menus[#menus+1]=m;return m end
 local session=p.qmsSession;local originalViewInfo,originalSetView=session.viewInfo,session.setView
 local intent
 session.viewInfo={buildingAvailable=true,maxRadius=3,rooms={{label='Kitchen',token='room-a'},{label='Bedroom',token='room-b'}}}
 session.setView=function(_,view,done) intent=view;done('ok') end
 p.containerUI.buttons.containers.onclick(p)
 local root=menus[1];assert(root and #menus==3)
 root.options[1].callback(p);assert(intent.kind=='building')
 local rooms=root.options[2].sub
 assert(rooms.parent==root and #rooms.options==2 and rooms.player==root.player)
 rooms.options[2].callback(p);assert(intent.kind=='room' and intent.room=='room-b')
 rooms.options[1].callback(p);assert(intent.room=='room-a')
 root.options[3].sub.options[2].callback(p);assert(intent.kind=='proximity' and intent.radius==2)
 session.viewInfo,session.setView=originalViewInfo,originalSetView;ISContextMenu.get=originalGet
end
setJoypadFocus(p.playerNum,p.containerUI.rail)
assert(focused and focused~=p and focused.itemheight==48,'controller must reach rail')
focused:onJoypadDown(Joypad.BButton)
assert(focused==p,'controller must return from rail')
local x,y,w,h=p.listbox.x,p.listbox.y,p.listbox.width,p.listbox.height
for i=1,3 do p:layout() end
assert(p.listbox.x==x and p.listbox.y==y and p.listbox.width==w and p.listbox.height==h,'layout drift')
assert(p.listbox.x>=64 and p.listbox.vscroll.x==p.listbox.width-17)
-- Native getters are independent of Lua fields; the old layout passed Lua-only mocks.
local oldWidth,oldHeight=p.getWidth,p.getHeight
for _,size in ipairs({{640,460},{900,720},{640,460}}) do
    local nativeW,nativeH=size[1],size[2]
    p.width,p.height=nativeW,nativeH
    p.getWidth=function() return nativeW end
    p.getHeight=function() return nativeH end
    local widthGetter,heightGetter=p.getWidth,p.getHeight
    for i=1,3 do p:layout() end
    assert(p.getWidth==widthGetter and p.getHeight==heightGetter,'dimension getters leaked')
    assert(p.listbox.y+p.listbox.height<=p.btnSave.y-6,'tree overlaps native footer')
    assert(p.btnSave.y+p.btnSave.height<=button('Copy').y,'footer rows overlap')
    assert(button('Cancel').y+button('Cancel').height<=nativeH-8,'footer outside window')
    assert(p.listbox.x+p.listbox.width<=nativeW-10,'tree outside window')
    assert(p.listbox.vscroll.height==p.listbox.height,'scrollbar exceeds tree')
end
p.getWidth,p.getHeight=oldWidth,oldHeight
p:layout()
local before=f.sent()
p.selectedCats={B47_Ammo=true};p:rebuild()
assert(p.qmsSession:dirty(p.qmsSession.selected))
assert(f.sent()==before,'UI edit wrote world state')
assert(p.qmss.count>=3)
p:close()
assert(p.qmsSession.closed and f.sent()==before,'X must cancel')
Q.openPicker(f.a,0,0);p=Q.picker
-- Copy from working state, paste into a separate target, and cancel both without writes.
p.priority=11;p:rebuild();button('Copy').onclick(p)
assert(Q.workingClipboard.priority==11 and Q.workingClipboard.WholeContainer==nil)
local rail
for _,child in ipairs(p.children) do if child.itemheight==48 then rail=child end end
local destination
for _,entry in ipairs(rail.items) do if entry.item.target.container==f.unrelated.container then destination=entry.item end end
assert(destination)
rail.onmousedown(p,destination)
assert(p.qmsSession.selected==destination and p.priority==0)
button('Paste').onclick(p)
assert(p.priority==11 and p.qmsSession:dirty(destination) and f.sent()==before)
button('Cancel').onclick(p)
assert(f.sent()==before and not f.unrelated.obj.md.LSBoxPriority)
Q.openPicker(f.a,0,0);p=Q.picker
p.priority=9;p:rebuild();p.btnSave.onclick(p)
assert(p.qmsSession.closed and Q.Configuration.read(f.origin).priority==9)
assert(f.sent()==before+1,'new Save must use one server adapter transmission')
print('PASS multi-container Picker integration: attach, layout, dirty edits, X cancel and Save binding')

Q.openPicker(f.a,0,0);p=Q.picker
p.selectedCats={};p.selectedItems={RoundA=true};p.selectedPresets={};p:rebuild()
p:editPreset('Field kit',true)
local editor=Q.presetEditor
assert(editor and editor.qmss and editor.targetKind=='preset' and not editor.btnModePreset.visible)
assert(p.dimmer.visible and editor.selectedItems.RoundA)
editor.selectedItems={RoundB=true};editor:rebuild();editor.btnSave.onclick(editor)
assert(editor.removed and not p.dimmer.visible)
local definition=p:getPresetStore()['Field kit']
assert(definition and definition.items.RoundB and not definition.items.RoundA)
p.selectedCats={};p.selectedItems={};p.selectedPresets={['Field kit']=Q.Schema.link(definition)};p:rebuild()
assert(p.qmss.count==1,'owned preset coverage absent from immediate selected count')
p:editPreset('Field kit',false);editor=Q.presetEditor
editor.selectedItems={RoundC=true};editor:closePicker()
assert(p:getPresetStore()['Field kit'].items.RoundB,'preset cancel persisted edits')
p:editPreset('Field kit',false);editor=Q.presetEditor
editor.selectedItems={RoundA=true,RoundB=true};editor:rebuild();editor.btnSave.onclick(editor)
assert(p.qmss.count==2,'preset edit did not refresh parent count')
p:closePicker()
assert(Q.Presets.snapshot().definitions['Field kit'].items.RoundA,'closing container editor rolled back shared preset')

-- Native opener controls and world-object menus operate without foreign callbacks.
local registered,lootRegistrations=nil,0
ISInventoryWindowControlHandler=ISPanel
ISInventoryWindowContainerControls={AddHandler=function(c) registered=c end}
ISLootWindowContainerControls={AddHandler=function() lootRegistrations=lootRegistrations+1 end}
package.loaded['ISUI/InventoryWindow/ISInventoryWindowControlHandler']=true
package.loaded['ISUI/InventoryWindow/ISInventoryWindowContainerControls']=true
local control=require 'B47ANCEDQuartermaster/ConfigureControls'
assert(registered==control)
assert(lootRegistrations==0,'menu opener registered in loot pane')
local opener=control:new();opener.playerNum=0
assert(opener:shouldBeVisible(),'empty/unbound inventory hid opener')
local originalMake=Q.Targets.make
Q.Targets.make=function(obj,...) assert(obj,'target-free opener probed a nil native object');return originalMake(obj,...) end
opener:perform()
Q.Targets.make=originalMake
assert(Q.picker.qmsSession and #Q.picker.qmsSession.targets>0 and not Q.picker.qmsSession.selected,'inventory opener failed target-free discovery')
assert(Q.picker.btnSave.enable==false,'unselected inventory opener enabled Save')
Q.picker:closePicker()
local testCalls=0;ISWorldObjectContextMenu={setTest=function() testCalls=testCalls+1;return true end}
local menu=ISContextMenu.get()
control.fill(0,menu,f.list({f.a,f.a}),true)
assert(testCalls==1 and #menu.options==0,'test context pass mutated menu')
control.fill(0,menu,f.list({f.a,f.a}),false)
assert(#menu.options==1 and menu.options[1].name==getText('UI_QMSS_OpenMenu'),'canonical entry or object deduplication failed')
control.fill(0,menu,f.list({f.a}),false);assert(#menu.options==1,'duplicate navigation')
local option=menu.options[1]
option.callback(option.target)
assert(Q.picker.qmsSession and Q.picker.qmsSession.selected)
Q.picker:closePicker()
assert(LootSorter==nil)
print('PASS standalone frontend: native opener, owned preset create/edit/cancel/counts and no foreign global')

-- New nested UI uses production authority; staged customization/reset and cancel never write.
dofile(TEST_ROOT..'/fixtures/containers.lua');f=CONTAINER_FIXTURE;Q.Bindings.sessions={}
local d=assert(Q.Bindings.discover(f.player,{scope={x=0,y=0,z=0}}));local token
for _,meta in ipairs(d.targets) do if Q.Bindings.sessions[f.player].records[meta.token].target.obj==f.a then token=meta.token end end
local initial=Q.Authority.handle(f.player,'load',{session=d.session,token=token,whole=true})
assert(Q.Authority.handle(f.player,'groupChange',{session=d.session,token=token,whole=true,revision=initial.revision,config=Q.Schema.empty(),taxonomyVersion=6}).status=='ok')
Q.openPicker(f.a,0,0);p=Q.picker
assert(p.qmsSession.selected.configMode=='inherit' and p.qmss.model.readOnly)
local parent,child
for _,entry in ipairs(p.containerUI.rail.items) do if entry.item.target.whole then parent=entry.item elseif entry.item.target.obj==f.a then child=entry.item end end
assert(parent and child,'parent or physical child omitted')
local sent=f.sent();local original=Q.Configuration.clone(p.qmsSession.selected.working)
p.qmss.model:clear();assert(Q.Configuration.equal(p.qmsSession.selected.working,original),'read-only inherited view changed rules')
p.containerUI.buttons.whole.onclick(p);assert(p.qmsSession.selected.pendingAction=='custom' and not p.qmss.model.readOnly)
p.priority=17;p:rebuild();assert(p.qmsSession:dirty(p.qmsSession.selected))
p.containerUI.buttons.apply.onclick(p);assert(p.qmsSession.selected.pendingAction=='custom','reset lacked confirmation')
p.containerUI.buttons.apply.onclick(p);assert(not p.qmsSession.selected.pendingAction and p.qmss.model.readOnly)
assert(f.sent()==sent,'staged controls wrote authoritative state')
p.containerUI.rail.onmousedown(p,parent);assert(p.qmsSession.selected.target.whole)
p:closePicker();assert(f.sent()==sent,'cancel persisted nested edits')
print('PASS OFFLINE dev26 nested UI: inherited read-only, explicit customization, confirmed staged reset, parent/child navigation and cancel')
