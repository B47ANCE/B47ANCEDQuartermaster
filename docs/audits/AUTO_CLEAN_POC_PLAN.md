# Auto Clean: reproducible single-square proof of concept

Prepared 2026-10-14 America/Phoenix for observed Quartermaster `0.7.0-dev.1`
and installed Build 42.21. Actual native execution: **NOT TESTED**.
G7 BLOCKED / NOT TESTED; stable-release G8 BLOCKED.

## Milestone and boundaries

Prove one native cleaning operation and its actual resource changes. The user
clarified the primary recipe: **10 mL bleach in the bucket first, then fill the
remaining capacity with water**. Use that sequence; it is a specified test
input, not a minimum-dose claim. No Auto Clean runtime code, custom Mod ID,
custom room dependency or automatic retrieval is needed for the first run.

This document does not authorize game/server launch, changes to the installed
Java-agent configuration, deployment, publication, remote access or production
save use. Use a separately authorized pristine native Build 42.21 installation
and disposable save/server profile. Do not launch the currently observed
third-party Java-agent configuration as native/Lua-only proof.

Automated gameplay is blocked by the [authority findings](AUTO_CLEAN_MULTIPLAYER_AUTHORITY.md).
Manual native action observations can establish baseline mechanics. Before a
controlled automated POC, design/test the server Lua guard around actual native
hooks; do not queue unguarded action constructors as an automation substitute.
No production gameplay adapter is supplied in this handoff.

## Test fixture

One player, one isolated naturally blood-stained loaded square, one empty native
`Base.Bucket` (inspect actual 10 L capacity), one nonbroken native clean-stains
tool (e.g. `Base.Sponge` or `Base.Mop`), one native `Base.Bleach` bottle with
sufficient measured fluid, and one water source. Start with a **finite** source
whose native amount/type can be observed, e.g. an eligible native collector.
Repeat taps/plumbing and infinite sources separately. Move supplies manually
using native inventory transfer before this fixture; do not mutate item lists.

Keep cleaner/tool in the actor's main inventory for the baseline. A two-handed
mop can occupy both hands while the cleaner stays in inventory. No second
cleaning tool or separate broom is needed. Choose a fixture away from room,
chunk, safehouse and floor-boundary ambiguity, with no other stained candidate
in the native footprint. Record and inspect surrounding XY ±1 tiles and stacked
floors because native blood removal is not limited to one exact tile.

Use consistent blood decal settings above zero and record them on both clients.
Do not generate a blood target by calling remove/add methods from Auto Clean;
prepare a disposable native test scenario. Grime, graffiti, ashes, bandages and
vehicles require separate fixtures, not an expanded first milestone.

## Required observation record

Record exact game build, source/effective-class hashes, enabled mods, test save
ID (no private player data), tested source version and commit plus dirty-source
hash inventory, actor identity, native item IDs/FullTypes, source identity,
square/chunk coordinates and floor. Use only separately authorized native debug
inspection or a reviewed read-only Lua observer. A client animation or floating
fluid label cannot substitute for server values.

For each physical fluid container, refresh total using `getAmount()`, read
`getCapacity()`, `getSpecificFluidAmount(Fluid.Bleach)`, Water, TaintedWater,
CleaningLiquid as applicable, and `getRatioForFluid(Fluid.Bleach)`. Save values
with enough digits to expose native float changes. Do not call hypothetical
`getFluids()` or infer exact quantities from the primary fluid label.

Record blood `haveBlood`, floor/wall helpers, `haveStains`, native grime queries,
actual before/after source quantities, server action outcome and subsequent
observed state. Another player's inventory may not be replicated to observer B;
if unavailable, mark it unavailable and use server data plus controlled native
handoff of the same bucket after the operation. Do not invent observer values.

Suggested evidence row (one per checkpoint; empty initially):

| Trial / side | Square and stains | Bucket ID / capacity / total / species | Bleach bottle ID / species | Water source ID / amount / kind | Action outcome / error |
|---|---|---|---|---|---|
| Baseline | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |

Record a monotonic trial/checkpoint identifier and retain actual logs privately;
never commit raw player/server logs or credentials.

## Primary sequence: bleach first, then water

1. On the server/authoritative test environment, confirm a loaded target has
   native blood and no unrelated work in its native footprint. Record the empty
   bucket capacity and all initial source/bottle/bucket quantities.
2. Use the native fluid-transfer UI to transfer **0.01 L (10 mL)** from the
   bleach bottle to the empty bucket. This corresponds to the UI's native 0.01 L
   rounding grid when the selected source/slider permits it. Native action:
   `ISFluidTransferAction:new(character,sourceWrapper,sourceFluidObject,
   targetWrapper,targetFluidObject,amount)`. This signature is explanatory;
   use normal native UI for the manual baseline.
3. Wait for authoritative completion/state. Verify original bottle loss and
   bucket bleach gain, rather than the requested amount or client queue status.
   Stop this trial if actual transfer is not 0.01 L within demonstrated native
   float representation. Do not make corrective direct fluid writes.
