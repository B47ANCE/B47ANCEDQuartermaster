# Sort with a physical paper ledger

Project Version: 0.24.0-dev.2

## Player workflow

Create the initial paper ledger by consuming one whole vanilla Notebook, retaining the clipboard and pen/pencil. No loose page is needed. Existing blank, partial or completed ledgers are reused; sorting does not consume another notebook.

The default-on server option **SortUpdatesLedger** applies to inventory, selected-container, floor/proximity, vehicle-source, designated-room and building Sort. Carry a **pen or pencil**. The server first searches accessible, loaded physical storage in the player's native building for a completed Supply Sheet covering that location. Carried completed papers are also considered. A completed accessible ledger takes precedence over a carried blank/unfinished sheet; carried completed papers win over stored papers, then stored choices use distance and native item ID as deterministic ordering. Stale but completed papers can be used: this updates touched entries without renewing the whole building's freshness.

If the chosen completed paper is stored, the player walks there and **picks up that exact native item through the existing transfer executor** before sorting. This includes normal nested storage bags, using captured native bag IDs/references and the existing ContainerSources validation. Native access, removal, carrying weight and space still apply. A full inventory or changed/inaccessible chosen source fails visibly rather than cloning the paper or bypassing access. The paper stays carried after sorting. The search does not force-load chunks, sweep vehicles, inspect ground objects, or manufacture a paper.

If no accessible completed ledger is found, use a carried **blank or unfinished Supply Sheet**. A carried ledger in a carried bag is supported through native recursive ownership. Forged labels, corrupt/future records and papers for another scope do not become blank sheets. Outdoors, the existing safehouse scope can be used; where neither a native building nor a supported safehouse scope exists, report scope unavailable rather than creating a global ledger. Loaded/accessible search is the provable scope; no claim is made about unloaded or private storage.

The selected paper and writing supplies remain required during Sort and are protected from this mod's automatic transfers, including carried bags containing them. This is not a lock against manual/vanilla transfers. Paper loss, tool loss, access changes or scope changes stop new grants; already completed native moves remain completed. No item is dropped/deleted or forcibly rolled back by bookkeeping.

After the **entire successful job**, including all carried and physical sources of a room/building sweep, one native timed **writing action** records confirmed touched storage. It uses the vanilla book/paper pose used by ISWriteSomething and existing LedgerBaseSeconds plus LedgerEntrySeconds per prepared row. Transfer groups and timing are unchanged. A no-movement job needs no write, except that a confirmed ledger pickup itself can change its source storage. Canceled, failed or uncertain jobs do not write a success snapshot. Stopping writing leaves physical moves complete. A canceled/late dedicated result can be unconfirmed, so check the paper before repeating inspection; cancellation feedback alone is not proof that a server commit did not occur.

Only touched physical compartments are refreshed. Bag-source changes refresh their stationary physical parent; quantities retain the ledger's existing top-level native item/stack semantics, without inventing a flattened nested-inventory ledger. Ground/vehicle sources have no building storage entry, but their confirmed physical destinations are updated.

**Blank sheets stay partial.** Sorting does not claim to have inspected an entire building. Unvisited entries and the original whole-scope inspection/expiry timestamp remain unchanged; normal full inspection is still needed for a completed/fresh ledger. Shopping collection retains its existing fresh-completed-ledger/computer rule. Computers and installed software do not replace the required paper in this new Sort mode. Planning Shopping and computer installation are otherwise unchanged.

## Settings and compatibility

| Setting | Default | Behavior |
| --- | --- | --- |
| SortUpdatesLedger | true | Building-first paper search/native pickup, carried paper plus pen/pencil for all Sort, deferred writing. |
| RequireLedgerForSorting | true | Applies to the previous Room/Building freshness/computer rule when SortUpdatesLedger is off. |
| LedgerMode | 1 | Disabled (2) bypasses this workflow and removes the ledger requirement as before. |
| LedgerBaseSeconds / LedgerEntrySeconds | existing defaults | Reused for post-sort writing; no duplicate duration setting. |

These are authoritative server sandbox choices. Missing/invalid SortUpdatesLedger values keep the new behavior enabled; only explicit false opts out. Existing saves receive the default without deleting or rewriting saved records. All names/tooltips/statuses use the 29-locale English fallback policy. Meaningful configuration is server-owned; coordinates, scan/admission bounds and protocol limits are internal safety constraints.

