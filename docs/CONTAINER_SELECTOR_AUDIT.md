# Container selector, area discovery and Whole Container audit

Audit date: 2026-09-27. Observed patch metadata: 0.1.4; installed Quartermaster: 0.24.0. This is source/bytecode evidence, not a PZ runtime test. The implementation handoff received during this audit supersedes the earlier save-only Whole Container brief: propagation is a deliberate **staging** action, followed by independent dirty-target saves.

## Evidence and scope

[VERIFIED] Inspected installed files directly. `CONTAINER_SELECTOR_EVIDENCE.json` contains SHA-256 baselines and relevant installed Java method disassemblies. `tests/audit_container_apis.py` reproduces public-signature checks and verifies that inspected inputs remain unchanged during inspection. No upstream code was changed or copied into runtime implementation.

Path abbreviations used below:

- G: `E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid`
- Q: `E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/3761216758/mods/Quartermaster/42/media/lua`
- S: this project's `src/QuartermasterSorting/42/media/lua/client/QuartermasterSorting` at audit time (renamed by the subsequent migration).

The installed JAR hash is `80e405a4bfc42f6072e75b3735f458a6514143da011d3226007ded305a442f44`. Core initializes GameVersion with 42 and 20; do not infer a precise patch suffix from the repository's historical 42.20.3 baseline. The JAR hash pins this audit's exact evidence.

## B42 world inventory

[VERIFIED] `G/media/lua/client/ISUI/ISInventoryPage.lua` owns the rail. `ISInventoryPage` derives from `ISPanel`; constructor at line 1936 is `new(x,y,width,height,inventory,onCharacter,zoom)`. `createChildren` (68) creates `ISInventoryPane`, resize widgets, inventory/loot container controls and `ISInventoryPageContainerButtonPanel` (118). The rail is on the right in vanilla. The proposed left placement is custom layout, not a direct vanilla widget option.

| Responsibility | Exact entry points / fields |
| --- | --- |
| Rail panel | `ISInventoryPageContainerButtonPanel:new`, `prerender`, `render`, `keepSelectedButtonVisible` (23–56); stencil clipping; parent `selectedButton` coupling |
| Buttons | `addContainerButton` (1461); ordinary `ISButton`, `buttonPool`, `backpacks`, `buttonSize`, `button.inventory`, `name`, `tooltip`, `capacity` |
| Population | `refreshBackpacks` (1537), removes old children into pool, clears/repopulates rail |
| Selection | `selectContainer` (1088), `setNewContainer` (1122), `selectButtonForContainer` (1143), reference equality against `ItemContainer` |
| Selected appearance | `selectedButton`, gray 0.7 background; unselected transparent; hover gray 0.3; border and image supplied through ISButton |
| Icons | supplied Texture first; otherwise `ContainerButtonIcons[container:getType()]`; fallback `media/ui/Container_Shelf.png` |
| Names | `IGUI_ContainerTitle_<type>` translation, object container custom name override; vehicle part translation; item bags use item name |
| Hover | `onMouseOverButton` (2004), `onMouseOutButton` (2026), `shouldSetOutlineHighlight`; world outlines and external-highlight coordination; rename may trigger refresh |
| Tooltip/render | `ISButton:render` (196), texture override (269), tooltip creation (317) using `ISToolTip`, including joypad focus |
| Mouse | `onBackpackMouseDown` (1340), click (1347), mouse-up (1360), right-down (1368); mouse-up also attempts drag/drop transfers |
| Overflow | panel scroll height = last button bottom; keep-selected-visible scrolls child panel with margins; `onMouseWheel` (1302) cycles containers, not a free scroll list; rapid overflow cycling suppresses wrapping |
| Controller | `prevUnlockedContainer`, `nextUnlockedContainer`, `selectPrevContainer`, `selectNextContainer` (787–838); `onJoypadDown` (840), directional handlers; shoulder-switch option has three modes |
| Refresh | `update` (482): player square/direction changes and lock checks; `dirtyUI` (1330); resize/zoom paths; refresh events `begin`, `beforeFloor`, `buttonsAdded`, `end` |
| Stale removal | rebuild drops undiscovered buttons, clears pooled highlights, preserves reference if still found or chooses fallback; `forceSelectedContainer` is a timed exception |

