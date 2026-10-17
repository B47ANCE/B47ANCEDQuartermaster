# Auto Clean: offline Lua authority guard and single-square POC

Date: 2026-10-14 America/Phoenix. Observed parent version: `0.7.0-dev.1`.
Scope: the user authorized a Lua-only guard and isolated offline POC, using
**10 mL bleach first, then fill the bucket with water**. No game/server launch,
deployment, publication, packaging or public push was performed.

## Result

[TESTED offline] The isolated controller completes the three-stage scenario
through the actual installed native Lua constructors/callbacks, with engine,
fluid storage, world and transport test doubles. **31 scenario groups PASS.**
The current existing Quartermaster offline regression suite also PASSed with
zero production-source changes during that execution. Native Java fluid
transactions, packets, real save/load and dedicated behavior were not executed.

[VERIFIED source] New code lives only in `research/auto-clean` and standalone
tests; it is outside packaged `src` and the production inventory. There is no
new Mod ID, new client command, shared action class registration, global vanilla
method replacement, event hook, direct fluid/blood mutation or persistent state.
Original native actions perform the mutations after guard checks.

This closes the offline controller/callback milestone. It does **not** establish
a deployed dedicated-authoritative network integration. G6 native POC NOT
TESTED; G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.

## Files and version decision

| File | Responsibility |
|---|---|
| `research/auto-clean/Guard.lua` | Server-only lifecycle, exact action binding, resource/footprint claims, state revalidation, observed receipts, cancellation, expiry and bounded tombstones |
| `research/auto-clean/NativePort.lua` | Verified native reads, strict fixture validation, native constructors, native CanTransfer/clean validation and float measurement bounds |
| `research/auto-clean/Poc.lua` | Per-instance serverStart/complete/stop/progress guards; delegates the original native callbacks |
| `research/auto-clean/README.md` | Isolation and activation boundaries |
| `tests/test_auto_clean_guard.lua` | 31 scenario groups; actual installed native Lua callbacks with explicit simulated engine/float32 model |
| `tests/run_auto_clean_guard.py` | Lua 5.1 runner, source/JAR audit parity, class metadata, syntax, isolation checks and explicit evidence output |
| `docs/audits/AUTO_CLEAN_GUARD_OFFLINE_EVIDENCE.json` | Observed version/HEAD, exact code/native hashes and simulated before/after receipt |
| This report | Implementation decision, commands, outcomes and runtime gates |

Current/target development checkpoint remains `0.7.0-dev.1`: this is an inert
research slice within the already-open development checkpoint, with no public
gameplay, API, configuration or save contract change. No canonical version or
mirror was edited. Integrating a distributable gameplay feature is a compatible
MINOR capability and requires its own recorded version/configuration decision;
this experiment does not select a future release version or invent a Mod ID.
The work remains local/uncommitted and is not claimed as GitHub backup.

Freshness preflight initially observed HEAD
`674ad3809701c772d7e6ee2bb4670d8b4a4aae58` on `feature/custom-rooms`, matching
`origin/fix/transfer-throughput` (0 ahead/0 behind), ahead 10/behind 0 versus the
reported remote default ref. Result REVIEW for existing dirty work. Other work
subsequently committed the room implementation as
`de6101c45f6d09f6c926cb8afe09105c4c0dec30` and selected
`feature/rooms-extraction`. This task made no checkout, staging, commit or remote
mutation and did not edit that production work. Evidence records the actual
HEAD when each test ran rather than relabelling earlier audits.

## Separate Rooms project

User correction: room ownership has moved to its own project. The verified
`B47ANCEDRooms/AGENTS.md` assigns geometry and room permissions to that project,
with Quartermaster an optional consumer. Its README observed `0.1.0-dev.1` and
described extraction in progress. The inspected Quartermaster snapshot still
contained room code while the extraction branch was active; that is not an
Auto Clean integration dependency.

This POC imports neither Rooms nor Quartermaster modules. It accepts one native
square and manually prepared supplies selected by trusted server-side code.
Future room-wide work must consume the separate project's accepted server-owned
API, without duplicating geometry or taking room authority into Auto Clean.
No files in the Rooms repository were edited.

## Authority model and native integration boundary

`Poc.new(NativePort.new())` returns a controller for a **trusted server-side
caller**. `begin(actor, selection)` binds actual current actor/item/source/square
references after native validation. `next(actor,id)` returns a native action
instance guarded for that operation. A trusted test driver invokes the native
server lifecycle; no client can submit this selection or invoke these methods
through a registered command. `status` returns copied scalar receipts only.

