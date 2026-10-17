# Overall progress, full carries and native container sources

Project Version: 0.18.0-dev.5

Current-source note: the carry/source behavior below was introduced in 0.12.0-dev.1. The current iteration adds [Dangerous Load and the physical Supply Ledger](LEDGER_AND_LOAD.md); the normal comfort allowance remains unchanged. Dated 0.12 evidence retains its original version and does not prove native 0.13/0.14 behavior.

Compatible MINOR feature iteration from 0.11.0-dev.1. Storage schemas, native category resolution, presets, priorities, SupplyAPI 1 and required Rooms identity are unchanged. Movement capability increases from 8 to 9: update server and every client together, then reconnect. Older movement peers are rejected. This is development source, not a new Workshop publication.

## Carry and transfer behavior

[VERIFIED source] The server prepares one carry, the client loads it before walking, then unloads that carry before requesting another. Route Optimization on groups destinations by native room; off groups one destination container. Outdoor destinations use bounded nearby tile clusters. The nearest destination in the selected group is unloaded first. Existing hard priorities and live eligibility still apply. Carried-inventory sorting can deposit already-carried items while overweight.

The carry follows available comfort weight, equipped-bag reduction and native carrier capacity, with a technical ceiling of 400 operations. A planning slice examines at most 250 source items. A sufficiently filled group can start without enumerating the rest of the source. Native requests contain at most 100 operations. These are internal resource/protocol bounds, not speed settings.

**Vanilla transfer grouping and timing stay unchanged.** Small same-type items retain vanilla's smaller groups (up to 20 in the inspected implementation); heavier items retain their native behavior. A large carry does not become one giant native transaction. No native capacity, global action methods or Java classes are replaced. Native queue merging remains local to the owned batch.

If a destination rejects capacity before PUT authorization, the same carried item can be assigned to another matching permitted crate. Previously rejected crates are excluded to avoid cycling; pending reservations are included when choosing alternatives. If none works, the client may request a native return to the exact original source. Return requires live source identity, deposit permission, native capacity and proximity. Failed/uncertain dispatched transfers are not automatically replayed or rolled back. Capacity loss after PUT authorization can still leave affected items carried; known completed transfers remain credited.

Ground items have no verified original return container after native pickup. Player-inventory sources already hold the items. Those cases retain carried items if destinations fail. A removed, inaccessible, changed or full return source also leaves the item carried. Nothing is deleted, spawned or automatically dropped. A wholly rejected batch stops rather than silently discarding every later item; partial rejection preserves admitted work.

## Sandbox configuration

| Setting | Meaning | Existing-save default |
| --- | --- | --- |
| Extra carry allowance (CarryAllowance) | Additional comfort-weight budget for Sort and Collect; integer 0–40 kg. Native hard limits and restrictions still win. Encumbrance penalties/injury remain possible. | 0 kg |
| Optimize sorting visits (RouteOptimization) | One building/floor destination group per carry when enabled (nearby cells outdoors); one destination crate when disabled. | Enabled |
| SortBatchSize | Retired UI setting: saved values remain readable for compatibility but no longer slice a carry. | Ignored by the carry planner |

The server interprets shared settings and rechecks carry admission at TAKE grants. The allowance is not a personal client override. Root inventory weight and equipped-bag reduction are used; vanilla validates actual carrier acceptance independently.

## Two progress bars

[VERIFIED source] Progress.lua adds a local overall bar above the player while leaving vanilla's current-action bar intact. Auto Clean already supplies its own overall bar and is not modified by this change.

- Selected-source Sort measures processed eligible source items: confirmed deposits, confirmed failures and planning skips. TAKE alone is not a completed deposit. It shows preparation until the server supplies a source count.
- Room/building Sort uses one aggregate bar across all sources, including carried inventory/bags. Each source has equal weight; the active source contributes its item-completion fraction. This is source progress, not a claim that all sources contain equal numbers of items.
- Shopping uses authoritative remaining demand at start and subsequent server ledger snapshots. It measures fulfilled initial demand, not elapsed time or a guessed client item count. Unavailable supplies can end the job below 100%.

Actor/operation identity binds each bar; stale callbacks cannot remove a newer bar. Cancellation, completed jobs, actor replacement/death, disconnect and menu return remove it. Viewport-local projection, zoom/font sizing, clipping and input pass-through are tested offline. Actual overhead placement alongside vanilla/Auto Clean, split-screen, controllers and UI mods still require native acceptance.

## Native container support and clean-room boundary

[VERIFIED source] ContainerSources.lua accepts selected native vehicle storage parts and native inventory bags nested inside a vehicle part or an already discovered physical container. Ordinary world containers, carried bags and supported ground/proximity sources retain their existing routes. Vehicle/trailer sources use exact vehicle/part references, native storage access checks and the part's native walking area, including cargo areas far from vehicle centers. Locks/closed access are not bypassed or automatically opened.

The server captures a bounded bag-ID path and exact object/item references. Hints select a source; they do not supply destinations or rules. Native part ModData replication carries only an incarnation marker. Native loaded-square, safehouse, Rooms inspect/withdraw/deposit, exact identity, containment and capacity checks remain applicable. Vehicle movement/replacement, bag removal or access changes invalidate affected work. No persistent vehicle sorting configuration is added.

