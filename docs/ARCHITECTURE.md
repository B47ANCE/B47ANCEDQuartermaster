# Architecture and implementation map

Project Version: 0.21.0-dev.3

Current Sort workflow: default-on `SortUpdatesLedger` requires carried paper and pen/pencil, searches accessible loaded building storage for a completed covering ledger first, uses native pickup, accepts carried blank/unfinished fallback and writes confirmed touched storage once after the full successful job. It overrides the older Sort-only freshness/computer exception below while enabled. Shopping collection and computer application installation are unchanged. Movement 12 / Ledger 5 require matching peers. [Current implementation, boundaries and validation](SORT_LEDGER.md). Earlier checkpoint evidence remains historical.

Current application prerequisite: find and run the Quartermaster Application CD installer on each PC before computer ledger reads/writes or automatic knowledge provision (server opt-out supported). The Application CD is released after successful setup and is not required nearby afterward. Paper inspection does not need the app; Sort follows the default paper/writer policy above. Current capabilities are Ledger 5 / Movement 12. [Exact implementation, settings, validation and migration limits](APPLICATION_CD.md). Earlier checkpoint sections retain their original evidence.

Current designated-only scope correction: native room selectors/requests are retired; B47ANCEDRooms designations provide room identity and native buildings provide building scope. Quartermaster Rooms capability is 4; movement remains 11. Existing ledger signatures, upstream complete-footprint configuration permission and provider-capability checks remain. Enforcement/live role routing stay disabled. [Exact validation and limitations](DESIGNATED_ROOM_SCOPES.md).

## Computer presentation

PC Framework owns original pixel icons and CRT chrome in ComputerArt, plus the bounded drive/tool/app registry, task buttons, minimize/restore/focus and layout. Quartermaster ComputerUI is an alias; LedgerUI registers its reader and ComputerWriter tool. LedgerUI resumes cached digital panels through the existing authenticated read hook, invalidating old callbacks and clearing old rows. The reconciled source requires PC Framework, as introduced by upstream 0.19.0-dev.1. This UI correction adds no further shared state, network command, inventory mutation or protocol change. Geometry caches refresh on resize. Artwork draws from fixed bounded layers rather than scanning world state. [Behavior, preview and validation](WINDOWS93_COMPUTER.md).

## Ledger freshness — current 0.17 source iteration

Inventory/selected-container Sort is independent of ledger possession. Room/Building jobs retain server-validated fresh scope checks. Four ledger modes, in-game update days, manual/automatic computer updates, immutable renewal generations and bounded read-only live projections are implemented. Current branch: `feature/ledger-freshness`, from `2cac3ae5497bdbf793e119d12f3ef61ceb457457`; current manifest: 211 runtime files. No package/deployment/publication/game/server launch. [Exact policy, validation and pending runtime gates](LEDGER_FRESHNESS.md). G6/G7 NOT TESTED; stable G8 BLOCKED.

Earlier iteration sections below retain their original publication/validation context and do not describe this source-only iteration.

## Current development iteration

Save now keeps the container-rule editor open, refreshes acknowledged records/rail state and reloads an invalidated inherited section when necessary. Existing server save/permission behavior and manual close/Cancel are preserved. Current focused UI regression and syntax checks pass offline; native acceptance remains NOT TESTED. See [exact checks and workflow](MULTI_CONTAINER_UI_IMPLEMENTATION.md). Physical-shopping implementation/full-suite evidence remains from 0.16.0-dev.1 and is unchanged by this local UI fix.

Physical ShoppingLists schema 1 stores independent server-owned profiles bound to native paper item IDs plus opaque item ModData references. Personal.account retains account goals and the old shopping backup; Personal.identity projects the selected carried paper into the existing allocator. Commands validate exact possession, selected paper, supplies and revisions. New papers use the existing challenged native ledger-action completion boundary; one exact blank becomes one paper. Collection checks continued possession and profile revision before new TAKE grants; completed observations/cancellation remain available. HUD and list selector are client presentation. Personal protocol is 2; Shopping is 3; movement 11, Ledger 3 and Rooms 4 enforce current scope/reader semantics; storage schemas stay unchanged. Existing ledger requirements still apply to collection. See [workflow, native evidence, limits and acceptance](PHYSICAL_SHOPPING_LISTS.md).

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

Current source version: 0.21.0-dev.3. Native-only storage retirement is the current development candidate. See NATIVE_CATEGORIES_COMPATIBILITY.md for validation and limits.

Historical note: Recorded source snapshot: 0.4.0-dev.50. Stage A adds bounded correlated Sort timing, immediate preparation acknowledgement, and independent B47 carry-allocation regression. Background destination-index optimization awaits correlated native root-cause evidence; no gameplay/cache decisions changed. See `dist/handoffs/dev19-responsiveness.md`. Native dedicated timing remains BLOCKED.

