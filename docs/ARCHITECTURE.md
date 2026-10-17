# Architecture and implementation map

Project Version: 0.4.0-dev.48

## Current dev.25 ground source implementation

Lua-only explicit Floor and resolvable aggregate sources are implemented. Short-lived server references, native queued acquisition and observed carrier/destination confirmations preserve the native PZ authority boundary. Movement capability 3 requires matching builds. Native Proximity Inventory UI and dedicated transfer acceptance remain unverified: G7 NOT TESTED/BLOCKED; G8 BLOCKED. No deployment/publication. See [details and native gates](DEV25_GROUND_SOURCES.md).


## dev.21 Category failure investigation

User confirms dev.20 loaded but visible Category labels remained vanilla with Neat UI. Added OFF-by-default bounded boundary diagnostics; no new renderer or gameplay changes. Full offline suite and 5,092-entry zero-change comparison passed. G6 diagnostic acceptance BLOCKED, G7 NOT TESTED, G8 BLOCKED. Bulk-transfer/collision native audit is separate and implementation remains outstanding. See `dist/handoffs/dev21-category-investigation.md` and `dev21-bulk-and-collision-audit.md`. Published dev.20 remains unchanged.

## dev.20 Inventory Category column hotfix

Compatible PATCH correction on dev.19: Category cells use the canonical resolver cache and current localized labels. Compatibility is checked during rendering rather than permanently skipping registration during early Lua loading. Native row.cat, sorting, grouping and item definitions stay unchanged. Full offline regression and frozen 5,092-item comparison passed; actual B42.21 inventory/loot/controller/scaling and second-language client acceptance remain UNTESTED. Dev.19 Stage A instrumentation is retained; its dedicated timing gate remains BLOCKED. See `dist/handoffs/dev20-inventory-category.md`. No deployment or publication.

Current source version: 0.4.0-dev.48. Stage A adds bounded correlated Sort timing, immediate preparation acknowledgement, and independent B47 carry-allocation regression. Background destination-index optimization awaits correlated native root-cause evidence; no gameplay/cache decisions changed. See `dist/handoffs/dev19-responsiveness.md`. Native dedicated timing remains BLOCKED.

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