Vanilla shoulder mappings also transfer/focus inventory operations. Copying those callbacks would conflict with the patch's existing mode bumpers. Reuse generic focusable controls and provide explicit rail focus, keeping patch editor controls intact.

### Native discovery trace

[VERIFIED] World branch of `refreshBackpacks` (1631–1800): origin is player X/Y/Z; loops dy then dx from -1 through 1 (3×3, same floor; no Euclidean radius). Nil squares are skipped. Other squares require `currentSq:canReachTo(gs)`; MP uses `SafeHouse.isSafehouseAllowLoot(gs,player)`. It does not determine discovery by building or room.

For each admitted square, insertion order is world items/bags, static-moving objects, ordinary objects and all their indexed containers, then vehicle compartments/bags. There is no name sort. Facing/look-square can change selection. A vehicle table prevents repeated vehicle enumeration across squares; there is no universal container-ID dedupe. Ordinary spatial/list traversal supplies most uniqueness. Extensions can add entries through refresh events.

`getWorldObjects()` contributes world items to a synthetic floor container and gives dropped container-items their own buttons. `getStaticMovingObjects()` contributes container-bearing bodies; an animal dead body branch breaks that loop. `getObjects()` contributes `getContainerByIndex(0..count-1)`. Locked `IsoThumpable` buttons remain visible with lock art but callbacks/highlighting disabled; selection and controller traversal also check locks. Doors/walls affect square reachability, separately from storage locks.

Vehicles use `getVehicleContainer`, iterate parts, and require `vehicle:canAccessContainer(partIndex,player)`. Bags inside admitted vehicle parts are included except GloveBox. The on-character branch also handles player inventory, equipped bags and in-vehicle storage. This is selective nested-bag enumeration, not arbitrary recursive storage discovery.

`GetFloorContainer(playerNum)` (1526) caches a per-player `ItemContainer.new("floor",nil,nil)`, marked explored. Refresh clears/repopulates it from nearby world items; Ground is appended last with `ContainerButtonIcons.floor`. It is not a persistent furniture target. Exclude it from the new rail.

### Reuse verdict: PARTIALLY REUSABLE

[VERIFIED] `refreshBackpacks`, `checkExplored` and `selectContainer` can fill loot, request server items, mark containers explored, play sounds, refresh crafting/build panels and invoke transfer paths. Do not instantiate a hidden inventory page to harvest its discovery, and do not call these methods from the sorting rail.

[INFERRED] Reuse `ISPanel`, `ISButton`/scrolling primitives, `ISToolTip`, `ContainerButtonIcons`, vanilla textures and icon-size option. Implement a small independent rail with explicit metadata and selection callbacks. The panel subclass has little independent value because of parent coupling; use its clipping/selected-visible behavior as reference, not a copied inventory implementation. No object sprite rendering is needed: furniture rail icons are keyed by container type, not object tile sprites.

## Quartermaster target and eligibility

[VERIFIED] `Q/client/LootSorter_ContextMenu.lua:onWorldContext` (26) enumerates `worldobjects` with `getContainerCount()>0`, dedupes object references, makes one target per zero-based index, and applies `LootSorter.canLootSquare`. `addBoxOptions` (60) passes `(obj,ci,playerNum)` to `openPicker`. `onInvContext` (94, target branch 131) takes an item's actual container, gets its parent, and requires `LootSorter.containerIndex(parent,container)` to resolve. Unlike world-context entry, this branch does not repeat `canLootSquare`.

`Q/client/LootSorter_Picker.lua:openPicker` (845) stores `targetObj`, `targetCI`, `playerNum`; targetKind is `box`. Target is **IsoObject plus container index**, not display name and not just ItemContainer. `containerIndex` in Core (90) compares actual ItemContainer references. `openPicker` and the setters do not themselves validate eligibility, locks, object existence or index lifetime.

There is **no complete public canConfigureTarget predicate**. Reusable pieces are `containerIndex`, `canLootSquare`, indexed storage APIs. `findDesignatedOnSquare` (Core 307) is a read of already-designated ordinary objects, not a discovery or eligibility function: it omits unconfigured storage. The registry is a coordinate index of designations, so also cannot discover unconfigured storage.

