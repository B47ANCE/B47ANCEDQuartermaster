"""Hard gate: compare installed B42 vanilla definitions with frozen dev.14 IDs."""
import argparse
import json
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.test-deps'))
from lupa.lua51 import LuaRuntime
from audit_workshop_installed import audit_helpers

ap=argparse.ArgumentParser()
ap.add_argument('--game',type=Path,required=True)
ap.add_argument('--output',type=Path,default=ROOT/'dist/handoffs/dev15-vanilla-diff.json')
ap.add_argument('--approved-changes',type=Path,help='Explicit reviewed baseline deviations; unexpected or missing deviations fail')
args=ap.parse_args()
parse_items,bridge=audit_helpers()
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().package.path=(ROOT/'src/B47ANCEDQuartermaster/42/media/lua/shared/?.lua').as_posix()+';'+lua.globals().package.path
lua.execute("ComponentType={FluidContainer='FluidContainer'}")
classify=lua.eval(bridge)
current={}
for path in sorted((args.game/'media/scripts').rglob('*.txt')):
    for item in parse_items(path):
        result=classify(lua.table_from(item,recursive=True))
        current[item['fullType']]=result[0]
baseline=json.loads((ROOT/'dist/handoffs/dev15-vanilla-membership.json').read_text(encoding='utf-8'))['categories']
diff=[{'fullType':name,'before':baseline.get(name),'after':current.get(name)}
      for name in sorted(set(current)|set(baseline)) if baseline.get(name)!=current.get(name)]
out=args.output
out.write_text(json.dumps({'beforeCount':len(baseline),'afterCount':len(current),'changed':diff},indent=2)+'\n',encoding='utf-8')
print(f'Vanilla membership: {len(baseline)} baseline, {len(current)} current, {len(diff)} changed')
if args.approved_changes:
    approved=json.loads(args.approved_changes.read_text(encoding='utf-8'))
    if sorted(diff,key=lambda row:row['fullType'])!=sorted(approved,key=lambda row:row['fullType']):
        print('FAIL deviations do not exactly match approved changes');raise SystemExit(1)
    print('PASS exact approved deviations; historical baseline retained')
elif diff:print('First changes:',diff[:12]);raise SystemExit(1)
