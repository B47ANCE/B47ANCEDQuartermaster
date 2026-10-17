# Dangerous Load and Supply Ledger

Project Version: 0.13.0-dev.1

## Scope and completion status

Development and offline testing only. No local/live deployment, Workshop change, game/server launch or modification of another mod. Lua-only runtime. No source or assets copied from third-party mods.

| Workstream | Implemented in this iteration | Still unavailable |
| --- | --- | --- |
| Dangerous Load | Server-owned personal preference, shared capacity policy, Sort/Collect integration, settings dialog, localization and offline regressions | Native SP/dedicated acceptance, measured heavy-load route calibration |
| Shared content analysis | Unwired read-only bounded analyser in runtime source | Native ledger inspection binding, confirmed-change revision boundary, cross-job cache |
| Building Supply Ledger | Isolated offline domain prototype and native feasibility audit | Physical ledger/disc definitions, recipes, walking/inspection action, server binding, native conversion/recovery, production persistence and reader UI |

This is a compatible MINOR iteration from 0.12.0-dev.1, commit f1be19acaba4e4704f34696a76136425fad1a365. The feature branch is `feature/supply-ledger-and-load`, stacked on `feature/progress-and-containers`. Canonical source is `src/B47ANCEDQuartermaster`; experiments are outside it and excluded from the package. Optional Extended Categories support also uses the existing explicit category-member path; see [clean-room provenance](THIRD_PARTY_RESEARCH.md). Movement remains protocol 9, SupplyAPI remains 1, native sorting data/allocations/presets/priorities and required Rooms identity are unchanged. A new load-policy capability family is version 1; older peers cannot serve these settings.

The current local checkout at the original repository path has unrelated preserved work. Implementation uses the existing managed progress-and-containers worktree. Freshness interpretation: parent feature upstream matched f1be19a; the default branch has a README-only commit already represented in this feature's README. No gameplay delta from that default branch is silently omitted. No merge, reset, artifact cleanup or historical relabeling occurred.

## Native evidence and its limits

[VERIFIED SOURCE] Installed Build 42.21.0, Steam build 25485521. `projectzomboid.jar` SHA-256 is `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`. [Dated method descriptors, source hashes and findings](HANDOFFS_NATIVE_EVIDENCE_2026-10-15.json) record the inspected bytes. Public Java descriptors alone do not establish Lua exposure, correct execution side or multiplayer guarantees. Read-only JAR inspection is host tooling; no Java runtime mod or copied/decompiled game source is distributed.

### Capacity, weights and native transfers

- `ItemContainer.getEffectiveCapacity(IsoGameCharacter): int` is called by installed `media/lua/client/ISUI/ISInventoryPage.lua` (including lines 484–485). Its native implementation returns container capacity with applicable modifiers. On a character root, Organized/Disorganized storage modifiers are not applied in the same way as external storage.
- Comfortable capacity is `player:getMaxWeight()`. Root `ItemContainer.getMaxWeight()` follows that comfortable character value; it must not be mistaken for the root's native effective-capacity admission limit.
- Root effective capacity is read dynamically; the implementation never assumes a universal 50 kg maximum. Native `hasRoomFor` has additional special cases for floor/vehicle seats, heavy items, item size, bag/parent constraints and item restrictions. Those checks remain mandatory even below the policy budget.
- Item planning uses `getUnequippedWeight()` when present, with equipped carrier weight reduction applied by CarryBudget. Actual current carried weight comes from `player:getInventory():getCapacityWeight()`. Nested contents are represented by native item weights, not recursively added again.
- Native movement actions retain exact physical IDs/handles, live source/destination permissions and capacity admission. Confirmations require actual inventory results; walking alone is not transfer success. Server policy does not replace native final mutation checks or make unrelated vanilla transfers subject to a new lock.
- Native encumbrance, stamina, moodles, movement and injury effects are untouched. Their exact strength/trait/health/movement formulas, native weight propagation timing and remote-server rejection timing have not been calibrated in this iteration. There is no claimed formula or runtime throughput gain.

### Ledger items, recipes and computer

Verified vanilla definitions include `Base.Notebook`, `Base.SheetPaper2`, `Base.Pen`, `Base.Pencil`, `Base.Disc_Retail` (CD media) and `Base.Mov_DesktopComputer` (`appliances_com_01_72`). A functional terminal is not established merely by its sprite. `IsoGridSquare.haveElectricity()` is public and used by native Lua for powered equipment; complete computer interaction/range/power binding remains unimplemented.

