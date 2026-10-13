# dev.38 sorting preparation

Compatible PATCH performance correction, canonical 0.4.0-dev.38. No gameplay settings, schema or protocol changes. Batch cache lifetime is an implementation ownership boundary, not a configurable gameplay policy.

[VERIFIED source] Each trip already snapshots authoritative source IDs and references. Static classifications are already cached. The client already prefetches offers while a batch executes. Native transfer actions already merge into native queue lists. Before this change, every item rebuilt the destination list, loaded each configuration, copied the preset library and expanded candidate effective rules. The live acceptance callback also resolved presets repeatedly.

Planner.prepare now produces a server-local destination/rule snapshot. Trips creates it and one preset snapshot once per tripNext invocation. Movement and Catalog reuse them for every item examined in that invocation. No cache survives into the next request. Player position/distance is captured within the synchronous batch; permissions, target identity/revocation, source presence, eligibility and current capacity are still checked for items. Existing Movement.valid compares persisted configuration/effective presets before native movement. Clients cannot submit this prepared context through network arguments.

Long-lived authoritative contents or capacity caches are deliberately not added: other players, crafting, item-state changes and native transfers can invalidate them. Existing source references are hints, not permission to transfer. Per-request snapshots remove redundant work without requiring unverified inventory-change events. World discovery remains live and can still contribute startup latency. [UNKNOWN] The remote server's dominant timing stage, because no correlated dedicated trace is available. This is not proof that the complete reported pause is resolved.

## Clean-room reference record

Reference: original Quartermaster, installed Workshop item 3761216758; static classification and native transfer domains. Narrow questions: can static item/category lookup results be cached, and can transfers use queued native actions? General capabilities observed: script-derived lookup reuse and native inventory transfer action use. No reference algorithms, control flow, constants, identifiers or source transferred.

Independent verification: installed vanilla ISInventoryTransferAction.lua explicitly supports queueList merging; owned BatchExecutor uses that native facility. Existing owned Catalog and source snapshot fixtures demonstrate static lookup reuse and real-item authority boundaries. SOURCE CODE COPIED: NO. IMPLEMENTATION DERIVED FROM REFERENCE: NO. Design consequence: eliminate independently identified repeated work in owned server Planner/Movement, retaining vanilla transfer execution. Remaining verification: actual dedicated timing and native queue behavior with the user's active UI mods.

## Validation

[TESTED offline] 100 decisions reuse one preparation without further Store.load or Schema.effective calls. Changing the live eligibility predicate changes the selected destination; revoked targets and foreign preparation owners are rejected. Existing full movement suite covers native donor merges, overlapping batches, replacement, capacity, cancellation and mixed peers. Offline fixtures do not prove dedicated correctness or elapsed startup improvement.

Commands from the project, using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev38-vanilla-diff.json --approved-changes docs/DEV34_APPROVED_TAXONOMY_CHANGES.json
```

Log: dist/handoffs/dev38-tests.log. [RUNTIME GATE] Matching remote client/server build, correlated discovery/planning/action-start timings, inventory edits by another player during sorting, capacity/rule/preset changes and bulk take/put confirmation. G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No package, live deployment or publication.
