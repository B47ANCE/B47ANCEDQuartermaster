# Auto Clean native transport: offline Lua integration

Observed parent checkpoint: `0.8.0-dev.1`; HEAD
`de6101c45f6d09f6c926cb8afe09105c4c0dec30`. Installed source target: Build 42.21.
This report supersedes the *future integration boundary* in the earlier guard
report, without changing that report's historical evidence or version.

## Outcome and evidence limits

[TESTED offline] **31 guard + 23 transport scenario groups PASS** in Lua 5.1.
The transport tests load the installed `ISBaseObject`, `ISBaseTimedAction` and
native fluid/fill/clean Lua callbacks. Engine objects, float32 storage, packets,
native scheduling and event delivery are simulated. Java bytecode is parsed,
never executed. This is an implemented research integration, not an in-game
transport test or a runnable mod.

[VERIFIED source] Native `OnClientCommand` binds its player argument to the
actual connection. The server constructor returns the retained guarded action;
it does not recreate an unguarded vanilla action from client-selected resources.
Native raw callback fields and timing methods survive the metatable change.

The native timed-action packet's sender is **not proven** by its serialized
character. Mutation authority therefore uses a second, connection-bound native
command with a fresh challenge for that reconstructed instance. No completion
or mutation command is exposed. This protects the experiment's guarded writes;
it does not repair engine-wide packet identity or denial-of-service behavior.

[RUNTIME GATE] No PZ/client/server was launched, installed or published. Native
packet behavior, actual API execution, synchronization, save/load and dedicated
multiplayer remain NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

## Files and activation boundary

| File in `research/auto-clean` | Purpose |
|---|---|
| `NativeAction.lua` | Shared class factory; fixed constructor projection; preserve resolved native methods as raw fields before stamping the new metatable |
| `ServerTransport.lua` | Connection-bound command validation, actor/phase leases, reconstruction, confirmation, guarded callbacks, expiry and cancellation |
| `ClientTransport.lua` | Pending intent, native presentation queue, challenge confirmation after local start, native completion/result ordering |
| `NativeWire.lua` | Explicit native command/event/class bindings, targeted messages and client resource resolution; no activation at require time |

`Guard.lua`, `NativePort.lua` and `Poc.lua` retain their implementation. The
existing guard test now exports its test-only fixture, and its runner scopes
the no-ingress check to those original three modules. The new transport runner
checks inert loading, explicit installation, native source contracts and absence
of direct world/fluid writes or custom timer completion. Prior evidence JSON is
preserved; new hashes and receipts are in `AUTO_CLEAN_TRANSPORT_OFFLINE_EVIDENCE.json`.

All code remains outside `src` and its production inventory. There is no Mod ID,
vanilla class replacement, room authority, persistent schema, release package or
public API introduced. The explicit installers are tested only against offline
event doubles. They are not invoked in a real game environment.

## Source verification of sender and reconstruction

The runner records effective class SHA-256 values and instruction hashes, and
fails if the inspected sender/reconstruction contracts no longer match.

1. `GameServer.receiveClientCommand(reader, connection, short)` reads the local
   player index. Offsets 64–69 pass **that connection** and index to
   `getPlayerFromConnection`, retaining the result in local 8. Index -1 uses
   `getAnyPlayerFromConnection` at 76–80. Both helpers only call that connection's
   `getPlayerAt` over indexes 0–3; neither uses the global player map. Null player
   returns before the event. Offsets 217–228 dispatch `OnClientCommand` with
   module, command, **local 8**, and args. The handler trusts this argument only;
   payload `player`, `actor`, resource, timing and callback fields are rejected.
2. `PlayerID.parsePlayer` used by character serialization also has a global-map
   fallback. A constructor's `character` argument alone cannot authenticate a
   sender. The exposed `NetTimedAction` does not provide a public connection or
   requester-player getter; the native ActionManager is not exposed as a Lua
   submission API. No protected fields, reflection, bridge or injected class
   are used.
