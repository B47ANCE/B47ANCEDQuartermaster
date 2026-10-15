# Clean Building — offline integration

Observed development checkpoints: Quartermaster `0.8.0-dev.1`, Rooms
`0.1.0-dev.1`. Native source target: installed Build 42.21. This is the next
authorized slice after the single-square guard and transport experiments.
Earlier evidence retains its own version, HEAD and implementation boundaries.

## Implemented workflow

[TESTED offline] One simulated **Clean Building** context-menu click now drives
the actual integration installers/handlers and all subsequent steps without
another user action:

1. Obtain a server-owned native building scope from the separate Rooms project.
2. Survey its loaded tiles and eligible configured physical storage in bounded
   steps. Prefer already-carried supplies and the current suitable cleaning tool.
3. Fetch the exact selected bucket, pure bleach and native clean-stains tool.
4. Walk to a valid water source, add **10 mL bleach first by default**, and fill
   the 10 L bucket with water through the original native Lua callbacks.
5. Walk between eligible targets and clean through the guarded native action.
   Reuse measured solution; top up bleach first and water second when needed.
6. Restore supported original primary-hand state and return borrowed supplies
   to their exact original eligible storage. If that storage changed, lost
   permission or filled up, retain the item and report it instead of choosing
   another destination. Cancellation retains actual partial work and supplies.

The client drives presentation and intent only. Server-observed arrival is
required; a client path callback does not grant reach or complete a cleaning
step. Native/MP behavior remains untested. These installers are **not activated
in a live game or packaged into a mod**.

## Ownership and source changes

Rooms now owns `clean` as an independent delegated policy action, the native
building scope/claim and cleaning sandbox options. Its API advertises
`cleaning=1`. Existing native safehouse loot/interact rules remain mandatory.
Geometry, private policy and scope membership are not copied into a second room
authority in Auto Clean. See the Rooms repository's `docs/CLEANING_API.md`.

Rooms files changed for this slice:

- `shared/B47ANCEDRooms/Cleaning.lua`: server-only scope, native scanning,
  membership/clean checks, options interpretation, claims and expiry.
- `API.lua`, `Policy.lua`, and the existing `Editor.lua`: additive API, distinct
  clean policy, and policy/visitor controls. No inventory/world mutation lives
  in Rooms.
- Existing sandbox declarations and translation dictionaries: six settings and
  localized clean/menu/result strings, using the existing English fallback
  policy. No claim of human translation coverage.
- Source inventory, the existing development changelog, `tests/test_cleaning.lua`,
  the test runner and API documentation.

Quartermaster research files:

- `BuildingJob.lua`: server-owned lifecycle, exact claims, phase ordering,
  arrivals, native callback guards, cancellation, observed receipts and returns.
- `BuildingNative.lua`: actual configuration reader, bounded survey, native
  transfer/equipment helpers, exact identity/reach/permission/capacity checks.
- `BuildingWire.lua`: explicit native server/client bindings and localized
  context action. One-click automation uses native walking and timed actions.
- Existing `Guard.lua` / `NativePort.lua`: opt-in building preparation modes,
  phase-specific reach, prepared-solution reuse, conservative Rooms footprint
  checks and measured residual top-ups. Original standalone behavior still has
  its 31 regression groups.
- Existing native transport adapters: guarded fetch/equip/return/unequip phases,
  native replication waits, server-selected presentation dose and cancellation.
- Standalone building/click tests and `run_auto_clean_building.py`.

Auto Clean remains outside packaged `src`, with no new Mod ID or automatic
initializer. This work edits no Quartermaster production Lua or canonical
version value. Its version inventory classifies the frozen audit reports as
historical; Rooms inventories its current API-document version mirror. It extends
the already-open research checkpoint and the initial
unreleased Rooms API checkpoint; no independent version number was invented.
An eventual distributable gameplay feature remains a compatible MINOR
capability requiring an explicit release/version/provenance decision.

## Mutation boundary

The earlier native sender/reconstruction proof still applies. Native
`OnClientCommand` supplies the connection-bound actor. The fixed shared
constructor serializes only `character, operation, phase, grant`; server
reconstruction returns the retained guarded action. Fresh, actor-bound native
confirmation precedes original guarded server start and all mutations. Clients
cannot submit resources, quantities, completion, callbacks or timing fields.