| Target | Observed contract / future treatment |
| --- | --- |
| Ordinary furniture/crates | Canonical path; enumerate all indexed sections, including secondary compartments |
| Appliances/freezer sections | Same ordinary indexed-container contract; no category/type whitelist in Quartermaster |
| Ground | Synthetic parentless floor; distribution source is supported, designation is not |
| Vehicles | Vanilla rail supports parts; Quartermaster has no vehicle-part designation identity/path. Do not infer support from distribution/carrier code |
| Corpses | Inventory parent may satisfy inherited indexed APIs and expose a menu; sorting destination scan only iterates square ordinary objects, not static-moving corpses. Not proven supported end-to-end; exclude from new discovery |
| Player inventory | Used as source/carrier; no dedicated designation/registry path; exclude |
| Nested/dropped bags | Native inventory buttons exist, but no recursive Quartermaster destination contract; `containerIndex` must match the precise parent's indexed container. Exclude unsupported item-owned containers |

[INFERRED] Use a small adapter predicate for live ordinary square objects: loaded square, membership in `sq:getObjects()`, valid index/reference roundtrip, existing Quartermaster square gate, and explicit native lock/safehouse restrictions. This is a conservative bridge around incomplete upstream eligibility, not a competing storage-type database. Do not claim every menu-exposed odd target is a functional sorting destination. Require server-side checks separately: `canLootSquare` returns true outside `isClient()` and fails open for absent context/API errors, so it is not an authority validator.

## Load, save, networking and copy/paste

[VERIFIED] Load functions in Core: `getBoxCats` (106) → LSBox; `getBoxItems` (113) → LSBoxItems; `getBoxPresets` (121) → LSBoxPresets; `getBoxPriority` (193) → LSBoxPriority or zero. All data is on the physical object's ModData keyed by `tostring(ci)`. Getters return live tables. `openPicker` clones category/item membership and preserves preset link **values**, which may be generation numbers rather than booleans.

`Picker:onSave` (793, box branch 816–820) calls `setBoxCats`, `setBoxItems`, `setBoxPresets`, `setBoxPriority`, then closes. These functions exist in **client/Core.lua**. `setBoxSet` (182) assigns the supplied table directly, clears empty sets, transmits object ModData and invokes local `syncCoord`. Priority also transmits but does not sync the registry. There is no combined `saveConfiguration` API, all-fields transaction, conflict check, per-target acknowledgment or save-time validity check for boxes. A future wrapper must clone tables for every target/write to prevent aliasing.

`syncCoord` (170) calls `squareHasDesignation`, then `addCoord`/`removeCoords`. `Q/server/LootSorter_Coords.lua` owns `LootSorter_Registry`, registers those operations through `serverFn`; add validates coordinate parsing, remove checks current server data and grace period, broadcasts global ModData, with deferred removal broadcasts. Registry synchronization is separate from object ModData. It is not an authoritative setter for box rules. `Q/shared/LootSorter_Rpc.lua` sends module `Quartermaster`, result `rpcResult`, tokens/timeouts, `OnClientCommand`/`OnServerCommand`; `callServer` selects player 0. Do not assume split-screen player routing is correct for a new command using this helper unchanged.

Engine bytecode: `IsoObject:transmitModData` sends ObjectModData from clients, calls GameServer.sendObjectModData on servers, and flags hot-save. `ObjectModDataPacket.parse` loads/wipes object ModData; `processServer` relays to relevant clients. `isConsistent` delegates to MovingObject, whose check here is object non-null. These methods show replication, **not Quartermaster rule/permission/revision validation**. Broader packet dispatcher checks are not certified by this audit. No safe server-authoritative multi-box mutation abstraction was found.

Sort reads are live: `gatherBoxes` checks registry/preset sync, resolves loaded designated squares and `resolveEffective`, then `sort` builds a plan. No explicit box-save event or queued-plan invalidation was found in the save path; a new sort sees updated data, an already queued plan is not proven rebuilt. Registry/preset global data receive/start hooks handle snapshot requests; object replication and late-join persistence require engine runtime proof. Preset-definition editing is a different RPC path (`putPreset`/`removePreset`, revision/generation checks, server world store); do not confuse it with saving a box's preset links.

### Authority blocker

