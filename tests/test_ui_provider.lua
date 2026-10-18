dofile(TEST_ROOT..'/test_shopping_ui.lua')
local Q=B47ANCEDQuartermaster
local API=require 'B47ANCEDUI/API'
local UI=require 'B47ANCEDQuartermaster/UIProvider'
assert(API.apiVersion==1 and UI.consumerID=='B47ANCEDQuartermaster')
assert(Q.UIProvider==UI and require('B47ANCEDQuartermaster/UIProvider')==UI)
assert(Q.UIProvider.Theme==API.Theme and Q.UIProvider.Renderer==API.Renderer)
assert(Q.UIProvider.AppearanceEditor~=nil and Q.UIProvider.Clipboard==API.Clipboard)
assert(Q.picker.b47AppearanceScope=='B47ANCEDQuartermaster','Picker did not consume scoped UI')
local before=UI.Appearance.get(0)
local unrelated=API.forMod('IndependentConsumer');unrelated.Appearance.set(0,25)
assert(UI.Appearance.get(0)==before,'Another consumer overwrote Quartermaster appearance')
assert(not pcall(API.requireVersion,99),'Incompatible API accepted')
print('PASS OFFLINE Quartermaster uses required public API and isolated appearance; native/dedicated NOT TESTED')
