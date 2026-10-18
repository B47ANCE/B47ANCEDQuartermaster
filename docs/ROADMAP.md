# Roadmap

Project Version: 0.20.0-dev.1

Current designated-only scope correction: native room selectors/requests are retired; B47ANCEDRooms designations provide room identity and native buildings provide building scope. Quartermaster Rooms capability is 4; movement remains 11. Existing ledger signatures, upstream complete-footprint configuration permission and provider-capability checks remain. Enforcement/live role routing stay disabled. [Exact validation and limitations](DESIGNATED_ROOM_SCOPES.md).

## Ledger freshness — current 0.17 source iteration

Inventory/selected-container Sort is independent of ledger possession. Room/Building jobs retain server-validated fresh scope checks. Four ledger modes, in-game update days, manual/automatic computer updates, immutable renewal generations and bounded read-only live projections are implemented. Current branch: `feature/ledger-freshness`, from `2cac3ae5497bdbf793e119d12f3ef61ceb457457`; current manifest: 211 runtime files. No package/deployment/publication/game/server launch. [Exact policy, validation and pending runtime gates](LEDGER_FRESHNESS.md). G6/G7 NOT TESTED; stable G8 BLOCKED.

Earlier iteration sections below retain their original publication/validation context and do not describe this source-only iteration.

## Current development iteration

Save now keeps the container-rule editor open, refreshes acknowledged records/rail state and reloads an invalidated inherited section when necessary. Existing server save/permission behavior and manual close/Cancel are preserved. Current focused UI regression and syntax checks pass offline; native acceptance remains NOT TESTED. See [exact checks and workflow](MULTI_CONTAINER_UI_IMPLEMENTATION.md). Physical-shopping implementation/full-suite evidence remains from 0.16.0-dev.1 and is unchanged by this local UI fix.

Physical shopping papers, list selection/renaming, retained writing supplies, explicit preserved-data import and the held notebook-paper HUD are implemented for offline validation. Preserve native grouping, supply-ledger collection requirements and the separate Auto Clean project. Native client visual/input acceptance and dedicated trading, reconnect, restart and collection acceptance remain mandatory. See [current report](PHYSICAL_SHOPPING_LISTS.md).

## Separate Auto Clean and supply API — historical 0.11.0-dev.1

Clean Building's production modules/menu/jobs now belong to B47ANCEDAutoClean. Quartermaster provides SupplyAPI 1 for configured storage, live permission/capacity checks and exact native transfers. Auto Clean requires Quartermaster and Rooms; no reverse dependency was added. Storage/save schemas and Rooms sandbox settings remain unchanged. See [current contract and validation](SUPPLY_API.md). This extraction is not deployed or published. SP/dedicated acceptance remains NOT TESTED; G7/stable G8 BLOCKED. Earlier embedded-cleaning sections below are historical checkpoints.

## Single-player Clean Building — historical 0.10.0-dev.1

Lua-only SP support now queues the retained guarded Job/Poc native actions locally. Exact local-player binding, Rooms settings/permissions, supply locks, measured recipe and cross-level footprint checks remain active. Multiplayer command authentication and reconstruction are unchanged. Offline SP/native-Lua regression tests pass; real PZ SP and dedicated acceptance remain NOT TESTED, G7 and stable G8 BLOCKED. See [SP design, exact validation commands and runtime gates](CLEAN_BUILDING_SINGLE_PLAYER.md).

The earlier version sections below are historical checkpoints. Their disabled-SP status and prior publication/restart observations do not describe the current source.

## Required Rooms dependency — 0.9.0-dev.1

Rooms (Mod ID B47ANCEDRooms, Workshop 3820077442) is now mandatory in native mod.info metadata and Steam Required Items for Quartermaster and its embedded Auto Clean. This breaking 0.x dependency change preserves Lua gameplay, server guards, schemas and protocols. Both peers must enable Rooms. Source/package/version checks must pass before the authorized MP testing upload; native/dedicated G7 NOT TESTED and stable G8 BLOCKED. Earlier checkpoint sections below retain their original optional-dependency context.

## Rooms extraction and scoped sorting — 0.8.0-dev.1

[VERIFIED source] B47ANCEDRooms is an optional standalone service. It owns room IDs, geometry, overrides, editing, delegated policies and persistence. Quartermaster owns physical discovery, furniture, configuration, planning, Shopping/Dibs and native transfers. Without Rooms, native room/building sorting and vanilla safehouse checks remain available. An installed incompatible/unavailable Rooms service fails closed.

