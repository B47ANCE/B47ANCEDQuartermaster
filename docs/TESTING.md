# Testing

Project Version: 0.6.0-dev.1

## Current native-only storage cleanup

Server-only, one-way sorting-data retirement removes obsolete categories/formats while preserving native rules, explicit items, priorities, owned preset generations and whole-container identities. Retired taxonomy modules are excluded from runtime. Foreign LSBox registries and unrelated personal/gameplay state remain untouched. See NATIVE_CATEGORIES_COMPATIBILITY.md for exact scope, protocol versions and validation. Runtime/dedicated acceptance pending; no deployment/publication.

Historical implementation notes below describe their original versions, not the current category architecture.

## Current dev.25 ground source implementation

Lua-only explicit Floor and resolvable aggregate sources are implemented. Short-lived server references, native queued acquisition and observed carrier/destination confirmations preserve the native PZ authority boundary. Movement capability 3 requires matching builds. Native Proximity Inventory UI and dedicated transfer acceptance remain unverified: G7 NOT TESTED/BLOCKED; G8 BLOCKED. No deployment/publication. See [details and native gates](DEV25_GROUND_SOURCES.md).


## dev.21 Category failure investigation

User confirms dev.20 loaded but visible Category labels remained vanilla with Neat UI. Added OFF-by-default bounded boundary diagnostics; no new renderer or gameplay changes. Full offline suite and 5,092-entry zero-change comparison passed. G6 diagnostic acceptance BLOCKED, G7 NOT TESTED, G8 BLOCKED. Bulk-transfer/collision native audit is separate and implementation remains outstanding. See `dist/handoffs/dev21-category-investigation.md` and `dev21-bulk-and-collision-audit.md`. Published dev.20 remains unchanged.

## dev.20 Inventory Category column hotfix

Compatible PATCH correction on dev.19: Category cells use the canonical resolver cache and current localized labels. Compatibility is checked during rendering rather than permanently skipping registration during early Lua loading. Native row.cat, sorting, grouping and item definitions stay unchanged. Full offline regression and frozen 5,092-item comparison passed; actual B42.21 inventory/loot/controller/scaling and second-language client acceptance remain UNTESTED. Dev.19 Stage A instrumentation is retained; its dedicated timing gate remains BLOCKED. See `dist/handoffs/dev20-inventory-category.md`. No deployment or publication.

Current source version: 0.6.0-dev.1. Native-only storage retirement is the current development candidate. See NATIVE_CATEGORIES_COMPATIBILITY.md for validation and limits.

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
