"""Development-only source preview. Requires Pillow and lupa.lua51; never launches PZ.
Native widget drawing and fonts are approximated; Lua positions/art are executed unchanged.
Sample item names are fixtures, not real player inventory.
"""
from pathlib import Path
import sys,json
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'.test-deps'))
from lupa.lua51 import LuaRuntime
from PIL import Image,ImageDraw,ImageFont
import argparse,os
args=argparse.ArgumentParser(description='Host-render the real computer Lua layout; not native PZ pixels.')
args.add_argument('--output',type=Path,required=True)
args.add_argument('--ui',type=Path,required=True,help='Standalone B47ANCEDUI checkout')
args.add_argument('--pc-framework',type=Path,required=True,help='Paired standalone PC Framework source checkout')
args=args.parse_args()
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src/B47ANCEDQuartermaster/42/media/lua'
OUT=args.output.resolve();OUT.mkdir(parents=True,exist_ok=True)
PC=args.pc_framework.resolve()/'src/B47ANCEDPCFramework/42/media/lua'
assert (PC/'client/B47ANCEDPCFramework/ComputerArt.lua').is_file(), 'Paired CRT framework is required'
fontroot=Path(os.environ.get('WINDIR','C:/Windows'))/'Fonts'
try:
 font=ImageFont.truetype(str(fontroot/'tahoma.ttf'),14)
 heading=ImageFont.truetype(str(fontroot/'tahomabd.ttf'),18)
except OSError:
 font=ImageFont.truetype('DejaVuSans.ttf',14)
 heading=ImageFont.truetype('DejaVuSans-Bold.ttf',18)
