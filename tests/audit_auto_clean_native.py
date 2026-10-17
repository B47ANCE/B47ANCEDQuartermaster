"""Auto Clean installed-source contracts; never starts Java, PZ, or a server.

Lua callbacks run under Lua 5.1 with explicit test doubles. Bytecode is parsed,
not executed. Passing tests include reproductions of unsafe native contracts;
they do not certify authority, conservation, networking, or save/load behavior.
"""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess
import sys
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.test-deps'))
from jawa.cf import ClassFile
from lupa.lua51 import LuaRuntime

PARSER = argparse.ArgumentParser(description=__doc__)
PARSER.add_argument('--game', type=Path, required=True)
PARSER.add_argument('--write-evidence', type=Path)
PARSER.add_argument('--verify-evidence', type=Path)
ARGS = PARSER.parse_args()
GAME = ARGS.game.resolve()
LUA = 'media/lua/'
GAME_FILES = [
    LUA + 'shared/TimedActions/' + name + '.lua' for name in (
        'ISCleanBlood', 'ISCleanGraffiti', 'ISClearAshes', 'ISCleanBandage',
        'ISTakeWaterAction', 'ISBaseTimedAction', 'ISAddFluidFromItemAction')
] + [
    LUA + 'shared/Fluids/' + name + '.lua' for name in (
        'ISFluidContainer', 'ISFluidTransferAction', 'ISFluidUtil')
] + [
    LUA + 'server/BuildingObjects/ISCleanBloodCursor.lua',
    LUA + 'server/BuildingObjects/ISCleanGraffitiCursor.lua',
    LUA + 'client/ISUI/ISWorldObjectContextMenu.lua',
    LUA + 'client/Fluids/ISFluidTransferUI.lua',
    LUA + 'client/TimedActions/ISInventoryTransferAction.lua',
    LUA + 'client/TimedActions/WalkToTimedAction.lua',
    LUA + 'shared/Vehicles/TimedActions/ISWashVehicle.lua',
    LUA + 'shared/Defines.lua',
    'media/scripts/generated/items/normal.txt',
    'media/scripts/generated/items/drainable.txt',
    'media/scripts/generated/items/weapon.txt',
    'media/scripts/generated/fluids.txt',
    'ProjectZomboid64.json',
]
PROJECT_LUA = 'src/B47ANCEDQuartermaster/42/media/lua/'
PROJECT_FILES = ['VERSION', 'version-inventory.json', 'docs/CUSTOM_ROOMS.md'] + [
    PROJECT_LUA + 'shared/B47ANCEDQuartermaster/' + name + '.lua' for name in (
        'Rooms', 'RoomGeometry', 'RoomDetection', 'Bindings', 'Targets',
        'Movement', 'Trips', 'Shopping', 'Dibs', 'Route', 'Protocol',
        'Authority', 'Identity', 'Schema')
] + [PROJECT_LUA + 'client/B47ANCEDQuartermaster/Executor.lua']
CLASSES = {
    'zombie/core/Core': ['<clinit>'],
    'zombie/core/GameVersion': ['<init>', 'toString'],
    'zombie/core/NetTimedAction': ['set', 'parse', 'perform', 'start', 'stop',
                                   'isValid', 'isConsistent', 'update'],
    'zombie/core/Action': ['isConsistent'],
    'zombie/core/ActionManager': ['update', 'createNetTimedAction', 'remove'],
    'zombie/characters/CharacterTimedActions/LuaTimedActionNew': [
        'valid', 'complete', 'perform', 'start', 'update', 'stop'],
    'zombie/network/packets/NetTimedActionPacket': ['processServer', 'processClient'],
    'zombie/entity/components/fluids/FluidContainer': [
        'contains', 'getSpecificFluidAmount', 'getRatioForFluid', 'getAmount',
        'getCapacity', 'isEmpty', 'isFull', 'adjustAmount', 'removeFluidInstanceIfEmpty', 'addFluid',
        'CanTransfer', 'Transfer', 'canAddFluid', 'recalculateCaches',
        'save', 'load', 'saveSyncData', 'loadSyncData'],
    'zombie/entity/components/fluids/FluidInstance': ['save', 'load', 'setAmount'],
    'zombie/entity/components/fluids/FluidUtil': ['roundTransfer'],
    'zombie/entity/components/fluids/Fluid': ['canBlendWith'],
    'zombie/entity/components/fluids/FluidFilter': ['allows'],
    'zombie/core/math/PZMath': ['equal'],
    'zombie/iso/IsoGridSquare': ['haveBlood', 'haveBloodFloor', 'haveBloodWall',
                               'haveGrime', 'haveGrimeFloor', 'haveGrimeWall', 'haveStains',
                               'haveGraffiti', 'getGraffitiObject',
                               'removeBlood', 'removeGrime', 'removeGraffiti'],
    'zombie/iso/IsoObject': ['hasFluid', 'getFluidAmount', 'transferFluidTo', 'sync'],
    'zombie/inventory/InventoryItem': ['syncItemFields'],
    'zombie/inventory/ItemContainer': ['containsTagEval', 'containsTagEvalRecurse',
                                     'getFirstTagEval', 'getFirstTagEvalRecurse', 'getFirstRecurse'],
    'zombie/network/packets/SyncItemFieldsPacket': ['write', 'parse', 'processClient'],
    'zombie/network/packets/actions/RemoveBloodPacket': ['processClient', 'isConsistent'],
    'zombie/Lua/LuaManager$Exposer': ['exposeAll'],
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def text(path):
    return path.read_text(encoding='utf-8-sig')


def instructions(cf, method):
    """Resolve pool indexes; retain offsets without copying method bodies to JSON."""
    result = []
    for ins in method.code.disassemble() if method.code else []:
        operands = []
        for index, operand in enumerate(ins.operands):
            if isinstance(operand, dict):
                value = repr(operand)
            elif operand.op_type.name == 'CONSTANT_INDEX' or (index == 0 and ins.mnemonic in (
                    'anewarray', 'checkcast', 'instanceof', 'new', 'multianewarray')):
                value = cf.constants.get(operand.value)
                if hasattr(value, 'class_') and hasattr(value, 'name_and_type'):
                    value = (value.class_.name.value + '.' + value.name_and_type.name.value
                             + ':' + value.name_and_type.descriptor.value)
                elif hasattr(value, 'string'):
                    value = value.string.value
                elif hasattr(value, 'name'):
                    value = value.name.value
                elif hasattr(value, 'value'):
                    value = value.value
                else:
                    value = repr(value)
            else:
                value = operand.value
            operands.append(value)
        result.append((ins.pos, ins.mnemonic, operands))
    return result


METHODS = {}
EVIDENCE = {'date': '2026-10-14 America/Phoenix',
            'environment': 'Installed source + parsed bytecode + Lua 5.1 test doubles; no PZ runtime',
            'projectVersionObserved': text(ROOT / 'VERSION').strip(),
            'head': subprocess.check_output(['git', '-C', str(ROOT), 'rev-parse', 'HEAD']).decode().strip(),
            'dirtyBaseline': True, 'jarSha256': sha((GAME / 'projectzomboid.jar').read_bytes()),
            'gameFiles': {p: sha((GAME / p).read_bytes()) for p in GAME_FILES},
            'projectFiles': {p: sha((ROOT / p).read_bytes()) for p in PROJECT_FILES},
            'classes': {}}
with zipfile.ZipFile(GAME / 'projectzomboid.jar') as archive:
    for name, selected in CLASSES.items():
        member = name + '.class'
        jar_data = archive.read(member)
        loose_path = GAME / member
        data = loose_path.read_bytes() if loose_path.is_file() else jar_data
        cf = ClassFile(io.BytesIO(data))
        jar_cf = ClassFile(io.BytesIO(jar_data))
        record = {'jarSha256': sha(jar_data), 'effectiveSha256': sha(data),
                  'resolution': 'loose class before JAR' if loose_path.is_file() else 'JAR',
                  'looseDiffers': data != jar_data, 'methods': []}
        for method in cf.methods:
            if method.name.value not in selected:
                continue
            rows = instructions(cf, method)
            key = (name, method.name.value, method.descriptor.value)
            METHODS[key] = rows
            jar_method = next(m for m in jar_cf.methods
                              if m.name.value == method.name.value and m.descriptor.value == method.descriptor.value)
            references = [{'offset': pos, 'op': op, 'value': values[0]}
                          for pos, op, values in rows
                          if values and (op.startswith(('invoke', 'get', 'put', 'ldc')))]
            if name == 'zombie/core/Core':
                references = [r for r in references if r['offset'] <= 17]
            if name == 'zombie/Lua/LuaManager$Exposer':
                references = [r for r in references if any(token in str(r['value']) for token in (
                    'FluidContainer', 'FluidInstance', 'NetTimedAction', 'IsoGridSquare',
                    'IsoObject', 'LuaTimedActionNew'))]
            record['methods'].append({'name': method.name.value, 'descriptor': method.descriptor.value,
                                      'normalizedSha256': sha(json.dumps(rows).encode()),
                                      'sameInstructionsAsJar': rows == instructions(jar_cf, jar_method),
                                      'references': references})
        EVIDENCE['classes'][member] = record


def rows(name, method, descriptor=None):
    found = [v for (c, m, d), v in METHODS.items()
             if c == name and m == method and (descriptor is None or descriptor == d)]
    if len(found) != 1:
        raise AssertionError((name, method, descriptor, len(found)))
    return found[0]


def refs(name, method, descriptor=None):
    return ' '.join(str(v) for _, _, operands in rows(name, method, descriptor) for v in operands)


FC = 'zombie/entity/components/fluids/FluidContainer'
BOOT = r'''
require=function() end
ISBaseTimedAction={}
function ISBaseTimedAction:derive(name) local o={Type=name};o.__index=o;setmetatable(o,{__index=self});return o end
function ISBaseTimedAction.new(self,c) return setmetatable({character=c},{__index=self}) end
function ISBaseTimedAction.perform(self) self.queueFinished=true end
function ISBaseTimedAction.stop(self) self.stopped=true end
Fluid={Bleach='Bleach',CleaningLiquid='CleaningLiquid'}
ItemTag={CLEAN_STAINS='clean'}
function item(amount,kind,tool,broken)
 local f={amount=amount,kind=kind,changes=0}
 function f:contains(k) return self.kind==k end
 function f:getAmount() return self.amount end
 function f:adjustAmount(a) self.amount=a;self.changes=self.changes+1 end
 local i={f=f,tool=tool,broken=broken,syncs=0}
 function i:getFluidContainer() return self.f end
 function i:isBroken() return self.broken==true end
 function i:hasTag(t) return self.tool==true end
 function i:syncItemFields() self.syncs=self.syncs+1 end
 return i
end
function actor(items,nested)
 local inv={items=items,nested=nested or {}}
 function inv:containsEvalRecurse(p) for _,list in ipairs({self.items,self.nested}) do for _,i in ipairs(list) do if p(i) then return true end end end;return false end
 function inv:containsTagEval(t,p) for _,list in ipairs({self.items,self.nested}) do for _,i in ipairs(list) do if i:hasTag(t) and p(i) then return true end end end;return false end
 local c={}
 function c:getInventory() return inv end
 function c:isTimedActionInstant() return false end
 function c:stopOrTriggerSound() end
 return c
end
function target() return {bloodCalls=0,grimeCalls=0,removeBlood=function(s,a,b) assert(a==false and b==false);s.bloodCalls=s.bloodCalls+1 end,removeGrime=function(s) s.grimeCalls=s.grimeCalls+1 end} end
'''


class Contracts(unittest.TestCase):
    def lua(self, code):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute(BOOT)
        defines = text(GAME / (LUA + 'shared/Defines.lua'))
        amount = float(re.search(r'CleanBloodBleachAmount\s*=\s*([\d.]+)', defines)[1])
        lua.globals().ZomboidGlobals = lua.table_from({'CleanBloodBleachAmount': amount})
        lua.execute(text(GAME / (LUA + 'shared/TimedActions/ISCleanBlood.lua')))
        lua.execute(code)

    def test_01_build_and_constructor(self):
        core = rows('zombie/core/Core', '<clinit>')
        self.assertEqual([r[2][0] for r in core if r[1] == 'bipush'][:2], [42, 21])
        self.assertIn('function ISCleanBlood:new(character, square, cleaner)', text(GAME / (LUA + 'shared/TimedActions/ISCleanBlood.lua')))
        self.lua('local c=actor({});local s=target();local i=item(1,"Bleach");local a=ISCleanBlood:new(c,s,i);assert(a.square==s and a.cleaner==i and a.maxTime==150)')

    def test_02_water_alone_rejected(self):
        self.lua('assert(not ISCleanBlood:new(actor({item(1,"Water"),item(0,nil,true)}),target(),nil):isValid())')

    def test_03_measured_mixture_candidates(self):
        # Fluid membership is a test double; Java mixing itself is NOT executed.
        self.lua('for _,ml in ipairs({1,5,10,25}) do local i=item(1+ml/1000,"Bleach");assert(ISCleanBlood:new(actor({i,item(0,nil,true)}),target(),i):isValid()) end')

    def test_04_total_threshold(self):
        self.lua('local t=ZomboidGlobals.CleanBloodBleachAmount;for _,v in ipairs({t-0.00001,t,t+0.00001}) do local i=item(v,"Bleach");assert(ISCleanBlood:new(actor({i,item(0,nil,true)}),target(),i):isValid()==(v>=t)) end')

    def test_05_cleaning_liquid_alternative(self):
        self.lua('local i=item(0.5,"CleaningLiquid");assert(ISCleanBlood:new(actor({i,item(0,nil,true)}),target(),i):isValid())')

    def test_06_tool_and_broken_tool(self):
        self.lua('local i=item(1,"Bleach");assert(not ISCleanBlood:new(actor({i}),target(),i):isValid());assert(not ISCleanBlood:new(actor({i,item(0,nil,true,true)}),target(),i):isValid())')

    def test_07_nested_tool_native_recursion(self):
        self.lua('local i=item(1,"Bleach");assert(ISCleanBlood:new(actor({i},{item(0,nil,true)}),target(),i):isValid())')
        self.assertIn('containsTagEvalRecurse(ItemTag.CLEAN_STAINS', text(GAME / (LUA + 'client/ISUI/ISWorldObjectContextMenu.lua')))
        self.assertIn('getFirstTagEval', refs('zombie/inventory/ItemContainer', 'containsTagEval'))
        self.assertIn('getFirstRecurse', refs('zombie/inventory/ItemContainer', 'getFirstTagEval'))
        self.assertIn('InventoryContainer.getInventory', refs('zombie/inventory/ItemContainer', 'getFirstRecurse'))

    def test_08_target_not_revalidated_gap(self):
        self.lua('local i=item(1,"Bleach");assert(ISCleanBlood:new(actor({i,item(0,nil,true)}),nil,i):isValid())')

    def test_09_stale_cleaner_reference_gap(self):
        self.lua('local other=item(1,"Bleach");local stale=item(0.5,"Water");local a=ISCleanBlood:new(actor({other,item(0,nil,true)}),target(),stale);assert(a:isValid());assert(a:complete());assert(stale.f.amount<0.5 and other.f.amount==1)')

    def test_10_native_completion_and_client_queue(self):
        self.lua('local i=item(1,"Bleach");local s=target();local a=ISCleanBlood:new(actor({}),s,i);a:perform();assert(i.f.amount==1 and s.bloodCalls==0 and a.queueFinished);assert(a:complete());assert(math.abs(i.f.amount-(1-ZomboidGlobals.CleanBloodBleachAmount))<1e-10 and i.syncs==1 and s.bloodCalls==1 and s.grimeCalls==1)')

    def test_11_cancellation_no_clean_callback_mutation(self):
        self.lua('local i=item(1,"Bleach");local s=target();local a=ISCleanBlood:new(actor({}),s,i);a:stop();assert(i.f.amount==1 and s.bloodCalls==0 and a.stopped)')

    def test_12_duplicate_completion_not_rejected_gap(self):
        self.lua('local i=item(1,"Bleach");local s=target();local a=ISCleanBlood:new(actor({}),s,i);a:complete();a:complete();assert(i.f.changes==2 and s.bloodCalls==2)')

    def test_13_nil_cleaner_gap(self):
        self.lua('local s=target();assert(ISCleanBlood:new(actor({}),s,nil):complete());assert(s.bloodCalls==1)')

    def test_14_membership_has_no_concentration_threshold(self):
        value = refs(FC, 'contains')
        self.assertIn('FluidInstance.getFluid', value)
        self.assertNotIn('getAmount', value)
        self.assertNotIn('getPercentage', value)
        self.assertIn('FluidInstance.getAmount', refs(FC, 'getSpecificFluidAmount'))

    def test_15_precision_and_proportional_consumption(self):
        self.assertIn('9.999999747378752e-05', refs(FC, 'removeFluidInstanceIfEmpty'))
        self.assertIn('FluidInstance.setAmount', refs(FC, 'adjustAmount'))
        self.assertTrue(any(op == 'fmul' for _, op, _ in rows(FC, 'adjustAmount')))
        self.assertIn('100.0', refs('zombie/entity/components/fluids/FluidUtil', 'roundTransfer'))
        self.assertIn('java/lang/Math.round', refs('zombie/entity/components/fluids/FluidUtil', 'roundTransfer'))

    def test_16_transfer_conservation_mechanism_not_runtime(self):
        value = refs(FC, 'Transfer', '(Lzombie/entity/components/fluids/FluidContainer;Lzombie/entity/components/fluids/FluidContainer;FZ)V')
        for symbol in ('CanTransfer', 'getCapacity', 'PZMath.min', 'FluidInstance.getPercentage', 'addFluid', 'FluidInstance.setAmount'):
            self.assertIn(symbol, value)
        self.assertIn('canBlendWith', refs(FC, 'canAddFluid'))

    def test_17_server_dispatch_gap_and_native_hook(self):
        self.assertIn('complete', refs('zombie/core/NetTimedAction', 'perform'))
        self.assertIn('serverStart', refs('zombie/core/NetTimedAction', 'start'))
        self.assertIn('serverStop', refs('zombie/core/NetTimedAction', 'stop'))
        self.assertNotIn('isValid', refs('zombie/core/NetTimedAction', 'perform'))
        self.assertNotIn('isValid', refs('zombie/core/ActionManager', 'update'))
        self.assertIn('playerId', refs('zombie/core/Action', 'isConsistent'))

    def test_18_world_replication_and_fluid_persistence(self):
        self.assertIn('INetworkPacket.sendToRelative', refs('zombie/iso/IsoGridSquare', 'removeBlood'))
        self.assertIn('transmitUpdatedSpriteToClients', refs('zombie/iso/IsoGridSquare', 'removeGrime'))
        self.assertIn('FluidInstance.save', refs(FC, 'save'))
        self.assertIn('FluidInstance.load', refs(FC, 'load'))
        self.assertIn('FluidContainer.save', refs('zombie/network/packets/SyncItemFieldsPacket', 'write'))

    def test_19_fill_constructor_and_stale_source_gap(self):
        value = text(GAME / (LUA + 'shared/TimedActions/ISTakeWaterAction.lua'))
        self.assertIn('new(character, item, waterObject, waterTaintedCL)', value)
        self.assertIn('self.waterObject:transferFluidTo(self.item:getFluidContainer(), _amount)', value)
        self.assertIn('if not isClient() then', value)
        self.assertNotIn('isExistInTheWorld', value)
        self.assertNotIn('isSafehouseAllow', value)

    def test_20_equipment_definitions(self):
        normal = text(GAME / 'media/scripts/generated/items/normal.txt')
        self.assertRegex(normal, r'item Bucket\s*\{[^}]*Capacity = 10\.0,')
        self.assertIn('item CleaningLiquid2', normal)
        self.assertIn('item Sponge', normal)
        self.assertIn('base:cleanstains', normal)

    def test_21_quartermaster_handles_rooms_and_return_gap(self):
        bindings = text(ROOT / (PROJECT_LUA + 'shared/B47ANCEDQuartermaster/Bindings.lua'))
        rooms_src = text(ROOT / (PROJECT_LUA + 'shared/B47ANCEDQuartermaster/Rooms.lua'))
        movement = text(ROOT / (PROJECT_LUA + 'shared/B47ANCEDQuartermaster/Movement.lua'))
        executor = text(ROOT / (PROJECT_LUA + 'client/B47ANCEDQuartermaster/Executor.lua'))
        for symbol in ('function B.target(', 'function B.session(', 's.roomRevision'):
            self.assertIn(symbol, bindings)
        for symbol in ('function R.resolve(player,id,revision)', 'function R.contains(', 'function R.discover(', 'function R.tick()'):
            self.assertIn(symbol, rooms_src)
        self.assertIn('function M.withdraw(', movement)
        self.assertIn('ISInventoryTransferAction:new', executor)
        self.assertIn("if args.destination~=nil or args.target~=nil or args.config~=nil", movement)

    def test_22_no_owned_inventory_mutation_and_storage_only(self):
        targets = text(ROOT / (PROJECT_LUA + 'shared/B47ANCEDQuartermaster/Targets.lua'))
        self.assertIn("t.container:getType() == 'floor' or t.container:getContainingItem()", targets)
        for filename in ('shared/B47ANCEDQuartermaster/Movement.lua', 'client/B47ANCEDQuartermaster/Executor.lua'):
            self.assertNotRegex(text(ROOT / (PROJECT_LUA + filename)), r':(?:Remove|AddItem|addItem|removeItemWithID)\s*\(')

    def test_23_transfer_constructor_and_headless_risk(self):
        value = text(GAME / (LUA + 'shared/Fluids/ISFluidTransferAction.lua'))
        self.assertIn('new(character, sourceContainer, sourceFluidObject, targetContainer, targetFluidObject, amount)', value)
        self.assertIn('if isServer() then', value)
        self.assertIn('self.sourceStartAmount - self.amount', value)
        util = text(GAME / (LUA + 'shared/Fluids/ISFluidUtil.lua'))
        self.assertIn('getPlayer():getInventory()', util)
        self.assertIn('print("not implemented")', text(GAME / (LUA + 'shared/Fluids/ISFluidContainer.lua')))

    def test_24_lua_exposure(self):
        value = refs('zombie/Lua/LuaManager$Exposer', 'exposeAll')
        for symbol in ('zombie/entity/components/fluids/FluidContainer', 'zombie/core/NetTimedAction', 'zombie/iso/IsoGridSquare'):
            self.assertIn(symbol, value)

    def test_25_mixture_blending_contract(self):
        self.assertIn('FluidFilter.allows', refs('zombie/entity/components/fluids/Fluid', 'canBlendWith'))
        filters = refs('zombie/entity/components/fluids/FluidFilter', 'allows', '(Lzombie/entity/components/fluids/Fluid;)Z')
        self.assertIn('EnumSet.isEmpty', filters)
        self.assertIn('Fluid.isCategory', filters)
        fluids = text(GAME / 'media/scripts/generated/fluids.txt')
        bleach = fluids[fluids.index('    fluid Bleach'):fluids.index('    fluid Blood')]
        self.assertIn('Beverage,', bleach)
        self.assertIn('fluid TaintedWater', fluids)

    def test_26_user_bleach_first_fill_headroom(self):
        # Execute the actual native fill constructor, not a new recipe function.
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute(BOOT)
        lua.execute(text(GAME / (LUA + 'shared/TimedActions/ISTakeWaterAction.lua')))
        lua.execute('''
            local bucket=item(0.01,"Bleach")
            function bucket.f:getCapacity() return 10 end
            function bucket:isEquipped() return false end
            local c=actor({bucket})
            function c:getFreeInventoryCapacity() return 20 end
            function c:isEquippedClothing() return false end
            local source={getFluidAmount=function() return 12 end}
            local a=ISTakeWaterAction:new(c,bucket,source,false)
            assert(math.abs(a.waterUnit-9.99)<1e-10)
            assert(a.item==bucket and a.waterObject==source)
            assert(bucket.f.amount==0.01) -- constructor itself has not filled anything
        ''')


if ARGS.verify_evidence:
    expected = json.loads(ARGS.verify_evidence.read_text(encoding='utf-8'))
    for key in ('jarSha256', 'gameFiles', 'projectFiles', 'classes', 'head', 'projectVersionObserved'):
        if expected[key] != EVIDENCE[key]:
            raise SystemExit('Source evidence drift: ' + key + '; re-audit rather than relabel old results')
suite = unittest.defaultTestLoader.loadTestsFromTestCase(Contracts)
result = unittest.TextTestRunner(verbosity=2).run(suite)
EVIDENCE['offlineResults'] = {'testsRun': result.testsRun, 'failures': len(result.failures),
                             'errors': len(result.errors), 'nativeExecution': 'NOT TESTED',
                             'G7': 'BLOCKED / NOT TESTED', 'stableG8': 'BLOCKED'}
if result.wasSuccessful() and ARGS.write_evidence:
    ARGS.write_evidence.parent.mkdir(parents=True, exist_ok=True)
    ARGS.write_evidence.write_text(json.dumps(EVIDENCE, indent=2) + '\n', encoding='utf-8')
    print('Evidence written:', ARGS.write_evidence)
raise SystemExit(0 if result.wasSuccessful() else 1)
