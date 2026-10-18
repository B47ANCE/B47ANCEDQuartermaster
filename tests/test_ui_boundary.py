"""Public provider/dependency/source boundary checks; no PZ execution."""
from pathlib import Path
import argparse,json,re,sys
from lupa.lua51 import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]
def run(ui):
    source=ROOT/'src/B47ANCEDQuartermaster/42'
    client=source/'media/lua/client'
    assert not (client/'B47ANCEDUI').exists(),'Embedded provider still shipped'
    required=re.findall(r'^require=(.*)$',(source/'mod.info').read_text(),re.M)
    assert required==['B47ANCEDRooms,B47ANCEDPCFramework,B47ANCEDUI']
    assert (ui/'src/B47ANCEDUI/42/media/lua/client/B47ANCEDUI/API.lua').is_file()
    provider=(client/'B47ANCEDQuartermaster/UIProvider.lua').read_text()
    assert "require 'B47ANCEDUI/API'" in provider and 'requireVersion(1)' in provider
    for p in (client/'B47ANCEDQuartermaster').glob('*.lua'):
        for module in re.findall(r"require\s*\(?\s*['\"](B47ANCEDUI/[^'\"]+)",p.read_text()):
            assert module=='B47ANCEDUI/API' and p.name=='UIProvider.lua',(p,module)
    for p in source.rglob('*.lua'): LuaRuntime().execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
    assert not any('/B47ANCEDUI/' in p for p in json.loads((ROOT/'scripts/production-files.json').read_text()))
    print('PASS OFFLINE required UI dependency, one public API boundary, no bundled implementation and Quartermaster Lua 5.1 syntax')
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--ui',type=Path,required=True)
    run(parser.parse_args().ui)
