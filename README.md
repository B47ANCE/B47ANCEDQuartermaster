# B47ANCE'd Quartermaster

**Clean Building is activated for multiplayer testing**. Subscribe to [Quartermaster](https://steamcommunity.com/sharedfiles/filedetails/?id=3807217050) and [Rooms](https://steamcommunity.com/sharedfiles/filedetails/?id=3820077442), then enable both on the server and every client. Right-click inside a native building and choose **Clean Building**: fetch eligible supplies, add 10 mL bleach by default, fill the remaining bucket capacity with water, clean eligible blood/grime and return borrowed supplies when permitted. Rooms owns settings/permissions. Single-player cleaning is disabled. [Setup, limits and validation](docs/CLEAN_BUILDING.md). Published 0.8.0-dev.1 remains a historical optional-Rooms build. The 0.9.0-dev.1 candidate makes Rooms mandatory and needs an updated package. Upload success does not establish native/MP correctness.

Current source requires **B47ANCE'd Rooms** (Workshop 3820077442 / Mod ID B47ANCEDRooms) for Quartermaster and its embedded Auto Clean feature. Enable both mods on the server and every client. **Designate Room** opens Rooms' independent editor. The Lua-only gameplay and server guards are unchanged.

The inventory Sort button opens a scope menu: **Sort Entire Building**, **Sort Room**, or **Sort Only Inventory / Selected Container** when applicable. Both area choices include the full carried inventory, including unequipped bags, plus configured physical storage. Hidden/private storage is filtered and source/destination permissions are rechecked independently. Ground/proximity remains a single-source operation.

Offline tests pass; native UI, real persistence and dedicated multiplayer acceptance remain NOT TESTED. G7 and stable G8 are BLOCKED. Room policies govern supported integration checks and do not lock unrelated vanilla transfers, entry or doors. See [current design, limitations and validation](docs/ROOMS_INTEGRATION.md). The authorized 0.8.0-dev.1 testing upload is confirmed; no local SP deployment, game/server launch or server changes occurred.

Active sorting uses native categories: vanilla alone, or metadata provided by optional sorting/container mods. Inventory category presentation is left to those UIs. See [native categories and compatibility](docs/NATIVE_CATEGORIES_COMPATIBILITY.md). The older implementation milestones below are historical.

## dev.21 Category failure investigation

User confirms dev.20 loaded but visible Category labels remained vanilla with Neat UI. Added OFF-by-default bounded boundary diagnostics; no new renderer or gameplay changes. Full offline suite and 5,092-entry zero-change comparison passed. G6 diagnostic acceptance BLOCKED, G7 NOT TESTED, G8 BLOCKED. Bulk-transfer/collision native audit is separate and implementation remains outstanding. See `dist/handoffs/dev21-category-investigation.md` and `dev21-bulk-and-collision-audit.md`. Published dev.20 remains unchanged.

## dev.20 Inventory Category column hotfix

Compatible PATCH correction on dev.19: Category cells use the canonical resolver cache and current localized labels. Compatibility is checked during rendering rather than permanently skipping registration during early Lua loading. Native row.cat, sorting, grouping and item definitions stay unchanged. Full offline regression and frozen 5,092-item comparison passed; actual B42.21 inventory/loot/controller/scaling and second-language client acceptance remain UNTESTED. Dev.19 Stage A instrumentation is retained; its dedicated timing gate remains BLOCKED. See `dist/handoffs/dev20-inventory-category.md`. No deployment or publication.

Standalone container sorting with a combined category/item tree, staged multi-container configuration, shared presets, and native item transfers.

Embedded B47ANCEDUI supplies an amber-accented native ISUI shell, dedicated Shopping/Wanted/Needed views and responsive tables. The approved visual reference is used without its logo.

Development candidate **0.9.0-dev.1** for Project Zomboid Build 42.21.0 (installed source inspection; native acceptance pending). No Quartermaster runtime dependency. Mod ID: `B47ANCEDQuartermaster`. Authoritative source: `src/B47ANCEDQuartermaster/42`.

Current identity: **B47ANCE'd Quartermaster**, Mod ID `B47ANCEDQuartermaster`, Workshop ID `3807217050`. Replace `QuartermasterSorting` in enabled-mod selections; do not enable both copies. For this standalone source, enable B47ANCEDQuartermaster alone and disable Quartermaster and previous sorting identities. The previous standalone local installation and dev.7 Workshop staging are historical deployments; current source changes are not automatically deployed. See [migration instructions](docs/RENAME_MIGRATION.md).

## Standalone implementation

B47 owns the configuration window, tree, native icons, shared preset editor/storage, server planning and native trip executor. Configure Sorting is available on eligible loot containers and their world-object context menu. Use Sort for movement. The full offline suite also runs with no Quartermaster directory present. Native standalone/dedicated validation remains pending; this is not a release-ready claim. Current source is 0.9.0-dev.1; the native category integration candidate is for testing, not multiplayer certification. Dev.18 was deployed locally and published to Workshop on 2026-10-08 as an experimental testing candidate; native dedicated acceptance remains untested. See [current status](docs/MASTER_HANDOFF_STATUS.md).

Native categories are the only active taxonomy. Better Sorting and Better Containers are optional. This source retires obsolete owned sorting formats and category rules through server-only cleanup, preserving native selections, explicit items, priorities and owned preset generations. Foreign sorting registries are not imported or deleted. The former B47 matcher is absent from runtime. See [native categories and cleanup](docs/NATIVE_CATEGORIES_COMPATIBILITY.md). Original Quartermaster remains incompatible. The last confirmed Workshop upload is 0.6.0-dev.3. No upload is authorized for this Rooms integration iteration. Native acceptance remains pending.

## Multi-container editing

The icon rail selects which container you edit. In multiplayer, explicitly choose a server-discovered rail entry before editing; coordinates never bind the original click to an object. Edits stay staged when switching targets; `*` marks unsaved changes. Save commits dirty targets into B47ANCEDQuartermaster-owned data through the server/SP adapter; Cancel/X discards remaining staged edits. A partial Save can leave successfully saved targets alongside failed targets whose edits remain staged.

Verified multi-section furniture appears as a nested Whole Container parent and physical sections. Shared parent settings apply live to inheriting sections. Use Customize Section for a complete override, or confirm Reset to restore inheritance. Existing configured sections keep their independent rules when shared settings are first saved. Copy to visible sibling sections remains an explicit action in the container header menu; Save commits staged changes.

Whole Building discovery defaults on for new sandbox configuration; existing explicit values are preserved. The editor initially shows the player's physical room. Its container header offers Building, individual rooms and Proximity (1–the server's Container Range). Hidden sections cannot be modified through a partial parent. These view filters do not change Sort's authoritative destination discovery scope.