MINOR development iteration from 0.20.0-dev.2: deliberate default gameplay change, no physical item IDs or ledger schema replacement. **Movement capability 12 and Ledger capability 5** require matching server/clients and reconnect. Ledger schema 1 remains readable, with an optional sortUpdated timestamp; old records retain their actual observations. SortUpdatesLedger=false restores the previous workflow. No existing artifact is relabeled or deleted.

## Server authority and persistence

Clients request preparation and next writing work with no submitted ledger identity, quantities, category counts, destinations or claimed completion. The server chooses the paper, retains exact native references, uses its own scope signature, and validates genuine snapshot bindings. Stored-paper pickup is a narrow server-owned withdrawal, independent of Shopping knowledge. New TAKE checks real membership, native capacity, current writer and current inspect/withdraw permission; the server confirms exact native carriage before allowing Sort. Existing incarnation-marked native descriptors and transfer reconstruction are reused. An unrelated item cannot be substituted for the selected paper.

SortLedger contexts are ephemeral, actor-owned and bounded. Trips binds a context to its server session/sweep and authoritative source set. Movement only records touched targets after native TAKE/PUT membership is observed. A grant or a client completion message alone is insufficient. All source trips must end with no outstanding operations before writing is offered. The ordinary unbound movePlan shortcut is refused in this mode; server-owned Trips remains the sorting path. Safe returns and read-only observations retain their prior behavior.

Before writing, bounded ContentAnalysis prepares current native contents of touched storage. Native action reconstruction is single-use and actor-bound, with the existing dedicated sender challenge/confirmation and authoritative native progress check. Completion revalidates paper ownership/binding/revision, writing tool, physical objects/compartments/markers, current inspect permissions, scope and exact analysis references/counts/types/quantities/conditions/weights/categories. Concurrent changes reject the whole write, rather than half-applying it. No new authority is inferred from an item ModData label or client UI flag.

The existing server ModData ledger registry owns persistence and media bindings. Completed writing constructs replacement entry/order tables without mutating old ones. An unshared paper snapshot reuses its ID with a higher revision. If another paper/CD or an unresolved conversion journal references it, copy-on-write preserves the old generation and binds only this paper to the new one. This avoids a new persistent generation for every ordinary Sort. Existing count/row/schema bounds still apply; failures preserve prior records. Item ModData is synchronized with syncItemModData after commit. Notification failure reports saved/pending and never replays the write as a new physical operation.

Disconnect/death/expiry cleanup cancels bookkeeping. A canceled pickup whose native outcome is unknown is observed without retry/rollback; its obsolete grant is retired after the bounded observation window. Late client offers are relinquished. Reconnect/server restart abandons unfinished ephemeral work and preserves the last committed snapshot; it does not automatically resume or claim success. Actual native save/restart/sync ordering still needs dedicated testing.

The accepted vanilla native-transfer authority boundary remains: Lua cannot retract an already dispatched transfer or lock unrelated vanilla/manual inventory actions. No Java/custom bridge, client-owned shared state or broader engine protection is introduced.

## Bounds and evidence

Server building search is incremental: at most 512 work units and a two-millisecond deadline per slice, four-millisecond tick budget, 16 contexts, 16 nested bag levels, 4,096 instances per container and 65,536 examined instances per search. Oversized or changed scans fail explicitly, never silently claim no completed ledger. World squares are not force loaded. The normal scope cursor, 4,096 touched-compartment and 32,768 row caps are retained. Post-sort analysis is incremental; final atomic row validation is bounded by those caps. All are implementation safety limits, not gameplay tuning controls.

Only native scope classification is cached up to one second; immediate scope containment and current permissions, real ownership, writing supplies and media revision are rechecked on grants. Destination ranking uses a lightweight scope hint after the synchronous planning slice's actor check; it never authorizes a native transfer. TAKE/PUT always perform the full check. No catalog or full-building item scan runs on every transfer. Native latency/frame/server-tick measurements are NOT TESTED; these structural bounds are not a performance claim.

[VERIFIED SOURCE] Installed Project Zomboid 42.21.0 / Steam build 25485521: existing native inventory transfer, exact item ownership, ModData synchronization, scope/room permission and challenged LedgerAction paths are reused. ISWriteSomething.lua lines 46-60 uses ReadType/book, CharacterActionAnims.Read, hand-model override and EventRead for paper writing; ISBaseTimedAction.lua exposes their wrappers. Fingerprints are recorded alongside this report. No game/third-party source bodies or assets were copied.