[UNKNOWN / RUNTIME GATE] Calling the four existing client setters once per target is not sufficient for the required server-authoritative multi-target feature. Do not label it an audited authoritative save API. Implementation must either obtain an upstream authoritative API, or introduce an explicitly scoped, validated server adapter preserving the four native fields and registry semantics. Do not load all of client/Core.lua on a dedicated server. Validate authenticated player, bounds/sandbox scope, existence/reference, permissions/locks, data shape, preset links, stale/conflicting originals and per-target outcomes. A request token/retry policy must prevent uncertain retries from overwriting later edits. No gameplay implementation should silently downgrade to client writes when this bridge is absent.

### Copy Sorting

[VERIFIED] Core `copyDesignation` (235) reads source `(obj,ci)` into global process-local `LootSorter.clipboard` with cats/items/presets/priority. Local `copySet` turns truthy values into true, **including generation-valued preset links**. `pasteDesignation` (247) makes new copies and calls the four ordinary setters; it replaces rather than merges. UI only offers Paste when `hasClipboardContent` is true (including nonzero priority). No Whole Container or UI state exists in its payload.

[INFERRED] Leave external Quartermaster menu Copy/Paste unchanged. In the staged editor, Copy must snapshot selected **working** configuration and Paste must replace working state only. Preserve preset link generations for internal staging/Whole Container cloning; if importing the native clipboard, accept its actual boolean-link semantics rather than claiming it preserved generations. Never call `pasteDesignation` for staged Paste: that writes immediately. Scope, target, discovery and dirty state remain outside configuration payloads.

## Area discovery

### Origin and range

[INFERRED] Freeze origin at the opening target's square. This guarantees stable context when the player walks or switches rail selection, and selects the relevant building when the player stands outside an indoor cabinet. Prefer target origin over moving player origin; name the option tooltip accordingly. Always insert the valid opening `(object,container)` first and select it explicitly. If it becomes invalid, show an invalid-target condition, not an arbitrary replacement.

Use bounded same-floor Chebyshev range (native neighborhood shape and Quartermaster distance convention): integer offsets -R..R, loaded `getGridSquare`, ordinary `getObjects`, each indexed container, adapter eligibility, dedupe by ItemContainer reference. This is discovery of configuration targets, not immediate loot reachability. Do not apply vanilla one-step `canReachTo` to a distant square; it would defeat building/range discovery. Retain square permissions and locks. Server validation must enforce the chosen configuration scope, independently of what the client displayed.

| R | Square lookups per discovery | Relative to R=5 |
| --- | ---: | ---: |
| 5 | 121 | 1.00 |
| 10 | 441 | 3.64 |
| 20 | 1681 | 13.89 |
| 30 | 3721 | 30.75 |

[TESTED: offline arithmetic] `(2R+1)^2`; not engine timing. Cost adds O(objects + indexed containers) and optional O(targets log targets) ordering. No configuration/hierarchy construction during scanning. Scan on open/manual refresh only; a bounded UI work queue is appropriate for unusually large building room lists. Avoid unrestricted loaded-world scans or registry-based omissions of unconfigured storage.

### Building

[VERIFIED] Installed bytecode exposes `square:getBuilding()` → `square:getRoom():getBuilding()` or nil; `IsoBuilding:getDef()` → BuildingDef; **BuildingDef**, not IsoBuilding, has `getRooms()`. Each RoomDef exposes `getIsoRoom`, `getBuilding`, `getRects`, `getZ`; IsoRoom exposes `getSquares`, `getRoomDef`, `getBuilding`. RoomDef:getIsoRoom resolves through meta-grid room ID.

[INFERRED] Preferred read-only traversal: opening square → building → def → room defs → loaded IsoRoom squares; dedupe square references/coordinates and verify each candidate's actual building definition still equals origin's definition. If room squares are incomplete, iterate exact room rectangles at `roomDef:getZ()` and check actual square membership; rectangles are enumeration aids, not the membership predicate. Never call refreshSquares or generate/load chunks merely to discover targets.

**Do not use BuildingDef:getSquares() as membership.** [VERIFIED] Current bytecode scans expanded rectangular X/Y bounds and Z=-32 through 30, adding every non-null square without a building test. This can include unrelated structures and incurs many unnecessary lookups.

