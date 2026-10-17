# Auto Clean: fluid mixing and dose evidence

Dated research: 2026-10-14 America/Phoenix; observed project `0.7.0-dev.1`,
Build 42.21 installed source. [VERIFIED source] / [TESTED offline Lua doubles]
only. Real transfer, replication, cancellation and persistence are NOT TESTED.
Hash/method-offset inventory: [evidence JSON](AUTO_CLEAN_B42_21_EVIDENCE.json).

## Exact cleaning acceptance rule

`media/lua/shared/TimedActions/ISCleanBlood.lua:5–20` checks an inventory item
whose FluidContainer contains `Fluid.Bleach` OR `Fluid.CleaningLiquid`, and whose
**total** amount is at least `ZomboidGlobals.CleanBloodBleachAmount`.
`media/lua/shared/Defines.lua:47` sets that global to **0.24999 L**.

`FluidContainer.contains(Fluid):boolean` (descriptor
`(Lzombie/entity/components/fluids/Fluid;)Z`, offsets 0–41) scans fluid entries
for the same native Fluid object. It does not read amount, percentage, purity,
primary-fluid identity, fluid category, or a recipe token. Accordingly, a
retained bleach entry mixed with enough water qualifies; pure water does not.
The cleaning validator does not itself require the entry's quantity to be
positive. Normal transfer/add paths and empty-entry removal govern retention.

**No concentration threshold or minimum absolute bleach dose is present in
this cleaning validator.** The community 10 mL claim is not a proven chemical
minimum. The smallest reliably deliverable and durable dose for an arbitrary
workload is UNKNOWN. No minimum-dose formula or production constant is introduced.

User clarification: use **10 mL bleach first, then fill the remainder with water**.
Adopt that sequence as the primary POC input. For the defined 10 L bucket, the
nominal final contents are 0.01 L bleach + 9.99 L water, provided the actual
bucket starts empty and source/carry capacity permit a complete fill. This is
the user's requested test recipe, not an inferred chemical minimum or native
runtime result. No gameplay constant was implemented.

## Read and transfer interfaces

All methods below are `zombie.entity.components.fluids.FluidContainer` public
native methods unless otherwise stated. `LuaManager$Exposer.exposeAll` exposes
FluidContainer; this audit parses metadata/vanilla Lua usage, not a live Lua
bridge. It never adds a Java dependency.

| Signature | Contract / evidence |
|---|---|
| `getCapacity():float` / `getAmount():float` | Capacity and total litres; `getAmount` refreshes caches. A 10 L bucket is defined in generated items, not assumed from its name |
| `getSpecificFluidAmount(Fluid):float` | Fluid amount by identity; absent species yields zero, offsets 0–64 |
| `getRatioForFluid(Fluid):float` | Cached species percentage, offsets 0–44; call `getAmount` first to refresh caches |
| `getPrimaryFluid():Fluid`, `isMixture():boolean` | Useful description only; cleaning does not test primary type/purity |
| `CanTransfer(source,target):boolean` | Reject null/same container, full destination, empty source, locked/filter-incompatible destination and excessive distinct species. No actor/reach/room permission argument |
| `Transfer(source,target,amount):void` | 3-argument overload invokes 4-argument overload with `false`: conserve source through normal native transfer; never request the optional source-preserving mode |
| `canAddFluid(Fluid):boolean` | Checks container input/can-empty restrictions, distinct species bound, both fluids' blending filters, then container filters |
| `adjustAmount(float):void` | Clamps new total to 0..capacity; scales every species by new/old total and removes sufficiently small entries |
| `save(ByteBuffer)`, `load(ByteBuffer,int)` | Serializes species collection; delegates FluidInstance persistence. Native execution untested |
| `saveSyncData(ByteBuffer)`, `loadSyncData(ByteBuffer)` | Uses native save/load representation, not an Auto Clean protocol |

Direct `addFluid`, `adjustAmount`, or capacity mutation by an Auto Clean client
would bypass native transactions and is forbidden. The methods are inspected
to understand existing native actions only.

### Pairwise mixture permission

`media/scripts/generated/fluids.txt:3–38` defines Water and TaintedWater as
Beverage category; `:179–205` gives Bleach a Beverage blend whitelist.
`Fluid.canBlendWith(Fluid):boolean`, offsets 0–48, tests self identity then blend
filters. `FluidContainer.canAddFluid`, offsets 67–86, tests both directions.
The inspected water definitions have no opposing blend restriction: water +
bleach is permitted by this native source. TaintedWater is also a Beverage;
mixing it with bleach does not establish purification or safe drinking.