B42 `craftRecipe` input/output and `mode:keep` syntax is present. Native recipe OnCreate uses a protected void Lua callback; its return value cannot be treated as a transactional veto or rollback. Public consumed/kept/created-item accessors and OnTestItem are research leads for a future adapter. Separate item type/script setters do not prove safe atomic conversion or full replication.

Native timed actions require actual sender-bound reconstruction, start and completion validation, not a client message saying time elapsed. The team's Auto Clean action offers an architectural reference, but its receipt/grant cannot automatically authorize a different ledger operation. This iteration has not established the ledger-specific native action binding or a recovery-safe one-CD-to-one-disc transaction with the snapshot registry. Those are implementation blockers, not just missing multiplayer test results.

## Dangerous Load implementation

Production changes: `LoadPolicy.lua`, `CarryBudget.lua`, `Trips.lua`, `Shopping.lua`, `Authority.lua`, `Protocol.lua`, `LoadSettingsUI.lua`, and settings entries in `SortControls.lua`/`Adapter.lua`. Identity, production inventory, mod.info, translations and version mirrors also change.

The server-owned existing Personal record receives an additive `loadPolicy` field: schema 1, revision 0, enabled false, utilization 100. Existing sorting configuration is not migrated or cleared. Absent values initialize to the requested disabled default. Corrupt/future data is preserved and fails closed, rather than silently increasing capacity. The established player/account identity and ModData persistence provide reconnect/restart storage; native restart persistence still needs testing. A weak actor cache is cleared by Authority cleanup and never caches the numerical native maximum.

`loadGet` returns the current authenticated player's scalar policy and current native capacity reading. `loadChange` accepts only a boolean, integer 50–100 and matching revision. It rejects changes while a movement operation/run is active. Existing transport binds the real sender; rate limits bound requests. Clients cannot submit a capacity, weight, another player's record or authoritative inventory data. This personal preference uses server validation as explicitly requested; no server-wide toggle is introduced. Existing shared CarryAllowance remains a server sandbox option.

Normal mode preserves comfortable capacity plus sandbox CarryAllowance (0–40, default 0). Dangerous mode uses current root effective capacity × utilization / 100, minus current capacity weight. Invalid native capacity fails closed. Sort, Room/Building sorting through Trips, and Shopping/Collect use the shared interface. Native per-item `hasRoomFor` and permission checks remain in the movement boundary. Changes to carried weight/equipment are re-read before further admission; previously completed transfers are preserved. Uncertain or rejected transfers keep the established stop/recovery behavior.

The settings dialog opens from **Sorting load settings** in the Sort/Quartermaster context menus. It has the requested toggle, 5-point utilization slider, numeric percent, last server capacity reading and penalty warning. It resizes, follows existing transparency/theme, supports controller focus/cancel, hides the irrelevant slider when disabled and rejects duplicate pending dialogs/requests. A viewport too small for the minimum layout reports a localized message. All 29 folders retain the established English fallback parity; these are not claims of 29 human translations.

The existing carry planner remains bounded (250 source examinations/slice, 400 operations/carry, 100 operations/native request). **Vanilla smaller transfer groups and timing remain unchanged.** No full-building preplan, route rewrite or native action-speed override is added. One-room/one-crate carry grouping and hard priorities remain. Carry limits affect trip capacity, but a calibrated loaded-speed total-time cost model is **not implemented**; no movement formula or improvement claim is invented.

## Shared actual-content analysis

`ContentAnalysis.lua` is a read-only service with no events, network handlers or automatic activation. Its caller must own an exact physical container reference, authorization callback and lifetime. It is not an unauthenticated inspection endpoint. At most 4,096 native items are accepted; larger inventories return an explicit unavailable reason rather than truncated data. Each step performs at most 64 read/verification iterations. These are resource bounds, not new gameplay configuration.

The first pass records native item references/IDs, FullType, display name, count, actual/unequipped weight and canonical category. The second checks those fields and current access/list identity. Top-level contents only: nested bags contribute native weight without revealing/counting children again. Instance count is separate from quantity. Native used/effective capacity are recorded without mutating overfilled storage.

There is no cross-job cache or live revision event adapter yet. The two passes detect tested changes but **are not an atomic native snapshot**: contents can change after an earlier row's final verification. A future caller needs a verified confirmed-change/revision boundary or conservative reinspection before publishing a summary. Pending transfers never count as confirmed contents. No per-frame building scan exists; native analysis/network/tick performance is unmeasured.

## Ledger prototype and remaining work

