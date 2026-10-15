# Native transfer queue throughput

Project Version: 0.6.0-dev.3

## dev.3 category lookup correction

[VERIFIED client log, 2026-10-14 18:07 Phoenix] The running 0.5.0-dev.1
catalog logged repeated Categorizer.lua missing-method exceptions and completed
10,380 entries in 66,816 ms; the following discovery reply took 168 ms. No Sort
result was present in that log segment. The exception contribution to total
preparation time is not measured.

[VERIFIED installed B42.21.0 class metadata] Script Item exposes
getDisplayCategory/getItemType but lacks getScriptItem/getCategory. InventoryItem
exposes all four. Categorizer.read previously attempted every requested getter
inside pcall, including absent methods. The engine still logged those failures.
It now checks object shape and callable method presence before invocation.
Existing native category results, callable-getter protection and fallback values
are preserved. No taxonomy, ownership, persistence or sandbox option changes.

[TESTED offline] The new regression failed before the fix and passed afterward.
It counts failed protected calls for script definitions, inventory fallbacks,
missing/non-callable getters and invalid inputs. No failed calls occur for these
cases after the fix. Full Build-Workshop.ps1 regression, 29-language fallback
parity, Lua syntax, native membership, artifact versions and exact 126-file
source/package/stage parity PASS for dev.3. The dev.3 benchmark repeats the
dev.2 results below. Native
catalog timing and optional-mod acceptance remain NOT TESTED.

This candidate includes the dev.2 transfer correction below and is authorized
for Workshop MP test distribution. Prior dev.2 work was source-only. Actual
upload outcome/commit/hashes belong to the publication manifest and receipt;
G7 and stable G8 remain blocked. No local live-mod deployment is authorized.

## Evidence and scope

[VERIFIED client console] Latest 0.5.0-dev.1 client/server run: 1,767 source
items, 190 destinations, 272 confirmed transfers, 1,470 noMatchingRule skips,
then a local BATCH_PERFORM / batch dispatch guard rejection. No detailed Sort
timing trace was enabled. This does not establish the cause of the startup delay
or the precise rejected item condition. The local server log copy is historical;
the configured SFTP helper/setup is unavailable. No remote log was retrieved.

The user clarifies that the main complaint is pauses between item transfers at
the same container. [VERIFIED source] A 20-item inventory deposit previously
issued 60 separate B47 movement requests; a container take/deposit issued 80.
Both batch execution and Sort scheduling used 250 ms local phase polling.

## Correction and authority

moveBatch aggregates 1-100 existing operation IDs for exactly one allowed phase:
moveTake, moveCarried, movePut or moveDone. Server validates the entire shape,
duplicates, limits and phase before processing any entry, then calls the existing
per-item authoritative transition. The authenticated player owns the lookup;
no client category, destination, inventory contents or transfer result is trusted.

Per-item eligibility, capacity, source/destination identity, arrival, rules and
completion checks remain unchanged. Results correlate to each operation in order
before client state changes. Partial item rejection is retained. A malformed
response fails closed. Rate-limited/arrival/replication queries retry under the
existing bounds; native transfers are never retried. The new aggregate admission
limit is a technical work budget, not a transfer-speed setting. SortBatchSize
remains server controlled, unchanged at default 20 / supported 1-100.

Batch state scheduling runs on native OnTick and drains at most eight cheap
ready transitions. Pending replies, active native queues, unchanged states and
retry deadlines immediately yield. Sort local dispatch runs per tick, with
planning queries still bounded to the existing cadence. There are no per-tick
world/item scans added and no new gameplay option or speed multiplier.

Native ISQueueActionsAction / ISInventoryTransferAction construction, grouping,
weight/type limits, animations and timing are preserved. Each authorized batch
is queued before its native head starts. Native groups can still contain one
heavy item; this change removes B47 idle work around those groups. Batches beyond
the server batch limit remain separate. It does not promise an unlimited queue
or a single container-open animation for an entire inventory.

The client guard now reports its failed condition (identity, containment,
protection, carrier, access, capacity or range) instead of a generic dispatch
error. The 272-item runtime stop is NOT claimed fixed without reproduction with
that reason. Existing guards are preserved, not bypassed. The external mod hooks
seen in the console stack are not by themselves evidence of a conflicting mod.

Movement capability 6 rejects older peers; all clients/server must update.
Configuration/preset/taxonomy persistence versions remain 3/2/7. No stored-data
migration is added beyond the prior 0.6.0-dev.1 retirement policy. Pure local
scheduler state is ephemeral. Reconnect/restart cancels/forgets operation state
under existing ownership/lifetime rules; native synchronization remains the
movement authority. No custom Java, upstream modification or imported code.

## Validation

Commands with configured Python from repository root:

```text
python tests/run_tests.py
python scripts/benchmark_transfer_overhead.py --baseline 2c3d5a8 --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output <local-overhead-report.json>
python scripts/check_native_categories.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output <local-native-report.json>
python scripts/check_versions.py --root .
python scripts/check_deployment.py
```

[TESTED offline] Deterministic benchmark uses actual registered OnTick scheduling
and the owned pipeline with installed native queue/perform Lua. Engine animation
duration and network are simulated. It compares local Git baseline 2c3d5a8 with
current source for 100 items / batch size 20 at 16 ms simulation steps:

| Measure | Before | After |
|---|---:|---:|
| B47 movement requests | 300 | 15 |
| Queue idle frames | 540 | 25 |
| Synthetic total milliseconds | 11024 | 2064 |
| Native groups | 100 | 100 |
| Container opens | 5 | 5 |
| Exact transferred items | 100 | 100 |

This is 95% fewer B47 movement requests; it is not a live throughput/latency
promise or a comparison to a player at native game speed. No native action time
is shortened. [TESTED offline] The complete regression suite, version consistency,
126-file source manifest and native membership audit passed (5,105 declarations,
5,092 unique item types, zero mismatches). Regressions cover shape/foreign-owner/old-peer rejection, per-item
partial failures, malformed/reordered responses, cancellation with a late grant,
arrival/capacity waits, no retries of native transactions, replication gaps and
701-item native-shaped transfers.

[RUNTIME GATE] Actual SP/optional-mod and dedicated MP throughput, complete Sort,
late server responses, protection/capacity changes, cancellation, join/rejoin and
restart remain NOT TESTED. G7 BLOCKED; stable G8 BLOCKED. The last confirmed
Workshop upload before this candidate was 0.5.0-dev.1. Publication is a test
distribution step, not runtime proof; no game/server launch is authorized.
