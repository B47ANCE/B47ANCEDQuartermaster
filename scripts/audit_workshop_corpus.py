"""Read-only script-declaration corpus. Never executes external Lua or resolves load order."""
import argparse
import collections
import csv
import hashlib
import json
import os
from pathlib import Path
from audit_workshop_installed import ROOT, audit_helpers, property_file, LuaRuntime


def inventory(package):
    infos, scripts = [], []
    for directory, _, names in os.walk(package):
        folder = Path(directory)
        for name in names:
            path = folder / name
            if name.lower() == 'mod.info':
                infos.append(path)
            elif name.lower().endswith('.txt') and 'scripts' in {p.lower() for p in path.parts}:
                scripts.append(path)
    return sorted(infos), sorted(scripts)


def owner(path, infos):
    ancestors = [p for p in infos if p.parent in path.parents]
    if ancestors:
        return max(ancestors, key=lambda p: len(p.parts)), 'ancestor'
    # B42 common scripts are siblings of version-specific mod.info, not children.
    common = next((p for p in path.parents if p.name.lower() == 'common'), None)
    siblings = [p for p in infos if common and p.parent.parent == common.parent]
    ids = {property_file(p).get('id') for p in siblings}
    if len(ids) == 1 and siblings:
        return sorted(siblings)[-1], 'common-sibling'
    return None, 'unowned-or-ambiguous'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--workshop-root', type=Path, required=True)
    ap.add_argument('--output', type=Path, required=True)
    ap.add_argument('--compare', type=Path, help='Reclassify a previous local items.jsonl without copying external data into source')
    args = ap.parse_args()
    if not args.workshop_root.is_dir():
        raise SystemExit('Workshop root missing')
    parse, bridge = audit_helpers()
    version = (ROOT / 'VERSION').read_text().strip()
    resolver_hash = hashlib.sha256((ROOT / 'src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Categorizer.lua').read_bytes()).hexdigest()
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().package.path = (ROOT / 'src/B47ANCEDQuartermaster/42/media/lua/shared/?.lua').as_posix() + ';' + lua.globals().package.path
    lua.execute("ComponentType={FluidContainer='FluidContainer'}")
    classify = lua.eval(bridge)
    args.output.mkdir(parents=True, exist_ok=True)
    if args.compare:
        changes, counts, unchanged, total = [], collections.Counter(), 0, 0
        with args.compare.open(encoding='utf-8') as data, (args.output / 'all-items.csv').open('w', encoding='utf-8', newline='') as report:
            writer = csv.DictWriter(report, fieldnames=['workshopID', 'modID', 'fullType', 'source', 'before', 'after', 'reason', 'eligible', 'reviewFlags'])
            writer.writeheader()
            for line in data:
                row = json.loads(line)
                total += 1
                category, reason = classify(lua.table_from(row['properties'], recursive=True))[:2]
                flags = []
                if category == 'B47_Misc':
                    flags.append('unresolved-category')
                if row['ownership'] == 'unowned-or-ambiguous':
                    flags.append('ambiguous-owner')
                if not (row['properties'].get('ItemType') or row['properties'].get('Type')):
                    flags.append('partial-definition')
                writer.writerow({'workshopID': row['workshopID'], 'modID': row['modID'], 'fullType': row['properties']['fullType'], 'source': row['source'], 'before': row['category'], 'after': category, 'reason': reason, 'eligible': row['eligible'], 'reviewFlags': ';'.join(flags)})
                if category == row['category']:
                    unchanged += 1
                    continue
                counts[category] += 1
                changes.append({'workshopID': row['workshopID'], 'modID': row['modID'], 'fullType': row['properties']['fullType'], 'source': row['source'], 'sourceSHA256': row['sha256'], 'before': row['category'], 'after': category, 'reason': reason})
        result = {'version': version, 'resolverSHA256': resolver_hash, 'declarations': total, 'unchanged': unchanged, 'changed': len(changes), 'categories': dict(counts), 'changes': changes}
        (args.output / 'comparison.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
        print(json.dumps({k: v for k, v in result.items() if k != 'changes'}))
        return
    totals, categories, fallback, errors, packages = collections.Counter(), collections.Counter(), collections.Counter(), [], []
    definitions = collections.defaultdict(set)
    with (args.output / 'items.jsonl').open('w', encoding='utf-8') as out:
        for index, package in enumerate(sorted(p for p in args.workshop_root.iterdir() if p.is_dir()), 1):
            infos, scripts = inventory(package)
            provenance = []
            for info in infos:
                meta = property_file(info)
                provenance.append({'modID': meta.get('id'), 'name': meta.get('name'), 'author': meta.get('author', 'UNKNOWN'), 'version': meta.get('modversion', 'UNKNOWN'), 'license': 'UNKNOWN; no reuse authorized', 'path': info.relative_to(package).as_posix()})
            packages.append({'workshopID': package.name, 'url': 'https://steamcommunity.com/sharedfiles/filedetails/?id=' + package.name, 'mods': provenance, 'scripts': len(scripts)})
            totals['packages'] += 1
            totals['modInfos'] += len(infos)
            for path in scripts:
                totals['scriptFiles'] += 1
                info, ownership = owner(path, infos)
                meta = property_file(info) if info else {}
                digest = hashlib.sha256(path.read_bytes()).hexdigest()
                try:
                    for entry in parse(path):
                        result = classify(lua.table_from(entry, recursive=True))
                        cat, reason = result[:2]
                        eligible = bool(result[4])
                        row = {'workshopID': package.name, 'modID': meta.get('id'), 'source': path.relative_to(package).as_posix(), 'sha256': digest, 'ownership': ownership, 'properties': entry, 'category': cat, 'reason': reason, 'eligible': eligible}
                        out.write(json.dumps(row, ensure_ascii=False) + '\n')
                        totals['declarations'] += 1
                        categories[cat] += 1
                        definitions[entry['fullType']].add(cat)
                        if eligible and cat == 'B47_Misc':
                            fallback[entry.get('DisplayCategory', '')] += 1
                except Exception as exc:
                    errors.append({'source': path.relative_to(package).as_posix(), 'workshopID': package.name, 'error': str(exc)})
            if index % 25 == 0:
                print(f'Inventoried {index} packages; {totals["declarations"]} declarations', flush=True)
    summary = {'version': version, 'resolverSHA256': resolver_hash, 'totals': dict(totals), 'uniqueFullTypes': len(definitions), 'divergentTypes': sum(len(v) > 1 for v in definitions.values()), 'categories': dict(categories), 'eligibleMiscDisplays': dict(fallback), 'errors': errors, 'packages': packages, 'limits': 'Static declarations including B41/B42/optional variants, not effective active items. Lua-created definitions and runtime overrides/inheritance/load order unresolved. No third-party code/assets imported.'}
    (args.output / 'summary.json').write_text(json.dumps(summary, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(json.dumps({'totals': dict(totals), 'uniqueFullTypes': len(definitions), 'errors': len(errors)}))


if __name__ == '__main__':
    main()
