"""Read-only installed-engine evidence for the consolidated feature handoff.

This is source inspection, not a native runtime test or a release gate.
No third-party mod is read; no vanilla implementation is copied.
"""
import argparse
import hashlib
import io
import json
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.test-deps'))
from jawa.cf import ClassFile


def inspect_method(archive, path, name):
    cf = ClassFile(io.BytesIO(archive.read(path)))
    methods = [m for m in cf.methods if m.name.value == name and m.code]
    references, strings, calls = set(), set(), []
    for method in methods:
        for instruction in method.code.disassemble():
            for operand in instruction.operands:
                if operand.op_type.name != 'CONSTANT_INDEX':
                    continue
                constant = cf.constants.get(operand.value)
                if hasattr(constant, 'class_') and hasattr(constant, 'name_and_type'):
                    reference = constant.class_.name.value + '.' + constant.name_and_type.name.value
                    references.add(reference)
                    if instruction.mnemonic.startswith('invoke'):
                        calls.append({'offset': instruction.pos, 'reference': reference})
                elif hasattr(constant, 'string'):
                    strings.add(constant.string.value)
    if not methods:
        raise RuntimeError(f'Missing evidence method: {path}:{name}')
    return {'class': path, 'method': name, 'references': sorted(references),
            'strings': sorted(strings), 'calls': calls}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game-root', type=Path, default=Path(
        r'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'))
    args = parser.parse_args()
    jar = args.game_root / 'projectzomboid.jar'
    targets = [
        ('zombie/core/Transaction.class', 'updateItem'),
        ('zombie/Lua/LuaManager$GlobalObject.class', 'syncItemModData'),
        ('zombie/network/packets/SyncItemModDataPacket.class', 'parse'),
        ('zombie/inventory/InventoryItem.class', 'save'),
        ('zombie/inventory/InventoryItem.class', 'load'),
        ('zombie/inventory/InventoryItem.class', 'isFavouriteRecipeInput'),
    ]
    with zipfile.ZipFile(jar) as archive:
        methods = [inspect_method(archive, path, name) for path, name in targets]
    transfer = methods[0]
    # Guards identify changed evidence, not general gameplay correctness.
    required = {'zombie/inventory/ItemContainer.Remove',
                'zombie/inventory/ItemContainer.addItem',
                'zombie/Lua/LuaEventManager.triggerEvent'}
    if not required.issubset(transfer['references']):
        raise RuntimeError('Transfer evidence changed: re-audit the installed engine')
    relative = [
        'media/lua/server/TransactionProcessor.lua',
        'media/lua/client/ISUI/ISInventoryPane.lua',
        'media/lua/client/Entity/ISUI/Controls/ISWidgetTitleHeader.lua',
        'media/lua/shared/TimedActions/Fishing/TimedActions/ISChangeFishingRodEquip.lua',
    ]
    files = {name: hashlib.sha256((args.game_root / name).read_bytes()).hexdigest()
             for name in relative}
    print(json.dumps({'evidence': 'VERIFIED SOURCE ONLY; native SP/MP NOT TESTED',
                      'project_version': (ROOT / 'VERSION').read_text().strip(),
                      'jar_sha256': hashlib.sha256(jar.read_bytes()).hexdigest(),
                      'vanilla_file_sha256': files, 'methods': methods}, indent=2))


if __name__ == '__main__':
    main()