3. `NetTimedAction.set` reads its action metatable's **raw `new` Lua closure** and
   prototype parameter names, then reads matching raw action fields. The new
   class uses exactly `new(character, operation, phase, grant)`. Amounts, native
   resource objects, duration, callbacks and state snapshots are not parameters.
4. `NetTimedAction.parse` invokes the global type's constructor and retains its
   returned table, then attaches `name` and `netAction`. The server resolver
   validates the actor/operation/phase/grant and returns the same server-held
   native table with its guard closures. Unknown, expired, mismatched and second
   constructor calls fail closed. `NetTimedActionPacket.getAction` uses
   `copyFrom`, which retains that table and reattaches the native action pointer;
   it does not call the Lua constructor again.
5. Native start, duration, adjusted duration and completion look up raw callback
   fields. `NativeAction.stamp` preserves the resolved inheritance chain as raw
   fields, including `getDuration`, `adjustMaxTime`, `isUsingTimeout`, native
   helpers and existing guarded callbacks, before changing the metatable.
6. `NetTimedAction.start` calls native `setTimeData` before Lua `serverStart`.
   `Action.setTimeData` uses server time and the returned action's duration.
   `getAdjustedDuration` calls that table's `adjustMaxTime`, so actor modifiers
   come from its server-retained character. Client `LuaTimedActionNew.start`
   submits the native action and waits for native completion; update reacts to
   native Done/Reject. Dedicated `NetTimedAction.update` is empty. The integration
   neither invents a server update callback nor resets/forces the native clock.

The installed launcher/loose-class modifications recorded by the earlier audit
remain an unresolved native-environment gate. No vanilla or third-party files
were changed. Source inspection of these methods is not proof that the modified
installation behaves as a clean native runtime.

## Protocol and write ownership

A trusted server caller alone uses `poc.begin(actor, selection)` to bind actual
items, water source and one square. No network `begin` or selection command
exists. The client needs that operation ID from the trusted test driver; this
slice adds no UI or automated job discovery.

1. The bound client sends `next` for the known operation and current phase through
   native `sendClientCommand(actor, ...)`. Server ownership and phase checks
   prepare one guarded native action and an actor-bound grant. An identical
   pending request may resend the same offer; it never attaches another action.
2. The targeted offer contains read-only item IDs and world coordinates/indexes
   used to resolve local presentation. The client constructs the corresponding
   native action, stamps the shared type and queues it through
   `ISTimedActionQueue.add` only when its queue is empty.
3. Native server reconstruction returns the server-held object. Its `serverStart`
   sends a fresh instance challenge to that actor. Original guarded/native
   server start, update, transfer and completion remain unauthorized meanwhile.
4. The client confirms only when its matching offered action has locally started.
   A challenge arriving earlier waits for local start. The server compares the
   native command's connection-bound player with the lease owner, checks all
   identifiers, reconstruction/start flags, deadline and native progress, then
   invokes the original guarded `serverStart` exactly once. A foreign sender
   cannot confirm even knowing the grant and challenge.
5. Native callbacks perform all mutations behind the original Guard. The recipe
   remains **10 mL pure bleach into an empty 10 L bucket first, then native water
   fill to capacity, then one native cleaning action**. Exact resources,
   current permissions/access, accounting, conservation and footprint checks
   remain in force. Before-confirmation completion cancels without mutation.
6. Server result is a receipt, not a client completion command. The client waits
   for both the result and normal native perform before freeing its pending
   record. It never credits local perform, forces completion or queues a next
   phase automatically. Stops, expiry, disconnects and reconstruction replays
   cannot resume a retired action. Partial/uncertain outcomes are not refunded,
   replayed or compensated.

Native command tables have exact small schemas. Internal bounds are one pending
lease per actor within the Guard's four active operations; 80-character tokens;
16 valid commands per actor per second; five seconds from grant to confirmation;
and the existing two-minute operation lifetime. These are implementation safety
limits, not gameplay configuration. Instant actions or excessive latency may
finish before confirmation and fail closed; no timer extension is attempted.
Future distributed gameplay still needs appropriate server sandbox configuration.

