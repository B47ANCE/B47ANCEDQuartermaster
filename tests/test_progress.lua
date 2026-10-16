-- Actual vanilla widget; only native drawing, projection and actor services are simulated.
local Element={};Element.__index=Element
function Element:derive() local c={};c.__index=c;return setmetatable(c,{__index=self}) end
function Element:new(x,y,w,h) return setmetatable({x=x,y=y,width=w,height=h,draws={}},self) end
function Element:initialise() end
for _,name in ipairs({'WantMouseEvents','WantKeyEvents','Capture','FollowGameWorld','RenderThisPlayerOnly','X','Y','Width','Height'}) do
 Element['set'..name]=function(self,value) self[name]=value;if name=='Width' then self.width=value elseif name=='Height' then self.height=value elseif name=='X' then self.x=value elseif name=='Y' then self.y=value end end
end
function Element:addToUIManager() self.added=true end
function Element:removeFromUIManager() self.removed=(self.removed or 0)+1 end
function Element:setStencilRect() self.stencil=true end
function Element:clearStencilRect() self.stencil=false end
function Element:drawRectStatic(...) self.draws[#self.draws+1]={...} end
function Element:drawRectBorderStatic() end
function Element:drawText() end
ISUIElement=Element;package.loaded['ISUI/ISUIElement']=true
UIFont={Small='small'};PZMath={clamp_01=function(n) return math.max(0,math.min(1,n)) end};getTexture=function() return {} end
local fontHeight=14;local zoom=1
getCore=function() return {getZoom=function() return zoom end} end
getTextManager=function() return {MeasureStringX=function(_,_,s) return #s*7 end,getFontFromEnum=function() return {getLineHeight=function() return fontHeight end} end} end
getText=function(key,a,b) if key=='UI_B47_ProgressCount' then return a..': '..b..'%' elseif key=='UI_B47_ProgressPreparing' then return a..': preparing...' else return key end end
local screens={[0]={left=0,width=1280},[1]={left=1280,width=640}}
getPlayerScreenLeft=function(n) return screens[n].left end;getPlayerScreenTop=function() return 0 end
getPlayerScreenWidth=function(n) return screens[n].width end;getPlayerScreenHeight=function() return 720 end
isoToScreenX=function(n,x) return screens[n].left+400+x*16 end;isoToScreenY=function(_,_,y) return 360+y*8 end
local function actor() return {x=0,y=0,dead=false,getX=function(s) return s.x end,getY=function(s) return s.y end,getZ=function() return 0 end,isDead=function(s) return s.dead end} end
local actors={[0]=actor(),[1]=actor()};getSpecificPlayer=function(n) return actors[n] end
UIManager={getProgressBar=function() error('native current-action bar must remain untouched') end}
Events={};for _,key in ipairs({'OnTick','OnDisconnect','OnMainMenuEnter'}) do Events[key]={Add=function(fn) Events[key].handler=fn end} end
dofile(GAME_ROOT..'/media/lua/client/ISUI/ISProgressBar.lua');package.loaded['ISUI/ISProgressBar']=true
package.loaded['B47ANCEDQuartermaster/Progress']=nil
local P=require 'B47ANCEDQuartermaster/Progress'
local owned={};local first={};owned[0]=first
local state={known=true,total=10,completed=2,label='Sort'}
local function start(n,record) owned[n]=record;P.start(n,record,function() return state end,function(r) return owned[n]==r end);P.tick() end
start(0,first);local b=P.bars[0]
assert(b and b.added and b.progress==0.2 and b.WantMouseEvents==false and b.WantKeyEvents==false and b.Capture==false and b.FollowGameWorld and b.RenderThisPlayerOnly==0)
b:prerender();assert(#b.draws==2 and not b.stencil)
local x,y=b.x,b.y;actors[0].x=1;actors[0].y=1;b:prerender();assert(b.x>x and b.y>y)
y=b.y;zoom=2;b:prerender();assert(b.y>y)
fontHeight=24;b:prerender();assert(b.height==30 and b.textH==24)
local draws=#b.draws;screens[0].width=100;b:prerender();assert(#b.draws==draws);screens[0].width=1280
state={known=false,label='Sort'};P.tick();assert(b.progress==0 and b.text=='Sort: preparing...')
for _,bad in ipairs({{known=true,total=-1,completed=0},{known=true,total=10,completed=11},{known=true,total=10,completed=0/0},{known=true,total=math.huge,completed=1}}) do state=bad;P.tick();assert(b.progress==0) end
state={known=true,total=10,completed=5,label='Sort'};P.tick();assert(b.progress==0.5)
local second={};start(1,second);assert(P.bars[1].RenderThisPlayerOnly==1)
P.bars[1]:prerender();assert(P.bars[1].x+P.bars[1].width<=640)
local old=b;local replacement={};start(0,replacement);local current=P.bars[0]
P.clear(0,first);old:prerender();assert(old.removed==1 and not current.removed and P.bars[0]==current)
actors[0].dead=true;P.tick();assert(current.removed==1 and not P.active[0]);actors[0]=actor()
actors[1]=actor();P.tick();assert(not P.active[1] and not P.bars[1])
start(0,{});Events.OnDisconnect.handler();assert(not P.active[0] and not P.bars[0])
start(0,{});Events.OnMainMenuEnter.handler();assert(not P.active[0] and not P.bars[0])
print('PASS OFFLINE overhead HUD: native widget, progress/unknown/invalid counts, viewport/zoom/fonts, split screen, stale records, death/replacement/disconnect and no native bar access')
