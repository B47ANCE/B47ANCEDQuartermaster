"""Independent synthetic metadata only; never runs downloaded mod Lua."""
from pathlib import Path
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
from audit_workshop_corpus import inventory, owner

with tempfile.TemporaryDirectory() as directory:
    package = Path(directory)
    for variant in ('42', '42.21'):
        info = package / 'mods/Example' / variant / 'mod.info'
        info.parent.mkdir(parents=True)
        info.write_text('id=Example\nname=Synthetic fixture\n')
    script = package / 'mods/Example/common/media/scripts/items.txt'
    script.parent.mkdir(parents=True)
    script.write_text('module Fixture {\n item Sample {\n Type = Normal,\n }\n}\n')
    unowned = package / 'mods/Unknown/media/scripts/items.txt'
    unowned.parent.mkdir(parents=True)
    unowned.write_text('')
    infos, scripts = inventory(package)
    assert len(infos) == 2 and set(scripts) == {script, unowned}
    assert owner(script, infos)[1] == 'common-sibling'
    assert owner(unowned, infos) == (None, 'unowned-or-ambiguous')
    infos[0].write_text('id=DifferentOptionalVariant\n')
    assert owner(script, infos) == (None, 'unowned-or-ambiguous')
print('PASS OFFLINE Workshop inventory: common folders, exact file coverage and ambiguous ownership')
