"""Read-only bytecode viewer for the narrow vanilla transfer investigation."""
import argparse
import io
from pathlib import Path
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.test-deps'))
from jawa.cf import ClassFile

parser = argparse.ArgumentParser()
parser.add_argument('class_name')
parser.add_argument('methods', nargs='*')
parser.add_argument('--start', type=int, default=0)
parser.add_argument('--end', type=int, default=100000)
parser.add_argument('--jar', type=Path, default=Path(r'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\projectzomboid.jar'))
args = parser.parse_args()
with zipfile.ZipFile(args.jar) as archive:
    name = args.class_name.replace('.', '/') + '.class'
    cf = ClassFile(io.BytesIO(archive.read(name)))
    print(name, 'extends', cf.super_.name.value)
    for method in cf.methods:
        if args.methods and method.name.value not in args.methods:
            continue
        print(method.name.value, method.descriptor.value)
        if not method.code:
            continue
        for instruction in method.code.disassemble():
            if not args.start <= instruction.pos <= args.end:
                continue
            operands = []
            for operand in instruction.operands:
                if isinstance(operand, dict):
                    operands.append(str(operand))
                elif operand.op_type.name == 'CONSTANT_INDEX':
                    value = cf.constants.get(operand.value)
                    if hasattr(value, 'class_') and hasattr(value, 'name_and_type'):
                        operands.append(value.class_.name.value + '.' + value.name_and_type.name.value + ':' + value.name_and_type.descriptor.value)
                    elif hasattr(value, 'string'):
                        operands.append(repr(value.string.value))
                    elif hasattr(value, 'name'):
                        operands.append(value.name.value)
                    elif hasattr(value, 'value'):
                        operands.append(str(value.value))
                    else:
                        operands.append(str(value))
                else:
                    value = operand.value
                    if instruction.mnemonic.startswith(('if', 'goto')):
                        value = '->' + str(instruction.pos + value)
                    operands.append(str(value))
            print(instruction.pos, instruction.mnemonic, ' '.join(operands))