Moving/replacing a shared assembly invalidates inheritance when persisted identity or physical membership changes. Data is retained, and custom rules remain independent; automatic migration of moved assemblies is not supported in this candidate.

Server sandbox options: Container Range defaults to 10 tiles around the player on the player's floor; Whole Building defaults on and uses the player's native building and currently loaded squares when enabled, falling back to range without a building. Refresh Containers rescans loaded targets. Ground and unsupported moving/item-owned storage are excluded.

Copy/Paste in this editor acts on working sorting data only. B47's shared preset editor is independent: saving a preset there is not undone by cancelling container edits. Presets are server-owned, revision-checked, and editable by their creator or a server administrator. Deleted/recreated definitions receive new generations, so stale links do not silently reconnect. Legacy manual container rules remain readable; external preset definition files are not executed or silently imported. Missing preset links remain visible and must be recreated/relinked before those containers can route. Native UI and dedicated multiplayer tests remain pending; see [implementation and validation](docs/MULTI_CONTAINER_UI_IMPLEMENTATION.md).

## Hierarchy and search

Weapons uses Explosives, Sharp (Spear and Blade/Long/Short), Blunt (Long/Short), and Firearms (Handguns, Shotguns, Sub-Machine Guns, Assault Rifles, Sniper Rifles, Other Firearms, Attachments & Parts/Attachments/Parts). Other Weapons preserves insufficient-metadata items. Tool use is always primary; weapon-capable tools also appear in the Weapons tree with shared selections, secondary routing coverage and unique counts. The old ClassifyToolsByUse sandbox setting is retired. See docs/DEV41_WEAPONS.md for identity rules, compatibility and runtime gates.