Multiple rooms/floors follow room definitions, including negative Z when registered in the same building. `BuildingDef:isBasement` and `IsoBuilding:hasBasement` exist; this does not prove that every generated basement shares its upper building definition. A separate basement definition must not be guessed into the building through bounds/adjacency. Player-built/expanded structures may have no map room/building or unchanged membership; use engine membership only. Tests for construction/remodeling/basement associations remain runtime gates.

If the opening square has no valid building, fall back to range at the same frozen origin. A valid but partly unloaded building is **partial discovery**, not grounds to silently switch to range. Skip unloaded portions, retain a completeness notice and manual Refresh. No new squares/chunks created. Opening outside with selected container inside works by target origin; outside target with player inside intentionally falls back to range rather than changing origin semantics.

### Sandbox proposal

[INFERRED] Use new namespace `QuartermasterSorting` after rename. `ContainerRange`: integer, default 10, proposed range 1–30, step 1; `WholeBuilding`: boolean, default false. Server sandbox values govern shared permission/scope checks as well as client discovery. Use localized names/tooltips for all 29 languages. Clamp/reject nonfinite/fractional/out-of-range input at the server boundary, use defaults for absent settings in existing saves. These settings are distinct from upstream MAX_TILES/MAX_LEVELS (distribution travel). No old Balanced Sorting sandbox namespace exists in the inspected patch. UI padding, scheduling budgets and protocol size bounds are internal technical safeguards, not player gameplay options.

## Whole Container / physical identity

[VERIFIED] Installed public methods:

- `IsoObject.getSpriteGrid(): IsoSpriteGrid`
- `getSpriteGridObjectsIncludingSelf(java.util.ArrayList): java.util.ArrayList`
- `getSpriteGridObjects(java.util.ArrayList, boolean): java.util.ArrayList`
- IsoSpriteGrid width, height, **levels**, sprite position X/Y/Z, sprite lookup and validation.

Native Lua proof of intended calling convention: `G/media/lua/client/Vehicles/TimedActions/ISPathFindAction.lua:pathAdjacentToMultiTileObject` (348) creates `ArrayList.new()`, calls IncludingSelf and iterates Java list with size/get. A Lua table is not the expected result buffer.

Bytecode behavior: resolver clears the supplied list. Without grid, IncludingSelf adds self. With grid, it derives footprint origin from source square minus source sprite-grid X/Y/Z, iterates grid width/height/levels, skips unloaded squares, scans each square's ordinary objects and includes objects whose `getSpriteGrid()` is the same grid reference. It requires a live source square. It does **not** compare each candidate sprite's expected cell offset or store a persistent assembly-instance UUID.

Therefore this is the correct native resolver, but not an unconditional proof of unique physical assembly in malformed, overlapping or repeated same-grid placements. Do not invent adjacency/display-name/container-type/sprite-name grouping. A conservative adapter can additionally verify candidate grid-relative origin equals source origin, using actual grid position APIs, and reject ambiguous duplicate cells. That validates native grid metadata rather than guessing tile names. Missing/unloaded members cannot be resolved into offline objects. Rotation-specific hardcoding is unnecessary; current sprite/grid defines orientation and levels.

[INFERRED] Target is already `(obj,ci)`; reverse lookup unnecessary. For each validated grid member, enumerate indexed containers and apply the same target eligibility predicate. Include source explicitly after validation and dedupe actual containers. Decorative members have no eligible indexed storage. A gridless standalone target remains a singleton (do not widen to nearby crates). For multi-compartment grid members, each indexed storage section is a distinct target. Resolve once per selection, again at deliberate Whole Container Apply; validate exact staged target references again before Save. Do not rediscover-and-broadcast at final Save, because that would erase subsequent sibling overrides.

Cost is O(grid width × height × levels + objects in that footprint + containers); bounded local scan, no per-frame discovery. Checkbox useful only when distinct eligible targets >=2. Reset false on target switch and hide otherwise. Scope stays editor-only; selected source plus eligible physical siblings, **never the rail list**. Allow sibling session entries outside current rail discovery without expanding discovery scope; disclose affected target count and retain them for Save/Cancel. A future Refresh must not silently discard dirty hidden entries.

## Staged session and integration recommendation

