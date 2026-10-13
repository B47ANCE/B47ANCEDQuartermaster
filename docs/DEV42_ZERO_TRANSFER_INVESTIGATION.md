# dev.42 zero-transfer investigation

Compatible PATCH failure-containment/reporting correction in the ongoing prerelease series: 0.4.0-dev.42. No schema/protocol version or category change. Published dev.41 remains historical evidence, never dev.42 proof.

[VERIFIED user runtime report] Sort started from player inventory, with destinations configured. User clarified zero items were actually placed; character walked to a container. A walk proves neither PUT authorization nor server-observed transfer completion. The inspected client console identifies dev.41 and contains no correlated sort traces. Its native duplicate item-ID error has no stack and cannot be attributed to B47. Responding remote server version and precise rejection remain UNKNOWN.

[VERIFIED source] Client batches previously continued after all offered transfers in a batch failed, allowing subsequent batches to fail similarly. Failure containment now ends that run with invalid status when completed==0 and failed>0, preserving later items for a fresh user attempt. There is no native transfer retry, rollback or client-owned mutation. Successful/partial-progress batches retain existing behavior. This is not proof that the underlying live PUT rejection is fixed.

[VERIFIED source] Skipped in the existing halo callback combines native transfer failures with planner skips. The pipeline previously ignored skip totals in waiting/done responses, so terminal planning counts could be lost. All response states now capture planning totals before branching. One bounded client console summary reports completed, transferFailed, planningSkipped, a fixed-key reason histogram, server version, source item count, planning-target count and the first failed command/status/reason. It contains no item names, player names, configuration contents or world coordinates. It requires no full per-item tracing or user-edited Lua. Older servers may omit diagnostic fields; unknown is explicit, not fabricated.

Server diagnostics distinguish sourceChanged, itemProtected, carryCapacity, noMatchingRule, destinationRejected and generic planning rejection. noMatchingRule includes no current configured/live candidate, not proof that the user never configured a container. PUT rejection reasons retain every original check and ordering: phase, exact carrier presence, adjacency, capacity/permission, removal permission and operation validity. Validity reports expiry, protected item, changed carrier, invalidated destination, changed incarnation marker, changed configuration or effective rules. Missing/expired operation lookup remains rejected. Additive response fields and callback detail do not grant permission or change server state ownership.

[TESTED offline] Production Sorter/Trips/Movement/BatchExecutor with installed native queue merge/perform and simulated engine/network leaves: 701 player-inventory items deposit with zero failures in both SP and MP-shaped fixtures, including overweight carrier. Injected PUT rejection ends after the first batch, places zero items and preserves the remaining inventory; first-failure/server detail appears in the console summary. 701 unmatched items generate zero native transfers and exactly 701 noMatchingRule planning skips, distinct from transfer failures. Preset edits report effectiveRulesChanged and remain denied. Full regression suite PASS. Offline SP/MP-shaped fixtures do not certify actual dedicated behavior.

Exact commands using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe from this project:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev42-vanilla-diff.json --approved-changes docs/DEV41_APPROVED_TAXONOMY_CHANGES.json
```

Logs: dist/handoffs/dev42-tests.log and dev42-vanilla-diff.json. Taxonomy remains exactly the 625 approved cumulative deviations among 5,092 definitions. No gameplay option is added: stop-after-zero-progress is error containment, diagnostics are implementation evidence, and all normal configurable range/batching/routing remains server sandbox-owned.

[RUNTIME GATE] After separately authorized matching client/server deployment, repeat one player-inventory Sort and inspect the single sort summary line. Identify firstFailure, server, planningTargets, transferFailed and planningSkipped before choosing an underlying authority/capacity/configuration fix. Verify untouched remainder, no duplicate/lost items and a fresh user attempt. G6 native NOT TESTED; G7 dedicated BLOCKED / NOT TESTED; G8 readiness BLOCKED. No package, live deployment or publication authorized/performed in this investigation. Existing dev.41 publication does not authorize silently changing a running client or remote server.
