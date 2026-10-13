-- Actual owned window paths with engine/UI fixtures; no native rendering proof.
dofile(TEST_ROOT..'/test_shopping_ui.lua')
local Q,U=B47ANCEDQuartermaster,B47ANCEDUI
local G=Q.WindowLayout
local p=Q.openPicker(CONTAINER_FIXTURE.a,0,0)
local writes={};getFileWriter=function(name) return {write=function(_,text) writes[name]=text end,close=function() end} end
local left,top,width,height=0,0,1280,900
getPlayerScreenLeft=function() return left end;getPlayerScreenTop=function() return top end
getPlayerScreenWidth=function() return width end;getPlayerScreenHeight=function() return height end
local requests=0;local request=Q.Authority.request;Q.Authority.request=function(...) requests=requests+1;return request(...) end
local selected=p.selectedItems;selected.keep=true;local rail=p.containerUI.rail;local rows=rail.items
G.bounds(p,10000,10000,-200,-200);p:layout()
assert(p.width==width and p.height==height and p.x==left and p.y==top)
local before=G.railWidth(p);G.change(p,'railMore');assert(G.railWidth(p)>before)
G.change(p,'railLess');assert(math.abs(G.railWidth(p)-before)<1)
assert(p.selectedItems==selected and selected.keep and rail.items==rows,'layout rebuilt application state')
for _,action in ipairs({'railMore','railMore','railMore','smaller','smaller','railLess','reset'}) do
 G.change(p,action)
 assert(p.listbox.x+p.listbox.width<=p.width-8 and p.listbox.y+p.listbox.height<p.btnSave.y,'layout clips main content')
 assert(p.containerUI.rail.width>0 and p.containerUI.rail.height>0)
end
G.save(p);local saved=writes['B47ANCEDQuartermasterWindow0.txt'];assert(saved)
getFileReader=function(name) local i=0;local values={};for value in saved:gmatch('[^\n]+') do values[#values+1]=value end;return {readLine=function() i=i+1;return values[i] end,close=function() end} end
local other={playerNum=0,width=1120,height=780,x=0,y=0}
for _,method in ipairs({'setX','setY','setWidth','setHeight'}) do local field=method:sub(4):lower();other[method]=function(self,n) self[field]=n end end
other.getWidth=function(self) return self.width end;other.getHeight=function(self) return self.height end
G.restore(other);assert(other.width==p.width and other.height==p.height and math.abs(other.b47Divider-p.b47Divider)<0.00001)
left,top,width,height=640,40,640,600
G.restore(other);assert(other.x>=640 and other.y>=40 and other.x+other.width<=1280 and other.y+other.height<=640)
saved='NaN\ninf\n-5\n100000\n-100\n';G.restore(other)
assert(other.width>0 and other.height<=600 and G.railWidth(other)>0,'corrupt preference recovery')
-- Divider uses parent-space pointer, even after it changes its own x position.
local d=p.b47DividerWidget;local cursor=0;d.getMouseX=function(self) return cursor-self.x end
local captures={};d.setCapture=function(_,v) captures[#captures+1]=v end
left,top,width,height=0,0,1280,900;G.change(p,'reset');before=G.railWidth(p)
cursor=d.x+3;d:onMouseDown();cursor=cursor+48;d:onMouseMove();local after=G.railWidth(p);assert(after>before)
d:onMouseMove();assert(G.railWidth(p)==after,'moving divider loses coordinate origin')
d:onMouseUpOutside();assert(captures[1] and captures[#captures]==false and not d.dragging)
-- Layout action is present in controller focus and dispatches the same operations.
p:configJoypad();local found=false;for _,b in ipairs(p.allJoypadButtons) do if b==p.b47LayoutButton then found=true end end;assert(found)
local menu;local old=ISContextMenu.get
ISContextMenu.get=function() menu={options={},addOption=function(self,title,target,fn) self.options[#self.options+1]={title=title,target=target,fn=fn} end};return menu end
G.menu(p);assert(#menu.options==6 and menu.origin==p);menu.options[5].fn(p);ISContextMenu.get=old
assert(selected.keep and p.selectedItems==selected)
assert(requests==0,'geometry emitted gameplay/discovery RPC');Q.Authority.request=request
-- Restoring constructor geometry must not instantiate Java/UI children through getters.
local getter=other.getWidth;other.getWidth=function() error('premature native instantiation') end;G.restore(other);other.getWidth=getter
print('PASS OFFLINE dev28 layout: viewport/minimum bounds, divider capture, stable pointer, controller actions, persistence, corruption and unchanged state')
