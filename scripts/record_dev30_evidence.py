"""Read-only capability inventory and owned artifact receipt. No launch/deployment."""
from pathlib import Path
import hashlib, json, zipfile
ROOT=Path(__file__).resolve().parents[1]
source=ROOT/'src/B47ANCEDQuartermaster'
files={p.relative_to(source).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in source.rglob('*') if p.is_file()}
baseline=json.loads((ROOT/'dist/handoffs/dev29-build-receipt.json').read_text())['files']
changed=[n for n in sorted(set(files)|set(baseline)) if files.get(n)!=baseline.get(n)]
assert set(changed)=={'42/mod.info','42/media/lua/shared/B47ANCEDQuartermaster/Identity.lua','42/media/lua/client/B47ANCEDQuartermaster/InventoryCategories.lua'}, changed
workshop=Path('E:/Program Files (x86)/Steam/steamapps/workshop/content/108600')
inventory=[]
for info in workshop.rglob('mod.info'):
    text=info.read_text(encoding='utf-8',errors='replace')
    meta=dict(line.split('=',1) for line in text.splitlines() if '=' in line)
    if any(term in (meta.get('name','')+' '+meta.get('id','')).lower() for term in ('neat','booktracker','pzopt','better sorting','bettersort')):
        # Capability presence only: do not extract third-party implementation text.
        counts={k:0 for k in ('ISInventoryPane.renderdetails','ISInventoryPane:renderdetails','ISInventoryPane.refreshContainer','ISInventoryPane:refreshContainer')}
        for lua in (info.parent/'media/lua').rglob('*.lua'):
            content=lua.read_text(encoding='utf-8',errors='replace')
            for k in counts: counts[k]+=int(k in content)
        inventory.append({'metadata':str(info),'id':meta.get('id'),'name':meta.get('name'),'capabilityFileCounts':counts})
(ROOT/'dist/handoffs/dev30-renderer-capabilities.json').write_text(json.dumps({'scope':'installed metadata and capability-presence only; actual active runtime chain UNKNOWN','sourceCodeCopied':False,'implementationDerivedFromReference':False,'mods':inventory},indent=2)+'\n')
archive=ROOT/'dist/current/B47ANCEDQuartermaster-0.4.0-dev.30.zip'
with zipfile.ZipFile(archive) as z:
    assert {n.removeprefix('B47ANCEDQuartermaster/'):hashlib.sha256(z.read(n)).hexdigest() for n in z.namelist() if not n.endswith('/')}==files
receipt={'version':'0.4.0-dev.30','runtimeFiles':len(files),'package':str(archive),'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'sourcePackageParity':'PASS','changedRuntimeFiles':changed,'files':files,'offline':'PASS tests/run_tests.py --package; check_versions.py --release; check_vanilla_membership.py 5092 unchanged','G6':'NOT TESTED','G7':'BLOCKED / NOT TESTED','G8':'BLOCKED','deployed':False,'published':False}
(ROOT/'dist/handoffs/dev30-build-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print('PASS dev30 receipt, runtime diff restricted to adapter/version mirrors, package parity; capability metadata entries:',len(inventory))
