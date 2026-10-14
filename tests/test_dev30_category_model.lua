-- Offline execution of installed native comparators; no game launch.
getText=function(k) return k end
require 'B47ANCEDQuartermaster/Categorizer'
package.preload['ISUI/ISInventoryPane']=function() return true end
local allowed=true
package.loaded['B47ANCEDQuartermaster/Compatibility']={allowed=function() return allowed end}
ISInventoryPane={}
string.sort=function(a,b) return a>b end
local f=assert(io.open(GAME_ROOT..'/media/lua/client/ISUI/ISInventoryPane.lua','rb'))
local source=f:read('*a');f:close()
local first=assert(source:find('ISInventoryPane.itemSortByCatInc = function',1,true))
local last=assert(source:find('function ISInventoryPane:sortByName',first,true))
assert(loadstring(source:sub(first,last-1)))()
local function item(full,native)
 local script={getFullName=function() return full end,getDisplayCategory=function() return native end,
 getItemType=function() return 'normal' end,getTags=function() return {} end}
 return {getScriptItem=function() return script end,getDisplayCategory=function() return native end,
 getCategory=function() return native end,getJobDelta=function() return 0 end}
end
local nails=item('Base.Nails','ZZZ');local knife=item('Base.ButterKnife','AAA')
local refreshes=0
ISInventoryPane.refreshContainer=function(p)
 refreshes=refreshes+1
 p.itemslist={{items={nails,nails},name='Nails',cat='ZZZ',equipped=false},
 {items={knife,knife},name='Knife',cat='AAA',equipped=false}}
 table.sort(p.itemslist,p.itemSortFunc)
 p.selected={[1]=nails}
 return 'refresh',nil,7
end
ISInventoryPane.saveSelection=function(p,s) for _,v in pairs(p.selected) do s[v]='group' end;return s end
ISInventoryPane.restoreSelection=function(p,s) for n,r in ipairs(p.itemslist) do if s[r.items[1]] then p.selected[n]=r.items[1] end end end
ISInventoryPane.renderdetails=function() end
local start
Events={OnGameStart={Add=function(fn) start=fn end}}
local I=require 'B47ANCEDQuartermaster/InventoryCategories'
local p=setmetatable({itemSortFunc=ISInventoryPane.itemSortByCatInc,column3=80,selected={}}, {__index=ISInventoryPane})
local existing=setmetatable({inventory={},itemSortFunc=ISInventoryPane.itemSortByCatInc,column3=80,selected={}}, {__index=ISInventoryPane})
existing:renderdetails(false);assert(existing.b47CategoryRevision~=nil,'pre-existing native panes initialize before paint')
local firstPaintCount=refreshes;existing:renderdetails(false);assert(refreshes==firstPaintCount)
local a,b,c=p:refreshContainer();assert(a=='refresh' and b==nil and c==7)
for _,r in ipairs(p.itemslist) do assert(r.cat==B47ANCEDQuartermaster.Categorizer.label(B47ANCEDQuartermaster.Categorizer.resolve(r.items[1]))) end
assert(p.itemslist[1].cat<=p.itemslist[2].cat)
local count=0;for _,v in pairs(p.selected) do count=count+1;assert(v==nails) end;assert(count==1)
I.present(p);for _,r in ipairs(p.itemslist) do assert(r.b47NativeCat==r.items[1]:getDisplayCategory()) end
p.itemSortFunc=ISInventoryPane.itemSortByCatDesc;p:refreshContainer()
assert(p.itemslist[1].cat>=p.itemslist[2].cat)
local old=refreshes;p:renderdetails(false);p:renderdetails(false);assert(refreshes==old)
B47ANCEDQuartermaster.Categorizer.invalidate();p:renderdetails(false);assert(refreshes==old+1)
p:renderdetails(false);assert(refreshes==old+1)
allowed=false;p:renderdetails(false);assert(p.itemslist[1].cat=='ZZZ')
assert(nails:getDisplayCategory()=='ZZZ' and knife:getDisplayCategory()=='AAA')
allowed=true;p:renderdetails(false);assert(p.itemslist[1].cat==B47ANCEDQuartermaster.Categorizer.label(B47ANCEDQuartermaster.Categorizer.resolve(p.itemslist[1].items[1])))
local inner=ISInventoryPane.refreshContainer;local late=0
ISInventoryPane.refreshContainer=function(...) late=late+1;return inner(...) end
start();local head=ISInventoryPane.refreshContainer;start();assert(ISInventoryPane.refreshContainer==head)
p:refreshContainer();assert(late==1)
for _,r in ipairs(p.itemslist) do assert(r.b47NativeCat==r.items[1]:getDisplayCategory()) end
-- Display translations can order differently from canonical IDs.
local resolver=B47ANCEDQuartermaster.Categorizer;local label=resolver.label
resolver.label=function(key) return key==resolver.resolve(nails) and 'AAA readable label' or 'ZZZ readable label' end
p.itemSortFunc=ISInventoryPane.itemSortByCatInc;p:refreshContainer()
assert(p.itemslist[1].items[1]==nails and p.itemslist[1].cat=='AAA readable label','category ordering ignored translated labels')
assert(p.itemslist[1].b47Category==resolver.resolve(nails),'presentation sort changed the canonical category ID')
resolver.label=label;p:refreshContainer()
print('PASS dev30 UI row keys/native category comparators, selection identity, invalidation, compatibility and bounded startup reconciliation (offline)')