[TESTED OFFLINE, Windows / Python 3.12 / Lupa Lua 5.1] Full Quartermaster suite with actual Rooms 0.2.0-dev.6 and paired PC Framework 0.5.0-dev.2; focused server/client workflow fixtures. Fixtures verify building-first completed-paper selection over blank paper, native nested-bag pickup, no direct inventory mutation, carried blank/partial fallback, required/protected tool, exact native outcome observations, one write after both actual server area sources, copy-on-write CD preservation, unchanged expiry, unshared snapshot reuse, no premature/replayed write, tool/inventory change refusal, private-storage fallback, default/Disabled/explicit opt-outs, client pickup sequencing, no writing while movement runs, native-result-before-callback and late/canceled-offer cleanup. Existing native-shaped SP/MP pipeline/grouping, conservation, failed transaction, ground, vehicle and whole-sweep regressions remain offline evidence.

Commands from this feature worktree (host Python with Lupa; paths supplied explicitly):

```powershell
python -B tests/run_tests.py --only-sort-ledger --pc-framework <paired-PC-Framework>
python -B tests/run_tests.py --require-rooms --rooms <Rooms> --pc-framework <paired-PC-Framework>
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
python -B tests/test_deployment.py
git -c core.safecrlf=false diff --cached --check
```

Changed production paths: shared SortLedger.lua (new), Ledger.lua, LedgerMedia.lua, LedgerRequirement.lua, LedgerAction.lua, Movement.lua, Trips.lua, Protocol.lua, Authority.lua; client LedgerUI.lua, Sorter.lua, RoomSort.lua and SortControls.lua; sandbox-options.txt; 29 UI/Sandbox fallback pairs and current identity/mod metadata. Source manifest is 229 files. Tests, current feature docs, changelog, README, source overview and future Workshop text accompany the implementation. No package, local deployment, Workshop publication, game/server launch or merge is authorized here.

[RUNTIME GATE] G6 native client NOT TESTED; G7 dedicated multiplayer NOT TESTED/BLOCKED; stable G8 BLOCKED. Required: real building scan/pickup in storage/bags/across floors, full carry refusal, inaccessible and unloaded storage, paper/writer loss during walking/transfers/writing, two players contending for one paper/container, permission and room revision changes, native paper pose/cancel and progress, real item ModData synchronization, native save/restart/reconnect, and measured large-building search/write latency. Existing release evidence is not current proof for this feature.

Historical 0.21.0-dev.1 source receipt: **229 runtime files**, SHA-256 `223b296029e10acb7eec065ec33304f7c6b10379c63f2951c6fb03263a430d3e`; [native/source fingerprints](SORT_LEDGER_EVIDENCE.json). No current package was produced.

## 0.21.0-dev.2 recipe checkpoint

Compatible recipe correction: MakeSupplySheet now has one `Base.Notebook` input with native `mode:destroy`, replacing the loose-paper/notebook alternative. Keep inputs and single ledger output remain unchanged. No persistence/network schema change or new sandbox micro-setting for this ingredient correction. Physical Shopping Lists keep their separate sheet/notebook requirements.

[TESTED OFFLINE] `python -B tests/test_ledger_metadata.py`; `python -B scripts/check_versions.py`; `python -B scripts/check_deployment.py`; staged diff/source-receipt checks. The dev.1 full workflow suite above is historical, still applicable to unchanged sorting code but not relabeled as dev.2 execution. Native crafting/material consumption and dedicated G7 remain NOT TESTED; G8 BLOCKED. No package, deploy or publication.

0.21.0-dev.2 source receipt: **229 runtime files**, SHA-256 `faa25c504bfc88acb0bc7c2adbdb2a68cf7e2a67e8d841b426d1b9df9108db6b` (same algorithm; source only).

## 0.21.0-dev.3 polish checkpoint

Compatible fixes within the 0.21 prerelease; Ledger 5 / Movement 12 and saved schemas are unchanged. No new gameplay option is necessary: geometry, cancellation cleanup, invalid-candidate checks and distinct completion feedback repair existing behavior.

| Finding | Resolution | Offline evidence |
| --- | --- | --- |
| Carried fallback removed during incremental building discovery dereferenced a missing best target | Revalidate native ownership; a lost carried candidate cannot become an invented storage pickup | Reproduced nil lookup before fix; production bounded-scan fixture now returns SortLedgerRequired |
| A stored-ledger pickup moved the actor away before original-source discovery | Capture original square, return through native ISWalkToTimedAction, require completion at that square before continuation | Pickup/return ordering, unreachable return, cancellation, late callback and specific source-failure checks |
| Interrupted client writing could retire its server grant without a result, leaving actionPending busy | Notify the local coordinator on native cancellation; server still owns receipts and persistence | Reproduced failed cancellation completion; actual client LedgerAction.forceCancel now releases work exactly once |
| Writing warnings/errors were overwritten by generic Sort completion | Keep completed movement counts/status and pass a separate optional ledger outcome to final controls | Sync-pending, canceled writing and denied area-writing feedback tests; completed moves never relabeled failed |
| Setup drive remained occupied after installation and later CD removal | Release only the verified setup binding during successful server completion | Read and new burn grant work after the reusable Application CD moves away |
| Fallback Shopping paper row overlapped title/Add Item; mode changes could hide/resurrect controls | Separate paper row, explicit visibility, controller row and refreshed tooltip state | Active/fallback UI transitions, unique active focus rows, Import visibility and font geometry |

