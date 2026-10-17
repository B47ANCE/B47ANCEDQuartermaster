-- Original code-native pixel artwork. No textures, external OS assets or state.
require 'B47ANCEDUI/Renderer'
local R=B47ANCEDUI.Renderer
local A={}
local function c(r,g,b) return {r=r,g=g,b=b,a=1} end
A.colors={ink=c(.12,.14,.14),shade=c(.39,.38,.32),shell=c(.73,.71,.61),
 face=c(.83,.81,.71),light=c(.94,.92,.83),edge=c(.59,.57,.48),
 recess=c(.24,.25,.22),glass=c(.035,.07,.065),rim=c(.075,.105,.095),
 teal=c(0,.34,.33),glint=c(.16,.30,.28),silver=c(.69,.77,.78),
 white=c(.94,.97,.93),blue=c(.12,.26,.48),green=c(.40,.75,.24),
 amber=c(.93,.65,.23),red=c(.68,.22,.14),paper=c(.98,.96,.83)}
local P=A.colors
-- Each rectangle uses a 32x32 authoring grid; layers are deliberately editable.
A.icons={
 disc={
  {11,1,10,2,'ink'},{7,3,18,2,'ink'},{5,5,22,3,'ink'},
  {3,8,26,9,'ink'},{5,17,22,3,'ink'},{7,20,18,2,'ink'},
  {11,22,10,2,'ink'},{11,2,10,2,'white'},{8,4,16,2,'white'},
  {6,6,20,3,'silver'},{4,9,24,7,'silver'},{6,16,20,3,'silver'},
  {8,19,16,2,'white'},{10,6,4,2,'white'},{7,9,5,2,'white'},
  {20,15,5,2,'white'},{13,8,6,10,'shade'},{12,10,8,6,'shade'},
  {14,10,4,6,'teal'},{13,11,6,4,'teal'},
  {2,20,29,11,'ink'},{3,20,27,2,'light'},{3,22,27,7,'shell'},
  {4,28,25,2,'shade'},{5,23,19,3,'recess'},{6,23,17,1,'ink'},
  {25,24,3,2,'light'},{26,27,2,1,'green'}},
 writer={
  {3,7,26,3,'ink'},{1,10,30,18,'ink'},{3,9,25,3,'light'},
  {2,12,28,14,'shell'},{3,24,26,3,'shade'},{4,15,22,6,'recess'},
  {5,16,20,2,'ink'},{6,20,18,2,'light'},{5,24,3,1,'red'},
  {22,23,5,2,'light'},{19,3,8,2,'ink'},{17,5,12,2,'ink'},
  {16,7,14,10,'ink'},{18,17,10,2,'ink'},{19,4,7,2,'white'},
  {18,7,11,8,'silver'},{20,15,7,2,'white'},{22,8,4,5,'shade'},
  {23,9,2,3,'teal'},{9,22,3,7,'ink'},{12,19,3,7,'ink'},
  {15,16,3,7,'ink'},{18,13,3,7,'ink'},{21,10,3,7,'ink'},
  {10,23,2,4,'amber'},{13,20,2,4,'amber'},{16,17,2,4,'amber'},
  {19,14,2,4,'amber'},{22,11,2,3,'red'},{9,28,2,2,'paper'}},
 application={
  {2,3,26,21,'ink'},{3,4,24,18,'shell'},{5,6,20,14,'blue'},
  {12,24,7,3,'shade'},{7,27,17,3,'ink'},{8,27,15,2,'light'},
  {16,10,14,21,'ink'},{17,11,12,18,'paper'},{17,11,12,3,'green'},
  {19,17,2,2,'blue'},{23,17,4,1,'shade'},{19,21,2,2,'blue'},
  {23,21,4,1,'shade'},{19,25,2,2,'blue'},{23,25,4,1,'shade'}}}
