"""Host regression and packaging checks. Never starts or deploys to Project Zomboid."""
import argparse
import hashlib
import json
import re
from pathlib import Path
import sys
import struct
import random
import zipfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.test-deps'))
from lupa.lua51 import LuaRuntime

PARSER = argparse.ArgumentParser()
PARSER.add_argument('--quartermaster', type=Path, default=Path(r'E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\3761216758\mods\Quartermaster\42'))
PARSER.add_argument('--package', action='store_true')
PARSER.add_argument('--rooms', type=Path, default=ROOT.parent / 'B47ANCEDRooms', help='Standalone Rooms checkout for paired production integration tests')
PARSER.add_argument('--require-rooms', action='store_true', help='Fail instead of reporting unavailable paired integration')
ARGS = PARSER.parse_args()
SOURCE = ROOT / 'src' / 'B47ANCEDQuartermaster'
CLIENT = SOURCE / '42/media/lua/client'
upstream = ARGS.quartermaster
before = {p: hashlib.sha256(p.read_bytes()).hexdigest() for p in upstream.rglob('*') if p.is_file()}

def runtime():
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().package.path = str(CLIENT.as_posix()) + '/?.lua;' + (SOURCE / '42/media/lua/shared').as_posix() + '/?.lua;' + lua.globals().package.path
    lua.globals().TEST_ROOT = (ROOT / 'tests').as_posix()
    lua.globals().ROOMS_SOURCE = (ARGS.rooms / 'src/B47ANCEDRooms/42/media/lua').as_posix()
    lua.globals().GAME_ROOT = 'E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid'
    lua.execute("getActivatedMods=function() return {size=function() return 1 end,get=function() return 'B47ANCEDQuartermaster' end} end")
    return lua

for path in (SOURCE / '42/media/lua').rglob('*.lua'):
    runtime().execute('assert(loadstring(...))', path.read_text(encoding='utf-8'))
print('PASS Lua 5.1 syntax')
runtime().execute((ROOT / 'tests/test_native_categories.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_sorting_data_cleanup.lua').read_text(encoding='utf-8'))
# Embedded 0.7 room tests remain historical; standalone production tests live in Rooms.
runtime().execute((ROOT / 'tests/test_room_preferences.lua').read_text(encoding='utf-8'))
if (ARGS.rooms / 'src/B47ANCEDRooms/42/media/lua/shared/B47ANCEDRooms/API.lua').is_file():
    runtime().execute((ROOT / 'tests/test_rooms_integration.lua').read_text(encoding='utf-8'))
elif ARGS.require_rooms:
    raise SystemExit('Required standalone Rooms checkout is unavailable: ' + str(ARGS.rooms))
else:
    print('NOT TESTED paired Rooms integration: no standalone checkout; Quartermaster-only regressions continue')
runtime().execute((ROOT / 'tests/test_move_batch.lua').read_text(encoding='utf-8'))
for path in (SOURCE / '42/media/lua/shared/B47ANCEDQuartermaster/Movement.lua', SOURCE / '42/media/lua/shared/B47ANCEDQuartermaster/Trips.lua', CLIENT / 'B47ANCEDQuartermaster/Executor.lua', CLIENT / 'B47ANCEDQuartermaster/Sorter.lua', CLIENT / 'B47ANCEDQuartermaster/SortControls.lua', SOURCE / '42/media/lua/shared/B47ANCEDQuartermaster/GroundSources.lua'):
    owned = path.read_text(encoding='utf-8')
    assert 'LootSorter' not in owned and 'require "LootSorter' not in owned
    assert not re.search(r':(?:Remove|AddItem|addItem|removeItemWithID)\s*\(', owned), path
