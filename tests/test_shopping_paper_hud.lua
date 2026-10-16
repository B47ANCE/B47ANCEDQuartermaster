-- Native-shaped UI surface; geometry and async lifecycle, not pixel/native proof.
dofile(TEST_ROOT..'/test_load_settings_ui.lua')
local Q=B47ANCEDQuartermaster;local actor=CONTAINER_FIXTURE.player
SandboxVars.B47ANCEDQuartermaster.PhysicalShoppingLists=true
actor.isDead=function(self) return self.dead==true end
local primary,secondary
actor.getPrimaryHandItem=function() return primary end;actor.getSecondaryHandItem=function() return secondary end
getSpecificPlayer=function(num) if num==0 then return actor end end
getPlayerScreenLeft=function() return 0 end;getPlayerScreenTop=function() return 0 end
getPlayerScreenWidth=function() return 1280 end;getPlayerScreenHeight=function() return 720 end
for _,k in ipairs({'WantMouseEvents','WantKeyEvents','Capture','RenderThisPlayerOnly'}) do ISPanel['set'..k]=function(self,v) self[k]=v end end
local requests={}
Q.Authority.request=function(num,command,args,done) requests[#requests+1]={num=num,command=command,args=args,done=done} end
local H=require 'B47ANCEDQuartermaster/ShoppingPaperHUD'
local function paper(id) return {getID=function() return id end,getFullType=function() return 'B47ANCEDQuartermaster.ShoppingPaper' end} end
primary=paper(123);H.nextTick=0;H.tick();local e=assert(H.active[0]);assert(#requests==1 and requests[1].command=='shoppingPaperRead' and requests[1].args.item==123)
assert(e.panel.WantMouseEvents==false and e.panel.WantKeyEvents==false and e.panel.Capture==false and e.panel.RenderThisPlayerOnly==0)
local rows={};for n=1,25 do rows[n]={alternatives={'Base.Nails'},gross=20,carried=5,outstanding=15} end
requests[1].done({status='ok',paper={lists={{item=123,name='Hardware run'}}},requirements=rows,gross=500,carried=125,outstanding=375})
e.panel:prerender();assert(e.panel:getWidth()<=350 and e.panel.y>=0 and e.panel.y+e.panel:getHeight()<=720)
H.nextTick=0;H.tick();assert(#requests==1,'HUD polled per render/tick')
local old=e;primary=nil;secondary=paper(124);H.nextTick=0;H.tick();assert(H.active[0]~=old and #requests==2)
requests[1].done({status='ok',gross=999});assert(not H.active[0].snapshot,'late read painted a different paper')
requests[2].done({status='ShoppingPaperMissing'});assert(not H.active[0].snapshot)
H.active[0].panel:prerender()
primary=secondary;H.nextTick=0;H.tick();assert(#requests==2,'same item in both hands duplicated HUD')
secondary=nil;primary=nil;H.nextTick=0;H.tick();assert(not H.active[0])
primary=paper(125);H.nextTick=0;H.tick();assert(H.active[0]);actor.dead=true;H.nextTick=0;H.tick();assert(not H.active[0]);actor.dead=false
primary=paper(126);H.nextTick=0;H.tick();H.close();assert(not H.active[0])
print('PASS OFFLINE paper HUD: either hand, one panel, read cadence, long-list pagination geometry, stale callbacks, lost paper, death/disconnect cleanup; native visual acceptance NOT TESTED')
