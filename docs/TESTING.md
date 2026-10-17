# Testing

Project Version: 0.19.0-dev.1

Current computer hosting is supplied by the required **B47ANCED PC Framework**; Quartermaster registers its ledger reader and CD Writer as apps. Existing ledger/drive data and server permissions are preserved. See [extraction, setup and current evidence](PC_FRAMEWORK_INTEGRATION.md).

Current designated-only scope correction: native room selectors/requests are retired; B47ANCEDRooms designations provide room identity and native buildings provide building scope. Quartermaster Rooms capability is 4; movement remains 11. Existing ledger signatures, upstream complete-footprint configuration permission and provider-capability checks remain. Enforcement/live role routing stay disabled. [Exact validation and limitations](DESIGNATED_ROOM_SCOPES.md).

## Ledger freshness — current 0.17 source iteration

Inventory/selected-container Sort is independent of ledger possession. Room/Building jobs retain server-validated fresh scope checks. Four ledger modes, in-game update days, manual/automatic computer updates, immutable renewal generations and bounded read-only live projections are implemented. Current branch: `feature/ledger-freshness`, from `2cac3ae5497bdbf793e119d12f3ef61ceb457457`; current manifest: 211 runtime files. No package/deployment/publication/game/server launch. [Exact policy, validation and pending runtime gates](LEDGER_FRESHNESS.md). G6/G7 NOT TESTED; stable G8 BLOCKED.

Earlier iteration sections below retain their original publication/validation context and do not describe this source-only iteration.

## Current development iteration

Authorized Workshop MP test preparation now has a 209-file package/source/staging parity PASS, full offline build/regression PASS and a separate paired test against the actual Rooms checkout PASS. The default build runner reports its sibling Rooms path unavailable in this isolated worktree; the explicit paired invocation supplies the real checkout and passes. Native SP/dedicated acceptance remains NOT TESTED. See [publication preparation and artifact identity](WORKSHOP_TEST_0_16_0.md).

Save now keeps the container-rule editor open, refreshes acknowledged records/rail state and reloads an invalidated inherited section when necessary. Existing server save/permission behavior and manual close/Cancel are preserved. Current focused UI regression and syntax checks pass offline; native acceptance remains NOT TESTED. See [exact checks and workflow](MULTI_CONTAINER_UI_IMPLEMENTATION.md). Physical-shopping implementation/full-suite evidence remains from 0.16.0-dev.1 and is unchanged by this local UI fix.

Physical paper, native-action-shaped, collection, UI/HUD and full host regression checks are recorded in [the current report](PHYSICAL_SHOPPING_LISTS.md). Legacy movement fixtures explicitly use the supported physical-list/server-ledger opt-outs; new paper fixtures exercise the enabled paths and production handlers. Source manifest: 209 runtime files. The source-only implementation evidence predates the now-confirmed Workshop MP test publication; no local deployment occurred. Native G6/G7 NOT TESTED; stable G8 BLOCKED.

## Approved artwork follow-up — 2026-10-15

The owner approved the new crate-and-checklist thumbnail and matching transparent icon before replacement. This change updates source artwork only; no Lua, metadata, networking, saves or gameplay changed. See [artwork provenance, export commands and validation](../assets/branding/README.md). The existing published package remains an unchanged historical baseline and is not expected to match these two new source PNGs until a separately authorized build. No package, deployment, Workshop upload or native runtime check is part of this artwork update. G7 is N/A for this local-presentation-only difference; this does not reclassify earlier gameplay evidence.

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

Current source version: 0.19.0-dev.1. Native-only storage retirement is the current development candidate. See NATIVE_CATEGORIES_COMPATIBILITY.md for validation and limits.

Historical note: Recorded source snapshot: 0.4.0-dev.50. Stage A adds bounded correlated Sort timing, immediate preparation acknowledgement, and independent B47 carry-allocation regression. Background destination-index optimization awaits correlated native root-cause evidence; no gameplay/cache decisions changed. See `dist/handoffs/dev19-responsiveness.md`. Native dedicated timing remains BLOCKED.

