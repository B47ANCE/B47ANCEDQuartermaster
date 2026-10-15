# Unified hierarchical allocation development

Project Version: 0.9.0-dev.1

[VERIFIED SOURCE] This development iteration adds one sparse percentage model to the existing picker, container configurations, Whole Container inheritance, shared presets and optional Rooms profiles. **Allocation enforcement and room-role routing are not active in this build.** The server setting offers Off or Shadow (default Shadow); legacy sorting remains authoritative. `AllocationRuntime.enforcing()` is deliberately locked false until native compatibility and dedicated acceptance establish the new path. UI notices say that percentages are previews, not enforced limits.

[TESTED OFFLINE] Host Lua 5.1 regression, paired production Rooms API, native-shaped capacity/admission, migration, UI lifecycle, role-ranking and binary32 oracle tests. [RUNTIME GATE] No game/server was launched; native client G6 and two-remote-client dedicated G7 are NOT TESTED; stable G8 BLOCKED. Development packaging only; no installation, server, Workshop staging or upload changes.

## Baseline and compatibility

Quartermaster starts at 0.8.0-dev.1 commit 807b92ad95ce2445ec079219e62b1b3351aaf3fa. Rooms starts at 0.1.0-dev.1 commit fb500117ebf6f6f0444c15cce32cea2ce3ad7a3d. Installed game evidence is Build 42.21.0. Target development versions are 0.9.0-dev.1 and 0.2.0-dev.1: additive MINOR development features, with explicitly incompatible new client protocol/configuration writes in the 0.x lifecycle. See ALLOCATION_BASELINE.md for pre-edit source contracts.

Taxonomy protocol remains 7; no owned taxonomy is restored. Configuration capability is 6, preset capability 3, allocation capability 1; movement remains 8 and Rooms integration 2. Configuration schema is 3 with schema-2 decoding. Physical object root remains schema 1. Preset libraries and furniture parent records write schema 2, read 1/2. Rooms API/protocol remain 1, registry schema 2. Old peers must not write new profiles; handshake checks reject unsupported families.

## One model and the actual hierarchy

`AllocationProfile` stores `{schema=1, default=100, cats={}, items={}, paths={}}`. Percentages are finite whole numbers 0–100. Categories use canonical native IDs; item overrides use exact FullType. Paths record recovery context for unresolved overrides, not a parallel item classifier. The active provider is flat native category → optional mod heading → item; mod headings are presentation only. Synthetic nested-category tests establish the algebra, but the example Food/Perishable/Raw Meat taxonomy is not invented in the shipped resolver.

Changing a parent category stores its explicit aggregate ceiling and removes descendant category/item overrides; siblings survive. Item edits affect one FullType. Nearest ancestor supplies the displayed inherited value; all explicit ancestor aggregate ceilings and the explicit item ceiling apply independently against the same capacity, never multiplied. A default is an inherited per-item ceiling only when no explicit ancestor/item ceiling applies. Mixed is derived, never persisted. No profile means no extra quota. Profiles constrain the old native/name rules; they never select additional destinations, grant access, or reinterpret unchecked rows as exclusions.

Legacy duplicate display names retain their shared boolean selection. Virtual exact-FullType subrows permit independent percentages. Parent propagation intentionally affects the complete category branch; existing visible-row boolean operations retain their old visibility semantics. Unknown allocation keys persist; the allocation context menu lists bounded orphan-removal actions with preview/confirmation. More than 32 orphans can be removed in successive menu openings; no automatic deletion occurs.

## Editor and presets

The existing Adapter/Picker shell draws only visible percentage tracks; it creates no widget per catalog item. Drag uses 5% steps and one capture; clicking the numeric value opens exact input. Alt+Left/Right adjusts 5%, Alt+Enter opens exact input, and controller A on the room editor opens its allocation menu. Container controller users reach allocation actions through the existing context/bulk menu. Indicators: `L` legacy, `~` inherited, `=` explicit, or Mixed. Search, expansion, staged state, scroll identities, native icons, resize/divider/transparency and legacy item counts are preserved. Native rendering, large-font and controller acceptance remain NOT TESTED.

Allocation metadata comes from a bounded authoritative catalog job, reused from the prepared catalog in SP. No network/catalog request is issued from draw callbacks. Client-local category groups cannot establish server aggregate quotas: those controls show unavailable; exact item overrides remain the Lua-only alternative. Metadata retries are timed, not per-frame. Configuration writes occur only on explicit Save.

Allocation profiles can be saved through the existing shared preset editor, applied with a change preview and confirmation, reset, or discarded with the editor. Rename changes a display label without changing generation-bound saved links. Duplicate creates a new generation/owner. Applying an allocation profile replaces the local percentage profile only: existing legacy selections/exclusions, linked presets, priorities and Whole inheritance remain. Linked numeric conflicts use a deterministic restrictive minimum; explicit local keys override linked keys on the same node. Preset editing/deletion keeps existing owner/admin checks.

