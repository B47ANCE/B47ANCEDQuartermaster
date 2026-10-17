# Quartermaster supply extension API

Project Version: 0.14.0-dev.2

Current iteration: [Dangerous Load, ledger boundaries and validation](LEDGER_AND_LOAD.md). Existing SupplyAPI, Rooms permissions and container configuration contracts are unchanged.

## Current development iteration

SupplyAPI remains version 1; its public contract is unchanged. Sort movement capability is separately 9. Auto Clean is the existing separate Workshop mod (3820151540) and is unchanged here. Extraction/no-item statements below describe the original checkpoint, not current publication status. See [implementation and evidence](PROGRESS_CARRY_AND_CONTAINERS.md).

The user requested a separate Auto Clean mod and explicitly selected a required
Quartermaster supply provider. Quartermaster owns SupplyAPI 1 and configured
storage; B47ANCEDAutoClean owns Clean Building. Rooms owns geometry, permissions
and existing cleaning sandbox settings. Dependency graph:
B47ANCEDAutoClean -> B47ANCEDQuartermaster -> B47ANCEDRooms, with Auto Clean also
declaring its direct Rooms dependency. Quartermaster does not require Auto Clean.

This is a breaking 0.x packaging change from 0.10.0-dev.1: enable the separate mod
to retain cleaning. Sorting behavior, storage configuration, protocols and saved
schemas are unchanged. The old embedded cleaning reports/tests are historical;
their current successors belong to the Auto Clean project. No Workshop item has
been assigned to Auto Clean and no upload is authorized by this extraction.

## Contract

Load `require 'B47ANCEDQuartermaster/SupplyAPI'`. Version is 1; `ready=true`
describes the installed API, not permission to mutate. `capabilities()` returns
fresh metadata with `api=1`, project version, `configuredStorage=1` and
`nativeTransfer=1`. Consumers must check required methods and capabilities.

- `prepare()` checks active-mod compatibility and loads existing Quartermaster
  authority readers on the server/SP. It returns true or false, reason.
- `actorAvailable(actor)` admits only the exact connected server player or exact
  local player offline, rejects clients/combined roles/dead actors and refuses
  overlap with Quartermaster movement operations.
- `configuredStorage(actor, record)` checks current Target/Store/Presets identity
  and nonempty effective settings. It does not disclose hidden storage to clients.
- `storageItems(actor, record)` returns the authority's native list only after
  loaded physical storage, configuration, Rooms inspect/withdraw permission and
  identity checks. Oversized lists return nil, inventoryTooLarge (4096-item
  technical bound). Other denial returns nil, unavailable.
- `storageAllowed(actor, record, action)` checks withdraw or deposit, exact item
  identity/current holder, live source/destination permission and capacity,
  attachment/equipment/protected-item state. Unsupported native transforming
  item types are refused. A caller-supplied position never selects storage.
- `transferAction(actor, record, direction, seconds)` returns a native base timed
  action or nil, reason. Direction is fetch/return. Seconds must be an integer
  from 1 to 10; Auto Clean obtains this from Rooms' authoritative setting.

Records contain actual server/local handles: obj, square, ci, container and (for
item operations) item. They are never accepted over this API's network ingress:
it has none. Consumers must bind client intent to authenticated player identity
before resolving records. Returned lists/actions are authority handles, never
client wire payloads. No function accepts arbitrary mutation callbacks.

The returned transfer retains original actor/item/container references, checks
arrival and live access at start/completion, has a 120-second technical lease,
and latches before native mutation to reject replay/reentry. Vanilla
ISTransferAction:transferItem performs the move; destination synchronization is
sent only on a server. The consumer must preserve its own job guard and natural
native scheduling; a direct call from trusted server Lua is not a remote timed
action authorization. Auto Clean retains the authenticated native transport or
local queue and wraps this exact action with its existing BuildingJob guard.

## State, configuration and migration

No registry, persistent reservation or new sandbox setting is introduced.
Existing storage configuration and Rooms permissions remain authoritative.
Action leases/jobs are transient; no resume is attempted after reconnect/reload.
All meaningful cleaning settings remain in Rooms. Traversal/admission/expiry
limits are internal safety limits, not new player options.

Old Quartermaster lacks SupplyAPI and cannot run the new Auto Clean installer.
The new installer refuses missing/malformed providers and an already-running
embedded cleaner. The native action class/channel and constructor parameters
remain unchanged, but peers must update/enable matching selected mods together.
Update while jobs are stopped; do not mix old embedded and separate installations.
Quartermaster alone now registers no cleaning menu/class/command handler.

## Evidence

[VERIFIED source] Lua-only extraction from Quartermaster commit
9003109d2e5eb2dda6590cc66922895e1732f3b3 / 0.10.0-dev.1. Installed PZ 42.21.0,
Steam build 25485521: native transfer helper's exact signature and server-only
source synchronization were inspected. No game files or third-party mod source
are modified or copied into runtime packages. Source provenance/fingerprints are
recorded by the Auto Clean extraction ledger.

[TESTED offline] `python tests/run_tests.py` includes 30 SupplyAPI cases using
the installed native Lua helper and simulated engine/inventory/permission state.
The separate Auto Clean suite tests actual provider/Rooms and native Lua actions,
including full fetch/clean/return in SP and authenticated MP transport doubles.
`python scripts/check_deployment.py` verifies Quartermaster's exact source set
and absence of embedded cleaning. `python scripts/check_versions.py --root .`
checks current mirrors. No package, deployment or Workshop upload is performed.

[RUNTIME GATE] Actual SP/load order/split-screen and dedicated join/rejoin,
observers, permission changes, persistence and restarts remain NOT TESTED.
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Offline PASS is not runtime proof.
