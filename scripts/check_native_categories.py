"""Read installed native getCategory constants and compare script metadata with Lua.

No Java execution/build and no third-party Lua execution. This is offline API
evidence, not native item construction or runtime proof.
"""
import argparse
import io
import json
import struct
import zipfile
from pathlib import Path
from audit_workshop_installed import ROOT, audit_helpers, LuaRuntime


def category_literals(data):
    stream = io.BytesIO(data)
    def read(n):
        return stream.read(n)
    def u1(): return struct.unpack('>B', read(1))[0]
    def u2(): return struct.unpack('>H', read(2))[0]
    def u4(): return struct.unpack('>I', read(4))[0]
    read(8)
    pool = [None] * u2()
    index = 1
    while index < len(pool):
        tag = u1()
        if tag == 1: pool[index] = read(u2()).decode('utf-8', errors='replace')
        elif tag in (7, 8, 16, 19, 20): pool[index] = (tag, u2())
        elif tag in (3, 4): read(4)
        elif tag in (5, 6): read(8); index += 1
        elif tag in (9, 10, 11, 12, 17, 18): read(4)
        elif tag == 15: read(3)
        else: raise ValueError(f'Unknown constant tag {tag}')
        index += 1
    read(6)
    read(u2() * 2)
    def attributes():
        result = []
        for _ in range(u2()):
            name = pool[u2()]
            result.append((name, read(u4())))
        return result
    for _ in range(u2()): read(6); attributes()
    result = set()
    for _ in range(u2()):
        read(2); name = pool[u2()]; descriptor = pool[u2()]; attrs = attributes()
        if name != 'getCategory' or descriptor != '()Ljava/lang/String;': continue
        for key, body in attrs:
            if key != 'Code': continue
            code = body[8:8 + struct.unpack('>I', body[4:8])[0]]
            for offset, opcode in enumerate(code[:-1]):
                if opcode == 18: constant = code[offset + 1]
                elif opcode == 19 and offset + 2 < len(code): constant = int.from_bytes(code[offset + 1:offset + 3], 'big')
                else: continue
                value = pool[constant] if constant < len(pool) else None
                if isinstance(value, tuple) and value[0] == 8: result.add(pool[value[1]])
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--game', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    with zipfile.ZipFile(args.game / 'projectzomboid.jar') as archive:
        literals = {}
        paths = ['zombie/inventory/InventoryItem.class'] + [p for p in archive.namelist() if p.startswith('zombie/inventory/types/') and p.endswith('.class') and '$' not in p]
        for path in paths:
            values = category_literals(archive.read(path))
            if values: literals[Path(path).stem] = sorted(values)
    parse, bridge = audit_helpers()
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().package.path = (ROOT / 'src/B47ANCEDQuartermaster/42/media/lua/shared/?.lua').as_posix() + ';' + lua.globals().package.path
    classify = lua.eval(bridge)
    decode = lua.eval("require('B47ANCEDQuartermaster/Categorizer').nativeName")
    classes = {'weapon': 'HandWeapon', 'container': 'InventoryContainer', 'map': 'MapItem', 'radio': 'Radio', 'moveable': 'Moveable', 'weaponpart': 'WeaponPart', 'keyring': 'KeyRing', 'alarmclockclothing': 'AlarmClockClothing', 'drainable': 'DrainableComboItem'}
    count, mismatches, full_types = 0, [], set()
    for path in sorted((args.game / 'media/scripts').rglob('*.txt')):
        for entry in parse(path):
            count += 1
            full_types.add(entry['fullType'])
            kind = entry.get('ItemType', entry.get('Type', 'Normal')).split(':')[-1].lower()
            category = entry.get('DisplayCategory')
            if not category:
                values = literals.get(classes.get(kind, kind.title()), literals['InventoryItem'])
                if len(values) != 1: raise ValueError(f'Ambiguous native fallback: {kind}: {values}')
                category = values[0]
            actual = decode(classify(lua.table_from(entry, recursive=True))[0])
            if actual != category: mismatches.append({'item': entry['fullType'], 'expected': category, 'actual': actual})
    args.output.write_text(json.dumps({'items': count, 'uniqueTypes': len(full_types), 'mismatches': mismatches, 'nativeCategoryLiterals': literals}, indent=2) + '\n', encoding='utf-8')
    print(f'Native membership: {count} declarations, {len(full_types)} unique types, {len(mismatches)} mismatches')
    if mismatches: raise SystemExit(1)


if __name__ == '__main__': main()