The server holds all operation state. The opaque operation ID grants nothing
without the bound server actor and exact retained action instance. Clients are
rejected at every controller/mutation boundary. Registered actions execute
`serverStart` once before mutation; repeated completion, phase skipping,
reentrancy, old IDs and foreign actors are rejected. Local `perform` is not
credited as authoritative completion.

Reservations cover bucket, bleach, tool, water object and fluid components plus
the native blood-removal footprint. They serialize **this controller's** runs;
they are not global locks on vanilla activities or other mods. External changes
invalidate the next guarded mutation. Mutating callbacks run without a Lua
yield; outcome uncertainty is recorded rather than compensated or retried.

The verified native transport reconstructs actions from class constructors.
Per-instance wrappers do not survive that reconstruction. Also, public
NetTimedAction methods inspected here provide no requester-player getter.
`PZNetKahluaTableImpl.loadIsoGameCharacter` delegates to CharacterID/PlayerID;
`PlayerID.parsePlayer` uses the connection for a normal local index, but has a
global player-map fallback for index -1. Do not treat a constructor's character
argument alone as a universally sender-bound authorization context.

Therefore this experiment registers **no network action class, client handler,
or scheduler bridge**. Sending its instances through the normal native request
path would lose the guard and is prohibited. Before a native pilot, establish a
source-grounded sender-bound server integration that installs guards at the
actual server reconstruction/completion boundary, preserving native timing and
transactions. If that cannot be achieved through exposed Lua APIs, that affected
integration remains blocked; do not substitute client authority or Java.

## Preconditions and validation

The strict first fixture requires:

- One connected, living server actor, an empty `Base.Bucket` with actual 10 L
  capacity, a carried `Base.Bleach` container of pure bleach, and one held,
  nonbroken native clean-stains tool. Items must still be the exact retained IDs,
  objects and fluid components in the actor's inventory. Favorite or crafting-
  consumed items are excluded. No storage retrieval is implemented here.
- A live finite world fluid source containing pure Water, with no external
  plumbing. Its native amount must equal its own component amount and be below
  the native infinite-source sentinel. Enough water/bleach must remain to avoid
  trace-pruning ambiguity in this specific fixture. Infinite, tainted, virtual,
  mixed and indirect sources are outside this first POC.
- Current same-floor adjacency and no native blocked edge to both target and
  water source; exact source existence; current safehouse interact/loot access.
  A grant does not authorize future reach or permission changes.
- A loaded, blood-stained native target. Because native floor removal has no
  explicit Z filter, the guard conservatively validates the XY ±1 footprint at
  every `IsoCell.getMinZ()` through `getMaxZ()` level, including the upper bound.
  Every square must be loaded, in the same chunk and currently permitted.
  Missing levels, chunk edges and unavailable squares fail closed. This can
  reject many normal game locations and requires native acceptance; it never
  creates missing squares or assumes they are empty/permitted.

The footprint traversal is bounded to 64 levels / 576 squares. Maximum four
active runs, 32 closed receipts, a two-minute lifetime and 4,096 mutation calls
per run are internal safety limits. Closed receipts release world handles.
No world scan or automatic per-frame work is registered. Performance under a
real engine is NOT TESTED.

Every native mutation checks current exact snapshots, resource ownership,
action accounting fields, access, footprint and actor validity. It also checks
native CanTransfer or native cleaning validity. Bleach source start amount,
requested dose, water starting amount/cumulative fill amount, target square
and saved cleaner cannot be substituted after grant.

## Native sequence and resource receipts

1. Construct native `ISFluidTransferAction` for **0.01 L** bleach into the empty
   bucket. Guard both progressive `update` and final `complete` callbacks.
2. After measured dose success, construct native `ISTakeWaterAction` using
   remaining native bucket capacity. Guard the `transferFluid` mutation point,
   including calls reached through progress, emulated animation or completion.
   Full native fill is required before the next phase.
3. Construct native `ISCleanBlood` with that exact bucket and square. Revalidate
   immediately before original native completion. Observe actual mixture loss
   and native blood/grime state before recording completion.

Cancellation preserves measured native partial transfers. Disconnect, death,
expiry, stale data and invalid native filters stop further guarded mutation.
A native error after partial mutation is **uncertain**, retaining observed
values and preventing repeat invocation. There is no automatic fluid refund,
rollback, blood deletion, item creation or retry. `tick()` must be called by a
future trusted server driver for proactive expiry/disconnect cleanup; mutation
checks still fail closed without that tick. A new controller has no old grants.

