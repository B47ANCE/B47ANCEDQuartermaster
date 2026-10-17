# Ledger requirement for sorting and collection

Project Version: 0.18.0-dev.7

Physical Shopping now has separate writing supplies and carried shopping papers; those do not replace the completed supply ledger required for collection. Planning/reading do not require a supply ledger. See [physical Shopping](PHYSICAL_SHOPPING_LISTS.md).

See [ledger modes, freshness, renewal and the current acceptance report](LEDGER_FRESHNESS.md).

## Behavior

Inventory and selected-container Sort never require a ledger. By default, Room/Building Sort and Shopping **collection** require a fresh completed ledger covering each work location; Disabled Ledger mode bypasses both requirements. Shopping list planning/editing, recipe additions, Wanted/Needed planning, container configuration and recording a new ledger remain available without one. This avoids a circular prerequisite.

A qualifying source is either:

- A completed **paper Supply Sheet carried by that player**, including carried bags. The server must already bind that exact native item ID to a complete `LedgerComplete` snapshot for the work location. Blank, partial, stale, permission-limited, wrong-location and client-forged ModData labels do not qualify.
- A working powered **computer with a matching ledger CD loaded from accessible physical storage beside it**. The computer may be anywhere in the same native building as the work location, or within the configured horizontal range on the same floor. The snapshot must still cover that location; proximity alone cannot make a ledger for a different building qualify.

Coverage uses the existing server-recorded native building/safehouse scope signature, not display names or client coordinates. Safehouse records cover their verified native safehouse; building records cover their native building. Outdoor work needs a record actually covering that location (such as the safehouse), rather than treating an adjacent building's record as a global pass. Multiple carried papers or loaded computers may cover different source/destination locations.

Knowledge expires according to the server mode and update interval (default 7 in-game days), not after every item movement. Periodic/No updates modes show live read-only projections of recorded compartments; Historical mode preserves recorded quantities. Automatic computers provide current knowledge only while their real CD, power and permissions remain valid. Native geometry/signature changes can make the recorded scope no longer match. Nothing changes native capacity, carrying penalties, destinations, priorities, presets or vanilla smaller transfer groups/timing.

## Computer storage workflow

The approved Lua-only path leaves the **real ledger CD in existing storage**. There is no verified custom drive-container replication path, so this feature does not invent a computer inventory, consume a CD into ModData, create a virtual disc, clone inventory objects or move items manually.

1. Record a completed paper sheet and use Windows '93 **CD Writer** to create its ledger CD using the existing server-granted native completion.
2. Put the CD in a desk/container within one horizontal square of the computer, on its floor, using normal native inventory actions.
3. Open the powered computer, choose **CD-ROM (D:)**, select the storage CD and **Load selected storage CD**. This saves an authenticated server binding, without moving the disc.
4. Run **QUARTERMASTER.EXE** to read/search it. Loading does not auto-run the app. The loaded, powered computer also makes its matching record available for Sort/Collect while the player works around the building.
5. Log Off/close the interface to leave the computer; its established binding remains. Eject/unload removes only the binding and leaves the item in storage. Take/drop/move that CD manually and the old binding stops qualifying. Reload it explicitly if its storage identity changes.

Loading/unloading requires the current computer's Rooms **configure** permission, plus native interaction/safehouse authorization. Discovery and use require inspect/discover access to both computer and actual CD storage. Reading/knowledge eligibility does not confer withdraw/deposit/configure rights. Existing native safehouse and Rooms checks remain independent on each transfer.

The stock desktop sprite remains `appliances_com_01_72`; the CD must be the existing native `B47ANCEDQuartermaster.SupplyDisc` with a valid server snapshot binding. Carrying a CD by itself is not a paper substitute. CD Writer still consumes a selected carried vanilla CD only through its previous native-action/journal path. Loaded drives block other writes and concurrent load/write requests at the same computer. Current drive identity is required for eject; stale requests cannot silently clear a replacement binding.