Broad categories contain physical subcategories and item rows with native icons. A client-local Group Items by Mod preference adds mod headings when enabled; it is off by default. Ownership comes from the engine's script-item `getModID()` metadata; `pz-vanilla` is Vanilla, other IDs use installed mod titles. Missing/ambiguous provenance appears under Other / Unknown. No module-name or file-path guesses are used.

Search is case-insensitive and literal. A category match shows its subtree; a mod-name match shows that mod's items with its category; an item-name match retains both ancestors. Only Checked and Only Contents still narrow those results. Search expansion is temporary; clearing the search restores normal expansion.

## Controls

- Normal checkbox/item click toggles selection and establishes a range anchor.
- Shift-click checkbox/item applies the target's intended new state to visible rows of the same type between anchor and target. Checked or mixed targets clear; unchecked targets select. Works in either direction.
- Ctrl-click toggles independently, retaining the anchor. Different-type Shift endpoints act as a normal target click and establish a new anchor.
- Ctrl+A selects visible item rows; Ctrl+Shift+A clears them. Text-entry focus keeps normal text-editing shortcuts.
- Select All Visible, Clear All Visible and Invert Visible operate only on displayed ITEM rows, not headers or hidden children.
- Click a category/mod label to expand/collapse; Shift-click the label expands/collapses both hierarchy levels globally.
- Right-click a category/mod for its full-set select/clear/invert and expansion actions. Right-click an item or empty list space for visible-list actions. Group menus also provide a Visible List submenu.
- Controller A selects, X/Y expands, B leaves list focus, and bumpers switch modes. The navigable Bulk actions button exposes visible actions and Range Selection: Set Range Anchor, move to another row, then Apply Target State to Range. No existing controller chord is reassigned.

Category and mod-group checkbox/range/context actions explicitly target complete groups, including hidden children. Item ranges and visible-list actions never enumerate hidden descendants. Stable-ID anchors are invalidated when filtering or collapsing removes the row, and on mode changes.

## Selection and count semantics

The combined label is `Categories & Items (N)`, including `(0)`. N counts distinct item display names covered by manual category rules, explicit item rules and linked presets, independent of filtering/expansion. It never adds header-row counts. Quartermaster's original tabs counted category rules and explicit item-name rules separately, so this is an effective-name count built with its own identity/membership/preset semantics rather than a copied native total.

The rows edit manual rules. Presets remain independent additive coverage and their editor is unchanged. Full categories use native category rules. Partial selections use explicit item-name rules, which have higher routing precedence and enumerate current children only. Completing a category restores its native rule; pre-existing explicit rules are retained and conversion-created rules are removed only when safe for other categories.

Quartermaster shares explicit selections by display name. Editing a visible name can also affect hidden rows with that same name; independent native category rules can still cover it elsewhere. Inverting duplicate visible names uses one pre-edit snapshot, avoiding double toggles. Mod groups add no persisted selection type, and ownership describes the active engine script provenance, not historical authorship of overwritten definitions.

## Build and testing

Current movement capability is 7 (configuration 4, rooms 1): update/restart both client and server. Sorting waits for server-observed arrival before TAKE/PUT grants with bounded metadata polling, retains native permission checks and never retries a native transfer. See docs/DEV43_ARRIVAL_AUTHORIZATION.md for offline evidence and mandatory native gates.

Run `Build.ps1 -PythonPath <python.exe>` with Python and lupa 2.6. Alternatively install the host-only dependency with `python -m pip install --target .test-deps lupa==2.6`. The generated `dist/current/B47ANCEDQuartermaster-<VERSION>.zip` includes only runtime source and the Build 42 common directory.

