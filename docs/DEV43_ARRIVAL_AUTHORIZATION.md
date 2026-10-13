# dev.43 server-observed arrival authorization

Canonical 0.4.0-dev.43: a PATCH-style correction within the ongoing 0.4.0 prerelease. Saved schema/configuration/taxonomy IDs unchanged. Movement wire capability advances 3 -> 4 because older executors cannot safely treat arrival-pending as a retryable metadata state. This explicitly requires updating/restarting both client and server; it is not an unrecorded mixed-peer guarantee. Configuration, taxonomy and framework versions remain separate.

## Failure and correction

[VERIFIED source] Client walk completion immediately advanced to grantTake/grantPut. Server adjacency beyond two tiles returned invalid. Executors permanently failed offered items and dev.41 continued into subsequent batches. [TESTED offline audit] Immutable dev.35 and dev.41 both deposited 701/701 with synchronized positions; forcing server position to remain behind after client walking produced 0 deposited/701 failed on both builds. This demonstrates the failure path, not its occurrence in the user's actual remote session. [UNKNOWN] Actual live rejection and remote loaded version; client was dev.41. The installed Workshop copy matched all 127 published files. No upstream source or assets used.

Movement now validates current item/carrier/target/configuration/preset/permission/capacity first. For an otherwise valid operation, server-observed non-adjacency returns waiting/arrivalPending and preserves the ungranted planned/carried phase. No native transaction is authorized before adjacency. Server records a per-operation, per-leg 15-second deadline in ephemeral operation state; expiry remains denied even if a later query is adjacent. This data is never persisted or accepted from the client. The server uses only its authenticated player position, never a submitted client position.

Both BatchExecutor and single Executor poll authorization metadata at bounded intervals after a waiting reply and stop after 15 seconds. They do not resubmit native pickup/deposit transactions. Successful grants advance the operation state so they are not requested again. All original native last-boundary checks remain. Source/destination removal, protection, capacity, permissions, moved/replaced targets and changed rules remain rejected during waiting. Existing cancellation and zero-progress containment are retained; no rollback, lost-item recreation or permission bypass.

The single-item fallback also cancels rather than reporting success if an unrelated timed action occupies the queue when a grant response arrives. Successful authorization by itself is not credited as a completed transfer.

The 15-second deadline and metadata polling interval are implementation safety controls, not configurable gameplay behavior. Existing server sandbox range, building discovery, batch size and route settings remain authoritative. No gameplay micro-setting, Java bridge or shared-state client ownership added. Protocol negotiation rejects movement capability 3 before these flows, preventing older peers from consuming waiting semantics incorrectly. Join/reconnect negotiates again through the existing handshake; ephemeral runs are cleaned up by existing disconnect/timeout paths. Native multiplayer reconnection remains a runtime gate.

## Validation and limits

[TESTED offline] Production authority/planner/executors with installed native queue merge/perform and engine/network leaves simulated:

- 701 player-inventory items with delayed server PUT position transfer exactly once, with zero failures, in SP- and MP-shaped fixtures.
- Delayed TAKE arrival succeeds after server position updates.
- Permanent non-adjacency times out with no transfer; server deadline cannot be revived by late arrival.
- Destination removal, capacity changes and cancellation during waiting preserve items and do not grant movement.
- Single executor waits/polls without native dispatch, then transfers once; unrelated queued action cannot produce false success.
- Existing replacement, protected-item, rule/preset-change, conservation, native merge and mixed-peer rejection regressions pass.

Exact commands using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe from this project:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev43-vanilla-diff.json --approved-changes docs/DEV41_APPROVED_TAXONOMY_CHANGES.json
./Build-Workshop.ps1
./Prepare-WorkshopVdf.ps1 -OutputPath dist/workshop-publish/B47ANCEDQuartermaster-dev43-submit.vdf
```

Logs: dist/handoffs/dev43-tests.log and dev43-build-stage.log. Native corpus remains exactly the 625 approved deviations across 5,092 definitions. Offline != actual PZ/dedicated evidence. G6 native NOT TESTED; G7 dedicated BLOCKED / NOT TESTED; G8 readiness BLOCKED. User explicitly requested fixing and publishing; upload is a development testing candidate with limitations disclosed, never multiplayer certification. Publishing does not update a running remote server.

[RUNTIME GATE] Match client/server update and restart, reproduce the original player-inventory Sort, inspect the dev.42+ summary, verify server version, zero unexpected failures, preserved item identities and no duplicates/loss. Test actual delayed arrival, interruptions and an unavailable/full container. Native transaction consistency/item-count checks are still delegated to PZ and remain outside the offline fixture's proof.
