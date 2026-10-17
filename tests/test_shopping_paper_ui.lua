dofile(TEST_ROOT..'/test_ui_framework.lua')
local Q=B47ANCEDQuartermaster;local p=Q.openPicker(CONTAINER_FIXTURE.a,0,0);local u=p.shoppingUI
Q.ShoppingUI.switch(p,'shopping')
local response={status='ok',revision=4,shopping={},wish={},needed={},manual={},projects={},requirements={},gross=0,carried=0,outstanding=0,
 wishGoals={},neededGoals={},paper={enabled=true,selected=123,writable=true,legacy=true,lists={{item=123,name='Hardware'},{item=124,name='Food'}}}}
u.lists=response;u.rebuild();p:layout()
assert(u.paperPicker:isVisible() and u.paperNew:isVisible() and u.paperImport:isVisible() and u.paperRename.enable)
local meta=response.paper;meta.writable=false;u.rebuild();assert(not u.paperRename.enable and not u.pickerShopping.enable,'read-only paper exposed edits')
meta.selected=nil;u.rebuild();assert(not u.collect.enable)
meta.selected=124;meta.writable=true;response.revision=0;u.rebuild();assert(u.paperPicker.selected==2,'lower-revision second list could not be selected')
assert(u.pickerShopping.enable and u.preferences.enable,'returned writing supplies did not restore controls')
local font=getTextManager
for _,fh in ipairs({14,24,32,42}) do
 getTextManager=function() return {getFontHeight=function() return fh end,MeasureStringX=function(_,_,s) return #s*fh/2 end} end
 p:setWidth(1100);p:setHeight(850);p:layout()
 assert(u.paperPicker.y+u.paperPicker.height<=u.search.y,'paper picker overlaps search')
 assert(u.shopping.y+u.shopping.height<=u.collect.y,'shopping list overlaps actions')
 assert(u.paperImport.x+u.paperImport.width<=p:getWidth(),'paper controls outside window')
end
getTextManager=font
Q.ShoppingUI.switch(p,'sorting');assert(not u.paperPicker:isVisible() and not u.paperNew:isVisible())
print('PASS OFFLINE physical shopping UI: carried-list picker, writable/read-only controls, list revision independence, font 14/24/32/42 geometry and sorting restoration; native input/pixels NOT TESTED')
