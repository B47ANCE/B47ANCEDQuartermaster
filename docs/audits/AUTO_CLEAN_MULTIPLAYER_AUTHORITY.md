# Auto Clean: multiplayer authority audit

2026-10-14 America/Phoenix; observed `0.7.0-dev.1` dirty working tree.
[VERIFIED source] and [TESTED offline Lua doubles] are not dedicated runtime
evidence. G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.

## Authority decision

**A remote client can request a native cleaning action that completes on the
server, but the inspected chain does not safely validate the requested
automation contract.** Server execution and authoritative validation are
different findings. No automated cleaning gameplay was implemented.

Client context eligibility/path/equipment checks occur in
`media/lua/client/ISUI/ISWorldObjectContextMenu.lua:2408–2450`. The native action
is in `media/lua/shared/TimedActions/ISCleanBlood.lua`. Its `isValid`:17–20
searches any acceptable fluid item in inventory, not necessarily `self.cleaner`,
and checks a tool tag recursively (native `containsTagEval` delegates through
`getFirstTagEval` to `getFirstRecurse`). It does not revalidate its square at all.
Its `complete`:100–108 consumes the saved cleaner if present, then removes
blood/grime, without a current validation or once-only guard.

All bytecode offsets below are from the effective installed classes recorded
in [AUTO_CLEAN_B42_21_EVIDENCE.json](AUTO_CLEAN_B42_21_EVIDENCE.json), resolved
from loose class files before the JAR where present. No Java was executed,
modified, built, injected, or shipped.

## Native transaction chain

| Stage | Class/method and descriptor | Observed boundary |
|---|---|---|
| Client action start | `LuaTimedActionNew.start()V`; `ActionManager.createNetTimedAction(IsoPlayer,KahluaTable):byte` | Native timed-action request; uses constructor field metadata, not an Auto Clean command |
| Argument capture | `NetTimedAction.set(IsoPlayer,KahluaTable)V`:58–139 | Iterates Lua constructor parameter names and serializes corresponding action fields; nil uses native null marker |
| Server reconstruction | `NetTimedAction.parse(ByteBufferReader,IConnection)V`:6–227 | On Request, loads args, resolves action type/new, reconstructs Lua table, attaches `netAction` |
| Admission | `NetTimedActionPacket.processServer(PacketType,UdpConnection)V`:10–64 | Checks `isConsistent` and nonnull action; stops previous player action, starts accepted native action |
| Consistency | `NetTimedAction.isConsistent(IConnection)Z` delegates `Action.isConsistent`:0–8 | PlayerID consistency only in this delegation; not square/cleaner/tool/reach/safehouse validation |
| Server start | `NetTimedAction.start()V`:5–38 | Calls optional Lua `serverStart` |
| Server progress | `NetTimedAction.update()V`:0 | Empty. Do not assume it invokes the Lua action's `update`/`isValid` |
| Deadline completion | `ActionManager.update()V`:0–86 | Server accepted action reaches endTime, calls `Action.perform`; success sets Done |
| World mutation | `NetTimedAction.perform()Z`:0–27 | Calls protected Lua `complete`, takes returned boolean. No `isValid` call here |
| Cancel | `NetTimedAction.stop()V`:0–34 | Optional Lua `serverStop`; native action removal/cancellation path. Race with completion needs runtime observation |
| Client perform | `ISBaseTimedAction.perform`:68–72 | Removes local queue item and logs action. This alone is not server completion |

`LuaTimedActionNew.valid()Z` calls Lua `isValid`, but its existence does not add
that check to the inspected dedicated NetTimedAction admission/completion path.
Even invoking the existing clean validator on the server would not fix its
saved-reference and target gaps. Request acceptance/Done is not a receipt for
the exact amount consumed or the intended square's current eligibility.

## Per-operation ownership

| Operation | Native/Quartermaster mechanism | Assessment |
|---|---|---|
| Supply retrieval | `Bindings` server-issued session records; `Targets.valid`; `Movement.withdraw` and native Executor transfer | Source-grounded authority model available. Auto Clean borrowing adapter must preserve storage-only restrictions and current item identity |
| Bucket filling | `ISTakeWaterAction:new(character,item,waterObject,waterTaintedCL)`; server `serverStart`/`animEvent` + native `transferFluidTo` | Server mutation available; action validator lacks exact actor inventory/source identity, reach, permissions and measured result checks |
| Bleach transfer / mixing | `ISFluidTransferAction` serializes native fluid objects, server reconstructs wrappers, native Transfer | No actor argument in `CanTransfer`; UI-purpose validation is not a server ownership/access check. Amount must be finite/positive and authorized |
| Blood cleaning | Native `ISCleanBlood.complete`; RemoveBlood packet and item sync | BLOCKED for automation by missing exact current preconditions and duplicate guard |
| Refill | Same fill/transfer primitives | Requires serialized resource ownership and fresh checks each time, not cached source data |
| Equipment return | Native inventory transfer pipeline | Current sorting API selects rule-based destination; exact-origin return needs a bounded server-owned adapter and revalidated storage record |

No operation may accept client-supplied owner, item content, mixture amount,
reservation, target completion, or resource usage as authoritative truth.
Native inventory transfer remains responsible for physical item movement;
do not add direct AddItem/Remove code or compensate uncertain outcomes.

### Native helper limitations

`ISFluidUtil.validateContainer`, `shared/Fluids/ISFluidUtil.lua:6–18`, explicitly
documents UI-purpose validation. Its inventory branch uses
`isInPlayerInventory() or getPlayer():getInventory():containsID(...)`: it does
not prove ownership by the action's actor. `getPlayer()` fallback can be nil on
a headless server; whether that branch executes depends on actual object state.
The IsoObject branch only checks existence, not reach/permissions.
`ISFluidContainer.sync`:105–106 has an unimplemented ResourceFluid branch;
ResourceFluid is excluded from the POC and cannot be called supported MP storage.