`experiments/supply-ledger/Model.lua` is explicitly outside runtime. It models server-owned snapshot bindings, per-container times, partial/resume state, immutable views, current-permission redaction, paper without search, powered digital reading, literal case-insensitive search and bounded result pages. Its trusted ports are mock contracts, not production security. Base/container/entry durations follow the handoff's 10/5/1-second defaults in fixtures; no inactive sandbox controls are exposed.

Offers retain the actual actor, paper, scope, revision, target, duration and server-side rows. A caller cannot replace snapshot contents by editing the returned token. Completion needs current access, exact revision, native receipt and unchanged contents; otherwise the target needs reinspection. Burn conversion defaults to unavailable. Mock tests exercise one-input/one-output success and an outcome-unknown journal that prevents retrying the same CD under another request key. They do not prove native inventory conservation.

Missing production components are intentional and must not be mistaken for available features: physical item/recipe definitions, exact stack-equivalence aggregation, incremental building discovery, native walking/writing completion, server snapshot registry/item replication, complete corrupt-data validation/retention, powered terminal and burning adapter, final permission/power checks and recovery across restart, lazy paper/digital readers and bounded search indexes. The prototype's full stored-row search is not yet a large-base production algorithm. No real paper/CD is consumed or created.

Required next implementation gate: prove authenticated ledger-specific timed-action reconstruction/start/stop/complete and a conservation/recovery-safe native CD conversion, then bind real Rooms/safehouse inspection and power. The Lua-only alternative while that remains unresolved is a non-mutating native-binding proof using fixture media; do not make a client-owned registry or counterfeit physical media. Global AGENTS and the `pz-mp-audit` skill require: “Stop affected gameplay implementation if safe authority cannot be established; never downgrade to client authority.” The installed skill path is user-profile `.agents/skills/pz-mp-audit/SKILL.md`; the rule is quoted here for portable review.

## Scope removal

The owner explicitly removed the shelf appearance experiment during this pass. Its new uncommitted code, authoring assets, exporter and dedicated tests were removed. ContentAnalysis now contains only item/category/quantity/weight reads, without appearance-family mapping, fullness tiers or dominance thresholds. No shelf renderer, sprite library, texture registration, visual preferences or 3D feature is part of the active project scope. The dated native API audit retains prior overlay/model observations as research history only, not a roadmap or authorization to implement them.

## Validation and performance

[TESTED OFFLINE] Windows host Lua 5.1/Lupa fixtures, installed native Lua-shaped UI/queue fixtures and Python checks. The entire existing regression suite passes with actual Rooms repository fixtures. New cases cover 50/75/100% policy; dynamic native limits/weights; stale/forged/corrupt data; reconnect cache cleanup; client refusal; resize/controller/toggle/save/cancel; bounded analysis and access/content invalidation; ledger immutable records/receipts/reinspection/redaction/literal search and mocked CD conservation/unknown outcomes.

Commands (from this worktree; Python is the host runtime with Lupa):

```powershell
python -B scripts/check_versions.py
python -B tests/run_tests.py --require-rooms --rooms 'C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDRooms'
./Build.ps1 -PythonPath <verified-python.exe> -GamePath 'E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid'
python -B scripts/check_versions.py --release
git -c core.safecrlf=false diff --check
```

Source/package parity and version checks describe distribution integrity only. The new development ZIP is for Dangerous Load and earlier carry/progress/source testing; the isolated ledger code is excluded. See the dated `HANDOFFS_DEVELOPMENT_ARTIFACT_2026-10-15.json` receipt for exact file count, SHA-256, source hashes and artifact location. The initial unpublished candidate is preserved byte-for-byte under dist/history/0.13.0-dev.1/pre-scope-change before rebuilding the current candidate after scope removal. Published historical packages are not overwritten or relabeled.

[UNKNOWN / NOT MEASURED NATIVE] Enabled/disabled time to first pickup/movement, pickup grouping/action counts, source/destination visits, travel/total sorting time, server ticks, actual analysis duration, payload bytes, memory growth and cleanup. No runtime improvement is claimed. Offline resource limits/test passes are not frame/tick measurements.

[RUNTIME GATE] **G6 NOT TESTED; G7 dedicated MP NOT TESTED / BLOCKED; stable G8 BLOCKED.** No earlier owner report or Auto Clean test is promoted to proof for this version. Required native cases: settings/save/reload/controller/scaling; normal vs heavy root/equipped/nested-bag pickups; changed capacity/manual pickup between grants; no-progress/cancel; exact conservation; full-destination spill/return; two remote clients/rejoin/server restart. Ledger needs its missing native bindings first, then the handoff's power/privacy/permission/concurrency acceptance cases.