labels=json.loads((SRC/'shared/Translate/EN/UI.json').read_text(encoding='utf-8'))
labels.update(json.loads((PC/'shared/Translate/EN/UI.json').read_text(encoding='utf-8')))
lua=LuaRuntime(unpack_returned_tuples=True)
UI_CLIENT=args.ui.resolve()/'src/B47ANCEDUI/42/media/lua/client'
assert (UI_CLIENT/'B47ANCEDUI/API.lua').is_file()
lua.globals().package.path=UI_CLIENT.as_posix()+'/?.lua;'+lua.globals().package.path
lua.globals().translate=lambda k,*args:labels.get(k,k)
lua.globals().measure=lambda s:font.getlength(str(s))
lua.execute('package.path=... .. "/client/?.lua;" .. ... .. "/shared/?.lua;" .. package.path',SRC.as_posix(),SRC.as_posix())
lua.execute('package.path=... .. "/client/?.lua;" .. ... .. "/shared/?.lua;" .. package.path',PC.as_posix(),PC.as_posix())
lua.execute(r'''
UIFont={Small=1,Medium=2};Keyboard={KEY_ESCAPE=1};Joypad={BButton=1}
getText=function(k,...) local s=translate(k);for n,v in ipairs({...}) do s=s:gsub('%%'..n,tostring(v)) end;return s end
getTextManager=function() return {getFontHeight=function() return 14 end,MeasureStringX=function(_,_,s) return measure(s) end} end
getPlayerScreenWidth=function() return 1140 end;getPlayerScreenHeight=function() return 800 end
getTimestampMs=function() return 5000 end
setJoypadFocus=function() end
local W={};W.__index=W
function W:new(x,y,w,h,title,owner,fn) return setmetatable({x=x,y=y,width=w,height=h,title=title or '',onclick=fn,owner=owner,children={},visible=true,enable=true,options={},selected=1},self) end
function W:initialise() end;function W:instantiate() end
function W:addChild(c) c.parent=self;table.insert(self.children,c) end
function W:removeChild(c) for i,v in ipairs(self.children) do if v==c then table.remove(self.children,i);c.parent=nil;return end end end
function W:bringToTop() local p=self.parent;if p then p:removeChild(self);p:addChild(self) end end
function W:setVisible(v) self.visible=v end;function W:isVisible() return self.visible end
function W:getWidth() return self.width end;function W:getHeight() return self.height end
function W:setWidth(n) self.width=n end;function W:setHeight(n) self.height=n end
function W:setEnable(v) self.enable=v end;function W:setWantKeyEvents() end
function W:insertNewLineOfButtons() end;function W:addToUIManager() end;function W:removeFromUIManager() end
function W:drawRect(x,y,w,h,a,r,g,b) drawrect(self,x,y,w,h,a,r,g,b,false) end
function W:drawRectBorder(x,y,w,h,a,r,g,b) drawrect(self,x,y,w,h,a,r,g,b,true) end
function W:drawText(s,x,y,r,g,b,a) drawtext(self,s,x,y,r,g,b,a,false) end
function W:drawTextCentre(s,x,y,r,g,b,a) drawtext(self,s,x,y,r,g,b,a,true) end
function W:clear() self.options={} end
function W:addOptionWithData(text,data) table.insert(self.options,{text=text,data=data}) end
function W:prerender() end;function W:render() end
ISPanelJoypad=W;ISPanel=W;package.loaded['ISUI/ISPanelJoypad']=W;ISButton=setmetatable({},W);ISButton.__index=ISButton
ISCollapsableWindowJoypad=setmetatable({},W);ISCollapsableWindowJoypad.__index=ISCollapsableWindowJoypad
ISComboBox=setmetatable({},W);ISComboBox.__index=ISComboBox
function ISComboBox:render()
 local c=self.backgroundColor or {r=1,g=1,b=1,a=1};self:drawRect(0,0,self.width,self.height,c.a,c.r,c.g,c.b)
 self:drawRectBorder(0,0,self.width,self.height,1,.36,.36,.34)
 local v=self.options[self.selected];self:drawText(v and v.text or '',7,6,.04,.05,.05,1)
 self:drawRect(self.width-24,1,23,self.height-2,1,.75,.75,.72);self:drawText('v',self.width-17,5,.04,.05,.05,1)
end
package.loaded['ISUI/ISComboBox']=ISComboBox
require 'B47ANCEDUI/Theme';require 'B47ANCEDUI/Renderer'
require 'B47ANCEDUI/Clipboard'
B47ANCEDUI.Layout={place=function(w,x,y,a,b) w.x=x;w.y=y;w.width=a;w.height=b end}
B47ANCEDUI.Tooltip={attach=function() end,dispose=function() end};B47ANCEDUI.Focus={restore=function() end}
B47ANCEDUI.bounds=function(w) w.x=0;w.y=0 end
package.loaded['B47ANCEDUI/Controls']=true
-- Host pixel approximation only; paired tests, not this preview, validate the public provider/factories.
package.loaded['B47ANCEDQuartermaster/UIProvider']=B47ANCEDUI
require 'B47ANCEDPCUI/Theme';require 'B47ANCEDPCUI/Renderer'
B47ANCEDPCUI.Layout=B47ANCEDUI.Layout;B47ANCEDPCUI.Tooltip=B47ANCEDUI.Tooltip;B47ANCEDPCUI.Focus=B47ANCEDUI.Focus;B47ANCEDPCUI.bounds=B47ANCEDUI.bounds
package.loaded['B47ANCEDPCUI/Controls']=true
B47ANCEDPCFramework={}
package.loaded['B47ANCEDPCFramework/Device']={enabled=function() return true end,computer=function() return true end}
B47ANCEDQuartermaster={}
actor={isDead=function() return false end};getSpecificPlayer=function() return actor end
package.loaded['B47ANCEDQuartermaster/LedgerPolicy']={enabled=function() return true end}
package.loaded['B47ANCEDQuartermaster/LedgerMedia']={computer=function() return true end,disc='B47ANCEDQuartermaster.SupplyDisc'}
local function item(id,name,ft) return {getID=function() return id end,getDisplayName=function() return name end,getFullType=function() return ft end,getModData=function() return {B47Ledger={complete=true}} end} end
paper=item(1,'Supply Sheet - Home','B47ANCEDQuartermaster.SupplySheet');cd=item(2,'CD','Base.Disc_Retail')
mounted=false
local function row() return {id=3,name='Home Supply Ledger',fullType='B47ANCEDQuartermaster.SupplyDisc',drive='preview-drive',token='preview-token'} end
hooks={id='preview',enabled=function() return true end,canUse=function() return true end,canRun=function(i) return i:getFullType()=='B47ANCEDQuartermaster.SupplyDisc' end,file='QUARTERMASTER.EXE',text=function(k,...) return getText('UI_QMSS_'..k,...) end,writer=function(screen,hooks) return require('B47ANCEDQuartermaster/ComputerWriter')(screen,hooks) end,close=function() end,busy=function() return false end,read=function() end,burn=function() end,inventory=function() return {paper},{},{cd} end,
 drive=function(command,args,reply)
 if command=='mount' then mounted=true elseif command=='eject' then mounted=false end
 reply({status='ok',choices={row()},mounted=mounted and row() or nil})
 end}
C=require 'B47ANCEDQuartermaster/ComputerUI'
screen=C.open(0,{},hooks)
function walk(w)
 if not w.visible then return end
 if w.prerender then w:prerender() end
 if w.render then w:render() end
 for _,c in ipairs(w.children) do walk(c) end
end
''')
canvas=None
def position(w,x,y):
 while w is not None:
  x+=w['x'] or 0;y+=w['y'] or 0;w=w['parent']
 return round(x),round(y)
