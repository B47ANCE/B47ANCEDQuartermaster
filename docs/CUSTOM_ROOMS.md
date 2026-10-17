# Custom room designations

Project Version: 0.7.0-dev.1

## Current implementation status

Implementation complete for offline review; native acceptance remains blocked. Compatible MINOR addition to 0.6.0-dev.3; no removal
of existing category/discovery/sorting contracts. No package, deployment,
publication or game/server launch authorized. Dedicated G7 NOT TESTED/BLOCKED;
stable G8 BLOCKED. The separate transfer batch-stop investigation is unchanged.

## Repository audit

[VERIFIED source] DiscoveryView currently filters one Bindings physical-handle
set; Targets discovers native building rooms or a sandbox proximity radius.
Bindings retains exact object/container identity and native access checks.
Furniture checks each compartment and symmetric native assembly membership;
Whole Container permissions require every child inside the applied view.
Trips currently sorts one inventory source; no Sort Room/Building/Safehouse
operation exists. Planner/Movement validate rules, access, identity, capacity,
arrival and native outcomes. These remain authoritative.

Server storage uses ModData.getOrCreate('B47ANCEDQuartermaster') with independent
nested libraries. Room data uses a new customRooms schema 1, leaving config
schema 2, world root and existing preset/personal data unchanged. Empty older
saves gain the library only on a successful room write. Unknown/corrupt room
schemas must fail closed, never reset saves.

## Native API evidence

[VERIFIED installed B42.21.0 class metadata + vanilla Lua, not runtime proof]

| API | Verified signature / use |
|---|---|
| IsoCell | getGridSquare(int,int,int): IsoGridSquare; does not load missing data |
| IsoGridSquare | getX/getY/getZ(): int; getRoom(): IsoRoom; getRoomDef(): RoomDef; getBuilding(): IsoBuilding |
| Structural edges | isWallTo/isDoorTo/isWindowTo/isSomethingTo/isBlockedTo(IsoGridSquare): boolean; HasStairs(): boolean |
| RoomDef | getID(): long; getIDString(): String; getX/getX2/getY/getY2/getZ(): int |
| IsoRoom | getSquares(): ArrayList; getRoomDef(): RoomDef |
| BuildingDef | getIDString(): String; getRooms(): ArrayList; bounds getters |
| SafeHouse | getSafeHouse(IsoGridSquare or String): SafeHouse; getId/getOwner(): String; getPlayers(): ArrayList |
| Safehouse access | isSafehouseAllowLoot/isSafehouseAllowInteract(IsoGridSquare,IsoPlayer): boolean |
| Overlay | renderIsoLine(float x1,y1,z1,x2,y2,z2,int thickness,float r,g,b,a) |
| Mouse conversion | ISCoordConversion.ToWorld(scaled screen x,y,z); vanilla context and brush tools use this |
| Input capture | ISUIElement.setCapture(boolean), setWantKeyEvents(boolean), removeFromUIManager() |

Vanilla evidence: server/BuildingObjects/ISPlace3DItemCursor.lua checks structural
edges; client/Foraging/ISZoneDisplay.lua checks doors/windows; shared/env.lua
checks callable methods; server/BuildingObjects/ISMoveableCursor.lua draws ISO
lines; client/Context/ISMenuContextWorld.lua converts mouse coordinates;
client/ISUI/AdminPanel/ZoneEditor/MultiplayerZoneEditorMode_Safehouse.lua reads
current safehouse membership. Native methods alone do not prove runtime results.

DoTileBuilding in server/BuildingObjects/ISBuildingObject.lua creates a missing
grid square before processing cursors. The room editor does not use that cursor
path. It uses an explicitly active UI picker and read-only world lookup.
Door/window/opening semantics and remodeled/player-built room outlines require
native acceptance. Automatic candidates are never persisted without confirmation.

## Authority and invariants

The user selects creator plus current safehouse members as editors. Store the
creator and verified native safehouse ID on the server; never accept a payload
owner/member list. Re-evaluate current safehouse membership and native tile
access for writes. Admin access remains subject to native container permissions.
Geometry conveys selection, never access or reachability. Multi-floor regions
are explicit; disconnected geometry requires explicit confirmation.

Manual edits and undo/redo are client preview state. Server validates bounded
proposals cooperatively, checks revisions again before atomic commit, returns
authorized snapshots and invalidates deleted/revised scope IDs. Stable IDs are
never room names and never reused. Merge/split must preserve a declared survivor
and invalidate removed references explicitly. No full-world disclosure/scans,
client-authoritative saves or native geometry mutation.

## Implemented controls and behavior

