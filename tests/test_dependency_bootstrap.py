"""Shared-phase load contract and declared dependency graph (offline only)."""
import json
import re

metadata = (SOURCE / '42/mod.info').read_text(encoding='utf-8')
assert re.findall(r'^require=(.*)$', metadata, re.M) == ['B47ANCEDRooms,B47ANCEDPCFramework,B47ANCEDUI']
shared = (SOURCE / '42/media/lua/shared/B47ANCEDQuartermasterLedger.lua').read_text(encoding='utf-8')
client = (SOURCE / '42/media/lua/client/B47ANCEDQuartermasterLedgerClient.lua').read_text(encoding='utf-8')
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("isServer=function() return false end; package.loaded['B47ANCEDQuartermaster/LedgerPolicy']={}; package.loaded['B47ANCEDQuartermaster/LedgerAction']={}")
lua.execute(shared)  # Client modules deliberately unavailable in this phase.
assert "require 'B47ANCEDQuartermaster/LedgerUI'" in client
assert "require 'B47ANCEDQuartermaster/ShoppingPaperHUD'" in client
for locale in (SOURCE / '42/media/lua/shared/Translate').iterdir():
    sandbox = json.loads((locale / 'Sandbox.json').read_text(encoding='utf-8'))
    for key in ('PrimaryOverflowAt', 'PrimaryOverflowAt_tooltip', 'SecondaryReturnAt', 'SecondaryReturnAt_tooltip'):
        assert '%' not in sandbox['Sandbox_B47ANCEDQuartermaster_' + key], (locale, key)
if (ARGS.rooms / 'src/B47ANCEDRooms/42/mod.info').is_file():
    rooms_info = (ARGS.rooms / 'src/B47ANCEDRooms/42/mod.info').read_text(encoding='utf-8')
    assert re.findall(r'^require=(.*)$', rooms_info, re.M) == ['B47ANCEDUI']
assert not re.findall(r'^require=', (ARGS.ui / 'src/B47ANCEDUI/42/mod.info').read_text(encoding='utf-8'), re.M)
assert not re.findall(r'^require=', (ARGS.pc_framework / 'src/B47ANCEDPCFramework/42/mod.info').read_text(encoding='utf-8'), re.M)
print('PASS OFFLINE shared-phase ledger bootstrap, dependency graph and sandbox format strings')