for name in ('test_model.lua', 'test_ownership.lua', 'test_bulk_model.lua', 'test_integration.lua', 'test_containers.lua', 'test_container_ui.lua', 'test_transport.lua', 'test_standalone_schema.lua', 'test_bindings.lua', 'test_standalone_authority.lua', 'test_planner.lua', 'test_native_probe.lua', 'test_movement.lua', 'test_identity_migration.lua', 'test_presets.lua', 'test_consolidated.lua'):
    runtime().execute((ROOT / 'tests' / name).read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev13_compatibility.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev13_highlight.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev13_rejected_startup.lua').read_text(encoding='utf-8'))
# Historical retired inventory-interception contract retained in tests/test_dev14_inventory_category.lua
# Historical retired inventory-interception contract retained in tests/test_dev30_category_model.lua
runtime().execute((ROOT / 'tests/test_dev15_grouping.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev15_ui_options.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_shopping_ui.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_ui_framework.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev28_layout.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev29_appearance.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_row_tooltip.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_container_sprite.lua').read_text(encoding='utf-8'))
print('PASS dev23 container sprite: 30 physical identity/frame/sibling cases plus invalidation/fallback/diagnostic bounds (offline)')
runtime().execute((ROOT / 'tests/test_open_performance.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_collector.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_recipe_shopping.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_item_picker.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_wish_cooking.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_cook_ui.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_shopping_safety.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_shopping_add_ui.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_shopping_preferences_ui.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_shopping_recipe_safety.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_shopping_evolved_safety.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev18_remediation.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev18_ui.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev47_audit.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev19_trace.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev27_routes.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev27_tooltips.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev26_scopes.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev26_furniture.lua').read_text(encoding='utf-8'))
runtime().execute((ROOT / 'tests/test_dev25_ground.lua').read_text(encoding='utf-8'))
pipeline_runtime=runtime();pipeline_runtime.globals().DEV25_GROUND=True
pipeline_runtime.execute((ROOT / 'tests/test_dev24_pipeline.lua').read_text(encoding='utf-8'))
native_lifecycle=runtime();native_lifecycle.globals().DEV47_NATIVE_TRANSACTIONS=True
native_lifecycle.execute((ROOT / 'tests/test_dev24_pipeline.lua').read_text(encoding='utf-8'))
# Independent binary32 oracle for the verified native regular/spice operations.
arithmetic=runtime()
arithmetic.execute("require 'B47ANCEDQuartermaster/EvolvedRequirements'; instanceof=function() return true end")
capacity=arithmetic.eval("function(h,use,class,skill) local i={getHungChange=function() return h end,isBurnt=function() return false end,isRotten=function() return false end,isCooked=function() return false end,isFrozen=function() return false end,getFluidContainer=function() end,getAge=function() return 0 end,getOffAge=function() return 10 end};return B47ANCEDQuartermaster.EvolvedRequirements.capacity(i,use,class,skill) end")
def f32(n): return struct.unpack('f',struct.pack('f',n))[0]
random_source=random.Random(4003)
for _ in range(1000):
    h=f32(-random_source.randint(1,100)/100);use=random_source.randint(1,25);skill=random_source.randint(0,10)
    for kind in ('ingredient','seasoning'):
        portion=f32(use/100);step=portion if kind=='seasoning' else f32(portion-f32(f32(3*skill/100)*portion))
        value=h;count=0
        while -value>=portion and count<256:
            count+=1;value=f32(value+step)
            if (kind=='ingredient' and value>=-0.02) or (kind=='seasoning' and value>-0.01): break
        if count==256 and -value>=portion: count=0
        assert capacity(h,use,kind,skill)==count,(h,use,kind,skill,count)
print('PASS OFFLINE 2,000 native-shaped portion cases against independent binary32 oracle; not native execution')
for name in ('ItemPicker.lua','ItemCatalog.lua'):
    code=(CLIENT / 'B47ANCEDQuartermaster' / name).read_text(encoding='utf-8')
    assert not re.search(r'instanceItem|AddItem|GiveItem|/additem|SendCommandToServer',code), name

locales = set('AR CA CH CN CS DA DE EN ES ES_CL ES_MX FI FR HU ID IT JP KO NL NO PL PT PTBR RO RU STREW TH TR UA'.split())
translation_root = SOURCE / '42/media/lua/shared/Translate'
assert {p.name for p in translation_root.iterdir()} == locales
english = json.loads((translation_root / 'EN/UI.json').read_text(encoding='utf-8'))
labels = runtime().eval("require('B47ANCEDQuartermaster/Categorizer').labels")
for short in labels:
    assert 'UI_B47_Category_' + short in english, f'Missing category translation: {short}'
for path in (SOURCE / '42/media/lua').rglob('*.lua'):
    code = path.read_text(encoding='utf-8')
    assert not re.search(r'\b(?:BSgetCategory|BSupdateMedia)\b', code), f'Foreign categorizer dependency: {path}'
    if path.name != 'Compatibility.lua':
        assert 'BetterSortCC' not in code, f'External Mod ID used outside the conflict boundary: {path}'
    for key in re.findall(r"tr\('([^']+)'\)", code):
        assert 'UI_QMSS_' + key in english, f'Missing translation: {key}'
    for key in re.findall(r"getText\('(UI_QMSS_[^']+)'\)", code):
        assert key in english, f'Missing translation: {key}'
for key in ('full','partial','none','SelectItems','ClearItems','InvertItems','SelectVisible','ClearVisible',
            'InvertVisible','ExpandAll','CollapseAll','ExpandCategory','CollapseCategory','ExpandMod',
            'CollapseMod','VisibleList','Range','SetAnchor','ApplyRange'):
    assert 'UI_QMSS_' + key in english
for locale in locales:
    assert json.loads((translation_root / locale / 'UI.json').read_text(encoding='utf-8')) == english
    assert json.loads((translation_root / locale / 'Sandbox.json').read_text(encoding='utf-8')) == json.loads((translation_root / 'EN/Sandbox.json').read_text(encoding='utf-8'))
version = (ROOT / 'VERSION').read_text(encoding='utf-8').strip()
metadata = (SOURCE / '42/mod.info').read_text(encoding='utf-8')
assert 'id=B47ANCEDQuartermaster\n' in metadata
assert "name=B47ANCE'd Quartermaster\n" in metadata
assert 'modversion=' + version in metadata
assert (ROOT / 'WORKSHOP_ID.txt').read_text(encoding='utf-8').strip() == '3807217050'
for path in (SOURCE / '42').rglob('*'):
    if path.suffix in ('.lua', '.info', '.txt', '.json'):
        code = path.read_text(encoding='utf-8')
        if path.name not in {'Migration.lua', 'SortingData.lua'}:
            assert not re.search(r'QuartermasterSimpleSorting|QuartermasterSorting|B47ANCEDSorting', code), path
        if path.suffix == '.lua':
            assert not re.search(r'(?<![\w:.])next\s*\(', code), path
assert re.findall(r'^require=(.*)$', metadata, re.M) == ['B47ANCEDRooms']
for path in (SOURCE / '42/media/lua').rglob('*.lua'):
    assert 'LootSorter' not in path.read_text(encoding='utf-8'), path
# Upstream is optional: no production or test Lua is loaded from it.
print('PASS metadata and 29-language fallback parity')
import runpy
runpy.run_path(str(ROOT / 'tests/test_runtime_directories.py'))['run']()
runpy.run_path(str(ROOT / 'tests/test_workshop_corpus.py'))

if ARGS.package:
    sys.path.insert(0, str(ROOT / 'scripts'))
    from runtime_directories import ensure
    ensure(SOURCE)
    from check_deployment import validate
    validate()
    dist = ROOT / 'dist/current'
    dist.mkdir(parents=True, exist_ok=True)
    archive = dist / ('B47ANCEDQuartermaster-' + (ROOT / 'VERSION').read_text(encoding='utf-8').strip() + '.zip')
    expected = {}
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('B47ANCEDQuartermaster/common/', b'')
        for relative in ('common/media/AnimSets','common/media/actiongroups','42/media/AnimSets','42/media/actiongroups'):
            assert (SOURCE / relative).is_dir(), relative
            z.writestr('B47ANCEDQuartermaster/' + relative + '/', b'')
        for path in sorted(SOURCE.rglob('*')):
            if path.is_file():
                name = 'B47ANCEDQuartermaster/' + path.relative_to(SOURCE).as_posix()
                expected[name] = path.read_bytes()
                z.writestr(name, expected[name])
    with zipfile.ZipFile(archive) as z:
        assert len(z.namelist()) == len(set(z.namelist()))
        assert {n for n in z.namelist() if not n.endswith('/')} == set(expected)
        for name, data in expected.items():
            assert z.read(name) == data
    print(f'PASS archive byte parity: {len(expected)} files; {archive.name}')
    (dist / (archive.name + '.sha256')).write_text(hashlib.sha256(archive.read_bytes()).hexdigest() + '  ' + archive.name + '\n')

assert before == {p: hashlib.sha256(p.read_bytes()).hexdigest() for p in upstream.rglob('*') if p.is_file()}
print('PASS upstream files unchanged; native and multiplayer acceptance remain UNVERIFIED')