Historical dev.15 pass: canonical item-definition evidence is ranked with explicit deterministic precedence, confidence and diagnostic candidates. Existing vanilla classifications remain frozen; taxonomy protocol 6 rejects mixed peer writes while schema 2/world root 1 and saved IDs remain readable. Group Items by Mod is a client-local presentation preference, off by default. Installed Workshop audit tooling is development-only. Ground/placed-item protection is blocked pending a verified authoritative source path and physical-instance lifecycle.

Prior dev.14 pass: discovery has explicit client readiness/generation state and event-driven refresh; server discovery uses the player's native building bounds and loaded squares. The combined tree presents existing physical categories beneath broad parent rows without changing saved IDs or memberships. A client-only inventory-pane adapter presents the resolver winner in the Category column without mutating Item/ScriptItem state. Native behavior remains a runtime gate.

Prior dev.13 pass: embedded client B47ANCEDUI is presentation-only. WorldHighlight outlines the selected valid physical object for the local player, restores pre-existing attached-outline state, and clears on selection/mode/close/invalid-target changes. Catalog prepares one session script index and reuses it for covered observed items, with counters and build timing for diagnosis. Layout minimums and rail rows follow font metrics. Exact activated Mod IDs `Quartermaster` and `BetterSortCC` fail closed before authority routing; historical data does not. Gameplay authority, synchronization, persistence, taxonomy protocol 5 and sandbox policy are unchanged. See MASTER_HANDOFF_STATUS.md for source contracts and native gates.

Current implementation: standalone B47 Picker/Adapter/Model/MultiContainer frontend; owned Catalog/native item textures; Presets world-global storage and revision-based server requests; existing Bindings/Store server-owned container rules and native executor. No Quartermaster runtime requirement. See [MASTER_HANDOFF_STATUS.md](MASTER_HANDOFF_STATUS.md) for authority, migration limits and pending native gates. All remaining sections below are historical pre-extraction evidence.

Inspected 2026-09-24: installed Workshop item 3761216758, mods/Quartermaster/42/mod.info: id=Quartermaster, modversion=0.24.0, versionMin=42.0. Metadata describes a single-player beta; networking code is not multiplayer certification.

All paths below are relative to Quartermaster's 42/media/lua directory. Third-party files are inspected for the explicitly requested compatibility contract; no source or assets are copied into this patch. This task-specific integration is authorized by the user's handoff.

| Responsibility | Contract |
| --- | --- |
| Window | client/LootSorter_Picker.lua: local Picker derived from ISCollapsableWindowJoypad |
| Constructor/open | Picker:new; LootSorter.openPicker publishes LootSorter._picker after initialization |
| Modes | Picker:createChildren creates ISButton selectors, not ISTabPanel; setMode switches one ISScrollingListBox |
| Categories/items | shared/LootSorter_Categories.lua: getCategories, getItemNames, getItemsInCategory; cached and display-name keyed |
| Unsaved selections | picker.selectedCats, selectedItems, selectedPresets; picker.selection aliases the active table |
| Toggling | Picker.onRowClick toggles one key; no category/item propagation exists upstream |
| Load/save | openPicker reads getBoxCats/Items/Presets/Priority; onSave calls matching setters |
| Box persistence | client/LootSorter_Core.lua: object ModData LSBox/LSBoxItems/LSBoxPresets/LSBoxPriority, string container index; original setters transmit and update registry |
| Presets | client/LootSorter_PresetSync.lua: SP Lua/QuartermasterPresets.txt; MP server global ModData LootSorter_Presets; shared resolveEffective unions manual and linked rules |
| Rendering | Picker.doDrawItem draws custom checkboxes; 22px ISScrollingListBox rows |
| Scrolling | vanilla wheel/scrollbar/smooth scrolling and stencil clipping; adapter preserves row anchor and scroll offset on rebuild |
| Filters | currentFilter, contentsSet, rebuild: literal case-insensitive text plus Only Checked and Only Contents |
| Hooks | ContextMenu invokes global openPicker; openPresetEditor remains original; Core closes windows on reload |
| Controllers | per-instance list callbacks and configJoypad/cycleMode; original up/down navigation retained |
| Sorting | shared/LootSorter_Plan.lua tries explicit item matches before category matches; never patched |

## Interception plan (recorded before implementation)

Wrap only LootSorter.openPicker, retaining and calling the original. Adapt the resulting box-picker instance after it is created; never modify the local Picker class or global ISUI classes. Validate the expected API before adapting. Preserve the original save callback and all persistent ownership. Unknown contract failures leave the original window available.

Instance methods to replace/wrap: rebuild, layout, prerender, setMode, cycleMode, configJoypad. Rebind only this instance's combined-mode, Check filtered and Uncheck all button callbacks, list draw/input/context/controller callbacks. Presets mode delegates to captured original methods. Preset editor remains untouched.