`CleaningLiquid` at :224–244 has an empty whitelist category block.
`FluidFilter.allows(Fluid)`, offsets 6–39 and 138–178, treats empty species and
category sets as wildcards, so an empty whitelist does not mean "nothing".
Its water blend is source-supported. Bleach + CleaningLiquid is a different
pair: Bleach restricts to Beverage and CleaningLiquid is Hazardous, so do not
combine agents merely because each separately cleans. Current container/native
`CanTransfer` is always the authority on whether a particular transfer fits.
Poison `minAmount` and `diluteRatio` fields are ingestion rules, not cleaning rules.

## Measured native action and precision

`media/lua/shared/Fluids/ISFluidTransferAction.lua:91`:

```lua
ISFluidTransferAction:new(character, sourceContainer, sourceFluidObject,
    targetContainer, targetFluidObject, amount)
```

The first/third container arguments are Lua `ISFluidContainer` wrappers. The
fluid-object arguments are retained for constructor-argument serialization;
the server reconstructs wrappers from the corresponding native FluidContainer
or ResourceFluid objects (:100–110). Do not serialize a made-up Lua container.
Owner and `sourceStartAmount` are captured server-side (:119–122). Duration is
`max(amount * 40,20)` action units, or 1 for instant actions (native `FluidUtil`
constants). `isValid` only checks UI-purpose wrappers + `CanTransfer` (:5–9).

`update`:24–31 transfers only when not a client. It targets sourceStartAmount
minus requested amount times progress. `complete`:70–77 transfers the remaining
difference and synchronizes both wrappers. `stop`:63–68 performs queue/sound
cleanup; no refund. In the inspected generic dedicated `NetTimedAction`, Lua
`update` is not called by its empty Java `update`; do not assume progressive
dedicated mixing from the SP Lua branch. Completion is still native. Test this.

`ISFluidTransferUI.lua:152` uses slider fraction steps of 0.01. At :358 and :363,
max transferable volume and selected volume pass through
`FluidUtil.roundTransfer(float):float`, which computes `Math.round(x*100)/100`.
Thus native UI transfer results use **0.01 L = 10 mL increments**; slider/source
amount may limit which increments are reachable. Its smallest nonzero output
is 10 mL, not proof of a minimum cleaning dose. 1 mL / 5 mL trials need a
separately validated native-action research harness; there is no permission to
write client fluid quantities to construct them. Pure-bleach control is needed.

The quantities cross native Java `float` boundaries. `removeFluidInstanceIfEmpty`
uses `PZMath.equal(amount,0,0.0001f)` (:0–11), and that comparison is strict
`abs(delta) < epsilon` (`PZMath.equal(FFF)Z`:0–22). `adjustAmount` invokes this
for all scaled species. The threshold is roughly **0.1 mL**, not 10 mL.
Adding to a destination and reading a cache do not always prune small entries;
transfer-out source cleanup and cleaning can. `recalculateCaches(ZZ)V`:290–311
also snaps displayed total to capacity if remaining capacity is below roughly
0.001 L. This cache snap does not add component mass. Exact mathematical
threshold values should not be used as robust recipe margins.

## Consumption and conservation

`ISCleanBlood.complete`:100–108 subtracts 0.24999 L of **total mixture**, not
0.24999 L of bleach. `FluidContainer.adjustAmount(F)V`:8–24 clamps/scales total;
:50–71 multiplies each species and prunes small remnants. Under ideal arithmetic,
each species decreases proportionally. Float rounding, cache capacity snapping
and small-entry removal mean tiny residual loss can exceed ideal proportional
usage. Record actual species amounts; do not claim mathematically exact native
mass conservation or recreate discarded traces to "fix" vanilla rounding.

`Transfer(FluidContainer,FluidContainer,float,boolean)V`:8–36 caps requested
volume to available source and free destination; :68–106 moves each species by
its percentage then subtracts it from source when the flag is false. This is
the source-grounded conservation mechanism, not an executed conservation test.
The path has no explicit nonnegative/finite request guard at its entry; future
server adapters must reject malformed quantities before native invocation.

The action's progress accounting assumes its source is not concurrently edited.
If another operation draws from or adds to the source, the difference from the
captured start amount changes. Do not use sourceStartAmount as a reservation or
receipt. Mixing/filling must serialize relevant physical resources and compare
authoritative before/after states. A stale cleaner may be consumed even when a
different inventory item made `isValid` pass. Never infer consumed quantity from
the number of client callbacks.

