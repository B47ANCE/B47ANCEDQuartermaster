"""Synthetic clocks test summaries, never native latency."""
import importlib.util
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'scripts/summarize_sort_trace.py'
spec = importlib.util.spec_from_file_location('sort_summary', path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
client = '\n'.join(f'[B47QM SORT TRACE] client operation={i} stage=ACTION_STARTED elapsedMs={v} durationMs=5 clock=wall' for i, v in enumerate([10, 20, 30]))
server = '[B47QM SORT TRACE] server operation=0 stage=DISCOVERY_SCAN elapsedMs=9000 durationMs=70 clock=wall'
bad = '[B47QM SORT TRACE] client operation=bad stage=ACTION_STARTED elapsedMs=unknown durationMs=unknown clock=discontinuity'
result = module.summarize([client, server, bad], 'offline')
assert result['peers']['client']['firstNativeStart'] == {'samples': 3, 'medianMs': 20, 'p95Ms': 30, 'worstMs': 30}
assert result['peers']['server']['firstNativeStart'] is None
assert result['invalidClockRows'] == 1 and result['crossPeerDurationsComputed'] is False
assert result['peers']['server']['stages']['DISCOVERY_SCAN']['worstMs'] == 70
print('PASS OFFLINE synthetic Sort summary: median/p95/worst, peer separation, clock rejection; no native timing evidence')
