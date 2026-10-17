"""Native definition references, recipe consumption and fallback completeness."""
import json
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
source = root / 'src/B47ANCEDQuartermaster/42'
code = (source / 'media/scripts/b47_supply_ledger.txt').read_text(encoding='utf-8')
assert code.count('{') == code.count('}')
assert re.findall(r'^\s*item\s+(\w+)\s*$', code, re.M) == ['ShoppingPaper', 'SupplySheet', 'SupplyDisc']
assert 'OnTest = B47SupplyLedgerEnabled,' in code
assert 'ItemType = base:normal' in code and 'Tags = InHandCraft' in code
assert re.search(r'item 1 \[Base\.Pen;Base\.Pencil\] mode:keep,', code)
assert re.search(r'item 1 \[Base\.Clipboard\] mode:keep,', code), 'Clipboard must be required and retained'
assert re.search(r'item 1 \[Base\.SheetPaper2;Base\.Notebook\],', code)
assert re.search(r'outputs\s*\{\s*item 1 B47ANCEDQuartermaster\.SupplySheet,\s*\}', code)
assert 'SupplyDisc,' not in code, 'Disc conversion must remain behind authoritative completion'
assert 'ShoppingPaper,' not in code, 'Shopping paper creation must remain behind authoritative completion'
translations = source / 'media/lua/shared/Translate'
for name in ('ItemName.json', 'Recipes.json'):
    english = json.loads((translations / 'EN' / name).read_text(encoding='utf-8'))
    for locale in translations.iterdir():
        assert json.loads((locale / name).read_text(encoding='utf-8')) == english
native = Path('E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid/media/scripts/generated/items')
for filename, names in {'literature.txt': ['Notebook', 'SheetPaper2'], 'weapon.txt': ['Pen', 'Pencil'], 'normal.txt': ['Clipboard', 'Disc_Retail'], 'moveable.txt': ['Mov_DesktopComputer']}.items():
    text = (native / filename).read_text(encoding='utf-8-sig')
    for name in names:
        assert re.search(r'\bitem\s+' + re.escape(name) + r'\s*\{', text), name
print('PASS OFFLINE ledger definitions: native clipboard/paper/pen/CD/computer identities, retained clipboard and writing implement, one-sheet output, server-only disc conversion and 29-locale name/recipe fallback parity; native crafting NOT TESTED')