function A.icon(w,kind,x,y,scale)
 for _,v in ipairs(A.icons[kind] or A.icons.application) do
  R.rect(w,x+v[1]*scale,y+v[2]*scale,v[3]*scale,v[4]*scale,P[v[5]])
 end
end
local function cutbox(w,x,y,width,height,cut,color)
 R.rect(w,x+cut,y,width-2*cut,height,color)
 R.rect(w,x,y+cut,width,height-2*cut,color)
 for i=0,cut-1 do
  R.rect(w,x+cut-i,y+i,width-2*(cut-i),1,color)
  R.rect(w,x+cut-i,y+height-i-1,width-2*(cut-i),1,color)
 end
end
function A.geometry(width,height,font,button)
 local g={x=40,y=38,width=width-80,height=height-138}
 g.taskY=g.y+g.height-button-4
 g.statusY=g.taskY-font-9
 g.desktopHeight=g.statusY-g.y-8
 g.powerX=width-92;g.powerY=height-77
 return g
end
function A.monitor(w,g)
 local width,height=w:getWidth(),w:getHeight()
 -- A shallow pedestal and a molded, chamfered ABS shell around recessed glass.
 cutbox(w,width*.34,height-31,width*.32,20,5,P.shade)
 cutbox(w,width*.26,height-16,width*.48,14,4,P.shell)
 R.rect(w,width*.28,height-16,width*.44,2,P.light)
 cutbox(w,3,1,width-6,height-27,12,P.shade)
 cutbox(w,5,2,width-12,height-32,11,P.light)
 cutbox(w,8,5,width-18,height-38,9,P.shell)
 cutbox(w,14,10,width-30,height-48,8,P.face)
 R.rect(w,17,19,3,height-89,P.light)
 R.rect(w,width-25,24,5,height-91,P.edge)
 cutbox(w,g.x-17,g.y-16,g.width+34,g.height+32,10,P.edge)
 cutbox(w,g.x-13,g.y-12,g.width+26,g.height+24,9,P.recess)
 cutbox(w,g.x-8,g.y-7,g.width+16,g.height+14,7,P.rim)
 cutbox(w,g.x-4,g.y-3,g.width+8,g.height+6,4,P.glass)
 -- Reflections stay on the glass rim, away from application text and controls.
 R.rect(w,g.x+8,g.y-2,g.width-16,1,P.glint)
 R.rect(w,g.x-2,g.y+8,1,g.height-16,P.glint)
 local chin=g.y+g.height+20
 R.text(w,'B47',g.x,chin,P.recess)
 local badge=getTextManager():MeasureStringX(B47ANCEDUI.Theme.fonts.body,'B47')
 R.rect(w,g.x+badge+6,chin+2,1,11,P.edge)
 R.text(w,'CRT / 93',g.x+badge+14,chin,P.shade)
 for n=0,7 do R.rect(w,width/2-42+n*12,chin+1,7,2,P.edge) end
 R.rect(w,g.powerX-20,g.powerY+12,6,4,P.recess)
 R.rect(w,g.powerX-19,g.powerY+13,4,2,P.green)
end
function A.power(w)
 local width,height=w:getWidth(),w:getHeight()
 cutbox(w,0,0,width,height,4,P.edge)
 cutbox(w,1,1,width-3,height-3,3,w.pressed and P.shell or P.light)
 cutbox(w,3,3,width-7,height-7,2,P.face)
 local x=math.floor(width/2);local y=math.floor(height/2)
 R.rect(w,x-6,y-3,2,7,P.shade);R.rect(w,x+4,y-3,2,7,P.shade)
 R.rect(w,x-4,y+4,8,2,P.shade);R.rect(w,x-1,y-7,2,8,P.recess)
end
function A.glass(w,g)
 cutbox(w,g.x,g.y,g.width,g.height,6,P.teal)
end
function A.desktop(w)
 cutbox(w,0,0,w:getWidth(),w:getHeight(),6,P.teal)
end
return A