Use Containers > Room > Manage Custom Rooms. The original configuration window is hidden while the explicit full-player-pane editor owns input, then restored with staged sorting selections intact. A scrollable themed sidebar holds saved rooms, plain-text name entries and boundary tools. Drag a rectangle or click two corners; paint/erase edits one tile per pointer position. Controller D-pad moves the world cursor, A marks corners/tiles, Y returns to controls and B cancels world selection or closes. Floor controls select explicit Z regions; no automatic vertical inclusion. Undo/redo retains 32 immutable geometry snapshots. Names are limited to 96 UTF-8 bytes; duplicate names show distinct rN labels, never name-based identity.

Redetect uses current structural edges; Native Outline checks exact native room membership inside bounded native bounds. Auto-detection runs once on entry after server options arrive. Open and closed actual doors, windows and verified walls bound structural detection. Doorless frames follow the sandbox option. Missing data/extent/tile limits produce an explicitly incomplete candidate, never a complete enclosure claim. Manual review may save only the shown geometry after the warning; nothing is saved automatically. Native collision can conservatively stop a candidate at non-wall obstacles; manual editing is the fallback. Saved geometry never changes automatically after remodeling.

Selected boundaries are amber, candidates blue, additions green, removals/invalid tiles red, saved context cyan and overlaps/second split region purple. Up to eight authorized context snapshots are fetched at a bounded cadence; an explicit warning reports this context limit. Primary boundary rendering takes priority under an 8,192-line budget. Invalid previews inspect at most 64 tiles/2ms per update and mark up to 512 invalid tiles; the server checks every proposed tile before commit. Visual overlays are presentation only and are not proof of permission or enclosure.

Combine supports two or more authorized rooms, previews the exact union, identifies all affected room labels and preserves the selected ID. Split previews an exact nonoverlapping partition: the first keeps its ID and the second receives a new ID. Save/Undo a compound preview before further geometry edits. Delete/clear designation affects only the logical room. Overlaps are permitted; disconnected same-floor components and all separate floors require explicit confirmation. Cancel/close/death/disconnect/removal release capture, overlays and temporary references; late UI callbacks cannot revive the editor.

## Authority, identity and persistence

Clients submit intent through the existing Authority transport. The server derives the actor, creator and native safehouse association; payload ownership/member lists are ignored. Creators, current associated safehouse owners/members and native admins can edit, subject to current native tile access. Different safehouse associations cannot merge. Permission, revisions and safehouse membership are rechecked during cooperative work and before commit. Custom-room metadata/snapshots are restricted to authorized nearby designations. Geometry never grants container access, reachability or building/safehouse permissions.

World-global ModData owns `customRooms` schema 1 beneath the existing root. Records store a native random world UUID + independently generated room UUID, ordinal label, name, creator, optional server-derived safehouse ID, revision, created/updated timestamps and canonical inclusive `{z,y,x1,x2}` rows. UUIDs prevent room preference rebinding after ordinal reuse/rollback. Old saves without the section remain unchanged until the first successful write. Unsupported/corrupt room libraries fail closed and are never reset. Older B47 code cannot edit this new section; its real save/load round-trip remains a runtime gate. Keep backups before testing a downgrade.

Every write carries the library revision, affected primary room revision, nonce and server-issued single-use edit lease. Merge validates all IDs/exact union; split validates the exact partition. One job per actor, at most 16 pending global writes and 16 scans, with 30-second expiry. Validation is atomic at library replacement: no partial geometry writes. Cancel consumes the lease or cancels the matching pending job; an already committed save is reported honestly. Uncertain network outcomes are polled, never blindly rewritten. Preference files store only an exact world/room ID per local UI slot; inaccessible/deleted IDs invalidate, without falling back to an identically named room. Optional preference IO failures retain the in-memory selection and emit one bounded diagnostic.

Persistent records are compact; expanded geometry is bounded and cached by immutable server record. Technical limits: 4,096 tiles/room maximum, 512 row runs, 128x128 XY extent, explicit Z -32..31 with a span of at most eight floors, 128 rooms and 16,384 saved tiles/library. These are protocol/memory safeguards, not balance options. No background world scans, chunk loading, native room mutation or custom Java are introduced. Work uses up to four jobs with 32 steps each per tick and a total 4ms budget split between writes and discovery; active-player checks clean up disconnected work.

Meaningful server sandbox settings: CustomRooms (default on), RoomTileLimit (64–4,096, default 1,024), RoomEditRange (5–128 horizontal tiles, default 30), RoomDoorways (default on). Stable localized names/tooltips and existing-save defaults are supplied. Missing settings receive defaults; disabled rooms reject requests. New UI and sandbox strings use the existing 29-folder English fallback policy, not a claim of translated prose.