## Server settings and existing saves

| Sandbox identifier | Default | Bounds | Effect |
| --- | --- | --- | --- |
| LedgerMode | 1 | enum 1–4 | Periodic live / Disabled / No updates live / Historical |
| LedgerUpdateDays | 7 | integer, 1–365 days | Expiry for Periodic and Historical modes |
| LedgerComputerManualUpdates | true | boolean | Require inspection and new CD; false provides live automatic computer statistics only in the exact recorded building |
| RequireLedgerForSorting | true | boolean | Require fresh paper/computer knowledge only for Room/Building Sort |
| RequireLedgerForCollecting | true | boolean | Require it for Shopping collection; planning stays free |
| LedgerComputerRange | 10 | integer, 1–30 tiles | Nearby computer distance outside the same native building, same floor |

These are server-owned sandbox settings, localized with names/tooltips in all 29 supported locale folders using the established English fallback policy. Existing requirement booleans are preserved; RequireLedgerForSorting now applies only to scoped Room/Building operations. Missing new settings use Periodic live, 7 days and manual computer updates. Old completed records use their existing finished world-hour timestamp; invalid/future timestamps do not qualify. No expiry is written into old records. Disabling either requirement restores that action's previous unrestricted behavior. No old sorting/category/item/preset data or physical ledger record is deleted/migrated/reset.

This is a MINOR feature iteration with a deliberate default gameplay change. Peer capabilities change to **movement 11, Shopping 3, Ledger 3 and Rooms 4** so mixed older ungated peers do not silently run a different workflow. Physical ledger schema stays 1. Server and clients must update/reconnect together. Protocol identifiers are internal compatibility controls, not sandbox options.

## Persistence, synchronization and failure handling

- Server-only global `B47ANCEDQuartermasterLedgerDrives` schema 1 stores up to 256 bindings: opaque computer ID, exact computer/source object coordinates/index, physical compartment index, server storage marker, real native CD ID and native building index key. No copied snapshot contents, user-supplied permissions or Lua userdata are persisted.
- Object ModData exposes only incarnation markers. A marker or UI-mounted proxy alone never authorizes anything. Each provider resolves the current native objects/compartment, actual CD membership and server snapshot binding, then checks live permissions and power. A stale `getContainer()` pointer is insufficient.
- Existing loaded objects/storage are re-resolved after module/reconnect/server state reconstruction. Missing/unloaded/replaced/moved objects, reordered compartment/object identity, removed CDs and corrupt/future registries fail closed without resetting data. An explicit unload/reload can repair a stale binding when a valid physical CD remains. Actual native save/restart ordering and item-ID persistence still require dedicated acceptance.
- Mount choices are authenticated, actor-bound opaque offers expiring after 30 seconds. Competing mount operations cannot replace an occupied drive. Read/list responses contain only currently authorized media. Eject changes no inventory and checks the current drive ID. Mutation commands use the existing sender-bound transport with server request-rate limits.
- Room/Building Sort and Collect admission is checked before collection/planning. Source and destination candidates, and each new `moveTake`/`movePut` grant, recheck relevant coverage. Losing a ledger, power, CD or access blocks new grants. Already completed native transfers remain completed; observation/cancel/return commands do not acquire a new ledger prerequisite. Native return permissions/capacity still apply. Items may remain safely carried if new work stops; no forced drop/deletion/rollback is introduced.
- Carried completed papers and bound storage CDs are excluded from automatic movement while a requirement is enabled, so the sorter does not remove its own prerequisite. This is not a permanent item lock: unrelated native/manual transfers can still move them, and then the requirement is rechecked.
- The client periodically refreshes its drive UI (at most once per two seconds) and closes cached pages on reported loss. Server grant decisions do not depend on waiting for that poll. Logging off is client-session dismissal, not a new shared hardware power toggle.

