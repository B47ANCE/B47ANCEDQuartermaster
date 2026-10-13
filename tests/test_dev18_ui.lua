-- Focused UI callback regression, offline only.

dofile(TEST_ROOT..'/test_shopping_ui.lua')
local Q=B47ANCEDQuartermaster
local originalRequest=Q.Authority.request
local p=Q.openPicker(CONTAINER_FIXTURE.a,0,0);local u=p.shoppingUI
Q.ShoppingUI.switch(p,'shopping');u.neededTab.onclick(p)
u.lists.needed={['Base.Nails']=3};u.lists.neededGoals={['Base.Nails']={current=1,remaining=2,target=3}}
u.selected='Base.Nails';u.rebuild()
local dialog,sent
local originalNew=ISTextBox.new
ISTextBox.new=function(_,x,y,w,h,text,default,target,callback)
    dialog=ISPanel:new(x,y,w,h);dialog.entry=ISTextEntryBox:new(default,0,0,80,24);dialog.entry:setText(default)
    dialog.callback=callback;return dialog
end
Q.Authority.request=function(_,command,args) if command=='personalChange' then sent=args end end
u.editGoal.onclick(p);assert(dialog.entry:getInternalText()=='3')
dialog.callback(nil,{internal='CANCEL',parent=dialog});assert(not sent)
dialog.entry:setText('5');dialog.callback(nil,{internal='OK',parent=dialog})
assert(sent and sent.kind=='needed' and sent.quantity==5 and sent.revision==u.lists.revision)
sent=nil;dialog.entry:setText('1.5');dialog.callback(nil,{internal='OK',parent=dialog});assert(not sent)
ISTextBox.new=originalNew;Q.Authority.request=originalRequest
local originalFonts=getTextManager
getTextManager=function() return {getFontHeight=function() return 42 end,MeasureStringX=function(_,_,s) return #s*21 end} end
local minimum=Q.Picker:new(CONTAINER_FIXTURE.a,0,0,{api=p.api}).minimumHeight
assert(p.minimumHeight>=460)
local scaled=Q.openPicker(CONTAINER_FIXTURE.a,0,0)
assert(scaled.minimumHeight==minimum,'attached adapter discarded font-aware minimum')
scaled:setHeight(scaled.minimumHeight);scaled:layout()
assert(scaled.listbox.y+scaled.listbox.height<=scaled.btnSave.y-7,'font-aware minimum overlaps footer')
scaled:closePicker()
getTextManager=originalFonts
print('PASS OFFLINE dev.18 target editor prefill/cancel/3-to-5/numeric validation and final font-aware minimum geometry')
