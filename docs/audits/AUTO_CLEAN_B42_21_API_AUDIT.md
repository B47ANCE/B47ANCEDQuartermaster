# Auto Clean: installed Build 42.21 API audit

Audit date: 2026-10-14, America/Phoenix. Observed Quartermaster working-tree
version: `0.7.0-dev.1`. This is a dated research record, not a current version
mirror, a release, or evidence that the unfinished room feature works in PZ.

## Decision

[VERIFIED source] The installed native blood action accepts a container that
**contains a Bleach or CleaningLiquid fluid entry and holds at least 0.24999 L
total fluid**, plus a nonbroken `CLEAN_STAINS` tool. It does not test bleach
concentration or a minimum absolute bleach dose. Bleach and water can blend under
the inspected native filters. Native completion removes 0.24999 L of the mixture,
then blood and native grime. This is not a custom cleaning recipe.

User clarification during this audit: **put 10 mL bleach in the bucket, then fill
the rest with water**. This is the primary requested native POC sequence. It
avoids the full-water-bucket headroom problem and is distinct from a proven
minimum-dose claim; actual execution is still NOT TESTED in this session.

[VERIFIED source] A remote native timed action has a server completion path and
world/item synchronization mechanisms. **It does not establish the requested
safe authority contract.** The inspected action/completion chain lacks current
target, exact cleaner ownership/content, reach, permission, and duplicate-work
validation. See [authority findings](AUTO_CLEAN_MULTIPLAYER_AUTHORITY.md).

Full automation and a gameplay adapter are BLOCKED pending those boundaries.
The appropriate deliverable now is the executable offline audit and the
[single-square native POC plan](AUTO_CLEAN_POC_PLAN.md). No runtime mod, Mod ID,
room system, direct blood removal, or custom fluid mutation was added.

## Baseline and provenance

| Property | Observation |
|---|---|
| Repository | `C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDQuartermaster` |
| Authoritative runtime source | `src/B47ANCEDQuartermaster/42` |
| Canonical version | `VERSION`: `0.7.0-dev.1`; existing compatible MINOR custom-room development from `0.6.0-dev.3` |
| Identity | `B47ANCEDQuartermaster`; Workshop `3807217050`; proposed Auto Clean ID remains unapproved |
| Branch / HEAD | `feature/custom-rooms`; `674ad3809701c772d7e6ee2bb4670d8b4a4aae58` |
| Origin | `https://github.com/B47ANCE/B47ANCEDQuartermaster.git` |
| Upstream | `origin/fix/transfer-throughput`, same SHA; ahead 0 / behind 0 after fetch |
| Remote default ref reported by helper | `refs/remotes/origin/fix/native-transfer-diagnostics`; HEAD ahead 10 / behind 0 |
| Freshness | REVIEW: 90 modified and 12 untracked pre-existing files; no unfinished Git operation; branch/upstream naming mismatch retained |
| Change boundary | Six new research/test files only; no version iteration or production change; no commit/push performed |
| Installed game | `E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid` |
| Version evidence | JAR `zombie/core/Core.<clinit>()V`, offsets 0–14: `GameVersion(42,21,"")`. Build 42.21 confirmed; project names target 42.21.0. No native process queried |
| Full JAR SHA-256 | `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33` |
| Effective FluidContainer class SHA-256 | `747f8527f9320669a9685ca4af6a578456a1db8f8b1e0a76a8f892b1ea9d4e1b` |
| Effective NetTimedAction class SHA-256 | `d4a3046eeaec409977a756c6ea80b0676229274684012ad51210559ebfcb1090` |

The complete hashed Lua/script/project inventory, JAR and effective class hashes,
public method descriptors, normalized method hashes, and referenced bytecode
offsets are in [AUTO_CLEAN_B42_21_EVIDENCE.json](AUTO_CLEAN_B42_21_EVIDENCE.json).
Hash verification is implemented by `tests/audit_auto_clean_native.py`.
All paths in the source tables below are relative to the installed game root;
all Java references denote inspected vanilla interfaces, never mod dependencies.

Concurrent-edit caveat: an initial preservation hash inventory covered 102
pre-existing changed files. Later comparison detected changes in existing room,
movement, UI, localization and test files during this session. This audit's
writes were confined to its six new files; those other changes were neither
restored nor overwritten. Do not claim the whole worktree was unchanged.
Quartermaster findings are bound to the project-file hashes in the evidence
manifest and the inspected function names; line numbers can drift during the
ongoing room work. Reverify before implementation.