def color(r,g,b,a=1):return tuple(round(max(0,min(1,v))*255) for v in (r,g,b,a))
def rect(w,x,y,width,height,a,r,g,b,border):
 x,y=position(w,x,y);width=round(width);height=round(height)
 if width<=0 or height<=0:return
 d=ImageDraw.Draw(canvas);c=color(r,g,b,a)
 d.rectangle((x,y,x+width-1,y+height-1),outline=c if border else None,fill=None if border else c)
def text(w,s,x,y,r,g,b,a,center):
 x,y=position(w,x,y);s=str(s);d=ImageDraw.Draw(canvas)
 if center:x-=round(font.getlength(s)/2)
 d.text((x,y),s,font=font,fill=color(r,g,b,a),anchor='lt')
lua.globals().drawrect=rect;lua.globals().drawtext=text
lua.execute(r'''

local W=ISPanelJoypad
function W:setX(v) self.x=v end
function W:setY(v) self.y=v end
local U=B47ANCEDUI
U.skin=function() end;U.RowTooltip={hide=function() end};U.Tooltip.plain=function(s) return tostring(s):gsub('[<>]','') end
U.Layout.scrollbar=function() end
function W:getYScroll() return self.scroll or 0 end
function W:setYScroll(v) self.scroll=v end
U.Button=ISButton;U.WindowShell=ISCollapsableWindowJoypad
function ISButton:render()
 local c=self.backgroundColor or C.colors.grey
 self:drawRect(0,0,self.width,self.height,1,c.r,c.g,c.b)
 self:drawRectBorder(0,0,self.width,self.height,1,.36,.36,.34)
 local t=self.enable and (self.textColor or C.colors.black) or (self.textColorDisabled or C.colors.muted)
 self:drawTextCentre(self.title,self.width/2,(self.height-14)/2,t.r,t.g,t.b,1)
end
U.TextInput=setmetatable({},W);U.TextInput.__index=U.TextInput
function U.TextInput:new(value,x,y,w,h) local o=W.new(self,x,y,w,h);o.value=value;return o end
function U.TextInput:getInternalText() return self.value end
function U.TextInput:setTextRGBA() end
function U.TextInput:render()
 self:drawRect(0,0,self.width,self.height,1,1,1,.97)
 self:drawRectBorder(0,0,self.width,self.height,1,.36,.36,.34)
 self:drawText(self.value,7,6,.04,.05,.05,1)
end
U.ScrollList=setmetatable({},W);U.ScrollList.__index=U.ScrollList
function U.ScrollList:clear() self.items={};self.selected=1 end
function U.ScrollList:addItem(name,data) self.items=self.items or {};table.insert(self.items,{text=name,item=data}) end
function U.ScrollList:render()
 self:drawRectBorder(0,0,self.width,self.height,1,.36,.36,.34)
 local y=0
 for i,row in ipairs(self.items or {}) do
  if y+self.itemheight>self.height then break end
  row.index=i
  y=self:doDrawItem(y,row,i%2==0)
 end
end
for _,p in ipairs({'TimedActions/ISTimedActionQueue','TimedActions/WalkToTimedAction','B47ANCEDQuartermaster/Authority','B47ANCEDQuartermaster/LedgerScope','B47ANCEDQuartermaster/LedgerAction'}) do package.loaded[p]={} end
package.loaded['B47ANCEDQuartermaster/Ledger']={clientOffers={}}
function screen.computer:getSquare() return {getX=function() return 11000 end,getY=function() return 9600 end,getZ=function() return 0 end} end
function screen.computer:getObjectIndex() return 0 end
local previewComputer=screen.computer;local previewMD={B47QMProgramVersion='1'}
function previewComputer:getModData() return previewMD end
function actor:setHaloNote() end
local setupMounted=false
local setupRow={id=4,name='Quartermaster Application CD',fullType='B47ANCEDQuartermaster.ApplicationCD',drive='setup-preview',token='setup-preview-choice'}
B47ANCEDQuartermaster.Authority={request=function(num,command,args,callback)
 if command=='ledgerSetupList' then callback({status='ok',choices={setupRow},mounted=setupMounted and setupRow or nil});return end
 if command=='ledgerSetupMount' then setupMounted=true;callback({status='ok',mounted=setupRow});return end
 if command=='ledgerProgramRun' then callback({status='ok',program={id='quartermaster.setup',version='1'},media=setupRow});return end
 local rows={}
 local samples={{'Nails',200,'Base.Nails','Workshop','Wooden Crate'}, {'Hammer',3,'Base.Hammer','Workshop','Tool Cabinet'}, {'Canned Beans',12,'Base.TinnedBeans','Pantry','Cupboard'}, {'Bandage',8,'Base.Bandage','Medical','Wall Cabinet'}, {'9mm Rounds',150,'Base.Bullets9mm','Armory','Wooden Crate'}, {'Water Bottle',6,'Base.WaterBottle','Kitchen','Cupboard'}}
 for i,s in ipairs(samples) do rows[i]={name=s[1],quantity=s[2],fullType=s[3],condition=10,room=s[4],roomID='sample-'..s[4],container=s[5],position={x=11000+i,y=9600,z=0,ci=0},recorded=148.5} end
 callback({status='ok',rows=rows,rooms={{id='sample-Workshop',name='Workshop'},{id='sample-Pantry',name='Pantry'},{id='sample-Medical',name='Medical'}},scope='Home building',summary='LedgerComplete',revision=1,live=true,fresh=true,expires=172.5,cursor='sample-next'})
end}
local media=package.loaded['B47ANCEDQuartermaster/LedgerMedia'];media.owned=function(_,id) return id==1 and paper or nil end
local V=require 'B47ANCEDQuartermaster/LedgerUI'
openPaper=function() clipboard=V.read(0,paper) end
openInstaller=function() screen:close();previewMD.B47QMProgramVersion=nil;screen=V.computer(0,previewComputer);screen:openDrive();screen.content.insert.onclick();screen:runDisc() end
hooks.read=function(disc,host) return V.read(0,disc,screen.computer,host) end

''')
states=[('Desktop',''),('Start menu','screen.start.onclick()'),('Loaded ledger CD',"screen:openDrive();screen.content.insert.onclick()"),('CD Writer','screen:eject();screen:openWriter()'),('Supply Ledger',"screen:openDrive();screen.content.insert.onclick();screen:runDisc()"),('Paper Ledger',"openPaper()"),('Application CD Setup',"openInstaller()")]
images=[]
for i,(title,code) in enumerate(states):
 canvas=Image.new('RGBA',(int(lua.globals().screen.width),int(lua.globals().screen.height)),(28,28,26,255))
 if code:lua.execute(code)
 surface=lua.globals().clipboard if title=='Paper Ledger' else lua.globals().screen
 canvas=Image.new('RGBA',(int(surface.width),int(surface.height)),(28,28,26,255))
 lua.globals().previewSurface=surface;lua.execute('walk(previewSurface)')
 p=OUT/f'computer-{i+1}.png';canvas.convert('RGB').save(p);images.append((title,canvas.copy()))
 if title=='Paper Ledger':canvas.convert('RGB').save(OUT/'paper-ledger.png')
 if title=='Application CD Setup':canvas.convert('RGB').save(OUT/'application-setup.png')
thumbW=700
thumbH=round(thumbW*images[0][1].height/images[0][1].width)
sheet=Image.new('RGB',(thumbW*2+48,thumbH*((len(images)+1)//2)+220),(24,27,28));d=ImageDraw.Draw(sheet)
d.text((16,12),'Quartermaster computer UI - source-rendered preview',font=heading,fill=(235,236,230))
d.text((16,38),'Actual Lua layout, palette and symbols. Host fonts/native controls approximate; not a PZ screenshot.',font=font,fill=(175,185,185))
for i,(title,img) in enumerate(images):
 x=16+(i%2)*(thumbW+16);y=80+(i//2)*(thumbH+42)
 d.text((x,y-23),title,font=heading,fill=(230,233,227));preview=img.convert('RGB');preview.thumbnail((thumbW,thumbH),Image.Resampling.LANCZOS);sheet.paste(preview,(x,y))
p=OUT/'computer-ui-preview.png';sheet.save(p)
print(p)