Fetch/return are original Lua timed actions using the native scheduler and
vanilla shared `ISTransferAction:transferItem`. They do **not** submit an
unguarded client ItemTransaction. The vanilla helper removes/synchronizes the
source; the adapter uses the verified native `sendAddItemToContainer` for the
destination. It checks exact pre/post containment and identity, source removal
permission, destination eligibility/capacity, current Rooms action permission,
server scope, reach and item protection. No custom inventory AddItem/Remove
implementation or Java is introduced. A partial native error becomes uncertain;
there is no refund, recreation, repeated transfer or silent compensation.

Native `ISEquipWeaponAction` and `ISUnequipAction` perform/synchronize equipment
changes. Heavy/powered/special starting equipment that would trigger unrelated
native side effects is refused. Suitable tagged two-handed cleaning equipment
is supported with native equip behavior; a conflicting secondary-hand item
prevents starting that plan. Original primary-hand restoration is supported;
there is no dropping of user equipment to create carrying space.

Only supported carried/root items and eligible configured world storage are
surveyed. Quartermaster's current server configuration/physical-target readers
are reused. Shopping/Dibs records are not repurposed or changed. An active
Quartermaster movement run blocks this controller. Own claims are advisory
against other native activities; current references and state are checked again
at the final guarded boundary.

## Scope, limits and failure behavior

Building membership is native physical membership across loaded rooms/floors,
with exact holes. Rooms owns one cleaning scope per building, bound to actor,
building definition, registry revision and effective options. Policy/settings
changes, departure, death/disconnect and expiry invalidate it. A cancelled begin
request gets a bounded tombstone so a late begin packet cannot start a job.

The native blood-removal footprint remains conservative: all XY ±1 squares at
every native cell level must be loaded, same-chunk, inside the selected scope,
and currently clean-permitted. This can reject many normal locations, including
boundary tiles or incomplete vertical footprints. Such targets are skipped and
reported **partial**, never falsely labelled fully cleaned. No unsafe footprint
was relaxed to make a test pass. Only the verified blood/grime action is used;
graffiti, ashes and other effects are not silently treated as supported.

Finite pure-water sources with actual fluid components are supported. Infinite,
tainted, indirect/plumbed and mixed sources remain outside this integration.
Supplies in nested bags are not surveyed; root-carried supplies and configured
physical storage are supported. No storage retrieval outside the selected
building, chunk loading, item creation, teleporting, solution dumping or
unbounded scans are implemented.

Native room/survey bounds fail explicitly rather than truncate. The survey
advances 64 work units per call, with fixed per-container/object/total limits.
Four active jobs, 32 closed receipts, 16 recent begin/cancel keys per actor,
30-minute job/scope lifetime and 16 commands per actor/second are internal
safety bounds. The existing five-second confirmation and two-minute native
operation limits remain. Client inventory/world replication can catch up before
construction within that window; it never authorizes a retry after mutation.
Performance and packet timing in the native engine remain runtime gates.

Receipts count completed native clean actions, already-clean targets, skipped
targets, returned/retained supplies and unaccounted uncertain supply outcomes.
These are not claims about every individual splat affected by native removal.
External changes/new blood after the bounded survey are not an infinite
rescan loop. Cancellation or failure stops the job, retaining measured work;
normal successful completion attempts configured returns.

## Rooms settings and saves

All six stable settings are under `SandboxVars.B47ANCEDRooms`, validated on the
server with names/tooltips in the existing sandbox page:

| Setting | Default / bounds |
|---|---|
| `CleanBuildingEnabled` | true; boolean |
| `CleaningBorrowSupplies` | true; boolean |
| `CleaningReturnSupplies` | true; boolean |
| `CleaningBleachML` | 10; integer 1–100 mL |
| `CleaningBuildingTileLimit` | 4096; integer 128–16384 |
| `CleaningTransferSeconds` | 1; integer 1–10 seconds before normal actor modifiers |

Missing existing-save options use defaults without resetting saved state. Old
private policies with no clean rule default to their assigned owner. New clean
rules/grants are independent of withdrawal/deposit. No job or lease is persisted;
native items/world state remain vanilla-owned. Restart/reconnect never resumes
or replays an old job. Older Rooms parsers can refuse persisted clean rules;
downgrade after writing one is not claimed supported. No real save was tested.