## Existing discovery and movement integration

The existing Building/Room/Proximity selector gains Native Rooms and Custom Rooms, management and Sort Selected Custom Room. Custom discovery cooperatively enumerates only loaded room tiles and routes eligible physical compartments through the existing Targets/Bindings system. Handles, identity checks, inherited Whole Container rules and child overrides remain in place. A furniture assembly crossing a room boundary includes only actual compartment anchor squares inside the selected geometry; a partially visible assembly cannot apply Whole Container edits to hidden children. Native container footprint ambiguity is resolved conservatively by the verified owning square, never by pulling all siblings into the room.

Room Sort uses saved effective rules on configured physical sources, skips items already correct for that source, and passes misplaced items into existing Sorter/Trips/Movement/native timed actions. Server-issued sweep state deduplicates exact item IDs across sources; physical container instance/compartment identities are also deduplicated. Player/equipped/ground/placed-item/dropped-bag/virtual sources are rejected before enumeration. Source/destination configuration, room revision, identity, access, capacity and native outcomes are revalidated. A changed source rule invalidates pending authorization and the next planning batch, including removal of its final rule. Staged configuration must be saved/discarded before a room sweep. Stopping the operation does not undo confirmed native transfers.

Repository audit found no preexisting Sort Building or Sort Safehouse operation to extend. Existing native room/building/proximity discovery/configuration remain available; this pass adds only custom-room multi-source sorting through the current movement pipeline. Native movement remains the final authority boundary, including already-issued native actions; no Lua feature can revoke an action after the engine has accepted it. Native queue/pathfinding failures and the separately instrumented prior batch-stop investigation remain runtime limitations, not evidence that custom rooms fix them.

Protocol capabilities are configuration 4, movement 7 and rooms 1. Both peers must update together; older affected peers reject. Taxonomy/preset/personal families and sorting schema 2/world root 1 remain unchanged.

## Validation and acceptance

[TESTED offline, Windows host, Lua 5.1 via Lupa; installed game evidence B42.21.0]

Commands from repository root:

```powershell
python tests/run_tests.py
python scripts/check_deployment.py
python scripts/check_versions.py --root .
python scripts/check_native_categories.py --game 'E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid' --output "$env:TEMP/B47-custom-rooms-native.json"
```

The actual interpreter used was `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe` with repository `.test-deps`. The suite includes five dedicated room fixtures plus the existing native queue Lua pipeline. It covers L/hole/multifloor geometry, native/structural candidates, unloaded limits, alternate paths around blocked edges, creator/group permissions, revoked membership mid-job, stale revisions, replay/cancel races, atomic writes, module reload/corrupt data preservation, deletion isolation, merge/split identities, partial furniture, asynchronous view cancellation, UI lifecycle and optional preference IO. The three-source sweep moves 20 misplaced items exactly once, preserves 28 correct/already-seen items and conserves item instances. It uses installed native queue Lua on disposable host fixtures; it is not an actual PZ session.

[TESTED offline] Full source regression, 133-file manifest, Lua-only/case/require/translation checks and canonical version checks PASS. Native category comparison: 5,105 declarations, 5,092 unique types, zero differences. Previous published 0.6.0-dev.3 ZIP was moved alone under explicit authorization into `dist/history/0.6.0-dev.3`; SHA-256 `ec9f2082258054f4a42a800d0ce0e5edea6e80f848bb0b0764ad90e90395ee7b` and CRC/data integrity preserved. No new build artifact was generated.

[RUNTIME GATE] G7 dedicated NOT TESTED/BLOCKED; stable G8 BLOCKED. Required next acceptance:

1. Native mouse/controller editor at supported resolutions, scaling/split-screen/opacity; scrolling, modal focus, overlays, cancellation/death/disconnect and no lingering input capture.
2. Existing, remodeled and player-built boundaries; open/closed doors, doorless frames, windows, demolished walls, stairs, irregular holes, unloaded edges and server tile limits.
3. Two dedicated clients: creator/member/outsider, membership revocation, simultaneous stale edits, merge/split/deletion and inaccessible saved preference invalidation.
4. Server save/restart and client rejoin with exact stable IDs, geometry, safehouse access and unchanged ordinary sorting/presets/Shopping/Dibs.
5. Configured multi-container sweeps with overlapping rooms, cross-wall/unreachable targets, capacity changes, furniture boundaries, exact conservation and no excluded sources or duplicate moves. Test real native queue failures and cancellation during transfers.

No native SP, listen-server, dedicated MP, Linux runtime or live performance PASS is claimed. No package, local deployment, Workshop upload or game/server launch is authorized or performed for this feature.
