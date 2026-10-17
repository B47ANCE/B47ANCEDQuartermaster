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
args=args.parse_args()
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src/B47ANCEDQuartermaster/42/media/lua'
OUT=args.output.resolve();OUT.mkdir(parents=True,exist_ok=True)
fontroot=Path(os.environ.get('WINDIR','C:/Windows'))/'Fonts'
try:
 font=ImageFont.truetype(str(fontroot/'tahoma.ttf'),14)
 heading=ImageFont.truetype(str(fontroot/'tahomabd.ttf'),18)
except OSError:
 font=ImageFont.truetype('DejaVuSans.ttf',14)
 heading=ImageFont.truetype('DejaVuSans-Bold.ttf',18)
labels=json.loads((SRC/'shared/Translate/EN/UI.json').read_text(encoding='utf-8'))
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().translate=lambda k,*args:labels.get(k,k)
lua.globals().measure=lambda s:font.getlength(str(s))
lua.execute('package.path=... .. "/client/?.lua;" .. ... .. "/shared/?.lua;" .. package.path',SRC.as_posix(),SRC.as_posix())
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
ISPanelJoypad=W;ISPanel=W;ISButton=setmetatable({},W);ISButton.__index=ISButton
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
B47ANCEDUI.Layout={place=function(w,x,y,a,b) w.x=x;w.y=y;w.width=a;w.height=b end}
B47ANCEDUI.Tooltip={attach=function() end,dispose=function() end};B47ANCEDUI.Focus={restore=function() end}
B47ANCEDUI.bounds=function(w) w.x=0;w.y=0 end
package.loaded['B47ANCEDUI/Controls']=true
B47ANCEDQuartermaster={}
actor={isDead=function() return false end};getSpecificPlayer=function() return actor end
package.loaded['B47ANCEDQuartermaster/LedgerPolicy']={enabled=function() return true end}
package.loaded['B47ANCEDQuartermaster/LedgerMedia']={computer=function() return true end,disc='B47ANCEDQuartermaster.SupplyDisc'}
local function item(id,name,ft) return {getID=function() return id end,getDisplayName=function() return name end,getFullType=function() return ft end,getModData=function() return {B47Ledger={complete=true}} end} end
paper=item(1,'Supply Sheet - Home','B47ANCEDQuartermaster.SupplySheet');cd=item(2,'CD','Base.Disc_Retail')
mounted=false
local function row() return {id=3,name='Home Supply Ledger',fullType='B47ANCEDQuartermaster.SupplyDisc',drive='preview-drive',token='preview-token'} end
hooks={close=function() end,busy=function() return false end,read=function() end,burn=function() end,inventory=function() return {paper},{},{cd} end,
 drive=function(command,args,reply)
 if command=='ledgerDriveMount' then mounted=true elseif command=='ledgerDriveEject' then mounted=false end
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
states=[('Desktop',''),('Start menu','screen.start.onclick()'),('Loaded ledger CD',"screen:openDrive();screen.content.insert.onclick()"),('CD Writer','screen:eject();screen:openWriter()')]
images=[]
for i,(title,code) in enumerate(states):
 if code:lua.execute(code)
 canvas=Image.new('RGBA',(int(lua.globals().screen.width),int(lua.globals().screen.height)),(28,28,26,255));lua.execute('walk(screen)')
 p=OUT/f'computer-{i+1}.png';canvas.convert('RGB').save(p);images.append((title,canvas.copy()))
thumbW,thumbH=700,546
sheet=Image.new('RGB',(thumbW*2+48,thumbH*2+134),(24,27,28));d=ImageDraw.Draw(sheet)
d.text((16,12),'Quartermaster computer UI - source-rendered preview',font=heading,fill=(235,236,230))
d.text((16,38),'Actual Lua layout, palette and symbols. Host fonts/native controls approximate; not a PZ screenshot.',font=font,fill=(175,185,185))
for i,(title,img) in enumerate(images):
 x=16+(i%2)*(thumbW+16);y=80+(i//2)*(thumbH+42)
 d.text((x,y-23),title,font=heading,fill=(230,233,227));sheet.paste(img.convert('RGB').resize((thumbW,thumbH),Image.Resampling.LANCZOS),(x,y))
p=OUT/'computer-ui-preview.png';sheet.save(p)
print(p)
