# Standalone extraction — authoritative status

Project Version: 0.24.0-dev.6

Current designated-only scope correction: native room selectors/requests are retired; B47ANCEDRooms designations provide room identity and native buildings provide building scope. Quartermaster Rooms capability is 4; movement remains 11. Existing ledger signatures, upstream complete-footprint configuration permission and provider-capability checks remain. Enforcement/live role routing stay disabled. [Exact validation and limitations](DESIGNATED_ROOM_SCOPES.md).

## Ledger freshness — current 0.17 source iteration

Inventory/selected-container Sort is independent of ledger possession. Room/Building jobs retain server-validated fresh scope checks. Four ledger modes, in-game update days, manual/automatic computer updates, immutable renewal generations and bounded read-only live projections are implemented. Current branch: `feature/ledger-freshness`, from `2cac3ae5497bdbf793e119d12f3ef61ceb457457`; current manifest: 211 runtime files. No package/deployment/publication/game/server launch. [Exact policy, validation and pending runtime gates](LEDGER_FRESHNESS.md). G6/G7 NOT TESTED; stable G8 BLOCKED.

Earlier iteration sections below retain their original publication/validation context and do not describe this source-only iteration.

## Current development iteration

The user authorized publishing 0.16.0-dev.2 as Workshop MP test distribution. Full offline build/package/stage gates and explicit paired Rooms checks pass. SteamCMD publication, exact public description and graceful Steam restart are confirmed; G7/stable G8 remain blocked. See [current release record](WORKSHOP_TEST_0_16_0.md).

Save now keeps the container-rule editor open, refreshes acknowledged records/rail state and reloads an invalidated inherited section when necessary. Existing server save/permission behavior and manual close/Cancel are preserved. Current focused UI regression and syntax checks pass offline; native acceptance remains NOT TESTED. See [exact checks and workflow](MULTI_CONTAINER_UI_IMPLEMENTATION.md). Physical-shopping implementation/full-suite evidence remains from 0.16.0-dev.1 and is unchanged by this local UI fix.

Current feature/physical-shopping-lists implements named, transferable physical Shopping papers, retained notebook/writing tool requirements, one-sheet creation, an explicit one-time legacy import, list selection/renaming and a held-paper checklist HUD. Server-owned profiles preserve the current allocator/preferences and freeze linked targets onto each paper. The prior supply-ledger Sort/Collect requirements remain enabled by default. The original implementation checkpoint was source-only; 0.16.0-dev.2 is now packaged/published for Workshop MP testing without local deployment. Native G6/G7 NOT TESTED; stable G8 BLOCKED. See [current report](PHYSICAL_SHOPPING_LISTS.md).

## Separate Auto Clean and supply API — historical 0.11.0-dev.1

Clean Building's production modules/menu/jobs now belong to B47ANCEDAutoClean. Quartermaster provides SupplyAPI 1 for configured storage, live permission/capacity checks and exact native transfers. Auto Clean requires Quartermaster and Rooms; no reverse dependency was added. Storage/save schemas and Rooms sandbox settings remain unchanged. See [current contract and validation](SUPPLY_API.md). This extraction is not deployed or published. SP/dedicated acceptance remains NOT TESTED; G7/stable G8 BLOCKED. Earlier embedded-cleaning sections below are historical checkpoints.

## Single-player Clean Building — historical 0.10.0-dev.1

Lua-only SP support now queues the retained guarded Job/Poc native actions locally. Exact local-player binding, Rooms settings/permissions, supply locks, measured recipe and cross-level footprint checks remain active. Multiplayer command authentication and reconstruction are unchanged. Offline SP/native-Lua regression tests pass; real PZ SP and dedicated acceptance remain NOT TESTED, G7 and stable G8 BLOCKED. See [SP design, exact validation commands and runtime gates](CLEAN_BUILDING_SINGLE_PLAYER.md).

The earlier version sections below are historical checkpoints. Their disabled-SP status and prior publication/restart observations do not describe the current source.

## Required Rooms dependency — 0.9.0-dev.1

Rooms (Mod ID B47ANCEDRooms, Workshop 3820077442) is now mandatory in native mod.info metadata and Steam Required Items for Quartermaster and its embedded Auto Clean. This breaking 0.x dependency change preserves Lua gameplay, server guards, schemas and protocols. Both peers must enable Rooms. Source/package/version checks must pass before the authorized MP testing upload; native/dedicated G7 NOT TESTED and stable G8 BLOCKED. Earlier checkpoint sections below retain their original optional-dependency context.

## Rooms Workshop distribution follow-up

Rooms 0.1.0-dev.1 is now public on newly authorized Workshop item 3820077442 (Mod ID B47ANCEDRooms). Release source is Rooms commit `f1f41f60e14fb6d9411203c9dfe9b6c79524b5af`. SteamCMD upload and exact public metadata were verified; a fresh tool-cache download matched all 84 runtime files and required directories. Quartermaster's canonical description/changenote now link Rooms and instruct subscribing/enabling both mods on every peer. Its 141-file runtime ZIP is unchanged; the link-update source commit is `caa75c75a58cc491d468d827e58e1d0a5e36b043`. Both public feature branches were pushed and verified. Receipts are retained under each repository's ignored dist/workshop-publish directory. The previous source-only Rooms distribution limitation is superseded; earlier notes below remain historical.

This remains an MP testing distribution: native/dedicated G7 NOT TESTED, stable G8 BLOCKED; single-player cleaning disabled. No SP deployment or game/server launch. The final automatic Steam restart command was rejected by approval review with "blocked by policy"; no forced or alternate restart was attempted. Live verification completed separately and both publications are confirmed.

## Confirmed Workshop MP testing upload — 2026-10-15 UTC

Quartermaster 0.8.0-dev.1 was uploaded successfully to existing Workshop item 3807217050 at 05:48:48 UTC. SteamCMD reported `Committing update...Success`; the Steam published-file API returned the exact canonical description, matching item/app/title, newer update timestamp and unchanged public visibility. Release commit: `71e1ca81dc3fc20ba8533d60d3aa2e7b308be359`; ZIP SHA-256: `4f9253e549d80a8ab59a211f3edf54baa1d2522d0f4e0d34d24a96e982767bfa`. The local publication receipt and prior-package preservation ledger are under `dist/workshop-publish/0.8.0-dev.1-clean-building/`.

Both public feature branches were pushed and verified. Required Rooms source is commit `d603cd53903e01b6c575f4e1efcfa6da555e4a70`, version 0.1.0-dev.1; it has no Workshop item and was not uploaded. The description links that exact source and explains separate installation. The 141-file source/package/stage parity, archive integrity, Lua-only, version and offline checks passed, including 83 Clean Building scenarios. Steam was gracefully restarted and a new client process verified. Subscription/download agreement, native acceptance and dedicated G7 remain NOT TESTED; stable G8 BLOCKED. Single-player cleaning is disabled. No local SP deployment, game/server launch or server changes. The older checkpoint notes below retain their original context.

## Clean Building source activation

[VERIFIED source] Quartermaster now auto-installs its Clean Building server/client integration through verified multiplayer lifecycle events. Matching Rooms source supplies cleaning capability 1, settings and policy. The default recipe is 10 mL bleach first, followed by water to fill the 10 L bucket. [TESTED offline] Production-module workflow, sender/reconstruction guards and lifecycle tests pass. [RUNTIME GATE] Single-player remains disabled; native client/server acceptance and dedicated G7 are NOT TESTED, stable G8 BLOCKED. Existing packaged artifacts predate activation and remain unchanged. See [exact scope, commands and test prerequisites](CLEAN_BUILDING.md).

## Rooms extraction and scoped sorting — 0.8.0-dev.1

[VERIFIED source] B47ANCEDRooms is an optional standalone service. It owns room IDs, geometry, overrides, editing, delegated policies and persistence. Quartermaster owns physical discovery, furniture, configuration, planning, Shopping/Dibs and native transfers. Without Rooms, native room/building sorting and vanilla safehouse checks remain available. An installed incompatible/unavailable Rooms service fails closed.

[TESTED offline] The production-path room sweep includes the full player inventory and unequipped carried bags before configured physical sources: 24 exact moves and 33 skips. A second whole-building sweep moves two further items without revisiting correctly sorted stock. The actual standalone Rooms API is exercised for action-specific permissions, privacy, revocation and invalidation. These are Windows Lua 5.1 fixtures, not native multiplayer evidence.

[RUNTIME GATE] Native rendering/controller/scaling, actual save/load and two-client dedicated ownership, permissions, sorting, reconnect/restart and conservation tests are NOT TESTED. G7 and stable G8 remain BLOCKED. No deployment, publication or game/server launch. Development artifacts are offline test packages only. Both Quartermaster peers require configuration 5, movement 8 and rooms 2; Rooms uses its separate API/protocol 1 and registry schema 2. See [current design and validation](ROOMS_INTEGRATION.md).

## Historical custom room development — 0.7.0-dev.1

[VERIFIED source] Custom rooms are server-owned logical tile regions with creator/current safehouse-member editing, revision-checked atomic writes, and exact physical-container membership. The in-world editor provides bounded structural/native candidates, rectangles, paint/erase, undo/redo, duplicate, combine, split, rename and delete. All geometry remains a preview until confirmed. Native world geometry is never modified.

[TESTED offline] The full source regression suite, 133-file production inventory and installed native category comparison pass. The three-container room sweep moves 20 misplaced items exactly once, preserves 28 correct/already-seen items and retains the installed native queue Lua path. Host fixtures do not prove game behavior. Both peers require configuration capability 4, movement 7 and rooms 1; existing config schema 2/world root 1 are unchanged.

[RUNTIME GATE] Native visual/controller acceptance, remodeled/open-door boundaries, real save/load and two-client dedicated authority/reconnect/restart tests are NOT TESTED. Dedicated G7 and stable G8 remain BLOCKED. No package, deployment, publication or game/server launch for this iteration. See [custom room design, controls and exact validation commands](CUSTOM_ROOMS.md).

## Historical 0.6.0-dev.3 category lookup and MP test distribution

Compatible PATCH dev.3 checks getter availability before native category lookup. The missing-method regression fails before the change and passes afterward, preserving categories and server authority. Includes the dev.2 transfer correction below. The user authorized packaging and Workshop MP test distribution; the release manifest/receipt records the actual commit, hashes and upload outcome. Native catalog/transfer speed and dedicated acceptance remain NOT TESTED. See TRANSFER_THROUGHPUT.md. No local live deployment or game/server launch.

## dev.2 transfer throughput correction (retained source work)

Aggregate per-phase movement requests preserve individual server checks while reducing message overhead. Ready batch phases dispatch without quarter-second polling gaps; vanilla action timing is unchanged. See TRANSFER_THROUGHPUT.md for measured offline overhead, authority boundaries, exact commands and pending runtime gates. A separate observed batch-guard stop is instrumented with precise reasons; no runtime fix is claimed. No deployment/publication.

## Current native-only storage cleanup

Server-only, one-way sorting-data retirement removes obsolete categories/formats while preserving native rules, explicit items, priorities, owned preset generations and whole-container identities. Retired taxonomy modules are excluded from runtime. Foreign LSBox registries and unrelated personal/gameplay state remain untouched. See NATIVE_CATEGORIES_COMPATIBILITY.md for exact scope, protocol versions and validation. Runtime/dedicated acceptance pending; no deployment/publication.

Historical implementation notes below describe their original versions, not the current category architecture.

## Historical dev.50 native queue assembly

Compatible PATCH candidate: use native ISQueueActionsAction to enqueue all authorized donors before the first transfer begins. Existing server batch size, native weight/type grouping, transaction timing and stable item-ID guards remain. Regression reproduces one-item first submission before the fix; actual installed native helper and transfer lifecycle are exercised offline. See DEV50_NATIVE_QUEUE.md. No package/deployment/publication.

[VERIFIED scoped runtime] User confirms dev.49 fixed the one-item stop. Client log reports client/server dev.49, 140 completed, zero transfer failures, followed by a no-work run with 1,467 noMatchingRule skips. This is not complete G7 acceptance; dev.50 queue behavior remains runtime-unverified. G7 NOT TESTED/BLOCKED; stable G8 BLOCKED.

## Historical dev.49 Workshop corpus classification

Compatible PATCH correction: 378 installed packages, 13,893 script files, 37,320 declarations and 27,274 distinct types inventoried read-only. Five metadata fallback meanings refine 298 declarations (274 distinct types); all other classifications and approved vanilla deviations stay unchanged. No third-party implementation/assets imported. See WORKSHOP_CORPUS_AUDIT.md for provenance, limits and validation. Native effective-load-order/SP/dedicated evidence remains pending; G7 NOT TESTED/BLOCKED, stable G8 BLOCKED. No deployment/publication.

## Historical dev.48 native item lookup candidate

[VERIFIED client log] Dev.46 Sort ends putting:cancelled:operationStateRejected, completed=0, sourceCount=1608, planningTargets=190. The local server copy is still stale; no refreshed server evidence was supplied. [INFERRED] Lua wrapper identity may lose the operation lookup. Use the existing numeric item ID, preserving state/containment/native/server checks. Equivalent-wrapper fixture fails before this change; dedicated retest remains mandatory. No package, deployment or publication. G7 NOT TESTED/BLOCKED; stable G8 BLOCKED.

## Historical dev.47 audit remediation

Compatible PATCH iteration from dev.46. Source correction and regression work complete for selection, presentation, safe known-outcome cancellation, preferences and build reproducibility. Native continuation remains OPEN: no dev.46 Sort result is available. Expanded offline fixture executes installed vanilla constructor/start/update/validation/perform with simulated transaction acknowledgements. Full suite, 127-file source manifest, versions and 5,092-item approved taxonomy comparison PASS offline. See DEV47_AUDIT_REMEDIATION.md for all findings, commands and limits. G7 NOT TESTED/BLOCKED; stable-release G8 BLOCKED. No package build, deployment or publication. GitHub verification is recorded in the iteration report.

## Current dev.46 native stop-origin diagnostic

[VERIFIED runtime logs] Client and server dev.45; three attempts cancel during putting with nativeActionStopped, source count decrements by one. This disproves claiming dev.45 resolved the live defect. [UNKNOWN] Whether vanilla validity or another engine action stop cancels continuation. Dev.46 distinguishes nativeValidationRejected, batchGuardRejected, operationStateRejected and stop before/after native perform without changing transfer behavior. [TESTED offline] Full suite PASS, including forced native validation failure and stop after one completed group. Commands: `python tests/run_tests.py` and `python scripts/check_versions.py --root .` using the configured Python runtime. Current dev.45 package retained unchanged; artifact/version gate BLOCKED until separately authorized archival/build. G7 NOT TESTED/BLOCKED; G8 BLOCKED. No deployment/publication. GitHub iteration on fix/native-transfer-diagnostics; public push verification recorded in the iteration report.

## Current dev.45 batch replication guard

[VERIFIED publication] SteamCMD exit 0, Committing update...Success for Workshop 3807217050. Full offline suite, release versions, 127-file package/stage/source parity and exact submitted prose checks PASS. Receipt: dist/workshop-publish/dev45-publication-receipt.json. Development testing publication authorized; dedicated G7 and G8 readiness remain BLOCKED. No live client deployment or remote server update performed.

[VERIFIED source] Batch validation required source containment after native submission, unlike the single executor. Native source removal can precede destination containment; vanilla accepts the missing source item while awaiting its transaction. Delegate in-flight validation to vanilla; keep pending-group checks before submission. Cancellation distinguishes native transaction rejection and queue cancellation. [INFERRED] This may explain the live one-item stop; console alone does not prove the cause. G7 NOT TESTED/BLOCKED; G8 BLOCKED. No deployment/publication. [TESTED offline] Full suite and versions PASS. Exact commands: `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe tests/run_tests.py` and `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe scripts/check_versions.py --root .` from the project directory. Log: dist/handoffs/dev45-tests.log. Regression uses actual installed vanilla isValid with source absent during an in-flight transaction, alongside existing pending-group revocation/capacity tests. It does not execute native Java transactions or certify dedicated MP.

## Current dev.44 target-free opener guard

Console confirms client and responding server dev.43, and getContainerByIndex-on-null through MultiContainer.attach -> Targets.make during target-free inventory opening. MultiContainer now skips that resolution; Targets.make also guards absent objects before native lookup. Nearby discovery and unselected Save protection remain intact. Offline full suite PASS; native UI acceptance pending. No deployment/publication. Separate PUT-stage cancellation has not been diagnosed. Commands: `python tests/run_tests.py`, `python scripts/check_versions.py --root .`, `python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev44-vanilla-diff.json --approved-changes docs/DEV41_APPROVED_TAXONOMY_CHANGES.json`, using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe. Valid object/authority behavior unchanged; G7 N/A for this no-target navigation slice, existing project dedicated gates/G8 remain BLOCKED. Published dev.43 package archived unchanged under dist/history/0.4.0-dev.43.

## Current dev.43 authoritative arrival wait

[VERIFIED publication] SteamCMD exited 0 and committed the dev.43 update to Workshop 3807217050. Source/package/staging parity: 127 files. Receipt: dist/workshop-publish/dev43-publication-receipt.json. Canonical submitted prose matched exactly; public-page read was inaccessible. No live client deployment or remote server update performed. Dedicated validation remains pending.

TAKE/PUT adjacency is now a bounded server-observation wait, with unchanged authorization checks before any grant. Client batch/single metadata polling is bounded; native transfer is never replayed. Movement capability 4 rejects older peers; client/server both require the update. Offline delayed-position reproduction now transfers 701/701 with zero failures; timeout/capacity/removal/cancellation and late server deadline remain fail-closed. Native G7/G8 readiness BLOCKED / NOT TESTED. Development testing publication authorized. See DEV43_ARRIVAL_AUTHORIZATION.md.

## Current dev.42 zero-transfer investigation

User reports player-inventory Sort walking to a configured container but placing zero items, followed by 700+ skips. Client console identifies dev.41; no transfer trace proves the rejection or server build. Offline 701-item deposit fixtures pass. Dev.42 stops a zero-progress failed batch, preserves subsequent inventory and logs the first rejection plus separate skip counts/server identity. Terminal skip-count bug corrected. Full regressions PASS; native cause UNKNOWN, dedicated G7/G8 readiness BLOCKED. No live deployment/publication. See DEV42_ZERO_TRANSFER_INVESTIGATION.md.

## Current dev.41 Weapons hierarchy

[VERIFIED publication] SteamCMD exited 0 and reported Committing update...Success for Workshop 3807217050. Package/source/staging parity: 127 files. Receipt: dist/workshop-publish/dev41-publication-receipt.json. Public-page read was inaccessible; submitted prose was checked exactly against canonical text. Native/dedicated gates remain pending; no live local installation or remote server was changed.

Four category levels, Handguns spelling, new explosive/blade/firearm/attachment splits and secondary weapon rows for tools. Tool use is mandatory primary classification; retired sandbox option cannot override it. Shared names/counts and live server destination checks retained. Current reviewed native membership manifest: DEV41_APPROVED_TAXONOMY_CHANGES.json (625 cumulative, 63 new). Full offline regressions and package checks pass; G7 dedicated NOT TESTED/BLOCKED and G8 readiness BLOCKED. User authorized development testing publication; no readiness claim. See DEV41_WEAPONS.md.

## Current dev.40 category labels

Recreation, Smoking, Light Source and Media replace their former labels across 29 language tables. Category IDs, item assignments, hierarchy and saved rules unchanged. Weapons tree explicitly deferred. Validation commands: `python tests/run_tests.py`, `python scripts/check_versions.py --root .`, and `python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev40-vanilla-diff.json --approved-changes docs/DEV34_APPROVED_TAXONOMY_CHANGES.json` using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe. Offline suite, language parity, versions and exact approved memberships PASS; native display NOT TESTED. G7 N/A for these presentation-only labels; existing gameplay G7/G8 gates remain blocked. No deployment/publication.

## Current dev.39 inventory menu opener

Open Quartermaster Menu now registers with the native player inventory controls only, independent of selected carried container or empty contents. Target-free opening discovers from the player's location and requires selecting a returned target before Save. Server discovery/validation unchanged. Offline suite PASS; native inventory/controller acceptance NOT TESTED. See DEV39_INVENTORY_OPENER.md. No deployment/publication.

## Current dev.38 server planning cache

Destination configurations, effective rules and preset snapshots are reused within each synchronous server tripNext batch, then discarded. Live eligibility and transfer authorization remain unchanged. Offline cost regression: 100 decisions share one destination preparation, with dynamic capacity eligibility and revoked-target rejection. Full regression PASS; dedicated startup timing NOT TESTED. No deployment/publication. See DEV38_SORT_PREPARATION.md.

## Current dev.37 floor controls and startup

Native floor controls now register Sort separately from object loot controls. Floor/aggregate intent buttons remain visible through transient empty lists. BatchExecutor safely initializes before Executor, which preserves the shared executor table; this addresses the reported startup failure and subsequent missing batchSupported call. Full offline regression PASS; native Proximity Inventory compatibility and dedicated multiplayer remain NOT TESTED. No deployment/publication. See DEV37_FLOOR_CONTROLS_AND_STARTUP.md.

## Current dev.36 Room/Proximity scope hotfix

Console-confirmed null parent in native getNew, caused by dot syntax at MultiContainer.lua:219. Room and Proximity now use native colon method. Full offline suite PASS, strict parent contract and Building -> room-token/Proximity choices covered. Native hotfix NOT TESTED; console session client/server dev.30. No deployment/publication requested. G7/G8 BLOCKED. See DEV36_SCOPE_MENU_HOTFIX.md.

## Current dev.35 Bags

Bags now has Clothing as its primary UI parent and retains Containers as a compatibility parent. Existing B47_ContainersBags ID and all item classifications unchanged from dev.34; label is Bags across 29 languages. Full offline suite and versions PASS; corpus retains the same 562 cumulative approved deviations, with no new item moves. No package/deployment/publication requested. Native/dedicated NOT TESTED; G7/G8 BLOCKED. See DEV35_BAGS.md.

## Current dev.34 Clothing and armor hierarchy

Requested 13 Clothing & Accessories sections, including Costumes, plus ten applicable - Armor leaves. Jewelry includes necklaces/earrings/wrist jewelry; equipment includes bandoliers/holsters/belts/pouches; eyewear is separate. All 290 native ProtectiveGear definitions resolve to armor slot categories, with former Protective Clothing saved rules preserved. Exact cumulative reviewed changes: 562 of 5,092 items, including prior passes. Full offline tests/version checks PASS; native/dedicated NOT TESTED, G7/G8 BLOCKED. No package, deployment or publication requested. See DEV34_CLOTHING_AND_ARMOR.md.

## Current dev.33 ammunition/beverage hierarchy

Ammunition: Containers, Boxes & Cartons, Loose Ammo, Magazines & Clips. Beverages: Alcoholic, Soda, Water, Empty Water Containers, Milk, Other Drinks. Bandoliers use Clothing/Accessories; Books label shortened. Former Non-alcoholic Drinks ID remains a compatibility family. Exact cumulative deviations in DEV33_APPROVED_TAXONOMY_CHANGES.json: 119 of 5,092 baseline items, including prior scissors/rings corrections. Full offline suite and version checks PASS; native/dedicated NOT TESTED, G7/G8 BLOCKED. No package/deployment/publication requested.

## Current dev.32 woodworking label and rings

Rename ToolsCutting's label to Woodworking Tools without changing its ID/memberships. Add B47_ClothingJewelry under Clothing for the four normalized finger body locations: 24 vanilla rings plus matching modded items. Other accessories and key rings remain unchanged. Retain dev.31 Stationary/scissors correction. Exact cumulative approved deviations are in DEV32_APPROVED_TAXONOMY_CHANGES.json; historical baseline remains unchanged. No package/deployment/publication requested. Native SP/dedicated acceptance NOT TESTED; G7/G8 BLOCKED.

## Current dev.31 category correction

User-authorized exceptions to the frozen membership: Base.Scissors and Base.ScissorsBlunt (Safety Scissors) now resolve to B47_Stationery. Label is Stationary in all 29 fallback language tables. Category ID and native item metadata remain unchanged. Historical frozen baseline retained; exact approved deviations tracked in DEV31_APPROVED_TAXONOMY_CHANGES.json. No package, deployment or publication requested. Native acceptance remains NOT TESTED; G7/G8 BLOCKED.

## Current dev.30 presentation candidate

UI-owned canonical inventory Category row keys now drive native Category sorting and localized labels without mutating native item/script metadata. Full offline regression/package/version checks pass; 127 runtime files; frozen 5,092-item membership unchanged. Native Category renderer compatibility and dev.28/dev.29 resize/opacity acceptance remain NOT TESTED. G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. Development ZIP only; no deployment, staging or publication. See [current implementation/evidence](DEV30_CATEGORY_AND_NATIVE_ACCEPTANCE.md) and [native acceptance matrix](DEV30_NATIVE_ACCEPTANCE.md). Older sections below retain historical evidence and limitations.

## Current dev.25 ground source implementation

Lua-only explicit Floor and resolvable aggregate sources are implemented. Short-lived server references, native queued acquisition and observed carrier/destination confirmations preserve the native PZ authority boundary. Movement capability 3 requires matching builds. Native Proximity Inventory UI and dedicated transfer acceptance remain unverified: G7 NOT TESTED/BLOCKED; G8 BLOCKED. No deployment/publication. See [details and native gates](DEV25_GROUND_SOURCES.md).


## Current dev.24 implementation

Bounded server planning and native queued batches are implemented; 29 offline production pipeline scenarios and the full regression suite pass. Movement capability 2 requires matching peers. Source manifest: 119 files. Native startup latency and dedicated transfer behavior remain unverified: G7 NOT TESTED/BLOCKED; G8 BLOCKED. No current package, deployment or publication. See [implementation and runtime gates](DEV24_PIPELINE.md).


## dev.21 Category failure investigation

User confirms dev.20 loaded but visible Category labels remained vanilla with Neat UI. Added OFF-by-default bounded boundary diagnostics; no new renderer or gameplay changes. Full offline suite and 5,092-entry zero-change comparison passed. G6 diagnostic acceptance BLOCKED, G7 NOT TESTED, G8 BLOCKED. Bulk-transfer/collision native audit is separate and implementation remains outstanding. See `dist/handoffs/dev21-category-investigation.md` and `dev21-bulk-and-collision-audit.md`. Published dev.20 remains unchanged.

## dev.20 Inventory Category column hotfix

Compatible PATCH correction on dev.19: Category cells use the canonical resolver cache and current localized labels. Compatibility is checked during rendering rather than permanently skipping registration during early Lua loading. Native row.cat, sorting, grouping and item definitions stay unchanged. Full offline regression and frozen 5,092-item comparison passed; actual B42.21 inventory/loot/controller/scaling and second-language client acceptance remain UNTESTED. Dev.19 Stage A instrumentation is retained; its dedicated timing gate remains BLOCKED. See `dist/handoffs/dev20-inventory-category.md`. No deployment or publication.
Date: 2026-10-09
Public name: B47ANCE'd Quartermaster
Mod ID: B47ANCEDQuartermaster
Workshop ID: 3807217050

This is the single current extraction report. Earlier multi-container and identity reports are historical evidence. The authority handoff and native categorization revision supersede the optional Better Sorting integration proposal.

## Current implementation — 0.4.0-dev.19 responsiveness Stage A

[VERIFIED SOURCE] Bounded correlated trace spans measure discovery, handle generation, candidate validation, rules, trip construction, request round trips, client binding waits, grant requests and native action starts. Immediate preparation acknowledgement is localized in all 29 fallback folders. No planning or cache architecture changed. The clock is explicitly labeled wall time, independently on each peer.

[RUNTIME GATE] The largest measured native delay and first blocking boundary are UNKNOWN until matched client/server traces exist. Stage B–D optimization remains gated by the handoff’s instrument-first/do-not-optimize-blindly requirement. Dev.19 is not deployed or published. Dev.18 remains the published/local build. G6 native NOT TESTED; G7/G8 BLOCKED. See `../dist/handoffs/dev19-responsiveness.md`.

## Previous implementation — 0.4.0-dev.18 remediation

[VERIFIED SOURCE] Native metatables from dev.17 are retained. Same-floor checks use grid Z consistently; Set Target has a prefilled editor; font-aware minimum is no longer overwritten; terminal exceptions retain bounded context. Gameplay network requests declare family capabilities, expensive server reads have authenticated-player admission budgets, Dibs inspection scans only its existing reach, and stale/disconnected server capabilities are swept without clearing persistent lists.

[RUNTIME GATE] Local installation and Workshop staging now contain dev.18; SteamCMD committed dev.18 to Workshop on 2026-10-08. Available prior console evidence remains dev.13. Neither dev.17 nor dev.18 has a demonstrated dedicated Sort outcome. P0 remains BLOCKED — NATIVE TEST REQUIRED. A01 retains the native dispatch boundary; A02 stable item-rule migration is not implemented; A05/A06/A09/A10 retain documented partial work. See `../dist/handoffs/dev18-remediation.md`. G7 NOT TESTED/BLOCKED; G8 BLOCKED.

## Previous implementation — 0.4.0-dev.17, dedicated Sort timed-action hotfix

[VERIFIED SOURCE] B42.21 `NetTimedAction` serializes the action metatable's Type and raw `new` constructor arguments, then reconstructs that type on the dedicated server. The former client-only `B47OneItemTransfer`, `B47OneItemWalk`, and `B47ReturnToSource` derived metatables had no server counterpart and no raw constructor. Sort now queues native `ISInventoryTransferAction` and `ISWalkToTimedAction` instances; Quartermaster's final source/destination checks and cancellation callbacks remain attached to the local instances before native dispatch. Server planning/grants and native transaction validation are unchanged.

[TESTED offline] Focused movement tests exercise native-metatable reconstruction requirements, TAKE/walk/PUT, cancellation, target replacement veto and multiple trips. Full suite and package evidence are recorded in `dist/handoffs/sort-dedicated-mp-hotfix.md`. [RUNTIME GATE] The user's dedicated report remains the native baseline; no post-fix dedicated transfer has yet been observed. G6 native NOT TESTED, G7 dedicated NOT TESTED/BLOCKED, G8 BLOCKED. Ground sorting and placed-item protection are outside this hotfix.

## Historical dev.17 handoff ground/protection gate (source was dev.16) — source/JAR audit only

[INFERRED from verified APIs] A server discovery can bind a short-lived token to an exact currently loaded `IsoWorldInventoryObject` reference and revalidate it on action; client coordinates or native item ID alone are not authority. [VERIFIED SOURCE] Native object entity ID is derived from square/index. The world-inventory-object save override serializes its contained item but does not write inherited object modData through the generic `IsoObject.save` path. Item modData persists, but an item-attached protection marker follows manual pickup and can leak onto an ordinary Drop. The inspected SP and MP transfer paths reach `IsoGridSquare.RemoveTileObject`, which raises `OnObjectAboutToBeRemoved`; lower-level world-item removal does not directly raise it. Coverage across all native removal/reposition paths and a complete server-owned persistence/cleanup path remain [UNKNOWN]. See `dist/handoffs/dev17-world-protection-gate.md`.

[RUNTIME GATE] Stop before adding Protect/Allow actions or ground/proximity Sort. The handoff's exact-instance persistence and pickup-cleanup requirements cannot yet be met from verified boundaries. Automatic Place detection remains deferred. Source stays 0.4.0-dev.16, taxonomy protocol 6, schema 2 and world root 1. G6 native NOT TESTED/BLOCKED for this feature; G7 dedicated NOT TESTED/BLOCKED; G8 BLOCKED. No package, deployment or publication.

## dev.16 placement authority follow-up — source/JAR audit only

[VERIFIED SOURCE] `InventoryItem.id` is a serialized 32-bit random value. `AddWorldInventoryItem(InventoryItem,...)` gives its world object the same item reference, but the ID has no collision-free or client-trust guarantee. Vanilla sets `isPlaceItem=true` on the client after constructing `ISDropWorldItemAction`; `NetTimedAction` serializes the constructor arguments and reconstructs the action on the server, omitting that later marker. The inspected server world-add path therefore has no verified deliberate-Place indicator.

[UNKNOWN] An ordered, server-validated pending intent and atomic successful-creation observation point have not been proven. Save/chunk identity, modData persistence, repositioning and pickup cleanup need later investigation only after that bridge exists. [RUNTIME GATE] Ground/proximity sorting and placed-item protection remain disabled. G6 native NOT TESTED, G7 dedicated NOT TESTED/BLOCKED, G8 BLOCKED. See `dist/handoffs/dev16-placement-authority-proof.md`. This follow-up changes no production source, version, package or taxonomy.

## Previous implementation — 0.4.0-dev.16, inventory label cleanup and world-item authority gate

[VERIFIED SOURCE] Inventory Sort control uses the localized UI_B47_Sort label for mouse and joypad, on both inventory and loot windows. Its fallback text is now exactly Sort in all 29 language tables; the existing Auto-Sort control was not found in the production source.

[RUNTIME GATE] Native Place uses client-side isPlaceItem and ISDropWorldItemAction:complete creates the world object via AddWorldInventoryItem without carrying that flag into its resulting object or a verified server registration event. The native grab action uses a world-object transaction, but the inspected Lua does not prove the server can verify which placed instance resulted from a specific player intent. Ground sorting and placed protection remain disabled; G7 NOT TESTED, G8 BLOCKED. See dist/handoffs/dev16-authority-audit.md.

## Previous implementation — 0.4.0-dev.15, modded-item evidence and presentation

[VERIFIED SOURCE] Canonical resolver ranks exact FullType overrides, existing semantic/functional evidence and native DisplayCategory with deterministic weights and confidence. Its fast path retains the old classification when stronger evidence already wins. A generic `Medical` display-category fallback refines 19 installed Build 42 declarations from Misc to Medical Supplies. Taxonomy protocol 5 → 6 for changed modded memberships; schema 2, world root 1 and saved category IDs remain unchanged. Prior protocol 5 configurations remain readable; mixed-version writes are rejected by the existing authority check.

[TESTED offline] Frozen dev.14 comparison over 5,092 installed B42.21 vanilla FullTypes: zero category changes. Full Lua regressions include scoring/mod-neutrality and the local Group Items by Mod preference. The read-only Workshop audit covers 371 installed packages, 866 mod.info files, 14,241 script files and 34,890 item declarations across variants; installed does not mean active/effective. See the dev.15 audit artifacts for duplicate declarations, fallback cases and load-order limits. No Workshop files were edited or scanned by runtime code.

[VERIFIED SOURCE] The default tree presents broad category → physical subcategory → item. Group Items by Mod, off by default and saved to a client-local UI file, adds mod rows inside each subcategory. Mod provenance remains available for search and diagnostics and is not a normal taxonomy input. The inventory Category adapter continues to use the canonical resolver.

[RUNTIME GATE] Player-placed-item protection is stopped before gameplay code. Vanilla Place and Drop paths were identified, but the current Sort source set has no ground/proximity acquisition path; successful Place authority, exact world-instance association and persistence are not proven. See `dist/handoffs/dev15-placed-authority-audit.md`. SP, listen and dedicated validation are NOT TESTED; G7 BLOCKED / NOT TESTED and G8 BLOCKED. No dev.15 package, deployment or publication was performed.

## Previous implementation — 0.4.0-dev.14, discovery and presentation

[VERIFIED SOURCE] Initial container discovery now has explicit uninitialized/discovering/ready/failed states and rejects stale generations. A relevant loaded-square event marks the open picker for another server discovery; the callback updates that same window. Shopping opens while container discovery is pending because its personal list has separate authority. A native event after final container population, first-open timing, and authoritative target readiness still require in-game testing.

[VERIFIED SOURCE] Whole Building enumerates the player's native building room bounds and only currently loaded squares, without applying Tile Radius. The server validates the player's building and selected target. The ordinary radius mode still follows its sandbox limit. This changes discovery scope, not stored rules or trust ownership.

[VERIFIED SOURCE] Broad category → physical subcategory → mod → item presentation uses existing taxonomy IDs and resolver memberships. The ordinary inventory Category column has a client-only adapter for the same canonical resolver winner; Item/ScriptItem metadata is untouched. Native rendering and sorting require in-game visual testing. Sort now reports when zero items moved, but the native movement outcome remains unverified.

[TESTED offline] The full Lua regression suite covers building scope, event-driven same-window refresh, Shopping during pending discovery, hierarchy shape, and inventory Category display/sort without item mutation. Package and final parity evidence are recorded in the dev.14 handoff report.

[RUNTIME GATE] SP first-open, listen, dedicated two-client and multi-resolution UI acceptance are NOT TESTED. G7 BLOCKED / NOT TESTED; G8 BLOCKED. No dev.14 live deployment or Workshop publication was performed.

## Previous implementation — 0.4.0-dev.13, post-taxonomy UX/performance

[VERIFIED SOURCE] Compatible prerelease UX/performance refinement from dev.12 to dev.13. Taxonomy protocol 5, configuration schema 2, world root 1, authoritative server routing and sandbox settings are unchanged. The four frozen category-semantic modules match the dev.12 baseline; no player category or saved-rule migrations were introduced.

[VERIFIED SOURCE] Exact active Mod IDs `Quartermaster` and `BetterSortCC` reject B47 startup and actions before authority handlers register when known at startup. The client picker reports the conflict. Old saved data alone does not trigger rejection. Installed original Quartermaster `mod.info` confirms ID `Quartermaster`; Better Sorting ID `BetterSortCC` comes from the historical source audit. Better Containers is not automatically excluded. See [compatibility audit](../dist/handoffs/dev13-category-compatibility-audit.md).