[VERIFIED] Picker already edits copied tables and only writes boxes on Save. This supports staged editing, but S/Model.lua holds `picker` table references and `introduced` provenance; Adapter closures capture adapter state. Simply swapping `targetObj` is insufficient.

[INFERRED] Use one editor and lazy per-target records:

`targetKey, objectRef, containerRef, ci, position, displayName, icon, original, working, modelProvenance, dirty, invalidReason`.

Session identity: monotonically assigned session key mapped from actual ItemContainer reference, storing physical object reference and original container index. Revalidate loaded square/object membership and exact `getContainerByIndex(ci)==containerRef`. Display name is presentation only; x/y/z/object-index alone is unsafe if objects move/reorder/replace. No persistent GUID ModData. Session keys are not sufficient wire identity: a future authority protocol must independently resolve and validate object identity and fail on replacement/unload.

On select: stash current editor working state/provenance, rebind selectedCats/Items/Presets and `selection` to selected record, targetObj/CI, priorityEntry, clear `_contents`, invalidate range/filter/preset-count caches and row identity, restore or rebuild the target's model. Keep shared catalog/ownership cache; never enumerate entire item database per rail button. Rebuild selected target's count. Preserve user search/filter preferences while recomputing Only Contents against the new target. State equality must compare actual sets and preset generation values, not the selected count.

Explicit **Apply to Whole Container** is the clean propagation point. Checkbox alone and ordinary item clicks do nothing to siblings. Apply clones all four working fields to eligible siblings and marks differences dirty; toggling scope/switching does not write world data. Returning to a sibling resets scope false and allows independent override. Save commits current dirty records as independent snapshots; Cancel/X discards them. No final save-time replay of earlier group propagation. Copy/Paste works on working state. Preset definition editing remains globally meaningful and separate: Cancel of the container session cannot promise to undo a separately saved global preset; disclose this or disable definition editing inside the staged transaction.

Integration points: wrap `LootSorter.openPicker` after original construction; enhance instance adapter/layout/controller handling; intercept bound Save button callback as well as method; add session/discovery/rail modules; retain native preset editor separately. No global ISInventoryPage patch, no transfer code, no upstream edits. Explicit Refresh reconciles metadata while retaining dirty session records and stable selection; never reload over dirty working state.

### Failure and authority design gates

New server bridge is required before enabling shared-world multi-save. Preferred contract is per-target result acknowledgments and optimistic original-configuration comparison. Invalid/unloaded/replaced/unauthorized/conflicting targets fail individually and retain staged edits; successful targets become clean with fresh originals. No cross-target atomicity claim; no blind rollback over another player's work. Timeout is uncertain, not success; retain status until a read/result resolves it. No client-supplied scope list may bypass server permission and range/building checks. Group operation authorization must validate native sibling relationship without permanently storing links. If a safe wire identity/authority bridge cannot be established, disable affected Save and record blocker instead of calling client setters.

## Validation and remaining gates

[TESTED: offline] Public Java signatures and bytecode inspected; exact-input hashes stable. Command (workspace root):

```powershell
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'Quartermaster - Balanced Sorting/tests/audit_container_apis.py'
```

The command path above is historical pre-rename evidence. The migration updates the runnable path. This audit does not test a live SpriteGrid, room cache or network packet exchange. Source findings, arithmetic and recommendations are explicitly separated.

[RUNTIME GATE] Native: rotations, naturally spawned/moved/player-placed/modded furniture, multi-level grids, overlapping same-grid objects, decorative/unloaded siblings, stacked compartments, locked/safehouse storage, building rooms/floors/basements/player extensions, duplicate names, rail clipping/wheel/controller, stale refs and target movement. SP, hosted, remote dedicated, multi-client conflicts, late join/reconnect, restart, patch removal and uncertain multi-save all remain NOT TESTED. G6/G7 not passed; gameplay G8 blocked.

Version-policy discovery: source metadata says 0.1.4; root VERSION, project VERSION_POLICY.md and scripts/check_versions.py were absent when audited (also no workspace-root checker). No fabricated version/checker pass. Audit alone changes no runtime version. The later explicitly authorized rename/feature handoffs must adopt the standard canonical inventory before packaging and preserve historical artifacts/evidence.

Final distinction: **area discovery determines rail contents; selected target determines editor contents; Whole Container determines explicit sibling staging targets.**
