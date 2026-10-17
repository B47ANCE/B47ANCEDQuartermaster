# Clean Building source testing

> Historical embedded 0.10.0-dev.1 checkpoint. Current cleaning source/tests live in B47ANCEDAutoClean; see SUPPLY_API.md for Quartermaster’s current provider.

Project Version: 0.10.0-dev.1

Current dependency contract: Rooms is mandatory for Quartermaster and its embedded Auto Clean. Native `mod.info` requires `B47ANCEDRooms`; Quartermaster Workshop item 3807217050 requires Rooms item 3820077442. Auto Clean has no separate Mod ID or Workshop item here. The current single-player adapter is documented in [CLEAN_BUILDING_SINGLE_PLAYER.md](CLEAN_BUILDING_SINGLE_PLAYER.md); multiplayer guards are unchanged.

[VERIFIED source] The existing Quartermaster Mod ID now includes the AutoClean
modules under `42/media/lua/shared/B47ANCEDQuartermaster/AutoClean`. No new mod
identity or Java dependency is introduced. `Startup.lua` registers the
vanilla `OnGameStart` and `OnServerStarted` events, selects the current multiplayer or offline
role at dispatch and installs exactly once. These events are used together by
the installed Build 42.21 `shared/Util/CustomTileProps.lua`. Server initialization
requires Quartermaster's authoritative readers; client initialization creates
presentation, command listeners and the world context menu. Startup does not
scan the world or create jobs.

Single-player support is a compatible MINOR addition in 0.10.0-dev.1; earlier
0.8.0-dev.1 activation notes are historical. Rooms remains at its open 0.1.0-dev.1
construction checkpoint. Existing sorting APIs, Mod IDs and save namespaces are
preserved. Cleaning capability/protocol 1 is independent of project versions.
Current metadata follows the canonical VERSION;
historical audit reports retain the versions/hashes they actually observed.

## Test entry and supported scope

After a separately authorized test installation, enable matching current
Quartermaster and Rooms source on both server and clients. Rooms must expose
API 1, `ready=true` and cleaning capability 1. Older Rooms builds fail closed.
Rooms is required by native mod.info and Workshop. Missing/incompatible cleaning
capability fails closed without a cleaning menu or ingress.

Workshop follow-up: the user authorized a new Rooms item, assigned ID 3820077442.
Subscribe to that Rooms item and Quartermaster item 3807217050, then enable both
Mod IDs (`B47ANCEDRooms`, `B47ANCEDQuartermaster`) on the server and every client.
Rooms 0.1.0-dev.1 provides cleaning capability 1. The source-only installation
limitation in earlier dated publication notes is superseded by this distribution;
single-player now uses the guarded native local queue. In-game SP and dedicated
acceptance remain NOT TESTED.

Right-click while standing inside a loaded native building with an empty native
action queue and choose **Clean Building**. The command selects the actor's
current native building, rather than the clicked object's building. Rooms owns
the bounded native-building scope and independent `clean` permissions. Custom
room policies can restrict those tiles; this entry does not select a standalone
custom room or expand beyond the native building.

The authority (server or the offline local world) surveys loaded tiles and eligible configured physical storage, selects
the exact bucket, bleach, cleaning tool and finite pure-water source, then directs
fetching, walking, equipping, preparation, cleaning and optional return. Existing
eligible carried supplies are reused. With defaults, an empty supported 10 L
bucket receives **10 mL bleach first, then water to remaining capacity**. Supported
prepared solution is reused and refill accounts for residual bleach. The dose,
borrowing/return behavior, enable switch, building tile limit and logistics time
are authoritative Rooms sandbox settings with localized names/tooltips and
validated bounds. No hidden client recipe or gameplay preference is added.

During a job, the menu offers **Cancel Cleaning**. Cancellation/death/disconnect,
permission changes, unavailable geometry/resources and timeouts stop the job;
borrowed supplies can remain carried. Normal return rechecks the exact original
configured storage and current permissions/capacity. Completion reports actual
clean actions, skipped targets and retained borrowed items; it does not assert
that every stain was removed. Jobs/leases are ephemeral and are not resumed on
reconnect/restart. Native item/world persistence is retained.

## Authority and native limits

[VERIFIED source] Client commands carry bounded operation identifiers and intent.
Only the native `OnClientCommand` player supplies sender identity. Resource
references, dose, durations, scopes and callbacks are server-owned. The native
class constructor returns the retained guarded server action, with fixed
`character, operation, phase, grant` parameters. A targeted fresh challenge and
authenticated command confirmation are required before guarded native mutation;
the packet's character alone is insufficient. Reconstruction preserves the
instance guard closures. No client completion grants shared gameplay results.
The original sender/transport audit is retained under `docs/audits`.