Historical dev.15 offline gates add a 5,092-item vanilla membership comparison, deterministic scoring and mod-neutrality fixtures, local grouping/persistence fixtures, and a read-only installed Workshop definition audit. Placed-item registration and ground sorting are not implemented because their server authority path remains unproven. Dev.14 offline tests add native-shaped loaded-building discovery beyond radius, same-window event-driven refresh, Shopping access during discovery, broad/physical/mod/item tree presentation, and inventory Category display/sort without item mutation. Dev.13 offline tests cover exact activated-Mod-ID rejection and pre-registration authority guard, old saved data without active conflict, selected-object outline ownership/cleanup, repeated-open catalog reuse, large catalog preparation and font-scaled geometry/action visibility. These are Lua/native-shaped offline checks, not in-game rendering, timing or multiplayer proof. Native acceptance must test object outlines and cleanup, repeated-open latency, 1080p/1440p/2160p clipping, keyboard/controller controls and exact-ID conflict behavior in SP, listen and dedicated sessions.

Current offline coverage and exact commands: [MASTER_HANDOFF_STATUS.md](MASTER_HANDOFF_STATUS.md). The full suite runs without any Quartermaster directory or Lua loaded, including the owned UI, presets, bindings, persistence and native executor mocks. Current native standalone and dedicated MP acceptance are NOT TESTED; G7 NOT TESTED and G8 BLOCKED. Earlier entries retain their historical evidence.

## Published hover cleanup (2026-09-26)

Removed general instructional tooltips from combined-list rows. Only item-specific shared-name information remains on applicable items; controls help remains on the mode button. Integration regression covers category, mod and ordinary item tooltip absence with help still accessible. Presentation-only change: selection, save authority and synchronization are unchanged. Native hover retest remains pending.

## 0.1.4

Full host validation passes across four regression suites: original model, ownership, bulk/search/count model and installed-upstream Picker/Core integration. Coverage and remaining native gates are detailed in [V014_IMPLEMENTATION.md](V014_IMPLEMENTATION.md). Package contains 33 runtime files with source/archive SHA-256/byte parity and all 29 locale tables. No native or multiplayer readiness claim is made.

Native retest checklist: category/mod/item search; Ctrl+A in the list versus focused search/priority text boxes; Shift select/clear and Ctrl anchors; collapsed and filtered exclusions; group context commands; controller Bulk actions and Range Selection menus; immediate effective counts including presets; scrollbar and deep scroll stability; save/cancel/reopen/restart/removal. Shared display-name aliases retain Quartermaster's global rule semantics.

## 0.1.3 Shift-click range selection

Host regressions PASS for inclusive forward/reverse ranges, repeated Shift-click extension, selected endpoints, crossing category headers without selecting hidden children, filter-reset and collapsed-anchor fallback. Selection uses one model batch normalization and the existing scroll-preserving rebuild. All 29 translation tables include the new control description. Native Shift-key/mouse acceptance remains pending. No controller or Presets behavior changes.

## 0.1.1 native defect follow-up

User screenshot on Build 42.20.4 showed the combined mode, a `tire` filter and an empty list with scrollbar controls at the far left. Console inspection found no adapter stack trace. Installed ISScrollBar:instantiate derives position/height from the initial 10x10 list; ISScrollingListBox:prerender clips at vscroll.x + 3. The adapter now explicitly synchronizes scrollbar X/Y/height after the original layout, updating Lua and Java geometry. Scope is only the adapted picker, including its Presets view.

The original host stub's arbitrary scrollbar position masked this failure. Replaced it with initial native geometry: the new regression FAILED before the fix and PASSED afterward. Opening and resizing bounds, plus the complete host suite, pass. The corrected native rendering still requires user retest after restarting the game. No sorting or saved-data changes.

Host tests validate the original adapter/model and the installed upstream integration without copying upstream files. Run `python tests/run_tests.py` using Python with lupa. Full project validation includes Lua compilation, all model and integration regressions, metadata, localization parity and generated ZIP byte parity.

Native acceptance is UNVERIFIED. Test an existing save: untouched open/save preserves all selections and priority; full-to-partial and partial-to-full transitions; clear full/mixed; shared names; unknown selections; search with parent context; AND filters; Check filtered and Uncheck all; expansion without changes; deep scroll, scrollbar, resize and clipping; controller A selection/X expansion/B return and bumpers; Presets including unchanged editor and conflict rejection; close without Save; save/reopen/restart; disable patch and confirm original UI and normal rules.

