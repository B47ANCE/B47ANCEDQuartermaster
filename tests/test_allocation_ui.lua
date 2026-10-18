-- Domain controls isolate their presentation dependency; paired suites load the real public provider.
package.loaded['B47ANCEDQuartermaster/UIProvider']={Dialog={decorate=function() end}}
require 'B47ANCEDQuartermaster/Schema';require 'B47ANCEDQuartermaster/Categorizer'
local Q=B47ANCEDQuartermaster;local UI=require 'B47ANCEDQuartermaster/AllocationUI'
getText=function(key) return key end;UIFont={Small=1}
getTextManager=function() return {getFontHeight=function() return 14 end,MeasureStringX=function(_,_,text) return #text*7 end} end
local cat=Q.Categorizer.nativeID('Food')
local entries={{name='Shared',fullType='Base.Food',category=cat},{name='Shared',fullType='Other.Food',category=cat},{name='Other',fullType='Base.Other',category=cat}}
local api={entries=entries};local p={api=api,selectedPresets={},getPresetStore=function() return {} end,qmss={model={readOnly=false}},playerNum=0}
local captures=0;local list={getWidth=function() return 650 end,isVScrollBarVisible=function() return false end,setCapture=function(_,active) captures=captures+(active and 1 or -1) end};p.listbox=list
local group={key=cat,label='Food'}
local rows=UI.rows(p,{{kind='category',group=group,id='category'},{kind='item',key='Shared',group=group,id='shared'},{kind='item',key='Other',group=group,id='other'}})
assert(#rows==4 and rows[2].allocationFullType=='Base.Food' and rows[3].allocationFullType=='Other.Food' and rows[2].id~=rows[3].id)
local value,state=UI.state(p,rows[1]);assert(value==100 and state=='legacy')
assert(UI.set(p,rows[2],25) and p.allocation.items['Base.Food']==25 and not p.allocation.items['Other.Food'])
value,state=UI.state(p,rows[1]);assert(value==nil and state=='mixed')
local index=UI.index(p);local left,_,track=UI.geometry(list)
assert(UI.press(p,list,rows[1],left+track*.5));assert(captures==1)
UI.move(p,list,left+track*.75);UI.release(p);assert(captures==0 and not p.allocationDrag)
assert(p.allocation.cats[cat]==75 and p.allocation.items['Base.Food']==nil)
assert(UI.index(p)==index,'slider movement rebuilt the item catalog index')
p.qmss.model.readOnly=true;assert(not UI.set(p,rows[2],50));assert(p.allocation.cats[cat]==75)
p.qmss.model.readOnly=false;UI.reset(p,rows[1]);assert(p.allocation.cats[cat]==nil and UI.state(p,rows[1])==100)
local dialog
ISTextBox={new=function(_,_,_,_,_,_,text,owner,callback)
 dialog={entry={getInternalText=function() return text end},initialise=function() end,addToUIManager=function() end,owner=owner,callback=callback};return dialog
end}
setJoypadFocus=function() end
UI.exact(p,rows[2]);assert(dialog)
dialog.entry.getInternalText=function() return '31' end;dialog.callback(p,{internal='OK',parent=dialog});assert(p.allocation.items['Base.Food']==31)
dialog.entry.getInternalText=function() return '101' end;dialog.callback(p,{internal='OK',parent=dialog});assert(p.allocation.items['Base.Food']==31)
local requests=0;sendClientCommand=function() requests=requests+1 end
for n=0,100,5 do UI.set(p,rows[2],n) end
assert(requests==0 and UI.index(p)==index,'local preview submitted intermediate writes or rebuilt catalog')
print('PASS OFFLINE allocation UI controls: virtual exact-FullType rows, Mixed, 5% drag/capture cleanup, inheritance reset, read-only guards, numeric validation and zero intermediate network writes')