Single-player uses LocalQueue to run the exact retained guarded actions through
the vanilla local scheduler, with exact local-player binding and no network
ingress. Multiplayer clients cannot select this authority. Ambiguous combined
client/server roles still fail closed. The console startup state
is `singlePlayer`, `server`, `client`, `RoomsCleaningUnavailable`, a compatibility failure, or
`installationFailed`. Source tests verify that an occupied native class cannot
be overwritten and repeated lifecycle events cannot register duplicate handlers.

Supported cleaning is native blood/grime only. Water sources must be finite,
pure, loaded and directly held by the source object; plumbed/infinite/tainted or
mixed sources are rejected. Supplies must pass current native and Rooms checks;
protected items and unsupported equipment fail closed. Inventory headroom must
cover the filled bucket and borrowing. No new chunk loading, teleporting or
forced native action completion is used.

The audited native floor removal can affect XY neighbors within a chunk without
a Z filter. The guard conservatively requires the entire potential footprint,
including all native cell levels, to be loaded, permitted and inside the selected
Rooms building scope. This can skip many or all targets in an ordinary building;
that restriction remains intact. Do not loosen scope/permissions to make a test
appear successful. Actual native packet handling can interrupt an earlier action
before Lua confirmation; the Lua guard does not fix that engine-wide limitation.

## Validation and remaining gates

Publication follow-up: the user subsequently authorized `publish`. The candidate
remains 0.8.0-dev.1, its first authorized Workshop test upload. Build/staging and
source commits are now authorized by the publication workflow; this does not
authorize SP deployment, game/server launch, or a new Rooms Workshop item.
Quartermaster's existing item is 3807217050. Rooms must be installed separately
from its public source. The statements below about no packaging/commit/upload
describe the earlier source-activation checkpoint, not the later publish request.
Actual upload success belongs in the publication receipt.

[TESTED offline] Windows host Lua 5.1 with installed native Lua actions and actual
Rooms API: 31 guard, 23 transport, 20 building/menu-click and 9 startup scenario
groups pass against the production modules. Engine/network/clock/world/walking
are simulated; Java is parsed for API evidence and is never executed by tests.
Production imports, Lua syntax, inventory and case checks pass. Both projects'
full regression suites and canonical version checks pass.

Exact commands, from the respective repository roots, using the configured
Python runtime (`C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`):

```powershell
# Quartermaster
python tests/run_auto_clean_building.py --source --game 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid' --rooms '..\B47ANCEDRooms' --report docs/audits/AUTO_CLEAN_SOURCE_OFFLINE_EVIDENCE.json
python tests/run_tests.py --require-rooms
python scripts/check_deployment.py
python scripts/check_versions.py --root .
git -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --check
# Rooms
python tests/run_tests.py
python scripts/check_versions.py --root .
```

The source evidence JSON records actual source hashes, installed API/bytecode
evidence, observed HEADs and simulated receipts. Prior research fixtures remain
outside `src`; `--source` maps their module names to production code and asserts
the executed module identities. The startup suite invokes the real production
installers with simulated engine lifecycle events.

[RUNTIME GATE] No game/server was launched. Use a disposable native-only test
environment: the inspected local game installation contains pre-existing loose
class overrides and an NPC framework launcher agent, so it is not a clean engine
baseline. These were not changed. Confirm startup/menu visibility, reachable
sources, native timing, exact measured bleach/water, neighboring/floor effects,
resource conservation and return/cancel behavior. Then test two-client forged
sender/reconstruction/replay attempts, shared supply/building contention,
revocation, reconnect, observers, save/reload and dedicated restart. G7 remains
BLOCKED / NOT TESTED and stable-release G8 remains BLOCKED.

No ZIP was built or replaced, and no deployment, publication, game/server launch,
commit or push occurred. Existing 0.8.0-dev.1 artifacts predate this source change
and are not source-parity evidence for it. Offline authorization persists; live
GitHub freshness is UNKNOWN. Cached branch HEAD/upstream were both
`807b92ad95ce2445ec079219e62b1b3351aaf3fa` (Quartermaster) and
`fb500117ebf6f6f0444c15cce32cea2ce3ad7a3d` (Rooms). The work is local/uncommitted
and NOT BACKED UP to GitHub. Unrelated `AGENTS.md` edits were preserved.
Cached default-branch comparisons were ahead 12 / behind 0 for Quartermaster and
ahead 2 / behind 0 for Rooms; upstream comparisons were ahead 0 / behind 0.