The final inventory movement still uses the project's accepted vanilla native authority boundary. A new Lua grant check cannot retract an already dispatched native transfer or govern unrelated vanilla/manual inventory actions. This feature does not claim an absolute engine-level item lock or new Java enforcement. Native/dedicated timing and revocation races remain acceptance cases.

## Bounded work and caches

Paper candidate discovery is bounded to 4,096 native instances/depth 16 and reused for up to one second. Positive candidates still recheck exact current ownership and server snapshot binding on every eligibility decision. Native building classification/signatures are cached for at most one second; permission, power, physical CD presence and media bindings are never cached as a positive authorization.

Drive registry indices rebuild on server revision changes and use building/spatial buckets, avoiding a whole-registry scan per item. Directory discovery reads nine adjacent loaded squares, at most 1,024 objects, 512 compartments, 4,096 item instances and 32 matching CDs; excess returns an explicit resource-limit failure. Unknown/corrupt/future schemas fail closed. Old orphaned bindings are retained rather than deleting possibly valid unloaded state; the 256-binding ceiling is a known limit, not an automatic garbage collector.

Only loaded native storage/power can be proven. A same-building computer whose native object/storage is unloaded does not qualify until it is loaded and revalidated. No forced world/chunk load or expensive full-room scan runs per transfer. These are implementation resource limits, not additional gameplay tuning settings. Native tick/latency/throughput impact remains unmeasured; host fixtures are not performance proof.

## Validation and acceptance

[VERIFIED SOURCE] Existing Build 42.21.0 / Steam build 25485521 Lua-exposed item/container, object ModData, safehouse, native UI/transfer and electrical APIs are reused. No new Java/JAR, unsupported inventory-slot API, copied third-party assets/code or upstream Rooms edits are introduced. Existing dated native evidence retains its original version and status; no prior SP/MP evidence is relabeled.

[TESTED OFFLINE] Production Ledger inspection/conversion first generates real fixture server bindings; requirement tests then verify default-on scoped behavior, manual Sort without proof, forged/partial/wrong-building refusal, free planning/list access, paper loss despite candidate caching, automatic proof protection, actor-bound load choices, configure-vs-inspect separation, real stored-CD load/eject without item mutation, stale eject rejection, re-resolution from persisted records, power/private-storage/CD loss, same-building distance, nearby range boundaries, native classification-cache expiry, per-action opt-outs, future-schema preservation, positive production Sort TAKE and collection withdrawal, loss before PUT with an authorized native return, new PUT denial and completed native PUT observation. UI tests exercise server-derived storage descriptors and loss reporting. Existing transfer/return/conservation/grouping regressions explicitly exercise the supported opt-outs.

Commands from this source worktree, using the host Python with Lupa:

```powershell
python -B tests/run_tests.py --require-rooms --rooms 'C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDRooms'
python -B scripts/check_deployment.py
python -B scripts/check_versions.py
git -c core.safecrlf=false diff --check
```

Source manifest: **211 runtime files**. No package, deployment, Workshop publication or game/server launch is part of this iteration. Historical packages remain in their original worktrees with their original versions. The new branch is `feature/ledger-freshness`, based on 2cac3ae5497bdbf793e119d12f3ef61ceb457457 (physical Shopping Lists / PR #16); earlier stacked branches are not merged by this work.

[RUNTIME GATE] Native G6 NOT TESTED; dedicated G7 NOT TESTED/BLOCKED; stable G8 BLOCKED. Test two remote clients with completed/wrong/partial/forged records; inventory/container/ground/vehicle/room/building Sort; Collect versus list editing; all defaults/opt-outs; loaded computers across floors/nearby range; private computer/storage configure/inspect permissions; competing load/eject/write; power loss and CD removal during walking, dispatch and transfer; cancel/return/unknown outcomes; exact item conservation; reconnect; real server save/restart; unloaded objects and changed object indices; Linux path case; and actual native UI/input/performance. Offline passes do not replace those results.