[TESTED offline] The production-path room sweep includes the full player inventory and unequipped carried bags before configured physical sources: 24 exact moves and 33 skips. A second whole-building sweep moves two further items without revisiting correctly sorted stock. The actual standalone Rooms API is exercised for action-specific permissions, privacy, revocation and invalidation. These are Windows Lua 5.1 fixtures, not native multiplayer evidence.

[RUNTIME GATE] Native rendering/controller/scaling, actual save/load and two-client dedicated ownership, permissions, sorting, reconnect/restart and conservation tests are NOT TESTED. G7 and stable G8 remain BLOCKED. No deployment, publication or game/server launch. Development artifacts are offline test packages only. Both Quartermaster peers require configuration 5, movement 8 and rooms 2; Rooms uses its separate API/protocol 1 and registry schema 2. See [current design and validation](ROOMS_INTEGRATION.md).

## Historical custom room development — 0.7.0-dev.1

[VERIFIED source] Custom rooms are server-owned logical tile regions with creator/current safehouse-member editing, revision-checked atomic writes, and exact physical-container membership. The in-world editor provides bounded structural/native candidates, rectangles, paint/erase, undo/redo, duplicate, combine, split, rename and delete. All geometry remains a preview until confirmed. Native world geometry is never modified.

[TESTED offline] The full source regression suite, 133-file production inventory and installed native category comparison pass. The three-container room sweep moves 20 misplaced items exactly once, preserves 28 correct/already-seen items and retains the installed native queue Lua path. Host fixtures do not prove game behavior. Both peers require configuration capability 4, movement 7 and rooms 1; existing config schema 2/world root 1 are unchanged.

[RUNTIME GATE] Native visual/controller acceptance, remodeled/open-door boundaries, real save/load and two-client dedicated authority/reconnect/restart tests are NOT TESTED. Dedicated G7 and stable G8 remain BLOCKED. No package, deployment, publication or game/server launch for this iteration. See [custom room design, controls and exact validation commands](CUSTOM_ROOMS.md).

## Historical 0.6.0-dev.3 category lookup and MP test distribution

Compatible PATCH dev.3 checks getter availability before native category lookup. The missing-method regression fails before the change and passes afterward, preserving categories and server authority. Includes the dev.2 transfer correction below. The user authorized packaging and Workshop MP test distribution; the release manifest/receipt records the actual commit, hashes and upload outcome. Native catalog/transfer speed and dedicated acceptance remain NOT TESTED. See TRANSFER_THROUGHPUT.md. No local live deployment or game/server launch.

## dev.2 transfer throughput correction (retained source work)

Aggregate per-phase movement requests preserve individual server checks while reducing message overhead. Ready batch phases dispatch without quarter-second polling gaps; vanilla action timing is unchanged. See TRANSFER_THROUGHPUT.md for measured offline overhead, authority boundaries, exact commands and pending runtime gates. A separate observed batch-guard stop is instrumented with precise reasons; no runtime fix is claimed. No deployment/publication.

## Current native-only storage cleanup

Server-only, one-way sorting-data retirement removes obsolete categories/formats while preserving native rules, explicit items, priorities, owned preset generations and whole-container identities. Retired taxonomy modules are excluded from runtime. Foreign LSBox registries and unrelated personal/gameplay state remain untouched. See NATIVE_CATEGORIES_COMPATIBILITY.md for exact scope, protocol versions and validation. Runtime/dedicated acceptance pending; no deployment/publication.

Historical implementation notes below describe their original versions, not the current category architecture.

## Current dev.25 ground source implementation

Lua-only explicit Floor and resolvable aggregate sources are implemented. Short-lived server references, native queued acquisition and observed carrier/destination confirmations preserve the native PZ authority boundary. Movement capability 3 requires matching builds. Native Proximity Inventory UI and dedicated transfer acceptance remain unverified: G7 NOT TESTED/BLOCKED; G8 BLOCKED. No deployment/publication. See [details and native gates](DEV25_GROUND_SOURCES.md).


## dev.21 Category failure investigation

User confirms dev.20 loaded but visible Category labels remained vanilla with Neat UI. Added OFF-by-default bounded boundary diagnostics; no new renderer or gameplay changes. Full offline suite and 5,092-entry zero-change comparison passed. G6 diagnostic acceptance BLOCKED, G7 NOT TESTED, G8 BLOCKED. Bulk-transfer/collision native audit is separate and implementation remains outstanding. See `dist/handoffs/dev21-category-investigation.md` and `dev21-bulk-and-collision-audit.md`. Published dev.20 remains unchanged.

## dev.20 Inventory Category column hotfix