Snapshot comparisons before mutation are exact. Conservation checks account for
float32 subtraction precision using eight ULPs of original measured operands;
they do not hide deviations by rounding UI labels. Stage dose/full-fill checks
remain tied to their own measured quantities. Native cache-capacity snapping or
trace loss outside that bound produces uncertainty instead of an invented
correction. Exact zero-loss engine behavior remains unproven.

Representative successful **simulated** receipt (litres, rounded here only for
readability; full values are in the evidence JSON):

| Checkpoint | Bucket total | Bucket bleach | Bucket water | Bleach source | Water source |
|---|---:|---:|---:|---:|---:|
| Initial | 0 | 0 | 0 | 1 | 12 |
| Native bleach callback | 0.0099999998 | 0.0099999998 | 0 | 0.9900000095 | 12 |
| Native fill callback | 10 | 0.0099999998 | 9.9899997711 | 0.9900000095 | 2.0100002289 |
| Native clean callback | 9.7500095367 | 0.0097500095 | 9.7402591705 | 0.9900000095 | 2.0100002289 |

The test observed one simulated blood removal, native grime removal and three
successful stage receipts. These are results of Lua callbacks with a simulated
float32 fluid store, not execution of Java FluidContainer or a PZ world.

## Configuration and persistence

No sandbox options are introduced for a non-distributed, fixed test fixture.
The specified 10 mL input, empty 10 L bucket and finite pure-water source define
this experiment, not hidden configurable gameplay behavior or an asserted
minimum cleaning dose. A future active feature needs server-authoritative,
localized sandbox configuration and existing-save behavior before integration.

Only ephemeral server operation state and bounded in-memory receipts exist.
No ModData, room schema, inventory schema or save migration is written. Native
items/world state remain native-owned. Restart clears grants; it does not replay
work. Actual native save/load consistency and crash atomicity remain runtime
gates, with no compensating mutation implemented.

## Validation commands and outcomes

Run from the Quartermaster repository root in PowerShell:

```powershell
$py = 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$gameRoot = 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'
& $py scripts/check_versions.py --root .
& $py tests/run_auto_clean_guard.py --game $gameRoot --report docs/audits/AUTO_CLEAN_GUARD_OFFLINE_EVIDENCE.json
& $py tests/run_tests.py
& $py scripts/check_versions.py --root .
```

[TESTED offline] Targeted runner PASS: 31 scenario groups, Lua 5.1 syntax,
prior-audit native Lua/JAR hash parity, relevant native class signatures,
no runtime ingress/direct mutations/room-module imports, and production-inventory
exclusion. The evidence records exact source/JAR/effective-class hashes and
observed HEAD. It never invokes Java or launches the game/server.

Scenarios include full recipe order and measured completion; before-start,
repeated-start and local-perform rejection; client/foreign/unknown identity;
partial bleach and fill cancellation; repeated progress; stale items/components,
source, tool, target, permissions and accounting fields; death/disconnect/expiry;
overlapping claims; multilevel/chunk-edge refusal; finite pure-source limits;
malformed amounts; native filter denial; resource-gain detection; native errors
after partial fluid/world mutation; reentry; cancellation claim release;
bounded receipts; restart rejection; copied receipts; and unchanged vanilla
class methods.

Existing full regression PASS / exit 0, with zero production-source drift during
the run. Its production hash-map digest was
`e822df14097d160f2603b4aec5a223df936661db625e685e5b5178985aa3bb0f`
(SHA-256 of compact sorted-key JSON). Private full output is retained in the
temporary audit session, not committed as player/server diagnostics. Subsequent
isolated guard refinements were validated by the targeted runner.

Version checker PASS / exit 0 before/after this slice: current source mirrors
agree at `0.7.0-dev.1`, and no current package exists. Missing artifacts are
deferred, not a release pass. The earlier audit's stale-package failure is
historical evidence of its own snapshot; this task did not remove that package.
No packaging or `--release` gate was run.

## Remaining native gates

1. Prove trusted sender binding and server reconstruction/scheduling of guarded
   native actions; do not serialize this instance-only offline adapter.
2. Confirm Lua API exposure, native float conservation, progressive filling,
   strict footprint availability and callback order in an authorized clean
   disposable native environment without the observed third-party Java agent.
3. Verify two-client authority, competing native activities, cancellation at
   completion, source/bucket ownership changes, blood/grime replication, late
   join, disconnect/death, save/reload and dedicated restart.
4. Define the separate Rooms consumer API and neutral Quartermaster supply
   borrowing/return interface before any room-wide automation.

No native or dedicated gate is marked PASS. This deliverable is the offline
server guard and reproducible single-square POC; activation is a separate step.