## Validation

Run from the Quartermaster repository in PowerShell:

```powershell
$py = 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$gameRoot = 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'
$roomsRoot = 'C:\Users\willi\Desktop\Work\Project Zomboid\Mod Repositories\B47ANCEDRooms'
& $py scripts/check_versions.py --root .
& $py tests/run_auto_clean_building.py --game $gameRoot --rooms $roomsRoot --report docs/audits/AUTO_CLEAN_BUILDING_OFFLINE_EVIDENCE.json
& $py tests/run_tests.py --require-rooms
& $py "$roomsRoot/tests/run_tests.py"
& $py "$roomsRoot/scripts/check_versions.py" --root $roomsRoot
```

[TESTED offline] **74 Auto Clean scenario groups PASS**: 31 guard, 23 transport,
19 building integration groups and one full menu-click integration. The click
test uses actual installers/handlers, actual Rooms source and native Lua
constructors/callbacks; engine objects, packets, pathfinding/arrival, float32
storage and Quartermaster's configuration reader are test doubles. It performs
one user click, six exact inventory transfers, bleach-first preparation, two
distant clean actions, native equipment cleanup and three original-storage
returns. No second user click or manual supply preparation is used.

Failure tests cover foreign actors, replay, cancellation before begin,
reconstruction, stale containers, unavailable storage/space, native permission
revocation, native partial error after transfer, top-ups, failed returns,
uncertain outcomes, reentrant cancellation after native transfer, server arrival,
two-handed equipment and delayed replication.

[TESTED offline] The Rooms full suite passes, including multi-floor scope/hole
membership, independent clean policy, interact denial, ownership/claims, copied
snapshots, defaults/bounds, settings changes, disconnect/expiry and client
rejection. Syntax, source inventory, case, localization and existing migration,
editor, registry and network checks pass. Both version checkers pass at the
observed versions.

[TESTED offline] Quartermaster full regression with `--require-rooms` passes.
The earlier room-import/version failures were repaired by concurrent extraction
work; those earlier audit reports retain their historical failures. No source
drift occurred during the successful paired regression. Private full output is
in the local temporary `b47-clean-building-final-du7gsl8b` audit directory. The
final source-map SHA-256 digests were Quartermaster
`ec4fc6f1cada5f5bdddb9d4ac5f1c3739e944c04eec606e37fe3698c26187439`
and Rooms `88dd4a2c289758eb9d7decbda5927736319da7d682d1b317ec5221a171d10589`.
This task
does not claim ownership of the extraction fixes or commits.

New evidence is in `AUTO_CLEAN_BUILDING_OFFLINE_EVIDENCE.json`, binding exact
research/test/Rooms/native source hashes, observed HEAD/version and simulated
receipts. Original guard/transport evidence was not overwritten as current proof.

## Remaining runtime and repository gates

[RUNTIME GATE] No PZ/server launch, live installer activation, deployment,
publication or packaging was performed by this work. The explicit bindings
currently target dedicated server/client roles; a native single-player host
adapter is not implemented or claimed verified. Native UI, source/destination
inventory replication, packets, pathfinding/stairs, fluid conservation,
multiplayer races, interrupted returns, real persistence/reconnect/restart and
large-building performance require authorized native tests. The modified local
installation noted in the original audit still requires a clean disposable
native test environment. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

Native packet character alone still does not authenticate a sender, and native
packet processing can interrupt previous actions before Lua confirmation. The
guard protects this consumer's writes; engine-wide denial-of-service and other
mods' vanilla mutation paths are not claimed protected.

Offline authorization was used without fetching or writing any remote. Initial
cached ancestry was current versus upstream with dirty extraction work. During
the task, separate extraction work advanced the checkouts to Quartermaster
`807b92ad95ce2445ec079219e62b1b3351aaf3fa` and Rooms
`fb500117ebf6f6f0444c15cce32cea2ce3ad7a3d`. Their new HEADs are recorded as
observations, not commits/pushes performed by this task. This task made no branch,
stage, commit, push, tag or external-account mutation. The current local
integration tail is not claimed backed up to GitHub; live remote freshness
remains unverified under the offline instruction.