### Modified installation boundary

[VERIFIED installed files] The launcher classpath starts with `.` before the
JAR. Loose `zombie/iso/IsoGridSquare.class` and `zombie/iso/IsoObject.class`
differ from the JAR; their hashes are respectively
`33ddcf7237852e79a622eb45a23eb98aa0def5f3124323788ca213d7da212fb9` and
`6439e28d85acc04beb02c98361d71e755a5814d5c3e32cdf693c801e681ffe98`.
The audit parses the loose classes first and records both copies. The
`removeBlood` operation and dispatch match after resolving class-pool indexes;
fluid amount/availability instruction sequences differ. These observations do
not certify the installation as pristine vanilla.

`ProjectZomboid64.json` references a third-party NPCFW Java agent/JAR associated
with Workshop `3738362476`; PZ optimization files are also present. Author,
exact installed third-party version, license, and patch provenance are UNKNOWN
in this narrow audit. No third-party mod source, assets, implementation, or
diagnostic logs were imported or changed; only installed interface/provenance
observations were retained. Clean-room review: no reuse; independent Lua-only
design required. Reviewer signoff for any future compatibility PR remains
pending. A clean, separately authorized test installation is required before
attributing runtime results to native Build 42.21. Do not repair this installation
or launch its agent as part of this audit.

## Native cleaning call chain

| Reference | Exact function / source | Side, preconditions, mutation and failure |
|---|---|---|
| C1 | `media/lua/server/BuildingObjects/ISCleanBloodCursor.lua:3–10`: `create(x,y,z,north,sprite)`, `isValid(square)` | Cursor resolves loaded native square and calls context helpers. Folder name does not make this a server permission gate |
| C2 | `media/lua/client/ISUI/ISWorldObjectContextMenu.lua:2408–2450`: `canCleanBlood(playerObj,square)`, `doCleanBlood(playerObj,square)` | Client stain/tool/fluid check, `luautils.walkAdj`, native inventory transfer/equip, queues native action. No authoritative result |
| C3 | `media/lua/shared/TimedActions/ISCleanBlood.lua:118`: `new(character,square,cleaner)` | Stores square/cleaner references; `getDuration()` at 111 returns 150, or 1 for instant actions; base adjusts mood/pain timing |
| C4 | Same file:5–20, `isValid()` | Inventory-wide recursive acceptable-fluid search; tool check uses `containsTagEval`. Native ItemContainer routes that through `getFirstTagEval` to `getFirstRecurse`, so it also searches nested inventories despite its name. Requires nonbroken tool; does not validate saved square/cleaner |
| C5 | Same file:23–85, `waitToStart`, `update`, `start` | Face target; wall/floor animation based on stain helpers and held tool. Two-hand and toilet-brush animation branches; no resource mutation here |
| C6 | Same file:88–98, `stop()`, `perform()` | Sound and base queue cleanup. Client queue completion is not world completion; no fluid use in these callbacks |
| C7 | Same file:100–108, `complete()` | Saved cleaner total reduced by native global via `adjustAmount`; `syncItemFields`; `square:removeBlood(false,false)` and `removeGrime`; returns true. Nil cleaner skips consumption. No revalidation or rollback |
| C8 | `media/lua/shared/Defines.lua:47` | `ZomboidGlobals.CleanBloodBleachAmount = 0.24999` |

Native `LuaTimedActionNew.complete()V` checks `GameClient.client` at offsets
31–34 before local Lua completion; dedicated completion is
`NetTimedAction.perform()Z`, offsets 0–27, calling Lua `complete`. Server
`ActionManager.update()V`, offsets 0–86, completes accepted actions after their
deadline. This establishes execution side, not application validation.

### World identity, detection and synchronization

