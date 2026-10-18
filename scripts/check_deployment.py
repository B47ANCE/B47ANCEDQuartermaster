"""Exact file-set and content checks; does not establish native runtime loading."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]
MOD = 'B47ANCEDQuartermaster'
SOURCE = ROOT / 'src' / MOD

def files(root):
    return {p.relative_to(root).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in root.rglob('*') if p.is_file()}

def compare(expected, actual, label):
    missing = sorted(expected.keys() - actual.keys())
    extra = sorted(actual.keys() - expected.keys())
    changed = sorted(k for k in expected.keys() & actual.keys() if expected[k] != actual[k])
    if missing or extra or changed:
        raise ValueError(f'{label}: missing={missing}; extra={extra}; changed={changed}')

def validate(stage=None, local=None, package=False):
    expected = files(SOURCE)
    declared = set(json.loads((ROOT / 'scripts/production-files.json').read_text(encoding='utf-8')))
    if set(expected) != declared:
        raise ValueError(f'Source manifest mismatch: missing={declared-set(expected)}, extra={set(expected)-declared}')
    version = (ROOT / 'VERSION').read_text().strip()
    info_text = (SOURCE / '42/mod.info').read_text(encoding='utf-8')
    info = dict(line.split('=', 1) for line in info_text.splitlines() if '=' in line)
    assert info['id'] == MOD and info['name'] == "B47ANCE'd Quartermaster"
    assert info['modversion'] == version and info.get('require') == 'B47ANCEDRooms,B47ANCEDPCFramework,B47ANCEDUI'
    assert re.findall(r'^require=(.*)$', info_text, re.M) == ['B47ANCEDRooms,B47ANCEDPCFramework,B47ANCEDUI']
    for name in expected:
        assert '/AutoClean/' not in name, 'Embedded cleaning returned to Quartermaster: '+name
        p = SOURCE / name
        if p.suffix in ('.lua', '.json', '.txt', '.info'):
            code = p.read_text(encoding='utf-8')
            if name not in {'42/media/lua/shared/B47ANCEDQuartermaster/Migration.lua',
                            '42/media/lua/shared/B47ANCEDQuartermaster/SortingData.lua'}:
                assert not re.search(r'QuartermasterSimpleSorting|QuartermasterSorting|B47ANCEDSorting', code), name
            if p.suffix == '.lua':
                assert not re.search(r'(?<![\w:.])next\s*\(', code), name
                assert 'LootSorter' not in code, name
    if package:
        archive = ROOT / 'dist/current' / f'{MOD}-{version}.zip'
        with zipfile.ZipFile(archive) as z:
            assert len(z.namelist()) == len(set(z.namelist()))
            actual = {n: hashlib.sha256(z.read(n)).hexdigest() for n in z.namelist() if not n.endswith('/')}
            compare({MOD+'/'+k:v for k,v in expected.items()}, actual, 'package')
    if stage:
        stage = Path(stage)
        # Compare across Contents, so an extra mod beside the intended mod also fails.
        compare({'mods/'+MOD+'/'+k:v for k,v in expected.items()}, files(stage/'Contents'), 'stage')
        metadata = (stage/'workshop.txt').read_text(encoding='utf-8').splitlines()
        assert 'id=3807217050' in metadata and "title=B47ANCE'd Quartermaster" in metadata
    if local:
        compare(expected, files(Path(local)), 'local')
    print(f'PASS deployment parity: {MOD} {version}, {len(expected)} files; source manifest'
          + (' + package' if package else '') + (' + stage' if stage else '') + (' + local' if local else ''))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--stage', type=Path)
    parser.add_argument('--local', type=Path)
    parser.add_argument('--package', action='store_true')
    args = parser.parse_args()
    validate(args.stage, args.local, args.package)
