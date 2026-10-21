# Required Rooms integration and scoped sorting

Project Version: 0.24.0-dev.4

Current designated-only scope correction: native room selectors/requests are retired; B47ANCEDRooms designations provide room identity and native buildings provide building scope. Quartermaster Rooms capability is 4; movement remains 11. Existing ledger signatures, upstream complete-footprint configuration permission and provider-capability checks remain. Enforcement/live role routing stay disabled. [Exact validation and limitations](DESIGNATED_ROOM_SCOPES.md).

Current iteration: [advisory allocation integration](ALLOCATION_INTEGRATION.md).
Current Rooms is designated-only; nativeOverrides=false. Allocation profiles
require roomDesignations/storageScopes=1 and native permission across the loaded
configuration footprint. Gameplay action permissions remain independent. The
retired nativeRooms list may be absent in current metadata; malformed supplied
collections still fail closed. SupplyAPI and ledger privacy remain unchanged.

## Historical Supply Ledger privacy

Ledger reads at loaded origin squares use the public current inspect policy. Portable records with unloaded origin squares use a stricter parent membership rule plus Rooms' own validated schema-2 Registry/Geometry and Policy.storage helpers (API 1, feature checked). Missing/future/unavailable helpers fail closed. This is read-only historical disclosure, never a new deposit/withdrawal grant. No Rooms source is modified or duplicate room registry created; native inventory operations keep their existing permission path. See LEDGER_AND_LOAD.md for tests and limitations.

## Current development iteration

Current movement/personal/shopping/ledger/Rooms capabilities are 11/2/3/3/3;
load-policy 1, configuration 6, presets 3 and allocation 1. Container schema 3
reads schema 2 without schema-only rewriting; explicit saves preserve originals.
Source withdrawal and return deposit permissions are checked separately.
Current parked-vehicle, nested-bag, physical-paper, ledger and carry behavior is
preserved. Rooms API/protocol 1 and registry schema 2 remain unchanged. Earlier
extraction/native-override descriptions below are historical; they do not restore
retired native definitions or override current designated-room contracts.

## Baseline and ownership

[VERIFIED source] Baseline Quartermaster 0.7.0-dev.1 at `de6101c45f6d09f6c926cb8afe09105c4c0dec30` had embedded custom geometry, detection, preview editor, schema-1 registry and custom-room sorting. Native-room/building sorting, native overrides/restore and delegated action policies were absent. The exact baseline inventory is in the sibling Rooms repository, `docs/EXTRACTION_AUDIT.md`.

The 0.8 extraction originally made Rooms optional. The explicitly requested 0.9.0-dev.1 contract is a breaking 0.x change: native mod.info requires B47ANCEDRooms and Workshop item 3807217050 requires item 3820077442. This covers sorting and embedded Auto Clean; no separate Auto Clean Mod ID/item is introduced. Lua fallback branches remain defensive compatibility code, not a supported dependency-free installation. Matching Quartermaster peers are required. Rooms has its own version, API/protocol 1 and registry schema 2. Quartermaster configuration capability is 5, movement 8 and rooms 2; sorting config schema 2 and world root 1 are unchanged.

| Owner | Responsibilities |
|---|---|
| Rooms | Native/custom IDs, geometry, native overrides, structural candidates, editor, names, ownership, policies, migration, persistence, networking and versioned API |
| Quartermaster | Physical discovery/handles, furniture inheritance, configuration, presets, sorting routes, Shopping/Dibs, native transfers, local view preferences and area execution |

Removed active embedded modules: `Rooms`, `RoomGeometry`, `RoomDetection`, `RoomDraft`, `RoomEditor`. Historical tests and `CUSTOM_ROOMS.md` describe 0.7 and are retained. New `RoomAccess` is a consumer adapter, not a second registry. `RoomScopes` scans physical storage inside service-provided geometry; it owns no room definitions.

## UI and sorting semantics

The owned inventory/loot Sort control opens a context menu. Available options are Sort Entire Building, Sort Room, and Sort Only Inventory/Selected Container. Invalid scopes are omitted. With overlapping organizational rooms, choose a room from a submenu. While sorting, the button cancels rather than opening another operation.

Both area operations include the full carried inventory, including unequipped nested bags, followed by configured physical storage. Bags are processed before their parent inventory. This follows the user's direct instruction, superseding the earlier handoff's inventory exclusion. Exact instance deduplication prevents items moved into a later source from moving twice. Correctly sorted stock stays in place. Unconfigured physical sources, ground, placed items, dropped bags and virtual aggregates are excluded from area sweeps; existing single-source floor/proximity sorting remains available.