Multiplayer is UNVERIFIED. Test hosted and dedicated remote clients, server-observed object state, late join, rejected/conflicting preset edits and original authority behavior. The adapter adds no network channel or server write path. Do not claim multiplayer compatibility from host mocks.

## Host evidence (2026-09-24)

PASS under Lua 5.1 via lupa 2.6: syntax; full/partial/none transitions; final-child normalization; preservation of pre-existing explicit rules; shared-name cleanup guards; last-child deselection; empty/stale categories and unknown items; literal hierarchical search and AND filters; unchanged state on opening and untouched Save.

PASS integration against installed Quartermaster 0.24.0 source loaded directly (not copied): actual Picker constructor/opener/callbacks, original preset editor and preset generation links, mouse checkbox/disclosure separation, controller selection/expansion/mode navigation, filtered collapse, original Save/cancel, native Core ModData getters/setters and transmit call delegation, restoring native UI after removing the wrapper, unchanged planner item precedence.

PASS 200-category/20,000-item fixture: deep scroll stays at -2200 through expansion/collapse/selection/refresh and a Presets round trip; smooth scrolling targets reset; no catalog provider enumeration after opening; bulk selection uses a bounded number of refreshes. This is a host structural check, not an in-game frame-rate measurement.

PASS localization: all 29 vanilla language folders have matching keys and English fallback values. PASS packaging checks compare every ZIP file byte-for-byte with authoritative source. Tests also hash all installed Quartermaster files before/after and require no changes. Neither game nor dedicated server was launched; no live mods were deployed.

## Bounds correction — 0.2.0-dev.2
[VERIFIED source] ISUIElement dimension getters read Java geometry. MultiContainer now supplies temporary viewport getters to inherited layout and restores them before returning, including error paths.
[TESTED offline] `python tests/run_tests.py` and `Build-Workshop.ps1` passed, including native-style dimension getters at 640x460 and 900x720, footer/tree separation, scrollbar bounds and repeated layout. Build includes version checks and package parity. Client copy verified with Get-FileHash for all 70 files. Previous package/client archived in dist/bounds-fix-backup; prior Workshop staging archived by builder.
[RUNTIME GATE] In-game visual confirmation pending. Dedicated multiplayer remains untested; no release readiness claimed. No upload performed.

## dev.23 container presentation checkpoint

[TESTED — offline] Full regression and package checks passed. dev.22 tooltip positioning/lifecycle retained. Container rail uses current validated physical-object sprite textures with generic fallback, instance caches and bounded optional diagnostics. Presentation only; taxonomy 6, configuration schema 2 and movement protocols unchanged. [RUNTIME GATE] Actual native UI/sprite acceptance and dedicated two-client visual comparison are not tested; overall G7/G8 remain BLOCKED. Category-column investigation, bulk movement and collision recovery remain outstanding. Dev.23 subsequently published as a user-authorized development testing build; local live installation unchanged. Native gates remain pending. See `dist/handoffs/dev23-container-presentation-report.md`.

See [dev.24 pipeline implementation and runtime gates](DEV24_PIPELINE.md).

## dev.26 scope and furniture candidate

See [DEV26_SCOPES_FURNITURE.md](DEV26_SCOPES_FURNITURE.md) for current ownership, persistence, migration, UI behavior and acceptance gates. Offline evidence does not establish native persistence or dedicated multiplayer readiness. G6 NOT TESTED; G7 BLOCKED; G8 BLOCKED.


Current dev.27 UI remediation and bounded route candidate: [implementation, offline evidence and pending native gates](DEV27_IMPLEMENTATION.md). Calibrated native travel-time optimization remains pending.


Current dev.28 resizable-window candidate: [native audit, implementation and pending acceptance](DEV28_WINDOW_LAYOUT.md). Presentation only; inventory category adapter unchanged; no deployment/publication.


Current dev.29 independent tracks: [category audit/blocker and adjustable appearance implementation](DEV29_CATEGORY_AND_APPEARANCE.md). Category integration remains unresolved; transparency passes offline checks only. Native acceptance pending; no deployment/publication.


Current integration: see [ALLOCATION_INTEGRATION.md](ALLOCATION_INTEGRATION.md).
