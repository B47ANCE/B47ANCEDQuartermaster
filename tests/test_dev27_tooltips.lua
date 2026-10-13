-- Offline lifecycle/geometry contracts; no native pixel evidence.
B47ANCEDUI={Renderer={fit=function(text,width) return #text*7<=width and text or text:sub(1,math.max(0,math.floor(width/7)-3))..'...' end}}
package.loaded['B47ANCEDUI/Renderer']=true
getPlayerScreenLeft=function(p) return p==1 and 640 or 0 end;getPlayerScreenTop=function() return 0 end
getPlayerScreenWidth=function() return 640 end;getPlayerScreenHeight=function() return 480 end
getTextManager=function() return {getFontHeight=function() return 15 end,MeasureStringX=function(_,_,text) return #text*7 end} end;ISToolTip={GetFont=function() return 1 end}
local H=require 'B47ANCEDUI/Tooltip'
local tip={x=1230,y=470,visible=true,registered=true,backgroundColor={a=1},description=''}
function tip:setVisible(v) self.visible=v end;function tip:getIsVisible() return self.visible end
function tip:removeFromUIManager() self.registered=false end
function tip:getX() return self.x end;function tip:getY() return self.y end
function tip:getWidth() return self.width end;function tip:getHeight() return self.height end
function tip:setX(v) self.x=v end;function tip:setY(v) self.y=v end
function tip:setDesiredPosition(x,y) self.x,self.y=x,y end
function tip:doLayout() local n=1;for _ in self.description:gmatch('<LINE>') do n=n+1 end;self.width=380;self.height=n*19+20 end
function tip:adjustPositionToAvoidOverlap() self.x=0;self.y=490 end
H.prepare(tip,string.rep('<COLOR:1,0,0>long name\n',20),1)
assert(tip.x>=640 and tip.x+tip.width<=1280 and tip.y+tip.height<=480)
assert(not tip.description:find('<COLOR',1,true) and not tip.followMouse and tip.backgroundColor.a==0)
tip:adjustPositionToAvoidOverlap({});assert(tip.x>=640 and tip.y+tip.height<=480,'native avoidance escaped player bounds')
tip:setX(0);tip:setY(900);assert(tip.x>=640 and tip.y+tip.height<=480,'late native/context position escaped viewport')
local child={tooltipUI=tip,setVisible=function(self,v) self.visible=v end,isReallyVisible=function() return true end}
H.attach(child,1);tip.visible=false;child:setVisible(false);assert(not tip.registered,'invisible registered tooltip was not removed')
tip.registered=true;local parent={children={child},removeFromUIManager=function(self) self.removed=true end,isReallyVisible=function() return true end}
H.attach(parent,1);parent:removeFromUIManager();assert(parent.removed and not tip.registered,'parent removal orphaned child tooltip')
assert(H.plain('a<IMAGE:bad>\tname')=='aIMAGE:bad name')
print('PASS OFFLINE dev27 tooltips: invisible-registration cleanup, recursive disposal, bounded text and owner viewport after native avoidance')