Building scope uses the server's loaded native building and Whole Building setting. Room scope uses exact Rooms geometry when present, or the current native room when absent. Unloaded/oversize/changed scopes are refused, not silently truncated. Discovery and grant work remain bounded. Initial area discovery may retry busy/rate-limited responses for up to 30 seconds.

Designate Room appears in Quartermaster's container-header menu only with a ready compatible Rooms service. It opens the standalone editor and restores Quartermaster afterwards. No hard dependency is declared. Missing service retains ordinary native behavior; installed but incompatible, disabled, corrupt or unavailable authority does not bypass protected checks.

## Authority and privacy

| Operation | Authoritative checks |
|---|---|
| Discover / preview | Native loot/access, `discover`; no hidden descriptors or hidden object totals |
| Inspect / Only Contents / Dibs | `inspect` before enumerating contents |
| Edit sorting / presets applied to storage | `configure`; every affected physical furniture compartment checked |
| Configure-only load | Sorting configuration available; item enumeration/counts omitted |
| Route destination | `deposit`; server may read routing rules without disclosing private contents |
| Ordinary/area Sort source | `inspect` and `withdraw` before enumeration and subsequent batches |
| Shopping/Collect | `inspect` and `withdraw` before offers, then current grant checks |
| Transfer grant | Current actor, item/source/destination, withdrawal/deposit, rules, capacity, identity and relevant revisions |

Metadata administration is independent of gameplay. Parent safehouse owners/admins may manage room metadata but receive no automatic private withdrawal/deposit bypass. Native-denied access cannot be granted by a room rule. Physical compartments use their actual owning object's square; whole-furniture operations require every affected section, never a convenient sibling tile.

Rooms policy is read again on subsequent server boundaries. Permission/geometry changes invalidate room scope revisions and notify Quartermaster participants even when the Rooms editor is closed. Parent owner/bounds/membership are checked live. Revocation prevents further grants, preserves completed native transfers and retains carried items. An already accepted/dispatched native action cannot be safely revoked through an established Lua final-mutation hook. Independently initiated vanilla actions and other mods are outside this enforcement boundary.

No direct inventory Add/Remove mutation was introduced. Native queue grouping, timing and conservation checks remain. No custom Java, bridge, JAR or injected dependency. Taxonomy and current native selections, explicit item rules, priorities and presets are unchanged.

## Persistence and rollback

Rooms reads the old `ModData.B47ANCEDQuartermaster.customRooms` schema-1 section as data only, validates it, and imports into `ModData.B47ANCEDRooms.customRooms` schema 2. Stable world/room IDs, ordinals, creators and revisions are preserved. The original Quartermaster section is neither updated nor deleted; there is one active writer in Rooms. Existing room preferences retain their IDs. Corrupt/future schemas fail closed without replacement.

Back up saves before upgrading. Going back to 0.7 reads the old recovery section and cannot retain later Rooms-only edits; automatic reverse migration is unsupported. No real save was altered during offline tests.

## Validation and remaining gates

[TESTED offline, Windows/Lua 5.1] Quartermaster's full suite and the actual sibling Rooms API integration pass. Production-path native-Lua fixtures cover the three scope menu callbacks, room sorting (24 exact moves, 33 skips), a second whole-building sweep (2 additional moves), carried bags, source-rule invalidation, descriptor/count privacy, configure-only loading without content reads, independent actions, revocation and service mismatch. Native helpers run against fake containers/transactions; this is not real native mutation evidence.

Exact commands from each repository root, using a host Python with Lupa 2.6 available:

```text
python tests/run_tests.py --require-rooms --rooms ../B47ANCEDRooms
python scripts/check_deployment.py
python scripts/check_versions.py
python scripts/check_native_categories.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output <temporary-report.json>
```

The Rooms checkout runs `python tests/run_tests.py` and `python scripts/check_versions.py`. The Quartermaster-only suite may run without Rooms and explicitly reports paired integration NOT TESTED; `--require-rooms` makes that absence an error. Host packages are test-only, never shipped.

[RUNTIME GATE] Native UI mouse/controller/scaling, actual native-room detection/overrides, real save/load, two-client dedicated ownership and storage permissions, mid-walk/mid-transfer revocation, reconnect/restart and item conservation remain NOT TESTED. G7 BLOCKED/NOT TESTED; stable G8 BLOCKED. Offline package/version checks do not change these gates. No deployment, publication, server changes or game launch is authorized in this pass.

Unrelated Auto Clean research/implementation in the shared working trees is outside this extraction snapshot. Its files and edits are preserved and excluded from the extraction commits and artifacts. Artifact hashes and commit provenance are recorded beside development ZIPs, separately from this source report.
