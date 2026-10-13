"""Read-only per-peer Sort timings. Never subtract timestamps across peers."""
import argparse
import json
import math
import re
import statistics
from pathlib import Path

ROW = re.compile(r'\[B47QM SORT TRACE\] (client|server|local) (.*)')


def summarize(texts, environment):
    peers = {}
    invalid = limits = 0
    for text in texts:
        for line in text.splitlines():
            match = ROW.search(line)
            if not match:
                continue
            fields = dict(part.split('=', 1) for part in match[2].split() if '=' in part)
            if fields.get('stage') == 'TRACE_LIMIT':
                limits += 1
            if fields.get('clock') != 'wall':
                invalid += 1
                continue
            peer = peers.setdefault(match[1], {})
            operation = peer.setdefault(fields.get('operation', '-'), [])
            operation.append(fields)
    result = {'environment': environment, 'clock': 'wall; forward clock adjustments cannot be detected',
              'crossPeerDurationsComputed': False, 'invalidClockRows': invalid,
              'traceLimitRows': limits, 'peers': {}}
    for side, operations in peers.items():
        first_actions, first_positions, stages = [], [], {}
        for rows in operations.values():
            preparation = next((r for r in rows if r.get('stage') == 'CLIENT_PREPARATION'), None)
            prep_ms = int(preparation['durationMs']) if preparation and preparation.get('durationMs', '').isdigit() else 0
            for stage, values in [('ACTION_STARTED', first_actions), ('FIRST_POSITION_CHANGE', first_positions)]:
                row = next((r for r in rows if r.get('stage') == stage), None)
                if row and row.get('elapsedMs', '').isdigit():
                    values.append(int(row['elapsedMs']) + prep_ms)
            for row in rows:
                value = row.get('durationMs', '')
                if value.isdigit():
                    stages.setdefault(row.get('stage', '-'), []).append(int(value))

        def stats(values):
            values = sorted(values)
            return {'samples': len(values), 'medianMs': statistics.median(values),
                    'p95Ms': values[math.ceil(len(values) * .95) - 1], 'worstMs': values[-1]} if values else None

        result['peers'][side] = {'operations': len(operations), 'firstNativeStart': stats(first_actions),
                                 'firstPositionChange': stats(first_positions),
                                 'stages': {stage: stats(values) for stage, values in stages.items()}}
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('logs', type=Path, nargs='+')
    parser.add_argument('--environment', required=True, choices=['offline', 'runtime-sp', 'runtime-dedicated'])
    args = parser.parse_args()
    print(json.dumps(summarize([p.read_text(encoding='utf-8-sig', errors='replace') for p in args.logs], args.environment), indent=2))
