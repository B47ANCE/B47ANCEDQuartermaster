-- Original native-shaped offline fixture. Does not prove actual PZ rendering.
getText=function(key) return key end
local R=require 'B47ANCEDQuartermaster/Categorizer'
local nativeKey='IGUI_ItemCat_Material'
local language='EN'
getText=function(key)
 if key==nativeKey then return 'Vanilla material' end
 return language..':'..key
end
local allowed=false
package.loaded['B47ANCEDQuartermaster/Compatibility']={allowed=function() return allowed end}
package.preload['ISUI/ISInventoryPane']=function() return true end
local events={}
Events={OnGameStart={Add=function(fn) events[#events+1]=fn end}}
local script={getFullName=function() return 'Base.Nails' end,getDisplayCategory=function() return 'Material' end,
 getItemType=function() return 'normal' end,getTags=function() return {} end}
local item={getScriptItem=function() return script end,getDisplayCategory=function() return 'Material' end,
 getCategory=function() return 'Material' end,getJobDelta=function() return itemJob or 0 end}
local row={items={item,item},cat='Material',name='Nails'}
local draws,priorCalls={},0
ISInventoryPane={refreshContainer=function(self) self.itemslist={row};return 'refresh',nil,3 end,
 renderdetails=function(self,dragged)
  self.items={row}
  self:drawText('Nails',self.column2+8,12)
  self:drawText('Vanilla material',self.column3+8,12)
  self:drawText('Vanilla material',self.column3+8,30) -- same stack header cell
  self.items[#self.items+1]=item
  self:drawText('Native detail',self.column3+8,48) -- expanded detail stays intact
  if self.fail then error('native failure') end
  return 'rendered',nil,9
 end}
local nativeRender=ISInventoryPane.renderdetails
-- An earlier wrapper must remain in the invocation chain.
ISInventoryPane.renderdetails=function(self,...)
 priorCalls=priorCalls+1;return nativeRender(self,...)
end
local refresh=ISInventoryPane.refreshContainer
local I=require 'B47ANCEDQuartermaster/InventoryCategories'
assert(I.installed and #events==1,'early compatibility unknown must not prevent registration')
local wrapper=ISInventoryPane.renderdetails
local function pane(kind)
 return setmetatable({kind=kind,column2=20,column3=80,itemslist={row},
 drawText=function(_,value) draws[#draws+1]=value;return 'draw',nil,7 end},{__index=ISInventoryPane})
end
local p=pane('player');local draw=p.drawText
p:renderdetails(false);assert(draws[2]=='Vanilla material','unknown/conflicting compatibility fallback')
allowed=true
local expected=R.label(R.resolve(item))
assert(expected:find('UI_B47_Category_MaterialsFasteners',1,true))
for _,kind in ipairs({'player','bag','loot','vehicle','controller-player2'}) do
 draws={};local view=pane(kind)
 local a,b,c=view:renderdetails(false)
 assert(a=='rendered' and b==nil and c==9,'all return values preserved')
 assert(draws[1]=='Nails' and draws[2]==expected and draws[3]==expected and draws[4]=='Native detail')
 assert(row.cat=='Material' and item:getDisplayCategory()=='Material','native keys must remain unchanged')
end
assert(I.originalRefresh==refresh,'native refresh delegate must be preserved')
local a,b,c=p:refreshContainer();assert(a=='refresh' and b==nil and c==3)
assert(p.drawText==draw and priorCalls>0)
itemJob=0.5;draws={};p:renderdetails(false);assert(draws[2]=='Vanilla material','job text must not be substituted even when it equals a category label');itemJob=nil
draws={};p:renderdetails(true);assert(draws[2]=='Vanilla material')
-- Canonical cache keys by script identity, including shared instances; labels never cached.
local rank=R.rank;local calls=0
R.rank=function(...) calls=calls+1;return rank(...) end
R.invalidate();I.label(item);I.label(item);assert(calls==0,'explicit override uses canonical cache/override path')
local modScript={getFullName=function() return 'Example.Unknown' end,getItemType=function() return 'normal' end,
 getTags=function() return {} end,getDisplayCategory=function() return 'Material' end}
local modItem={getScriptItem=function() return modScript end}
assert(I.label(modItem)==R.label(R.resolve(modItem)),'modded canonical fallback')
local n=calls;I.label(modItem);assert(calls==n,'canonical cache reused')
R.invalidate();I.label(modItem);assert(calls==n+1,'canonical invalidation observed')
SandboxVars={B47ANCEDQuartermaster={ClassifyToolsByUse=false}}
I.label(modItem);assert(calls==n+1,'retired tool setting invalidated canonical cache')
language='FR';assert(I.label(item):sub(1,3)=='FR:','language changes use current translation')
local saved=B47ANCEDQuartermaster.Categorizer
B47ANCEDQuartermaster.Categorizer=nil;assert(I.label(item)==nil)
B47ANCEDQuartermaster.Categorizer={};assert(I.label(item)==nil)
B47ANCEDQuartermaster.Categorizer=saved
assert(I.label(nil)==nil)
-- Reinitialization keeps one wrapper/event and uses the current adapter implementation.
package.loaded['B47ANCEDQuartermaster/InventoryCategories']=nil
assert(require('B47ANCEDQuartermaster/InventoryCategories')==I)
I.install();events[1]();assert(ISInventoryPane.renderdetails==wrapper and #events==1)
-- A later wrapper also remains untouched by repeated initialization.
local outer=function(self,...) return wrapper(self,...) end
ISInventoryPane.renderdetails=outer;I.install();assert(ISInventoryPane.renderdetails==outer)
p.fail=true;assert(not pcall(p.renderdetails,p,false) and p.drawText==draw,'exception restores instance draw method')
-- Adapter only intercepts matching Category cells, never group headings/job labels.
p.fail=nil;draws={}
local oldLabel=I.label;I.label=function() return 'Intercepted' end
p.items={row};p:drawText('Vanilla material',88,0)
assert(draws[1]=='Vanilla material','drawing outside render remains native')
I.label=oldLabel
-- Execute the installed vanilla Category/detailed-child branch read-only.
-- Source extraction is a drift check and offline integration evidence, not a native test.
local file=assert(io.open(GAME_ROOT..'/media/lua/client/ISUI/ISInventoryPane.lua','rb'))
local source=file:read('*a'):gsub('\r\n','\n');file:close()
local begin=assert(source:find('                    if count == 1 then\n',source:find('if item:getJobDelta() > 0',1,true),true))
local finish=assert(source:find('                if self.selected ~= nil',begin,true))
local block=source:sub(begin,finish-1)
-- The last end closes the outer job branch rather than the extracted count branch.
block=assert(block:match('^(.*)                end\n'))
local installed=assert(loadstring('return function(self,doDragged,item,count,y,textDY,xoff,yoff) '..block..' end'))()
local beforeInstalled=ISInventoryPane.renderdetails
local beforeRefresh=ISInventoryPane.refreshContainer
local beforeInvalidate=R.invalidate
ISInventoryPane.renderdetails=function(self,dragged)
 self.items={row};installed(self,dragged,item,1,0,0,0,0)
 self.items[#self.items+1]=item;installed(self,dragged,item,2,1,0,0,0)
end
-- An independent fresh adapter instance wraps this native branch.
local previousI=B47ANCEDQuartermaster.InventoryCategories
B47ANCEDQuartermaster.InventoryCategories=nil
package.loaded['B47ANCEDQuartermaster/InventoryCategories']=nil
local nativeAdapter=require 'B47ANCEDQuartermaster/InventoryCategories'
p.itemHgt=20;p.headerHgt=10;p.font='Small'
p.drawItemDetails=function(self) self:drawText('Native detail',88,0) end
draws={};p:renderdetails(false)
assert(draws[1]==I.label(item) and draws[2]=='Native detail','installed native Category branch')
B47ANCEDQuartermaster.InventoryCategories=previousI
ISInventoryPane.renderdetails=beforeInstalled
ISInventoryPane.refreshContainer=beforeRefresh
R.invalidate=beforeInvalidate
-- Diagnostic production path: off by default, bounded, current-version samples.
local logs={};local originalPrint=print
print=function(message) logs[#logs+1]=message end
I.enableDiagnostics(false);p:renderdetails(false);assert(#logs==0)
I.enableDiagnostics(true);assert(logs[1]:find('SNAPSHOT',1,true))
for n=1,80 do p:renderdetails(false) end
assert(#logs==64 and I.traceCount==64,'diagnostics must exhaust fixed budget')
local joined=table.concat(logs,'\n')
for _,stage in ipairs({'WRAPPER_INVOKED','DRAW_TEXT','CATEGORY_POSITION','CATEGORY_DRAW','RESOLVED','SUBSTITUTED'}) do
 assert(joined:find(stage,1,true),'missing boundary '..stage)
end
I.enableDiagnostics(false);p:renderdetails(false);assert(#logs==64)
print=originalPrint
print('PASS OFFLINE dev.21 bounded diagnostics; dev.20 canonical native Category presentation, cache, compatibility, stacks, pane contracts and reload; native UI untested')