[VERIFIED SOURCE] The selected valid physical container receives one local-player outline through B42's IsoObject outline API. Switching selection/mode, closing, invalidating a target or refreshing away a target clears the owned outline. Already-highlighted objects are not claimed; prior attached-outline state is restored. Native visual behavior remains untested.

[VERIFIED SOURCE] Catalog preparation remains bounded per update and now reuses its session index for fully covered observed items on repeated target opens. Generation, hit/miss, fallback, classified-item and elapsed-time diagnostics are exposed. Font-derived minimum picker size, rail row height and conditional visible-bulk buttons address scaling. There is no measured in-game latency claim.

[TESTED offline] Lua 5.1 regression covers exact-ID startup/action rejection, saved-data non-conflict, outline selection/cleanup, repeated-open catalog reuse and enlarged-font geometry. Full build/package and final artifact results are recorded in the dev.13 validation section below. Offline fixtures do not prove native rendering or dedicated authority.

[RUNTIME GATE] SP, listen, dedicated two-client and 1080p/1440p/2160p UI acceptance are NOT TESTED. G7 BLOCKED / NOT TESTED; G8 BLOCKED. Native server `getActivatedMods()` availability, outline coexistence and Better Containers non-category interaction require runtime evidence. No PZ/server launch, live deployment or Workshop publication was performed.

### dev.13 validation

Run `tests/run_tests.py`, `Build.ps1`, and `scripts/check_versions.py --root . --release` with the bundled Python from the project root. See `dist/handoffs/dev13-build.txt` and `dist/handoffs/dev13-ux-performance-review.md` for exact results and package hash after build.

### dev.13 local deployment and publication attempt — 2026-10-05

[VERIFIED DEPLOYMENT] At the user's explicit request, `powershell -NoProfile -ExecutionPolicy Bypass -File ./Deploy-Test.ps1` passed. The 112 source/package/stage/local files match byte-for-byte; live test install is `C:/Users/willi/Zomboid/mods/B47ANCEDQuartermaster`, Workshop stage is `C:/Users/willi/Zomboid/Workshop/B47ANCEDQuartermaster`, and prior subscribed canonical copy was preserved in `dist/local-test-deployments/20261005-175829/`. Project Zomboid was closed and not launched. Log: `dist/handoffs/dev13-deployment.txt`.

[VERIFIED STAGING] Workshop description/change note were refreshed for dev.13. `Build-Workshop.ps1` and exact source/package/stage/local parity passed; upload VDF targets item 3807217050 under the previously selected account `[private publisher account]`, with no visibility override. Log: `dist/handoffs/dev13-workshop-stage.txt`.

[BLOCKED UPLOAD] Initial noninteractive SteamCMD upload reported no cached credentials and invalid password. A visible interactive login was opened for the user, but a second SteamCMD invocation still found no cache and revoked that interactive session. No `Committing update...Success` or `Upload finished ... OK` evidence exists for dev.13. Publication remains unconfirmed pending a successful authenticated retry. Logs: `dist/handoffs/dev13-steamcmd-upload.txt` and `dev13-steamcmd-upload-retry.txt`. Deployment/publication does not satisfy native G7/G8.

## Previous implementation — 0.4.0-dev.12, final taxonomy freeze

[VERIFIED SOURCE] Canonical version 0.4.0-dev.12; taxonomy protocol 4 → 5 due peer-visible physical IDs and routing memberships; configuration schema 2 and world root 1 unchanged. This is a compatible development MINOR refinement of 0.4.0, with exact saved-rule preservation. 83 → 80 physical categories; 80 → 77 populated vanilla rows; 13 → 24 compatibility-only narrow IDs; 119 supported IDs. New MedicalSupplies and CampingSupplies are practical union destinations; MedicalMedicine remains Medicine. HouseholdOther, MaterialsOther, ToolsGeneral, FoodOther, FoodShelfStable and MeleeOther receive replacement physical IDs solely to preserve immutable historical scope through item corrections. All 24 old IDs retain their exact dev.11 memberships. See [complete final review](../dist/handoffs/dev12-final-taxonomy-review.md) and [pre-change exact-member review](../dist/handoffs/dev12-pre-change-review.md).

[VERIFIED SOURCE] Exactly eight intentional semantic corrections: Base.Calculator → ElectricalOther; Base.Buckle → MaterialsFasteners; Base.CompassGeometry → Stationery; Base.GlassBlowingPipe → ToolsGeneral; Base.Paintbrush and Base.PaintbrushCrafted → MaterialsPaint; Base.WaterRationCan and Base.WaterRationCan_Box → BeveragesWater. Their historical narrow memberships remain in the old rule only. Current physical > historical narrow > broad compatibility, with explicit Item highest. The server still classifies real ScriptItems; no client claims authorize routing. ClassifyToolsByUse remains server sandbox-controlled. No new gameplay settings are warranted for static semantic bug fixes or category metadata.

[VERIFIED STATIC B42.21] 5,105 declarations, 5,092 unique FullTypes, 13 duplicate declarations, 430 physical changes from dev.11 and exactly eight intended semantic changes. Misc 34; 4,948 catalog eligible and 144 excluded. Three supported empty categories remain hidden until populated or selected: FirearmsOther, MeleeAxes, OutdoorOther. Read-only third-party script samples: Tactical Weapons 14 unique/14 declarations/0 duplicate, 0 physical/0 semantic changes, Misc 0; Authentic Z - Backpacks+ 274/277/3, 59 physical/0 semantic changes, Misc 26; WildFruits 5/5/0, 0 physical/0 semantic changes, Misc 0. No third-party classifier, mapping, assets or code copied/executed.

[TESTED offline] Focused category and migration fixtures, full Lua 5.1 regression, static source audit, 29-language key parity, native JAR/source inspection and source/package/version parity are run for this candidate as recorded in the final validation block below. Offline evidence is not PZ runtime evidence.

[RUNTIME GATE] SP UNTESTED; listen server UNTESTED; dedicated server plus two clients UNTESTED. G7 BLOCKED / NOT TESTED. G8 BLOCKED. No native game/server launch, installed-mod deployment, Workshop staging/upload or publication was authorized for this pass. Player-facing taxonomy status: **FEATURE FROZEN PENDING NATIVE ACCEPTANCE**. Reopen for concrete native misclassification, migration, mod compatibility, demonstrably bad category, or new PZ build evidence only.

Package and exact command results: see **dev.12 final validation** below.

## dev.12 final validation

[TESTED offline] Exact commands run from the project root (Python at `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`):

```
python dist/handoffs/dev12-focused-tests.py
python tests/audit_categories.py --mod "E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2324223029/mods/Tactical Weapons/42" --mod "E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2335368829/mods/Authentic Z - Backpacks+/42" --mod "E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2618566294/mods/WildFruits/42"
python tests/audit_taxonomy_native.py
python tests/audit_shopping_native.py
python tests/audit_ui_native.py
powershell -NoProfile -ExecutionPolicy Bypass -File ./Build.ps1
python scripts/check_versions.py --root . --release
```

`Build.ps1` ran `tests/run_tests.py --package`, `scripts/check_deployment.py --package`, `tests/test_deployment.py`, and the release artifact version check. Focused, full regression, Lua 5.1 syntax, 29 locales, static source audit, upstream-hash guard, package parity, rejection fixtures and version gates passed. Native JAR/source inspection is read-only API evidence, not gameplay execution. Logs: `dist/handoffs/dev12-build.txt`, `dev12-category-audit.txt`, and three `dev12-*-source-audit.json` files. The historical dev.11 snapshot/ZIP hashes remain unchanged.

[TESTED offline] Package: `dist/current/B47ANCEDQuartermaster-0.4.0-dev.12.zip`; 110 runtime files plus 5 empty directories; SHA-256 `8e3168142de10645ceb7b028c199977bdabec4f4bb8ef9543acf9687e9fab1ee`. Frozen dev.11 ZIP in `dist/history/0.4.0-dev.11/` retains SHA-256 `ea8ec7594f7131e24b8fb6753b0098d22155539661ec49c00cb12573691624f1`. No deployment, Workshop upload or native PZ launch occurred.

[RUNTIME GATE] SP UNTESTED; listen server UNTESTED; dedicated server + two clients UNTESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No other taxonomy defect remains known from offline review. **FEATURE FROZEN PENDING NATIVE ACCEPTANCE**.

## Previous implementation — 0.4.0-dev.11, player-facing taxonomy consolidation

### CHANGED

[VERIFIED SOURCE] Completed the bounded consolidation of dev.10's existing taxonomy. Project version **0.4.0-dev.10 -> 0.4.0-dev.11**: compatible MINOR functionality within the developing 0.4.0 prerelease line. Taxonomy protocol **3 -> 4** because peer-visible category membership/ranking changes; configuration schema **2** and world root **1** remain unchanged. All **105** prior stable IDs remain known, with **6** additive union IDs: **111** supported IDs, **83** physical destinations, **13** compatibility-only former physical IDs. Original broad IDs remain supported, including Misc's dual role.

Reviewed every one of the 90 dev.10 physical categories for storage purpose, eligible counts, family/semantic identity, plausibility, mod expansion potential, nearest sibling and decision. [Complete 90-category review](../dist/handoffs/dev11-taxonomy-consolidation.md) / [structured review](../dist/handoffs/dev11-taxonomy-consolidation.json). **90 -> 83** supported physical categories; **87 -> 80** populated default vanilla picker rows. Thirteen old destinations are removed from normal selection; six current destinations replace their unions, a net reduction of seven. Three supported empty fallback rows remain conditionally hidden. This is not an arbitrary count quota: useful weapon, medical, material and workstation distinctions remain intact.

Every consolidation and compatibility scope:

| Former physical ID | Current physical destination | Old saved-rule meaning |
| --- | --- | --- |
| B47_AnimalSupplies | B47_OutdoorFarmingSupplies | Only the original dev.10 Animal Supplies semantic membership; never the union. |
| B47_BeveragesOther | B47_BeveragesNonAlcoholic | Only the original dev.10 Other beverages semantic membership; never the union. |
| B47_BeveragesWater | B47_BeveragesNonAlcoholic | Only the original dev.10 Water semantic membership; never the union. |
| B47_ClothingEyes | B47_ClothingHeadwear | Only the original dev.10 Eyewear semantic membership; never the union. |
| B47_ClothingFace | B47_ClothingHeadwear | Only the original dev.10 Face coverings semantic membership; never the union. |
| B47_ClothingHead | B47_ClothingHeadwear | Only the original dev.10 Headwear semantic membership; never the union. |
| B47_ClothingSocks | B47_ClothingUnderlayers | Only the original dev.10 Socks semantic membership; never the union. |
| B47_ClothingUnderwear | B47_ClothingUnderlayers | Only the original dev.10 Underwear semantic membership; never the union. |
| B47_ElectricalComponents | B47_ElectricalSupplies | Only the original dev.10 Electrical components semantic membership; never the union. |
| B47_ElectricalPower | B47_ElectricalSupplies | Only the original dev.10 Portable power supplies semantic membership; never the union. |
| B47_OutdoorFarming | B47_OutdoorFarmingSupplies | Only the original dev.10 Farming and gardening supplies semantic membership; never the union. |
| B47_VehicleBatteries | B47_VehicleParts | Only the original dev.10 Vehicle batteries semantic membership; never the union. |
| B47_VehicleOther | B47_VehicleParts | Only the original dev.10 Other vehicle parts semantic membership; never the union. |

Current destination labels: **Farming & Gardening Supplies**, **Electrical Parts & Supplies**, **General Vehicle Parts**, **Headwear & Facewear**, **Underwear & Socks**, **Non-alcoholic Drinks**. New IDs are necessary because reusing either old narrow ID would change saved-rule intent. In particular, even old OutdoorFarming and VehicleOther rules remain narrow rather than silently gaining animal supplies/batteries. Complete electronics stay out of Electrical Supplies; vehicle tires remain separate. Instruments, Smoking, Recreation, Stationery, Alcohol and Notes remain dedicated destinations.

**Semantic-purpose architecture:** the dev.10 detector and StorageSemantics module preserve every previous semantic result. One explicit destination map in Taxonomy.lua maps semantic IDs to physical IDs; this is not a second classifier. `resolve` preserves its first three return meanings (current category/reason/original broad identity) and adds semantic purpose as a fourth return. `semantic` exposes that purpose for diagnostics/tests. Shared server Catalog routing independently resolves real ScriptItems; no client category controls routing.

**Router order:** explicit Item **4** > current exact physical **3** > historical narrow semantic ID **2** > broad compatibility family **1**, then unchanged fill priority/distance/tie-break. Broad coverage uses original semantic parents plus the original broad resolver; it is never the union of all parents of a merged physical group. Thus old Materials rules still include electrical components and do not gain batteries. Existing caches still key by ScriptItem and authoritative ClassifyToolsByUse policy. No movement executor, authority storage, Shopping/Dibs or unrelated framework changes.

**Visibility:** current catalog categories are populated physical destinations only. Existing Model.new adds selected persisted IDs, including empty/legacy rules, back to the tree. Alias groups expose only their narrow matching items; compatibility handling prevents normalization from creating obsolete IDs in new configurations. A legacy electrical Power row is inspectable/editable and marks only the battery subset in the consolidated group. Empty FirearmsOther/OutdoorOther/MeleeAxes remain available when populated or selected. Axes populate naturally with ClassifyToolsByUse=false. Existing category/mod/item search, Only Checked/Only Contents, state/count and visible bulk behavior remain unchanged; no UI redesign. Visibility builds on the existing catalog/model behavior rather than adding a new filter engine.

### CONSOLIDATION — small and empty categories

Recorded Media is **KEEP**: three VHS/CD script prototypes represent many distinct recorded titles; a tape/CD collection is a natural storage destination. It is not equivalent to three physical media objects. Sports/Recreation is not folded into Media. Medical subcategories, weapon/ammo, tires, fishing/trapping/fire supplies, maps and workstation/material distinctions remain useful. Every category with fewer than ten vanilla identities:

- **B47_AmmoLoose (9): KEEP** — Loose rounds are an obvious ammo storage concept distinct from loaded magazines or unopened boxes; strong firearm-mod expansion.
- **B47_AmmoMagazines (6): KEEP** — Reusable firearm magazines/clip supplies deserve a ready-magazine bin; modded firearms expand the six vanilla definitions.
- **B47_AnimalSupplies (2): MERGE** — Leash/water dish share animal-husbandry/farm supply storage; two identities do not justify a separate destination.
- **B47_BeveragesWater (2): MERGE** — Water and ordinary non-alcoholic drinks share drink storage; water-only rules remain narrow rather than becoming all drinks.
- **B47_ClothingSocks (7): MERGE** — Socks do not need a separate seven-identity destination alongside underwear; preserve sock-only saved rules.
- **B47_ElectricalComponents (3): MERGE** — Loose wire/electronics salvage and portable batteries share an electrical supply box; a new ID preserves old component-only rules.
- **B47_ElectricalPower (2): MERGE** — Portable cells/boxed cells share electrical supply storage; old battery-only scope stays separate from components and devices.
- **B47_FirearmsOther (0): CONDITIONAL/HIDDEN** — Useful mod-extensible ranged-weapon fallback when metadata does not identify handgun/long gun/shotgun; hide until eligible content or a saved rule exists.
- **B47_Handguns (6): KEEP** — Handgun lockers are a natural weapon concept with substantial mod expansion; six script identities are not evidence to merge.
- **B47_LongGuns (9): KEEP** — Long-gun racks are practical and heavily mod-extensible; nine native definitions justify no automatic merger.
- **B47_MaterialsFasteners (6): KEEP** — Nails/screws/boxes and verified sewing fasteners belong in a hardware supply box; six definitions represent many usable units.
- **B47_Media (3): KEEP** — Three shared VHS/CD ScriptItem prototypes represent many distinct recordings/titles; players plausibly keep tape/CD collections together. KEEP Recorded Media without pulling sporting equipment into it.
- **B47_MedicalBandages (7): KEEP** — Dressings are immediate first-aid consumables with distinct storage/use from medicine and reusable tools; keep seven definitions.
- **B47_MedicalTools (7): KEEP** — Reusable first-aid/surgical tools belong in a medical instrument kit separately from dressings/drugs; keep seven definitions.
- **B47_MeleeAxes (0): CONDITIONAL/HIDDEN** — Axes are a natural weapon/tool storage concept; default tool policy moves vanilla axes to Cutting Tools. Keep physical support and show when populated under false policy or selected.
- **B47_OutdoorFire (9): KEEP** — Lighters/matches/fire-starting supplies form a practical emergency/fire-making kit; distinct from camping gear and generic material fuel.
- **B47_OutdoorOther (0): CONDITIONAL/HIDDEN** — Unknown survival equipment needs a safe residual fallback; hide unless actual eligible content or a persisted rule makes it relevant.
- **B47_OutdoorTrapping (6): KEEP** — Traps/baits are a distinct activity supply stash; six definitions remain useful and mod-extensible.
- **B47_Shotguns (5): KEEP** — Shotgun racks are a natural weapon/ammunition distinction; keep despite five vanilla identities and allow mod expansion.
- **B47_ToolsMechanics (7): KEEP** — Vehicle-repair tools belong at a mechanics workstation, separately from spare parts; seven definitions and mod expansion support KEEP.
- **B47_VehicleBatteries (3): MERGE** — Three car battery classes normally share spare-part shelving. Tires remain separately useful; battery-only saved rules remain exact.
- **B47_VehicleTires (9): KEEP** — Bulky spare tires are naturally stored separately from general vehicle parts; three vehicle classes and mod content expand nine identities.

The linked review additionally covers every 10–20 member category individually, including rare tools, instruments, smoking, maps, radios, care/cleaning and household residuals. Mod expansion potential is labelled inference, not installed-mod certification. Generic residuals remain useful where genuine purpose is uncertain, rather than being merged into confidently wrong categories.

### FULL REGISTRY AUDIT — [TESTED OFFLINE]

Same installed Build 42.21 static source baseline: **5,105 declarations**, **5,092 unique FullTypes**, **13 duplicate declarations**, **0** invalid/unreadable definitions. **624 changed physical destinations / 4,468 unchanged; zero semantic changes** against the frozen dev.10 resolver and audit. Misc remains **34**. Default catalog remains **4,948 eligible / 144 excluded**, with exactly unchanged exclusion decisions. All 75 documented semantic exceptions and 27 bounded Base family selectors are retained; no third-party categorizer/database is incorporated.

[CATEGORY_AUDIT.json](CATEGORY_AUDIT.json) retains semantic purpose, final physical category, original broad/family membership, applicable legacy specific ID, eligibility, reason, dev.10 physical category and changed flag for every identity. All thirteen legacy narrow rules and every original broad-family coverage set are checked against dev.10 **for every row**, including all mod samples. Source hashes and frozen baseline fingerprint are embedded. [Complete item review](../dist/handoffs/dev11-category-review.md) lists changed members, exclusions, competing purpose rules, exceptions and remaining semantic uncertainties.