| Capability | Native reference and behavior | Limit |
|---|---|---|
| Stain eligibility | `IsoGridSquare.haveStains()Z`: offsets 0–11 call `haveBlood`, `haveGrime` | Native aggregate stain signal; not a dirt taxonomy |
| Floor / wall blood | `haveBlood()Z`, `haveBloodFloor()Z`, `haveBloodWall()Z`; action `start`:47–50 | Blood decal option zero makes blood checks return false. Loaded square/chunk data required |
| Blood removal | `removeBlood(ZZ)V`: wall list clear 0–45; floor queue traversal 52–186; server packet 189–227 | Native action footprint is broader than an exact floor tile: same-chunk splat XY within ±1. Inspected floor loop lacks an explicit splat Z filter. Adjacent, stacked-floor and chunk-edge tests required |
| Grime | `haveGrime()Z` scans attached sprites for `overlay_grime`; floor/wall helpers available | Native overlay grime only; does not establish cleaning of arbitrary dirt, mud, trash, or custom effects |
| Grime removal | `removeGrime()V`: removes matching attached animations, `transmitUpdatedSpriteToClients` at 136 | Rendering/network and save acceptance still required |
| Graffiti | `haveGraffiti()Z`, `getGraffitiObject():IsoObject`; overlay names include graffiti/messages and native sign pattern | Separate `ISCleanGraffiti:new(character,square,cleaner)`, petrol + clean-stains tool; consumption global is separate; not bleach cleaning |
| Ashes | `ISClearAshes:new(character,ashes)`; context menu `onClearAshes`:1626–1630 uses nonbroken `CLEAR_ASHES` item | Exact native ash object, e.g. vanilla test uses `floors_burnt_01_1`; action transmits removal then removes object. No fluid. No general burn/dirt detector established |
| Bandages | `ISCleanBandage:new(character,item,waterObject,recipe)` | Inventory recipe action replacing an item and using source fluid. Not a world stain action; exclude from first module |
| Vehicle blood | `ISWashVehicle` water predicate:5–7, `hasBlood`, `getWaterAmountForArea`, `updateWashing` | Vehicle area/intensity and water-specific process; separate capability, not room cleaning |

`removeBlood(false,false)` sends native `RemoveBlood` to relevant clients on the
server. `RemoveBloodPacket.processClient(UdpConnection)V`, offsets 0–12,
resolves square and calls `removeBlood(true,onlyWall)`. Persisted blood/grime
after save/reload, neighboring chunks, and late join remain [RUNTIME GATE].
Do not call these mutation methods directly from Auto Clean.

## Equipment inventory

[VERIFIED script + action] FullTypes below use the files' `module Base`.
Native tag names are case-normalized script IDs such as `base:cleanstains`,
mapped to `ItemTag.CLEAN_STAINS`. These are definitions, not effective-load-order
runtime proof. Sources: `media/scripts/generated/items/normal.txt` (N),
`drainable.txt` (D), `weapon.txt` (W); approximate item start lines are listed.

| FullType (file:line) | Relevant properties | Blood-cleaning role / restrictions |
|---|---|---|
| `Base.Bucket` N:13888 | Normal; 10 L FluidContainer; bucket/metalbucket/cookable/hasmetal; transfer rate 5 | Solution holder, not cleaning tool. Check capacity/current filters; leave headroom |
| `Base.BucketEmpty` N:13248 | Normal; 10 L FluidContainer; bucket/metalbucket/cookable/hasmetal | Another defined bucket holder; do not infer an old drainable-water item |
| `Base.BucketWood` N:13914; `BucketCarved` N:13939; `BucketForged` N:13965 | Each 10 L FluidContainer; different weight/tags/models | Holder candidates; no `CLEAN_STAINS` role inferred |
| `Base.Bleach` N:3546 | Normal; 1 L FluidContainer, initial Bleach; cookablemicrowave | Consumed fluid source; bottle itself reusable; exact remaining contents determine suitability |
| `Base.CleaningLiquid2` N:3572 | Normal; 0.5 L FluidContainer, initial CleaningLiquid | Supported alternative. `Base.CleaningLiquid` was not found as an item in the searched generated definitions |
| `Base.Mop` W:8760 | Weapon; cleanstains; two-handed; ConditionMax 3, ConditionLowerChanceOneIn 2 | Suitable nonbroken tool. Cleaning action has no condition decrease or tool-use call |
| `Base.Broom` W:7212; `Broom_Twig` W:7258 | Weapon; cleanstains + clearashes; two-handed; same condition fields | Blood tool and ash capability. Do not fetch one in addition to an already suitable blood tool |
| `Base.DishCloth` D:2203; `BathTowel` D:2187 | Drainable; cleanstains; UseDelta 0.1; depletion replaces Wet variant | Accepted nonbroken tools. Blood action does not call `Use`, so these drainable fields are not blood-action consumption |
| `Base.Sponge` N:3597 | Normal; cleanstains; 0.1 weight | Suitable single tool; no cleaning wear/consumption call found |
| `Base.ToiletBrush` N:9082 | Normal; cleanstains + toiletbrush | Suitable nonbroken tool; native animation branch |
| `Base.DishClothWet` N:10390; `BathTowelWet` N:10358 | Normal; no cleanstains tag in inspected definitions | Not accepted merely because dry variants work |
| `Base.RippedSheets` N:10656; `RippedSheetsDirty` N:10683 | Binding and bandage-related tags; no cleanstains | Not blood-cleaning tools. Generic `Base.Rag` not found in searched item declarations |

