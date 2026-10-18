-- Original editable Lua geometry; no textures, physical props or world mutation.
require 'B47ANCEDUI/Renderer'
local U=B47ANCEDUI;local R=U.Renderer;local A={}
local function c(r,g,b) return {r=r,g=g,b=b,a=1} end
local P={board=c(.35,.25,.15),edge=c(.20,.14,.09),grain=c(.43,.32,.20),paper=c(.94,.92,.82),
 sheet=c(.98,.97,.89),shade=c(.70,.68,.58),ink=c(.17,.20,.23),rule=c(.70,.77,.78),red=c(.74,.43,.40),
 metal=c(.57,.59,.57),metalLight=c(.84,.85,.79),metalDark=c(.28,.30,.29)}
A.colors={grey=P.paper,white=P.sheet,light=c(.96,.95,.86),shadow=P.rule,black=P.ink,
 muted=c(.37,.36,.30),blue=c(.24,.31,.36),selection=c(.84,.86,.77),selectedText=P.ink}
function A.draw(panel,view,m)
 local w,h=panel:getWidth(),panel:getHeight()
 R.rect(panel,0,0,w,h,P.edge);R.rect(panel,3,3,w-6,h-6,P.board)
 for n=0,2 do R.rect(panel,6+n*4,10,1,h-20,P.grain) end
 -- Stacked square-cut sheets, restrained ruling and a red notebook margin.
 R.rect(panel,22,56,w-40,h-70,P.shade);R.rect(panel,20,54,w-40,h-70,P.paper)
 R.rect(panel,18,52,w-40,h-70,P.sheet)
 -- Ruling belongs only to the scrolling table, not the header/details/buttons.
 R.rect(panel,view.left-10,60,1,h-86,P.red)
 -- Folded steel clip, top handle, screw heads and its cast shadow.
 local cw=math.max(110,m.font*5);local x=math.floor((w-cw)/2)
 R.rect(panel,x+3,17,cw,35,P.shade);R.rect(panel,x,12,cw,35,P.metalDark)
 R.rect(panel,x+2,14,cw-4,29,P.metal);R.rect(panel,x+3,15,cw-6,2,P.metalLight)
 R.rect(panel,x+8,38,cw-16,6,P.metalLight);R.rect(panel,x+12,39,cw-24,2,P.metalDark)
 R.border(panel,w/2-15,4,30,19,P.metalDark);R.border(panel,w/2-13,6,26,15,P.metalLight)
 for _,sx in ipairs({x+10,x+cw-14}) do R.rect(panel,sx,23,4,4,P.metalDark);R.rect(panel,sx+1,23,2,1,P.metalLight) end
 local title=getText('UI_QMSS_LedgerClipboardTitle')
 R.text(panel,R.fit(title,w-2*view.left),view.left,66,P.ink)
 -- The native resize widget stays active when its ordinary window frame is hidden.
 for band=0,2 do for n=0,band+1 do R.rect(panel,w-9-band*4+n*2,h-6-n*2,2,2,P.metalLight) end end
end
return A