This supports native-container-backed KI5 cars/trailers and other models through their native interfaces. It does not automatically enumerate every parked vehicle during room/building sweeps or add vehicle destination designations. Fluid tanks and unverified virtual/custom storage backends remain unsupported. Compatibility with each actual mod/model is a runtime gate, not established by metadata counts.

[VERIFIED metadata] The read-only local Workshop census found 422 downloaded item folders, 112 relevant items, 97 with vehicle-storage declarations and 10 with inventory-container declarations. Counts include templates and alternate game-version folders; they are not effective runtime definitions. Examples include KI5 Containers! (2625625421), M998/M101A3 (2642541073), Oshkosh P19A/trailers (2566953935), Oshkosh M911 (2618213077), True Cargo (3806955469), Useful Pallets (3813053718) and Better Containers (3586216562). Exact public metadata/authors/version observations, links and relevant file fingerprints are in [the dated census](CONTAINER_SOURCE_AUDIT_2026-10-15.json).

Clean-room review checklist:

- Purpose: identify native storage interfaces missing from Quartermaster source selection.
- Inspected: public mod metadata and declarative container-block counts/fingerprints. No third-party Lua was loaded or executed.
- Neutral specification: accept exact native vehicle parts and nested InventoryContainer chains through verified vanilla APIs; fail closed for unsupported ownership/access models.
- Third-party code, assets and text imported: **NONE**. No upstream files were changed.
- Licenses/permissions: UNKNOWN for the surveyed external mods; no copying authorization inferred. Attribution/source provenance is recorded for research; redistribution obligations are not presumed waived.
- Review: author self-check completed; independent clean-room reviewer signoff remains pending on the PR. This is not a legal clearance or runtime certification.

## Supplied patch and bug evidence

The owner supplied B47ANCEDQuartermaster-carry-load.zip, SHA-256 `aebb8a0cda22f5fa52f2dfb32ba9f9c274b1a99c0ce2eab3843b420b44a64dce`. Its 40 entries passed CRC, duplicate/case-collision, traversal and symlink checks before file-level reconciliation. The ZIP and private client log remain outside tracked source. The patch's carry state machine was reconciled with the new progress/source/carry guards; it was not installed wholesale.

Additional corrections include source-deposit authorization for returns, bounded alternate reservations/no cycles, accurate partial completion, capacity filtering of undispatched queue entries, ground-source resolution after native TAKE, and preserving vanilla transfer groups as explicitly requested. Uncarryable items no longer reserve destination space needed by lighter items.

The supplied 0.11.0-dev.1 client log showed a destinationFull queue guard abort and carry/destination rejections. Its recipe failure called non-public InputScript.isValid. Installed native metadata identifies that method as **protected**, not public; supported input validation now uses public resource/amount/candidate APIs. Fingerprints are in [native evidence](PROGRESS_CARRY_NATIVE_EVIDENCE.json). Uncorrelated native inventory-container errors in that log remain UNKNOWN without the corresponding server trace. The log alone does not prove why every reported ammo-crate attempt failed.

## Authority and persistence

Server-owned sessions, source references, eligibility, routing, capacity, permissions and movement phases remain authoritative for Quartermaster grants. Clients queue verified native actions and confirm observed results; production Lua does not directly Add/Remove inventory items. Return confirmation is read-only and preserves a completed native outcome even after a later permission change. Client UI/HUD data cannot authorize a transfer. No new save migration is required; vehicle markers are native replicated metadata, not access credentials.

The accepted native PZ authority boundary remains: Lua planning/grant checks and client dispatch guards do not prove an atomic server Lua interception of every unrelated native inventory mutation. This work does not claim to secure arbitrary vanilla or other-mod transfers against room policy. Concurrent native changes can still reject a grant's eventual transaction; unknown outcomes stop safely.

## Validation and acceptance

[TESTED offline, Windows / Python + Lupa Lua 5.1] Run from the repository root:

```powershell
python -B scripts/check_versions.py
python -B tests/run_tests.py --require-rooms --rooms <verified-B47ANCEDRooms-checkout>
python -B scripts/check_deployment.py
git diff --check
```

The suite includes actual installed vanilla transfer constructor/start/update/validation/queue/perform code with simulated engine/network leaves. Tests cover 701-item deposits, 400-operation carry limits, loading before unloading, no overlapping carries, 601 items starting after one 250-item slice, native group limits, alternate/return conservation, denial/replay/cancellation/late responses, pending alternate capacity, equipped-bag/allowance limits, generic vehicle-area walks, nested storage identity and source invalidation. HUD tests use actual vanilla ISProgressBar with simulated projection/UI. Source manifest validation is not a built-package check.

[RUNTIME GATE] Actual PZ SP, subscribed-mod/model compatibility and dedicated two-client acceptance for this iteration are **NOT TESTED**. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED. The owner's earlier Quartermaster MP pass belongs to the earlier build and is not reused as proof here. No package, deployment, server/game launch or Workshop upload is authorized by this development pass.

Required live cases: default/raised allowance and native hard capacity; large ammo stacks; crate fills during walking and after authorization; safe source returns/return denial; concurrent deposits; cancellation/replication gaps/disconnect; locked/moved/removed KI5 cargo and trailers; nested bags; overhead bars at zoom/font/split-screen extremes; room/building aggregate progress; shopping partial/fulfilled/unavailable demand; recipe selection without repeated console errors. Measure first movement and transfer throughput on the dedicated server before claiming a runtime speed improvement.