Fluid holder quantity is consumed; reusable equipment does not require an extra
broom or a tool per target. For the simplest fixture, place the nonbroken tool
in the main inventory; the verified tool query also searches bags.
Context transfer/equip behavior still needs native acceptance. Do not mutate
item condition to make a tool qualify.

## Quartermaster integration audit

Paths here are under `src/B47ANCEDQuartermaster/42/media/lua`.

| Interface | Source-grounded status | Integration constraint |
|---|---|---|
| Custom room geometry | `shared/B47ANCEDQuartermaster/RoomGeometry.lua:13–41`: `normalize(rows,limit)`, `contains(g,x,y,z)`; normalized rows, tile set/list, bounds | Present in uncommitted work. Stable room ID + revision, never room name |
| Server room service | `Rooms.lua`: `resolve(player,id,revision)` at 66, `contains` at 77, `metadata`, `discover` at 100; `handle`, `tick` at 227 in the later inspected snapshot | Permission/revision/proximity and server ModData library; cooperative discovery. Unfinished feature, no dedicated acceptance |
| Edited vanilla rooms | `RoomDetection.lua` proposes geometry; `RoomEditor`/`RoomDraft` are client authoring; server stores logical geometry | No engine room replacement or supported universal vanilla override API established |
| Building/safehouse | `Targets.discoverAt`:90 onward reads native building room bounds; `Rooms` safehouse membership/access checks | Building discovery exists; arbitrary whole-safehouse cleaning scope/API not established. Geometry does not grant access |
| Physical handles | `Bindings.session`:23, `target`:40, `discover`:60 retain session records, exact references and revisions | Re-resolve/revalidate; coordinates are not capability grants |
| Storage-only discovery | `Targets.valid`:20 rejects floor and containing-item containers; checks object identity, lock, safehouse | Use these physical records; do not opt into later GroundSources code, floor piles, dropped bags, decorations or player inventories |
| Native retrieval | `Movement.withdraw`:76 validates item/carrier/access; `Shopping.handle`:14 plans exact instances; `Executor` native transfer/walk | Shopping mutates personal shopping progress; not a neutral supply borrowing API. Use a bounded adapter, preserve Shopping/Dibs ownership |
| Reservations | Existing per-player runs/operations and social Dibs state | No general cross-player bucket, bleach, source-volume or clean-target reservation service found in these interfaces |
| Equipment return | `Movement.planOne`:90 selects destination through sorting rules; rejects client destination/config | Original-storage return is not supplied by this API. Needs server-retained origin record + revalidated native transfer adapter; never force preferred coordinates |
| Routes | `Route.estimate`, `tripEstimate`, `order`; `Executor` calls native `ISWalkToTimedAction` | Advisory loaded-cardinal approximation, not native hypothetical path result. Do not reuse offers as cleaning grants |
| Cancellation/progress | `tripCancel`, `shoppingCancel`, movement phases and observed carrier/destination confirmation | No authoritative clean/fluid operation receipt exists yet |
| Optional expansion API | Global namespace modules and explicit `Protocol` command families exist | No registered Auto Clean extension family/package or public stable expansion API found in the inspected surface. Do not invent Mod ID or optional dependency |

Current `Protocol.lua:2` has movement **7**, rooms **1**, configuration **4**;
`Schema.lua:3` retains configuration schema **2**, root `B47ANCEDQuartermaster`.
The handoff's frozen taxonomy references are historical: current native-only
category architecture retires the owned taxonomy. Nothing in this audit changes
those contracts, the 5,092-entry historical evidence, presets, UI, sorting,
localization, Shopping or Dibs. `CUSTOM_ROOMS.md` still describes some work in
future tense; source shows actual implementations, but not completed acceptance.

### Performance assessment

[VERIFIED source] `RoomGeometry` limits normalization to 4,096 tiles / 512 rows /
128 extent; sandbox room tile default is 1,024. `Rooms.tick` cooperatively scans
up to four jobs, with 32 inner steps and a shared time deadline, revalidating
room revisions. `Route.order` bounds the shared search budget to 512 and examines
at most eight primary stops; it reports `pathRequests=0` and uncertain estimates.

