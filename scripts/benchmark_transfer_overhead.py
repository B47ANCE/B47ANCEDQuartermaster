"""Deterministic offline queue/RPC overhead only; native timing/network simulated.

Reads the selected local Git baseline without altering source. Never launches PZ.
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.test-deps'))
from lupa.lua51 import LuaRuntime

MODULES = {'shared': ['Movement', 'Protocol', 'Authority'],
           'client': ['Executor', 'BatchExecutor', 'Sorter']}


def measure(game, baseline=None):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().package.path = ';'.join(
        (ROOT / f'src/B47ANCEDQuartermaster/42/media/lua/{side}/?.lua').as_posix()
        for side in ['client', 'shared']) + ';' + lua.globals().package.path
    lua.globals().TEST_ROOT = (ROOT / 'tests').as_posix()
    lua.globals().GAME_ROOT = game.as_posix()
    lua.execute("""
        print=function() end
        getActivatedMods=function() return {size=function() return 1 end,get=function() return 'B47ANCEDQuartermaster' end} end
        TICK_HANDLERS={}
        Events=setmetatable({OnTick={Add=function(fn) TICK_HANDLERS[#TICK_HANDLERS+1]=fn end}},
          {__index=function() return {Add=function() end} end})
    """)
    if baseline:
        for side, names in MODULES.items():
            for name in names:
                path = f'src/B47ANCEDQuartermaster/42/media/lua/{side}/B47ANCEDQuartermaster/{name}.lua'
                code = subprocess.check_output(['git', 'show', f'{baseline}:{path}'], cwd=ROOT).decode('utf-8')
                lua.execute('package.preload[...] = assert(loadstring(select(2,...)))',
                            f'B47ANCEDQuartermaster/{name}', code)
    fixture = (ROOT / 'tests/test_dev24_pipeline.lua').read_text(encoding='utf-8').split('-- Quantity, planning-size')[0]
    loop = 'S.tick();E.tick();flush();pump();f.advance(250)'
    assert fixture.count(loop) == 1
    fixture = fixture.replace(loop, 'for _,fn in ipairs(TICK_HANDLERS) do fn() end;flush();pump();f.advance(16)')
    metrics = lua.execute(fixture + """
        inventoryMode=true
        local started=getTimestampMs();local frames,idle=0,0
        local status,moved,failed=scenario(100,20,function(step)
          frames=step
          if E.batches[0] and #q.queue==0 then idle=idle+1 end
        end,1)
        assert(status=='ok' and moved==100 and failed==0)
        local calls=0
        for _,command in ipairs({'moveBatch','moveCarried','movePut','moveDone'}) do calls=calls+(rpcCounts[command] or 0) end
        return {elapsedMs=getTimestampMs()-started,frames=frames,queueIdleFrames=idle,
          movementRequests=calls,nativeGroups=groups,containerOpens=opens,items=moved}
    """)
    return dict(metrics.items())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--baseline', required=True, help='Existing local Git commit/ref, never fetched automatically')
    parser.add_argument('--game', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    before, after = measure(args.game, args.baseline), measure(args.game)
    assert before['items'] == after['items'] == 100
    assert before['nativeGroups'] == after['nativeGroups']
    assert after['movementRequests'] < before['movementRequests']
    assert after['queueIdleFrames'] < before['queueIdleFrames']
    result = {'environment': 'OFFLINE synthetic action/transport overhead; native animation duration and real network unverified',
              'baseline': args.baseline, 'before': before, 'after': after}
    args.output.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