4. Fill the remaining bucket capacity through the native source action.
   `ISTakeWaterAction:new(character,item,waterObject,waterTaintedCL)` computes
   free capacity and source/carry availability; it has no requested amount
   parameter. For a 10 L bucket with 0.01 L bleach, the nominal headroom is
   9.99 L. Sufficient carry capacity and source volume are required. A native
   portable-source fluid transfer is an alternate finite-source control.
5. Wait for server completion, then read actual bucket total/species and source
   loss. Confirm bleach remains present; check native `CanTransfer` and cleaning
   eligibility. Tainted source remains tainted mixture; no purification claim.
6. Use the normal native Clean Blood UI/cursor against exactly the selected
   valid square. It walks, transfers/equips as needed and queues `ISCleanBlood`.
   For a future guarded harness, send only intent through a verified path; never
   call `complete`, `removeBlood`, `removeGrime`, `addFluid`, or `adjustAmount`
   from a client test command.
7. Wait for server native completion and read resulting authoritative state.
   Observe client queue completion separately. Verify target/neighbor/stacked
   floor effects and native blood/grime agreement.
8. Read actual bucket total and species, bottle and finite source again.
   Expected source contract is 0.24999 L total cleaning use with proportional
   species reduction, subject to demonstrated native float/pruning/cache
   behavior. Report every discrepancy; do not round it away or refund it.
9. Save, unload/reload the disposable save, then inspect the same bucket/source
   and world target. Compare actual type/amount/stains, not regenerated objects.
10. Return reusable items manually through native transfer and confirm exact
    storage/content identity. Automatic original-storage return remains a later
    Quartermaster adapter dependency, not a successful POC claim.

If no valid source has enough volume or carry headroom, report incomplete fill;
do not call that a full-bucket recipe success. The recipe can still be evaluated
as a distinct partial-fill trial if recorded as such. No current native run is
claimed in this document.

## Dose controls and precision experiments

The primary run uses the user's 10 mL recipe. Independent controls may test
water only, 1 / 5 / 10 / 25 mL bleach and pure bleach, each with exact measured
final volume and fresh comparable stain fixture. Water only is expected to
fail the native fluid-membership validator. The Lua-double candidate test does
not create these mixtures or prove them in the game.

1 mL, 5 mL and 25 mL are not exactly selectable as outputs on the UI's 10 mL
grid. A separately reviewed native-action harness would need to demonstrate
requested-to-actual transfer, actor/source validation and native float behavior
first. If unavailable, mark those trials NOT EXECUTABLE WITH THIS UI; do not use
direct native mutation to fabricate them. 10 mL is neither a coded minimum nor
proof that every tiny positive value survives all native operations.

For repeated cleaning, recheck actual fluid membership and >=0.24999 L total
before every target; do not preauthorize a fixed number from nominal capacity.
Test near the last eligible action and around the 0.0001 L species cleanup
boundary in a separate precision fixture. Report native trace losses. Strict
zero-loss behavior for all trace inputs is not established by the native code.

## Cancellation and stale-state trials

Use fresh/disposable fixtures and repeat at before-start, partial-progress,
near-completion and after-completion checkpoints. For fill and transfer,
partial progress can remain; there is no automatic rollback contract.

Test: cancel fill, cancel mixing, cancel cleaning; remove/transfer bucket;
change mixture; empty/remove water source; break/move tool; clean target using
another action; move player out of reach; revoke safehouse access; revise/delete
scope; unload target; fill inventory; disconnect; die; restart server.
The server must not consume twice, restore uncertain fluid, create supplies or
retry a stale mutation. Current native deficiencies are reported as baseline
observations; their existence does not permit an unsafe automated implementation.

## Dedicated two-client proof

Only after separate test-server launch/setup authorization:

1. Record exact dedicated server/A/B builds and enabled Lua-only mod sets. Keep
   production saves/server untouched. Establish a remote A and independent B.
2. Repeat the primary bleach-first single-square sequence with server snapshots
   at every checkpoint. A initiates; B observes blood/grime and relevant item
   state where natively available. Compare source/bucket values to server data.
