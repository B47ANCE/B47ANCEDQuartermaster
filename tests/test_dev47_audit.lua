-- Actual owned UI/session/catalog paths under offline engine-shaped fixtures.
dofile(TEST_ROOT..'/test_shopping_ui.lua')
local Q=B47ANCEDQuartermaster;local f=CONTAINER_FIXTURE
do
 local original={token='one',target={room='room-a',x=0,y=0,z=0,ci=0,index=0},working=Q.Schema.empty()}
 original.working.items.keep=true
 local s=Q.Session.new(nil,0);s.targets={original};s.selected=original;s.viewInfo={}
 function s:request(command,args,done) assert(command=='viewSelect');done({status='ok',view=args.view}) end
 local status;s:setView({kind='room',room='room-b'},function(value) status=value end)
 assert(status=='ok' and not s.selected and original.working.items.keep,'hidden selection stayed active or staged edits were erased')
end
do
 local p=Q.openPicker(f.a,0,0);local s=p.qmsSession;assert(s.selected)
 local staged=s.selected
 if staged.configMode=='inherit' then p.containerUI.buttons.whole.onclick(p) end
 assert(not p.qmss.model.readOnly,'fixture requires an editable section')
 p.selectedItems.keep=true
 s.viewInfo={buildingAvailable=false,maxRadius=1,rooms={{label='Other room',token='absent'}}}
 local request=Q.Authority.request;Q.Authority.request=function(player,command,args,done)
  if command=='viewSelect' then done({status='ok',view=args.view}) else request(player,command,args,done) end
 end
 local get=ISContextMenu.get;local menu
 ISContextMenu.get=function(...) local value=get(...);menu=menu or value;return value end
 p.containerUI.buttons.containers.onclick(p)
 menu.options[2].sub.options[1].sub.options[1].callback(p)
 assert(not s.selected and not p.btnSave.enable and p.qmss.model.readOnly and #p.listbox.items==0,'hidden target remained editable in the actual picker')
 assert(staged.working.items.keep,'scope change discarded staged configuration')
 ISContextMenu.get=get;Q.Authority.request=request;p:closePicker()
end
do
 local base=Q.Catalog.build({},{{name='Vehicle Key',category='B47_Native_4B6579',fullType='Base.CarKey',owner='pz-vanilla'}})
 local api=Q.Catalog.forObserved(base,{{name='Test Sedan Key',category='B47_Native_4B6579',fullType='Base.CarKey',owner='pz-vanilla'}})
 assert(api==base,'renamed indexed item rebuilt the entire catalog')
 local overlay=Q.Catalog.build({{name='Test Sedan Key',category='B47_Native_4B6579',fullType='Base.CarKey',owner='pz-vanilla'}},base.entries)
 local p={selectedCats={},selectedItems={['Vehicle Key']=true},selectedPresets={}}
 local m=Q.Model.new(p,overlay,'Other');local group=m.byId['c:B47_Native_4B6579']
 assert(#group.children==1 and group.children[1]=='Vehicle Key' and m:covered(group,'Vehicle Key'),'renamed item gained a false unchecked alias')
 assert(m.selectedCount==1,'renamed alias inflated the item count')
end
do
 local new=ISPanelJoypad.new;ISPanelJoypad.new=function(self,...) local value=new(self,...);value.joypadButtonsY={};value.allJoypadButtons={};value.joypadButtons={};return value end
 local render=ISPanelJoypad.render;ISPanelJoypad.render=render or function() end
 local request=Q.Authority.request;Q.Authority.request=function(_,command,_,done) assert(command=='personalList');done({status='ok',wish={},needed={}}) end
 local p=Q.ItemPicker.open(0,'override',function() end,nil)
 p.renderJoypadFocus=function() end -- Native focus painting is outside this host fixture.
 assert(p.b47PickerShell,'item picker did not opt into a single header/footer painter')
 p:prerender();local draws={};p.drawText=function(_,text,x,y) draws[#draws+1]={text=text,x=x,y=y} end
 p:render()
 for _,draw in ipairs(draws) do
  assert(not tostring(draw.text):find('UI_QMSS_SelectedType',1,true),'selected type painted across footer buttons')
  assert(not (draw.x==12 and draw.y==10),'legacy picker heading duplicated shell heading')
 end
 p:close()
 ISPanelJoypad.new=new;ISPanelJoypad.render=render;Q.Authority.request=request
end
print('PASS OFFLINE dev47 room deselection preserves edits, renamed-item canonical rows/counts and single item-picker text painter')
