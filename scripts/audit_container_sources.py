"""Read-only Workshop metadata/declaration census. Never imports or executes mod Lua."""
import argparse
import hashlib
import json
import re
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--workshop', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
rows = []
folders = sorted(p for p in args.workshop.iterdir() if p.is_dir() and p.name.isdigit())
for folder in folders:
    metadata = {}
    fingerprints = {}
    for path in sorted(folder.rglob('mod.info')):
        text = path.read_text(encoding='utf-8-sig', errors='replace')
        fields = dict(re.findall(r'^([^=\r\n]+)=(.*)$', text, re.M))
        mod_id = fields.get('id', '').strip()
        if not mod_id:
            continue
        entry = metadata.setdefault(mod_id, {'id': mod_id, 'names': set(), 'authors': set(), 'versions': set()})
        for field, dest in [('name', 'names'), ('author', 'authors'), ('modversion', 'versions')]:
            if fields.get(field, '').strip():
                entry[dest].add(fields[field].strip())
        fingerprints[path.relative_to(folder).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    vehicle_files = containers = bags = 0
    for path in folder.rglob('*.txt'):
        relative = path.relative_to(folder).as_posix()
        if '/media/scripts/' not in '/' + relative.lower() or path.stat().st_size > 16 * 1024 * 1024:
            continue
        text = path.read_text(encoding='utf-8-sig', errors='replace')
        native_vehicle = bool(re.search(r'\b(?:vehicle|template\s+vehicle)\s+[\w.]+\s*\{', text, re.I))
        slots = len(re.findall(r'\bcontainer\s*\{', text, re.I)) if native_vehicle else 0
        item_bags = len(re.findall(r'\bType\s*=\s*Container\b', text, re.I))
        vehicle_files += native_vehicle
        containers += slots
        bags += item_bags
        if slots or item_bags:
            fingerprints[relative] = hashlib.sha256(path.read_bytes()).hexdigest()
    relevant_name = any(re.search(r'container|trailer|cargo|rv.?interior|pallet', name, re.I)
                        for m in metadata.values() for name in m['names'])
    if not (containers or bags or relevant_name):
        continue
    mods = [{key: sorted(value) if isinstance(value, set) else value for key, value in m.items()}
            for m in metadata.values()]
    rows.append({'workshop_id': folder.name,
                 'url': 'https://steamcommunity.com/sharedfiles/filedetails/?id=' + folder.name,
                 'mods': mods, 'vehicle_script_files': vehicle_files,
                 'vehicle_container_declarations': containers, 'inventory_container_declarations': bags,
                 'metadata_and_relevant_declaration_sha256': fingerprints,
                 'license': 'UNKNOWN; independent interoperability only, no code/assets imported',
                 'runtime': 'NOT TESTED'})
report = {'date': '2026-10-15', 'project_version': (Path(__file__).resolve().parents[1] / 'VERSION').read_text().strip(),
          'scope': 'Installed public metadata and native container declarations; no mod Lua loaded or copied',
          'limitations': 'Counts include common/B41/B42/optional variants and templates, not effective runtime definitions. '
                         'Storage created dynamically by Lua, virtual inventories, actual permissions and runtime load order '
                         'are not established by this census. Standard native world objects/carried bags retain existing support; '
                         'selected vehicle parts and bags inside native physical storage use the new generic adapter. '
                         'Fluids and virtual inventories without verified native ownership remain unsupported.',
          'downloaded_workshop_folders': len(folders), 'relevant_workshop_items': len(rows), 'items': rows}
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
print(json.dumps({'downloaded_items': len(folders), 'relevant_items': len(rows),
                  'vehicle_storage_items': sum(r['vehicle_container_declarations'] > 0 for r in rows),
                  'inventory_bag_items': sum(r['inventory_container_declarations'] > 0 for r in rows),
                  'runtime': 'NOT TESTED', 'output': args.output.as_posix()}, indent=2))