Fourteen room-type templates materialize only native IDs actually present in the authoritative catalog: Kitchen, Pantry, Medical, Armory, Workshop, Garage, Library, Bedroom, Bathroom, Laundry, Storage, Garden, Electronics, Utility. Native category spelling was inspected in installed scripts, including Water/WaterContainer and Communications. Unmapped optional-mod categories are not guessed: the template reports unavailable/missing mappings and custom presets can use actual categories. Templates add constraints only; they never configure every physical container or invent refrigeration.

## Capacity and authority

Native evidence: ItemContainer.getEffectiveCapacity(player), getCapacityWeight(), getContentsWeight(), hasRoomFor(player,item), isItemAllowed(item), and InventoryItem.getUnequippedWeight(). Ordinary physical storage sums actual instances once with native binary32 accumulation. Nested weight is already included by the getter; bag children are not counted recursively again. Native two-decimal admission correction stays inside hasRoomFor; quota ceilings use double arithmetic `C*P/100` without rounding upward. Normal/subnormal/ties and 4,096-instance accumulation are tested against Python's independent binary32 oracle. Installed Kahlua MathLib contains frexp/ldexp; this is source evidence, not native invocation.

Snapshots are non-yielding and must reconcile captured binary32 weight with native used weight. Missing getters, incomplete/unloaded geometry, changed object lists, inconsistent contents, deadlines and limits yield unknown, never partial quota authorization. Bounds are implementation safety limits: 256 physical compartments, 4,096 instances per compartment, 32,768 total instances, 16 overlapping active room profiles; 8 ms snapshot/admission work windows. A supported-scope failure does not alter the legacy sorter in Shadow mode. Special/dead-body/custom storage with unreconciled semantics remains unavailable for quota admission.

Each room denominator includes only deduplicated, actor-authorized physical compartments whose native restrictions and legacy rules accept the routed item and whose container profile has no applicable 0%. Full compatible storage still contributes its theoretical effective capacity. Logical Whole parents, floor inventories, placed objects, bags-as-destinations, unavailable or incompatible storage add no capacity.

Room aggregate occupancy is a trusted server-internal count across all supported physical storage in the room, including opaque compartments. Opaque storage contributes no capacity and is never exposed/bound or used as a destination. This conservative choice prevents different authorized actor subsets from double-spending a shared aggregate allowance. Metadata/configuration RPCs do not read private contents. Only internal advisory/admission accounting reads those weights; no private contents/counts are returned. An intra-room move already counted in aggregate occupancy has no additional quota growth; it cannot bypass a hard 0%. Existing over-limit stock is never evicted, dropped or deleted.

Server admission primitives validate exact retained item/target, current permissions/configuration/revisions, native capacity, room revisions, all room/container ceilings and pending reservations. One bounded global ledger covers actors, scopes and exact references; replay does not spend twice. Unknown issued PUT reservations remain until destination observation or fixed grant expiry; no retry/rollback/credit is inferred. Store and room revisions are stamped and stale admission is rejected. The production grant hooks are present behind the closed activation gate. Live grants and transfers continue to use the legacy pipeline. Lua does not establish interception of unrelated vanilla actions or of every final native mutation; this build makes no absolute lock/security claim.

## Optional Rooms and role routing

Rooms owns IDs, complete geometry, native aliases, ownership, type, designation and action-specific permissions. Quartermaster owns profile storage at `ModData.B47ANCEDQuartermaster.roomAllocations` (schema 1), profile/library revisions, thresholds, priority and generation-linked presets. Room metadata changes never move inventory. Room configuration requires authority plus vanilla configuration permissions throughout the relevant loaded geometry. Native room corners/holes cannot substitute for full membership. Aliases retained by native overrides/merges preserve old profile identities; multiple surviving profiles are separately editable and all active overlapping profiles must allow a deposit. A changed room revision requires review/save of its profile.

Room Allocation Profiles is available from the container scope menu when the new Rooms capabilities are ready. It reuses the same allocation picker with percentage-only rows, staged active state, priority and thresholds, reset/type defaults, preset application, cancellation and a revision-bound Save. Vanilla native profiles are manually configurable after complete geometry/permission preparation; room-type/designation metadata belongs to managed/native-override records in Rooms. No native room name or geometry is changed by Quartermaster.

Without Rooms, container/Whole profiles and existing native area sorting remain. Saved room profiles are dormant. Installed-but-unready Rooms fails closed for protected operations.

