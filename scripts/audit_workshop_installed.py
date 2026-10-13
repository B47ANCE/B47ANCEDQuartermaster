"""Read-only audit of installed Workshop item definitions, not active runtime mods.

Uses the project's existing static item parser and Lua resolver bridge. Script
inheritance, overrides and activated-mod load order remain native runtime gates.
"""
import argparse
import ast
import collections
import csv
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.test-deps'))
from lupa.lua51 import LuaRuntime


def audit_helpers():
    source = ast.parse((ROOT / 'tests/audit_categories.py').read_text(encoding='utf-8'))
    parser = next(node for node in source.body if isinstance(node, ast.FunctionDef) and node.name == 'items')
    bridge = next(node.value for node in source.body if isinstance(node, ast.Assign)
                  and any(isinstance(target, ast.Name) and target.id == 'bridge' for target in node.targets))
    namespace = {'re': re}
    exec(compile(ast.Module(body=[parser], type_ignores=[]), 'audit_categories.py', 'exec'), namespace)
    return namespace['items'], ast.literal_eval(bridge)


def property_file(path):
    result = {}
    for line in path.read_text(encoding='utf-8-sig', errors='replace').splitlines():
        if '=' in line and not line.lstrip().startswith('#'):
            key, value = line.split('=', 1)
            result[key.strip()] = value.strip()
    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--workshop-root', type=Path)
    ap.add_argument('--output', type=Path, default=ROOT / 'dist/handoffs/dev15-workshop-audit')
    args = ap.parse_args()
    candidates = [args.workshop_root] if args.workshop_root else [
        Path('E:/Program Files (x86)/Steam/steamapps/workshop/content/108600'),
        Path('C:/Program Files (x86)/Steam/steamapps/workshop/content/108600')]
    workshop = next((p for p in candidates if p and p.is_dir()), None)
    if not workshop:
        raise SystemExit('Workshop root unavailable; pass --workshop-root')
    parse_items, bridge = audit_helpers()
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().package.path = (ROOT / 'src/B47ANCEDQuartermaster/42/media/lua/shared/?.lua').as_posix() + ';' + lua.globals().package.path
    lua.execute("ComponentType={FluidContainer='FluidContainer'}")
    ranked_bridge = bridge.replace('return cat,reason,legacy,matches,eligible,exclusion,semantic,historical',
        'local winner,why,weight,confidence,candidates=R.rank(item);return cat,reason,legacy,matches,eligible,exclusion,semantic,historical,winner,why,weight,confidence,candidates')
    classify = lua.eval(ranked_bridge)
    frozen = LuaRuntime(unpack_returned_tuples=True)
    frozen.globals().package.path = (ROOT / 'dist/handoffs/dev15-baseline/src/B47ANCEDQuartermaster/42/media/lua/shared/?.lua').as_posix() + ';' + frozen.globals().package.path
    frozen.execute("ComponentType={FluidContainer='FluidContainer'}")
    classify_previous = frozen.eval(bridge)
    labels = json.loads((ROOT / 'src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/EN/UI.json').read_text(encoding='utf-8'))
    resolver = lua.eval("require('B47ANCEDQuartermaster/Categorizer')")
    packages, declarations, errors = [], [], []
    for package in sorted(p for p in workshop.iterdir() if p.is_dir()):
        title_file = package / 'workshop.txt'
        package_title = property_file(title_file).get('title', '') if title_file.exists() else ''
        infos = sorted(package.rglob('mod.info'))
        package_row = {'workshopID': package.name, 'workshopTitle': package_title,
                       'modIDs': [], 'modInfoCount': len(infos), 'scriptFileCount': 0,
                       'itemDeclarations': 0, 'buildVariants': []}
        variants = set()
        for info in infos:
            meta = property_file(info)
            mod_id = meta.get('id', '')
            package_row['modIDs'].append({'id': mod_id, 'name': meta.get('name', ''),
                                           'versionMin': meta.get('versionMin', ''), 'versionMax': meta.get('versionMax', ''),
                                           'path': info.relative_to(package).as_posix()})
            for path in sorted(info.parent.rglob('*.txt')):
                if 'scripts' not in {part.lower() for part in path.parts}:
                    continue
                # One mod.info owns the nearest tree; nested variant mod.info owns itself.
                if any(other != info and other.parent in path.parents and info.parent in other.parents for other in infos):
                    continue
                package_row['scriptFileCount'] += 1
                relative = path.relative_to(info.parent)
                variant = next((part for part in reversed(info.parent.parts + relative.parts)
                                if re.fullmatch(r'4[12](?:\.\d+)?', part)), 'common')
                variants.add(variant)
                try:
                    parsed = list(parse_items(path))
                except Exception as exc:
                    errors.append({'sourceFile': str(path), 'error': str(exc)})
                    continue
                source_hash = hashlib.sha256(path.read_bytes()).hexdigest()
                for entry in parsed:
                    package_row['itemDeclarations'] += 1
                    try:
                        value = classify(lua.table_from(entry, recursive=True))
                        category, reason, legacy, matches, eligible, exclusion, semantic, historical, winner, why, weight, confidence, ranked = value
                        previous = classify_previous(frozen.table_from(entry, recursive=True))[0]
                        contenders = [{'category': row['category'], 'reason': row['reason']}
                                      for row in matches.values()]
                        weighted = [{'category': row['physical'], 'semantic': row['category'],
                                     'reason': row['reason'], 'weight': row['weight']}
                                    for row in ranked.values()]
                        parents = [str(parent) for parent in (resolver.families.parents[category] or {}).values()]
                        full_type = entry['fullType']
                        decision = ('REFINE' if previous == 'B47_Misc' else 'MOVE') if category != previous else 'FALLBACK' if category == 'B47_Misc' else 'KEEP'
                        declarations.append({'workshopID': package.name, 'workshopTitle': package_title,
                            'modID': mod_id, 'modName': meta.get('name', ''), 'variant': variant,
                            'modVersionMin': meta.get('versionMin', ''), 'modVersionMax': meta.get('versionMax', ''),
                            'module': full_type.split('.', 1)[0], 'fullType': full_type,
                            'itemName': entry.get('DisplayName', full_type.split('.', 1)[-1]),
                            'sourceFile': path.as_posix(), 'displayCategory': entry.get('DisplayCategory', ''),
                            'tags': entry.get('Tags', ''), 'itemType': entry.get('ItemType', entry.get('Type', '')),
                            'semanticProperties': {key: entry[key] for key in sorted(entry) if key not in
                                {'fullType', 'DisplayName', 'DisplayCategory', 'Tags', 'ItemType', 'Type'}},
                            'previousCategoryID': previous,
                            'currentCategoryID': category, 'currentCategoryName': labels.get('UI_B47_Category_'+category[4:], category),
                            'currentParent': parents, 'proposedCategoryID': category,
                            'proposedCategoryName': labels.get('UI_B47_Category_'+category[4:], category),
                            'proposedParent': parents, 'reason': reason, 'candidates': contenders,
                            'weightedCandidates': weighted, 'winningWeight': weight, 'confidence': confidence,
                            'decision': decision,
                            'catalogEligible': bool(eligible), 'exclusion': exclusion or '',
                            'sourceSHA256': source_hash})
                    except Exception as exc:
                        errors.append({'sourceFile': str(path), 'fullType': entry.get('fullType'), 'error': str(exc)})
        package_row['buildVariants'] = sorted(variants)
        packages.append(package_row)
    counts = collections.Counter(row['fullType'] for row in declarations)
    categories_by_type=collections.defaultdict(set)
    for row in declarations:
        categories_by_type[row['fullType']].add(row['currentCategoryID'])
    divergent=sorted(full for full,categories in categories_by_type.items() if len(categories)>1)
    divergent_set=set(divergent)
    for row in declarations:
        if row['fullType'] in divergent_set:
            row['classificationDecision']=row['decision']
            row['decision']='AMBIGUOUS'
            row['effectiveDefinitionAmbiguous']=True
        else:
            row['effectiveDefinitionAmbiguous']=False
    duplicate = sorted(full for full, count in counts.items() if count > 1)
    output = args.output
    output.mkdir(parents=True, exist_ok=True)
    decisions=collections.Counter(row['decision'] for row in declarations)
    variants=collections.Counter(row['variant'] for row in declarations)
    summary = {'evidence': 'STATIC INSTALLED FILES ONLY; installed != active/effective',
        'projectVersion': (ROOT/'VERSION').read_text(encoding='utf-8').strip(),
        'taxonomyVersion': int(resolver.version),
        'resolverSHA256': hashlib.sha256((ROOT/'src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Categorizer.lua').read_bytes()).hexdigest(),
        'workshopRoot': str(workshop), 'packageCount': len(packages), 'modInfoCount': sum(p['modInfoCount'] for p in packages),
        'scriptFileCount': sum(p['scriptFileCount'] for p in packages),
        'declarations': len(declarations), 'uniqueFullTypes': len(counts), 'duplicateFullTypes': duplicate,
        'divergentDuplicateFullTypes': divergent,
        'decisionCounts': dict(sorted(decisions.items())), 'variantDeclarationCounts': dict(sorted(variants.items())),
        'errors': errors, 'packages': packages,
        'limits': 'Optional variants may be mutually exclusive. Static parsing cannot determine active scripts, inheritance, replacements or load-order winner.'}
    (output / 'summary.json').write_text(json.dumps(summary, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
    with (output / 'items.jsonl').open('w', encoding='utf-8') as file:
        for row in declarations:
            file.write(json.dumps(row, ensure_ascii=False)+'\n')
    columns = ['workshopID', 'workshopTitle', 'modID', 'modVersionMin', 'modVersionMax', 'variant', 'module', 'fullType', 'itemName',
        'sourceFile', 'displayCategory', 'tags', 'itemType', 'previousCategoryID', 'currentCategoryID', 'currentCategoryName',
        'currentParent', 'proposedCategoryID', 'proposedCategoryName', 'proposedParent',
        'winningWeight', 'confidence', 'decision', 'classificationDecision', 'effectiveDefinitionAmbiguous',
        'reason', 'catalogEligible', 'exclusion']
    with (output / 'items.csv').open('w', encoding='utf-8', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=columns, extrasaction='ignore')
        writer.writeheader()
        for row in declarations:
            writer.writerow({**row, 'currentParent': ';'.join(row['currentParent']),
                             'proposedParent': ';'.join(row['proposedParent'])})
    print(json.dumps({key: summary[key] for key in ('packageCount', 'modInfoCount', 'scriptFileCount', 'declarations', 'uniqueFullTypes')}, indent=2))


if __name__ == '__main__':
    main()