Expected ledger for a finite source trial:

- Water: source species loss versus bucket species gain, with any measured
  discarded water recorded separately.
- Bleach: original bottle loss versus bucket gain; no virtual/spawned fluid.
- Cleaning: bucket species loss and total loss after one server completion.
- Remaining fluid: compare exact species and total across server, A, B and
  post-reload state; quantify rounding/pruning separately rather than hide it.
- No duplicate resource restoration on cancellation, disconnect, death or retry.

Infinite mains/river source behavior is a native source model, not a finite
reservoir ledger. Use finite sources for the first conservation experiment.

## Water source and filling audit

`media/lua/shared/TimedActions/ISTakeWaterAction.lua:175`:
`new(character,item,waterObject,waterTaintedCL)`. Constructor takes the minimum
of available fluid, item free capacity and character carry capacity (:181–190).
There is **no requested partial-volume parameter**. `isValid`:5–7 checks an item
container, source `hasFluid`, and player not full; it does not verify exact
ownership, live source identity, safehouse access or reach.

`updateUse`:32–50 targets cumulative progress; `complete`:130–133 finishes it.
`transferFluid`:135–148 calls `waterObject:transferFluidTo(item:getFluidContainer(),
amount)`, item sync and stats. `serverStart`/`animEvent`:151–160 use native
`emulateAnimEvent` with server progress. Cancellation may leave valid partial
progress and must not refund it. `waterTaintedCL` is stored but is not a recipe
or purification instruction; actual source fluid type follows native transfer.

`IsoObject.transferFluidTo(FluidContainer,float):float` clamps input to
source/free capacity, handles external plumbing, finite component transfers,
reserve water, and native infinite water/puddles. Finite component transfer
calls native `transferTo` and `sync`; external sources may recurse and sync.
Its result is not a general permission grant. `getFluidAmount():float` can use
external/reserve or nominal infinite amounts; not every source is a fluid item.

| Source | Native support evidence | Remaining limitation |
|---|---|---|
| Sink / bathtub / fixed tap | Context `onTakeWater`:2050–2095; ISTakeWaterAction tap branch; IsoObject reserve/external/infinite source branches | Per-instance plumbing, available water, square access and finite/infinite accounting need native proof |
| Rain collector | Same action handles IsoThumpable; component/external fluid paths | Validate actual source object, taint and finite depletion; do not assume filtration |
| Other portable fluid container | ISFluidContainer wrapper + measured ISFluidTransferAction | Good first finite-volume trial; must already be in authorized actor inventory |
| World lake/river/water tile | IsoObject water-flag/infinite type branches; action source animation branches | Tainted-water and native infinite source behavior; distinct from finite collector |
| Puddle | solid-floor and `getPuddlesInGround() > 0.09` native branches | Weather state/source semantics and client/server agreement UNKNOWN |
| ResourceFluid virtual/entity source | Wrapper accepts ResourceFluid | `ISFluidContainer.sync`:105–106 prints "not implemented"; excluded from first POC |

Partial filling through a measured native transfer is supported as a primitive.
Cancelling a tap-fill action at an arbitrary animation percentage is not an exact
measured fill API. A full 10 L water bucket has no bleach headroom: transfer out
through a native permitted operation, record waste, or start with a measured
portable-water transfer. Never overfill or edit capacity.

For the user's clarified bleach-first recipe, use the native measured transfer
to put 0.01 L from the bleach bottle into the empty bucket, then use the native
fill action. Its fill-to-capacity constructor now supplies exactly the desired
remaining-capacity behavior in principle. Verify the measured bleach transfer
before queueing water fill; do not queue both optimistically from client state.

## Persistence and multiplayer limit

`FluidContainer.save/load` serializes the species collection;
`FluidInstance.save`:96–101 writes amount as float and native type identity;
`load`:130–135 restores float amount. SyncItemFields packet writes the complete
FluidContainer at :239–258, and its client path applies received fluid state.
`ISFluidContainer.sync`:96–107 deliberately returns on clients, uses IsoObject
sync or inventory item sync server-side, and leaves ResourceFluid unsupported.

These paths support a native persistence/replication hypothesis. They do not
prove actual two-client receipt, observer availability of another inventory,
restart conservation, or atomicity across blood and item saves. See the
[authority audit](AUTO_CLEAN_MULTIPLAYER_AUTHORITY.md) and
[native acceptance protocol](AUTO_CLEAN_POC_PLAN.md). All remain [RUNTIME GATE].