Every current physical category count is in [the 83-category table](../dist/handoffs/dev11-taxonomy-consolidation.md#full-vanilla-audit); counts include excluded representations so all 5,092 identities remain accounted for. No static definition-order result is asserted to be the final native loaded registry.

Read-only mod samples (no third-party Lua/classifiers run):

| Sample | Unique | Declarations | Physical destination changes | Semantic changes |
| --- | ---: | ---: | ---: | ---: |
| E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\2324223029\mods\Tactical Weapons\42 | 14 | 14 | 0 | 0 |
| E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\2335368829\mods\Authentic Z - Backpacks+\42 | 274 | 277 | 6 | 0 |
| E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\2618566294\mods\WildFruits\42 | 5 | 5 | 0 | 0 |

Authentic Z's six merged entries now use Headwear & Facewear while their exact prior semantic IDs and saved rules remain unchanged. There is no per-mod override database, dependency or runtime classifier. Mod load order/ownership and native generated records remain runtime gates.

### MIGRATION / AUTHORITY / CONFIGURATION

[TESTED OFFLINE] All thirteen old IDs retain exactly their narrow scope; new physical IDs never replace old cats keys during loading or migration. Migration 0/1/2/3/4 is a copy and idempotent; existing schema/world data stays intact. New envelopes write taxonomy 4. Missing/old peer write metadata, including dev.10 protocol 3, is rejected by existing dynamic authority checks; old server discovery is rejected by Session. Native multiplayer enforcement is untested. Configuration, shared presets and category rules remain server-owned; local presentation cannot broaden authoritative saved rules.

No new gameplay sandbox option is justified for this deterministic category presentation/membership pass. Existing authoritative ClassifyToolsByUse retains both policies. UI visibility is local presentation; protocol/version/cache internals are implementation details. All 29 locale tables append six canonical destination labels while preserving every dev.10 key/value and all legacy labels. English fallback is used consistently.

### VALIDATED — actual exact commands

PowerShell from the project directory; `$python` is `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`, with isolated `.test-deps` Lua 5.1/jawa dependencies:

```powershell
& $python scripts/check_versions.py --root . --release # pre-edit dev.10
& $python dist/handoffs/dev11-focused-tests.py
& $python tests/audit_categories.py --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2324223029/mods/Tactical Weapons/42' --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2335368829/mods/Authentic Z - Backpacks+/42' --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2618566294/mods/WildFruits/42'
& $python scripts/report_taxonomy_consolidation.py
& $python tests/run_tests.py
& $python tests/audit_taxonomy_native.py
& $python tests/audit_shopping_native.py
& $python tests/audit_ui_native.py
./Build.ps1
# Build.ps1 invokes:
& $python scripts/check_versions.py --root .
& $python tests/run_tests.py --package
& $python scripts/check_deployment.py --package
& $python tests/test_deployment.py
& $python scripts/check_versions.py --root . --release
& $python dist/handoffs/verify-dev11-artifacts.py
```

[TESTED OFFLINE] Focused consolidation plus all dev.10 semantic correction/taxonomy/migration tests PASS. Complete regression suite: routing, persistence, authority/session mocks, presets, category/mod/item state/search/filters/count/visible operations, Dibs, Shopping/Wish/Cook and native-shaped movement/executor cases PASS. Both tool policies, 83 physical synthetic expected cases, legacy/empty selected row editing, alias partial state, populated mod fallback visibility and explicit/current/historical/broad ranking PASS. JSON localization key/value parity, Lua syntax, standalone manifest/source guards, source/package SHA parity, version inventory and `--release` PASS. Deployment test `source + local` output refers only to temporary fixtures; no live deployment occurred.

[VERIFIED SOURCE] Installed native API audits PASS read-only; same Build 42.21 JAR/component/writing/shelf-life methods as dev.10, no new engine API introduced. Evidence: `dist/handoffs/dev11-focused-tests.txt`, `dev11-regressions.txt`, `dev11-build.txt`, `dev11-category-audit.txt`, `dev11-taxonomy-native-source-audit.json`, `dev11-native-source-audit.json`, `dev11-ui-native-source-audit.json`. These are source inspection/offline Lua evidence, not PZ/Kahlua/transport execution.

### UNTESTED / BLOCKED / DEFERRED

[RUNTIME GATE] SP **UNTESTED**, listen **UNTESTED**, dedicated **UNTESTED**. **G7 BLOCKED / NOT TESTED; G8 BLOCKED.** No PZ or server launch, staging, deployment or publication authorized/performed. Version `--release` PASS is consistency only and does not prove G8 readiness. No source authority blocker was discovered; native execution remains unproven.

Required native validation: compare loaded server/client registry and semantic/physical memberships under both tool policies; exercise all six current destinations and old thirteen specific rules; confirm no old rule broadens; reload saves/presets and verify ranks/current/legacy UI counts and editing; test real installed populated fallbacks, selected empty rows and controller/search/filter actions; route representative items; validate intentional protocol 3/4 mismatch rejection, dedicated clients, late join/reconnect/restart. Re-test Dibs/Shopping with the current catalog.

DEFERRED: dev.10 semantic judgement calls (sports/weapon boundary, occult game collectibles, production vessels, raw/finished stock, unknown writable mod metadata, unproven internal obtainability) remain as documented in the item review. No instance refill classification, speculative item-name rule, media/recreation merger, UI redesign or movement refactor. Keep useful tool/material/medical/weapon distinctions instead of merging to reach an arbitrary count. Native loaded-mod ownership and generated-title variety are not fully certified by static scripts.

### PACKAGE — development testing only

Exact ZIP: `C:\Users\willi\Desktop\Repositories\Project Zomboid\Quartermaster - Balanced Sorting\dist\current\B47ANCEDQuartermaster-0.4.0-dev.11.zip`

SHA-256: `ea8ec7594f7131e24b8fb6753b0098d22155539661ec49c00cb12573691624f1`

**0.4.0-dev.11; 110 runtime files + 5 empty directories**. Clean manifest/source/package parity PASS. Dev.10 package and companion checksum archived immutably under `dist/history/0.4.0-dev.10/`, SHA-256 `576a50467d0fa6dca43436ba966d4baf1390e0bca84da757f90f336303dbc688`. Dev.10 source/audit/status are frozen in `dist/handoffs/taxonomy-dev10-baseline/`. Nothing deployed or published.

### Exact files changed from dev.10 source inventory

- `CHANGELOG.md`
- `README.md`
- `VERSION`
- `WORKSHOP_CHANGE_NOTE.txt`
- `WORKSHOP_DESCRIPTION.txt`
- `docs/ARCHITECTURE.md`
- `docs/CATEGORY_AUDIT.json`
- `docs/MASTER_HANDOFF_STATUS.md`
- `docs/MULTI_CONTAINER_UI_IMPLEMENTATION.md`
- `docs/RENAME_MIGRATION.md`
- `docs/ROADMAP.md`
- `docs/TESTING.md`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Catalog.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Categorizer.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Identity.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Schema.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Taxonomy.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/AR/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/CA/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/CH/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/CN/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/CS/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/DA/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/DE/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/EN/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/ES/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/ES_CL/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/ES_MX/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/FI/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/FR/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/HU/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/ID/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/IT/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/JP/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/KO/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/NL/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/NO/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/PL/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/PT/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/PTBR/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/RO/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/RU/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/STREW/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/TH/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/TR/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/UA/UI.json`
- `src/B47ANCEDQuartermaster/42/mod.info`
- `tests/audit_categories.py`
- `tests/run_tests.py`
- `tests/test_categorizer.lua`
- `tests/test_presets.lua`
- `tests/test_standalone_authority.lua`
- `tests/test_taxonomy.lua`
- `tests/test_taxonomy_correction.lua`
- `version-inventory.json`

Added implementation-support/test files:

- `scripts/report_taxonomy_consolidation.py`
- `tests/test_taxonomy_consolidation.lua`

Generated consolidation/audit/log/package artifacts are listed above. All previous status evidence below remains verbatim.

## Previous implementation — 0.4.0-dev.10, full taxonomy correction

### CHANGED — compatible correction and five additive categories

[VERIFIED SOURCE] Completed the requested dev.9 correction pass in the existing owned resolver/catalog. Canonical version **0.4.0-dev.9 -> 0.4.0-dev.10**: compatible PATCH corrections plus additive MINOR functionality within the already developing 0.4.0 line. Taxonomy protocol **2 -> 3** prevents old/new peer category disagreement; configuration schema **2**, world root **1**, all **100** prior category/family IDs and all **18** original broad-rule identities remain supported. There are now **90 physical categories / 105 supported IDs**. Misc retains its existing dual physical/compatibility role. No movement, UI hierarchy, persistence ownership, Shopping or Dibs redesign.

Five new physical categories:

| ID | Label | Vanilla script identities |
| --- | --- | ---: |
| B47_Instruments | Instruments | 15 |
| B47_Smoking | Smoking & Tobacco | 15 |
| B47_Recreation | Sports & Recreation | 38 |
| B47_Stationery | Stationery & Office Supplies | 23 |
| B47_AnimalSupplies | Animal Supplies | 2 |

The first four also belong to the existing Household compatibility family; Animal Supplies belongs to Outdoor. No family ID is repurposed or removed. The original owned dev.8 broad resolver remains unchanged so original broad sorting rules preserve their coverage even when physical categories are corrected.

**Resolver precedence:** preserve explicit item routing > specific physical category rule > broad family rule. The classifier checks bounded FullType exceptions, then protected weapon-part/key identity; stable purpose rules run before incidental generic tool/weapon/food/memento fallback. Clothing/body-location identity stays protected. General firearm, medical, tool discipline, survival, container, literature, material and food metadata rules retain their established order. Functional camera/instrument/care/material purpose wins over memento fallback. Neither localized display names nor current contents/condition/rot affect storage identity. `ClassifyToolsByUse` remains an authoritative sandbox option; weapon-tools respect both values. Classification is cached by ScriptItem and tool policy, including exact exceptions. Developer competing-rule inspection does not run in rendering/routing.

`StorageSemantics.lua` adds original stable native tag/category/component rules plus 27 bounded Base identity-family selectors, each metadata-gated. The review artifact lists every selector, gate and matched FullType. There are **75 explicit FullType exceptions**, including the prior nine; **74** exist in this installed registry. `Base.PaperNapkins` is a user-locked compatibility identity absent from the installed vanilla scripts; `Base.PaperNapkins2` is present. Every exception has a documented reason. This is not an imported or exhaustive FullType database. No Better Sorting code, definitions, table, text or assets are used, loaded or copied.

**Catalog only:** native Hidden/Obsolete and DisplayCategory Hidden are ineligible by metadata; verified Base clothing Wound/ZedDmg definitions are damage representations; four exact development identities are ineligible. The static registry has 0 native Hidden/Obsolete skips, **134** body-damage representations, **6** display-hidden definitions and **4** exact development definitions: **144** exclusions, **4,948** eligible default picker identities. Classification/routing still resolves excluded identities if actually observed; saved explicit rules are retained. No item is removed from the game. Unknown internal-looking names, foreign definitions, carriable corpses and `TestWaterMug` are not hidden by speculation.

**Migration/localization:** taxonomy versions 0/1/2/3 load by copying existing IDs/rules; schema remains 2, no automatic save mutation on opening UI. Current envelopes use taxonomy 3. Existing server/session/binding checks use the shared resolver version, so incompatible peer discovery/writes remain rejected instead of accepting client classifications. All 29 `UI.json` locales append exactly the five new label keys, with English fallback; existing keys/values/formatting are preserved. No new meaningful gameplay setting is required: this is deterministic taxonomy correction, not configurable shared state. Fluid list cap 64 is an internal defensive bound, not a gameplay option.

### FULL REGISTRY AUDIT — [TESTED OFFLINE, static vanilla scripts + owned Lua 5.1]

**5,105** declarations inspected; **5,092** unique FullTypes; **13** duplicate declarations, **0** unreadable/invalid definitions. Each current row is compared to the frozen dev.9 resolver and its saved audit row. **361 changed / 4,731 unchanged**. Misc **114 -> 34**, reduction **80**. Counts include excluded catalog representations so all 5,092 remain traceable. This is static script evidence, not native final load-order/registry certification.

[CATEGORY_AUDIT.json](CATEGORY_AUDIT.json) records every FullType, declared type/category/tags/body location, relevant stable metadata, prior/current result, change reason, broad-family compatibility, catalog eligibility/exclusion and competing purpose/structural rules. [Complete item review](../dist/handoffs/dev10-category-review.md) lists all changes, exclusions, competing rules, new-category members, all 75 exceptions, all family selectors/matches and every broad residual member. Competing rules include expected fallback alternatives; they do not imply every flagged item has unresolved classification.

All 90 physical category counts (default `ClassifyToolsByUse=true`):

| ID | Label | Full registry | Default picker eligible |
| --- | --- | ---: | ---: |
| B47_AmmoBoxes | Ammunition boxes and cases | 38 | 38 |
| B47_AmmoLoose | Loose ammunition | 9 | 9 |
| B47_AmmoMagazines | Firearm magazines | 6 | 6 |
| B47_AnimalSupplies | Animal Supplies | 2 | 2 |
| B47_BeveragesAlcohol | Alcoholic drinks | 27 | 27 |
| B47_BeveragesOther | Other beverages | 38 | 38 |
| B47_BeveragesWater | Water | 2 | 2 |
| B47_ClothingAccessories | Accessories | 103 | 103 |
| B47_ClothingBottoms | Pants and skirts | 138 | 138 |
| B47_ClothingEyes | Eyewear | 42 | 42 |
| B47_ClothingFace | Face coverings | 15 | 15 |
| B47_ClothingFootwear | Shoes and boots | 33 | 33 |
| B47_ClothingGloves | Gloves | 20 | 20 |
| B47_ClothingHead | Headwear | 175 | 175 |
| B47_ClothingOther | Other clothing | 324 | 190 |
| B47_ClothingOuterwear | Jackets and outerwear | 65 | 65 |
| B47_ClothingProtective | Protective clothing | 290 | 290 |
| B47_ClothingSocks | Socks | 7 | 7 |
| B47_ClothingTops | Shirts and tops | 145 | 145 |
| B47_ClothingUnderwear | Underwear | 64 | 64 |
| B47_ContainersBags | Bags | 97 | 97 |
| B47_ContainersFluid | Fluid containers | 32 | 32 |
| B47_ContainersOther | Other containers | 160 | 160 |
| B47_ElectricalComponents | Electrical components | 3 | 3 |
| B47_ElectricalOther | Other electronics | 45 | 45 |
| B47_ElectricalPower | Portable power supplies | 2 | 2 |
| B47_ElectricalRadios | Radios and communication | 17 | 17 |
| B47_FirearmsOther | Other firearms | 0 | 0 |
| B47_FoodOther | Other food | 32 | 32 |
| B47_FoodPerishable | Perishable food | 431 | 431 |
| B47_FoodSeasoning | Seasonings and condiments | 100 | 100 |
| B47_FoodShelfStable | Shelf-stable food | 136 | 136 |
| B47_Handguns | Handguns | 6 | 6 |
| B47_HouseholdCare | Personal care | 17 | 17 |
| B47_HouseholdCleaning | Cleaning supplies | 13 | 13 |
| B47_HouseholdFurnishings | Furnishings and moveables | 351 | 351 |
| B47_HouseholdKeepsakes | Keepsakes and collectibles | 93 | 93 |
| B47_HouseholdKeys | Keys and keyrings | 35 | 35 |
| B47_HouseholdKitchen | Kitchenware | 88 | 88 |
| B47_HouseholdOther | Other household goods | 13 | 13 |
| B47_Instruments | Instruments | 15 | 15 |
| B47_LiteratureMagazines | Printed magazines and newspapers | 71 | 71 |
| B47_LiteratureManuals | Recipe and instruction manuals | 94 | 94 |
| B47_LiteratureMaps | Maps | 15 | 15 |
| B47_LiteratureNotes | Notes and notebooks | 21 | 21 |
| B47_LiteratureOther | General books and literature | 150 | 150 |
| B47_LiteratureSkill | Skill books | 144 | 144 |
| B47_LongGuns | Rifles and other long guns | 9 | 9 |
| B47_MaterialsAnimal | Animal parts and by-products | 30 | 30 |
| B47_MaterialsBinding | Adhesives and binding materials | 21 | 21 |
| B47_MaterialsFasteners | Fasteners | 6 | 6 |
| B47_MaterialsMetal | Metalworking materials | 132 | 132 |
| B47_MaterialsOther | General crafting materials | 93 | 93 |
| B47_MaterialsPaint | Paint and finishing supplies | 16 | 16 |
| B47_MaterialsTextile | Textile and leather materials | 106 | 106 |
| B47_MaterialsWood | Wood materials | 21 | 21 |
| B47_Media | Recorded media | 3 | 3 |
| B47_MedicalBandages | Bandages and dressings | 7 | 7 |
| B47_MedicalMedicine | Medicines and medicinal herbs | 17 | 17 |
| B47_MedicalOther | Other medical supplies | 25 | 25 |
| B47_MedicalTools | Medical tools | 7 | 7 |
| B47_MeleeAxes | Axes | 0 | 0 |
| B47_MeleeBlades | Bladed weapons | 18 | 18 |
| B47_MeleeBlunt | Short blunt weapons | 61 | 60 |
| B47_MeleeLongBlunt | Long blunt weapons | 60 | 60 |
| B47_MeleeOther | Other melee weapons | 35 | 35 |
| B47_MeleeSpears | Spears | 27 | 27 |
| B47_Misc | Miscellaneous | 34 | 28 |
| B47_OutdoorCamping | Camping supplies | 46 | 46 |
| B47_OutdoorFarming | Farming and gardening supplies | 182 | 182 |
| B47_OutdoorFire | Fire-starting supplies | 9 | 9 |
| B47_OutdoorFishing | Fishing supplies | 20 | 19 |
| B47_OutdoorLighting | Lighting | 21 | 21 |
| B47_OutdoorOther | Other outdoor equipment | 0 | 0 |
| B47_OutdoorTrapping | Trapping supplies | 6 | 6 |
| B47_Recreation | Sports & Recreation | 38 | 38 |
| B47_Shotguns | Shotguns | 5 | 5 |
| B47_Smoking | Smoking & Tobacco | 15 | 15 |
| B47_Stationery | Stationery & Office Supplies | 23 | 23 |
| B47_ToolsCarpentry | Carpentry tools | 12 | 12 |
| B47_ToolsCutting | Cutting and forestry tools | 59 | 59 |
| B47_ToolsFarming | Farming tools | 23 | 23 |
| B47_ToolsGeneral | General tools | 27 | 25 |
| B47_ToolsMechanics | Mechanics tools | 7 | 7 |
| B47_ToolsMetal | Metalworking tools | 21 | 21 |
| B47_ToolsSewing | Sewing tools | 14 | 14 |
| B47_VehicleBatteries | Vehicle batteries | 3 | 3 |
| B47_VehicleOther | Other vehicle parts | 89 | 89 |
| B47_VehicleTires | Vehicle tires | 9 | 9 |
| B47_WeaponParts | Weapon parts | 11 | 11 |

Representative installed mod scripts were inspected read-only; no third-party Lua/classifier executed:

| Static source | Unique items | Declarations | Changes from dev.9 | Misc |
| --- | ---: | ---: | ---: | ---: |
| E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\2324223029\mods\Tactical Weapons\42 | 14 | 14 | 0 | 0 |
| E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\2335368829\mods\Authentic Z - Backpacks+\42 | 274 | 277 | 0 | 26 |
| E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\2618566294\mods\WildFruits\42 | 5 | 5 | 0 | 0 |

The mod sample has 293 unique identities, 296 declarations and three duplicate declarations (Authentic Z). There is no cross-mod name-family rewriting. Mod-specific balancing, runtime ownership and late-loaded modifications are not certified.

### IMPORTANT CLASSIFICATION CHANGES

- **Alcohol:** 27 identities use initial native script fluids and the verified boxed-wine opening recipe, alongside existing alcohol metadata. Beer, wine, whiskey, vodka, gin, rum, tequila, champagne, scotch, port, sherry and vermouth now reach Alcoholic Drinks. Constant drinkable mixtures containing alcohol remain alcoholic; unknown/undrinkable fluid options never create a drink classification.
- **Ordinary beverages:** 38 identities, including juices, milk/chocolate milk, pop/soda, reviewed canned fruit drinks/milk and existing hot drinks. Water remains Water. Grenadine, syrup and lemon juice remain ingredients. Native `EatType=CanDrink` is deliberately not a beverage signal: it also animates canned meals, jam, ice cream, oats and other foods; negative regression cases guard this distinction. Instance refilling does not change stable category identity.
- **Instruments:** 15 identities including playable instrument-weapons, harmonica, picks, tuning fork and whistles. Instrument purpose beats incidental melee/memento use. Broken instrument necks retain melee identity.
- **Smoking/tobacco:** 15 smoking products/materials, driven by verified smoking tags and narrowly reviewed untagged exceptions; no shelf-life/Tool leakage.
- **Recreation:** 38 balls, tees, darts, birdies, board/chess/game components, cards/dice/poker chips plus individually reviewed rackets, weights, paddles and bowling pin. No blanket SportsWeapon override. Bats, golf clubs, pool cues and hockey/lacrosse sticks retain their PZ melee identity; alternative storage expectations are documented below.
- **Stationery:** 23 writing utensils/office supplies; stapler/staples/hole punch/clipboard/paper clips and correction fluid use documented exceptions where metadata is insufficient. Writable documents remain Literature Notes.
- **Animal supplies:** coherent native Leash/WaterDish family confirmed (2); live animals are not supplies or animal materials.
- **Notes/notebooks:** 21 personal/writable documents. All 19 statically declared CanBeWrite definitions reach Notes; notes/handwritten letters add two. Native Item has no exposed writable getter, so bounded verified Base literature families provide this signal without Java field access/reflection. Skill books/manuals/maps/newspapers/printed magazines retain their own semantics.
- **Seed bags:** all 47 empty seed-packaging definitions now Farming through one bounded family rule before recipe-learning semantics; no 47-item override list.
- **Cameras:** all three camera devices and CameraFilm -> Other Electronics. Camera functional identity wins over Keepsakes, as locked by the user. Bullhorn is electronic; electric sheep shears keep Farming Tools.
- **Personal care:** cologne/perfume, comb/razor, toothpaste/toothbrush/soap plus existing hair products -> Personal Care. Wearable/body-location makeup representations remain Clothing. Soap2 is Personal Care; cleansing cloth states/products are Cleaning.
- **Cleaning/household paper:** bleach/cleaning liquid/steel wool and wet cloth/towels -> Cleaning; GrillBrush cleaning identity stays ahead of cooking identity. ToiletPaper and PaperNapkins/PaperNapkins2 -> Household Other as locked by the user.
- **Electrical components/power:** Wire/ElectricWire/ElectronicsScrap -> Components (3). Battery/BatteryBox -> Power (2). Vehicle batteries remain Vehicle Batteries; Generator remains Other Electronics; CarBatteryCharger is Mechanics Tools. No fictitious battery-pack family is invented.
- **Materials:** textile rolls/strips/flax/hemp/Dogbane/wool/yarn and tarp stocks -> Textile; copper sheets/metal stock/welding rods/meteorite raw input -> Metal; plank/log stacks/branches/twigs/firewood -> Wood; epoxy/fiberglass tape/tape boxes/rope/string -> Binding; buttons/beads and existing nails/screws boxes -> Fasteners. Finished clothing/wooden objects and complete tools do not become raw stock.
- **Specialized tools:** anvils/tongs/bellows/vises/heading tools -> Metalworking; thimble/fleshing tools -> Sewing; Jack/TirePump preserved and battery charger -> Mechanics; can openers/dedicated cooking tools -> Kitchenware. SheetMetalSnips stays Metalworking despite its can-opener capability; Multitool/Handiknife remain General Tools because multiple distinct disciplines apply. Molds do not become functional anvils/vises.
- **Animal materials:** all five fur tufts and genuine tanning/animal-part inputs -> Animal Parts & By-products. Wool and processed textile fibers use Textile. Live animals/care equipment/dummies remain distinct.
- **Keepsake precedence:** functional identities now win; generic supported memento metadata covers residual collectible plushies/specimens. Tarot/Ouja versus recreation remains a documented interpretation, not a hidden guess.
- **Internal/debug:** only verified metadata families and four exact development definitions are default-picker exclusions; unfamiliar names alone never justify exclusion.

### AMBIGUOUS — explicit human/runtime decision boundaries

- **Residual Misc cases:** Every current Misc identity is listed below with metadata. Live animals, carriable corpses, financial tokens, props, loose junk and empty waste stay residual; no speculative purpose/name rule. Obtaining and intended use of props/dummy identities requires runtime evidence.
- **Sports weapons:** Reviewed rackets, weights, paddles and bowling pin use Recreation; bats, golf clubs, pool cues, hockey/lacrosse sticks and broken instrument necks retain native melee purpose. Generic foreign SportsWeapon stays melee. Alternate player expectations need a human policy decision.
- **Collectible games:** Tarot/Ouja and collectible game objects with memento identity retain Keepsakes where no stronger recreation rule applies. Decide whether occult collectibles should become Recreation before extending that rule.
- **Fluid mixtures and ingredients:** Initial script fluids determine stable product purpose. Refilling, unknown mixtures and current fluid contents do not recategorize instances. Grenadine, syrup and lemon juice remain ingredients; condensed canned milk follows its reviewed drink family. Further ingredient/beverage distinctions require a human decision.
- **Writable/printed materials:** Verified vanilla writable families use bounded Base identity plus literature/display metadata because CanBeWrite has no exposed instance getter. Foreign writable books without exposed semantic metadata retain literature fallback; no arbitrary name guessing.
- **Containers versus production equipment:** Empty fired ceramic vessels/crucibles with native fluid components use Fluid Containers; unfired/cast definitions remain Materials Other. Whether foundry/glassworking vessels should instead be specialized tools needs a human decision.
- **Raw versus finished materials:** Wooden molds/casts and finished mixed objects remain Materials Other; fiber/fabric and fur inputs follow their verified identities. Buttons/beads used as fasteners use Fasteners. Do not classify every wooden finished object as raw wood.
- **Broad residual categories:** Complete MaterialsOther, ToolsGeneral, HouseholdOther, ClothingOther, FoodOther, ContainersOther, VehicleOther and LiteratureOther member lists follow. Calibration/ceramic/knapping tools, calculator/magnifier/fire extinguisher/umbrellas/rat poison, generic novels/resources, carrying bundles, mixed casts/glass/rubber/chemicals and undifferentiated vehicle parts lack a sufficiently specific supported semantic signal.
- **Internal-looking catalog entries:** Verified hidden/display-hidden, Base wound/zed-damage representations and four exact development definitions are excluded only from default catalog. Hair/beard/makeup and Book props, TestWaterMug, corpses, animal placeholders and unfamiliar foreign definitions remain available where evidence is insufficient. Native obtainability is untested.
- **Empty/small categories:** FirearmsOther, MeleeAxes with tool policy on and OutdoorOther are empty vanilla fallback categories; Water, AnimalSupplies, ElectricalComponents/Power, VehicleBatteries and recorded-media categories have few script identities. Generated titles/instance contents do not create new ScriptItem identities. Native mod ownership/load order and additional actual item definitions require runtime audit.

All 34 residual Misc cases (their metadata and competing-rule traces are in the linked review):

- `Base.Animal` — declared `Generic`, type `base:animal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Animal_Item_Dummy` — declared `Junk`, type `base:normal`; excluded from default picker by verified-development-definition.
- `Base.Bell` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.BookFancy_Prop` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Book_Prop` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Clitter` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Cork` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.CorpseFemale` — declared `Corpse`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.CorpseMale` — declared `Corpse`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.CreditCard` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.CreditCard_Stolen` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.DentedCan_Open` — declared `Hidden`, type `base:normal`; excluded from default picker by native-hidden-category.
- `Base.DogTag_Pet_Blank` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.DryerLint` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Frame` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Frog` — declared `Frog`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Money` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.MoneyBundle` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.MysteryCan_Open` — declared `Hidden`, type `base:normal`; excluded from default picker by native-hidden-category.
- `Base.Pinecone` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Pipe` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.PlasticTray` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Pop2Empty` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Pop3Empty` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.PopEmpty` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.RubberBand` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Splinters` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.Stairs` — declared `Hidden`, type `base:normal`; excluded from default picker by native-hidden-category.
- `Base.Straw2` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.TinCanEmpty` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.UnusableMetal` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.WaterDrop` — declared `Hidden`, type `base:normal`; excluded from default picker by native-hidden-category.
- `Base.WaterRationCanEmpty` — declared `Junk`, type `base:normal`; remains visible; no sufficiently specific supported storage-purpose signal.
- `Base.WaterRationCan_Open` — declared `Hidden`, type `base:normal`; excluded from default picker by native-hidden-category.

The complete broad residual lists are intentionally retained rather than forced into guessed destinations. Materials Other: mixed stone/clay/glass/chemicals/casts and finished production molds; Tools General: undifferentiated/multi-discipline equipment; Household Other: mixed domestic utility; Clothing Other: undifferentiated body slots/representations; Food Other: uncertain product/ingredient identity; Containers Other: undifferentiated carrying containers/bundles; Vehicle Other: general mechanical parts; Literature Other: generic printed resources/novels. These are review boundaries, not claims of universal semantic correctness.

### VALIDATED — exact commands and evidence environment

All commands below ran from the project directory. PowerShell `$python` denotes `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`; `lupa.lua51` and `jawa` are isolated under `.test-deps`. Commands are offline only.

```powershell
& $python scripts/check_versions.py --root .
& $python dist/handoffs/dev10-focused-tests.py
& $python tests/audit_categories.py --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2324223029/mods/Tactical Weapons/42' --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2335368829/mods/Authentic Z - Backpacks+/42' --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2618566294/mods/WildFruits/42'
& $python tests/audit_taxonomy_native.py
& $python tests/audit_shopping_native.py
& $python tests/audit_ui_native.py
./Build.ps1
# Build.ps1 actually invokes:
& $python scripts/check_versions.py --root .
& $python tests/run_tests.py --package
& $python scripts/check_deployment.py --package
& $python tests/test_deployment.py
& $python scripts/check_versions.py --root . --release
```

[TESTED OFFLINE] Focused resolver/taxonomy/correction/migration tests PASS; all 90 physical categories have synthetic expected-result cases; both tool policy values, item > specific > family precedence, legacy save/reload/idempotence, unknown taxonomy rejection and client/server mock parity PASS. Full regression suite including UI/search/visible operations, shopping, Wish, Dibs, movement/native-shaped executor and persistence mocks PASS. Retained six contamination gates plus requested families, all empty seed bags, all writable definitions and CanDrink non-beverage guards PASS. Source/package parity, production manifest, Lua syntax loading and all 29 JSON locale key parity PASS. Deployment parity test uses temporary fixtures only; its `source + local` PASS does not indicate a live deployment. Version `--release` PASS proves inventoried consistency only, not G8 acceptance.

[VERIFIED SOURCE] Installed `projectzomboid.jar` API/bytecode proves canonical ScriptItem component lookup, initial fluid list/type/percentage/random APIs, Lua-exposed component classes and non-spoiling shelf-life defaults (1,000,000,000). The writable Java field has no Lua instance getter, so production uses bounded source-verified families. Fluid/writing conclusions are not Kahlua execution proof. Installed Core bytecode is **42.21**; exact hashes and method signatures are in the native audit artifact. Native UI/Shopping API audits also PASS read-only. No third-party categorizer executes.

Evidence artifacts: `dist/handoffs/dev10-focused-tests.txt`, `dev10-category-audit.txt`, `dev10-build.txt`, `dev10-taxonomy-native-source-audit.json`, `dev10-native-source-audit.json`, `dev10-ui-native-source-audit.json`. Source fingerprints and all vanilla script hashes are embedded in CATEGORY_AUDIT.json. The frozen dev.9 source/audit/status/hashes remain in `dist/handoffs/taxonomy-dev9-baseline/`; dev.9 ZIP remains immutable under `dist/history/0.4.0-dev.9/`.

### UNTESTED / BLOCKED / DEFERRED

[RUNTIME GATE] Actual native ScriptItem/Kahlua classification, SP, listen server and dedicated MP have **NOT TESTED** status for dev.10. No PZ/server process was launched. G7 dedicated multiplayer **BLOCKED / NOT TESTED**; G8 **BLOCKED** pending runtime evidence. No version or offline test result overrides these gates. No source authority blocker is identified; runtime correctness remains unproven.

Required runtime acceptance: prepare the real catalog and invoke owned catalog diagnostics on every peer/server, test both tool settings, compare loaded registries and all specific/broad rule results, verify old saved rules and new IDs, inspect expanded Category -> Mod -> Item and all five new labels, exercise representative routing with explicit item overrides, late join/reconnect/restart and intentional mixed dev.9/dev.10 peer rejection. Re-test Shopping/Dibs and current item catalog filtering after actual observation. Dedicated evidence is mandatory before claiming multiplayer/release readiness.

DEFERRED: semantic decisions above, foreign writeable metadata without exposed getter, unproven internal obtainability, current-instance refill categorization, finer medical/food/recorded-media/caliber distinctions, unrelated UI/framework/movement work and Better Sorting integration. No unsupported native blocker is disguised as an offline PASS.

### PACKAGE — development testing only

`C:\Users\willi\Desktop\Repositories\Project Zomboid\Quartermaster - Balanced Sorting\dist\current\B47ANCEDQuartermaster-0.4.0-dev.10.zip`

Version **0.4.0-dev.10**, **110 files + 5 empty directories**. SHA-256: `576a50467d0fa6dca43436ba966d4baf1390e0bca84da757f90f336303dbc688`. Clean source/package parity PASS; no extra production files. Nothing deployed or published.

### Exact changed files from frozen dev.9 source inventory

- `CHANGELOG.md`
- `README.md`
- `VERSION`
- `WORKSHOP_CHANGE_NOTE.txt`
- `WORKSHOP_DESCRIPTION.txt`
- `docs/ARCHITECTURE.md`
- `docs/CATEGORY_AUDIT.json`
- `docs/MASTER_HANDOFF_STATUS.md`
- `docs/MULTI_CONTAINER_UI_IMPLEMENTATION.md`
- `docs/RENAME_MIGRATION.md`
- `docs/ROADMAP.md`
- `docs/TESTING.md`
- `scripts/production-files.json`
- `src/B47ANCEDQuartermaster/42/media/lua/client/B47ANCEDQuartermaster/ItemCatalog.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Catalog.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Categorizer.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Identity.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Schema.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Taxonomy.lua`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/AR/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/CA/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/CH/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/CN/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/CS/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/DA/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/DE/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/EN/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/ES/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/ES_CL/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/ES_MX/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/FI/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/FR/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/HU/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/ID/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/IT/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/JP/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/KO/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/NL/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/NO/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/PL/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/PT/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/PTBR/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/RO/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/RU/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/STREW/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/TH/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/TR/UI.json`
- `src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/UA/UI.json`
- `src/B47ANCEDQuartermaster/42/mod.info`
- `tests/audit_categories.py`
- `tests/audit_taxonomy_native.py`
- `tests/run_tests.py`
- `tests/test_presets.lua`
- `tests/test_standalone_authority.lua`
- `tests/test_taxonomy.lua`
- `version-inventory.json`

New implementation/test files:

- `src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/StorageSemantics.lua`
- `tests/test_taxonomy_correction.lua`

Generated local audit/report/log/package artifacts are listed above; old status history below is preserved verbatim.

## Previous implementation — 0.4.0-dev.9, expanded standalone storage taxonomy

Compatible MINOR feature expansion within the existing 0.4.0 prerelease line. Project version **0.4.0-dev.9**, taxonomyVersion **2**, configuration schema **2** and world root **1**. Current inventoried mirrors and testing package agree. Historical records retain their original versions and evidence.

### Completion record

**CHANGED:** Extended the existing owned Categorizer/Catalog into a deterministic 85-item-category taxonomy, with compatibility coverage for every original ID. Added native metadata interpretation, nine owned FullType exceptions, shared catalog/routing coverage, specific-rule precedence, guarded peer taxonomy compatibility and state-aware category/mod selection actions. Updated model normalization, persistence validation, all 29 locale tables, tests and current version mirrors. No UI redesign, upstream edits or Better Sorting integration.

**VALIDATED:** [TESTED OFFLINE, Python + Lua 5.1 host] Focused taxonomy/migration tests and complete existing regression suite PASS; syntax loading, localization parity, standalone guards, production manifest, source/package parity and version consistency PASS. [VERIFIED SOURCE] Installed native JAR APIs, resource identity serialization and constructor shelf-life defaults verified. These checks do not execute PZ rendering, Kahlua, native transfers or networking.

**UNTESTED:** Actual loaded registry classification, native SP/listen/dedicated behavior, peer parity, rendering/controller and actual routing across all categories. **BLOCKED:** Dedicated multiplayer G7 NOT TESTED/BLOCKED; release G8 BLOCKED. Version `--release` PASS proves consistency only. **DEFERRED:** Unsupported fine medical, ingredient/snack, recorded-media subtype, caliber and electrical-tool distinctions; UI reskin/framework extraction and unrelated features. No speculative English-name rules added.

**PREVIOUS CATEGORY COUNT:** 18 stable IDs. **NEW CATEGORY COUNT:** 100 supported stable IDs: 85 physical item categories and 16 compatibility families, with Miscellaneous serving both roles (85 + 16 - 1 = 100). There are 82 new IDs. Fifteen original categories were subdivided; WeaponParts and Media remain physical categories; Misc retains its physical fallback and old-rule compatibility. Alias rows remain visible when existing rules require them; no category-family level is inserted into the tree.

### New taxonomy / category IDs / category families / category counts

The table lists ALL final IDs and canonical English labels. Counts are the unique vanilla static-definition snapshot, under default ClassifyToolsByUse, not actual loaded-game counts. Zero means the category is supported/tested but this snapshot did not resolve an item there; it is not evidence of runtime absence. Family alias direct counts are zero because classification resolves physical categories. ElectricalComponents belongs to both Materials and Electrical for compatibility, while still having one physical category.

| Stable ID | Display name | Role / compatibility family | Vanilla direct count |
| --- | --- | --- | ---: |
| B47_Ammo | Ammunition | Compatibility alias | 0 |
| B47_AmmoBoxes | Ammunition boxes and cases | Item category; B47_Ammo | 38 |
| B47_AmmoLoose | Loose ammunition | Item category; B47_Ammo | 9 |
| B47_AmmoMagazines | Firearm magazines | Item category; B47_Ammo | 6 |
| B47_Beverages | Beverages | Compatibility alias | 0 |
| B47_BeveragesAlcohol | Alcoholic drinks | Item category; B47_Beverages | 0 |
| B47_BeveragesOther | Other beverages | Item category; B47_Beverages | 18 |
| B47_BeveragesWater | Water | Item category; B47_Beverages | 2 |
| B47_Clothing | Clothing and accessories | Compatibility alias | 0 |
| B47_ClothingAccessories | Accessories | Item category; B47_Clothing | 103 |
| B47_ClothingBottoms | Pants and skirts | Item category; B47_Clothing | 138 |
| B47_ClothingEyes | Eyewear | Item category; B47_Clothing | 42 |
| B47_ClothingFace | Face coverings | Item category; B47_Clothing | 15 |
| B47_ClothingFootwear | Shoes and boots | Item category; B47_Clothing | 33 |
| B47_ClothingGloves | Gloves | Item category; B47_Clothing | 20 |
| B47_ClothingHead | Headwear | Item category; B47_Clothing | 175 |
| B47_ClothingOther | Other clothing | Item category; B47_Clothing | 324 |
| B47_ClothingOuterwear | Jackets and outerwear | Item category; B47_Clothing | 65 |
| B47_ClothingProtective | Protective clothing | Item category; B47_Clothing | 290 |
| B47_ClothingSocks | Socks | Item category; B47_Clothing | 7 |
| B47_ClothingTops | Shirts and tops | Item category; B47_Clothing | 145 |
| B47_ClothingUnderwear | Underwear | Item category; B47_Clothing | 64 |
| B47_Containers | Bags and containers | Compatibility alias | 0 |
| B47_ContainersBags | Bags | Item category; B47_Containers | 97 |
| B47_ContainersFluid | Fluid containers | Item category; B47_Containers | 28 |
| B47_ContainersOther | Other containers | Item category; B47_Containers | 160 |
| B47_Electrical | Electrical equipment | Compatibility alias | 0 |
| B47_ElectricalComponents | Electrical components | Item category; B47_Materials, B47_Electrical | 1 |
| B47_ElectricalOther | Other electronics | Item category; B47_Electrical | 43 |
| B47_ElectricalPower | Portable power supplies | Item category; B47_Electrical | 1 |
| B47_ElectricalRadios | Radios and communication | Item category; B47_Electrical | 17 |
| B47_Firearms | Firearms | Compatibility alias | 0 |
| B47_FirearmsOther | Other firearms | Item category; B47_Firearms | 0 |
| B47_Food | Food | Compatibility alias | 0 |
| B47_FoodOther | Other food | Item category; B47_Food | 74 |
| B47_FoodPerishable | Perishable food | Item category; B47_Food | 434 |
| B47_FoodSeasoning | Seasonings and condiments | Item category; B47_Food | 100 |
| B47_FoodShelfStable | Shelf-stable food | Item category; B47_Food | 144 |
| B47_Handguns | Handguns | Item category; B47_Firearms | 6 |
| B47_Household | Household goods | Compatibility alias | 0 |
| B47_HouseholdCare | Personal care | Item category; B47_Household | 9 |
| B47_HouseholdCleaning | Cleaning supplies | Item category; B47_Household | 8 |
| B47_HouseholdFurnishings | Furnishings and moveables | Item category; B47_Household | 352 |
| B47_HouseholdKeepsakes | Keepsakes and collectibles | Item category; B47_Household | 81 |
| B47_HouseholdKeys | Keys and keyrings | Item category; B47_Household | 35 |
| B47_HouseholdKitchen | Kitchenware | Item category; B47_Household | 73 |
| B47_HouseholdOther | Other household goods | Item category; B47_Household | 23 |
| B47_Literature | Books and written material | Compatibility alias | 0 |
| B47_LiteratureMagazines | Printed magazines and newspapers | Item category; B47_Literature | 72 |
| B47_LiteratureManuals | Recipe and instruction manuals | Item category; B47_Literature | 141 |
| B47_LiteratureMaps | Maps | Item category; B47_Literature | 15 |
| B47_LiteratureNotes | Notes and notebooks | Item category; B47_Literature | 0 |
| B47_LiteratureOther | General books and literature | Item category; B47_Literature | 170 |
| B47_LiteratureSkill | Skill books | Item category; B47_Literature | 144 |
| B47_LongGuns | Rifles and other long guns | Item category; B47_Firearms | 9 |
| B47_Materials | Crafting materials | Compatibility alias | 0 |
| B47_MaterialsAnimal | Animal parts and by-products | Item category; B47_Materials | 24 |
| B47_MaterialsBinding | Adhesives and binding materials | Item category; B47_Materials | 9 |
| B47_MaterialsFasteners | Fasteners | Item category; B47_Materials | 4 |
| B47_MaterialsMetal | Metalworking materials | Item category; B47_Materials | 128 |
| B47_MaterialsOther | General crafting materials | Item category; B47_Materials | 150 |
| B47_MaterialsPaint | Paint and finishing supplies | Item category; B47_Materials | 16 |
| B47_MaterialsTextile | Textile and leather materials | Item category; B47_Materials | 76 |
| B47_MaterialsWood | Wood materials | Item category; B47_Materials | 10 |
| B47_Media | Recorded media | Item category | 3 |
| B47_Medical | Medical supplies | Compatibility alias | 0 |
| B47_MedicalBandages | Bandages and dressings | Item category; B47_Medical | 11 |
| B47_MedicalMedicine | Medicines and medicinal herbs | Item category; B47_Medical | 17 |
| B47_MedicalOther | Other medical supplies | Item category; B47_Medical | 25 |
| B47_MedicalTools | Medical tools | Item category; B47_Medical | 7 |
| B47_Melee | Melee weapons | Compatibility alias | 0 |
| B47_MeleeAxes | Axes | Item category; B47_Melee | 0 |
| B47_MeleeBlades | Bladed weapons | Item category; B47_Melee | 18 |
| B47_MeleeBlunt | Short blunt weapons | Item category; B47_Melee | 69 |
| B47_MeleeLongBlunt | Long blunt weapons | Item category; B47_Melee | 71 |
| B47_MeleeOther | Other melee weapons | Item category; B47_Melee | 44 |
| B47_MeleeSpears | Spears | Item category; B47_Melee | 27 |
| B47_Misc | Miscellaneous | Item category + legacy compatibility | 114 |
| B47_Outdoor | Outdoor equipment | Compatibility alias | 0 |
| B47_OutdoorCamping | Camping supplies | Item category; B47_Outdoor | 46 |
| B47_OutdoorFarming | Farming and gardening supplies | Item category; B47_Outdoor | 136 |
| B47_OutdoorFire | Fire-starting supplies | Item category; B47_Outdoor | 9 |
| B47_OutdoorFishing | Fishing supplies | Item category; B47_Outdoor | 20 |
| B47_OutdoorLighting | Lighting | Item category; B47_Outdoor | 21 |
| B47_OutdoorOther | Other outdoor equipment | Item category; B47_Outdoor | 0 |
| B47_OutdoorTrapping | Trapping supplies | Item category; B47_Outdoor | 6 |
| B47_Shotguns | Shotguns | Item category; B47_Firearms | 5 |
| B47_Tools | Tools and maintenance | Compatibility alias | 0 |
| B47_ToolsCarpentry | Carpentry tools | Item category; B47_Tools | 12 |
| B47_ToolsCutting | Cutting and forestry tools | Item category; B47_Tools | 68 |
| B47_ToolsFarming | Farming tools | Item category; B47_Tools | 23 |
| B47_ToolsGeneral | General tools | Item category; B47_Tools | 49 |
| B47_ToolsMechanics | Mechanics tools | Item category; B47_Tools | 6 |
| B47_ToolsMetal | Metalworking tools | Item category; B47_Tools | 10 |
| B47_ToolsSewing | Sewing tools | Item category; B47_Tools | 14 |
| B47_Vehicle | Vehicle parts | Compatibility alias | 0 |
| B47_VehicleBatteries | Vehicle batteries | Item category; B47_Vehicle | 3 |
| B47_VehicleOther | Other vehicle parts | Item category; B47_Vehicle | 90 |
| B47_VehicleTires | Vehicle tires | Item category; B47_Vehicle | 9 |
| B47_WeaponParts | Weapon parts | Item category | 11 |

Broad-rule coverage counts (overlapping; do not sum): B47_Ammo=194, B47_Beverages=20, B47_Clothing=1436, B47_Containers=315, B47_Electrical=62, B47_Firearms=22, B47_Food=772, B47_Household=616, B47_Literature=598, B47_Materials=425, B47_Medical=63, B47_Melee=309, B47_Misc=218, B47_Outdoor=240, B47_Tools=200, B47_Vehicle=106.

### Resolution precedence / metadata sources / name-based heuristics

The existing first-match resolver remains the foundation. FullType override wins first. Canonical ScriptItem is used for observed InventoryItems, with safe getter reads and normalized native resource identities. New classification order is ammunition/magazines/boxes; weapon parts; keys/keyrings; cleaning; bandages; clothing; medical; vehicle battery/tire; tool components; toy/firearm metadata; tools; remaining mechanics parts; outdoor purpose; containers; radios/clocks/moveables; beverages; literature/maps; recorded media; remaining weapons; power/materials; stable food; animal parts/keepsakes; recognized vanilla DisplayCategory fallback; survival/kitchen semantics; Misc. Each item gets one functional category.

Native script item type, weapon categories, ammo resource and animation distinguish firearms/melee; body location and ProtectiveGear group clothing; skill training/learned recipes distinguish books; bandage/medical flags distinguish treatment families; script DaysFresh and spice flags distinguish food; type/WaterContainer distinguish containers; native radio/moveable/key semantics and mechanics/memento flags establish their families. Quartermaster independently interprets native tags for ammunition boxes/magazines, tool disciplines, fishing/trapping/farming/camping/fire/lighting, materials, beverage and cleaning purposes. Recognized vanilla DisplayCategory is a conservative final fallback. The complete resolver is `Categorizer.lua`; review rows retain the winning reason and input metadata.

Food's native default no-spoil sentinel is 1,000,000,000, verified in the installed JAR constructor. Fresh/perishable classification uses script shelf life, never current rot/frozen/burnt/condition/fluid state. Clothing with unknown modded body slots falls back to Other clothing. Worn containers retain container precedence. Keys/keyrings use native identity; explicit Vehicle Key/Key Ring matching semantics are preserved. Printed magazines cannot be firearm magazines merely because the generic magazine tag occurs on literature. Household cookware/metal tags do not force cookware into Materials.

**NAME-BASED HEURISTICS:** NONE. Item display/localized names are not classification authority. Existing explicit item-rule lookup remains an existing compatibility behavior, separate from the taxonomy classifier. Native metadata/property identifiers are interpreted as stable identities, not arbitrary translated names.

**CLASSIFY TOOLS BY USE:** Existing server sandbox option remains authoritative. With true/default, supported multipurpose weapon-tools resolve into their useful tool discipline (axes into Cutting and forestry tools). With false, weapon-tools resolve into the appropriate melee family (axes into Axes). Non-weapon tools remain tools. Cache invalidates with this policy. No new gameplay setting: labels/family membership are the taxonomy contract; cache/protocol/UI internals are implementation details.

**OVERRIDES: 9**, owned and O(1), independently justified by installed vanilla definitions:

| FullType | Category | Why an exception is needed |
| --- | --- | --- |
| Base.Battery | B47_ElectricalPower | Generic Electronics lacks a script power-supply tag. |
| Base.Nails | B47_MaterialsFasteners | Material + fishinghook also describes unrelated paperclips. |
| Base.Screws | B47_MaterialsFasteners | Generic Material lacks fastener semantics. |
| Base.NailsBox | B47_MaterialsFasteners | Generic metal material/opening recipe does not identify contents generically. |
| Base.ScrewsBox | B47_MaterialsFasteners | Same ambiguity as other metal supply boxes. |
| Base.Plank | B47_MaterialsWood | MaterialWeapon + fuel/tinder does not generically establish wood. |
| Base.BlowTorch | B47_ToolsMetal | Generic Tool has no discipline-specific tag. |
| Base.Jack | B47_ToolsMechanics | Broad VehicleMaintenance cannot distinguish tool from part. |
| Base.TirePump | B47_ToolsMechanics | Same broad mechanics metadata as vehicle parts. |

### Legacy migration / broad compatibility / routing precedence

All original IDs remain valid; none removed or renamed. Versions 0/1/2 load through idempotent migration without replacing broad IDs or writing on open. Subsequent explicit Save records taxonomyVersion 2 and retains unrelated data. Future taxonomy envelopes fail safely. Unknown IDs already present may remain dormant for data preservation, but do not route items; newly introduced unknown IDs are rejected. No invented aliases for unknown categories.

An old B47_Medical rule covers all current medical descendants AND actual items previously classified Medical by our owned dev.8 resolver. This deliberately preserves old membership across corrected categories too. The same applies to every old broad family, including Misc. A frozen independent dev.8 classifier checks this retained legacy resolver for every audited definition. This can preserve historical oddities, such as printed magazines previously covered by Ammo; a newly configured specific literature destination wins over that broad rule. Migration does not silently narrow old intent.

**ITEM RULE PRECEDENCE:** explicit item rank 3 > exact physical category rank 2 > compatible broad family rank 1 > no route. At equal rank, existing fill priority, distance and stable key tie-breaking apply. **CHILD RULE PRECEDENCE:** specific child wins even if broad destination has higher fill priority. Linked presets use the same family coverage.

Visible item clearing/inversion under a broad rule first decomposes the affected broad selection into current membership, then changes requested visible names, preserving unseen effective selections. This is an explicit user edit, not an automatic migration. Such an edit replaces broad future coverage with the resulting specific/current-member rules; ordinary load/save preserves the broad alias. No-op Select Visible does not invent a new specific rule or alter routing precedence. Effective selected count deduplicates represented items, including broad presets; it never adds CATEGORY/MOD_GROUP rows to the count.

### Offline vanilla and modded audit / misclassification review

**VANILLA VERSION AUDITED:** Installed Core Build 42.21, JAR SHA-256 `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`. **VANILLA DEFINITIONS INSPECTED:** 5,105 declarations; **CLASSIFIED:** 5,092 unique FullTypes; **MISC:** 114 (2.24%); **INVALID/UNREADABLE:** 0; excluded obsolete/hidden flags: 0. Thirteen duplicate identities are recorded explicitly. The parser selects the last sorted definition for duplicates; that is not certification of native load order/inheritance. Hidden DisplayCategory alone is not the Obsolete/Hidden exclusion flag. Hair/wound/debug definitions can therefore be present in this static snapshot.

4,964 classifications differ from the frozen own dev.8 baseline, predominantly expected broad-to-child changes. Both classifiers execute independently; retained legacy resolution matches the frozen baseline across the audit. Exact source hashes and per-definition metadata/reasons/old category are in `docs/CATEGORY_AUDIT.json`. Human-review examples and all fallback entries are in `dist/handoffs/dev9-category-review.md`.

Six explicit contamination checks all pass: food in tools, printed material in ammo, weapon parts outside WeaponParts, keys outside Keys, clothing in Household, cookware in Materials. Representative review tightened tool heads, tea carrying broad beverage tags, fake weapons/keepsakes and the nine important exceptions. These checks are bounded evidence, not proof that all 5,092 semantic decisions are perfect.

Important remaining Misc includes Camera/CameraFilm, ToiletPaper/PaperNapkins, instruments such as TuningFork/Whistle, generic animal/debug entries and untagged junk/sport/game items. Their available metadata identifies only generic Junk/Instrument/Animal or unrelated material properties; it does not establish one of our supported storage purposes reliably. Some could be handled by future deliberately owned categories/individual justified overrides; broad hasmetal/cookable tags and English names would be unsafe classifiers. Other supported broad fallbacks (Other medical, General crafting materials, Other clothing) intentionally retain items lacking reliable fine distinctions. All 114 exact identities are in the review artifact.

**MODDED DEFINITIONS AUDITED:** Three installed samples, 296 declarations / 293 unique identities. Read-only script definitions; no third-party Lua executed or copied.

| Sample | Declarations | Unique classified | Misc | Invalid/unreadable |
| --- | ---: | ---: | ---: | ---: |
| Tactical Weapons | 14 | 14 | 0 | 0 |
| Authentic Z - Backpacks+ | 277 | 274 | 26 | 0 |
| WildFruits | 5 | 5 | 0 | 0 |

Tactical Weapons resolve from native weapon/ammo metadata; Authentic Z clothing/bags use type/body/category metadata, with 26 insufficiently described items left safely Misc and three duplicate identities recorded; WildFruits use food script semantics. Full per-source counts/examples/review flags are in the JSON. Mod load-order changes, inherited/runtime-mutated metadata and actual ownership/provenance need loaded-game diagnostics. These sample classifications are not a universal mod-compatibility certification.

### Better Sorting reference / granularity comparison / exact agreement

Existing behavioral reference record identifies Better Sorting 2.1.5, Workshop 2313387159. This pass uses the useful storage concepts described in the handoff as direction and independently derives rules from vanilla definitions/APIs. No Better Sorting runtime calls/dependency, Lua/database/item-list/localization/assets copied or executed. No third-party files altered.

The taxonomy now supports distinct ammo forms, firearm/melee families, tool disciplines, stable food storage, clothing families, treatment families, materials, outdoor purposes, vehicle parts, books and household destinations. This substantially closes the prior coarse-granularity gap. It is not a 1:1 Better Sorting reproduction. Medical disinfectant/suture detail, snack/ingredient types, audio/video subtypes and additional specialty distinctions remain broader where exposed stable metadata does not support a reliable generic classifier. Inventory display-category renaming outside our owned tree is not implemented by this pass.

**EXACT ITEM AGREEMENT STATUS:** UNKNOWN / not measured. No Better Sorting category database was loaded for comparison; no agreement percentage is claimed. The measured comparison is against our own pre-expansion resolver, not Better Sorting.

### Tree, search, filters, bulk/range, controller, authority and performance

**CATEGORY TREE:** Category → Mod Group → Item preserved, including mod ownership and partial/full/none states. **SEARCH:** category-name matches temporarily expose all eligible children; item-only matches preserve parent context; clearing restores normal expansion. **FILTERS:** Only Checked/Only Contents remain intersecting visibility constraints. **BULK/RANGE:** same-row-class anchors, Ctrl-click preservation, visible-only item ranges/select/clear/invert retained; category/mod actions use existing group transition semantics. No hidden item rows silently edited by visible-list operations. **CONTROLLER:** existing navigation/focus code and offline regressions preserved; actual game controller validation pending. Context menus suppress meaningless Select/Clear actions on empty/full/none groups.

**MULTIPLAYER AUTHORITY:** Server independently classifies authoritative script metadata with the same owned resolver that feeds Catalog display and destination routing. Client config IDs are validated. Current discovery/save/preset requests carry taxonomyVersion 2; incompatible/missing peer taxonomy fails before initialization/write. Both peers must use the same build/definitions; matching version alone cannot prove identical mod registries. Existing server validation, persisted shared state, sync, access/handle validation and native movement architecture remain intact. No client category claim authorizes routing or mutation. Late join/reconnect/restart native acceptance remains mandatory.

**CACHE/PERFORMANCE:** Existing cooperative Catalog preparation retained. Per-ScriptItem weak-key cache holds category/reason/legacy under the tools policy; explicit invalidation/game start/policy changes clear it. Nine overrides use table lookup. No registry scans or tag normalization in row drawing. Developer `Catalog.audit` is an explicit diagnostic, never a per-frame scan. Offline repeated-read/cache tests pass; actual frame timing is not measured.

**LOCALIZATION:** New category labels and taxonomy-peer status are present across all 29 supported locales with English fallback values and matching keys. Classifier has no localized-name input.

### Regression tests / taxonomy tests / migration tests / exact commands

[TESTED OFFLINE] Full regression suite PASS: Sorting, broad/partial counts, mod grouping, visible bulk/ranges/search/filters, UI framework/layout, discovery, transport, schema/authority/presets, planner/native movement fixtures, Shopping/Wish/collection/preferences, Dibs!, crafting/building/recipe shopping and Project Cook. Production Lua syntax and locale coverage/JSON parity are checked by the suite. Standalone guards verify no Quartermaster requirement or LootSorter dependency; no third-party module is used by production classification.

New taxonomy tests cover all 85 physical categories, both tools policies, native-shaped Sets/resources, conflicting metadata, localized-display independence, no mutable instance-state reads, nine exceptions and caching. Migration tests cover all 18 original IDs, load/no-write, repeated conversion, Save/foreign-data preservation, dormant unknowns/new unknown rejection, specific/item rank, presets, peer rejection and visible clearing with hidden membership preserved.

Exact commands, from project root (PowerShell `$python` is the bundled runtime below):

```powershell
$python = 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $python scripts/check_versions.py --root .
& $python dist/handoffs/dev9-focused-tests.py
& $python tests/audit_categories.py --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2324223029/mods/Tactical Weapons/42' --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2335368829/mods/Authentic Z - Backpacks+/42' --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2618566294/mods/WildFruits/42'
& $python tests/audit_taxonomy_native.py
& $python tests/audit_shopping_native.py
& $python tests/audit_ui_native.py
./Build.ps1
& $python scripts/check_versions.py --root . --release
& $python scripts/check_deployment.py --package
```

Build.ps1 runs the complete `tests/run_tests.py --package`, source/package parity, temporary deployment parity rejection fixtures and version consistency. Its fixture log saying “source + local” refers to temporary test paths, not the live mods installation. Logs: `dev9-focused-tests.txt`, `dev9-category-audit.txt`, `dev9-build.txt`; native API artifacts: `dev9-taxonomy-native-source-audit.json`, `dev9-native-source-audit.json`, `dev9-ui-native-source-audit.json`, all under `dist/handoffs`.

### Native validation checklist / remaining gates

**NATIVE VALIDATION:** NOT TESTED for this build. The requirement to audit the actual loaded vanilla registry first could not be fulfilled without native execution, which this handoff does not authorize; the complete installed-script snapshot and JAR inspection are explicitly offline substitutes, not an actual-registry PASS. Run the developer catalog audit after normal prepared registry loading on each authorized peer; compare every actual resolved definition, duplicates/inherited metadata and provenance against this static review before native acceptance.

- SP: inspect all present categories and Category → Mod → Item; route representative actual items from each populated category; exercise old broad rules, specific child and explicit item conflicts; both ClassifyToolsByUse settings; save/reload; mod samples; key/keyring; search/category match/item-only; Only Checked/Contents; full/partial/none; all visible/range actions and count; mouse/controller/resize; first-open discovery and timing. Empty native categories require synthetic mod definitions or remain a documented unsupported test gate.
- Listen server: host/client taxonomy agreement; server independently reproduces routes; invalid/new unknown/stale taxonomy requests rejected; broad migrations, linked presets, server sandbox tools policy, save/refresh and reconnect.
- Dedicated server + two clients: identical loaded definitions and category results; authoritative routing/transfer results; existing-save migration; concurrent edits; restart persistence; late join/reconnect; mod provenance and mismatch rejection. G7 must pass before G8; SP/listen evidence does not replace dedicated evidence.

**Architecture blocker:** None identified in source/offline design; safe server ownership and compatibility mechanisms remain in place. This is not a native authority PASS. G7/G8 stay blocked until required actual dedicated evidence and acceptance.

### Package / deployment / Workshop

**PACKAGE:** `C:/Users/willi/Desktop/Repositories/Project Zomboid/Quartermaster - Balanced Sorting/dist/current/B47ANCEDQuartermaster-0.4.0-dev.9.zip`; 109 byte-matched production files plus five empty directory entries. SHA-256 `843e53e424c5bb3b6102b28b0417de909270cf6cd0c96cff5b0c288bf2313c96`, companion `.zip.sha256`. Testing build only; not release-ready.

**DEPLOYMENT:** NONE for this pass. **WORKSHOP:** NONE for this pass. Dev.7 historical staging is unchanged. No PZ/server launched, no live mod deployed, no Steam upload performed.

### Explicit answers to the final 20 questions

1. ALL 100 IDs and display names appear in the complete taxonomy table above; 85 are physical classifications.
2. Ammo, Firearms, Melee, Tools, Medical, Food, Beverages, Clothing, Literature, Materials, Vehicle, Outdoor, Containers, Electrical and Household were subdivided. WeaponParts and Media remain; Misc remains fallback plus old-membership compatibility.
3. Old broad IDs cover current descendants and retained old membership, without an automatic narrowing/write. More-specific destinations take precedence.
4. No original IDs were removed or renamed. All 18 load/save compatibly.
5. 5,105 vanilla declarations inspected; 5,092 unique identities classified, 13 duplicate identities recorded.
6. 114 unique vanilla definitions remain Misc in this static default-tools snapshot.
7. Cameras/film, paper hygiene, generic instruments, junk/sports/games and generic animal/debug entries lack sufficiently specific supported metadata. The fallback review lists every exact identity; names/material tags would be unsafe inference.
8. Nine FullType overrides, every identity/category/reason listed above.
9. All classification inputs originate in native definitions/APIs; direct type/body/weapon/skill/shelf-life/bandage/loot flags establish families, while our original interpretation groups native purpose/material tags. Detailed family distinctions and fallback order are above and in Categorizer; no third-party category authority.
10. NO classifier depends on item display/localized names.
11. NO Better Sorting runtime dependency.
12. NO Better Sorting source/category database copied.
13. YES, the server uses the same deterministic script resolver for supported definitions. Actual identical loaded registries/peer execution remain a native gate.
14. YES, explicit Item rank 3 beats category ranks 2/1.
15. YES, exact physical child rank 2 beats compatible broad rank 1 before fill priority.
16. YES, Categorizer feeds both Catalog display and authoritative destination matching.
17. YES, all complete existing offline regression tests remain green; no actual native PASS claimed.
18. Actual loaded registry, native UI/controller/frame timing, SP/listen/dedicated routes/transfers, mod/provenance parity, mixed peers, persistence/reconnect/restart and late join remain unverified.
19. No architecture blocker identified; native G7 evidence missing, G8 blocked. No authority downgrade or safety bypass.
20. Exact generated testing ZIP: `C:/Users/willi/Desktop/Repositories/Project Zomboid/Quartermaster - Balanced Sorting/dist/current/B47ANCEDQuartermaster-0.4.0-dev.9.zip`.

## Previous implementation — 0.4.0-dev.8, UI bounds and same-floor discovery remediation

**Version / scope:** Compatible PATCH-level defect fixes continue the 0.4.0 prerelease line at dev.8. Current source/code/metadata/document mirrors agree. No new feature, protocol, schema, persistence format or sandbox setting. UI coordinates/anchoring/status spacing and diagnostics are implementation details; existing server-owned discovery/access limits remain authoritative.

**Runtime evidence:** [USER RUNTIME OBSERVATION, dev.7] Empty container rail on the first screenshot, header “Target unavailable or access denied”; later screenshot populated rail/Ready, misplaced scrollbars, duplicate native title/footer and crowded header controls. User reports three menu opens before containers appeared. [VERIFIED CONSOLE, dev.7] Loaded dev.7; catalog prepared 10,349 scripts in 3,379ms; no Quartermaster Lua exception found in the inspected opening log. The session was SP/local authority, so absence of MP transport send/ack lines is expected. These observations are not dev.8 runtime validation.

**Before-edit invariants / files:** UI.lua and B47ANCEDUI/Controls.lua own explicit local widget layout; preserve native input/collapse/resize handlers, staged rules/count/tree/filter/range/bulk, all personal lists and controller navigation. Bindings.lua, Targets.lua, Session.lua, MultiContainer.lua and Authority.lua retain server-issued exact target handles, distance, current-square/object/container identity, locks, safehouse, expiry and execution-side guards. Native inventory movement/planner, writes, synchronization and persistence are unchanged. Add focused host tests and native-source contract checks; update current version mirrors and status. No third-party code or files changed.

**CHANGED — UI:** Explicit placement disables conflicting right/bottom native anchors on owned layout widgets and scrollbars. Scrollbar width is reset to 17 and its position/height follows its list on each layout. Visible and hidden personal lists receive consistent geometry. Only the owned main window disables native frame title/status painting; the custom header/border/status paints once. Pin/collapse share their native alternating slot, separate from Help and Close. Footer reserves space based on native font height; compact layout maintains table/tree/action clearance. Hiding an owned widget hides its attached tooltip UI. No global native class styling override introduced.

**CHANGED — discovery:** Same-floor validation now compares `math.floor(player:getZ())` with the integer scope Z, consistent with installed vanilla server Foraging and native transfer/crafting floor-offset usage. Fractional same-floor actor height previously rejected discovery and subsequent handle access. Different floors (including negative fractional Z), excessive distance, unloads, replacements and access denials still fail closed. [INFERRED] This defect could explain repeated opening failures; the exact dev.7 rejection was not logged, so causation remains unproven. No speculative widening of range, automatic write retry or bypass of server validation. Discovery logs rejection stage and successful target count; opening validation logs rejection reason; SP/local commands now log tracked outcomes and caught handler errors. These are console diagnostics, not untranslated player-facing strings or new network payloads.

**VALIDATED:** [TESTED OFFLINE, Lua 5.1 host] Focused then full regression suites PASS. Same-floor fractional Z discovery/session access; integer floor separation above/below zero; unchanged distance boundary; existing stale/replacement/revocation and authority coverage. UI checks cover explicitly managed scrollbars after simulated delayed anchor processing, header-control spacing, one owned native-frame suppression, footer/status clearance and preserved staged state at 640×460, 1100×800 and 1280×720 with font heights 14/24/32. The delayed-anchor fixture models the documented native flags; it does not execute Java rendering. [VERIFIED SOURCE] Installed native ISUIElement anchor/dimension APIs, ISScrollBar native right/bottom flags and conditional native frame/title/status paint; generic framework isolation audit and existing Shopping native API audit PASS. Version inventory and production source manifest PASS.

**UNTESTED / BLOCKED:** Actual native rendering, mouse/controller/resize/collapse, first-open discovery in the user’s mod set and real transfers. Overall dedicated G7 NOT TESTED/BLOCKED; G8 BLOCKED. Offline tests and SP evidence do not certify dedicated MP. No current dev.8 package; release artifact checks are deferred until authorized packaging.

**DEPLOYMENT:** Source only. No dev.8 packaging, staging, live deployment, game/server launch or Steam upload. Workshop staging remains dev.7. Its unchanged ZIP/checksum is archived under `dist/history/0.4.0-dev.7/`; historical report below records the original package location and validation at staging time.

**Exact commands:** Run from project root with `$python = 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'`:

```powershell
& $python dist/handoffs/dev8-focused-tests.py
& $python tests/run_tests.py
& $python tests/audit_ui_native.py
& $python tests/audit_shopping_native.py
& $python scripts/check_deployment.py
& $python scripts/check_versions.py
```

Evidence: `dist/handoffs/dev8-focused-tests.txt`, `dev8-offline-tests.txt`, `dev8-ui-native-source-audit.json`, `dev8-native-source-audit.json`, `dev8-source-parity.txt`, `dev8-version-check.txt`.

**Native next gate:** After separately authorized installation, confirm dev.8 identity and test first/second menu open, rail population, Refresh, resize and font scaling, header/title/status/footer painting, tooltip dismissal and collapse/restore. Capture `[B47ANCEDQuartermaster] discovery`, `opening rejected` or `transport local` lines if the rail remains empty. Then preserve all functional Save/Cancel and real transfer acceptance checks; dedicated peers/reconnect remain required before release readiness.

## Previous implementation — 0.4.0-dev.7, opening/transport runtime remediation

**Version / scope:** Compatible defect remediation after the packaged dev.6 UI pass; canonical development checkpoint 0.4.0-dev.7. No new gameplay feature. All current inventoried mirrors agree. Dev.6 ZIP is immutable under `dist/history/0.4.0-dev.6/`; dev.6 report below remains historical proof for that UI snapshot. Its component inventory and screen conversion remain present in dev.7.

**Runtime evidence:** [VERIFIED ATTACHED LOGS] Both supplied client/server excerpts load `B47ANCEDQuartermaster version=0.4.0-dev.3 workshop=3807217050`, not dev.6/dev.7. Missing AnimSets/actiongroups errors occur during startup/ResetLua for numerous mods, including B47. They are not a stack for the menu opening. Server excerpts also contain native ReceiveModData missing-square errors at startup; no evidence attributes them to B47 discovery. [USER RUNTIME OBSERVATION] Opening the menu twice froze for roughly 30 seconds each, then its header showed no-server-confirmation/outcome-unknown; this happened before Save. [UNKNOWN] Exact elapsed hot path and whether a server reply was absent, delayed or unhandled cannot be established from these excerpts. No claim that the actual freeze is now eliminated.

**Before-edit audit / invariants:** Picker construction, Ownership and MultiContainer repeated native catalog/provenance scans; Shopping populated an invisible full catalog during opening. Transport selected its event handler using isClient() at shared-module initialization; a later connection could require the other handler. Initial discovery timeout left session ID unset, while Refresh required an existing ID. Changes target Catalog/Picker/Adapter/MultiContainer/ItemCatalog/ShoppingUI and Authority, focused tests, localization, current version mirrors and packaging. Preserve server-issued handles, source/target authorization, planner/executor/native mutation, staged Save/Cancel, counts/range/bulk/filter and the complete dev.6 UI.

**CHANGED:** Catalog preparation displays cancellable progress and bounds native reads to 64 entries per tick with a cooperative 4ms budget checked between entries. First open waits for this preparation before discovery. Subsequent opens reuse its native registry/index; Adapter consumes the catalog's functional-category provenance instead of performing another raw DisplayCategory scan. MultiContainer reuses the opening catalog, merging observed instance names as before. Shared Add Item catalog is seeded from prepared script references; dedicated views do not populate their hidden legacy catalog. No catalog scan/network request runs in row drawing. Native index/model construction after the scan remains a native timing gate; the cooperative budget is not a hard bound on an individual engine call.

**Transport / recovery:** Both native event contracts register once and evaluate execution side at dispatch. OnClientCommand refuses client execution; OnServerCommand refuses server execution; A.handle retains its server/local guard and all existing validation. This avoids assuming the connection was already active when shared Lua loaded. Discovery/load/presets/personal inspection timeout now says the server did not reply; uncertain writes remain uncertain. One read-only grace after a blocked event loop permits queued acknowledgement delivery before expiry. No automatic write retry, optimistic save or fallback to client authority. Refresh can repeat initial discovery without an existing session ID. Request/receive/reply/acknowledgement/timeout logs include command/request, elapsed time and server version; no inventory payloads or credentials are logged. Additive serverVersion response metadata is diagnostic only, not a new gameplay command/schema.

**Startup warning hygiene:** Original empty `common/media/AnimSets`, `common/media/actiongroups`, `42/media/AnimSets`, `42/media/actiongroups` directories are present in this mod's source and testing ZIP. No animation definitions, sentinel runtime files or external-mod edits introduced. [TESTED OFFLINE] Exact ZIP entries verified. Actual startup warning disappearance remains [RUNTIME GATE]. Errors naming other mods and native missing-square packets are outside this mod fix and unchanged.

**VALIDATED:** [TESTED OFFLINE] Full Lua 5.1 host suite; menu preparation/cancel/double-open/reuse/hidden-catalog tests; staged behavior, counts/tree/bulk/filter and existing authority/planner/executor/Shopping/Dibs!/preferences/provenance tests; pre-connection event registration and wrong-side guards; queued read acknowledgement after a simulated stalled event loop; genuine read expiry; uncertain write timeout; initial discovery Refresh recovery. New preparation fixture has 2,048 synthetic scripts, at most 64 native reads per step, one registry scan and zero scans on the second open. Its clock is synthetic, not a PZ frame-time benchmark. Full UI geometry/font tests from dev.6 retained. [VERIFIED SOURCE] Native ISUI and existing Shopping/native engine API audits pass.

**UNTESTED / BLOCKED:** Actual native opening time, connection-transition delivery, server transport, frame-time, rendering/fonts/controller, SP/listen/dedicated and peer/reconnect acceptance. Overall G7 BLOCKED / NOT TESTED; G8 BLOCKED. Read-only UI preparation does not waive inherited gameplay acceptance. Fixes are source/offline evidence, not a native PASS.
**DEFERRED:** Unrelated features/mods, standalone framework extraction and speculative engine/third-party fixes. Feature freeze remains; only concrete runtime remediation continues.
**MULTIPLAYER AUTHORITY / SETTINGS:** Server validates and owns shared rules/state, persists and synchronizes as before; native transfer execution unchanged. Client cache/progress and status/focus are transient presentation. Cache invalidates on game start and ClassifyToolsByUse changes; explicit Catalog.invalidate supports deliberate registry refresh. No new shared configuration candidate. Chunk/time budget and acknowledgement grace are internal scheduling/safety constants, not gameplay settings.

**PACKAGE:** `C:/Users/willi/Desktop/Repositories/Project Zomboid/Quartermaster - Balanced Sorting/dist/current/B47ANCEDQuartermaster-0.4.0-dev.7.zip`; 108 byte-matched production files plus five empty directory entries. SHA-256 `4c453bc516fc4716cbf49c27a31f09d2546f4f36b0346372ed11c75d61df1132`. SHA-256 companion included. Version, source manifest and current ZIP agree.
**DEPLOYMENT / WORKSHOP:** On 2026-10-04, at the user’s explicit request, ./Build-Workshop.ps1 deployed dev.7 to `C:/Users/willi/Zomboid/Workshop/B47ANCEDQuartermaster` for manual publishing to existing item 3807217050. All 108 production files match source/package/staging; previous staging was backed up. Validation log: `dist/handoffs/dev7-workshop-deployment.txt`. No game/server launched, live-mod directory changed or Steam upload performed. Native G7/G8 remain blocked.

**Exact commands:** Run from project root with `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe` (called `$python` below):

```powershell
& $python tests/run_tests.py
& $python tests/audit_shopping_native.py
& $python tests/audit_ui_native.py
./Build.ps1
& $python scripts/check_versions.py --release
& $python scripts/check_deployment.py --package
```

Build.ps1 runs full tests/package, source parity and temporary deployment-gate fixtures; it does not deploy live mods. Logs are `dist/handoffs/dev7-offline-tests.txt`, `dev7-build.txt`, `dev7-native-source-audit.json`, `dev7-ui-native-source-audit.json`, `dev7-version-check.txt`, `dev7-package-parity.txt`. Attached-log hashes/identity evidence are retained in `dev7-user-log-evidence.json`.

**Native next gate:** With separately authorized installation, ensure both client and server load dev.7. Test first and second opening in the actual large mod set, cancellable progress, discovered targets and Refresh recovery, then staged Save/Cancel and real transfers. Capture catalog/transport lines from both sides to distinguish no handler, server work, delayed reply and client processing. Test disconnect/reconnect and dedicated peers without replaying an uncertain write. Preserve every dev.6 UI/functional checklist below. No release/native-readiness claim until dedicated G7 and G8 evidence exists.

## Previous implementation — 0.4.0-dev.6, UI framework testing candidate

**Before-edit audit / invariants:** Actual baseline is dev.5. Compatible reusable UI additions continue the MINOR 0.4.0 feature line at dev.6. Inventory: owned Picker shell and preset editor; Adapter category/mod/item tree, filters/counts, range/bulk and context menus; MultiContainer rail, staged Save/Cancel, sibling apply, clipboard and refresh; unified Shopping, manual catalog/picker, Wanted/Needed targets and bulk/scoped collection; Preferences with overrides/reset; duplicate/quantity/explanation/preset dialogs; physical Dibs details/context/icon badges; native/Neat/Project Cook intent controls. Native classes are ISCollapsableWindowJoypad, ISPanelJoypad/ISPanel, ISButton, ISScrollingListBox, ISTextEntryBox/ISTextBox, ISLabel, ISComboBox, ISModalDialog, ISContextMenu and native item/script icon rendering. Existing focus rows, dialog Cancel arming, controller A/B/bumpers, text focus, Shift/Ctrl range and visible-only Sorting operations must remain. Implementation files: new embedded client B47ANCEDUI theme/renderer/control/dialog/focus primitives and owned Quartermaster UI consumers, localization, manifest/tests and current version mirrors. No server protocol, resolver, collector/executor, ownership, persistence, native definitions or global vanilla styling changes. User image is inspiration; top-left logo expressly omitted. Dedicated/native gates remain blocked; no deployment/publication authorized.

### Current completion report

**CHANGED:** Embedded original B47ANCEDUI plus owned Quartermaster consumer. Approved dark/amber reference, no logo. Dedicated personal-list views replace simultaneous panes. No gameplay additions.
**VALIDATED:** [TESTED OFFLINE] Complete host regression suite, geometry/font fixtures, production manifest/source/package parity, version inventory and packaging gates. [VERIFIED SOURCE] Native ISUI and existing Shopping/native engine API inspection.
**UNTESTED:** Actual PZ rendering, input/controller, UI/font scaling, SP/listen/dedicated behavior, reconnect and optional frontend runtime.
**BLOCKED:** Overall G7 BLOCKED / NOT TESTED; G8 BLOCKED. UI-only additions have no new shared-state authority gate, but do not waive the inherited gameplay gates.
**DEFERRED:** Standalone framework extraction, other B47ANCE'd projects and unrelated gameplay. Feature development frozen for native acceptance.
**VERSION:** 0.4.0-dev.6; compatible additions continue the MINOR 0.4 feature line. VERSION and all inventoried current mirrors/artifacts agree. Dev.5 archive retained unchanged.

| Report field | Current result |
| --- | --- |
| UI FRAMEWORK | Four embedded client modules: Theme, Renderer, Controls, Dialog. Quartermaster-specific view models/layout reside in Quartermaster/UI.lua. |
| THEME SYSTEM | Central native-font roles, colors, spacing, dynamic metric cache, square borders and amber accents. Widget colors copied, not aliased to palette. |
| WINDOW SHELL | Native collapsible/resizable window, per-instance styling; branded header without logo. |
| BUTTONS | Native callbacks and enable rules; scoped styling, focus outlines, clipped captions retain original title. |
| ICON BUTTONS | Native button factory used by help and clear-search controls; native item/container icons and safe fallback outlines. No new art/font dependency. |
| TAB SYSTEM | Sorting/Shopping navigation and dedicated Shopping/Wanted/Needed/Settings actions. Selected amber underline. |
| SEARCH / INPUTS | Existing literal case-insensitive behavior, placeholder/clear controls and native text/number/dropdown inputs. |
| TREE | Existing model/state transitions, count, hierarchy, visibility/range/bulk/filter behavior; themed rows, full/partial/empty checkboxes. |
| TABLE | Cached formatted cells, native icons, clipped column headings, row selection/hover and viewport culling. |
| PROGRESS | Current/target status text plus bounded bar; over-target current numbers remain truthful. |
| BADGES | Semantic Needed/Wanted/success roles and unsaved container marker; preexisting physical-item badge hook retained. |
| DIALOGS | Scoped native quantity/explanation/name dialogs and generic Cancel-default, armed confirmation; bounded scrollable text-only body. |
| TOOLTIPS | Existing short actionable tooltips retained; owned button tooltip instances themed. No large category tutorial popup reintroduced. |
| CONTROLLER / FOCUS | Visible-only focus rows; refreshed selection actions reachable; focus widget preserved through rebuild; confirmations retain explicit acceptance, B cancel and owner restoration. Native event delivery remains a gate. |
| CONTAINER RAIL | Named native-icon rows, selection/dirty feedback, existing discovery/refresh/clipboard/sibling semantics. Hidden for personal lists. |
| SORTING UI | Search, combined count, presets, checks/priority/tree and reachable footer; staged Save/Cancel preserved. Preset editor now has explicit Cancel. |
| SHOPPING UI | Dedicated provenance rows plus actual server allocation rows; Add Item, edit/remove, collection/cancel and details preserved. |
| DIBS! WANTED UI | Dedicated target/current/remaining/fulfillment table, individual/bulk Shopping actions and scoped collection. |
| DIBS! NEEDED UI | Same target workflow with Needed emphasis; no ownership/material-consumption enforcement invented. |
| SHOPPING PREFERENCES UI | Themed popup, applicable overrides, global controls and existing confirmed reset. Responsive two/three-column controls. |
| PROVENANCE UI | Manual, craft/build/cook projects, linked Dibs!, extras and pooled requirement allocations retained. Execution rows never invent per-project current credit; explicit requirement rows show the server's actual totals. |
| RESIZING | [TESTED OFFLINE] Main table/footer bounds at 640×460, 1100×800 and 1280×720. Personal details collapse below 640 height. |
| UI SCALE / FONT SCALE | [TESTED OFFLINE] Simulated native font heights 14/24/32; compact Sorting layout keeps tree above footer. Real UI scale and split-screen remain native gates. |
| LARGE-LIST PERFORMANCE | Existing large catalog/tree regression retained; cached table cells and icon fallback, no catalog/network work during draw. No native timing/frame-rate claim. |
| LOCALIZATION | All 29 vanilla folders carry complete new keys with English fallback. Native font rendering and real translated expansion pending. |
| ACCESSIBILITY | Status expressed in words/counts as well as colors; keyboard/controller native controls and focus outline. Screen reader/contrast certification not claimed. |
| FUNCTIONAL REGRESSION | Existing offline authority/model/selection/presets/collector/preferences/provenance/replay/integration tests pass. No intentional loss of an existing action. |
| MULTIPLAYER AUTHORITY | Presentation-only modules own transient view/focus/filter state. Existing server validates, mutates, persists and synchronizes gameplay; native transfer boundary unchanged. No new protocol/schema/gameplay setting. |
| OFFLINE TESTS | PASS; commands and logs below. |
| NATIVE VALIDATION | NOT TESTED. Source/API inspection is not native execution. |
| PACKAGE | Testing ZIP, 108 exact production files plus empty common directory entry. SHA-256 955c63619344cdb13ed7f9d879916e89b5b5da596c33c7703d39d59432f6888d. |
| DEPLOYMENT | None. Temporary deployment-parity fixtures are not live mods. |
| WORKSHOP | None; no staging/upload/publish. Workshop 3807217050 identity unchanged. |

### Explicit implementation inventory / outstanding limits

1. Reusable components: WindowShell, Panel, Button, IconButton, TabBar, SearchField, TextInput, NumberInput, Toggle, Dropdown, ScrollList, SectionHeader, Tree checkbox/indent, Table prepare/draw, Badge, Progress, Tooltip, Dialog decorate/confirm, Focus visibleRows/restore, Renderer text/fit/row/icon/border/focus and bounds helper. Theme contains all palette/font/metric roles.
2. Converted screens: main Configure Sorting and preset editor, container rail, Sorting hierarchy/owned menus, dedicated Shopping, Wanted, Needed and details, shared item picker, Shopping Preferences, owned duplicate/reset/delete/quantity/name/explanation/help dialogs; B47-owned native/Neat/Project Cook add buttons and Dibs! submenu.
3. Native context-menu chrome, native input/dropdown/scrollbar internals and physical Dibs! inventory overlay retain native behavior. Optional frontends' parent windows are not restyled. Those boundaries avoid global reskinning and preserve native input contracts; only owned instances/actions receive the theme.
4. No action intentionally removed. Layout/navigation changed as authorized. Project allocations remain pooled: execution provenance uses “See requirements”, rather than fabricating counts. Goal bulk explicitly retains the preexisting all-unfulfilled-goals scope (tooltip states it includes hidden search rows); Sorting visible-only semantics remain unchanged.
5. Remaining controller issue: native input dispatch, long-dialog scrolling, optional frontend focus, tab/selection restoration and text-entry escape/back must be tested in PZ. Host reachability/safe acceptance passes, not a native controller PASS.
6. Remaining scaling issue: supported main minimum is 640×460; viewports smaller than that, real split-screen, non-Latin glyphs, maximum UI/font scale and expanded translations require native verification. Offline geometry is not a visual-fit certification.
7. Framework has no Quartermaster requires/state/protocol/player inventory assumptions. Labels, callbacks, rows, owner and player viewport index are injected; extraction is deferred, not blocked by gameplay coupling.
8. NO new global vanilla UI styling or replacement. Existing scoped optional frontend extension hooks and physical Dibs! overlay hooks predate this pass and remain. Framework styling is per instance.
9. No new architecture blocker prevents native testing. Overall G7/G8 remain blocked pending actual dedicated evidence; release readiness is not claimed.
10. Exact testing package: `C:/Users/willi/Desktop/Repositories/Project Zomboid/Quartermaster - Balanced Sorting/dist/current/B47ANCEDQuartermaster-0.4.0-dev.6.zip`.

### Exact validation commands / evidence

Run from the project root; Python is `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe` with project `.test-deps` (Lua 5.1 host fixtures). Commands:

```powershell
& $python tests/run_tests.py
& $python tests/audit_shopping_native.py
& $python tests/audit_ui_native.py
& $python scripts/check_versions.py
./Build.ps1
& $python scripts/check_versions.py --release
& $python scripts/check_deployment.py --package
```

`$python` denotes the absolute executable above, not a system variable override. Build.ps1 runs full tests/package, temporary deployment fixture tests, source/package parity and release-version consistency. Logs: `dist/handoffs/dev6-offline-tests.txt`, `dev6-build.txt`, `dev6-native-source-audit.json`, `dev6-ui-native-source-audit.json`, `dev6-version-check.txt`, `dev6-package-parity.txt`. UI audit hashes native ISUI classes and confirms framework independence. Native source inspection: installed 42.21 source/runtime; engine JAR hash retained in Shopping audit. No third-party code/art/layout/text/balance copied. New sandbox candidates: none, purely local presentation; geometry, role colors, safety arming and protocol limits remain implementation constants. Existing server settings unchanged.

### Native acceptance checklist — feature freeze

[RUNTIME GATE] In SP, listen host/client and dedicated peers: open an initial drawer/nearby multi-container session; verify rail targets, staged save/cancel/clipboard/siblings and native sorting movement. Confirm Sorting full/partial/empty counts, collapsed/search/Only Checked/Only Contents visible-only range/Ctrl/invert operations, presets and reopen/reconnect persistence. Navigate all personal views without container ownership confusion. Test item add/edit/remove, true current possession changes, Wanted/Needed overlap/links/extras/bulk/scoped collection, preference applicability/reset/revision rejection, every supported Craft/Build/Neat/Cook entry point and cancellation/intentional repeat/replay/rapid/controller acceptance. Verify actual icons, native fonts, window drag/resize/collapse, no footer/tree overlap, long translated names, narrow/split-screen layouts, large catalogs and text/search focus. Dedicated G7 must PASS before G8. Do not deploy/publish/launch without separate user authorization. Only concrete runtime remediation follows this freeze.

## Previous implementation — 0.4.0-dev.5, 2026-10-03

**Scope / version decision:** [VERIFIED SOURCE] This handoff extends the actual dev.4 source, retaining its optional Neat Crafting/Building adapters and collection-result fixes. Compatible additions continue the existing MINOR 0.4.0 feature line at the explicit dev.5 checkpoint; no stable release is claimed. VERSION is canonical and every inventoried current mirror is synchronized. Legacy internal wish names remain compatibility aliases; the player-facing concept is Dibs! Wanted. Historical reports below retain their original meaning and evidence. Feature development is now frozen for native acceptance.

**CHANGED:** Original shared ShoppingPreferences and ShoppingAdds modules extend Personal, ShoppingRequirements and the existing server Shopping planner. Client ShoppingAddUI and PreferencesUI extend the current unified UI and shared ItemPicker. No second collector, transfer executor, inventory scanner, recipe database or third-party implementation was introduced. Source implementation uses clean-room rules; installed reference interfaces were read only. Native movement authorization and native engine mutation remain in the existing executor.

**Dibs! Wanted / Needed / migration:** Wanted retains existing wish targets and schema-2 possession semantics. Old acquisition counters are retired without becoming inventory or credit. dibsListSchema=1 adds an empty Needed target map, separate links, extra-demand provenance and request receipts; it does not fabricate Needed entries. Both lists show current / target / remaining / fulfillment, add/edit/remove, individual Add Remaining and Collect Remaining, and bulk Add Items to Shopping List. Summaries derive fulfilled rows / total rows and summed remaining from an authoritative snapshot; they are never persisted. Physical Wanted or Needed establishes its respective absent target at one, preserving larger existing targets. Clearing a physical mark leaves targets; removing a target leaves physical marks. Needed retains stronger presentation and planning priority, without ownership or material-use enforcement.

**Overlap / current inventory:** Wanted and Needed full types are independent goals credited against the same qualifying possession count. When both are linked to Shopping, their possession requirement is max(targets), never a sum. Only explicitly linked goal sources contribute to Shopping; an unlinked target is not silently added. Manual/recipe/explicit-extra demand remains independently additive and shares the existing single-credit allocator. Current counts are not clamped; dropping, consuming or disqualifying carried items increases the remaining goal. The existing root inventory, directly equipped bags, native keyrings and exact-reference dedupe domain is unchanged; nearby storage, remote players and unsupported deeper bags do not grant credit.

**Preferences / default policy:** preferences schema 1 stores personal global defaults, applicable per-field item overrides and the duplicate-confirmation flag. Default ANY imposes no additional restriction on otherwise eligible items in a supported native requirement. Condition/durability uses native getCondition/getConditionMax percentage for weapons and clothing (including alarm-clock clothing). Food filters use native age/off-age, rotten, cooked and frozen states. Drainable thresholds use native getCurrentUsesFloat, whose installed implementation returns remaining uses multiplied by use delta. Inclusive 25/50/75/100% thresholds are UI choices; the server accepts bounded integer percentages. Food freshness, cooked/frozen and rotten choices retain explicit ANY/inheritance. Removing/resetting an item override inherits global/default behavior. Inherit-only entries and global ANY defaults are not duplicated in storage. Reset All is confirmed in the UI, restores ANY and duplicate confirmation ON. Malformed/future preferences reset safely to defaults instead of permanently disabling Shopping.

The one compiled evaluator wraps all supported native requirement predicates, current carried credit, both Dibs! goals, candidate planning and final TAKE authorization. A preference change returns a new authoritative snapshot and immediately rebuilds goals, summaries and Shopping credit. Profile edits are rejected while collection is active; a physical candidate state change before TAKE is still revalidated. Item override controls expose only applicable fields; an ordinary nail has no meaningless food/condition/drainable override. Personal acceptance expresses the authenticated player's request intent and does not change shared recipe validity, Dibs! enforcement, other players' goals or server gameplay policy. Existing meaningful shared gameplay behavior continues to use server sandbox settings. No new shared balance option was introduced. Schema/protocol limits, 350ms rapid-activation coalescing, 250ms dialog arming and 60-second challenge expiry remain implementation safety limits rather than gameplay settings.

**Shopping provenance / synchronization:** UI rows identify Manual, Dibs! Needed, Dibs! Wanted, Crafting, Building and new Project Cook sources. Cook-origin native projects use an optional @cook key suffix, keeping them distinct from ordinary crafting projects; old origin-less projects are preserved without inventing provenance. Linked Dibs! sources derive remaining from current qualifying possession and edited targets. Unlinking one source or removing its goal leaves unrelated goals/manual/projects/explicit extras intact. Confirmed Dibs! Add Again creates independently removable extra demand based on the server's current remaining quantity; subsequent target changes do not silently erase that deliberate extra. Bulk skips fulfilled and unavailable types and atomically commits or rejects the whole eligible batch.

**Duplicate / replay / controller safety:** All current Add paths share ShoppingAddUI → shoppingAdd → ShoppingAdds. The server validates authenticated player, source identity, current revision, native recipe/intent, quantity and current Dibs! remainder before commit. Manual keys use full type; project keys use native recipe + canonical intent + optional Cook origin; Dibs! links use list kind + full type. First addition commits normally. An already represented source returns one bounded confirmation challenge without changing demand. Cancel sends no commit. Add Again adds manual quantity, project executions or independent Dibs! extra demand exactly once. Mixed bulk offers one dialog with counts and Add New Only; Cancel leaves the entire batch unchanged, Add New Only links legitimate new entries without inflating old ones. Same operation/digest replays return current acknowledgment, mismatches/stale revisions reject; a replay of a pending request retains its challenge token. Both client and server coalesce rapid fresh-nonce activation. Receipt history is bounded to 256; evicted committed requests retain obsolete revisions and cannot become new additions. Confirmation OFF persists but preserves replay, double-fire and linked-Dibs! idempotence; explicit again intent can create independent Dibs! extras.

The duplicate dialog overrides the native Modal's direct A-to-Yes mapping, initially focuses Cancel, arms acceptance only after the opening event, supports B cancellation and restores the owning panel. Recipe frontends pass their owning panel to the shared dialog. Settings/controller navigation excludes hidden inapplicable fields. These handlers are [TESTED OFFLINE]; actual controller event delivery, fonts, rendering, optional frontend focus and small/split viewports remain [RUNTIME GATE].

### Shopping add entry-point audit — [VERIFIED SOURCE; TESTED OFFLINE]

| Entry point | Protected add path / semantics |
|---|---|
| Manual catalog and shared picker | ShoppingAddUI.send(kind=shopping); incremental quantity, manual full-type provenance |
| Wanted individual / bulk | Same dispatcher, wanted source; current remaining, one batch challenge, linked idempotence / explicit extras |
| Needed individual / bulk | Same dispatcher, needed source; same safeguards and stronger planning tier |
| Collect Remaining | Reuses an existing link without Add Again; otherwise establishes the link through the same protected dispatcher before scoped collector start |
| Vanilla Crafting / Building | RecipeShoppingUI.submit → shared dispatcher; native identity / executions |
| Neat Crafting / Building | Existing optional ProjectCookUI adapter → RecipeShoppingUI.submit → shared dispatcher |
| Project Cook native CraftRecipe / EvolvedRecipe | Same pipeline with cook origin and canonical addition intent; no reference execution or fabricated requirements |
| Existing-row quantity / target edits | Revision-checked setters express an absolute edit, not an add activation; explicitly labelled Set Quantity / Set Target |
| Legacy personalProject add=true | Redirected to ShoppingAdds; missing operation rejected, cannot bypass safety |
| Legacy wishToShopping alias | No current UI caller; compatibility operation is idempotent link establishment and cannot create duplicate/extra demand |

### Project Cook unsupported re-audit — [VERIFIED SOURCE / TESTED OFFLINE, not native operation proof]

| Case | Current classification and result |
|---|---|
| Several otherwise valid physical instances / personal condition or food-state choice within a supported native requirement | RESOLVED BY ANY/PREFERENCES for selection. Multiple valid candidates already worked in the baseline; no former quantity gate is relabelled as resolved. ANY accepts the supported candidate pool; one shared preference evaluator may narrow it. |
| Whole-item native CraftRecipe consumables, OR alternatives and non-degrading reusable tools | Supported baseline retained, now uses personal acceptance and protected provenance. Recipe validity still precedes personal choice. |
| Fresh, uncooked, unfrozen native Food full additions, regular ingredient and Food seasoning, partially used food with complete full portions left | Supported existing Evolved subset retained; verified binary32 use/exhaustion/skill arithmetic unchanged. Preferences can narrow candidates but do not fabricate capacity. |
| Cooked, stale, rotten, frozen or burnt Evolved ingredient states | UNSUPPORTED — REQUIREMENT SEMANTICS / DEFERRED: existing fresh-path capacity does not establish these native validity/conversion/consumption branches. Whole-item manual/Dibs! ANY may accept such physical food; that is not an Evolved support claim. |
| full_first / partial_first, short final portions, native use units, partial-use/drainable recipe consumption | UNSUPPORTED — REQUIREMENT SEMANTICS: ANY does not establish portion arithmetic or transformations. |
| Water/fluid/energy, non-Food seasoning, replacements/depletion, prefilled or spiced bases, frozen/spice helper operations | UNSUPPORTED — REQUIREMENT SEMANTICS: no approximate demand or copied reference helper introduced. |
| Ambiguous/missing registry identity, module mismatch, unsupported/manual input selection, compound/variable/apply-on-tick/state-changing inputs | Fail closed. Personal selection does not establish a trustworthy native requirement. |
| Whole-item versus portion demand for the same type, incompatible portion pools, consumed versus retained ambiguity | UNSUPPORTED — REQUIREMENT SEMANTICS: collection is blocked rather than double-crediting one physical instance. |
| Actual native supported/unsupported behavior, optional UI focus, replication, persistence after restart | BLOCKED / NOT TESTED native acceptance; source and host fixtures are not engine execution. |

No former unsupported quantity/operation path became supported in this pass. No architecture blocker prevents testing the supported subset; deferred operations remain explicitly unavailable, and native multiplayer acceptance remains the release blocker.

**Authority / persistence:** [VERIFIED SOURCE; TESTED OFFLINE] New target maps/preferences/provenance/receipts live in the existing server Global ModData personal account record. MP identity derives from the authenticated player username, not payload identifiers. Personal snapshots use existing targeted request/result transport; social physical marks retain native item modData synchronization. Clients submit intent only, and final native walk/TAKE/mutation boundaries are unchanged. Reconnect-shaped fixtures reuse the existing account identity and receipts. Real save/restart, join/reconnect, SP/listen/dedicated synchronization and stock competition remain [RUNTIME GATE]. Compatibility schema versions stay separate from project VERSION; mixed-version peers/downgrades are not supported claims.

**Localization / performance:** [TESTED OFFLINE] All new strings have identical English fallback coverage in all 29 vanilla language folders. Legacy key identifiers remain stable; player-facing Wish language is removed from current UI and feature summaries. One loaded-definition catalog and one canonical carried inventory domain remain. Overrides are merged once per compiled evaluator, not reconstructed for each candidate. Existing discovered records are traversed once into Needed/Wanted/ordinary planning tiers and preserve distance/ID ordering within a tier. No continuous full catalog scan or extra executor is introduced. Actual large native inventories/rendering latency remain untested.

**Validation commands / evidence:** [TESTED OFFLINE] Bundled Python `tests/run_tests.py` PASS (Lua 5.1 syntax; existing regression suite; new preference thresholds/ANY/inheritance/corruption; target migration/overlap/physical separation; manual, Craft, Build and Cook Evolved provenance/replay; mixed bulk; confirmation OFF; reconnect-shaped identity; safe modal focus/arming; settings field applicability; final TAKE revalidation; 29-language parity; 2,000 independent binary32 portion cases). Bundled Python `tests/audit_shopping_native.py` PASS [VERIFIED SOURCE ONLY], including native preference getters and ItemType enum constants. Installed JAR SHA-256 remains e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33, inspected base 42.21. Exact final commands from the project root: `python tests/run_tests.py`; `python tests/audit_shopping_native.py`; `python scripts/check_versions.py --root . --release`; `./Build.ps1`. Here python means `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`, not an assumed PATH executable. Build runs regression, package parity, deployment-gate regressions and version checks without deployment. Current full-build evidence: dist/handoffs/dev5-build.txt; native source audit: dev5-native-source-audit.json; final version check: dev5-version-check.txt. dev5-offline-tests.txt is the earlier standalone run within this pass; the final Build repeated every regression after the last source fixes.

**Package / freeze / native gates:** Testing-only artifact: `dist/current/B47ANCEDQuartermaster-0.4.0-dev.5.zip` plus SHA-256 companion; 103 exact source files (and one empty common directory entry). Package SHA-256: 87f1b14f453a6a77eb712c83a54d338ef9fcdc80821a160f6ebdd83870d44593. Canonical version, metadata and current package agree. Historical released packages remain immutable. No game/server was launched, no Workshop staging or live mod was deployed, and no Workshop upload was made. G7 BLOCKED / NOT TESTED; G8 BLOCKED, regardless of offline package/version PASS. Native acceptance must cover initial drawer opening, saves/restarts, both Dibs! list lifecycles, overlap/unlink/extra demand, preference changes and physical state changes before TAKE, all eight add entry points with Cancel/Add Again/replay/rapid/controller actions, mixed bulk, optional Cook/Neat support boundaries, SP/listen/dedicated peers, join/reconnect and competing stock. No further feature additions before this acceptance.

## Previous implementation — 0.4.0-dev.4, 2026-10-03

**CHANGED:** Compatible fixes and optional frontend additions on the existing 0.4.0 feature line. Project Cook selected recipes remain clickable even when the supported native resolver rejects their intent; click displays a localized explicit explanation and submits no partial project. Supported choices retain complete server-side validation. Optional Neat Crafting NC_CraftActionPanel and Neat Building NB_BuildingInfoDetailPanel wrappers add footer Shopping buttons using native logic:getRecipe() identity and execution/build quantity. Neat Crafting footer layout reserves space before native self.height-based placement; Building detail height includes the owned footer. Original create/layout/update callbacks are delegated; no reference craft/build/cook action is invoked by Shopping. No external definitions, algorithms, assets, text or balance were copied.

**SOURCE EVIDENCE:** Focused read-only interface inspection of installed Neat Crafting 1.7.3 (Workshop 3502080466, common Neat_Crafting/NC_CraftActionPanel), Neat Building 1.7.8 (Workshop 3536052310, 42.15 Neat_Building/nb_buildinginfodetailpanel and parent information panel) and previously audited Project Cook 1.4.8. Optional require paths are client-only and attempted only for activated mods. No third-party files were changed or executed by host fixtures. Missing optional modules leave other integrations available. Optional UIOnly activation is accepted, but its installed module contract has not been separately audited.

**COLLECTION FOLLOW-UP / RUNTIME OBSERVATION:** User reported a two-Butter-Knife request collected one item, with gross 2/carried 1/collected 1 and Cancel disabled. User then identified the remaining item as a Bread Knife, so no movement or full-type matching defect was established. Collection rules/authority/executor remain unchanged. Confirmed UI defect: periodic snapshots erased final collection messages. Shopping now preserves the result with remaining demand, retains totals as a tooltip, and distinguishes finished-but-unfulfilled collection from fulfillment. The earlier intermittent empty container opener recovered on reopening; its cause remains UNKNOWN.

**AUTHORITY / CONFIGURATION:** Changes are local presentation and optional recipe-intent adapters; existing server-owned Personal/project resolver and native movement/synchronization/persistence remain unchanged. No shared gameplay policy or new configurable balance was introduced. Unsupported partial/fluid/food-state/mixed-demand restrictions remain; enabling an explanatory button does not broaden server acceptance. Join/reconnect and version parity still require native multiplayer evidence.

**VALIDATION:** [TESTED OFFLINE] tests/run_tests.py PASS, including new selected-unsupported explanation/no-submit, optional Neat activation without Project Cook, native intent quantities, idempotent footer geometry, self.height-based quantity-control bounds, no-selection disable and collection-message persistence. Lua 5.1 syntax, 29-language fallback key parity, existing movement/planner/Dibs/Wish/cooking regressions and 2,000 binary32 cases PASS. Exact commands: bundled Python tests/run_tests.py and scripts/check_versions.py --root . from the project root. Historical dev.3 package/checksum were moved unchanged to dist/history/0.4.0-dev.3 before synchronizing canonical VERSION/current mirrors. No dev.4 package, staging/live deployment, game/server launch or Workshop upload was requested/performed. --release is not applicable until an authorized current artifact exists.

**RUNTIME GATES:** [RUNTIME GATE] In-game Neat footer visibility/resize/click/controller focus, Project Cook supported and unsupported selections, modal explanations and native server acceptance NOT TESTED for dev.4. User's dev.3 item collection is limited runtime evidence, not complete SP/listen/dedicated acceptance. G7 BLOCKED / NOT TESTED; G8 BLOCKED. Dev.3 publication below remains historical evidence only.

## Previous implementation — 0.4.0-dev.3, 2026-10-03

**CHANGED — former blockers superseded:** The latest handoff intentionally retires historical acquisition goals. Wish now means current qualifying carried physical instances / target, with remaining = max(0, target − current) and fulfilled = current >= target. Current display is not clamped. The general acquisition-history observer is no longer a requirement or current architecture blocker. Project Cook is an optional frontend over native CraftRecipe/EvolvedRecipe definitions, not an ingredient authority. Its former missing server recipe contract is superseded by native reconstruction. Dev.2 text below is preserved historical evidence, not current behavior.

**VERSION / MIGRATION:** Canonical project version and declared current mirrors use 0.4.0-dev.3, continuing the 0.4.0 feature line with an explicitly requested Wish semantics change. The immutable dev.2 artifact/checksum moved unchanged to dist/history/0.4.0-dev.2. Owned per-player wishSchema=2 retains every target and removes obsolete wishProgress during migration; counters never become items, target adjustments or Shopping credit. Unknown future Wish schemas fail closed. Only targets and linked-demand intent persist; current/remaining/fulfilled are derived server snapshots. Existing account/SP-character identity and native global ModData persistence remain unchanged. All peers must use this candidate; no mixed-version or downgrade compatibility claim.

**WISH CARRIED DOMAIN / RECONCILIATION — [VERIFIED SOURCE; TESTED OFFLINE]:** ShoppingRequirements.carried remains the one canonical traversal: root inventory, directly equipped InventoryContainers, and existing directly carried root keyrings identified by native type/tag. This intentionally preserves dev.2's native inventory-page keyring inclusion even when a root keyring is not separately worn. Exact item references are deduplicated. Other players, storage/floor/corpses/vehicles/nearby inventories and unsupported nested/unequipped bags are excluded. One carried array builds a fullType→physical-instance-count map for every Wish and supplies the aggregate ledger; there is no per-Wish inventory traversal or per-frame inventory scan. Native physical item counts retain Shopping's existing units; fluid/use fractions are not Wish quantities. Opening/showing Shopping (where Wish is visible), target changes, visible once-per-second refresh, Add Remaining, Collect begin, each source offer, final TAKE authorization and successful TAKE callbacks reconcile current supplies. Same-revision out-of-order UI snapshots are rejected by request sequence. Drops/use remove credit; internal root↔equipped-bag moves preserve it.

**WISH → SHOPPING / COLLECT REMAINING — [VERIFIED SOURCE; TESTED OFFLINE]:** wishToShopping derives the actor and revision on authority and recomputes possession; client current/remaining/progress fields cannot grant credit. A linked wishDemand[type]=true contributes the current Wish target as gross demand to the existing aggregate ledger. After ONE carried allocation it yields the deficit: target 222/current 157 gives outstanding 65. Persisting 65 as gross and subtracting 157 again would be incorrect. Repeated clicks update the same link without adding demand or incrementing its revision repeatedly. Manual quantities and native projects stay independent and unchanged. Wish entries receive first carried allocation; total physical credit is still assigned once across the aggregate. Target edits re-evaluate linked demand; removing a Wish removes its link while preserving manual/project demand and physical Dibs. Fulfilled goals disable both actions.

Collect Remaining calls the same Collector with a validated Wish scope; Shopping/Movement use a scoped ledger for that run, retaining ordinary discovery, exact source/carrier checks, native walking/TAKE, capacity, interruption/cancellation and native authority boundary. It stops on fulfillment or normal exhaustion/failure; unrelated manual/projects are retained and are not collected by this scoped action. No second discovery engine, executor, PUT, spawn, teleport, raw inventory mutation, or rollback. Before-TAKE revalidation rejects an offer made surplus by newly acquired supplies. Ordinary Collect still uses the complete aggregate. Existing busy guards prevent concurrent list edits/runs. Server snapshots after confirmed TAKE derive Wish progress from actual inventory, not a persisted acquisition counter.

**DIBS → WISH:** Existing Wanted behavior remains: establish absent target 1, preserve existing target/order, Needed alone creates no Wish, Needed/Clear retain Wish and removing Wish retains exact-item Dibs. Carried Wanted yields 1/1; a Wanted instance in storage yields 0/1 until actually carried. Nothing changes Dibs ownership, social priority, enforcement or normal cooking/crafting behavior.

**PROJECT COOK VERSION / FOCUSED CLEAN-ROOM AUDIT — [VERIFIED SOURCE ONLY]:** Installed Workshop 3490188370 Project_Cook 42.15/mod.info is 1.4.8, compatibility floor 42.15, with metadata reporting 42.21 compatibility. The installed engine inspected is 42.21 (console metadata 42.21.0); JAR SHA-256 e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33. The supplied Guide/FAQ URL was unavailable through the web reader, so no external guide assertion is promoted to independently verified evidence. Installed frontend/API traces supply the implementation evidence. No reference Lua was executed, imported, copied or mechanically translated; no reference algorithms/assets/database/text were incorporated. Project Cook also has optional frozen/spice cleanup helpers; the owned resolver uses the supported native fresh-food path and never calls those helpers or its transfer/cooking engine.

Audit trace: PJCK_HandCraftPanel creates PJCK_CraftActionPanel with player/logic; logic:getRecipe() returns the native CraftRecipe and quantityInput supplies executions passed to native handcraft batch machinery. PJCK_EvoPanel:getRecipe()/getBaseItem() expose selected EvolvedRecipe/physical base; getPreCookItems() exposes logical addition requests whose displayItem, panelType and portionPolicy describe selection intent. Requests represent additions, not final physical ingredient counts. portionPolicy has full_only/full_first/partial_first modes. Native ISAddItemInRecipe.complete delegates to EvolvedRecipe.addItem. PJCK_CookingInfo supplies a separate createChildren/calculateLayout/update surface. PJCK_Window reuses or recreates panels through these constructors, so wrappers apply to each new instance and are idempotent. The two inspected action/info panels derive ISPanel and declare no direct controller handlers; owned insertion uses available controller rows and a focused-panel Y forceClick path while delegating other handlers. Actual focus/navigation through NeatUI/Project Cook remains UNTESTED.

**PROJECT COOK UI HOOKS / CRAFTRECIPE PATH — [VERIFIED SOURCE; TESTED OFFLINE]:** Optional client-only ProjectCookUI wraps createChildren/update on PJCK_CraftActionPanel and createChildren/calculateLayout/update on PJCK_CookingInfo. Craft Shopping fits between existing Craft and quantity controls; the info panel reserves an owned 28px footer strip, with stable repeated layout. Original callbacks/buttons/layout/update behavior remain delegated. The action opens the owned quantity prompt and submits native identity, executions, revision and minimal addition choices only. Craft uses existing RecipeShoppingUI.submit→Personal.project→ShoppingRequirements→getScriptManager():getCraftRecipe, preserving existing fail-closed requirement support and manual-input rejection. No duplicate CraftRecipe resolver. When Project Cook is absent no external require, UI instantiation or class injection occurs. A missing optional hook fails without breaking owned features; no mod.info dependency was added. Runtime placement, localization/fonts, lifecycle and controller behavior are UNTESTED.

**EVOLVEDRECIPE PATH / NATIVE AUTHORITY — [VERIFIED SOURCE; TESTED OFFLINE]:** Original EvolvedRequirements looks up getScriptManager():getAllEvolvedRecipes() and verifies a unique module + getUntranslatedName() identity. getOriginalname()/getName() can be shared display labels and are not identity. Native full getBaseItem()/getFullResultItem(), getItemsList(), ItemRecipe.getModule()/getUse(), script item type/spice metadata and getMaxItems() reconstruct requirements. The request carries an empty-base full type, Full mode and bounded type/class/addition choices; no final ingredient quantities, inventory credit or validity are accepted. The server validates every choice against loaded native membership/module/use/class and the per-dish regular maximum; seasoning type may occur once per dish. Every component must resolve before the project is committed. Persisted project intent is copied and re-resolved, not a duplicate cooking database. Quantity means intended dishes, multiplying selected additions and base count. Selected bases with existing additions/spices are unsupported.

**EVOLVED PORTIONS / SEASONINGS / AGGREGATION:** Separate rows retain base / regular ingredient / seasoning classes. Whole base count uses ordinary physical-instance allocation. Fresh, uncooked, unfrozen Food additions use actual getHungChange and native ItemRecipe use, with binary32 rounding matching the inspected Java operations. Regular consumption reduces native use by 3% × Cooking level; fresh regular food is exhausted under native getHungerChange >= −0.02 behavior. Seasoning uses its distinct native consumption and > −0.01 exhaustion boundary, independent of regular skill consumption. Full additions require a complete native portion; the resolver never rounds a short final portion up. Thus five additions can be supplied by one actual cabbage that supports five full uses; a partially used physical item can contribute fewer full uses. Available stock is assessed by actual candidate capacity, never a guessed fixed cabbage count. No Food/InventoryItem is created or mutated to preview use. Kahlua MathLib frexp/ldexp presence is source verified; actual Kahlua execution is UNTESTED.

Portion nodes allocate each physical item once, pool only identical native recipe/use/class/skill semantics and feed the same Shopping source offers/TAKE executor. Mixing the same type's portion requirement with whole-item manual/Wish/Craft/retained demand, or incompatible portion pools, is explicitly UNSUPPORTED and disables aggregate collection rather than double-crediting it. Ordinary Craft alternatives/reusable tools retain their existing allocator. Row counts for Food are native additions, explicitly labelled, not asserted physical item counts; source selection computes actual usable stock capacity. Protocol ceilings (32 chosen types, 256 aggregate nodes/candidate uses, existing quantity/payload limits), binary32 conversion and refresh/layout values are implementation safeguards, not gameplay settings.

**UNSUPPORTED / FAIL CLOSED:** Project Cook Full/native-safe full_only requests are supported; full_first/partial_first queued modes reject rather than importing reference-specific portion policy. Cooked, stale, rotten, burnt, frozen, no-recipes or fluid-bearing Food is not credited/collected for this supported slice. Vanilla cooked/rotten modifiers, frozen allowances and arbitrary modified behavior are not approximated. Fluid/energy quantities, water fill/source operations, pre-filled bases, non-Food additions, ingredient replacement/recovery, multiple same-type seasonings per dish, exceeding regular maxima, ambiguous/unknown identities/API failures, oversized uses and mixed portion/whole-item demands reject or remain ineligible with an explicit explanation. Existing CraftRecipe unsupported rules remain. These are known support boundaries, not the retired Project Cook architecture blocker. Modded recipes/ingredients registered through native definitions are resolved generically with module validation; a modded fixture passes. Actual modded loaded-registry compatibility remains UNTESTED; no per-mod database or general compatibility promise.

**MULTIPLAYER AUTHORITY / CONFIGURATION:** Server/SP derives account/character identity, validates revisions/minimal intent, reads actual owned carried inventory and native recipe/skill state, updates/persists owned goals/projects/links and returns snapshots through existing command transport. Clients own presentation only. Native global/item ModData synchronization and the established native transfer boundary remain unchanged. Reconnect/restart reconstruct derived counts; no acquisition event stream, custom inventory replication or client credit. Existing server Container Range/Whole Building sandbox options continue controlling discovery. Fixed requested Wish/current-possession/full-native semantics introduce no configurable routing/balance variant; no meaningless sandbox options were added. Dedicated validation remains mandatory.

**VALIDATED — OFFLINE:** Full Lua 5.1/lupa suite passes with sorting/presets/staged editing/movement regressions preserved. New tests cover zero/partial/exact/over-target, gains/drops/use/target edits, legacy counter removal, equipped-bag dedup/exclusion, stale-client server recalculation, repeated-click idempotence, manual isolation, existing scoped server planner/TAKE grants, fulfillment stop and surplus-grant rejection; native-shaped Evolved registry/module/full-base/result/same-label identity, normal/spice classes, full uses in partially used actual Food, skill, invalid states, modded definitions and fluid/partial/spoof/replacement/mixed-demand rejection; optional absent/missing-hook behavior, Craft identity/execution reuse, additive layout/delegation, queued minimal intent, Wish controls and same-revision response ordering. An independent Python struct binary32 oracle passes 2,000 native-shaped ingredient/seasoning cases. This validates owned arithmetic/fixtures, not an executing engine. All 29 locale tables have matching English fallback. Static/source audit is separate from host tests and native evidence.

Exact commands from the project root:
```powershell
$py = 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $py tests/audit_shopping_native.py
& $py tests/run_tests.py
& $py scripts/check_versions.py --root .
& './Build.ps1'
```

**PACKAGE:** [TESTED OFFLINE] Final Build.ps1 PASS: full fixtures/arithmetic/locales, exact 99-file source/archive manifest and byte parity, extra/missing/changed-file rejection fixtures and check_versions.py --release. Artifact: dist/current/B47ANCEDQuartermaster-0.4.0-dev.3.zip. The local parity line is a temporary deployment-test fixture, not a live installation. Dev.2 artifact remains historical and unchanged.

**DEVELOPMENT TESTING PUBLICATION — 2026-10-03:** The user explicitly authorized publishing the current candidate as a development testing build. Build-Workshop.ps1 PASS rebuilt the candidate and verified exact 99-file source/package/stage parity at C:/Users/willi/Zomboid/Workshop/B47ANCEDQuartermaster. Workshop description and change note identify 0.4.0-dev.3 as experimental with native SP/listen/dedicated validation pending. Generated upload configuration: dist/workshop-publish/B47ANCEDQuartermaster-dev.vdf, item 3807217050, account [private publisher account]; visibility omitted to preserve the existing setting. First attempt timed out uploading the preview after content upload. Retry reported `Committing update...Success.` and exited 0. [VERIFIED UPLOAD] SteamCMD workshop_log.txt records preview success at 15:33:08 and `Upload finished for workshop item 3807217050 : OK` at 15:33:10, content ManifestID 7084105240722511640. Publication success does not establish native runtime acceptance or G7/G8 PASS. No local live-mod deployment, game/server launch, or independent public-page visibility verification was performed.

**UNTESTED / NATIVE VALIDATION / [RUNTIME GATE]:** No PZ/server launch. G6 SP/listen NOT TESTED; G7 dedicated BLOCKED / NOT TESTED; G8 BLOCKED until mandatory runtime evidence. Test Wish current counts/save-load/drop-use/root↔bag/Wanted storage↔carried, target changes, Add Remaining repeated/stale clicks/manual coexistence and scoped Collect/cancel/capacity/no duplication. Test installed Project Cook 1.4.8 actual Craft and Base Cooking controls, full_only choices, native portions/spices/skill, unsupported partial/food-state/water explanation, fresh base replacement after ordinary cooking (which Q does not execute), stable resize/rebuild/controller/font behavior and Project Cook absence. Test a real modded native definition. Run SP then listen/remote then dedicated with two clients, isolated goals, spoof/revision checks, actual source/TAKE replication, disconnect/reconnect, save/reload/restart and inventory parity. Do not infer native PASS from fixtures or source audits.

**BLOCKED:** None currently known at the feature-architecture boundary. The cumulative acquisition observer and Project Cook-specific authoritative ingredient contract are superseded. G7/G8 remain blocked by missing mandatory native/dedicated evidence, not by those former architectures.

**DEFERRED:** Cooker-tab/device/fuel control, auto cooking/crafting/building, historical acquisition tracking/Java observer, complex partial/cooked/stale/rotten/frozen/fluid allocation, mixed whole/portion allocation, pre-filled dishes and container recovery, route optimization and Dibs enforcement remain outside this slice. No solved transfer-authority research reopened, vanilla/reference modification, copied assets/code or duplicated executor.

## Historical implementation — 0.4.0-dev.2, 2026-10-03

**VERSION:** Compatible continuation of the 0.4.0 MINOR feature line. Canonical VERSION and declared current mirrors use 0.4.0-dev.2. The immutable dev.1 ZIP/checksum moved to `dist/history/0.4.0-dev.1`. Native/live/staging versions were not rewritten. Earlier reports below retain their observed versions and are historical evidence.

**CHANGED — CRAFTING / BUILDING INTEGRATION:** Owned `RecipeShoppingUI` adds an adjacent Shopping button to the native `ISWidgetHandCraftControl` and `ISWidgetBuildControl`. Additive wrappers delegate existing create/layout/update handlers and preserve native Craft/Build callbacks. The quantity prompt defaults to a positive native handcraft execution count; a zero/unavailable value defaults to one for planning. Building has native batch disabled, so the owned prompt supplies intended build count. Quantities mean executions/builds, not output units. The UI submits kind + native recipe name + quantity + personal revision; it never submits authoritative ingredients. No crafting/building actions are triggered. Manual input-selection mode is explicitly unsupported in this slice. Project rows in the same Shopping view can be selected and their quantity replaced/reduced or removed with existing quantity/set/remove controls.

**NATIVE REQUIREMENT RESOLVER / REQUIREMENT TYPES:** `ShoppingRequirements` reconstructs loaded native `CraftRecipe`/`InputScript` requirements on the server using `getScriptManager():getCraftRecipe`. Fixed whole-instance Item inputs retain native possible alternatives as OR choices; native `CraftRecipeManager.isItemValidForInputScript` validates actual candidates, including native state/tag matching. Non-degrading `isKeep` tools stay fixed per execution batch and may serve compatible retained-tool requirements across projects. Supported scope is declarative native Item requirements, not arbitrary supplemental resource consumption performed by custom lifecycle code. No callback execution, recipe database or display-text scraping. Fluid/Energy, variable amounts, partial food/drainable uses, weighted alternatives, create/consume-from/replacement inputs, wildcard inputs, on-tick inputs/outputs, degrading/sharpness-dependent tools, tool-without-keep, compound/mode-restricted inputs, non-instance use units, state-changing unseal/activation/inherited-use flags, empty/unresolvable definitions and native API failures reject the affected project without partial insertion. Overlapping retained-tool slots within a recipe are rejected. Consumed/retained candidate-type overlap anywhere in the aggregate ledger is also explicitly unsupported: the allocator must not invent a mixed-use assignment. Unknown custom callback-driven supplemental requirements remain a native compatibility gate; no general custom-recipe compatibility claim.

**INVENTORY CREDIT / SHOPPING INTEGRATION:** Persisted schema-2 Shopping data contains gross manual quantities and native recipe project provenance `{kind, recipe, quantity}`. Same project additions accumulate executions (10 + 2 = 12). Native definitions are re-resolved, not persisted as a duplicate recipe DB. A capacitated augmenting-path allocator assigns actual carried consumed instances once across manual + Craft + Build demands, re-routing alternatives when necessary. Retained tools share credit only under the supported rules above. Credit uses the verified native carried-recipe domain: root inventory plus direct equipped containers/direct keyrings; arbitrary nested/unequipped bags and nearby loot are not credited. Exact-reference deduplication prevents duplicate bag/root credit. Current supplies reconcile on snapshots, once per second only while Shopping is visible, authoritatively before Collect, before each next offer and before TAKE authorization. Acquired supplies reduce outstanding; dropped/used supplies restore it. Wish cumulative history is never read from this credit. Old dev.1 outstanding-only manual data migrates once to `old outstanding + current carried matching instances`, preserving outstanding at migration. Original historical gross demand was never saved in dev.1 and cannot be recovered; this migration does not pretend otherwise. Removed completed dev.1 entries stay absent.

**SHOPPING PROGRESS:** Gross demand persists after collection. Exact native arrival increments the existing run's collected counter and a persisted `collectedSinceEdit` counter exactly once; Shopping demand edits reset the latter, Wish edits do not. UI distinguishes gross/current-carried credit/outstanding/collected-since-edit. Current carried credit is not labelled collected. All collection reuses the existing Bindings discovery, carrier/capacity logic, one-item native walk→TAKE executor and accepted engine authority boundary. No new scanner, PUT, teleport, rollback or inventory mutation. Cancellation/partial fulfillment retain successfully collected items. Unsupported aggregate requirements disable Collect; missing projects remain removable so blocked lists can be repaired.

**MP ITEM PICKER AUDIT — [VERIFIED] INSTALLED 42.21 SOURCE, NOT RUNTIME:** Installed 42.21 `ISItemsListViewer` enumerates `getAllItems`, excludes `getObsolete()`/`isHidden()`, and groups definitions by module; `ISItemsListTable` uses script display names/full names and native script-item icons. Its text filters use guarded patterns; the requested owned picker intentionally uses case-insensitive literal matching. The admin viewer's Give/creation paths and UI class are never instantiated/called. Core static initialization independently identifies native base version 42.21; current console metadata reports 42.21.0. The earlier 42.20.3 label came from an outdated workspace note and is corrected here without relabelling historical validation. This establishes installed-source/API evidence for 42.21, not dev.2 runtime behavior. Native controller behavior remains untested. Read-only `tests/audit_shopping_native.py` records native source hashes and JAR method references. JAR SHA-256 remains `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`.

**MANUAL ITEM PICKER:** One owned ItemCatalog caches actual loaded script definitions and native metadata, invalidates on game start, filters obsolete/hidden definitions without name heuristics, and searches display name/full type/module literally. Both the existing inline browser and the shared Wish/Shopping Add Item picker use this catalog. Picker rows include native script icons, display name and stable full type; no InventoryItem is created. The same picker takes Wish/Shopping context, supports controller rows/selection/back, validates positive integer quantities and disables duplicate Wish creation. Shopping picker adds to existing gross manual demand; the main quantity controls replace quantities for editing. Server validation remains authoritative, with revisions and existing protocol bounds. No admin/debug permission, Give command or spawning API. Missing saved types retain their stable identity/fallback label and can be removed. Picker bounds follow the actor viewport and controller close restores the native joyfocus owner. Shopping mode now hides/restores native children by their element-ID map, preserves focused owned text fields during prerender and exposes both Add Item buttons in controller rows.

**WISH LIST / WISH PROGRESS:** Target definitions remain separate from physical Dibs and Shopping. Owned `wishProgress` persists cumulative counters independently of target edits. New goals begin with a stored zero counter; historical dev.1 goals with no counter retain unknown progress. UI explicitly labels acquisition tracking blocked, so stored zero is not presented as a complete automatic observer. Persisted progress 137 is preserved when target changes from 222 to 100; completion is derived when stored progress >= target, without deleting history. Shopping confirmations/current possession never update Wish progress. Automatic general acquisition remains BLOCKED by the previously documented observer gap; no repeated callback audit or polling workaround. Exact remaining is unavailable without that observer. `wishToShopping` is a prepared server boundary that rejects client progress and returns `wishBlocked`; Add Remaining/Collect Remaining is not enabled. This affected integration is BLOCKED, rather than falsely treating target or current inventory as exact remaining.

**DIBS → WISH:** Server-applied physical Wanted establishes an absent full-type Wish with target 1 and stored counter 0. Existing target/counter is untouched, repeated Wanted keeps call order, Wanted→Needed/Clear never removes the Wish, Needed alone never creates one, and removing Wish never clears physical Dibs. No world-wide type marking. The existing authoritative account-derived opaque identity, item inspection capability, reachability checks, item ModData persistence and native synchronization remain in use.

**DIBS VISUAL PRIORITY / ACCESSIBILITY:** Needed > Wanted > Unmarked applies across all players. Context entry shows explicit Needed + [!] before Wanted; single-item details list Needed first and Wanted in unchanged call order. Mixed selection has compact priority plus summary. An additive native `ISInventoryItem.renderItemIcon` wrapper delegates native drawing then shows a larger bordered ! for Needed or smaller localized W for Wanted. The render path reads only that displayed item's synchronized ModData, with no inventory rebuild, catalog rebuild, network request or order mutation. Distinction uses text/size/border, not color alone. No ownership, consumption protection or collection preference is implied. Actual native scaled-font/stack/icon rendering and synchronization remain runtime gates.

**PROJECT COOK / PROJECT COOK REQUIREMENTS — BLOCKED:** One focused clean-room inspection covered installed `Project_Cook` metadata and public method declarations only. The public evolved-recipe panel declares `getRecipe`, portion-profile helpers and selected-use/group-count helpers; this establishes a selection/portion-aware surface, not a server-verifiable dish + serving quantity + optional/substitute ingredient contract. Requested units, partial food/drainable/fluid use, consumed/replaced versus retained containers, modded ingredient groups and safe server reconstruction remain UNKNOWN. No internal data, algorithm, assets or source was copied or executed. The optional owned ProjectCookAdapter reports absent/blocked and rejects Cook resolution in both cases. No functional Cook Shopping button, required dependency or separate cooking list/executor was added. The absent mod leaves all native/manual features usable. This affected adapter stops at its contract gate.

**MULTIPLAYER AUTHORITY / CONFIGURATION:** Clients submit validated intent; server derives actor/account and reconstructs native requirements, changes/persists player data and acknowledges snapshots. Client ingredient lists, progress, carried credits, identity and recipe output counts are not authoritative. No gameplay InventoryItem is created/mutated by the picker/resolver. Native movement/item ModData synchronization are reused. Collection retains authoritative Container Range/Whole Building sandbox options. New semantics follow fixed requested UX; no additional routing/balance variation is introduced. Cache refresh interval, protocol revisions/count bounds (including 256 alternatives per input and 256 aggregate requirement nodes) and UI geometry remain implementation-only safeguards, not speculative sandbox settings. Dedicated evidence is still mandatory for these gameplay changes.

**VALIDATED — OFFLINE:** Lua 5.1 host fixtures cover old sorting/preset/movement regressions plus repeated 10 + 2 gross requirements with 3 carried, shared manual/recipe credit, drop/acquisition/bag deduplication, fixed reusable tools, non-greedy OR matching, stale/forged/client-side requests, unsupported partial/variable/fluid/degrading inputs, ambiguous retained/consumed blocking, missing-project repair, optional Cook absent/present rejection, Wish progress preservation and blocked bridge, loaded/modded catalog/filter/cache/literal full-type search, quantity/duplicate checks, compound/mode/use-unit rejection, sparse native child visibility, focused-field preservation, controller Add Item reachability, viewport bounds/focus restoration, no-spawn static guards, native-shaped recipe wrapper geometry/handler delegation, other-player Needed priority, Wanted ordering and non-color badges. All 29 locales have English fallback coverage. Offline tests do not prove actual native recipe/render/persistence/MP behavior.

Validation commands (from project root):
```powershell
$py = 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $py tests/audit_shopping_native.py
& $py tests/run_tests.py
& $py scripts/check_versions.py --root .
& './Build.ps1'
```

**PACKAGE VALIDATION:** [TESTED — OFFLINE] Final Build.ps1 PASS: full Lua 5.1 fixtures, syntax, 29-language parity, exact 97-file source/archive parity, deployment-gate rejection fixtures and check_versions.py --release. The reported local parity is a temporary test fixture, not deployment to the live mods directory. Current artifact: dist/current/B47ANCEDQuartermaster-0.4.0-dev.2.zip. No live/staging deployment or Workshop publication authorized/performed in this pass.

**UNTESTED / NATIVE VALIDATION / [RUNTIME GATE]:** SP, listen and dedicated all NOT TESTED for dev.2. Validate native fixed consumable + OR + reusable-tool recipes, actual craft execution/output units, building counts, unavailable ingredients, unsupported recipe explanation, modded native definitions, changed/dropped/equipped-bag supplies, exact TAKE outcomes, repeated additions/edit/remove and save/load. Validate new picker and Wanted→Wish with normal non-admin clients, missing mods, reconnect and server restart; verify no spawning, duplication or teleport. Test Needed by B over Wanted by A on both clients, stacked rows/details and font scaling. Required 42.21 picker validation is NOT TESTED; inspected installed source is 42.21 (console metadata 42.21.0). G7 dedicated NOT TESTED; G8 BLOCKED even when offline package/version checks pass.

**BLOCKED / DEFERRED:** Project Cook contract; general cumulative Wish observer and exact Wish remaining→Shopping/Collect Remaining; native/42.21/dedicated acceptance. Partial-use/Fluid/Energy/variable/degrading/mixed-use allocation, manual recipe input choices, custom callback supplemental requirements and unsupported definitions are outside this supported resolver slice. Dibs enforcement, auto craft/build/cook and route optimization remain deferred. No vanilla/third-party files modified. No deployment/publication.

## Historical feature implementation — 0.4.0-dev.1, 2026-10-02

The revised handoff authorizes the independent features and explicitly limits Wish to definitions/UI. It supersedes the earlier all-features audit checkpoint below. This is a compatible MINOR feature line from 0.3.0-dev.8; all declared current mirrors now use 0.4.0-dev.1. The old dev.8 ZIP was preserved under `dist/history/0.3.0-dev.8`; local/Workshop dev.8 installations are historical deployments and were not rewritten.

**CHANGED / IMPLEMENTED — UNIFIED UI:** Exactly one localized `Open Quartermaster Menu` world-container entry opens the owned main window; duplicate fills are ignored, pooled menu reuse works, and an instance-local prerender wrapper keeps the entry last after other handlers append actions. Loot/controller opener uses the same name. Existing eligible fixed-container rules and server-returned rail selection remain intact. ShoppingUI attaches to the same window after the existing sorting/session adapters, hides/restores its controls, preserves staged selections, blocks hidden-tree keyboard bulk actions, keeps footer geometry within bounds and supplies controller rows. Original geometric cart/crate icons occupy the same button position, with localized Shopping/Sorting tooltips. No separate main window or fake sorting destination.

**IMPLEMENTED — DIBS / WANTED ORDER:** `Dibs.lua` stores `{schema=1, serial, players}` in actual InventoryItem ModData `B47Dibs`. Each player's opaque public identity maps to Wanted or Needed; absence means NONE. The server derives identity, inspects exact accessible item references, issues an expiring sender-bound inspection capability, validates references again on mutation and changes only that sender's entry. Same-ID substitutes/ambiguous candidates fail closed. Multi-selected native inventory groups are normalized with vanilla `getActualItems`; concise Wanted/Needed/Clear actions follow mixed-selection semantics. Shared details are available on the compact Dibs submenu tooltip, with Wanted ordered by a persisted per-item server serial. Repeating Wanted keeps current order; leaving Wanted removes it; returning assigns a newer order. Needed is independent and first Wanted grants no ownership or movement restriction. Native `syncItemModData` transports server changes. No global item registry or transfer-time clearing; item destruction naturally removes its item-contained records. Inspection references expire after ten minutes (protocol lifetime, not gameplay tuning). Actual item save/load/transfer/reconnect/replication remain native gates.

**IMPLEMENTED — PERSONAL DATA:** Native world-global ModData's owned `personal` version-1 section stores an internal account-to-opaque-ID roster and per-player Shopping/Wish quantities with revisions. MP keys derive from the server player's username, never a payload display/online/local-slot identity; account usernames are not sent in snapshots. SP assigns an opaque identity stored in native player ModData and preserves the list for that character across saves; a new SP character receives a new identity. MP account lists survive character death by design; renaming an MP account requires a separate migration and is not silently matched by display name. Public labels are separate from identity. Native roster/player persistence/reconnect is UNTESTED. Protocol limits: 256 list entries, positive integer quantities through 1,000,000 and bounded type/label lengths; invalid/fractional/unknown types and stale revisions reject. Those limits are technical validation limits, not configurable crafting/balance values.

**IMPLEMENTED — SHOPPING:** Concrete native full-type quantities count physical instances (Nails instances, ammunition instances, and whole drainable containers, not their use/volume fractions). The picker retains raw native catalog entries, including same-name type distinctions. Editable lists are authoritative and revision checked; the UI shows remaining requested quantities. Collect is disabled for an empty list. Shopping reuses Bindings discovery and Trips' equipped-carrier selection. A server run retains exact source records; deterministic original-distance/position/item-ID ordering chooses one actual requested item at a time. Every next request reads current surviving sources and remaining quantities, allowing alternatives after stale candidates. TAKE rechecks source position, marker, exact item reference, access, proximity, native capacity and selected carrier. Root and equipped bags use the existing weight reduction/max-weight budget. No category queries, world scanner, inventory mutation or custom inventory replication was added.

**IMPLEMENTED — WITHDRAWAL EXECUTOR:** Movement grants a distinct `withdrawal=true` offer with no destination. The existing owned Executor resolves its native marker, queues a native walk to source, then uses the existing one-item transfer subclass/final dispatch guard for TAKE only. Exact authoritative carrier arrival confirms one collected instance and decrements Shopping remaining once; no PUT follows. Cancellation stops future actions and retains carried items. A cancelled already-dispatched TAKE retains a bounded server operation until exact arrival can be observed, so a legitimate completed transfer is accounted without rollback. Capacity/availability stop normally with remaining quantities intact. Sorting grants and TAKE→PUT behavior remain separate and covered by existing regressions. Native post-dispatch authority remains the previously accepted PZ engine boundary; this does not create stronger native guarantees.

**IMPLEMENTED — WISH LIST:** Player-specific create/edit/remove full-type target definitions appear beneath Shopping, clearly labelled progress not active. Progress is unknown (`— / target`), not a fabricated zero/current-possession measure. No polling, acquisition observer, auto-completion, automatic Wanted marking/clearing or Collect Remaining was introduced. These seams share personal persistence but never turn every world item of a type into an item-level Dibs record.

**CONFIGURATION ASSESSMENT:** Collection reuses the existing authoritative Container Range and Whole Building sandbox choices. Wanted/Needed lifecycle and physical-instance quantity semantics implement the fixed requested social/list model; this pass introduces no balance/routing policy variation requiring a new setting. Crafting protection, Dibs avoidance and exclusive ownership remain absent. UI geometry, protocol lifetime/count/payload bounds and polling of the existing executor confirmation state are implementation safeguards, not speculative sandbox options. Executor confirmation polling is not Wish acquisition polling.

**VALIDATED — OFFLINE:** Focused and full host Lua 5.1 regressions cover original Sorting, presets and staged sessions; new Dibs transitions, independence, serial order, re-calls, inspection sender binding, malformed requests, exact/partial Shopping, deterministic choices, no destination/PUT, stale item/source dispatch, capacity, cancellation after dispatch, list revisions and inactive Wish CRUD. UI fixtures cover same-window switching, hidden hotkey guards, footer bounds, concise mixed-state Dibs actions, duplicate/bottom navigation and pooled-context reuse. All 29 languages include English fallback keys. Validation commands are listed below; they do not prove native behavior.

```powershell
# From Quartermaster - Balanced Sorting
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/run_tests.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/check_versions.py --root .
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/check_deployment.py
# Authorized handoff permits an offline test package; no live/staging deployment:
& './Build.ps1'
```

**BLOCKED:** General cumulative Wish acquisition remains blocked by the documented observer gap. G7 dedicated NOT TESTED; G8 BLOCKED. Offline packaging/version parity is not gameplay release readiness.

**VALIDATED — OFFLINE PACKAGE, 2026-10-02:** `& './Build.ps1'` PASS after the final geometry/window-control corrections. It ran `scripts/check_versions.py --root <project>`, `tests/run_tests.py --package`, `scripts/check_deployment.py --package`, `tests/test_deployment.py`, and `scripts/check_versions.py --root <project> --release`. Current ZIP: `dist/current/B47ANCEDQuartermaster-0.4.0-dev.1.zip`; all 92 intended production files have exact source/archive byte parity. Deployment regression's “local” result refers to its temporary fixture, not the user's live mods directory. No Workshop staging/live files were updated. Final geometry regressions cover 640×460 and 1100×800, non-overlapping status/footer areas and retained native close/resize controls. Shopping snapshots refresh after authoritative item confirmations and ignore older revision responses. Multi-item Dibs tooltips summarize the selection instead of repeating every player's list for every stacked instance; inspecting an individual item exposes its ordered players.

**UNTESTED / NATIVE VALIDATION:** No PZ/server launch, live deployment or Workshop publication performed in this pass. Required SP, then listen, then dedicated acceptance: open eligible storage and verify the final single entry; switch modes and return to staged sorting; save sorting/presets; create Shopping/Wish entries; collect from one/multiple sources with excess/insufficient stock, stale source removal, capacity, equipped bags and cancellation. With at least two clients, A Wanted → B Wanted → A Needed → A Wanted must show B then A on both clients; A Clear must leave B; test concurrent calls, storage→inventory→bag→storage, Shopping and Sorting transfers, reconnect, save/load and dedicated restart. Verify no duplication/teleportation and precise remaining requests. Runtime must specifically confirm native item ModData propagation and personal identity persistence; mock tests cannot certify either.

**DEFERRED:** Wish acquisition/fulfillment/Collect Remaining and the type-goal↔instance Wanted bridge; crafting/building protection, named projects, locks/theft prevention, complex Dibs avoidance, category requests and route optimization. No vanilla/third-party files modified or copied.

## Historical consolidated audit checkpoint, 2026-10-02 / 0.3.0-dev.8

Current production version remains **0.3.0-dev.8**. Planned implementation target: **0.4.0-dev.1**, a MINOR feature expansion for Dibs Wanted/Needed, Shopping retrieval, Wish acquisition goals and unified navigation. No production implementation or version bump occurred in this audit checkpoint. The supplied consolidated handoff supersedes the earlier quantity-reservation pitch: named projects, crafting protection and exclusive ownership are deferred. Do not present this checkpoint as a completed feature pass.

**CHANGED:** Added read-only `tests/audit_consolidated_native.py` to make the installed-engine method-reference/constant evidence and vanilla file hashes reproducible. This document remains the single authoritative status report. No third-party mod code, assets, definitions or structure were inspected or copied for this audit. No vanilla files changed.

**VERIFIED — VANILLA / SOURCE:** Installed Build 42.20.3 `projectzomboid.jar` SHA-256 is `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`. `InventoryItem.save/load` serialize native item ID and the item mod-data table. `LuaManager.GlobalObject.syncItemModData` is guarded by `GameServer.server` and sends the native SyncItemModData packet to relative clients. Packet parsing resolves container + native item ID and loads the table into the resolved item's mod data. These establish available persistence/synchronization primitives, not proof of reconnect/transfer behavior, complete packet trust boundaries or globally collision-free identity. Dibs must validate exact accessible server item references and derive the sender; client payload ownership/ordering is never authoritative.

**VANILLA FAVORITE SYSTEM — VERIFIED SOURCE:** `ISInventoryPane` separately checks `item:isFavorite()`, `item:isNoRecipes(player)` and `item:isFavouriteRecipeInput(player)` and renders different indications. `InventoryItem.isFavouriteRecipeInput` delegates to script-item classification. `ISWidgetTitleHeader.onFavouritesClick` uses `BaseCraftingLogic.getFavouriteModDataString(recipe)` and player mod data, then native player transmission. Recipe favorites are distinct from item favorites. This inspection does **not** establish that favorite recipe materials are protected from consumption. Dibs must not modify or repurpose either favorite mechanism. Building-recipe coverage and consumption semantics remain UNKNOWN pending their specific native source/runtime audit.

**WISH LIST — BLOCKED for general acquisition implementation:** In inspected `Transaction.updateItem`, ordinary transfer resolves the existing source item by ID, removes it from the source container and adds the same item to the destination, then sends native container packets. Its Lua event strings are special actions (`scrapMoveable`, `pickUpMoveable`, `rotateMoveable`, `placeMoveable`, `dropOnFloor`) and clothing updates; the ordinary container transfer branch has no general acquisition callback. Native `server/TransactionProcessor.lua` corroborates those special-action handlers. Adding a listener to `OnProcessTransaction` therefore cannot provide a general source/destination acquisition ledger. Generic `OnContainerUpdate` notifications also occur for non-acquisition changes and do not provide that provenance. This is a boundary of the inspected APIs, **not** a claim that every possible engine extension has been exhausted.

Inventory polling is not an exact substitute: an outside item can enter and leave/consume within a polling interval, and inventory-count deltas lose item provenance and confuse internal bag movements. Counting only owned Shopping confirmations would miss ordinary looting and other qualifying acquisitions. Per-item deduplication alone does not recover missed events. Per handoff section 59, stop this affected gameplay implementation rather than weaken cumulative acquisition semantics or trust client progress. Smallest viable full-scope alternative: a verified, narrowly scoped server-side post-transfer/acquisition observer exposing actor, exact item, source, destination and successful completion, with nested-container ownership and non-transfer acquisition coverage audited. Java policy permits investigating such a bridge, but a supported loader/hook contract, redistribution status and native dedicated evidence have not been established; do not patch vanilla or bundle an unverified loader. A narrower Shopping-only progress feature is a scope change, not an implementation of this handoff.

**DIBS / WANTED ORDER — UNIMPLEMENTED, authority audit incomplete:** Native item-contained data is a promising primitive; exact item association through transfers, reconnect/restart, death, packet updates and grouping still needs verification. MP server username is already used by owned presets, but its account lifetime and a persistent SP identity for the new lists are not yet established. Do not reuse a temporary online ID or local player slot for these new records. No persistent Dibs registry, order serial or item/menu state has been added. Do not classify these features as proven impossible because of the Wish callback gap.

**SHOPPING LIST — UNIMPLEMENTED, reuse boundary identified:** Existing server-bound discovery, exact source validation and native TAKE leg are the reusable foundation. Current Executor requires a sorting destination during resolution, confirmation and final checks and continues to PUT; a withdrawal-only lifecycle must be explicitly added and tested, not achieved with a fake destination or silent early cancellation. Quantity/grouping audit remains incomplete: vanilla uses `ISInventoryPane.getActualItems` to normalize selected rows and separately exposes drainable use quantities; grouped visual row counts must not be treated as physical item quantity. Concrete full-type requests, exact amount, carrier capacity, stale sources, partial collection and cancellation are not yet implemented or certified.

**UNIFIED UI — UNIMPLEMENTED:** Current dev.8 Configure Sorting navigation and sorting-only window remain unchanged. One bottom `Open Quartermaster Menu` entry, Sorting/Shopping icon toggle and Shopping/Wish presentation have not been added. No inactive Shopping shell is presented as completed functionality. Preserve existing staged sorting sessions, Save/Cancel and exact server handles when implementing the independent UI slice.

**VALIDATED — OFFLINE:** The read-only audit command and version-consistency checker pass (exact commands below). This is source inspection and audit-script execution only; it is not feature regression testing or native behavior validation. Existing dev.8 test evidence below stays historical and is not promoted to new feature evidence.

```powershell
# From Quartermaster - Balanced Sorting; Python path used explicitly:
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/audit_consolidated_native.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/check_versions.py --root .
```

**NATIVE VALIDATION — UNTESTED:** No game/server was launched; no package, deployment or publication performed. Item-state synchronization, first-call ordering, stable identity, exact Shopping retrieval, loop-proof cumulative Wish progress and unified UI have no native acceptance evidence. G7 dedicated NOT TESTED; G8 BLOCKED. Continuing requires resolving the affected Wish acquisition observer contract and implementing/testing the independent slices; this audit does not authorize weakening the requirements.

**DEFERRED by supplied scope:** Named projects, reserved crafting quantities, crafting-consumption prevention/warnings, enforcement between players and automatic third-party favorites import. No new sandbox options were introduced: this checkpoint changes no gameplay. Assess genuine shared gameplay configuration when production work starts; protocol limits and UI dimensions remain implementation details.

## Current standalone source — 0.3.0-dev.8

User requires all functionality to reside in B47, with no Quartermaster dependency. This supersedes the earlier frontend/preset extraction deferral. Compatible additions within the existing 0.3.0 development milestone advance the prerelease to dev.8. Public identity remains B47ANCE'd Quartermaster / B47ANCEDQuartermaster / Workshop 3807217050. Current source and local dev.8 deployment are standalone. Earlier dev.7 dependency records below are historical.

[CHANGED / VERIFIED source] Removed require=Quartermaster and every production LootSorter reference. Added original Picker.lua and ConfigureControls.lua using vanilla ISUI/loot-container controls and world-object context-menu APIs. Existing owned Adapter/Model/MultiContainer logic now runs on that shell: hierarchy, filtering, icons, selection counts, visible bulk/ranges, priorities, rail/sibling apply, staged Save/Cancel, copy/paste and controller controls. Native icon lookup uses cached local presentation instances via instanceItem/getTex; it never inserts an item into inventory. No third-party runtime, UI class, text or asset was copied. The user-provided poster/icon remain unchanged.

[VERIFIED vanilla source] Installed ISCollapsableWindowJoypad, ISPanelJoypad, ISScrollingListBox, ISTextBox and ISModalDialog establish the UI/callback surface. Installed ISItemsListTable uses instanceItem; server/Foraging/forageServer.lua demonstrates native persistent ModData.getOrCreate. Existing verified command transport carries client intent and server results. No third-party source was read to design the new window or preset service. SOURCE CODE COPIED: NO. IMPLEMENTATION DERIVED FROM REFERENCE: NO.

[CHANGED authority] Shared Presets.lua stores an original version-1 presetLibrary under native world-global ModData B47ANCEDQuartermaster. Server/SP exclusively validates and mutates it. MP edits require a valid player session and bound accessible container plus current library revision and definition generation; payload owner values are ignored. Existing definitions can be edited by their creator or server administrator; snapshots are readable by validated participants. Generation serials survive deletions. Owned links are explicitly namespaced strings (b47:<generation>); legacy numeric/boolean links cannot resolve to an owned definition, even when its name and numeric generation match. New container envelopes use schema version 2 while reading versions 1 and 2; the enclosing object root and taxonomy retain version 1. This intentionally makes new-format preset configurations incompatible with older experimental writers; do not mix dev.7 and dev.8 clients/servers or downgrade newly saved containers. Recursive links and malformed/oversized data reject. Preset edits are shared state, separate from cancelling staged container changes. SP ownership uses local player slot; MP ownership uses server player username. Migrating an SP world's preset ownership to MP may require administrator editing.

[VERIFIED source / TESTED offline] New/returning editors request current server snapshots. Successful MP edits send revision notices to session participants; clients refresh owned snapshots, ignoring older results. Parent selected counts refresh immediately after owned preset edits. Planner/executor now resolve linked definitions on authority; retained effective rules are checked again before TAKE/PUT. A changed or missing preset invalidates an obsolete routing grant without reversing a completed TAKE. Native post-dispatch movement authority remains exactly the previously accepted PZ boundary.

[CONFIGURATION ASSESSMENT] Existing server sandbox range/building/classification options remain authoritative. No new gameplay tuning is introduced. Preset ownership, revision/generation checks and bounded snapshot payload sizes are authorization/protocol safeguards, not balance options or client preferences.

[MIGRATION LIMIT] Existing canonical and legacy version-1 manual container rules remain read-only-importable as before. Legacy preset links are retained, visible as missing when unresolved, and fail closed for routing. External Quartermaster preset definition files/stores are not executed, guessed or silently imported. Recreate owned definitions and explicitly relink affected containers; creating the same name alone must not silently restore an old generation. Independent automatic migration of those external definitions is not implemented or claimed.

[TESTED offline] Full suite passes both normally and with --quartermaster C:/nonexistent-upstream-for-standalone-test. Tests load no Quartermaster Lua and fixtures no longer provide its globals. Owned window tests cover bulk/ranges/search/scroll/controller/20k rows, icons, Save/Cancel, bounds, preset create/edit/cancel/counts, and world-menu Java collections/test-pass handling. New authority tests cover preset ownership, stale edits, isolated snapshots, deletion/recreation, module reload persistence contract, client rejection, invalid target, recursive links and MP revision notices. Movement test covers preset-only routing plus rejecting PUT after a preset edit following TAKE. All 29-language key parity passes. Static source dependency/identity checks and the 86-file expected manifest pass. These are host Lua mocks plus inspected vanilla source, not native UI/serialization/MP evidence.

Exact commands from the project directory, using Python at C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe:

```powershell
& $python tests/run_tests.py --quartermaster C:/nonexistent-upstream-for-standalone-test
& $python tests/run_tests.py
& $python scripts/check_versions.py --root .
& $python scripts/check_deployment.py
& $python tests/test_deployment.py
```

[VERIFIED deployment, 2026-10-01] User explicitly requested deployment. Ran `& ".\Quartermaster - Balanced Sorting\Deploy-Test.ps1"` from the workspace root. Full offline suite, source manifest, version checks including --release, and exact source/package/stage/local parity PASS for all 86 production files. Local install: C:/Users/willi/Zomboid/mods/B47ANCEDQuartermaster; stage: C:/Users/willi/Zomboid/Workshop/B47ANCEDQuartermaster; package: dist/current/B47ANCEDQuartermaster-0.3.0-dev.8.zip. Previous local installation backed up under dist/local-test-deployments/20261001-161303; deployment.json records paths. PZ was closed during deployment. Default mod selection enables B47ANCEDQuartermaster and excludes Quartermaster/legacy sorting IDs; per-save selections must also use standalone B47. Installed upstream files remain untouched. No game/server launch or Workshop publication. Native dev.8 load/Save/presets/movement and dedicated gates remain UNTESTED.

[RUNTIME GATE] Test dev.8 with only B47ANCEDQuartermaster enabled: verify identity log; open the owned window; save/reopen/reload manual rules; create/edit/delete/recreate/link presets and verify world persistence; sort keys and ordinary items; confirm controller/bounds and reconnect snapshots. Dedicated MP must verify ownership/conflicts, late join, notifications and preset edits during TAKE/PUT. G6 standalone NOT TESTED; G7 dedicated NOT TESTED; G8 BLOCKED. Prior dev.6 local Save PASS is historical and does not certify this new shell or library.

## Historical source correction — 0.3.0-dev.7

[VERIFIED source / user report] User tested Sort (B47ANCED) with both Vehicle Key and Key Ring selected. Vehicle-named car keys were skipped while the keyring moved with its contents. Catalog.destination previously matched only InventoryItem.getDisplayName(), whereas the picker derives the vanilla Vehicle Key entry from its ScriptItem display name. Vanilla defines CarKey as a key and KeyRing as a container; moving a selected keyring with its contents is expected native behavior.

[CHANGED] Compatible bug fix within the existing 0.3.0 development milestone: explicit rules now match either the instance display name or its script display name. Custom-name rules retain exact-name behavior; explicit rules still outrank category rules and obey server-resolved target/access/capacity checks. No inventory mutation, recursion into keyrings, data migration, network protocol, category or sandbox behavior changed. This is matching correctness, not a configurable gameplay policy; no new option is warranted.

[TESTED offline] Full tests/run_tests.py PASS, including regression cases for renamed vehicle keys, both key/ring selections, Vehicle Key not matching rings or house keys, retained instance-specific rules, rejected eligibility and category-priority precedence. scripts/check_versions.py --root . PASS and scripts/check_deployment.py source manifest PASS. Commands use C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe. Upstream files unchanged; 29-language parity PASS.

[VERIFIED deployment, 2026-10-01] At explicit user request, ran `& ".\Quartermaster - Balanced Sorting\Deploy-Test.ps1"` from the workspace root. Full offline suite, key regression, version checks including --release, and exact 83-file source/package/stage/local parity PASS. dev.7 is installed at C:/Users/willi/Zomboid/mods/B47ANCEDQuartermaster and staged at C:/Users/willi/Zomboid/Workshop/B47ANCEDQuartermaster. Current ZIP: dist/current/B47ANCEDQuartermaster-0.3.0-dev.7.zip. Previous local install is preserved under dist/local-test-deployments/20261001-153046; deployment.json records archived paths. PZ was closed during replacement; no game launch or publication performed.

[RUNTIME GATE] Native dev.7 loading, key movement and dedicated multiplayer retest are pending. G7 NOT TESTED and G8 BLOCKED. Previous dev.6 packages remain unchanged under dist/history/0.3.0-dev.6. Historical local Save PASS remains dev.6 evidence, not dev.7 movement proof.

## Current deployment and Save gate — 2026-10-01 / 0.3.0-dev.6

This section supersedes deployment, identity and version statements in the dated records below.

[VERIFIED source] B47ANCE'd Quartermaster / Mod ID `B47ANCEDQuartermaster` / Workshop `3807217050` / version `0.3.0-dev.6`. The dev.6 prerelease is a compatible identity correction within the existing 0.3.0 milestone. Current Lua globals/modules, network traffic, sandbox declarations and owned persistence use the canonical namespace. No selection or movement redesign. `require=Quartermaster` remains for the existing frontend; no new upstream dependency or copied third-party implementation.

[VERIFIED source; TESTED offline] Legacy `B47ANCEDSorting`, `QuartermasterSorting`, `QuartermasterSimpleSorting` recognition exists only in the read-only Migration module. Present canonical container configuration takes precedence, including empty selections; invalid present data fails closed. An authoritative Save imports lazily into the canonical namespace and never writes legacy namespaces. Older LSBox storage remains a read-only import. Existing server sandbox values prefer current values, with fallback to available legacy values; native registration/defaulting may hide old values, so native existing-save sandbox migration is UNKNOWN and custom settings require review in the canonical page.

[VERIFIED old log/source comparison] The prior Save trace at Authority.lua:44 matched the bare next(value) implementation in 0.2.0-dev.2 staging. That establishes stale-code execution, not a defect in current Store.commit and not conclusive proof of which copy/cached Lua supplied the trace. Two remaining current movement emptiness checks were fixed in dev.5. The dev.6 production bare-next audit passes; Java iterator :next() is retained.

[VERIFIED deployment] Clean source, ZIP, Workshop staging and local installation have exactly 83 identical SHA-256 production files, checked against scripts/production-files.json. Current stage: `C:/Users/willi/Zomboid/Workshop/B47ANCEDQuartermaster`; live test mod: `C:/Users/willi/Zomboid/mods/B47ANCEDQuartermaster`; package: `dist/current/B47ANCEDQuartermaster-0.3.0-dev.6.zip`. Three stale discoverable copies were archived: local QuartermasterSorting dev.3, Workshop QuartermasterSorting 0.2.0-dev.2, subscribed own Workshop QuartermasterSimpleSorting 0.1.4. Exact original paths/backups are in `dist/local-test-deployments/20261001-005754/deployment.json`. Installed upstream Quartermaster is unchanged. Steam could redownload its subscribed old copy; enabled legacy IDs must remain absent in the native startup log.

[VERIFIED tooling] Deploy-Test.ps1 refuses deployment while a native PZ process is running, builds clean staging, archives only known owned identities, installs from source, updates the default mod selection and fails on mismatched files. The initial deployment's default preset lacked Quartermaster; the user was explicitly told to enable it for the test and the generator was corrected to ensure the dependency on future deployments. Per-save selections are not silently rewritten. No Workshop publication occurred.

[TESTED offline] Full existing Lua regression suite plus identity migration/repeated Save/reopen tests PASS. Deployment gate tests prove extra obsolete files, missing files and changed contents reject. Version checks before/after and package --release version checks PASS; these do not mean gameplay G8 PASS. Localization parity across all 29 languages and unchanged upstream hashes PASS.

Exact commands run from the workspace root (Python executable is C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe):

```powershell
& '.\Quartermaster - Balanced Sorting\Deploy-Test.ps1'
```

That invokes Build-Workshop.ps1 → Build.ps1, including `scripts/check_versions.py --root <project>`, `tests/run_tests.py --package`, `scripts/check_deployment.py --package`, `tests/test_deployment.py`, `scripts/check_versions.py --root <project> --release`, and final `scripts/check_deployment.py --package --stage C:/Users/willi/Zomboid/Workshop/B47ANCEDQuartermaster --local C:/Users/willi/Zomboid/mods/B47ANCEDQuartermaster`.

[VERIFIED native startup, 2026-10-01] Actual PZ console.txt reports loading Quartermaster and B47ANCEDQuartermaster, with `[B47ANCEDQuartermaster] loaded id=B47ANCEDQuartermaster version=0.3.0-dev.6 workshop=3807217050` at lines 231 and 362 across native Lua initializations. No legacy ID loading lines occur in this fresh log. Excerpts and snapshot hash are preserved in `dist/local-test-deployments/20261001-005754/native-startup-evidence.txt`. This is native evidence, distinct from offline mock output. The user subsequently reported testing complete and everything working, explicitly excluding moving/sorting items into containers.

[TESTED native, user-operated] Following the requested Save/reopen/repeat/reload checklist, user reports: "done testing, everything seems to be working, I have not tested moving/sorting items into containers yet." Native Save is recorded as PASS based on that report, with verified current identity. Console inspected through 2026-10-01 01:12:01 contains no Object tried to call nil, exception/stack trace or Authority/Store/Session/MultiContainer failure. Snapshot preserved as `dist/local-test-deployments/20261001-005754/native-save-console.txt`; deployment.json records its SHA-256. Stale-build Save regression resolved for this local test; no further Save changes justified.

[UNKNOWN / evidence limits] UI actions were performed by the user, not automated or directly observed here. Individual selected values, authoritative ModData contents and reload/reconnect outcomes were not independently captured; the user's aggregate success report must not be represented as dedicated MP or detailed persistence telemetry. Legacy-save and custom sandbox migration still lack native-specific evidence.

[UNTESTED / RUNTIME GATE] Native item moving/sorting, executor TAKE/carrier/walk/PUT/return sequencing and dedicated MP/reconnect remain untested. G7 NOT TESTED / BLOCKED on dedicated evidence; G8 BLOCKED. Local Save success does not clear broader extraction/runtime gates.

[DEFERRED] Movement runtime testing, frontend/preset extraction, unsupported sources, UI/features, artwork and publication remain outside this pass. Native Save has a user-reported local PASS only; there is no release-ready claim.

## Historical identity — 0.3.0-dev.4

User-selected identity: **B47ANCE'd Quartermaster**, activation ID `B47ANCEDQuartermaster`, Workshop ID `3807217050`. Source moved to `src/B47ANCEDQuartermaster`; build/test paths and packaging metadata follow the new ID. Lua namespaces, module paths, persistence, sandbox and network identifiers deliberately remain unchanged. This is an activation/branding change within the existing MINOR development milestone, not a gameplay rewrite. Existing saves must change enabled-mod selections; never enable both copies. The project workspace folder retains its old name for tooling continuity.

Only source was renamed. Local installation remains the previously deployed 0.3.0-dev.3 / QuartermasterSorting; Workshop is unchanged. This current identity supersedes activation/version statements in the dated implementation records below. The category audit mirror identifies applicability to unchanged categorizer code, not a new coverage run. Offline regressions and version consistency were rerun; native gates remain untested. No package, deployment or publication is part of this rename.

## Historical boundary — dev.5 and earlier

[VERIFIED runtime log / source comparison, 2026-09-30] Save produced `Object tried to call nil in write`, Authority.lua:44 → Session.save → MultiContainer.onSave in console.txt (session started 14:04:02, log inspected through 14:30:04). The failing line is the old `next(value)` call. Workshop staging under `C:/Users/willi/Zomboid/Workshop/QuartermasterSorting/Contents/mods/QuartermasterSorting` remains 0.2.0-dev.2 and its Authority.lua SHA256 matches the archived prior local install (7b7dfd9df2f54c4fd044eb71bd8010361eed82529cbeeacef9019bd63b75b713). That old module matches the trace; current local 0.3.0-dev.3 has only a four-line forwarding module there. The stack therefore represents old code, although the log does not conclusively identify which copy or cached module supplied it. Restart alone is not proven sufficient while duplicate old-ID copies remain discoverable.

Current source advances to 0.3.0-dev.5 for a compatible Lua fix: two remaining global next() checks in Movement/Trips are replaced by pairs-based emptiness checks. The movement suite now runs with global next=nil, alongside the unchanged full regression suite; all pass offline and current version mirrors pass. Current Store.commit already replaced the obsolete Save/write implementation and contains no global next call. This is source remediation, not a native Save retest. Neither the old staging nor the local installation was changed in this diagnostic pass. Retesting requires deploying the renamed B47ANCEDQuartermaster build, enabling it instead of QuartermasterSorting, keeping its Quartermaster dependency, and restarting the game. Do not enable both activation IDs. Runtime Save success remains UNTESTED for the updated source.

[VERIFIED deployment, 2026-09-30] At the user's explicit request, 0.3.0-dev.3 was installed for local testing at `C:/Users/willi/Zomboid/mods/QuartermasterSorting`. All 82 installed files match authoritative source SHA-256 hashes. Previous 0.2.0-dev.2 installation is preserved under `dist/local-test-deployments/20260930-140134/previous-local-installation`; deployment.json in that directory records verification. Version check and full offline suite passed immediately before installation. This supersedes the older local-deployment statements below; Workshop staging/publication remain unchanged. PZ was not launched and native G6/G7 remain NOT TESTED. Keep Quartermaster enabled for the existing configuration frontend and use Sort (B47ANCED) to test the new owned executor.

[TESTED offline] The demonstrated stale-descriptor bootstrap has been replaced with server-issued handles. Owned persistence, staged Save/Cancel, a native categorizer/catalog and an authoritative destination-ranking primitive are connected and covered by host regressions. This is not a complete standalone mod or a runtime authority certification.

Activation remains QuartermasterSorting with require=Quartermaster. The existing configuration frontend, preset-definition editor/store and item icon lookup still depend on Quartermaster. The new owned Sort (B47ANCED) inventory/loot controls invoke the owned production trip executor, independently of the legacy Distribute Loot trigger. This development source is not a complete standalone replacement. Last local/client and Workshop staging copies remain 0.2.0-dev.2; no deployment, game/server launch or publication occurred in the executor pass. The previously requested developer handoff ZIP is historical, not a release.

Version rationale: 0.3.0-dev.2 introduced the one-item executor; 0.3.0-dev.3 advances the same MINOR development milestone for equipped bag staging, multiple trips and the owned sorting controls requested by the subsequent handoff. Target remains the 0.3.0 standalone milestone, not a released version. Declared current mirrors are synchronized; previous audit sections and released artifacts retain their observed versions. Schema version 1 and taxonomy version 1 remain independent. The category audit data is unchanged and retains its original observation date; its current projectVersion mirror indicates applicability to unchanged categorizer code, not a rerun of coverage.

## Production trip workflow — 0.3.0-dev.3

Quartermaster is the canonical **behavioral reference for sorting execution**. B47ANCEDSorting independently implements equivalent source → carried inventory/bag → walk → destination behavior with the same native PZ timed-action mechanisms. The preceding audit already established the reference sequence, including whole-trip loading before deposits and retained carried items on failed PUT. That sequence was used here; no reference implementation, trip algorithm, constants or class bodies were copied. No post-submission interception investigation was reopened.

### Production path

`SortControls.lua` registers owned inventory/loot-window buttons and native controller menu actions. The visible label is **Sort (B47ANCED)** to distinguish it from the installed legacy mod's Distribute Loot button while frontend extraction remains incomplete. During a run it becomes Stop sorting. Five new UI strings have fallback coverage in all 29 language folders. The handlers do not replace vanilla controls or call Quartermaster. This is a usable sorting entry, not a debugger-only probe.

`Sorter.start(playerNum, sourceContainer, callback)` discovers server-issued targets through the existing authority transport. The original clicked source reference is retained. Server-created incarnation markers associate returned handles with the loaded client objects; it binds only a unique marker that resolves to that retained source, never a same-index replacement. Missing metadata waits at most 15 seconds and fails closed. Source root inventory and equipped/held bags use actor-owned inventory IDs. Server authority independently validates the source and actual source items.

`Trips.lua` snapshots eligible source item IDs **and references** once. It uses the existing Planner for destination selection for each item, preserving explicit-item/category/priority/deterministic precedence. It budgets a trip against native effective container capacity and native maximum carried weight, accounting for equipped bag reduction and planned space consumption in destinations/carriers. Worn and hand-held bags are discovered through vanilla character APIs; root inventory is a fallback carrier. The current trip is planned on the server, not all future trips on the client. This keeps routing authoritative without copying the reference's trip planner. The actual action workflow remains load trip, visit chosen destinations, deposit, return for another load if needed. There is no return walk after the final successful trip.

`Sorter.lua` feeds the existing guarded one-item executor the trip's immutable offers. All permitted TAKE actions complete into their assigned carriers before the first deposit. Loaded operations are retained while the next item loads. Deposits are grouped by selected destination and use native walking; source return uses another native walk. The executor does not choose another box. Each initial item is considered at most once for a dispatched move, preventing repeated source/destination cycling; vanished/replaced initial items are not substituted. Items deferred solely by the current trip's reserved capacity can be reconsidered on the next trip while still the same initial source item. Newly arriving items are not silently added to the run.

Failed per-item validation cancels that item and lets independent eligible work continue. User cancellation, movement/cancel input or uncertain native outcome ends the run and cancels its own pending native action; completed TAKE items remain in their carriers. No rollback transfer is manufactured. Ordinary manual/native actions are not patched. A failed/missing destination, full carrier, exhausted destination or changed rule set does not cause capacity bypass or rerouting of an already-authorized item. Skipped-planning counts and failed-item counts are included in the completion summary.

Operations and runs are transient and actor-scoped, with a 30-minute protocol expiry; initial discovery/marker waits use 15 seconds. A maximum initial snapshot of 4096 items is an explicit protocol safety bound: larger sources reject, never silently truncate. These are technical limits, not gameplay timing settings. Carry budgets use native maximum weight/effective capacity, not an invented load-speed or fill-percentage setting. Existing server sandbox discovery settings continue to define candidate scope. Action durations, animation, movement/pathfinding and inventory replication remain vanilla-owned.

**Accepted authority boundary remains in force:** owned planning/grants and observable exact-reference checks run before native dispatch; after dispatch inventory identity resolution and synchronization use native PZ semantics. Native ModData carries object incarnation metadata; no custom inventory replication exists. The new execution modules have no Quartermaster runtime calls and no direct Remove/AddItem operations.

### Coverage and current limitations

[TESTED offline] Expanded `tests/test_movement.lua` exercises the actual owned Sorter → Authority/Trips/Planner → Executor sequence with a fake native queue: six distinct items, worn bag staging, load-before-deposit order, multiple carry-limited trips, return walks, exactly one TAKE and one PUT per item, all six at the destination, and no duplicated or stranded test items. Cancelling after TAKE retains the item in its bag and releases the run's grants. Tests also verify two owned native control registrations and absence of global native action replacement. Earlier per-item replacement/replay/capacity/cancellation tests and the installed vanilla start fixture still pass.

The production runner currently supports fixed storage discovered by the existing binding system, root player inventory and equipped/held bags. Ground, vehicle/corpse sources and non-equipped/nested source bags are not offered by these controls. This is not a claim of complete parity with every Quartermaster-supported source. Destination rules with unresolved preset links remain excluded because the owned preset-definition store/editor is still unfinished; no runtime fallback to Quartermaster presets is introduced. The categorizer, configuration tree, persistence, rail and Whole Container behavior were not redesigned. Full application standalone activation still awaits frontend/preset/dependency work. These are explicit remaining extraction tasks, not an inventory-authority blocker.

### Required native tests

Use the **Sort (B47ANCED)** button for this code, not the legacy Distribute Loot button. Configure destination rules through the existing combined editor, using direct item/category rules without linked presets for this slice. Use a disposable source with several ordinary items whose combined weight requires at least two trips, and an equipped bag with available space. In SP, listen+remote and dedicated+remote independently:

1. Start sorting from A. Verify native TAKE actions load a carrier before the character walks to B, deposits execute with normal animation/time, the character returns to A only when another load is needed, and every routed item arrives exactly once. Record counts/IDs on server, executing client and remote observer.
2. Use two destinations with explicit-item/category conflicts and differing priorities. Confirm existing routing precedence and capacity behavior. Fill the preferred destination after planning and ensure already-authorized items are not silently redirected.
3. Stop during loading, walking and depositing. Completed TAKE items must remain carried if PUT never dispatched; unrelated manual transfers must continue working. Repeat with keyboard movement/cancel input, a failed path, unequipping/dropping the carrier, death/disconnect and reconnect. Inspect native state before retrying an uncertain run.
4. Use the debugger hold described in the one-item section below for pre-TAKE and between-leg replacement. In a trip the held phase is still visible in `B47ANCEDSorting.Executor.active[0]`; loaded suspended operations are in `B47ANCEDSorting.Sorter.active[0].loaded`. Remove B, create C at its old position, then resume. C must not receive a newly dispatched owned PUT when the replacement is observable before dispatch. Post-dispatch behavior follows the accepted native boundary.
5. Sort from root inventory and an equipped bag; verify TAKE is skipped, the bag is not unnecessarily unpacked, and destinations still come from the server Planner. Confirm Stop sorting on both control surfaces, controller action access, summary text and no Lua errors in client/server console logs.

Exact offline commands remain `tests/run_tests.py` and `scripts/check_versions.py --root .` using the bundled Python shown below. [RUNTIME GATE] SP/listen/dedicated execution, actual ModData replication order, native Lua exception/cancellation behavior and final inventory synchronization are **UNTESTED — NATIVE EXECUTION REQUIRED**. G4/G5 PASS offline; G6/G7 not tested; G8 BLOCKED by unexecuted runtime gates and remaining extraction scope. No deployment, packaging or publication was performed. The earlier one-item section is retained as the dev.2 implementation checkpoint; this section supersedes its one-item/root-only limitations.

## Accepted native boundary and one-item executor — 0.3.0-dev.2

The latest handoff explicitly accepts the boundary and supersedes the architectural-decision stop below:

> B47ANCEDSorting guarantees exact-target authorization and validation through native transfer dispatch. After dispatch, execution inherits vanilla Project Zomboid container-address resolution and synchronization semantics.

This is an intentional project contract, not a claim of completed native certification. No further interception investigation is required. The implementation checks the currently observable retained instance at dispatch; it does not promise stronger post-dispatch identity semantics than ordinary PZ. The vanilla race is not a B47ANCEDSorting-specific defect.

### Implementation and limits

- `shared/B47ANCEDSorting/Movement.lua` owns one transient operation per authenticated player. `Authority.lua` routes its move commands using the existing request/reply adapter. The server resolves the source from its issued session token (or the player's root inventory), looks up the actual item, rejects protected/equipped/attached items and containers, and calls the existing Planner. No client destination, category or rule is accepted. Explicit-item/category/priority ranking is unchanged.
- Server preflight checks source access, carried capacity and destination eligibility. The issued operation retains exact item/source/destination references. TAKE and PUT grants each advance a server phase once; duplicate/wrong-actor/out-of-phase requests fail. Native arrival in carried inventory is confirmed on the server before walking/PUT; successful destination arrival is confirmed without moving anything manually. Changed destination configuration invalidates the operation rather than silently replanning.
- `client/B47ANCEDSorting/Executor.lua` exposes `start(playerNum, sessionID, sourceToken, itemID, callback)` and `cancel(playerNum)`. It queues one native transfer, confirms carried state, queues native walking to an adjacent tile, obtains the PUT grant and queues one native transfer. Existing-carried items use sourceToken `inventory` and skip TAKE. This minimal slice deliberately uses root player inventory as carrier; bag selection, container items, vehicles/floor sources and batching are unsupported, not simulated.
- An original subclass of ISInventoryTransferAction disables merging. Its final `checkQueueList` override is invoked by installed vanilla start immediately before the native request. It checks the authorized local destination instance, source/item identity, eligibility and capacity; a failed check aborts within the subclass's protected start call and uses native cancellation. No global action/network override is installed. SP additionally validates at perform, where native SP mutation happens. This narrow native-method ordering is version-sensitive and has an offline test running installed vanilla start; future engine updates require revalidation.
- Server-issued incarnation markers use native IsoObject ModData replication (`B47MovementInstance`). A process-local weak object map allocates markers; persisted/client marker values never create server authorization. The offer contains marker, square and section metadata. Client lookup searches that square for a unique matching marker, not the current occupant of a supplied object-list index; unavailable/ambiguous markers fail closed. Once found, the client retains object/container references and checks live square membership/section identity through Targets.valid. No index fallback or replacement selection occurs. Native marker delivery order and server/client association require dedicated validation. This is object metadata synchronization, not custom inventory replication.
- Client observation cannot make server and client memory references identical across processes. Server grants validate the server-held record; the local final guard validates its synchronized, retained counterpart. Native integer item ID is reacquired after TAKE only after server confirmation of the original item because client deserialization may produce another reference. Unknown/timeout outcomes are cancelled without rollback or automatic transfer retry.
- The pending operation has a two-minute safety lifetime; transport polling is bounded by the existing request timeout and a 250ms client poll. These are internal expiry/transport constants, not gameplay transfer speeds. Native timing/animations/capacity/walking remain native. Existing server sandbox discovery range/building rules constrain initial planning; operation revalidation checks exact retained targets and access without extending the UI session's origin-distance restriction to the walk. No new meaningful gameplay option is introduced by this one-item API. Carry/batch policy settings are deferred with those features.
- Owned preset definitions remain outside this slice. Destinations with preset links are excluded rather than silently treating unresolved links as authoritative rules. No Quartermaster function is called by either new module. Existing application dependency metadata remains unchanged because dependency cleanup was explicitly excluded.

After an already-completed TAKE, failed PUT/cancellation leaves the item carried. No source restoration, direct ItemContainer writes, custom inventory packets, Java hooks, forced successful completion, UI integration or batch runner is added. Temporary operation/marker authorization does not persist across restart; reconnect must request fresh discovery and authorization. Abandoned server operations expire. Final native outcomes can be uncertain and require inspection; a cancelled native action is not represented as guaranteed rollback.

### Validation actually performed

[TESTED offline, Lua 5.1] `tests/test_movement.lua` covers valid TAKE/confirm/walk/PUT, server-issued destination identity, wrong actor, replayed grants, destination invalid before TAKE, replacement after TAKE, source replacement, item substitution with the same ID, destination override attempts, full destination, cancellation and retained-carried outcomes. Only fixture code simulates native inventory mutation. Installed vanilla `ISInventoryTransferAction.start` is also executed with mocked engine leaves: replacement during its preparation is rejected at the last queue-list check before simulated dispatch; unchanged B permits dispatch. This is not a running PZ engine.

Static suite assertions reject direct inventory mutation calls and LootSorter runtime references in the new modules. Existing full suite remains green, with metadata/29-language parity and unchanged upstream files. Version checker validates all current declared mirrors. Exact commands, from this project directory:

```powershell
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/run_tests.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/check_versions.py --root .
```

No --package/--release check was run because no release artifact was requested. G4/G5 PASS offline for this slice; G6 and G7 **UNTESTED — NATIVE EXECUTION REQUIRED**. G8 BLOCKED pending native gates and remaining standalone work, not because of the accepted native race.

### Exact operator-run native procedure

Run separately in disposable SP, listen+remote, and dedicated+remote environments. Do not overwrite live saves or treat old staging as this build. This task did not deploy or launch anything. For an isolated developer setup, load the owned shared B47ANCEDSorting modules, their owned QuartermasterSorting Configuration/Targets dependencies, and the client Executor; native game modules supply actions. The new executor itself needs no Quartermaster. Full application activation still requires the existing dependency until the separate frontend extraction is complete.

1. Place accessible fixed source A and destination B on the same floor, within configured discovery range and with ample room. Use one ordinary unequipped, non-favorite, non-attached item X. Stand next to A; clear the action queue. Obtain X's exact native getID from the inventory debugger, not by substituting another item of its type. Keep a server and client inventory count/reference snapshot.
2. On the client/SP Lua debugger, run `require 'B47ANCEDSorting/Executor'`. Discover with `B47ANCEDSorting.Authority.request(0,'discover',{scope={x=AX,y=AY,z=AZ}},function(r) B47TestDiscovery=r; print(r.status,r.session) end)` using A's actual square coordinates. Inspect the returned targets and choose A's server source token and B's server destination token explicitly. Coordinates here request discovery, not identity authorization.
3. Configure B through the owned editor or owned authority: request `load` with the discovery session/B token; after success create `B47ANCEDSorting.Schema.empty()`, set `config.items[X:getDisplayName()]=true`, then request `commit` with that returned revision/config and the same token/session. Use a disposable box since this intentionally replaces its config. The server Planner must select B; do not supply a client destination to Executor.
4. Run `B47ANCEDSorting.Executor.start(0,B47TestDiscovery.session,SOURCE_TOKEN,ITEM_ID,function(status) print('B47 one-item result',status) end)`. Watch TAKE, carried inventory, walking and PUT. Require exactly one item leaving A/entering carried/entering B, correct native timing and matching server/client results. Callback `ok` means server-confirmed arrival; `uncertain` or `cancelled` is not success. Inspect nearby inventories for duplicates and refresh/reconnect to check native synchronization.
5. For deterministic pre-TAKE/between-leg tests use a debugger-only tick hold: save `B47SavedTick=B47ANCEDSorting.Executor.tick`, then replace that function temporarily with a wrapper that returns while `B47ANCEDSorting.Executor.active[0]` has phase `grantTake` (before TAKE) or `confirmCarried` (after TAKE). Otherwise call B47SavedTick. On reaching the selected phase, record server item location, remove B and place a distinct replacement C at its old location through normal test-world tools. Restore `B47ANCEDSorting.Executor.tick=B47SavedTick`. Require no TAKE in the first case; in the second, no PUT and X remains carried. C receives nothing. Do not copy object ModData by hand onto C.
6. Repeat with source removal and item removal before TAKE, then with B filled after TAKE. Require no substitute selection and no overflow. Repeat `Executor.cancel(0)` during TAKE, during walking, and while awaiting PUT; record native-safe state without claiming rollback. Try ordinary manual transfers after every cancellation to confirm the sorter has not globally changed native behavior.
7. On dedicated server, retain console logs from both peers, PZ build/JAR hash, mod version and sandbox values. Inspect replicated B47MovementInstance before action start, operation phases/grants, exact item IDs/counts, and callback status. Test a remote observer and reconnect. Marker replication, Lua exception cancellation, engine reach/pathfinding, death/disconnect, capacity and final inventory parity all remain runtime gates. A post-dispatch replacement is measured under accepted vanilla semantics, not advertised as stronger owned protection.

No current native case is PASS. The following dated audit sections explain how the accepted boundary was reached and do not supersede this implemented slice.

## Final PUT lifecycle / architecture decision — 2026-09-30

Version: 0.3.0-dev.1. **Decision: CASE 2 — NATIVE PZ HAS INHERENT POST-SUBMISSION RACE.** This is an API/identity-boundary conclusion, not an observed successful replacement exploit or a native runtime PASS. Stop for an explicit architectural decision; no further hook search, production implementation, packaging or deployment in this pass. This section supersedes the previous suggestion that another Lua investigation could establish end-to-end exact-target enforcement.

### Last Lua-controlled boundary

[VERIFIED installed vanilla source] The PUT action is `ISInventoryTransferAction`, defined in `media/lua/client/TimedActions/ISInventoryTransferAction.lua`. Quartermaster behavior was not re-audited. The relevant lifecycle is:

1. `new` (764 onward) retains `item`, `srcContainer`, `destContainer` as engine object references, plus the character. The destination parent IsoObject is available from the container; the action itself does not replace these fields with coordinates. MP starts with native-duration waiting and a queue list that may merge transfers.
2. `isValid` (11 onward) checks native action conditions. MP invokes native transaction consistency before the action starts. A past validity result does not lock the destination. An owned subclass/composed guard can additionally test the retained exact target through `Targets.valid`, rather than reconstructing it from coordinates.
3. `waitToStart` (249 onward) delays client start for native batching. It is not final submission and cannot be the only identity check.
4. `start` (258 onward) handles already-transferred/no-op cases, preparation and sound/container state, gathers the native queue list, then calls `createItemTransaction(character, items, srcContainer, destContainer)` at 313. That call is the last Lua-to-native submission boundary for the first item. Lua can check its retained references before entering native submission. Simply overriding `isValid` is insufficient; delegating to base start also leaves its preparation calls between the wrapper's check and line 313. A proposed narrow guard must cover that distinction and must not claim an implemented instruction-adjacent hook where none has been added.
5. MP `update` (162 onward) polls native Done/Rejected and duration; it is after submission. Cancellation then is not a guaranteed pre-mutation veto.
6. MP `perform` (477 onward) handles completion/queue advancement; local `transferItem` is restricted to the non-client branch. Additional merged entries submit at 526, so a one-item proof must exclude merging or cover every submission. A guard only in perform misses the first request.
7. The native request is accepted/scheduled and executed on the server. The previously verified execution trace applies to the player-to-world PUT leg. No new private interception investigation is needed to establish this boundary.

### What exact validation can and cannot mean

[VERIFIED owned source] `Targets.valid` checks the retained object's membership in its actual live square and equality of `getContainerByIndex(ci)` with the retained container. `Bindings.target` additionally validates the server-issued record/session, player, live position/type and revocation. A replaced object at the same index is not the retained object. An observable mismatch before submission can cancel PUT without moving the carried item. Checking only equality of `action.destContainer` with another stale reference is insufficient; live membership must also pass.

[INFERRED design capability] Lua can apply that exact-instance check to its retained local target at dispatch. This is a local pre-submission capability, not an existing production guarantee: no owned action wrapper has been implemented. Server-issued references cannot be compared directly to client Java objects in another process. The current server metadata includes descriptors and tokens, not a synchronized incarnation identity; an eventual executor must establish its client target association without claiming that descriptor lookup alone proves the server's instance. A fresh server check plus local retained-reference check does not create an atomic network lock. The offline proof below intentionally uses shared fixture references and does not certify that remote association.

The requested boundary statement is the proposed Case 2 contract:

> Exact-target validation is guaranteed through native PUT submission.
> Post-submission destination resolution is owned by vanilla PZ and has the same replacement race as ordinary native transfers.

Read “guaranteed” here as the contract a guarded executor would need to implement for observable local identity at dispatch, **not a claim that this unfinished build already guarantees remote server-instance identity through submission**. The narrow lifecycle investigation cannot honestly certify a cross-process guarantee from the present fixtures. Production remains disconnected pending the architecture decision and implementation of that association/guard.

### Native identity and baseline

[VERIFIED bytecode from prior trace] The native call serializes world destination ContainerID using square coordinates, object-list index and container-section index. It does not serialize the client ItemContainer reference or B47ANCEDSorting authorization. Server parsing resolves the address, and `Transaction.updateItem` resolves it again before using the current destination container. There is no B47ANCEDSorting incarnation/token comparison in this path. A different object occupying the addressed slot is not rejected merely because it is a different instance; other native checks may still reject a particular attempted transfer.

Ordinary PZ inventory transfers use this same native entry. The previously audited Quartermaster PUT delegates to it too. Thus the post-submission identity limitation is shared native behavior, not introduced by the owned Planner or by splitting TAKE/PUT. That does not prove a reproducible live race, make native acceptance equivalent to server authorization of our routing decision, or authorize relaxing the project's stronger contract. Neither Lua update polling nor late cancellation proves prevention. Under the restrictions against native modification, private/Java interception and replacing transfer mechanics, this pass establishes no way to carry the exact-instance invariant through later server resolution.

### Offline proof and runtime gap

[TESTED offline, Lua 5.1 via lupa, 2026-09-30] Ran an ephemeral Python-stdin fixture experiment using the existing `tests/fixtures/containers.lua`, `Targets` and `Bindings`. Each case used a fresh runtime, server discovery, a retained exact binding, a simulated carried item and a dispatch counter. No native engine or transfer action was executed and no production/test files changed:

- B valid at action-model creation: binding accepted, no dispatch yet.
- Replace B in the fixture square before validation: binding rejected; dispatch count zero.
- Validate B, then replace it immediately before the final guard: final guard rejected; dispatch count zero.
- Unchanged B: final guard allowed exactly one simulated dispatch.

The carried-item fixture remained unchanged in all cases because the dispatch stub never mutates inventory. This proves rejection suppresses the modeled request, not that an actual native action cancels correctly or that a successful PUT moves an item. Both checks used the real owned binding methods; these are not native-runtime evidence. Interpreter: `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`, module `lupa.lua51`. The ephemeral test was deliberately not shipped because this handoff permits only this document to change. Existing reproducible binding regressions remain in `tests/test_bindings.lua` and the suite command `python tests/run_tests.py`.

[RUNTIME GATE] No SP/listen/dedicated PUT test was performed. G7 NOT TESTED / BLOCKED pending architecture decision; G8 BLOCKED. Do not claim live post-submission race proof. If the project explicitly accepts the native boundary, the next one-item implementation must independently establish the retained client target association, validate server planning and between-leg state, guard every permitted submission, and keep invalid PUT items carried. Runtime tests must distinguish replacement before validation, after validation but before submission, and after submission; record native/server/client results separately. The last case measures the engine boundary rather than a Lua guarantee. No runnable new executor exists in this pass.

**Decision needed:** whether to explicitly adopt native PZ post-submission identity semantics for this feature while preserving exact checks at every owned boundary. This document does not make that acceptance for the user. A decision to retain an absolute server-instance guarantee leaves implementation blocked under the stated mechanism restrictions. Further identical audits will not change that tradeoff.

## Current movement parity audit — 2026-09-30

Project Version remains 0.3.0-dev.1. The player-inventory/timed-action handoff supersedes pursuit of a direct source-to-destination executor and further pre-mutation interception work in this pass. Earlier investigations below are retained as dated evidence, not the current proposed workflow. No production changes, new movement calls, deployment or publication occurred.

### Clean-room scope and evidence

Reference: installed Quartermaster 0.24.0, Workshop 3761216758, inventory sorting execution only. Narrow question: how does one sorted item actually reach its destination, and which native gameplay APIs execute the legs? Inspected the distribution entry points, the sorting executor, carrier discovery, deposit and walking actions. Did not inspect/copy the trip planner's algorithm, adopt its constants, or implement its helpers. SOURCE CODE COPIED: NO. IMPLEMENTATION DERIVED FROM REFERENCE: NO. Findings below describe behavior and native API usage; no new implementation was created.

Reference root: `E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/3761216758/mods/Quartermaster/42/`. Reproducibility hashes for `media/lua/client/`:

- `LootSorter_Core.lua`: e7016876c5042b2e9152591f55c900bac56c6cb8c5b7ab955daae4967692a1d2
- `LootSorter_DepositAction.lua`: e7e4a5b5ba88631d35fb91dc549b48663f44ad1326b0c664f90d8fb29950b5d6
- `LootSorter_WalkAction.lua`: cf51db831023131ecc23d6fd84f40e21fa29e97c40495292153c3e73ba36d685

[VERIFIED source, not runtime] Independent vanilla verification used installed `media/lua/client/TimedActions/ISInventoryTransferAction.lua`, `ISTimedActionQueue.lua` and `WalkToTimedAction.lua`. `ISWalkToTimedAction` is defined in WalkToTimedAction.lua, not a file named ISWalkToTimedAction.lua. Native transfer source/hash and server execution evidence remain recorded below. Remaining independent verification is live SP/listen/dedicated execution, not another reference-mod implementation audit. The reference's mod.info describes a single-player beta; this is not evidence of dedicated multiplayer correctness.

### How Quartermaster actually moves one item

**World source → native TAKE → carried container → native WALK → native PUT → designated world container.** The intermediate can be a worn/carried bag, not necessarily the player's main inventory. It is real inventory ownership. Items already carried skip TAKE and can be deposited directly from their current bag. These are meaningful additions to the proposed two-leg model, not evidence of instantaneous container-to-container sorting.

| Question | Observed execution behavior |
| --- | --- |
| Entry | Inventory/loot/floor distribution controls and controller options call the client sorting entry; the inventory context menu also exposes distribution. Reference locations: DistributeButton.lua calls at 25/67/102; ContextMenu.lua:128; Core.lua:476. |
| Candidate selection | Scans the selected source's items; excludes equipped, favorited and hotbar-held items. Records each item's actual container. This is not an arbitrary whole-world item scan. |
| Planning / destination | Before execution, client gathers designated loaded boxes, resolves current designation/presets, finds adjacent standing tiles, and makes a trip plan. Queued destinations retain container references and walking tiles. This does not implement our server-issued binding protocol. |
| Intermediate | Carriers are player inventory UI carry containers, including bags; carry capacity/weight reduction and native item admission influence eligibility. Main inventory is a fallback carrier. No root-inventory-only guarantee. |
| One item / batching | Each item's load and deposit are queued actions, but the whole trip is loaded before visiting boxes. Multiple trips/actions are queued up front, not one fully completed item followed by re-planning the next. Native transfer merging remains enabled. |
| TAKE | A reference transfer subclass invokes vanilla ISInventoryTransferAction with source and chosen carrier. The sorter does not directly Remove/AddItem. If the item is already carried, TAKE is omitted. |
| Walking | Uses a subclass of native ISWalkToTimedAction toward an adjacent free tile. Source loading assumes the current source is accessible; subsequent trips walk back to the starting square. Walking can fail or be cancelled. The reference adjusts fast-forward around walking; native pathfinding remains responsible for the walk. |
| PUT | The same native transfer superclass handles carrier-to-box transfer. This is a separate operation after the walk. No explicit authoritative server acknowledgment/revalidation of an owned destination handle is inserted between legs. |
| Timing / animation | Delegates successful transfers to vanilla action start/perform. Native weight/traits/container timing and loot/self-transfer animation apply; MP waits for native transaction duration/completion. No instantaneous successful transfer is introduced by the sorter. |
| Capacity / invalid state | Destination capacity is considered in planning, then the reference consults native transfer validity when an action starts. A rejected start is skipped without moving the item so later queued work may continue. Missing-source handling is enabled. The reference's permissive validity override is not itself a safety guarantee and will not be copied. |
| Failure after TAKE | Skipped PUT leaves the item in its carried container. No automatic rollback or search for another destination was found in this execution path. A later native rejection/cancellation is not proof that all pending actions continue. |
| Interruption | Native transfer stop cancels its transaction and delegates to the base timed action. Walking cancels on movement/cancel input or pathfinding failure. The reference preserves stop behavior; queue reset can discard remaining work. Another action's effect depends on native queue handling; no live interruption result has been observed here. |
| Source/item invalidation | Start-time native validity and missing-item handling determine whether a queued transfer proceeds/skips. No source replacement/identity protocol was found. Item disappearance must not be interpreted as successful arrival. |
| Destination invalidation | A start-time rejection may skip a deposit; the reference does not establish an exact-target guarantee through later native execution. A stale reference is not a server-side authorization. |
| Destination is player | Player-carried containers are intermediate carriers, not intentional terminal sorting destinations in the inspected designated-world-box path. Do not add player inventory as a new terminal routing feature. |
| MP | The inspected successful transfer delegates to vanilla ISInventoryTransferAction.start, whose client branch calls createItemTransaction. Server native mutation/replication still applies separately to each leg. The reference's planning is client-side; its use of native transfer does not prove server authority over routing choices. |

### Independent one-item design assessment

The owned server Planner, schema, binding and categorizer remain appropriate. A future independently implemented one-item coordinator would retain the server-selected item/source/destination, validate both endpoints before TAKE, use native TAKE into a supported carried container, confirm the item's authoritative arrival, walk, then revalidate the destination and eligibility before requesting native PUT. Cancellation or failed PUT must leave a completed TAKE in the carrier; no rollback, coordinate fallback or replacement target. Existing-carried items skip TAKE. No batching, new carry-budget settings, custom timing or global queue wrappers are introduced in this pass.

This describes a possible coordinator, **not an implemented or proven-safe execution path**. Server-side Java item reference identity must not be confused with client replica identity; successful native deserialization can replace the client reference while preserving the native ID. Server confirmation, not a stale client reference or action completion alone, would determine progress.

**Fresh reassessment: the two-leg model adds a useful validation boundary but does not establish the requested exact-target guarantee during PUT.** Independently checked vanilla ISInventoryTransferAction.start:313 submits the native transaction with the current source/destination; its multiplayer branch does not execute local transferItem in perform. Thus for PUT, a server check can validate B, the client submits Player→B, and native execution can later resolve the same address to C. The existing native trace applies to this particular PUT leg as well as direct transfers. The carried intermediate changes the legitimate failure location to player inventory; it does not change destination identity resolution. No new investigation of private hooks was pursued.

Replacement already observable **before** the between-leg validation could be rejected by the existing server binding. Replacement **after** that validation or native PUT submission remains unproven, as does preventing a modified client from substituting another native destination while claiming authorized sorting completion. Native server validation of an ordinary transfer is distinct from enforcing our chosen routing target. These are [INFERRED] failure possibilities from the verified API sequence, not observed runtime failures or a claim of a vanilla exploit.

Under the handoff's unchanged exact-target rule and section 29 authority stop condition, production one-item execution is **NOT IMPLEMENTED**. No new runtime calls to Quartermaster were added. This is not stopping because the carried workflow was absent (it was confirmed), nor because a public timed-action API was missing (it was identified). It is stopping because the corrected workflow does not yet demonstrate the required end-to-end MP target authorization. No unsafe native call was added merely to produce a nominal implementation milestone.

### Gate reassessment and remaining tests

[VERIFIED source] Behavioral/API audit complete for this narrow scope. Version remains unchanged because no production behavior changed. Only this status document changes in this pass. G6 NOT TESTED; G7 BLOCKED / NOT TESTED for exact-target enforcement on the PUT leg and absent dedicated execution; G8 BLOCKED. Native movement was not run. The earlier direct-transfer architecture is superseded; its blocked result was not automatically treated as the gate result for this design.

Next native behavioral observation, if the operator runs a disposable save: use one inert item X in source A and one designated destination B; request distribution, observe/log X entering the player's actual carrier, interrupt while walking before PUT, then inspect that carrier and A/B. Expected reference behavior is X retained in the carrier, not rollback to A. This is an observation procedure, not proof of the standalone path. No game/server launch is authorized or performed here.

The eventual owned one-item acceptance matrix remains A–J from the new handoff: normal two-leg arrival; B invalid before TAKE (X stays A); B invalid after TAKE (X stays carrier); invalid source; missing item; interrupted TAKE; interrupted between legs; capacity rejection; replacement receives nothing; ordinary manual movement unaffected. Run SP, listen and dedicated remote-client separately and retain server/client IDs, inventory counts, cancellation and synchronization logs. Additionally distinguish replacement before PUT validation from replacement after PUT submission; passing only the former cannot certify the unchanged exact-target promise. No runnable protected one-item harness exists yet, so none of these are labeled PASS.

Validation command for this documentation-only pass: bundled Python `scripts/check_versions.py --root .`. Production source parity with the historical developer handoff is checked separately. Existing offline regression results retain their original dates; they are not native movement evidence.

## Pre-mutation authorization follow-up — 2026-09-29

Version remains 0.3.0-dev.1. [VERIFIED source/bytecode] This pass inspected only the final ordinary transfer boundary and its ItemContainer lifecycle/admission methods in the previously identified installed JAR (SHA256 e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33). No third-party mod implementation was inspected. Production, Planner, UI, dependencies and the baseline probe remain unchanged.

**Result: STOP / BLOCKED under the latest handoff section 25.** No usable cancellable extension surface or safe native-request authorization correlation has been established. This is a bounded finding about the inspected path, not proof that instrumentation is impossible. Do not add a simulated token check and describe it as native enforcement.

### Final boundary findings

- `Transaction.updateItem(TransactionEntry)` is private. It owns resolved item local 2 and the entry's resolved source/destination containers. The ordinary path removes attached/equipped state at offsets 1128–1164, sends the source removal packet at 1218 or 1261, then invokes `ItemContainer.Remove(item)` at 1272. A guard placed only inside Remove is too late to prevent the already-sent replication notification; throwing there is not a proven clean rejection.
- `ItemContainer.Remove(InventoryItem)` invokes `InventoryItem.OnBeforeRemoveFromContainer(source)` at 48, before `ArrayList.remove` at 56. Despite its promising name, this is a void Java lifecycle method, not a cancellable Lua event. The InventoryItem base implementation is a single return. It has no destination, actor or transaction parameter. Subclass overrides are not certified here; overriding an item subtype would not intercept every existing native item or establish a general authorization boundary.
- `ItemContainer.addItem(InventoryItem)` delegates to `AddItem(InventoryItem)`. The latter assigns the container at 93 and inserts into its list at 101; `OnAddedToContainer` at 146 is after mutation. It cannot provide a pre-removal veto or rollback guarantee.
- `ItemContainer.isItemAllowed` does expose a Lua `getAcceptItemFunction` callback through `protectedCallBoolean`. However, neither final `updateItem` nor the inspected Remove/AddItem overloads calls that admission predicate or `isRemoveItemAllowed`. The earlier native acceptance check therefore cannot close the subsequent re-resolution gap. Replacing per-container admission functions would also affect ordinary transfers and does not provide native transaction/actor correlation.
- Wrapping the client Lua timed action or a custom server command cannot intercept the later private Java method. Previously traced special `OnProcessTransaction` and clothing events are void notifications, not an ordinary transfer authorization veto. Calling a public validator from Lua is not installing a validator into this execution path.

### Required bridge boundary and unresolved protocol

[INFERRED design requirement, NOT implementation] A native intervention would need to cover the ordinary branch before equipment changes/source notifications and retain or recheck the exact resolved references at mutation, with no intervening callback able to invalidate them unnoticed. Compare Java reference identity for item/source/destination plus the authenticated actor/session against server-owned authorization; ID/type/coordinates alone are insufficient. A private-method bytecode injection would be version-fragile instrumentation, not an exposed stable API. No loader, transformer or dedicated-server hook is established or installed by this pass. Java policy was read; its permission to investigate Java does not itself prove an interception facility exists.

The native wire entry still has no owned token. A byte transaction ID alone is reusable and client-controlled; a separate Lua command keyed only by that ID does not establish ordered, collision-safe association to this exact native transaction object. A future bridge must bind server-issued authorization to a specific participating native transaction at ingress, preserve that association until execution, reject malformed/missing/used protected authorization and leave unrelated vanilla requests untouched. An unmarked vanilla request must never be reported as authorized sorting completion. A client flag cannot issue permission. No such correlation is implemented, so actor checks, protected/vanilla isolation and replay prevention remain UNKNOWN rather than PASS.

Consume only after exact-reference/actor/lifetime checks at the protected native boundary and before the first permitted side effect, once native prechecks have succeeded. If execution then fails, do not automatically reuse an uncertain authorization; inspect authoritative outcome and issue a new authorization only through fresh validation. These are requirements for a future bridge, not tested semantics. A consume-only Lua manifest cannot enforce them.

### Validation and native next step

[TESTED offline] `tests/audit_movement_api.py` now asserts the exact overloads, empty base lifecycle method, private transfer method, absence of direct admission/Lua callbacks in Remove/AddItem and notification-before-removal order in the inspected ordinary branch. Bytecode offsets intentionally fail on engine changes requiring reinspection. The first new assertion accidentally selected an earlier special-case Remove; it was corrected to pin the inspected ordinary branch at 1272. This diagnostic verifies source facts only.

Commands from the project directory, using `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`:

```powershell
python tests/audit_movement_api.py
python tests/run_tests.py
python scripts/check_versions.py --root .
```

[RUNTIME GATE] UNTESTED — NATIVE EXECUTION REQUIRED. No authorization harness is available to run: extending the baseline probe without a proven hook/correlation would misrepresent its protection. All required native authorization cases A–H, actor mismatch, listen and dedicated execution remain NOT TESTED. G7 BLOCKED / NOT TESTED; G8 BLOCKED. The immediate next engineering step is to establish a dedicated-server-capable native interception/ingress association under the Java policy; stop conditions prohibit production movement meanwhile.

Once that isolated bridge exists, the first exact manual test is: dedicated server plus remote client, one inert item X in A, empty fixed B; record server-held references and issue one authorization for that actor. Pause the protected transaction after authorization but before execution, replace B with C at the same native object/section slot, release execution, then snapshot server and client. Required logs: correlated authorization/transaction, actor check, actual-versus-authorized reference mismatch, REJECT before consume/notification/mutation; A still contains X once, B/C receive nothing, clients agree. Repeat unchanged A/X/B for success (one consume, one move, native synchronization), then replay, source/item/destination substitution, wrong actor, missing/invalid protected authorization and an unrelated vanilla move. These steps are a future acceptance procedure, not runnable commands for the existing unguarded baseline probe.

The user-requested developer handoff ZIP created before this follow-up is an immutable historical source snapshot under `dist/handoffs`; it is not a runtime/G8 release and does not contain this follow-up. No new archive, deployment or publication was performed in this investigation.

## Current narrow movement investigation — client initiation, server execution

This section answers the subsequent native-movement-authority handoff. It supersedes the earlier suggestion that a client-originated transfer is itself disqualifying. Production remains unchanged at 0.3.0-dev.1. Only tests/diagnostics and this report changed. No third-party reference mod was needed or inspected in this pass; the trace follows installed vanilla Lua and Java bytecode.

**Result:** the normal multiplayer container path is client-initiated and server-executed, with client-side animation and replicated inventory state. That architecture is compatible with server-authorized sorting in principle. However, an out-of-band Lua movement manifest is not enforced by the inspected native request/execution path. Native world-container addresses are re-resolved by square/object/section indices at execution. There is no established binding from that operation to the owned exact-reference authorization. Investigation is therefore PARTIAL / BLOCKED, not PASS. UNTESTED — NATIVE RUNTIME REQUIRED. G7 remains BLOCKED / NOT TESTED; G8 remains BLOCKED.

### End-to-end vanilla path

[VERIFIED installed source/bytecode; not runtime evidence]

1. `ISInventoryPane:transferItemsByWeight` (client ISUI/ISInventoryPane.lua:632; call at 655) handles inventory/loot transfers and drag/drop. For an ordinary item it queues `ISInventoryTransferUtil.newInventoryTransferAction(character, item, item:getContainer(), destination)` through `ISTimedActionQueue.add`. The shared TimedActions/ISInventoryTransferUtil.lua constructs `ISInventoryTransferAction` for ordinary inventory items; corpse-specific paths are separate.
2. `ISInventoryTransferAction:isValid` checks native eligibility. `start` sets client wait-for-finished and calls `createItemTransaction` (line 313), passing actual item/source/destination references. `update` (around 162) polls native transaction completion/rejection and updates animation timing. MP `perform` does not perform the direct Lua transfer (around 477–510); SP is a separate direct-action branch.
3. `LuaManager.GlobalObject.createItemTransaction` calls `TransactionManager.createItemTransaction` only in client mode. The manager performs consistency checks, constructs an `ItemTransactionPacket`, registers its local tracking entry, writes the packet through `GameClient.connection`, and sends PacketType.ItemTransaction. The byte transaction ID tracks this protocol; it is not an unforgeable sorting permission.
4. `PacketTypes.PacketType.onServerPacket` invokes `parseServer`, packet consistency and configured anticheat checks, then `processServer`. The default `INetworkPacket.parseServer` delegates to the packet's parse. `ItemTransactionPacket.parse` reads transaction ID/state, PlayerID, integer item IDs and source/destination ContainerID for each entry. `ContainerID.parse` resolves the native address with `findObject`.
5. `ItemTransactionPacket.processServer` (bytecode 35–75) calls the real `TransactionManager.isConsistent` for each entry, using the item ID and resolved containers. For a valid Request it sets time data, registers the transaction and returns Accept; otherwise Reject (96–179). This is the real native server validator, distinct from the misleading server Lua wrapper that returns true without validation.
6. `TransactionManager.update` runs the accepted, due transaction on the server (0–64). It calls `Transaction.update`, which invokes `updateItem` for its entries. Crucially, `updateItem` first calls `sourceId.findObject()` and `destinationId.findObject()` again (0–11), then obtains the exact integer item ID from the re-resolved source (`getItemWithID`, 218–226). Missing source/item/destination can fail the transfer; an equivalent item name/type is not substituted.
7. On the ordinary container path, `Transaction.updateItem` sends source removal notification, calls source `Remove(item)` (1264–1272), adds that item to the destination with `addItem(item)` (1358–1366), and sends destination addition notification (1458–1551). This is authoritative server mutation. Special floor/corpse/clothing/moveable operations have additional branches and are not covered by the minimal ordinary-item probe.
8. Server remove/add packets reach the inventory owner or relevant world observers. `RemoveInventoryItemFromContainerPacket.processClient` removes IDs from the addressed container; `AddInventoryItemToContainerPacket.parse/processClient` loads serialized item data, checks duplicate IDs and applies additions. Client Java object references can consequently differ from the original client item despite preserved native ID. The server transaction sends Done after successful update; `ItemTransactionPacket.processClient` updates tracking and overlays. Timed action completion then follows the native state. `TransactionManager` also has rejection/exception cleanup and client timeout handling; exact late-rejection/order behavior remains a runtime test, not a promised rollback.

The common ordinary-item path takes explicit source/destination containers, supporting player→world and world→player requests, and structurally world→world requests. UI drag/drop callers exist; practical reachability and world→world execution must be verified in the installed runtime. This trace does not claim arbitrary remote-distance transfers, floor handling, or nested-bag parity.

### Required answers and identity boundaries

| Question | Evidence-based answer |
| --- | --- |
| 1. Normal MP transfer path? | Inventory pane → transfer utility → native timed action → ItemTransaction packet → native server validation/scheduling → Transaction.updateItem → inventory packets/client replicas. |
| 2. Who initiates? | The ordinary MP Lua entry originates on the client. The server decides native acceptance and executes the authoritative mutation. |
| 3. What does the server validate? | The native consistency routine checks resolvable destination, source membership by item ID, destination item admission, safehouse rules, pending item/container-chain conflicts and reserved weight/capacity. Vehicle-specific distance checks exist. Generic packet checks/anticheat precede it. Do not infer all mod-specific lock, reachability, equipment/favorite exclusions or nested/count policies from those checks; owned eligibility still applies. |
| 4. What mutates inventory? | Server Transaction.updateItem calls ItemContainer.Remove/addItem on the ordinary path. Clients apply the server's inventory packets; they do not authoritatively perform the action's normal direct-transfer Lua branch in MP. Classification A (SERVER EXECUTES), with client request/animation/replication stages. |
| 5. Exact item identity? | Integer InventoryItem.id (getID), encoded per transaction entry and looked up inside the resolved source. Retain the authoritative item reference plus ID/source for a short-lived owned authorization. It is not display name, type, list index, or a proven never-reused global lifetime ID. Special floor/moveable cases can use sentinel IDs and are excluded from this probe. |
| 6. Container identity? | Fixed ObjectContainer: x/y/z + object-list index + container-section index. PlayerInventory: native PlayerID; an inventory bag additionally uses its containing item ID. Vehicles/world-item containers have separate native formats. Native IDs are addresses, not B47ANCEDSorting exact-placement handles. |
| 7. Synchronization? | Server-issued remove/add inventory packets and ItemTransaction Accept/Done/Reject state. World data goes to relevant observers, player inventory to its owner; client handlers apply by IDs and refresh associated native state. No custom raw inventory synchronization is required or implemented. |
| 8. Can our selected destination safely feed it? | It can identify the intended destination initially, but manifest-only Lua dispatch has not proven exact-target safety through native execution. Both endpoints are re-resolved; the native path does not consult our binding/token. Production connection remains prohibited. |
| 9. Must native initiation be client-side? | The ordinary exposed createItemTransaction Lua API is client-only. This is acceptable in principle. Java Transaction.set also contains a server Accept branch, but no safe owned server integration is proven by that fact. |
| 10. What prevents destination substitution? | Nothing in the inspected native packet fields/ordinary handler checks our manifest. Vanilla eligibility limits native requests, but another vanilla-eligible destination is not tied to our planner decision. A cooperative client check is not a server-enforced boundary; post-transfer observation cannot undo a wrong-target write. |
| 11. Remaining stale races? | Item disappears/moves; source/destination is removed, unloaded, replaced or shifted in the object list; capacity/access changes after acceptance; disconnect/cancel; reused/delayed instructions. The address can be reinterpreted at request parse and again at execution. Native validation does not establish original-placement equality. |
| 12. Exact proof required? | A dedicated server + remote-client one-item transfer with a server-enforced guard at the native acceptance/execution boundary, showing unchanged exact item/source/destination identity before mutation, successful replication, and pre-mutation rejection of substituted/stale targets and replay. The baseline probe below tests native transport only and cannot satisfy the missing guard proof. |

PlayerID.parsePlayer ordinarily derives a local player's identity from the connection and player index, with other native lookup branches. No broad native anti-cheat/security claim is inferred here. B47ANCEDSorting must continue deriving its own actor from the authenticated command sender.

Native capacity/chain validation is visible at acceptance; `updateItem` does not rerun the whole consistency routine before its ordinary mutation. Downstream APIs may enforce additional constraints, but late capacity/access changes, nested cycles, recursive item-count limits and movement while another native transaction is pending remain required runtime cases. Client `ISInventoryTransferAction:isValid` includes recursive item-count and nested/consumed-item checks. Do not claim all client checks are independently enforced at every server stage.

### Why a Lua manifest alone does not close the gate

`ContainerID.setObject` records coordinates, object index and section index; `findObject` resolves ObjectContainer by current square object-list membership and `getContainerByIndex` (ObjectContainer branch 676–773). `Transaction.updateItem` discards earlier cached endpoint resolution and repeats it. A slot occupied by replacement B′ is not tested against the old bound B reference. This is a source-supported race hypothesis requiring a native reproduction, not a claim that a live duplication/exploit was demonstrated.

The native entry contains only itemId/sourceId/destinationId. The packet also carries transaction state/ID, player identity and operation-specific extra data. `extra` has built-in clothing/operation semantics; it is not a verified opaque authorization extension and must not be repurposed as our token. The inspected generic dispatch and processServer contain no Lua event veto. `OnProcessTransaction` branches observed in updateItem concern special moveable/floor actions and return through void event calls; they are not a general cancellable hook for ordinary container transfer.

Proposed authorization contract, **not implemented**: server picks one item through the owned Planner, retains exact item/source/destination references and bound handles, and issues a short-lived one-use operation identifier tied to the actor/session. A native-side guard must match that authorization when accepting the native request and revalidate the same references after final address resolution immediately before mutation. Only then may the existing native validator/mover/synchronization run. Completion verifies exact authoritative inventory outcome before marking the move complete. Unknown/expired/replayed/mismatched requests reject; no rollback-based authorization and no reinterpretation of coordinates.

That guard has not been established through exposed Lua. A narrow native bridge/interception investigation may be necessary under the workspace Java policy, but no bridge is added or assumed correct. A server Java transaction wrapper is also only a candidate: it must preserve native reservations and prove exact-reference validation through execution, including the native re-resolution and any intervening item lifecycle callbacks. Merely calling public Java methods or checking on OnTick is not that proof. Ordinary vanilla user transfers must remain separate from owned sorting authorization; a malicious executor must not be able to label an unrelated vanilla request as an authorized sort completion.

### Minimal native probe — isolated, manual, untested

`tests/probes/NativeTransferProbe.lua` is an original, dependency-free diagnostic, outside production source/build input. Loading it only defines functions: no events, commands, automatic transfers, spawning or world mutation. It contains no movement manifest and makes no claim to secure native packets. An explicit client/SP `transfer` call queues one ordinary vanilla timed action; the server observation side never initiates client actions. It refuses self-transfer, duplicate setup labels, retry, stale held endpoints, changed item identity, busy queues, nested bags, vehicles/corpses, equipped/favorite items and failed immediate admission/capacity checks.

For an operator-run disposable test save:

1. Manually load the probe through a separate diagnostic mod's `42/media/lua/shared/NativeTransferProbe.lua` on each peer (normal Build 42 mod layout, including common folder). Keep it outside the production mod. No deployment is performed by this task. Quartermaster and Better Sorting are unnecessary for this probe. Obtain/debug-inspect actual source/destination references on each peer and the same native item ID; do not select an item by name or use a substitute if missing.
2. Use one ordinary, inert, unequipped, non-favorite item, an empty destination with ample capacity and reachable stationary containers. Hold source/destination references before the attempt. For player→world use `player:getInventory()` as source; reverse for world→player. For world→world hold two distinct loaded fixed storage sections. Initial operator lookup may use a square/object/section to obtain a reference, but the probe freezes and subsequently checks that reference; this is manual setup, not a production authorization protocol.
3. On the dedicated/listen server and the executing client, call `B47NativeTransferProbe.watch('one', source, itemID, destination)`. It must print source=1/destination=0 and both endpoints live. In SP arm once. Use the server's actual item ID; native client/server references are intentionally not compared across processes.
4. On the client or SP only, call `B47NativeTransferProbe.transfer('one', player)`. Perform no other timed action. Let the native action finish, then on both peers call `B47NativeTransferProbe.snapshot('one')`. Require source=0/destination=1, live endpoints and matching ID/type. On the server/SP require destinationSameReference=true; client deserialization may legitimately produce a different Java reference. Compare server and client results and logs. Counts cover these two containers, not a global duplicate scan; inspect nearby/affected inventories too before claiming no loss/duplication.
5. Repeat with fresh labels and reset items for player→world, world→player and supported world→world; separately SP, listen and dedicated/remote. Retain logs/build/hash/sandbox context. Test a second item of the same type to show it was not substituted. An uncertain attempt is inspected on both peers, never retried automatically.
6. Before enqueue, replace a held endpoint or move the item: the probe must refuse. This tests only its local guard. For the critical after-authorization/after-Accept race, a controlled native test barrier must hold the transaction before updateItem, replace B in the same slot, then release it. Record whether vanilla reaches B′. Do not call this race passed merely because the pre-enqueue guard worked. The required future guarded path must reject before mutation when B′ is present, when a different destination is supplied, or when the one-use operation is replayed.

No native sessions were launched or exercised here. The isolated probe's Lua load/guard/snapshot behavior was tested offline only. Until a native guard exists, the one-item baseline can demonstrate vanilla movement/replication, but even a successful baseline cannot close the owned movement-authority gate. Section 20's destination-substitution stop condition remains active; production movement stays disconnected.

### Reproducible evidence commands

From the project directory, with the same bundled Python used by the existing suite:

```powershell
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/audit_movement_api.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/inspect_native_transfer.py zombie.network.packets.ItemTransactionPacket processServer processClient write parse
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/inspect_native_transfer.py zombie.core.TransactionManager update isConsistent
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/inspect_native_transfer.py zombie.network.fields.ContainerID setObject findObject
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/inspect_native_transfer.py zombie.core.Transaction updateItem
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/run_tests.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/check_versions.py --root .
```

The expanded audit asserts the observed call-chain/identity facts and prints native source hashes. Existing regressions plus the isolated probe guard tests pass offline. No production version change, deployment, package, publication, window/preset/dependency work or taxonomy/planner redesign occurred. Source inspection establishes the architecture; it does not establish successful live transfers or a secure owned authorization hook.

## Previous completion handoff follow-up — historical investigation step

The 2026-09-28 completion handoff was read after the preceding implementation pass. Its section 26 says to STOP when native movement authority cannot be established or a required movement API is ambiguous. The focused native movement inspection below reached that condition. No production Lua, taxonomy, target binding, dependency metadata or installed mod was changed in this follow-up. Added only a reproducible read-only movement audit and this authoritative record. The owned window/preset work has not been completed; no standalone completion is claimed.

### Baseline and ownership review

There is no Git repository or supplied 19-file diff in this workspace. The preserved 0.2.0-dev.2 source snapshot was compared byte-for-byte with current source: 7 new files and 66 changed files, including 58 locale files. This is the available archived baseline, not an invented 19-file change set. The current Model/MultiContainer/Session/Configuration/Targets changes and seven new owned modules were reviewed against their current responsibilities. Existing standalone systems were not reimplemented or re-audited; category coverage evidence above remains from its original run.

| Surface | Current owner / boundary |
| --- | --- |
| UI window | Quartermaster Picker; owned Adapter and MultiContainer extend it. This remains a runtime dependency. |
| Session | Owned QuartermasterSorting/Session.lua; per-handle staging, acknowledgements and Cancel. |
| Catalog | B47ANCEDSorting/Catalog.lua for the bound tree; initial adapter/icon contracts still use upstream. |
| Categorizer | B47ANCEDSorting/Categorizer.lua; no Better Sorting provider. |
| Bindings | B47ANCEDSorting/Bindings.lua; server-issued exact-reference handles. |
| Authority | B47ANCEDSorting/Authority.lua; configuration command validation and acknowledgements. |
| Store | B47ANCEDSorting/Store.lua; owned world ModData and read-only legacy conversion. |
| Planner | B47ANCEDSorting/Planner.lua; destination choice only, no movement. |
| Presets | Owned configuration retains links; definitions/editor/sync remain upstream. Native definition import/store still missing. |
| Actual movement | No owned implementation or trigger; upstream movement cannot consume the owned configurations. |

### Authoritative gate meanings

[VERIFIED source] Framework WORKFLOW.md, Gates section, defines G6 = actual PZ client, G7 = mandatory dedicated multiplayer for gameplay-affecting features, G8 = package/release. The project instructions and earlier status use those meanings. G7 is not a code-completion stage; G8 is not dependency removal. G7 must PASS before gameplay G8.

Current gate state: G3 affected movement implementation BLOCKED; G4/G5 existing-source checks PASS offline; G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. An executable standalone runtime candidate is not available, so a valid dedicated standalone run cannot yet be attempted. No gate was redefined and no runtime PASS was inferred from the audit.

### Exact movement API evidence

Run `tests/audit_movement_api.py` against the installed game; it parses class metadata/bytecode without launching Java/PZ. Jar SHA256 remains e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33.

- [VERIFIED bytecode] LuaManager.GlobalObject.createItemTransaction checks GameClient.client and returns 0 on a non-client before calling TransactionManager.createItemTransaction. It cannot be used as a server transaction-start call.
- [VERIFIED bytecode] LuaManager.GlobalObject.isItemTransactionConsistent checks GameClient.client; on a non-client it returns true without running TransactionManager.isConsistent. A successful server Lua call is therefore not proof of validation. The existing planner eligibility callback must not treat it as one.
- [VERIFIED bytecode] TransactionManager.isConsistent references active transactions, nested-container chains, capacity, item/container lookup and safehouse checks. This is behavior beyond bare Remove/AddItem plus notification.
- [VERIFIED bytecode] Transaction.updateItem performs native mutation and inventory notifications, with additional equipped/clothing, floor and container-specific handling. GameServer.sendAddItemToContainer/sendRemoveItemFromContainer are packet notification helpers; they do not mutate inventory or consult TransactionManager themselves. The inspected Lua Exposer has no explicit Transaction class constants; that observation does not prove every possible Lua exposure route absent.
- [VERIFIED vanilla Lua] ISInventoryTransferAction:isValid/start/perform handles source/destination existence, source membership, crafting-consumed items, self-routing, destination capacity, removal/admission rules, nested-container cycles and multiplayer item-count limits. In MP its start requests a transaction; perform does not call its direct transferItem path. SP uses a different execution branch. This client timed action cannot simply be invoked as a server executor.
- [VERIFIED vanilla Lua] Server ClientCommands.lua demonstrates explicit inventory mutation followed by sendRemove/sendAdd for a specific item conversion. That supports notification use for that operation, not an arbitrary two-container transfer with native transaction conflict handling.

Source hashes: ISInventoryTransferAction.lua = 96ee554609f9ae029809643d50e4f31dbc5a7d21a558934be0804fd909c345b4; ClientCommands.lua = c9de3d3024a46e2b3ab1670c11f98885647bfb6d73114ff7896bf41e263923fd. The diagnostic asserts the observed guards and prints these hashes, so a game update forces reinspection rather than silently reusing evidence.

**Blocker:** no verified server-callable transaction seam has been established that both participates in native transfer conflict handling and preserves the owned exact source/item/destination authorization until mutation. Raw server Remove/AddItem plus sendRemove/sendAdd would bypass unverified native transaction behavior. Sending a destination to the client for a later native transaction has an unproven binding between our authorization and that transaction's container identities. Neither approach is implemented or claimed safe. This is an unresolved API/architecture question, not proof that server-authoritative movement is impossible.

The next bounded step is an isolated native API/exposure investigation or, if required, a narrow Java bridge design under the workspace docs/JAVA_DEVELOPMENT_POLICY.md. It must establish reservation/conflict handling, exact-reference validation at execution, capacity/count limits, nested-item policy, cancellation and synchronized completion. No bridge or client-authority fallback was added. The completed binding system need not be redesigned merely to hide the missing movement seam.

### Smallest native validation plan after the blocker is resolved

Run the same short scenario in SP, then a listen server with a remote peer, then a dedicated server with two remote clients. Disable Quartermaster and Better Sorting. Use a disposable test save and retain game build, mod version, sandbox settings, server/client logs and observed results. No scenario below has been executed.

1. Boot, build the catalog, expose Configure Sorting, open the owned window and select a server-discovered rail target. Check section/group indicators and keyboard/controller navigation.
2. Resize at minimum and enlarged bounds. Confirm fixed rail/row/font sizes, usable grip, visible footer/right edge, unchanged staging and no resize commands/saves.
3. Set category/item/preset rules and priority on two sections. Switch and Refresh, then Cancel; reopen to confirm no persistence. Repeat and Save; reopen and restart/reconnect to confirm owned persistence and unchanged legacy data.
4. Configure an explicit-item destination against a higher-priority category destination. Sort once; verify the explicit destination wins. Remove the explicit rule and verify category priority and deterministic ties. Count/identify the same items on server and clients.
5. Include a self-destination and opposing A/B rules; verify each item is considered at most once, no duplication/loss and no A→B→A loop. Check capacity and nested/full-bag/count-limit cases with the validated movement policy.
6. Remove or replace a destination before load, before Save and between planning/movement. Old handles must fail without rebinding or redirecting. Fill another destination; it must fail safely while independent valid work completes.
7. On listen/dedicated runs, race two clients' Save revisions and item transfers, including an ordinary vanilla transfer during sorting. Only valid acknowledged writes become clean. Disconnect/reconnect and check persistence, inventory parity and recovery after partial/uncertain failure.

Record SP/listen/dedicated separately. G7 remains BLOCKED / NOT TESTED until dedicated evidence covers the gameplay path; G8 stays BLOCKED until G7 and the remaining release checks pass. Do not package or publish this partial source to obtain a nominal gate result.

Follow-up commands (project directory):

```powershell
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/audit_movement_api.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/run_tests.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/check_versions.py --root .
```

The first command is a successful source diagnostic of a blocker, not a transfer test or G7 PASS. Existing regression and version checks remain offline evidence only. No category audit was repeated during this follow-up, and no new overlapping status document was created.

## Clean-room provenance — mandatory for all absorption

ALWAYS use clean-room rules when absorbing other mods. Reference mods may establish capabilities, interface contracts and observable failure modes. Do not copy their code, algorithms, category databases, item mappings, definitions, text, assets or internal structure. Production changes must be independently designed from the approved behavior and verified vanilla capabilities. No licensing exception is being used.

Reference: Better Sorting 2.1.5, Workshop 2313387159, Mod ID BetterSortCC. Its source was inspected once as requested; no files or mappings were imported. It is neither a dependency, an optional integration nor a runtime provider. No BSgetCategory/BSupdateMedia calls remain. Tests reject those identifiers in production Lua. Quartermaster 0.24.0 remains the transitional frontend dependency, not copied source. The host integration harness reads installed upstream files and checks their hashes unchanged.

SOURCE CODE COPIED: NO. THIRD-PARTY CATEGORY DATABASE COPIED: NO. Implementation rules are original and supported by vanilla B42 metadata. Reference concepts informed feature scope, not a line-by-line translation or renamed implementation. Better Sorting's license is not asserted to authorize reuse; no reuse is proposed.

## Identity and authority

The former coordinate/object-index resolver can bind a replacement at the same slot. tests/reproduce_initial_target_race.lua preserves that diagnostic; reproducing the defect is not a safety pass. Production load/commit no longer calls that resolver.

New handshake:

1. Client requests discovery around a nearby loaded square. Coordinates define the discovery scope only; the request does not claim an object identity.
2. Server enumerates eligible live containers and binds each opaque handle to exact object, container and container-index references, frozen position/type, authenticated player and session.
3. Server returns rail metadata and handles. MP starts with no selected target: the player explicitly selects a returned rail entry. It never auto-matches the old clicked object by coordinates/index/name/type. SP can auto-select only by the shared exact references.
4. Lazy load and Save accept only issued handles. Every request rechecks the exact object/container, live square membership, range/building or verified physical sibling scope, lock/safehouse access and session validity.
5. Removal revokes handles. Refresh never rebinds an old handle to a replacement. Invalid/unloaded/moved/replaced targets fail closed. Session expiry and near-origin checks invalidate abandoned scopes; rediscovery creates new handles deliberately.

[TESTED offline] Existing targets, pre-load identical replacement, refresh without rebinding, removal revocation, independent sections on one object, container slot swaps, wrong actor/malformed handles and unloaded scope. No persistent UUID or cached engine network ID is treated as placement identity. A 4096-handle technical registry bound rejects overflow instead of silently truncating the returned rail.

[VERIFIED bytecode] getEntityNetID depends on square/object indices; customHashCode is not immutable per-placement identity. Current inspected jar SHA256: e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33. This differs from older audit evidence, which is not relabeled current.

[RUNTIME GATE] Dedicated removal-event delivery, chunk unload/reload userdata behavior, reconnect, two clients and synchronization ordering still require native validation. MP discovery intentionally adds explicit initial rail selection to avoid an unprovable client-click binding.

## Owned persistence and staged editing

B47ANCEDSorting/Schema.lua validates only cats/items/presets/priority. Category and explicit item keys are string-to-true sets; preset links are true or positive generation IDs; priority is a finite exactly representable integer. Copies do not alias. Protocol size/key bounds are internal safety constraints. No UI state is persisted.

B47ANCEDSorting/Store.lua writes only object ModData.B47ANCEDSorting, schemaVersion=1, containers keyed by section index. Each envelope stores schema/taxonomy version, revision, config, legacyImported and section shape checks. All four fields commit together, followed by native transmitModData. Server/SP owns writes; clients submit intent and become clean only after successful acknowledgement. Revision and original-snapshot comparisons reject external conflicts and duplicated/reordered stale writes. A failure after the authoritative assignment but before acknowledgement is uncertain; no transactional rollback is claimed.

Legacy LSBox/LSBoxItems/LSBoxPresets/LSBoxPriority reads are explicit and read-only. Discovery/load never write migration data. Native data wins, including corrupt/future native data which blocks fallback. Foreign fields and coordinate registries are never written. Legacy keys remain preserved/dormant if the new taxonomy does not recognize them; semantic category migration and preset-definition import are still required before cutover. Retained links alone do not prove compatible preset behavior.

Session records keep original and working copies per issued handle. Switching, filtering, refreshing, Copy and Cancel do not persist. Whole Container uses verified sibling handles, stages each sibling independently and resets on target switch. Apply to Siblings remains the existing explicit control. Save processes all dirty targets, preserves failed edits and acknowledges successful targets individually. Refresh reloads selected contents/observations without replacing staged data. Own clipboard replaces the foreign clipboard fallback. The native getter-based bounds fix remains intact.

## Reference categorization audit and design choices

[VERIFIED reference inspection] Better Sorting mutates script display categories at startup, uses detailed category families, explicit correction/support tables and metadata-based rules, and also changes some instance media/fluid categories during client inventory refresh. That lifecycle can cause input differences when clients mutate scripts independently. It has explicit supported-mod mappings as well as generic classification. None of those rules, mappings or refresh algorithms is reproduced.

Conceptual family decisions (reference families deliberately merged; no reference ID table imported):

| Capability family | Decision | Owned result |
| --- | --- | --- |
| Ammunition and weapon components | ADAPT | Ammunition / Weapon parts |
| Firearms and specialized melee classes | ADAPT / MERGE | Firearms / Melee weapons |
| Tool roles and maintenance | ADAPT | Tools and maintenance, server-configurable multipurpose weapon treatment |
| Medical subtypes | MERGE | Medical supplies |
| Food lifecycle and drink distinctions | ADAPT / MERGE | Food / Beverages; no per-instance spoilage taxonomy |
| Clothing body regions and accessory kinds | MERGE | Clothing and accessories |
| Bag/container subtypes | MERGE | Bags and containers, including known water-container scripts |
| Books, maps and written material | MERGE | Books and written material |
| Audio/video media | MERGE | Recorded media; no copied title database |
| Crafting disciplines and ingredients | MERGE | Crafting materials |
| Vehicle maintenance | ADOPT concept | Vehicle parts |
| Electrical subtypes | MERGE | Electrical equipment |
| Fishing, gardening, camping, lighting and fire-starting | MERGE | Outdoor equipment |
| Furniture, keys, domestic and cosmetic goods | MERGE | Household goods |
| Collectibles, miscellaneous and unsupported semantics | ADAPT | Miscellaneous safe fallback |
| Debug/test-only distinctions | OMIT | No dedicated runtime category |
| Dynamic per-fluid/per-media category mutation | OMIT in this slice | Stable script-definition classification; no reference synchronization layer |

This is a coarser taxonomy, intentionally suited to the existing tree. No claim of feature-for-feature Better Sorting equivalence or complete classification accuracy is made.

## Resolver, UI and planner

Categorizer.lua owns 18 stable B47_* category IDs, localized independently through UI_B47_Category_* keys in all 29 locale tables (English fallback). Persisted IDs do not contain translated labels. The centralized overrides table is currently empty; generic support uses metadata, not per-mod patches or item-name guessing.

Deterministic precedence: own explicit override; ammunition tags; weapon-part type; medical/mechanics semantics; ranged flag; tool-use tags and sandbox choice; outdoor and beverage tags; strong item types/body-location; recorded-media metadata; material tags; narrowly recognized vanilla display-category fallback; melee type; household-use tags; Miscellaneous. isMedicalLoot/isMechanicsLoot incorporate vanilla category semantics in the engine, so they are not claimed to be category-independent. Unknown properties are read safely. Java Set tag iteration is supported.

[VERIFIED vanilla source/API] Script getItemType, getTags, isRanged, getBodyLocation, getRecordedMediaCat, getFullName/getDisplayName/getModID, hidden/obsolete checks and medical/mechanics predicates. Vanilla definitions establish semantic ammo/tool/flashlight/startfire/sealedbeveragecan tags and WaterContainer/LightSource/FireSource fallback categories. No third-party item names select production rules.

Catalog.lua builds cached script entries at editor attachment after scripts are available. Per-container observed entries come from authority; switching reuses base entries, explicit Refresh rebuilds the catalog. Category labels and origin-mod groups remain separate. Missing/ambiguous provenance uses Other / Unknown. Rendering does not reclassify the whole database every frame.

Planner.lua is a server/SP-only destination-selection primitive. It validates bound live targets, reads persisted owned configurations itself and invokes Catalog.destination with the same Categorizer.resolve used by the tree. Explicit item rules precede category rules, then higher priority, shorter distance and stable key order. Self-routing is excluded. A transfer-specific access/capacity predicate is mandatory. There is no network command accepting a client-supplied item/category/configuration. This primitive does not move items, walk, reserve capacity or validate a future client item-selection intent; the movement backend must supply those pieces.

Schema envelopes carry taxonomyVersion=1. Store.load calls the centralized migration function, currently preserving version 0/1 keys unchanged; unknown future versions reject. Future rename/merge mappings belong there. Unknown legacy IDs are not silently discarded. Changing the classification sandbox option intentionally changes membership of stable category rules.

## Configuration and coexistence

Existing server ContainerRange (1–30, default 10) and WholeBuilding (default false) remain in the transitional QuartermasterSorting namespace pending deliberate canonical migration. B47ANCEDSorting.ClassifyToolsByUse is a server sandbox boolean (default true). Tagged multipurpose weapons go to Tools by default; false prefers Melee for those weapons while ordinary tools remain Tools. Definitions and localized name/tooltip are provided. Missing existing-save value defaults true. The server resolver interprets only the explicit false value as disabled.

Category taxonomy/overrides are owned code, not user-edited settings. No per-item micro-settings or client category authority were added. UI coordinates, session lifetimes, protocol limits and schema/taxonomy versions remain internal implementation constants.

Better Sorting is redundant and should be disabled for this development path. Strong semantic rules still work if it is installed, but its script display-category changes can affect fallback, medical/mechanics inputs or client/server parity. No coexistence/parity guarantee is made and no synchronization integration is installed. Native tests must compare loaded catalogs on both peers.

## Coverage and developer diagnostics

[TESTED offline static] tests/audit_categories.py reads script definitions without executing PZ or third-party Lua, runs the owned Lua resolver and writes CATEGORY_AUDIT.json. The report includes Project Version, resolver/source hashes, category/reason counts, fallback metadata, duplicates and examples. Static inheritance, overrides, hidden declarations and runtime mutation limit equivalence to the loaded catalog.

Latest default-setting audit: 5,092 vanilla definitions; 14 Tactical Weapons definitions; 274 Authentic Z Backpacks+ definitions; 5 Wild Fruits definitions. Every scanned item returns a category. Remaining Miscellaneous fallbacks: vanilla 218, Tactical Weapons 0, Authentic Z 27, Wild Fruits 0. Fallback is safe, not proof each placement is ideal. Reviewed clusters include junk/collectibles, toys, animal remains, small household objects and definitions whose metadata is missing or inherited. Further loaded-catalog review is required; no production compatibility database was created.

An explicit developer call B47ANCEDSorting.Catalog.audit() returns loaded-script category counts, identity/name/owner/reason records, fallback/unresolved cases, overrides and duplicate/ambiguous display-name records. It does not run automatically or print release logs. Run on server and client after script loading and compare identities/categories for native parity evidence.

## Validation commands and gates

Run from the project directory with Python at C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe:

```powershell
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/run_tests.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/check_versions.py --root .
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tests/audit_categories.py --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2324223029/mods/Tactical Weapons/42' --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2335368829/mods/Authentic Z - Backpacks+/42' --mod 'E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2618566294/mods/WildFruits/42'
```

[TESTED offline] Lua 5.1/lupa: syntax; model/ownership/bulk literal search and effective counts; native-Picker host integration and 20k item fixture; container bounds; lazy sessions; staged refresh/Save/Cancel; Whole staging; serial partial saves; conflict/duplicate/revoked target rejection; simulated transport timeouts and acknowledgements; independent schema with no Quartermaster and next disabled; server bindings; categorizer semantics/provenance/fallback/settings; shared resolver and authoritative planner primitive. Localization parity and unchanged installed Quartermaster hashes pass. These mocks are not Kahlua or network runtime proof.

[TESTED offline] Development version consistency passes. No current package exists; --release is not a PASS and is not run to manufacture a release gate.

[UNTESTED / RUNTIME GATE] Native Kahlua and Java bindings; server serialization of metadata/envelopes; actual save/reload/persistence/transmit; SP, host, remote and dedicated operation; late join/reconnect; unload/replacement lifecycle; real UI mouse/controller/resize; server/client loaded category parity. G6 native acceptance is NOT TESTED, G7 dedicated is NOT TESTED, G8 is BLOCKED.

[BLOCKED] Standalone release/activation and deployment remain blocked by native authority evidence and unfinished owned shell/preset/movement integration. Do not claim the reported in-game Save symptom was reproduced or fixed in PZ; only the demonstrated offline authority defect and tests are addressed.

[DEFERRED, not dropped] Independent UI shell/context entries and icons; native preset-definition persistence/migration and generation checks; semantic migration of legacy category rules; full planner invocation/vanilla movement with equipped/favorite exclusions and capacity handling; proximity/group ordering and approved Whole propagation refinements; canonical activation/sandbox/package migration; final dependency sweep and native/dedicated evidence. No unrelated craft/manifest systems are being absorbed.

2026-10-09 authorized local diagnostic deployment: dev.21 base116 files verified; one deliberate local-only000_B47CategoryDiagnostics.lua overlay enables at most64 diagnostic samples. Older local/subscribed copies safely archived under dist/local-test-deployments/20261009-232349. Workshop remains published dev.20. Native Category result UNKNOWN; wait for current console and visual observation. Receipt: dist/handoffs/dev21-local-diagnostic-deployment.json.

## dev.23 container presentation checkpoint

[TESTED — offline] Full regression and package checks passed. dev.22 tooltip positioning/lifecycle retained. Container rail uses current validated physical-object sprite textures with generic fallback, instance caches and bounded optional diagnostics. Presentation only; taxonomy 6, configuration schema 2 and movement protocols unchanged. [RUNTIME GATE] Actual native UI/sprite acceptance and dedicated two-client visual comparison are not tested; overall G7/G8 remain BLOCKED. Category-column investigation, bulk movement and collision recovery remain outstanding. Dev.23 subsequently published as a user-authorized development testing build; local live installation unchanged. Native gates remain pending. See `dist/handoffs/dev23-container-presentation-report.md`.

See [dev.24 pipeline implementation and runtime gates](DEV24_PIPELINE.md).

## dev.26 scope and furniture candidate

See [DEV26_SCOPES_FURNITURE.md](DEV26_SCOPES_FURNITURE.md) for current ownership, persistence, migration, UI behavior and acceptance gates. Offline evidence does not establish native persistence or dedicated multiplayer readiness. G6 NOT TESTED; G7 BLOCKED; G8 BLOCKED.


Current dev.27 UI remediation and bounded route candidate: [implementation, offline evidence and pending native gates](DEV27_IMPLEMENTATION.md). Calibrated native travel-time optimization remains pending.

User-authorized development testing publication: 0.4.0-dev.27 uploaded to Workshop 3807217050 using [private publisher account]; SteamCMD exit 0 and Committing update...Success. Source/package/stage parity PASS (124 files). Native UI and dedicated MP NOT TESTED; G8 remains BLOCKED for readiness. Public page description verification unavailable unauthenticated. Local live installation unchanged. Receipt: dist/workshop-publish/dev27-publication-receipt.json.


Current dev.28 resizable-window candidate: [native audit, implementation and pending acceptance](DEV28_WINDOW_LAYOUT.md). Presentation only; inventory category adapter unchanged; no deployment/publication.


Current dev.29 independent tracks: [category audit/blocker and adjustable appearance implementation](DEV29_CATEGORY_AND_APPEARANCE.md). Category integration remains unresolved; transparency passes offline checks only. Native acceptance pending; no deployment/publication.
