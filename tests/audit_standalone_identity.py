"""Read installed engine evidence without running PZ. No upstream code is copied."""
import io
import sys
import zipfile
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.test-deps'))
from jawa.cf import ClassFile
from lupa.lua51 import LuaRuntime

jar = Path(r'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\projectzomboid.jar')
print('VERIFIED_SOURCE jar SHA256', hashlib.sha256(jar.read_bytes()).hexdigest())
with zipfile.ZipFile(jar) as z:
    cf = ClassFile(io.BytesIO(z.read('zombie/iso/IsoObject.class')))
    for method in cf.methods:
        if method.name.value not in ('getEntityNetID', 'customHashCode'):
            continue
        dependencies = set()
        for instruction in method.code.disassemble():
            for operand in instruction.operands:
                if operand.op_type.name == 'CONSTANT_INDEX':
                    value = cf.constants.get(operand.value)
                    if hasattr(value, 'class_') and hasattr(value, 'name_and_type'):
                        dependencies.add(value.class_.name.value + '.' + value.name_and_type.name.value)
        print(method.name.value, 'references:', ', '.join(sorted(dependencies)))

lua = LuaRuntime(unpack_returned_tuples=True)
source = ROOT / 'src/B47ANCEDQuartermaster/42/media/lua'
lua.globals().package.path = ';'.join((str(source / 'shared/?.lua'), str(source / 'client/?.lua'), lua.globals().package.path))
lua.globals().TEST_ROOT = (ROOT / 'tests').as_posix()
lua.execute((ROOT / 'tests/reproduce_initial_target_race.lua').read_text(encoding='utf-8'))
print('DIAGNOSTIC ONLY: existing protocol is not certified safe by this reproduction')