Native `haveBlood` scans a chunk splat queue plus square objects; `haveGrime`
scans attached overlays. Calling either for every room square every frame is not
acceptable. Future candidate discovery should incrementally walk the validated
room tile list, cache only candidates, and recheck current state before grants
and completion. Cache membership never proves current stain or access.
`Targets.discoverAt` building enumeration and `ShoppingNext` inventory planning
are synchronous loops; they are not yet proof of bounded whole-building cleaning
responsiveness. Native pathing must occur only for the actual queued walk.

## Capability decisions

SUPPORTED below means the named primitive is verified in source with the
appropriate read-only/local role, not native execution. Shared-state mutation
requires a safe authority boundary; known gaps receive BLOCKED even where native
code exists. ADAPTER means a bounded integration is identifiable, not implemented
or MP certified.

| Capability | Classification | Reason / next gate |
|---|---|---|
| Native blood cleaning end to end | BLOCKED | Native server mutation exists; exact state/permissions/duplicate validation missing |
| Blood detection | SUPPORTED | Read-only native stain/floor/wall queries; decal option, chunk footprint and load constraints |
| Tool validation | SUPPORTED WITH ADAPTER | Native recursive tags/broken check; enforce exact current actor-owned tool and native equip/transfer requirements server-side |
| Bucket filling | SUPPORTED WITH ADAPTER | Native source transfer and action exist; measured partial/source ownership and access need guards |
| Bleach mixing | SUPPORTED WITH ADAPTER | Native bilateral fluid filters and measured transfer; server actor/source/amount validation missing |
| Cleaning Liquid alternatives | SUPPORTED WITH ADAPTER | Native accepted species; inspect pairwise blending, never replace with a guessed recipe |
| Universal minimum-dose calculation | UNKNOWN | No cleaning concentration threshold; retention/UI/float constraints and workload differ |
| Fluid consumption | SUPPORTED WITH ADAPTER | Native proportional total decrement; exact cleaner and once-only completion needed |
| Refill automation | BLOCKED | No accepted clean/fluid operation lifecycle yet |
| Supply retrieval | SUPPORTED WITH ADAPTER | Verified physical handle/native transfer pipeline; neutral borrowing and reservation adapter needed |
| Equipment return | SUPPORTED WITH ADAPTER | Native transfer usable after a server-origin adapter; current sorter cannot promise original storage |
| Custom room scope | SUPPORTED WITH ADAPTER | Uncommitted server-owned implementation exists; stable accepted API/runtime gates pending |
| Building/safehouse scope | SUPPORTED WITH ADAPTER | Building primitive and native safehouse access exist; bounded safehouse scope resolver not established |
| Native pathing | SUPPORTED WITH ADAPTER | Actual native walk exists; route estimate remains advisory |
| Dedicated synchronization | UNKNOWN | Packet/save paths verified; dedicated result/reconnect/observer agreement not tested |
| Two-client concurrency | BLOCKED | No clean-target/shared-fluid reservation and completion safeguards |
| Cancellation | SUPPORTED WITH ADAPTER | Native clean stop is mutation-free; fill/transfer partial progress and races require reconciliation |
| Persistence | UNKNOWN | Native fluid serialization exists; exact world/mixture restart acceptance not executed |

Arbitrary dirt accumulation, trash sweeping, and unsupported stains would be
CUSTOM GAMEPLAY REQUIRED and are outside this task. No such behavior was added.

## Validation and unresolved gates

See [POC validation commands and coverage](AUTO_CLEAN_POC_PLAN.md#offline-validation).
[TESTED offline] 26 new source/Lua-double tests PASS; existing `tests/run_tests.py`
PASS, including room sweep fixtures. These results do not execute the Java
engine, packets, pathfinder, real fluid serialization or world saves.

`scripts/check_versions.py --root .` FAILS before/after this research because
`dist/current/B47ANCEDQuartermaster-0.6.0-dev.3.zip` and its `mod.info` are stale
relative to `0.7.0-dev.1`. Source mirrors agree. No packaging, artifact relocation,
cleanup, deployment, Steam restart, publication, game/server launch or remote
server access occurred. G6 native POC NOT TESTED; G7 BLOCKED / NOT TESTED;
stable-release G8 BLOCKED. Audit files are local and uncommitted, not a GitHub
backup. Do not commit unrelated ongoing room work as part of this audit.

The next safe milestone is a clean-install, native-only, single-square measured
transfer/cleaning observation run in a disposable save after launch authorization.
Before any automated gameplay, prove a server-only guard around the native
completion hooks; then obtain dedicated two-client conservation/cancellation
evidence. Room-wide design waits for that proof and the room API acceptance.