3. Repeat with two actors contesting target/footprint, bucket transfer ownership,
   bleach source and finite water source. Neither actor may acquire permission
   by sharing a client reference or copying a request. Test full matrix in the
   [authority audit](AUTO_CLEAN_MULTIPLAYER_AUTHORITY.md#concurrency-and-failure-test-matrix).
4. Check reconnect, late join after chunk unload/reload, server save/restart,
   cancelled/native-Done races, and stale handles. Observe actual packet state
   and native outcomes; do not equate two client animations to server agreement.
5. Fail acceptance on unauthorized mutation, duplicate use, unexplained resource
   gain/loss, stale-source use, cross-boundary cleaning, or missing authoritative
   completion. Preserve logs and describe exact limitation rather than suppress it.

Pass criteria bind version/commit/source hashes to actual environment and each
successful scenario. Source and SP tests cannot mark dedicated G7 PASS. This
plan has **zero executed native trials** and supplies no stable G8 approval.

## Offline validation

From repository root, in PowerShell:

```powershell
$py = 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$gameRoot = 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'
& 'C:\Users\willi\.codex\b47anced-team\tools\Test-PZRepositoryFreshness.ps1' -Repository 'C:\Users\willi\Desktop\Work\Project Zomboid\Mod Repositories\B47ANCEDQuartermaster'
& $py scripts/check_versions.py --root .
& $py tests/audit_auto_clean_native.py --game $gameRoot --verify-evidence docs/audits/AUTO_CLEAN_B42_21_EVIDENCE.json
& $py tests/run_tests.py
& $py scripts/check_versions.py --root .
```

Executed results:

| Command / check | Result and limitation |
|---|---|
| Freshness helper | REVIEW / exit 1: dirty baseline; upstream ahead 0/behind 0; remote-default ahead 10/behind 0; no unfinished operation |
| `check_versions.py --root .` before/after | FAIL / exit 1: current ZIP and embedded mod.info still `0.6.0-dev.3` versus source `0.7.0-dev.1`; existing issue preserved |
| Audit with `--write-evidence docs/audits/AUTO_CLEAN_B42_21_EVIDENCE.json` | PASS / exit 0: 26 source/bytecode/Lua-double tests; writes hashed research inventory only |
| Audit with `--verify-evidence` | PASS / exit 0: same 26 tests plus hashed source/class/HEAD inventory comparison |
| `tests/run_tests.py` | PASS / exit 0: existing offline regression suite; fixtures include room sweep; no native server. Final regression run had zero source/test-file drift during execution |
| Pre-existing work preservation | Changes detected against the 102-file initial inventory during this session; this audit wrote only its six new files and did not restore/overwrite the evolving pre-existing work |
| Deployment / packaging / publication | Not performed; `--release` not run because packaging not requested and known stale artifact remains |
| G6 native POC / G7 / stable G8 | Native POC NOT TESTED; dedicated G7 BLOCKED / NOT TESTED; stable G8 BLOCKED |

The test is standalone and deliberately not registered by editing the ongoing
project runner. It reads source and class data, executes native cleaning Lua
callbacks with test doubles, and never starts Java/PZ/server. It requires the
existing `.test-deps` jawa and Lupa libraries. Evidence generation is explicit;
normal verification writes no research output. Expected evidence drift stops
verification; re-audit instead of relabelling old proof.

The stable full-regression run's sorted source/test hash-map digest was
`c8c122082b8395db99501aab9695a14d7b032248d390d50aa242b8d613777aaf`
(SHA-256 of compact sorted-key JSON). The standalone audit test was subsequently
corrected to reflect native nested-tool recursion and rerun separately; the
production source was not edited by this audit. Private full-run output and
before/after hashes remain in the temporary audit session directory, not in
public source or claimed native evidence.

### Required offline coverage map

| Requested check | Coverage / limit |
|---|---|
| Constructor signatures | Tests 01, 19, 23; actual Lua constructor + source parameters |
| Cleaning target/tool/fluid validation | Tests 02–08; source validator with explicit inventory doubles; target-validation absence reproduced |
| Bucket capacity / composition / dose | Tests 03–05, 14, 20, 25; native signatures, definitions, membership/filter contracts; no actual native mixture created |
| User's bleach-first sequence | Test 26 executes actual native fill constructor with doubles: 0.01 L in a 10 L bucket leaves 9.99 L requested headroom; no filling executed |
| Conservation / consumption / completion | Tests 10, 14–18; actual Lua callback to mocks + native cap/proportion/serialization references; native float transfer NOT executed |
| Cancellation | Test 11 clean stop callback; fill/mix/restart/network cancellation left native gate |
| Duplicate target rejection | Test 12 reproduces lack of completion idempotency; NOT a duplicate-safety PASS |
| Stale cleaner / nil cleaner | Tests 09, 13 reproduce unsafe saved-reference behavior |
| Stale water source | Test 19 records absent existence/permission guard; no live source disappearance simulated |
| Server validation / world sync | Tests 17–18, 23–24 trace server callback, packet paths, headless risk and Lua exposure; no packets executed |
| Quartermaster handles / room geometry | Test 21 source interface checks; existing regression runner covers actual owned Lua room/handle fixtures |
| Equipment return | Test 21 proves forced destination is rejected; automatic original-storage return remains an adapter gap |
| No direct inventory mutation | Test 22 checks owned movement/executor + storage restrictions; no new runtime code added |

## Next development milestone

First obtain the authorized clean native fixture evidence for the user's 10 mL
bleach-first recipe and one cleaning completion. In parallel planning terms,
specify the smallest server Lua guard and neutral Quartermaster borrowing/return
contract without implementing a room sweep. Gameplay implementation waits for a
safe reviewed authority model. Room-wide scheduling waits for successful native
and dedicated single-square proof plus stable server room API acceptance.
