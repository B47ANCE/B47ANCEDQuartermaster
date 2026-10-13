"""Read-only installed-source evidence; does not launch PZ or emulate runtime behavior."""
import hashlib
import io
import json
from pathlib import Path
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.test-deps'))
from jawa.cf import ClassFile

GAME = Path(r'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid')
QM = Path(r'E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\3761216758\mods\Quartermaster\42')
FILES = [GAME / 'projectzomboid.jar', QM / 'mod.info']
FILES += [GAME / 'media/lua' / p for p in (
    'client/ISUI/ISInventoryPage.lua', 'client/ISUI/ISButton.lua',
    'shared/Definitions/ContainerButtonIcons.lua',
    'client/Vehicles/TimedActions/ISPathFindAction.lua')]
FILES += [QM / 'media/lua' / p for p in (
    'client/LootSorter_ContextMenu.lua', 'client/LootSorter_Core.lua',
    'client/LootSorter_Picker.lua', 'shared/LootSorter_Util.lua',
    'shared/LootSorter_Rpc.lua', 'shared/LootSorter_Authority.lua',
    'shared/LootSorter_Presets.lua', 'server/LootSorter_Coords.lua',
    'server/LootSorter_Presets.lua')]

def hashes():
    return {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in FILES}

before = hashes()
classes = {
    'zombie/iso/IsoObject': ['getSpriteGrid', 'getSpriteGridObjectsIncludingSelf',
        'getSpriteGridObjects', 'getContainerCount', 'getContainerByIndex', 'transmitModData'],
    'zombie/iso/sprite/IsoSpriteGrid': ['getWidth', 'getHeight', 'getLevels',
        'getSpriteGridPosX', 'getSpriteGridPosY', 'getSpriteGridPosZ', 'getSprite', 'validate'],
    'zombie/iso/IsoGridSquare': ['getRoom', 'getBuilding'],
    'zombie/iso/areas/IsoBuilding': ['getDef'],
    'zombie/iso/BuildingDef': ['getRooms', 'getSquares', 'isBasement'],
    'zombie/iso/RoomDef': ['getIsoRoom', 'getBuilding', 'getRects', 'getZ'],
    'zombie/iso/areas/IsoRoom': ['getBuilding', 'getSquares', 'getRoomDef'],
    'zombie/network/packets/ObjectModDataPacket': ['parse', 'isConsistent', 'processServer'],
    'zombie/network/fields/MovingObject': ['isConsistent'],
}
report = {'evidence': 'TESTED_OFFLINE: class/source inspection only', 'sha256': before,
          'methods': {}, 'range_square_counts': {str(r): (2*r+1)**2 for r in (5, 10, 20, 30)}}
with zipfile.ZipFile(GAME / 'projectzomboid.jar') as jar:
    for name, expected in classes.items():
        cf = ClassFile(io.BytesIO(jar.read(name + '.class')))
        report['methods'][name] = {}
        for method in cf.methods:
            if method.name.value not in expected:
                continue
            assert method.access_flags.acc_public, (name, method.name.value)
            instructions = []
            for instruction in method.code.disassemble() if method.code else []:
                operands = []
                for operand in instruction.operands:
                    value = (cf.constants.get(operand.value)
                             if operand.op_type.name == 'CONSTANT_INDEX' else operand.value)
                    if hasattr(value, 'class_') and hasattr(value, 'name_and_type'):
                        value = (value.class_.name.value + '.' + value.name_and_type.name.value
                                 + value.name_and_type.descriptor.value)
                    operands.append(str(value))
                instructions.append(f'{instruction.pos}: {instruction.mnemonic} {" ".join(operands)}')
            report['methods'][name][method.name.value + method.descriptor.value] = instructions
        for expected_name in expected:
            assert any(k.startswith(expected_name + '(') for k in report['methods'][name]), (name, expected_name)
assert 'modversion=0.24.0' in (QM / 'mod.info').read_text()
assert 'object:getSpriteGridObjectsIncludingSelf(objects)' in FILES[5].read_text()
assert before == hashes(), 'Inspected files changed during audit'
print(json.dumps(report, indent=2))