Advisory ranking preserves existing explicit item/category match rank, then hard container priority, then room role preference and room priority, then distance, stable room ID and existing physical token. Same-type Primary and Secondary pools deduplicate physical compartments within each role; overlaps across roles remain organizational membership, never extra physical capacity. Multiple same-role thresholds use the lowest explicitly configured threshold in that role. Defaults for new profiles are server sandbox Primary 60%, Secondary 80%; existing explicit values survive changes to defaults. Secondary at/above return prefers Primary; otherwise Primary at/above overflow prefers Secondary; otherwise Primary. Missing/full/ineligible preferred pools fall back to remaining valid candidates. Role preference is calculated once per bounded advisory comparison; it does not switch live routes item by item because live role routing is gated off.

## Shadow comparison and diagnostics

Planning enqueues at most one sample per actor every two seconds, with eight queued samples globally. Jobs scan complete geometry cooperatively, at most four jobs/64 steps each inside a shared 4 ms tick window; snapshots have their own deadline and never block the first legacy move. Samples whose source changed are discarded as unknown. Counters distinguish quota/capacity/permission rejection, unknown scope, expected explicit-limit differences, advisory priority changes and unexplained differences. No inventory mutation is used. Diagnostics are SP/admin only, bounded counts/timing without item identities or coordinates. No native shadow capture has yet explained actual live differences; that remains an activation gate.

## Persistence and rollback

Schema-2 reads do not trigger schema-only rewriting. Explicit schema-3 save preserves the original envelope in owned allocationBackups. Existing obsolete-format retirement keeps its former semantics but now snapshots original owned roots/rules before replacement; furniture and preset cleanup similarly retain original recovery data. Whole profiles inherit live through exact physical compartments; child override/reset/removal retain complete profiles and backups. Unknown allocation keys and paths persist. Configuration priorities, preset generations and foreign ModData remain intact.

Older versions are not safe readers/writers of schema-3 configurations, schema-2 presets/parent records or room profiles. Rollback requires offline restoration of the pre-migration owned snapshots and matching old source/version; automatic downgrade is unsupported. Never test destructive migration/rollback on real player saves. Offline reload fixtures do not prove disk persistence, client reconnect or dedicated restart.

## Validation and performance

Commands from this worktree (host Python with original .test-deps on PYTHONPATH):

- `python tests/run_tests.py --require-rooms`
- `python tests/benchmark_allocation.py`
- `python scripts/check_versions.py`
- `python scripts/check_deployment.py`
- After authorized ZIP creation: `python scripts/check_deployment.py --package` and `python scripts/check_versions.py --release`.
- Rooms sibling: `python tests/run_tests.py`, `python scripts/check_versions.py`, then `python scripts/build_dev.py` for its development ZIP.

Measured host scenario: 8,192 definitions / 256 containers / 8,192 captured instances. Setup 83.840 ms; 200 sparse edits 167.863 ms; 100,000 value lookups 122.895 ms; 1,000 full admission arithmetic checks 907.790 ms; 100 combined room scopes 212.097 ms; retained Lua growth after GC 35.938 KiB. These are host fixture numbers, not native frame-time/server-tick measurements or a proven transfer speed improvement. Final completion/provenance records bind exact committed source and artifacts.

## Remaining native gates

Enforcement activation, live role routing, real two-client reservation exhaustion, native grant cancellation/late outcomes, full item conservation, capacity modifiers/special containers, room geometry changes while walking, real save/reconnect/restart, optional-mod category parity, visual large-font/controller acceptance, and native tick/throughput measurements remain NOT TESTED. G6 NOT TESTED, G7 NOT TESTED/BLOCKED, stable G8 BLOCKED. Stage O development packaging is not acceptance or publication.

## Authorized upstream reconciliation

The user approved reconciliation in fresh isolated worktrees. Current base 06c11c5a40d9494e6cdc2bc05f907344620cf579 includes upstream Auto Clean changes. Original allocation worktrees and patch/untracked-file hash snapshots are preserved under the sibling allocation-reconciliation directory. Incoming cleaning APIs, policy actions, UI/translation keys, tests and source inventory are retained; this allocation feature does not redesign them. Their previously published evidence remains historical.

Explicit physical-compartment capacity inspection is on demand, requires inspection permission before any inventory read, reports bounded over-limit rules and is advisory. Configuration-only metadata RPCs remain free of contents reads. Room-wide private occupancy is never returned as an inspection summary. Preset-local previews use their own pending profile; async container previews are bound to the original selected target and are discarded if selection changes. Metadata retries stop after 30 attempts and can be restarted explicitly.

Paired-development Rooms 0.2.0-dev.1 (Workshop identity 3820077442) is required for new allocation metadata APIs. The currently published 0.1.0-dev.1 cleaning API is historical distribution evidence, not proof that the new allocation editor is installed. Final paired worktree is the sibling allocation-final/B47ANCEDRooms; all runtime bytes match the tested paired worktree.

Final publication-link reconciliation base: caa75c75a58cc491d468d827e58e1d0a5e36b043. Final paired roots are allocation-final/B47ANCEDQuartermaster and allocation-final/B47ANCEDRooms. Runtime bytes match the completed offline/package validation exactly. Original worktrees remain preserved.
