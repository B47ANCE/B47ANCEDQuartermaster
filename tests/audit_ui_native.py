"""Read-only native ISUI contract inventory. Source evidence, not runtime proof."""
from pathlib import Path
import hashlib,json,argparse
root=Path(r'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\media\lua\client\ISUI')
contracts={
 'ISUIElement.lua':['function ISUIElement:setAnchorsTBLR','function ISUIElement:setWidth','function ISUIElement:setHeight'],
 'ISScrollBar.lua':['anchorRight = true','anchorBottom = true'],
 'ISCollapsableWindow.lua':['if self.drawFrame then','and self.drawFrame and'],
 'ISButton.lua':['function ISButton:prerender','function ISButton:render','backgroundColorMouseOver','tooltipUI'],
 'ISPanelJoypad.lua':['function ISPanelJoypad:insertNewLineOfButtons','function ISPanelJoypad:onJoypadDown','joypadButtonsY'],
 'ISModalDialog.lua':['function ISModalDialog:onGainJoypadFocus','self:setISButtonForA(self.yes)','function ISModalDialog:destroy'],
 'ISScrollingListBox.lua':['doDrawItem','itemheight','vscroll'],
 'ISTextBox.lua':['function ISTextBox:onGainJoypadFocus','self.entry','function ISTextBox:destroy'],
 'ISComboBox.lua':['function ISComboBox:addOption','function ISComboBox:clear'],
 'ISLabel.lua':['function ISLabel:prerender','self.translation'],
 'ISCollapsableWindowJoypad.lua':['ISCollapsableWindowJoypad','ISPanelJoypad:derive']}
report={'evidence':'VERIFIED native Lua source contracts; runtime NOT TESTED','files':{}}
for name,symbols in contracts.items():
 path=root/name;code=path.read_text(encoding='utf-8')
 for symbol in symbols: assert symbol in code,(name,symbol)
 report['files'][name]={'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'symbols':symbols}
parser=argparse.ArgumentParser();parser.add_argument('--ui',type=Path,required=True);args=parser.parse_args()
project=args.ui
assert (project/'src/B47ANCEDUI/42/media/lua/client/B47ANCEDUI/API.lua').is_file()
for path in (project/'src/B47ANCEDUI/42/media/lua/client/B47ANCEDUI').glob('*.lua'):
 code=path.read_text(encoding='utf-8')
 assert 'B47ANCEDQuartermaster' not in code and 'sendClientCommand' not in code and 'getSpecificPlayer' not in code,path
print(json.dumps(report,indent=2))