## Synchronization and persistence evidence

- Server `IsoGridSquare.removeBlood(ZZ)V`:189–227 sends native RemoveBlood to
  relevant clients; `RemoveBloodPacket.processClient`:0–12 resolves/replays it.
- Native `removeGrime()` updates attached overlays and invokes object sprite
  replication; this is separate from floor blood packets.
- `ISCleanBlood.complete` invokes item `syncItemFields()`. The inventory native
  method selects player/container paths, and SyncItemFields packet includes a
  serialized FluidContainer. Other clients may not hold another player's private
  item object; observer UI visibility is not authoritative quantity evidence.
- FluidContainer save/load delegates species amounts/identity to FluidInstance;
  amounts are native floats. World and item save lifecycles are not shown to be
  one crash-atomic transaction by these methods.

[UNKNOWN] Packet arrival ordering versus action Done, lost/cancelled requests,
observer item availability, blood/grime rendering after unload/reload, late
join synchronization, disconnect/death cleanup and crash recovery. No game,
server, real save, remote logs or SFTP session was used here.

## Concurrency and failure test matrix

Every row is [RUNTIME GATE], currently NOT TESTED. Offline callback cases only
demonstrate the documented native gaps, not a multiplayer reproduction.

| Case | Source risk | Required acceptance for a future adapter |
|---|---|---|
| A/B clean same target | Native complete does not retest stains or reject duplicate work | Serialize/claim overlapping native footprint, recheck immediately before mutation; no second use on already-clean work |
| A/B contend for same bucket | Persisted action refs can outlive transfer/ownership | Only current legitimate holder may use it; old request fails without consuming another container |
| A/B draw same bleach | SourceStartAmount is not a reservation; contents can change | Serialized or reconciled native transfers, no negative/duplicated fluid, actual deltas recorded |
| A/B draw same finite water | Native cap prevents simple overflow but action progress may become stale | Current source/capacity checks and actual finite-source conservation |
| Target already cleaned/unloaded/replaced | `isValid` does not inspect target; native footprint includes neighboring splats | Re-resolve loaded identity and current stains; reject stale/boundary work without consumption |
| Actor disconnects | Deadline completion may race cancellation/cleanup | No unauthenticated continuation or replay on reconnect; release claims and reconcile only observed outcome |
| Actor dies | Same stale action/resources risk | Reject further gameplay, no refund/duplication; report completed partial native work honestly |
| Bucket removed/replaced | Another valid bleach item can make native isValid pass | Check exact item ID/reference, actor container, component identity, fluid state at commit |
| Mixture changes | No exact dose/composition lock | Re-evaluate exact current native validity and usage; never consume a substitute based on cached summary |
| Server restarts mid-operation | Operation and world/item saves may not be atomic | No automatic replay; load real native state, report uncertain work, new session/claims only |
| Cancel before/during/at completion | Client stop is not confirmation server stopped | Check early no-use, partial fill/transfer retention, completed-use case exactly once |
| Inventory full / source empty / filter changed | Constructor/UI state may precede server changes | Fresh capacity/access/native CanTransfer checks; no optimistic success |
| Room revision/safehouse access changes | Geometry/permission can change during travel/action | Invalidate work and permissions before completion; no scope name/coordinate fallback |
| Room/chunk/multifloor edge | Blood mutation footprint is not exact target-square geometry | Prove permission/scope for the full native footprint or block that candidate |

## Lua-only guard feasibility, not implementation

[VERIFIED source] Lua `serverStart`, `serverStop` and `complete` hooks are called
by the native engine. These are a possible bounded adapter seam. A client-side
instance override alone is insufficient: the server reconstructs the action
from its class/new and serialized constructor fields.

[INFERRED design] A server-loaded Lua guard around the native cleaning completion
could validate the bound actor, exact cleaner/tool, current native square,
reach/access, scope revision, overlapping footprint claim and once-only receipt,
then invoke the original native completion exactly once. That would retain
native fluid consumption and blood mutation. Server-owned start/stop claims
would need safe cleanup for failed construction, cancellation, disconnect/death
and stale completion. Measured fill/transfer actions need their own guards.
No new client-trusted cleaning command or direct removeBlood call is justified.

This seam is **SUPPORTED WITH ADAPTER as a research direction**, not a proven
safe authority model. Initialization/load ordering, avoiding interference with
normal vanilla actions, hook coverage and denial behavior need a focused design
and offline proof before gameplay. If guards cannot cover all actual mutation
paths safely through Lua, automated gameplay remains BLOCKED; do not substitute
Java or client authority. The current decision is to stop affected implementation.

## Configuration candidates for a later accepted feature

No Auto Clean sandbox options were added to this research. Any implementation
must specify stable localized IDs, defaults, bounds/steps and existing-save
behavior before coding. Server interpretation owns shared behavior.

Meaningful candidates: enabled/authorized-player policy, permitted cleanable
groups (blood/native grime initially), permitted water/agent sources, allowed
scope/range limits where user-facing, and solution preparation/refill policy.
The user supplied 10 mL bleach first then water as the POC recipe; if future
automation makes the dose or refill policy configurable, it belongs in server
sandbox configuration and must be native-valid. Never expose a setting that
permits an ineffective/unsafe mixture or disables required authority checks.

Native 0.24999 L consumption is engine behavior, not an Auto Clean tuning
setting. Protocol IDs, transaction finite-number checks, resource-claim safety
bounds, per-tick work budgets and UI coordinates are implementation details.
New saves/old saves must remain unchanged until a successful authorized feature
write; no new persistence schema or room library was created by this audit.
