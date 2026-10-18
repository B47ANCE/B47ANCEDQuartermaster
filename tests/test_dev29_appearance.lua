-- Owned production paths plus installed native slider code. Offline, not pixel evidence.
dofile(TEST_ROOT..'/test_shopping_ui.lua')
local Q,U=B47ANCEDQuartermaster,B47ANCEDUI
local A=Q.UIProvider.Appearance;local p=Q.openPicker(CONTAINER_FIXTURE.a,0,0)
assert(A.get(0)==82)
local records={};local writes=0
getFileWriter=function(name) return {write=function(_,s) records[name]=s;writes=writes+1 end,close=function() end} end
local calls=0;local request=Q.Authority.request;Q.Authority.request=function(...) calls=calls+1;return request(...) end
local layout=p.layout;local layouts=0;p.layout=function(...) layouts=layouts+1;return layout(...) end
local icons={};local text={};local rect={}
p.drawRect=function(_,x,y,w,h,a,r,g,b) rect[#rect+1]={x=x,y=y,w=w,h=h,a=a} end
p.drawText=function(_,value,x,y,r,g,b,a) text[#text+1]=a end
p.drawTextureScaledAspect=function(_,texture,x,y,w,h,a) icons[#icons+1]=a end
for _,percent in ipairs({20,50,82,100}) do
 A.set(0,percent);U.Renderer.background(p,0,0,p.width,p.height,U.Theme.colors.window)
 assert(rect[#rect].a==percent/100)
 U.Renderer.text(p,'foreground',0,0,U.Theme.colors.text);U.Renderer.icon(p,{},0,0,24)
 assert(text[#text]==1 and icons[#icons]==1)
end
rect={};p:prerender();local backing=0;for _,draw in ipairs(rect) do if draw.x==0 and draw.y==0 and draw.w==p.width and draw.h==p.height then backing=backing+1;assert(draw.a==1) end end;assert(backing==1,'duplicate root backing pass');layouts=0
assert(layouts==0 and calls==0 and writes==0,'appearance triggered expensive work or per-preview preference writes')
local child=ISPanel:new(0,0,100,100);child.parent=p;U.skin(child,'panel');A.prepare(child,'panel');assert(child.backgroundColor.a==0,'nested opaque backing')
local button=U.Button:new(0,0,100,30,'button',p,function() end);A.prepare(button,'button');assert(button.backgroundColor.a==U.Theme.colors.raised.a)
local stripe=U.Theme.colors.accent.a;assert(stripe==1)
local before=Q.WindowLayout.railWidth(p);Q.WindowLayout.change(p,'railMore');assert(A.get(0)==100 and Q.WindowLayout.railWidth(p)>before)
A.save(0);assert(records['B47ANCEDUI/appearance/B47ANCEDQuartermaster.0.txt']=='opacity=100\n')
-- Separate local player and a fresh module cache simulate restart/reconnect reload.
getFileReader=function(name) return {readLine=function() return records[name] end,close=function() end} end
local path=UI_SOURCE..'/B47ANCEDUI/Appearance.lua'
local RootAppearance=dofile(path)
local Reload=RootAppearance.context('B47ANCEDQuartermaster',{legacyAppearancePrefix='B47ANCEDQuartermasterAppearance'})

assert(Reload.get(0)==100 and Reload.get(1)==82,'local player persistence isolation')
for i,value in ipairs({'opacity=abc','opacity=-1','opacity=101','opacity=nan'}) do records['B47ANCEDUI/appearance/Corrupt'..i..'.0.txt']=value;assert(RootAppearance.context('Corrupt'..i).get(0)==82) end
A=Reload
-- Run the installed native slider rather than mirroring its rounding implementation.
dofile(GAME_ROOT..'/media/lua/client/RadioCom/ISUIRadio/ISSliderPanel.lua')
package.loaded['RadioCom/ISUIRadio/ISSliderPanel']=true
local V=require 'B47ANCEDQuartermaster/AppearanceUI'
A.set(0,82);local panel=V.open(p);assert(panel.slider:getCurrentValue()==82)
local oldWidth,oldHeight=p.width,p.height
panel.slider:setCurrentValue(51);assert(A.get(0)==50 and panel.slider:getCurrentValue()==50)
assert(p.width==oldWidth and p.height==oldHeight)
panel.slider:onJoypadDirRight();assert(A.get(0)==55)
panel.reset.onclick();assert(A.get(0)==82 and panel.slider.currentValue==82)
assert(panel.b47AppearanceOpaque and A.alpha(panel)==.94)
panel.close();assert(records['B47ANCEDUI/appearance/B47ANCEDQuartermaster.0.txt']=='opacity=82\n')
local tip={backgroundColor={a=0},b47AppearanceOpaque=true};assert(A.alpha(tip)==.94)
assert(calls==0,'appearance emitted gameplay RPC')
Q.Authority.request=request;p.layout=layout
print('PASS OFFLINE dev29 appearance: native slider, live alpha, foreground/selection opacity, single backing, local persistence, corruption, controller and geometry independence')