Compatible PATCH correction on dev.19: Category cells use the canonical resolver cache and current localized labels. Compatibility is checked during rendering rather than permanently skipping registration during early Lua loading. Native row.cat, sorting, grouping and item definitions stay unchanged. Full offline regression and frozen 5,092-item comparison passed; actual B42.21 inventory/loot/controller/scaling and second-language client acceptance remain UNTESTED. Dev.19 Stage A instrumentation is retained; its dedicated timing gate remains BLOCKED. See `dist/handoffs/dev20-inventory-category.md`. No deployment or publication.

Current source version: 0.20.0-dev.1. Native-only storage retirement is the current development candidate. See NATIVE_CATEGORIES_COMPATIBILITY.md for validation and limits.

Historical note: Recorded source snapshot: 0.4.0-dev.50. Stage A adds bounded correlated Sort timing, immediate preparation acknowledgement, and independent B47 carry-allocation regression. Background destination-index optimization awaits correlated native root-cause evidence; no gameplay/cache decisions changed. See `dist/handoffs/dev19-responsiveness.md`. Native dedicated timing remains BLOCKED.

Historical dev.15 definition-based modded classifier audit and optional Mod grouping are implemented for offline review. Placed-item protection is blocked at its native authority/source-path gate. The dev.14 discovery/building, hierarchy and inventory Category presentation pass remains pending runtime review. Next: native SP first-open discovery and Sort transfer acceptance, then native SP and 1080p/1440p/2160p display acceptance, listen and dedicated two-client G7 tests, then G8 review. Verify server activated-Mod-ID API and Better Containers non-category coexistence if its source/runtime is available. No taxonomy or saved-data changes are planned.

Standalone source now owns the frontend, preset library, icons, server rules and native movement. Remaining work is native standalone/dedicated acceptance and any explicitly approved legacy preset-definition migration, tracked in MASTER_HANDOFF_STATUS.md. Deployment/publication require explicit authorization. Entries below are historical milestones.

- 0.1.4: bulk/range controls, category/mod/item search, metadata-based mod subgroups and effective item-name count implemented and host-validated. Published to Workshop item 3807217050 on 2026-09-24. Native and multiplayer acceptance pending; local live-mod deployment unchanged.

- 0.1.0: standalone instance adapter, approved conversion and tri-state hierarchy, filters, stable scrolling, controller support, localization and host regressions.
- Native acceptance: rendering/hitboxes, wheel/scrollbar, controller focus and preset editor, save/restart/removal, large database.
- Multiplayer acceptance: hosted and dedicated clients, unchanged Save authority, replication, late join and preset conflicts.

No automatic launch, live deployment or Workshop publication. Optional persistent expansion and expand-all are outside this initial slice.

## dev.23 container presentation checkpoint

[TESTED — offline] Full regression and package checks passed. dev.22 tooltip positioning/lifecycle retained. Container rail uses current validated physical-object sprite textures with generic fallback, instance caches and bounded optional diagnostics. Presentation only; taxonomy 6, configuration schema 2 and movement protocols unchanged. [RUNTIME GATE] Actual native UI/sprite acceptance and dedicated two-client visual comparison are not tested; overall G7/G8 remain BLOCKED. Category-column investigation, bulk movement and collision recovery remain outstanding. Dev.23 subsequently published as a user-authorized development testing build; local live installation unchanged. Native gates remain pending. See `dist/handoffs/dev23-container-presentation-report.md`.

See [dev.24 pipeline implementation and runtime gates](DEV24_PIPELINE.md).

## dev.26 scope and furniture candidate

See [DEV26_SCOPES_FURNITURE.md](DEV26_SCOPES_FURNITURE.md) for current ownership, persistence, migration, UI behavior and acceptance gates. Offline evidence does not establish native persistence or dedicated multiplayer readiness. G6 NOT TESTED; G7 BLOCKED; G8 BLOCKED.


Current dev.27 UI remediation and bounded route candidate: [implementation, offline evidence and pending native gates](DEV27_IMPLEMENTATION.md). Calibrated native travel-time optimization remains pending.


Current dev.28 resizable-window candidate: [native audit, implementation and pending acceptance](DEV28_WINDOW_LAYOUT.md). Presentation only; inventory category adapter unchanged; no deployment/publication.


Current dev.29 independent tracks: [category audit/blocker and adjustable appearance implementation](DEV29_CATEGORY_AND_APPEARANCE.md). Category integration remains unresolved; transparency passes offline checks only. Native acceptance pending; no deployment/publication.


Current integration: see [ALLOCATION_INTEGRATION.md](ALLOCATION_INTEGRATION.md).

Implemented source/offline in 0.20.0-dev.1: approved computer table/selected details and writer-host completion routing, paired with the framework's common CRT desktop, Start menu and retained taskbar sessions. Native pixel/input and dedicated acceptance remain blocked. Arbitrary drag/snap, multiple SDK windows per app and new shared gameplay apps remain separate work.