`LedgerUI.lua`, `Sorter.lua`, `RoomSort.lua`, `SortControls.lua`, `ShoppingUI.lua`, `ShoppingPaperUI.lua`, `SortLedger.lua`, `LedgerAction.lua`, `LedgerProgram.lua` and 29 UI fallback files are the production delta, plus version mirrors. Native groups/timing, inventory mutation, sorting rules, ledger recipes and peer/save schemas are preserved. PC Framework, Rooms, installed mods and game files were read-only.

[VERIFIED SOURCE] PZ 42.21.0 / Steam build 25485521 `media/lua/client/TimedActions/WalkToTimedAction.lua`: constructor accepts character/square, native pathfinding uses that square, setOnComplete is called only by perform, stop/forceCancel do not imply arrival. The return wrapper additionally refuses canceled work and validates the actor's actual square. This is not evidence of pathfinding success in-game.

[TESTED OFFLINE] Full paired regression suite and then the focused polish suite including final travel, feedback and data-drive assertions. Full suite covers Lua 5.1 syntax, sorting/conservation, native-shaped SP/MP actions, ground/vehicle/container sources, Rooms integration, PC app/clipboard UI, localization and source/package fixture checks. Commands:

```powershell
python -B tests/run_tests.py --require-rooms --rooms <Rooms-0.2.0-dev.6> --pc-framework <paired-PC-0.5.0-dev.2>
python -B tests/run_tests.py --only-polish --pc-framework <paired-PC-0.5.0-dev.2>
python -B tests/test_ledger_metadata.py
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
python -B tests/test_deployment.py
```

[RUNTIME GATE] Native pixels/focus, pickup/return pathfinding, interruption/network result ordering, real installation/data-CD transition, reconnect/restart and dedicated peers remain NOT TESTED. G6/G7 NOT TESTED; stable G8 BLOCKED. Existing allocation enforcement/live role routing remains intentionally disabled and the shelf/3D experiment remains out of scope. No package, deployment, publication or game/server launch performed.

Current dev.3 source receipt: **229 runtime files**, SHA-256 `18cfee8629566d1b428eab31654ac4940409da678b45ecbb9f0ba10329daae3f` (algorithm above; source only).

## 0.21.0-dev.4 action-confirmation checkpoint

Rejected/rate-limited/unconfirmed native challenge replies now finish the current tagged work with its actual reason, rather than silently canceling the coordinator. Callback delivery is guarded before native stop, and late/duplicate/replaced-operation responses are ignored. Completed Sort transfers remain successful; a later writing error remains the separate ledger outcome. Program installation notification failure separately reports committed/pending instead of failing the action. See [the correction and tests](APPLICATION_CD.md#0210-dev4-confirmation-and-notification-correction).

Validation commands (from this worktree, using the paired dependency checkouts):

```powershell
python -B tests/run_tests.py --only-program --pc-framework ../../pc-quartermaster-program/B47ANCEDPCFramework
python -B tests/run_tests.py --require-rooms --rooms ../../../B47ANCEDRooms --pc-framework ../../pc-quartermaster-program/B47ANCEDPCFramework
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
python -B tests/test_deployment.py
```

These tests are offline; actual PZ/dedicated G6/G7 remain NOT TESTED. No source package/deploy/publish performed. The previous dev.3 source receipt and full-suite result above remain historical.

Dev.4 source receipt: **229 runtime files**, SHA-256 `d61e908eb23eac253966dc82381a11a334f3872e32600729623207571e2ce756` (same algorithm, source only).

Publication preparation corrects only mod.info/player-facing release prose; the runtime-code checkpoint above remains 458857d. Candidate source (including corrected metadata) SHA-256: `a5503445542288a4434f9fb47eba5d05b0b92d33a82fcb6883ec2f20bee697ce`, 229 files. Dependency distribution remains pending; package validation does not authorize an unavailable required dependency.