Native state and synchronization remain owned by vanilla items/fluids/squares.
Leases, pending requests and receipts are ephemeral. Reconnect/restart does not
restore or replay them; late join relies on native world state, not old action
messages. Actual replication, saving and crash behavior remain runtime gates.

## Validation and repository state

Exact PowerShell commands from the repository root:

```powershell
$py = 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$gameRoot = 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'
& $py scripts/check_versions.py --root .
& $py tests/run_auto_clean_transport.py --game $gameRoot --report docs/audits/AUTO_CLEAN_TRANSPORT_OFFLINE_EVIDENCE.json
& $py tests/run_tests.py
& $py scripts/check_versions.py --root .
```

[TESTED offline] Transport runner exit 0: 31 existing guard plus 23 transport
scenario groups; actual vanilla Lua inheritance/raw-field preservation;
constructor projection and retained action identity; source-bound sender path;
foreign/spoofed characters; pre-start/stale/wrong/replayed confirmation; direct
water animation/transfer bypass; accounting/permission changes; invalid native
clock; phase order; native partial error/uncertainty; cancellation, disconnect,
restart and expiry; rate limits; client local-start/result/perform ordering;
targeted native wire descriptors and all three client presentation constructors;
explicit installation/class collision/uninstall; no direct world writes or timer
forcing; no Rooms/Quartermaster runtime dependency. Java and real transport are
not executed. Production files did not drift during this execution.

The full existing regression command exits 1 at the old room tests:
`B47ANCEDQuartermaster/RoomGeometry` cannot be imported after the separate Rooms
extraction removed that module. Source hash-map digest during that execution:
`5d7315ffba46510e2eb8189a2ef9be140d651241eee43f527ec3edadd0a6d937`;
no production drift occurred during the run. This slice does not repair or claim
PASS for concurrent extraction work. Private full output is retained under the
local temporary `b47-autoclean-transport-51zu2p6o` audit directory.

The version checker currently exits 1: canonical `0.8.0-dev.1` does not have a
matching newest changelog entry (still `0.7.0-dev.1`). No current package exists;
that is deferred, not a release PASS. Both failures were observed before this
slice and remain owned by the concurrent extraction work. This task edits no
canonical version, mirror, production source, changelog or packaging inventory.
The inert research checkpoint stays within the observed development version;
an eventual active feature would be a compatible MINOR capability requiring
its own version/configuration decision. Historical 0.7 evidence is not relabelled.

Offline preflight: `feature/rooms-extraction`, HEAD/upstream both
`de6101c45f6d09f6c926cb8afe09105c4c0dec30`; upstream
`origin/feature/custom-rooms`, cached divergence 0 ahead / 0 behind; cached
remote-default divergence 11 ahead / 0 behind. Dirty work was reviewed and left
untouched. No unfinished operation was observed in the prior preflight. No
network fetch was attempted under the user's explicit offline instruction;
live remote freshness is UNKNOWN. No branch, staging, commit, push, tag or
external account mutation was performed. Local research is **NOT BACKED UP**.

## Remaining gates

- [RUNTIME GATE] Clean disposable native environment: validate class lookup,
  constructor parameter introspection, raw methods, native action-pointer
  reattachment, challenge delivery, short actions, packet/result ordering and
  failure/cancel behavior. No real native test is claimed here.
- [RUNTIME GATE] Two-client dedicated tests: sender/character spoofing, races,
  replay, simultaneous native activities, cancellation/death/disconnect,
  progressive water filling and measured conservation, blood/grime replication,
  late join, save/reload and restart. Native packet processing can stop previous
  player actions before Lua confirmation; this experiment does not claim to
  prevent engine-level interruption/denial-of-service outside its guarded writes.
- [RUNTIME GATE] The existing conservative multi-Z native blood footprint can
  refuse normal locations. It still requires loaded permitted same-chunk
  squares throughout the bounded footprint; no relaxation was introduced.
- Room-wide work must use the separate Rooms project's accepted authority API.
  Storage borrowing/return and active sandbox/UI integration are outside this
  single-square transport slice. G7 and stable G8 remain BLOCKED.
