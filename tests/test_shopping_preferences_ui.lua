dofile(TEST_ROOT..'/test_shopping_add_ui.lua')
local Q=B47ANCEDQuartermaster
package.loaded['ISUI/ISPanelJoypad']=true
ISComboBox=ISPanel:derive('ComboBox');package.loaded['ISUI/ISComboBox']=true
function ISComboBox:clear() self.options={};self.selected=1 end
function ISComboBox:addOption(text) self.options[#self.options+1]=text end
ItemType={WEAPON='weapon',CLOTHING='clothing',ALARM_CLOCK_CLOTHING='alarm',FOOD='food',DRAINABLE='drainable'}
local types={['Base.Knife']='weapon',['Base.Soup']='food',['Base.Bottle']='drainable',['Base.Nails']='normal'}
getScriptManager=function() return {FindItem=function(_,t) return {getItemType=function() return types[t] end,getDisplayName=function() return t end} end} end
local snapshot={status='ok',revision=8,preferences={schema=1,global={condition=75},overrides={},confirm=true}}
local commands={};Q.Authority.request=function(_,command,args,cb)
 if command=='personalList' then cb(snapshot) else commands[#commands+1]={command=command,args=args};cb({status='conflict'}) end
end
local U=require 'B47ANCEDQuartermaster/PreferencesUI'
local owner={};local p=U.open(0,nil,owner)
assert(p.controls.condition:isVisible() and p.controls.freshness:isVisible() and p.controls.uses:isVisible())
assert(not p.removeOverride:isVisible() and p.controls.condition.values[p.controls.condition.selected]==75)
p.fullType='Base.Knife';p:refresh()
assert(p.controls.condition:isVisible() and not p.controls.freshness:isVisible() and not p.controls.uses:isVisible())
assert(p.controls.condition.values[1]=='inherit' and p.controls.condition.selected==1 and not p.removeOverride:isVisible())
p.controls.condition.selected=2;p.save.onclick(p)
assert(commands[1].command=='shoppingPreference' and commands[1].args.rule.condition==0 and commands[1].args.fullType=='Base.Knife' and commands[1].args.revision==8)
snapshot.preferences.overrides['Base.Knife']={condition=0};p:refresh();assert(p.removeOverride:isVisible() and p.resetItem:isVisible())
p.removeOverride.onclick(p);assert(commands[2].args.action=='remove')
p.fullType='Base.Soup';p:refresh();assert(not p.controls.condition:isVisible() and p.controls.cooked:isVisible() and p.controls.rotten:isVisible())
p.fullType='Base.Bottle';p:refresh();assert(p.controls.uses:isVisible() and not p.controls.cooked:isVisible())
p.fullType='Base.Nails';p:refresh();assert(not p.save.enable and not p.controls.uses:isVisible() and not p.controls.condition:isVisible())
for _,row in ipairs(p.joypadButtonsY) do for _,button in ipairs(row) do assert(button:isVisible(),'hidden/inapplicable setting in controller rows') end end
p.global.onclick(p);p.confirm.onclick(p);assert(commands[3].args.action=='confirm' and commands[3].args.value==false)
local modal;local confirm=Q.ShoppingAddUI.confirm
Q.ShoppingAddUI.confirm=function(...) modal=confirm(...);return modal end
p.reset.onclick(p);assert(modal.yes.title==getText('UI_QMSS_ResetAllPreferences') and #commands==3)
modal.no:forceClick();assert(#commands==3,'Cancel reset mutated preferences')
p.reset.onclick(p);assert(#commands==3)
p:close();assert(p.closed)
print('PASS OFFLINE settings UI: global versus applicable item fields, explicit ANY/inheritance, remove/reset visibility, hidden-controller exclusion, reset confirmation, personal intent/revision and no item spawning')
