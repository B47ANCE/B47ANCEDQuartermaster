# Clean Building single-player execution

Project Version: 0.10.0-dev.1

Compatible MINOR addition from 0.9.0-dev.1. Rooms 0.1.0-dev.1 remains required
(Mod ID B47ANCEDRooms / Workshop 3820077442). Auto Clean remains embedded in
Quartermaster (Mod ID B47ANCEDQuartermaster / Workshop 3807217050). Neither
network protocols nor save/registry schemas change. No Rooms update is needed.

## Authority and native lifecycle

[VERIFIED source] Startup chooses singlePlayer only when both isClient() and
isServer() are false. The local port additionally binds every actor to
getSpecificPlayer(actor:getPlayerNum()) by exact engine identity. Network clients
and ambiguous combined roles cannot use this port. Startup loads the existing
Quartermaster authority readers before creating jobs. It installs once through
the existing lifecycle hooks; there is no network command listener or network
action class registration for SP.

LocalQueue queues the exact action returned by BuildingJob/Poc through the
vanilla ISTimedActionQueue. Local start invokes the retained guarded serverStart
closure to admit the operation, then native presentation start. Poc omits only
the vanilla network-only serverStart hook in local mode: ISTakeWaterAction's hook
requires a netAction and emulates network animation events. Native local update
and complete perform the water transfer under the existing transferFluid guard.

Native complete is accepted once, for the same current queued action, matching
actor/operation/phase, started lease and native job delta 1. Completion never
forces native time/progress. Native perform retains sounds/presentation cleanup
and queue removal. Stop/forceCancel close the job and retain native stop cleanup.
Cancellation invalidates all later mutation callbacks; it requests native stop
only for this mod's current action; a replacement current action is left alone.
Native stop retains vanilla queue-cancellation semantics for following actions.

BuildingJob, Poc and Guard still own supply selection, borrowing/return admission,
resource locks, exact identities, live permissions and measured fluid outcomes.
NativePort still enforces pure finite water, supported equipment, capacity,
bleach-first preparation and the full conservative cleaning footprint. Local
inventory transfers use the same native transfer helper; only its explicit MP
destination synchronization is omitted offline. MP retains its existing command
sender binding, fresh challenge, reconstruction and retained guard callbacks.

Rooms is already able to run its registry, cleaning scope and sandbox validation
offline. No Rooms source change or additional setting is necessary. Existing
CleanBuildingEnabled controls the feature in SP and MP. All other cleaning
sandbox options remain authoritative for the current world. Protocol/time/claim
limits stay internal technical limits, not gameplay micro-settings.

Jobs and action leases remain transient. Save/load and reconnect do not resume
jobs; native inventory/world persistence remains engine-owned. No new saved data
or migration is introduced. Split-screen actors are bound independently, while
Rooms' existing per-building claims prevent concurrent jobs on the same building.

## Evidence and validation

[VERIFIED source] Installed PZ 42.21.0 / Steam build 25485521. Vanilla
ISBaseTimedAction.begin/create use LuaTimedActionNew; native timed-action bytecode
invokes local start/update and invokes complete only outside GameClient mode.
BaseAction.complete does not reset delta. Vanilla ISTimedActionQueue.add and
onCompleted own admission/queue progression. ISTransferAction:transferItem guards
MP synchronization with isServer(). Existing Rooms Registry uses exact local
player binding. Detailed fingerprints are retained in ignored release evidence
and the local API audit draft; no game source or custom Java is shipped.

[TESTED offline] tests/run_auto_clean_single_player.py runs actual installed Lua
base/queue/actions and Rooms with a simulated native engine/world/pathfinder.
It covers the one-click full workflow, partial fluid updates, bleach before
water, duplicate callbacks, cancellation, native stop, death, player replacement,
network-role change, scope/settings changes, resource/source/tool changes, unsafe
footprints, lease expiry, denied storage and prevention of MP use of local mode.
The existing 83 guard/MP transport/building/startup scenarios also run.

Exact validation commands (configured Python interpreter with lupa/jawa):

```powershell
python scripts/check_versions.py --root .
python tests/run_auto_clean_single_player.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --rooms ../B47ANCEDRooms
./Build-Workshop.ps1 -WorkshopRoot "dist/workshop-publish/0.10.0-dev.1-single-player/staging"
python scripts/check_deployment.py --package --stage "dist/workshop-publish/0.10.0-dev.1-single-player/staging/B47ANCEDQuartermaster"
python scripts/check_versions.py --root . --release
```

Canonical Workshop inputs remain WORKSHOP_DESCRIPTION.txt and
WORKSHOP_CHANGE_NOTE.txt. The isolated staging tree, submission.vdf, release
manifest, package hashes, preservation ledger and actual upload/download receipt
belong under dist/workshop-publish/0.10.0-dev.1-single-player/. The exact preceding
0.9.0-dev.1 ZIP/hash/provenance are retained in dist/history.

[VERIFIED distribution] Uploaded to existing Workshop item 3807217050 from
public release commit 08399c47a23cdb1f248d22fd68882af5edc8093d. Package SHA-256:
0ef279848e4aaa111d339747bd9bebb1e29dd068f631290e6b81ea0ac8b1d890.
SteamCMD reported successful upload/download; all 142 downloaded files match
the source/package/stage hashes. The live page shows 0.10.0-dev.1, SP enabled
for testing and Rooms under Required Items, with unchanged public visibility.
All 102 focused offline scenarios and the full build passed. Steam desktop
was gracefully restarted and its process verified. The local receipt binds
these observations to the exact release manifest; no in-game result is claimed.

[RUNTIME GATE] Actual PZ single-player, split-screen, saving/reloading mid-job,
listen-server and dedicated execution remain NOT TESTED. G7 BLOCKED / NOT TESTED;
stable G8 BLOCKED. Explicit authorization permits a labeled Workshop testing
upload after all offline/security/authority/package checks pass. Distribution
success does not prove in-game correctness. No game/server launch or local SP
deployment is part of this request. The existing cross-level native footprint
restriction can skip many or all targets and remains unchanged.