A small independent model references the original selectedCats/selectedItems tables directly. It owns cached membership, reverse membership and ephemeral provenance of item rules it introduced (not a second selection store). It normalizes newly completed categories and removes only adapter-created redundant names that remain covered in every other known category. Existing configuration is never normalized merely by opening, filtering, expanding or saving.

Flattened rows retain kind, category, item key and stable row identity. Search retains parents and reveals matching children without writing expansion state. Categories start collapsed. Uncategorized item names and stale selected names must remain accessible in a synthetic items group; this group is presentation-only and never saved as a category.

The implementation uses separate in-memory expansion overrides while filters are active; overrides reset when filter criteria change. Expanding/collapsing within search never alters the normal expansion map. A refresh snapshots top-row identity, offset and controller selection, then restores/clamps them after rebuilding. Smooth-scroll targets are cleared to avoid stale targets moving the list afterward. Bulk filtered selection runs one normalization pass rather than one catalog pass per item.

Normalization provenance lasts only for the open picker. After reopening, explicit selections are conservatively treated as pre-existing; the patch cannot infer which were created by an earlier conversion without adding saved provenance. Full category rules still return when a user completes a category, but such prior explicit rules remain. This preserves existing explicit routing intent and shared-name state. The synthetic Other group has no native category rule, so its full state necessarily uses explicit names.

The adapter also temporarily filters `insertNewLineOfButtons` during the original `configJoypad` call, restoring the method immediately afterward. Original per-instance function references are retained in `picker.qmss.original`; the global opener is retained as `QuartermasterSorting.originalOpenPicker`. No preset editor method is changed. Category context inspection is replaced by inline expansion; Presets context menus remain original.

## Accepted semantics and limits

0.1.3 stores a presentation-only item-row ID as the mouse range anchor. Shift-click snapshots visible item rows between the anchor and endpoint, skips category headers, and calls the existing batched selection/normalization path once. Range selection only checks items; it never toggles an already selected interval off. Filters/mode/bulk actions invalidate the anchor; if it is hidden the clicked item becomes the new anchor. Uses vanilla isShiftKeyDown; no global input hooks.

0.1.1 explicitly positions and sizes the existing list scrollbar after upstream layout. This is required because native list clipping reads its Lua x coordinate; retaining geometry from the initial 10x10 list can hide all rows. No global scrollbar/list class is modified.

Full-to-partial conversion is explicitly approved. Explicit rules change routing precedence and enumerate only current children. Shared display names remain global explicit selections. Clearing a category intentionally clears its child names everywhere, while independent native category rules remain. Linked presets are independent additive coverage; manual UI does not promise exclusions from presets. No preset links are rewritten.

No migration on open, new save fields, RPC, authority changes, Java bridge, copied upstream classes or altered Workshop files. All writes remain Quartermaster's original Save path. Multiplayer authority/synchronization/failure behavior are inherited unchanged, with no compatibility claim pending hosted/dedicated validation. Client adaptation failures must not mutate selections.

## dev.23 container presentation checkpoint

[TESTED — offline] Full regression and package checks passed. dev.22 tooltip positioning/lifecycle retained. Container rail uses current validated physical-object sprite textures with generic fallback, instance caches and bounded optional diagnostics. Presentation only; taxonomy 6, configuration schema 2 and movement protocols unchanged. [RUNTIME GATE] Actual native UI/sprite acceptance and dedicated two-client visual comparison are not tested; overall G7/G8 remain BLOCKED. Category-column investigation, bulk movement and collision recovery remain outstanding. Dev.23 subsequently published as a user-authorized development testing build; local live installation unchanged. Native gates remain pending. See `dist/handoffs/dev23-container-presentation-report.md`.

See [dev.24 pipeline implementation and runtime gates](DEV24_PIPELINE.md).

## dev.26 scope and furniture candidate

See [DEV26_SCOPES_FURNITURE.md](DEV26_SCOPES_FURNITURE.md) for current ownership, persistence, migration, UI behavior and acceptance gates. Offline evidence does not establish native persistence or dedicated multiplayer readiness. G6 NOT TESTED; G7 BLOCKED; G8 BLOCKED.


Current dev.27 UI remediation and bounded route candidate: [implementation, offline evidence and pending native gates](DEV27_IMPLEMENTATION.md). Calibrated native travel-time optimization remains pending.


Current dev.28 resizable-window candidate: [native audit, implementation and pending acceptance](DEV28_WINDOW_LAYOUT.md). Presentation only; inventory category adapter unchanged; no deployment/publication.


Current dev.29 independent tracks: [category audit/blocker and adjustable appearance implementation](DEV29_CATEGORY_AND_APPEARANCE.md). Category integration remains unresolved; transparency passes offline checks only. Native acceptance pending; no deployment/publication.


Current integration: see [ALLOCATION_INTEGRATION.md](ALLOCATION_INTEGRATION.md).