Host checks cover the development implementation; native keyboard/controller/rendering and hosted/dedicated multiplayer acceptance remain UNVERIFIED. Historical version 0.1.4 was published under the former identity. Version 0.4.0-dev.3 was published as a development testing build on 2026-10-03 to Workshop item 3807217050; that dated dev.5 candidate was a historical testing package. Current source version: 0.9.0-dev.1. See docs/MASTER_HANDOFF_STATUS.md for publication evidence and pending runtime gates.

The archived 0.2.0-dev.2 package used normal Quartermaster rules. Current development Save writes a separate owned namespace and leaves those legacy rules untouched. Removing this development source does not convert owned rules back to Quartermaster. Do not deploy it until the extraction and native gates are complete. Build scripts do not deploy or launch the game.

## 0.4 feature candidate

The same window now provides Sorting and Shopping modes. Shopping stores concrete full-type requests and retrieves physical item instances through native walk/TAKE actions. Dibs Wanted/Needed records belong to each actual item and each player; Wanted order is server-assigned social precedence. Dibs! Wanted and Needed goals derive qualifying carried inventory; overlapping goals use the greater linked target. Add Remaining, bulk add and Collect Remaining reuse authoritative Shopping. Personal Shopping Preferences default to Any, with applicable condition, food-state and drainable overrides. Provenance-aware additions require confirmation for intentional repeats; replay and rapid duplicate events cannot inflate demand. Optional Project Cook controls submit native recipe intent; supported full portions are resolved from vanilla definitions, and unsupported operations fail closed. Native SP/listen/dedicated acceptance is pending; do not treat offline mocks as multiplayer proof.

## dev.23 container presentation checkpoint

[TESTED — offline] Full regression and package checks passed. dev.22 tooltip positioning/lifecycle retained. Container rail uses current validated physical-object sprite textures with generic fallback, instance caches and bounded optional diagnostics. Presentation only; taxonomy 6, configuration schema 2 and movement protocols unchanged. [RUNTIME GATE] Actual native UI/sprite acceptance and dedicated two-client visual comparison are not tested; overall G7/G8 remain BLOCKED. Category-column investigation, bulk movement and collision recovery remain outstanding. Dev.23 subsequently published as a user-authorized development testing build; local live installation unchanged. Native gates remain pending. See `dist/handoffs/dev23-container-presentation-report.md`.
# Workshop submission formatting

For the next authorized update, generate a fresh VDF with
`Prepare-WorkshopVdf.ps1 -OutputPath <new-vdf-path>` after the normal build,
staging and package checks. It reads the current canonical description, change
note, version and Workshop ID, preserving real paragraph breaks. Do not reuse
the existing `dist/workshop-publish/*.vdf` files: they contain literal newline
escapes and remain historical submission evidence. Preparing a VDF does not
upload; publication still requires user authorization.

See [dev.24 pipeline implementation and runtime gates](docs/DEV24_PIPELINE.md).


## Current dev.25 ground source implementation

Lua-only explicit Floor and resolvable aggregate sources are implemented. Short-lived server references, native queued acquisition and observed carrier/destination confirmations preserve the native PZ authority boundary. Movement capability 3 requires matching builds. Native Proximity Inventory UI and dedicated transfer acceptance remain unverified: G7 NOT TESTED/BLOCKED; G8 BLOCKED. No deployment/publication. See [details and native gates](docs/DEV25_GROUND_SOURCES.md).


Current dev.27 UI remediation and bounded route candidate: [implementation, offline evidence and pending native gates](docs/DEV27_IMPLEMENTATION.md). Calibrated native travel-time optimization remains pending.


Current dev.28 resizable-window candidate: [native audit, implementation and pending acceptance](docs/DEV28_WINDOW_LAYOUT.md). Presentation only; inventory category adapter unchanged; no deployment/publication.


Current dev.29 independent tracks: [category audit/blocker and adjustable appearance implementation](docs/DEV29_CATEGORY_AND_APPEARANCE.md). Category integration remains unresolved; transparency passes offline checks only. Native acceptance pending; no deployment/publication.
