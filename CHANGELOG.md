# Changelog

## [0.24.0-dev.3] - 2026-10-21

- Style Quartermaster-owned layout, scope, and Sort menus and their submenus through B47ANCEDUI public API 1. Sorting actions and server-owned gameplay state are unchanged.
- Audit UI 0.5.0-dev.11 public API and run its offline suite plus Quartermaster paired UI checks. Native visual/controller and dedicated MP acceptance remain untested for this iteration. No deployment or Workshop upload.

## [0.24.0-dev.2] - 2026-10-18

- Require actual room inspection, separate from discovery, before disclosing shared Stock targets. Hide protected Base Ledger area labels and recording times even from metadata-only reads.
- Reject Stock totals when the ledger reader revision, freshness or live status changes during a paginated read. Keep Base Ledger area tokens only for the active actor view so long-running servers do not exhaust a global token table.
- Offline regressions cover access, metadata, revision and token boundaries. Native SP and dedicated MP for this iteration are NOT TESTED; G7 and stable G8 remain blocked. No deployment or Workshop publication.

## [0.24.0-dev.1] - 2026-10-18

- Add historical Base Ledger fallback from a genuine completed CD brought to the viewing PC when its building cannot contribute through a loaded connected PC. Prefer online building PCs, choose the newest CD per offline area, show recording time, and mark the combined view partial/static. Refresh the source paper ledger, then rewrite an existing matching-area ledger CD or burn a new blank disc. Prior snapshot generations remain immutable.
- Server-authorized row inspection, stock notification suppression, native transfers and saved ledger schemas remain unchanged. Offline tests pass; native SP/dedicated NOT TESTED, G7/stable G8 BLOCKED. Workshop multiplayer test distribution authorized; no local or server deployment.

## [0.23.0-dev.1] - 2026-10-18

- Add room/building stock goals, paper/PC stock views and low-stock notifications. Support latest-per-area multi-CD and linked Base Ledger views through PC Framework. Sorting, transfers and personal Needed goals unchanged.
- Prepared for authorized Workshop MP testing with existing UI item 3822582242 (UI 0.3.0-dev.1 / API 1) and PC Framework 0.11.0-dev.1. Build entry points accept the explicit UI checkout; CI pins the current public dependency commits. Native and dedicated multiplayer NOT TESTED; upload receipts remain separate evidence.

## [0.22.0-dev.1] - 2026-10-18

- Extract shared presentation into required B47ANCEDUI public Lua API 1. Remove the embedded library; retain application screens and gameplay callbacks.
- Move reusable appearance editor and clipboard drawing; import old per-player appearance values read-only into consumer-scoped preferences.
- This 0.x MINOR adds a required mod dependency. Both peers must install UI. Gameplay authority, protocols, window settings and save data are unchanged.
- Source-only: offline validation, native SP/dedicated NOT TESTED; G7/stable G8 BLOCKED. No package/deploy/Workshop upload.

## [0.21.0-dev.5] - 2026-10-18

- Integrate all open Quartermaster feature branches with the public PC Framework dependency and unified desktop.
- Use the approved transparent crate/checklist mod icon; Workshop thumbnail and poster are unchanged.
- Preserve installer-CD, clipboard, sort-ledger and failure-handling workflows.
- MP testing build - dedicated multiplayer NOT TESTED.

# Changelog

## [0.21.0-dev.4] - 2026-10-17

- Publication preparation corrects stale mod.info/release prose: current default SortUpdatesLedger, whole-Notebook ingredient and Movement 12 / Ledger 5. Runtime code is unchanged; required Framework distribution remains a publication gate.

- Rejected/timed-out native confirmations close tagged work and notify its caller once, preserving the specific error and any completed Sort movement.
- Installation notification failure returns an explicit committed/synchronization-pending result. Keep the per-PC receipt and retire the grant successfully; never replay installation or consume the CD.
- Installer controls allow retry after denial and prevent reinstall while a committed installation notification is pending.
- Compatible error-path corrections; native groups/timing, sandbox defaults, schemas and protocol capabilities are unchanged. Native/dedicated acceptance remains NOT TESTED; no deploy or publication.

## [0.21.0-dev.3] - 2026-10-17

- Revalidate ledgers after bounded discovery; lost carried sheets fail safely.
- Resume sorting at its original source after picking up a stored ledger.
- Clear interrupted native writing work instead of leaving the UI busy.
- Keep movement results distinct from the subsequent ledger-writing outcome.
- Release the reusable Application CD after installation so the data drive is available.
- Repair Shopping paper controls, visibility, focus and feedback across view changes.
- Offline regressions cover these transitions; native client and dedicated MP remain NOT TESTED.

## [0.21.0-dev.2] - 2026-10-17

- Creating a new paper Supply Ledger consumes one whole vanilla Notebook via native mode:destroy; remove the loose-sheet alternative. Keep the clipboard and pen/pencil. Existing ledgers are reused for recording and post-sort updates, with no new notebook charge.
- Compatible recipe correction within the current prerelease; no saved-item, snapshot or protocol change. Shopping List materials remain unchanged. Metadata/recipe, version and source-manifest checks pass offline; native crafting/dedicated acceptance remains NOT TESTED. No deploy or publication.

## [0.21.0-dev.1] - 2026-10-17

- Default-on Sort ledger workflow: bounded server building search prioritizes a completed accessible paper ledger, collects it through native transfer, otherwise uses carried blank/unfinished paper. Require carried paper and pen/pencil throughout sorting.
- After the entire successful Sort, a server-granted native writing action updates confirmed touched storage on the paper. Blank papers remain partial; untouched timestamps and existing CD snapshots are preserved.
- Server sandbox opt-out restores previous behavior; Ledger Disabled bypasses this feature. Ledger/movement capabilities advance; all peers must update/reconnect. Native and dedicated acceptance pending; no package, deploy or publication.

## [0.20.0-dev.2] - 2026-10-17

- Place the Application CD in commercial office desks/counters, office supply shelves/crates and computer retail/stock pools, including warehouse offices mapped as native office rooms. Remove generic electronics drops; home desks and general warehouse cargo remain unchanged.
- Compatible loot correction; reuse the existing server loot-weight option. New native loot rolls only, no inventory refill or installation/protocol/save changes.
- Focused offline program, native-table integration, metadata/version/manifest checks pass. Native loot generation and dedicated multiplayer remain NOT TESTED; no deploy or publication.

## [0.20.0-dev.2] - 2026-10-17

- PATCH-level publication metadata/tooling checkpoint within pending 0.20.0: link required PC Framework Workshop item 3822042011 and prepare accurate MP testing prose. Pass explicit dependency checkouts through Workshop staging.
- SteamCMD upload succeeded for existing item 3807217050; public metadata/version verified and the Workshop required-item relationship added alongside Rooms. Record exact source/package/upload evidence in WORKSHOP_PUBLICATION.md.
- Gameplay, sandbox settings, public APIs, saves, existing item 3807217050 and visibility are unchanged. Full offline package/paired regressions are required before upload. Native SP/dedicated NOT TESTED; G7/stable G8 BLOCKED.

## [0.20.0-dev.1] - 2026-10-17

- Add a found Quartermaster Application CD and explicit SETUP.EXE installer through PC Framework CD program API 1. Native timed completion creates a server-owned receipt bound to the exact PC; setup media is retained and reusable.
- Require installation for computer ledger reads/writes and automatic ledger knowledge by default, preserving paper/CD records and ordinary Sort. Server sandbox options control the prerequisite, install duration and new office/electronics loot weight.
- Ledger protocol advances to 4; peers must update and reconnect. No snapshot migration or automatic legacy-PC installation. Use paired PC Framework 0.5.0-dev.2 integration, preserving the CRT/taskbar and public SDK/API branches.
- Full offline paired regressions and focused installation/loot/UI checks pass; native SP/dedicated NOT TESTED. See docs/APPLICATION_CD.md. No package, deploy, publication or shared-main merge.

## [0.19.0-dev.3] - 2026-10-17

- Redraw the paper ledger metal clamp with a wider beveled steel plate, rivets, raised spring tab and rolled jaw overlapping the sheet. Retain title clearance, row geometry and all ledger behavior.
- Presentation-only PATCH checkpoint; source-rendered visual review and focused offline UI/version/manifest checks pass. Native visual acceptance remains NOT TESTED; no deploy or publication.

## [0.19.0-dev.2] - 2026-10-17

- Reconcile the clipboard/ledger work with the standalone PC Framework integration. Preserve owned CRT/taskbar presentation in PC Framework 0.3.0-dev.1 rather than duplicating a desktop in Quartermaster.
- Correct paper-ledger proportions, ruling/scroll alignment, usable row selection and page/details controls. Keep the reusable clipboard recipe and exact-building computer-refresh policy.
- Compatible UI/integration checkpoint, no save/protocol change. Offline/native evidence: docs/CLIPBOARD_UI_FIX.md. No package/deploy/publication.

## [0.19.0-dev.1] - 2026-10-17

- Extract the Windows '93 desktop, computer validation and reusable server drive engine into the required B47ANCED PC Framework mod.
- PC Framework 0.2.0-dev.1 recognizes all powered vanilla PC orientations and Computer-tagged alternate tiles; Quartermaster inherits this through the unchanged device adapter.
- Quartermaster registers its ledger reader/CD writer as an app; existing paper/CD identities, snapshots and persisted drive bindings remain unchanged.
- 0.x compatibility change: enable B47ANCEDPCFramework on every peer. Missing framework fails closed through the loader dependency. No deployment/publication; native SP/dedicated NOT TESTED, G7/stable G8 BLOCKED.


## [0.18.0-dev.8] - 2026-10-17

- Require one retained vanilla Base.Clipboard in the paper Supply Sheet recipe, alongside the retained pen/pencil. Paper/notebook consumption and the single-sheet output remain unchanged.
- Verify the native clipboard definition and kept-input recipe line in the existing ledger metadata test. Update ingredient documentation and current version mirrors.
- Compatible recipe checkpoint within the 0.18 development line; no Lua behavior, schema, item identity or existing-ledger migration changes. Native crafting/dedicated acceptance pending; no deployment/publication.

## [0.18.0-dev.7] - 2026-10-17

- Give paper ledgers an original clipboard, metal clip, ruled sheets, Item / Quantity / Location columns and previous/next-sheet controls, with exact-entry details and native resizing/controller access.
- Limit computer live updates and automatic freshness exemptions to the exact recorded native building. Off-site and safehouse-wide CDs stay readable as historical records under ordinary expiry; they cannot refresh remote buildings.
- Preserve paper live-mode policy, manual Sort, permissions, immutable snapshots, transfer grouping and server-owned media. Compatible UI/policy correction within the 0.18 development line; no save/protocol change.
- Offline/native evidence: docs/CLIPBOARD_AND_LOCAL_COMPUTER.md. No deployment/publication.

## [0.18.0-dev.6] - 2026-10-17

- Give the computer ledger a Windows 93 table with Item, Quantity and Location columns, compact status and page information, raised headers and a selected-entry details area.
- Retain authenticated reads, literal search, room filtering, paging, media checks and taskbar behavior. Paper reading and shared gameplay/protocols remain unchanged.
- Compatible client presentation checkpoint within the 0.18 minor development line. Offline/native evidence is recorded in docs/WINDOWS93_COMPUTER.md; no deployment/publication.

## [0.18.0-dev.5] - 2026-10-17

- Clean the CRT artwork with softer molded-case shading and fewer concentric edge bands, retaining its bulky housing, recessed glass and substantial stand.
- Replace the single placeholder task button with independent retained CD-ROM, CD Writer and ledger tasks. Add active/minimized states, task switching, most-recent visible fallback, per-app Close and Show Desktop/restore.
- Preserve query, pagination and media choices across minimizing/switching; clear old ledger rows and revalidate through existing server reads on resume. Media loss/ejection closes the ledger without discarding unrelated apps; late mount/read replies do not reopen closed windows.
- Refresh controller rows after mounting a CD, ignore Escape in hidden panels, and keep native full-title tooltips and tooltip cleanup on task switches. Power/Log Off still closes all tasks and cancels pending CD writing.
- Client presentation only: no new commands, protocol/save changes, runtime dependency or gameplay settings. Offline and native evidence are recorded in docs/WINDOWS93_COMPUTER.md; no deployment/publication.

## [0.18.0-dev.4] - 2026-10-17

- Increase CRT case mass with thick front molding, offset vented rear housing, a deeper glass recess, a broad lower control deck and a large swivel-neck pedestal.
- Keep icons/CD behavior unchanged; reserve usable desktop area and adapt the centered badge/control deck at large fonts. The power switch still closes the local UI and cancels pending CD writing, without changing shared electricity or stored media.
- Strengthen offline coverage for power-button cancellation and glass/control/stand separation. UI-only compatible correction; no protocol, persistence or gameplay change. Native visual acceptance remains pending; no deployment/publication.

## [0.18.0-dev.3] - 2026-10-17

- Replace the flat computer surround with an original Lua-drawn beige CRT, recessed glass rim, pedestal, vents and power light. Add detailed CD-drive, CD-writer and application pixel icons.
- Keep the desktop, taskbar and status text within the glass; increase resize minimums for the bezel and large fonts. The physical power button uses the existing Log Off/cancellation path and controller focus.
- Presentation only: no networking, saved-data, ledger authorization, CD handling or native transfer changes. No protocol bump or new gameplay setting.
- Offline/UI evidence and remaining native gates: docs/WINDOWS93_COMPUTER.md. No deployment or publication.

## [0.18.0-dev.2] - 2026-10-17

- Retire native-room selectors, fallback requests, allocation aliases and active grouping. Use B47ANCEDRooms designated rooms for room organization and native PZ buildings for building scope, with proximity fallback where no designation applies.
- Preserve existing native-building ledger signatures, historical labels and dormant native-room profiles. Existing native configuration-footprint and provider-capability checks remain intact.
- Fix no-profile Shadow comparisons without adding quotas or bypassing native capacity. Keep enforcement/live role routing disabled, carry-first sorting, vanilla smaller groups and current ledger/shopping behavior.
- Quartermaster Rooms capability is 4; movement remains 11. Matching peers required. No save schema change from dev.1.
- Full final offline and native acceptance evidence is recorded in docs/DESIGNATED_ROOM_SCOPES.md; native G6 and dedicated G7 remain NOT TESTED, stable G8 BLOCKED. No deployment/publication.


## [0.18.0-dev.1]

Port the advisory allocation foundation onto the current ledger/physical-shopping/carry stack; retain movement 11, personal 2, shopping 3, ledger 3, Rooms 3 and load-policy 1. Add sparse profiles, Whole/preset migrations with recovery snapshots, percentage editors, bounded server shadow diagnostics and paired designated-room permissions. Configuration/preset wire capabilities become 6/3; saved configuration/preset schemas become 3/2. Fix current Rooms metadata discovery when retired nativeRooms is omitted; reject malformed metadata and obsolete allocation providers. Enforcement and live routing remain disabled. Native/dedicated NOT TESTED; G7/stable G8 BLOCKED.

## [0.17.0-dev.1] - 2026-10-16

- Inventory and selected-container Sort no longer require a supply ledger. Room/Building Sort still require current location knowledge when enabled.
- Add server Ledger Mode (periodic live, disabled, live without expiry, historical snapshots), Update Interval (1–365 in-game days, default 7) and Computer Manual Updates (default on).
- Renew paper records through native inspection without changing older CDs. Live readers refresh confirmed contents of recorded physical compartments through bounded, permission-checked server analysis; historical pages remain immutable.
- Disabled mode hides ledger/computer actions and rejects ledger work without disabling physical shopping papers. Existing data is preserved for re-enabling.
- Correct the mod-browser description to match scoped ledger requirements, freshness modes, computer updates and current protocol capabilities; runtime behavior is unchanged by this metadata correction.
- Development source only; native client and dedicated multiplayer acceptance NOT TESTED (G7/stable G8 blocked).

## [0.16.0-dev.2] — Keep sorting setup open after Save

- Authorized Workshop MP test distribution preparation; description/changenote disclose native/dedicated acceptance pending and the default-on ledger/physical-list requirements. No stable-release claim.

- Successful container-rule saves keep Quartermaster open with its current container selected. Refresh the container rail after acknowledgement, then continue configuring another container without reopening.
- Preserve authoritative commits/revisions, partial-save errors, manual close/Cancel and preset-dialog behavior. UI-only compatible fix; no protocol, save-schema or sandbox changes. Native acceptance pending; prior gameplay G7/G8 gates remain blocked.

## [0.16.0-dev.1] — Physical shopping lists (development)

- Named physical Shopping papers with independent server-owned contents, selected-list revisions and exact native item possession checks; papers can be transferred to friends.
- One blank sheet becomes one list through challenged native action completion. Notebook and pen/pencil are retained for creation/editing; reading and collection need no writing supplies.
- List picker, rename, explicit one-time legacy import and a non-interactive ripped-paper HUD while held in either hand. Long lists paginate automatically.
- Preserve the old personal plan as a backup and support server opt-outs. Linked goal targets are copied to paper, so hand-offs do not adopt the recipient's personal goals. Existing allocator/preferences and native smaller transfer groups remain.
- Personal protocol 2 and Shopping protocol 3; ledger 2, movement 10 and physical-ledger data schemas unchanged. New shopping-paper registry schema 1. Offline fixtures validate handlers, native-action-shaped conservation/replay, trade, collection and UI geometry. Native client/dedicated multiplayer NOT TESTED; G7/stable G8 blocked. Source-only, no package/deployment/publication.

## [0.15.0-dev.1] - 2026-10-16

MINOR gameplay feature with an explicit default-behavior change: sorting and Shopping collection now require a completed, location-matching ledger by default. Server sandbox switches can restore unrestricted use; planning/editing remain available. New peer capabilities prevent silently mixing older ungated clients/servers. Existing sorting and ledger records are preserved.

- Add server-owned computer drive bindings to actual ledger CDs kept in accessible adjacent physical storage, without inventing a computer inventory or moving items.
- Add paper/computer knowledge checks at job admission and each new transfer grant, with safe observation/return paths retained after requirement loss.
- Native/dedicated acceptance NOT TESTED; no package, deployment or publication.

## [0.14.0-dev.2] - 2026-10-16

Compatible UI expansion of the 0.14 Ledger feature: a client-local Windows ’93 computer desktop with explicit CD insertion and application launching. Ledger protocol/schema, native media identity, saved records, permissions and transfers remain unchanged.

- Replace direct computer context actions with a CRT screen, desktop, Start menu, CD-ROM browser and CD Writer application. A mounted ledger disc must be run explicitly; opening the computer does not fetch ledger pages.
- Embed the existing digital reader inside the computer application. Retain server validation and close on power/access/possession loss. Paper stays independent.
- Native client/controller and dedicated acceptance remain NOT TESTED; no deployment or publication.

## [0.14.0-dev.1] - 2026-10-16

Compatible MINOR: physical Building Supply Ledger, with separate ledger protocol/schema 1. Sorting configuration, movement protocol 9, native transfer grouping, Dangerous Load and existing item rules remain unchanged.

- Add craftable Supply Sheets using verified paper/notebook and a retained pen/pencil, plus dedicated Supply Ledger CDs using stock native icon/model references.
- Add bounded building/safehouse discovery, native walking and server-granted timed inspections. Record actual quantities with conservative native stack equivalence, physical locations and per-container times; preserve partial progress and re-inspect uncertain identities after restart.
- Add server-completed, power/access-checked CD conversion with per-input journals, definite rollback and conservative unknown-outcome locks. One compatible CD becomes one ledger CD; original paper remains.
- Add paged paper reading and a powered computer reader with literal search, room browsing, opaque cursors and current privacy checks. Portable history uses Rooms' validated registry/policy exports when the original square is unloaded, with stricter safehouse membership.
- Add four server sandbox timing settings and 29-folder English fallback names, recipes and UI strings. Include production service/action/UI/Rooms regressions and package evidence. The shelf experiment remains removed.
- Offline validation passes; native crafting/UI/SP and dedicated multiplayer acceptance remain NOT TESTED. G7 and stable G8 BLOCKED; no deployment or Workshop publication.

## [0.13.0-dev.1] - 2026-10-15

- Add optional Extended Categories (CAExtendedCategories) support using native metadata and existing explicit category-member selections, preserving dedicated authority across client/server detail differences. No external classifier/code/assets imported; independent clean-room review and native acceptance pending.

- Add disabled-by-default Dangerous Load with a server-owned personal preference, revision checks, native effective-capacity utilization (50–100%), shared Sort/Shopping capacity checks, resizable controller-compatible settings and 29-language English fallback parity.
- Preserve normal CarryAllowance behavior, full carry planning, native smaller transfer groups/timing and existing permission/no-progress boundaries. Re-read native capacity/weight before admission; never change native capacity, weight, stats or penalties.
- Add an unwired, bounded read-only actual-content analyser using canonical native categories. Add an isolated ledger domain prototype, tests and exact native evidence. It is not a functional in-game Ledger feature and is excluded from runtime activation. The owner removed the shelf appearance experiment from scope; no experimental shelf code/assets/tests are retained.
- Record native timing/receipt, CD conservation and load-aware route calibration gaps explicitly. Offline tests pass; native SP/G6 and dedicated G7 are NOT TESTED, stable G8 BLOCKED. No deployment or Workshop publication.

## [0.12.0-dev.1] - 2026-10-15

- Add overall Sort/Shopping overhead progress alongside vanilla's current-action bar. Room/building Sort aggregates sources; Shopping uses authoritative remaining demand. Auto Clean remains separate and unchanged.
- Reconcile the owner-supplied carry-load patch: load a weight-limited carry before walking and unload it before starting another. Route Optimization groups one native room per carry when on, one crate when off. Preserve vanilla's smaller transfer groups and timing.
- Add server sandbox Extra carry allowance (0–40 kg, default 0), with equipped-bag reduction and native capacity enforced. Retire the unused SortBatchSize UI control; saved values no longer slice a carry.
- Support selected native vehicle/trailer storage and nested physical-storage bags through exact identities, access checks and native cargo-area walking. Read-only Workshop metadata census records 112 relevant items among 422 downloads; no third-party code/assets imported. Automatic vehicle area sweeps, vehicle destination configuration, fluids and unverified virtual stores remain unsupported.
- Before PUT authorization, redirect full destinations to matching storage or request a permitted native return to the exact source. Include pending alternative reservations, prevent fallback cycles and preserve partial completion. Retain carried items when safe return or native outcome is unavailable; stop wholly rejected batches.
- Fix the non-public recipe-input lookup, preserve completed work when queued items become inadmissible, and explain zero-move skip reasons. Uncarryable items no longer reserve space needed by lighter items.
- Compatible MINOR iteration; movement capability 8 to 9 requires matching server/client builds and reconnect. Save/category/preset schemas and SupplyAPI 1 are unchanged. Offline regressions and source checks pass; actual PZ SP/dedicated G7 NOT TESTED, stable G8 BLOCKED. No package, deployment or publication.

## [0.11.0-dev.1] - 2026-10-15

- Approved artwork follow-up: replace the crowded thumbnail/poster with a simple crate-and-checklist design and a matching transparent icon. Preserve the original masters and reproducible size/format exports. Presentation-only source update; runtime version, gameplay and previously published package are unchanged. Not deployed or uploaded by this change.

- Documentation-only README refresh: describe the current Workshop features, required Rooms and optional integrations; link current published source, preserve the previous README as dated history and retire obsolete README version selectors. No gameplay or project-version changes.

- Workshop description follow-up: owner reports Quartermaster dedicated MP tests PASS and approves stable presentation. Replace development/test warnings and technical history with feature-focused copy and a short compatibility section. Description-only metadata update; no runtime/package version or gameplay changes.

- Extract Clean Building into the separate B47ANCEDAutoClean mod; Quartermaster no longer registers cleaning actions, jobs or menus. Breaking 0.x packaging change: users enable the new mod to retain cleaning.
- Add SupplyAPI 1 for authority-bound configured-storage queries, live withdrawal/deposit checks and replay-protected native transfer actions. Auto Clean requires this provider and Rooms; no dependency cycle.
- Preserve sorting behavior, configured storage/save schemas and existing sandbox settings. SP/dedicated runtime NOT TESTED; G7 and stable G8 BLOCKED. No Workshop upload is part of this extraction.

## [0.10.0-dev.1] - 2026-10-15

- Add Lua-only single-player Clean Building through the vanilla timed-action queue with the same Rooms job, supply and footprint guards.
- Bind local authority to the engine's exact local-player instance. Multiplayer sender binding and action reconstruction remain unchanged.
- Preserve native timing, guarded mutation, cancellation, borrowing/return, bleach-first mixing and Rooms sandbox settings. Compatible MINOR feature addition; no protocol or save-schema change.
- Offline tests are distinct from native acceptance. SP NOT TESTED; dedicated G7 BLOCKED / NOT TESTED and stable G8 BLOCKED. Authorized Workshop testing distribution only.

## [0.9.0-dev.1]
- Breaking 0.x dependency contract: Rooms (Mod ID B47ANCEDRooms, Workshop item 3820077442) is now required for Quartermaster and its embedded Auto Clean/Clean Building feature. No separate Auto Clean Mod ID or Workshop item exists in this distribution.
- Add the native mod.info dependency and Steam Required Items relationship; update packaging gates to reject missing or incorrect requirements. Enable Rooms on server and clients before updating. Existing saves, registry schemas, protocols, recipes and server mutation guards are unchanged.
- Minimum game version is 42.21.0, matching the required Rooms metadata and installed API baseline.
- Retain the published 0.8.0-dev.1 package/provenance before producing this MP testing candidate. Dedicated G7 NOT TESTED / BLOCKED; stable G8 BLOCKED. No local SP deployment or game/server launch.

## [0.8.0-dev.1]
- Authorized Workshop MP testing candidate for existing item 3807217050. Quartermaster only: matching Rooms cleaning source must be installed separately; no new Rooms Workshop item is created. Preserve the pre-cleaning package/provenance and record new source/package hashes. Dedicated G7 and stable G8 remain BLOCKED.
- Activate Clean Building in the Lua source under the existing Mod ID: multiplayer lifecycle hooks install server-owned jobs, guarded native timed actions and client context-menu intent. Rooms cleaning capability/settings are required; missing/incompatible service and single-player fail closed. Default preparation adds 10 mL bleach before water. Existing archives are unchanged; native/dedicated acceptance remains NOT TESTED.
- Compatible MINOR optional standalone Rooms integration. Extract room geometry/editor/registry into B47ANCEDRooms; preserve native-only fallback and sorting configuration.
- Inventory Sort opens building, room or exact-source choices. Both area scopes include full carried inventory/bags and configured physical storage, with exact-item deduplication and native transfers.
- Independently enforce discovery, inspection, withdrawal, deposit and configuration permissions at server discovery/planning/grant boundaries. Parent/admin metadata control does not bypass private gameplay policy.
- Add data-only legacy room migration in Rooms, native overrides/restore, delegated ownership and boundary approval. Original Quartermaster room data remains recovery evidence.
- Quartermaster capabilities configuration 5/movement 8/rooms 2; config schema 2/world root 1 unchanged. Rooms API/protocol 1 and registry schema 2 are separate.
- Full offline suites and paired production API tests PASS; native UI/persistence/dedicated G7 NOT TESTED, stable G8 BLOCKED. Development ZIPs only; no deployment or publication.

## [0.7.0-dev.1]
- Compatible MINOR custom-room development: server-owned logical geometry, safehouse-member editing, native physical discovery and movement retained.
- In-world structural/native candidate detection and preview editor: rectangles, paint/erase, explicit floors, undo/redo, names, duplicate, exact merge/split and delete. Overlap/disconnected warnings and cancellation cleanup preserve world/container data.
- Existing discovery selector gains exact custom-room scopes and configured-physical-container room sorting, retaining native access, capacity, priorities, grouping and transfer authorization. Excludes player/ground/bag/virtual sources and deduplicates exact items.
- Add server sandbox controls, room schema 1 and capability versions configuration 4/movement 7/rooms 1; existing sorting config schema 2/world root 1 remain unchanged. Update both peers together.
- Full offline regression, native metadata (5,105 declarations/5,092 types/zero differences), 133-file source inventory and version checks PASS. Three-source native-Lua fixture: 20 exact moves, 28 correct/seen skips, no duplication.
- Native UI/save/load/dedicated acceptance NOT TESTED; G7 and stable G8 BLOCKED. No packaging, deployment or publication authorized. Preserve the previous published ZIP unchanged in history.

## [0.6.0-dev.3]
- Compatible PATCH fix: check native getter availability before invocation, avoiding missing-method category lookup exceptions on script definitions without changing category results.
- Includes dev.2 bounded movement-phase queries and prompt queue scheduling; retain native timing and all per-item server checks. Movement capability 6 requires updating both peers.
- Authorized Workshop MP testing candidate; full offline regression, native metadata, version and package/source/staging checks PASS. Native SP/optional-mod/dedicated acceptance NOT TESTED. The separate batch-guard stop remains under investigation.

## [0.6.0-dev.2]
- Compatible PATCH throughput correction: aggregate per-item movement queries into bounded per-phase requests; preserve all existing server checks and native transfer timing. Movement capability 6 requires updating both peers.
- Advance ready batch/local Sort phases without fixed quarter-second gaps; throttle only repeated planning/arrival queries.
- Include the exact local dispatch-guard reason in batch rejection diagnostics. Native/dedicated acceptance pending; no deployment/publication.

## [0.6.0-dev.1]
- Breaking 0.x storage cleanup requested by owner: remove obsolete category rules and runtime taxonomy; retain native rules, explicit items, priorities and owned preset links through server-only, idempotent normalization.
- Remove old storage fallback routing; owned legacy envelopes are converted once and deleted, while unrelated mod/player data and historical evidence remain protected.
- No deployment/publication; native persistence and dedicated restart/reconnect acceptance pending.

## [0.5.0-dev.1]
- New 0.5 development line: intentionally replace the default B47 taxonomy with native item DisplayCategory/fallback categories. Retain retired rule interpretation only for saved-configuration compatibility; no third-party mappings imported.
- Permit Better Sorting and preserve Better Containers inventory UI; client-local category selections use explicit item rules on authority.
- Give catalog preparation the owned window header, layout and progress styling. Native UI, optional-mod and dedicated acceptance remain pending; no deployment/publication.

## [0.4.0-dev.50]
- Compatible PATCH candidate: assemble each authorized native transfer batch through vanilla ISQueueActionsAction before the first transfer begins. Keep existing server batch-size, native grouping/timing, per-item guards and stable item-ID lookup.
- User confirms dev.49 fixes the one-item stop; client log reports 140 completed with zero transfer failures. This is scoped runtime evidence, not full dedicated G7 acceptance. New queue behavior requires in-game testing.

## [0.4.0-dev.49]
- Compatible PATCH development iteration: audit installed Workshop item declarations and improve metadata-based fallback classification. Preserve taxonomy IDs, tool-first priority and native/server movement authority; no external classifier, source or assets imported.
- Add reproducible corpus inventory including common-folder definitions and ambiguous ownership reporting. Static audit is not runtime effective-load-order proof; dedicated validation pending.

## [0.4.0-dev.48]
- Compatible PATCH candidate: resolve native batch operations by the existing item ID rather than Lua wrapper table identity. Preserve operation state, containment, native and server authority checks.
- New dev.46 runtime evidence: PUT cancelled with operationStateRejected, zero confirmed transfers. Equivalent-wrapper regression added; dedicated retest remains required. No deployment/publication.

## [0.4.0-dev.47]

Compatible PATCH correction pass: category clearing/ranges, renamed-item presentation, hidden container selection, inventory category ordering, picker text/layout, preference preservation, known-unsubmitted shopping cancellation and reproducible runtime directories. Native continuation investigation and expanded transaction lifecycle coverage; no dedicated success claim. No deployment/publication.

## [0.4.0-dev.46]

- Documentation-only README refresh: describe the current Workshop features, required Rooms and optional integrations; link current published source, preserve the previous README as dated history and retire obsolete README version selectors. No gameplay or project-version changes.

Compatible diagnostic PATCH iteration. Distinguish operation-state, pending-item guard, native validation, transaction rejection and native cancellation before/after perform. Transfer execution and authority unchanged. Dev.45 live dedicated attempts still stop after one item; root cause remains unproven. No deployment/publication.

## [0.4.0-dev.45]

Compatible native batch replication guard correction: use vanilla validation for submitted transactions during source-removal/destination replication gaps. Pending groups retain final B47 checks. Native transaction and queue cancellation now have distinct reasons. Offline regression; dedicated acceptance pending. No deployment/publication.

## [0.4.0-dev.44]

Compatible inventory-opener correction: target-free opening skips world-object resolution entirely, and Targets.make rejects an absent object before native member access. Avoids the console-confirmed getContainerByIndex-on-null error even when protected calls print failures. Explicit-target validation, nearby server discovery, target selection and Save guards unchanged. Offline regression enforces no nil native lookup. No deployment/publication; separate native PUT cancellation remains undiagnosed.

## [0.4.0-dev.43]

Fix arrival/authorization race: an otherwise valid TAKE/PUT waits up to 15 seconds for server-observed adjacency. Batch and single executors poll metadata at bounded intervals, then dispatch native movement once after authorization; no native-transfer retry or authority relaxation. Invalidated targets, capacity, permissions, items and configuration remain rejected. Movement capability advances to 4, requiring matching updated peers. Single executor no longer credits success when an unrelated action blocks dispatch. Includes dev.42 zero-progress containment and skip diagnostics. Offline 701-item delayed-arrival, timeout, revocation/capacity/cancel and protocol tests pass; native dedicated gate remains untested. Authorized development testing publication.

## [0.4.0-dev.42]

Compatible sorting failure containment: stop after a batch transfers zero items and reports failures instead of draining subsequent batches into the same rejection. Preserve native authority checks and source items. Capture terminal/waiting planning skip totals correctly. Add one bounded client summary per run with first rejection command/reason, responding server version, source/planning-target counts and separate transfer/planning totals. Offline 701-item player-inventory deposits pass in SP/MP-shaped fixtures, including overweight carrier; forced PUT rejection preserves the remainder. User's live zero-transfer cause remains unknown. No deployment/publication in this investigation.

## [0.4.0-dev.41]

Weapons now has Explosives, Sharp (Spear and Blade/Long/Short), Blunt (Long/Short), and Firearms (Handguns, Shotguns, Sub-Machine Guns, Assault Rifles, Sniper Rifles, Other Firearms, Attachments & Parts/Attachments/Parts). Preserve an Other Weapons fallback for insufficient metadata. Tree rendering/search handles arbitrary category depth. Tool use is always primary, with shared secondary weapon rows and routing coverage; retire the conflicting ClassifyToolsByUse sandbox switch. Saved category IDs remain accepted and historical weapon coverage is retained. Native definitions produce 63 requested additional primary splits (625 cumulative approved deviations). Offline/native transfer fixtures pass; native UI and dedicated gameplay remain unverified. Development testing publication only.

## [0.4.0-dev.40]

Compatible presentation-only label corrections: Recreation, Smoking, Light Source and Media, synchronized across all 29 language fallback tables. IDs, taxonomy hierarchy, item membership and saved rules unchanged. Weapons reorganization deferred at the user's request. No deployment/publication.

## [0.4.0-dev.39]

Compatible UI correction: Open Quartermaster Menu is registered only in the player inventory control list and stays visible regardless of contents or the selected carried bag. It opens nearby server discovery without requiring an existing loot target. Save remains disabled until a discovered target is selected. Sort controls and world-object context navigation remain unchanged. Offline regressions pass; native UI acceptance pending. No deployment/publication.

## [0.4.0-dev.38]

Compatible server planning optimization: prepare destination configurations, effective rules and one preset-library snapshot per synchronous trip batch instead of rebuilding them per item. Keep live source, target, permission, capacity, revocation and final transfer checks. Existing source item-reference snapshots, static classification cache and native bulk transfer pipeline retained. Offline cost regression covers 100 item decisions without repeated configuration/rule construction; actual dedicated startup timing remains unverified. No deployment/publication.

## [0.4.0-dev.37]

Compatible floor/proximity UI and startup hotfix: register Sort in native floor controls, keep floor/parentless aggregate intent controls visible through transient empty refreshes, and initialize/reuse Executor safely when BatchExecutor loads first. Server source validation and native transfer authority unchanged. Includes dev.36 scope menu fix. Offline regression added; native Proximity/dedicated retest pending. No deployment/publication requested.

## [0.4.0-dev.36]

Compatible UI hotfix: fix Room and Proximity submenu creation to use the native ISContextMenu:getNew(parent) colon-method contract. Resolves the console-confirmed nil parent crash when opening scope choices. Strict parent-contract regression and Building -> selected Room/Proximity callback coverage added. Discovery authority and room tokens unchanged. Native/dedicated retest pending; no deployment/publication requested.

## [0.4.0-dev.35]

Compatible Bags hierarchy correction: move the existing Bags leaf under Clothing & Accessories and label it Bags. Preserve B47_ContainersBags, all bag item memberships and saved Containers-rule coverage. Bandoliers/holsters/pouches retain Equipment Accessories. No native item metadata or transfer changes. Native/dedicated acceptance pending; no package/deployment/publication requested.

## [0.4.0-dev.34]

Compatible Clothing & Accessories hierarchy correction: Accessories, Equipment Accessories, Jewelry, Gloves, Headware, Shirts, Pants, Undergarments, Footware, Eyeware, Outerware, Other Clothing and Costumes. Applicable clothing sections have separate - Armor leaves; explicit ProtectiveGear or armor tags establish armor identity. Separate eyewear, equipment and costumes; jewelry covers necklaces/earrings/wrist jewelry as well as rings. All 290 vanilla protective items follow armor slots, retaining historical protective-rule membership. Eight verified vanilla mascot/bunny costume pieces plus explicit modded costume/mascot tags are supported; branded regular clothing remains normal clothing. Existing item metadata, protocol and transfer authority unchanged. Native/dedicated acceptance pending; no package/deployment/publication requested.

## [0.4.0-dev.33]

Compatible taxonomy expansion: Ammunition splits reusable Containers from Boxes & Cartons, with Loose Ammo and Magazines & Clips labels. Bandoliers move to Clothing/Accessories. Beverages splits into Alcoholic, Soda, Water, Empty Water Containers, Milk and Other Drinks, retaining the former Non-alcoholic Drinks ID as a saved-rule family. Books and written material is renamed Books. Classification remains definition-based; native item metadata/transfer authority unchanged. Native/dedicated acceptance pending; no deployment or publication requested.

## [0.4.0-dev.32]

Compatible taxonomy extension: add Jewelry under Clothing and classify finger-worn rings by normalized body-location metadata, including compatible modded rings. Rename Cutting and forestry tools to Woodworking Tools without changing that category ID or membership. Retain dev.31 scissors/Stationary correction. Native and dedicated acceptance pending; no deployment or publication requested.

## [0.4.0-dev.31]

Compatible category correction requested by the user: Scissors and Safety Scissors move from Cutting Tools to Stationary. Shorten the display label to Stationary in all 29 language tables; retain the B47_Stationery identifier and native metadata. No other taxonomy changes. Native/dedicated acceptance remains pending; no deployment or publication requested.

## [0.4.0-dev.30]

Compatible inventory UI correction: canonical presentation keys drive row categories and native Category sorting without native item metadata mutation. Startup-only hook reconciliation, scoped display interception and native acceptance preparation. Actual native/client/dedicated compatibility remains pending.

## [0.4.0-dev.29]

Compatible client appearance feature in the ongoing 0.4.0 prerelease series. Background-only opacity with local persistence; native inventory metadata audit identifies gameplay coupling and leaves Category integration blocked/unchanged. No gameplay or taxonomy changes. Native visual acceptance pending.

## [0.4.0-dev.28]

Compatible UI feature checkpoint in the ongoing 0.4.0 development series: native resize grip, bounded local geometry, adaptive divider and controller layout actions. No gameplay or taxonomy changes; native acceptance pending.

## [0.4.0-dev.27]

PATCH-type fixes for tooltip lifecycle, viewport limits, controller inspection, concise explanations and plain-text fields. Route optimization is an additive MINOR-type feature within the ongoing 0.4.0 prerelease series; authority and assignment semantics must remain intact. Native acceptance pending.

## [0.4.0-dev.26]

Unreleased compatible discovery and grouped-configuration enhancement within the 0.4.0 series: room-first interactive scope, whole-building default, proximity ordering and explicit shared/override furniture settings. Existing per-section configurations preserved. Native/dedicated acceptance pending.


## [0.4.0-dev.25]

Unreleased compatible Lua-only ground source enhancement in the 0.4.0 series. Short-lived server references and native pickup; persistent decoration protection excluded. Native/dedicated validation pending.


## [0.4.0-dev.24]

Unreleased compatible movement enhancement within the 0.4.0 development series: bounded server planning and prefetched batches; native grouped transfer queues with per-item authorization/confirmation. Movement capability changes require matched peers. Native/dedicated validation pending; no deployment/publication.

## [0.4.0-dev.23]

Compatible UI enhancement: container rail previews use validated physical objects and their current native sprite frame; fallback remains for unavailable sprites. Per-instance identity cache, bounded diagnostic reasons and unchanged server handles. Retains dev.22 tooltip correction. Native visual/dedicated acceptance pending.

## [0.4.0-dev.22]

Compatible UI hotfix: measured screen-space container tooltips, bounded labels and instance cleanup. Gameplay, taxonomy and protocols unchanged; native visual acceptance pending.

## [0.4.0-dev.21]

PATCH diagnostic checkpoint: opt-in bounded native inventory Category adapter boundary traces. The user reports dev.20 labels still unchanged in-game. No new rendering strategy, taxonomy or gameplay changes; native cause/acceptance remain blocked pending diagnostic evidence. Separate bulk-transfer/collision native audit recorded without combining gameplay implementation.

## [0.4.0-dev.20]

Compatible PATCH UI correction: canonical cached Category labels, deferred compatibility checks, reload-safe registration and complete return preservation. Native category sorting and grouping retained. Dev.19 responsiveness instrumentation retained. No taxonomy or gameplay changes; native acceptance pending.

## [0.4.0-dev.19]

Stage A: bounded correlated Sort latency instrumentation and immediate preparation acknowledgement. No cache/planner optimization before native timing evidence. Existing authority, transfer semantics and frozen taxonomy retained. Dedicated acceptance pending.

## [0.4.0-dev.18]

Compatible reliability corrections for grid-floor checks, bounded Sort diagnostics, target editing and font-aware layout. Native transfers, taxonomy protocol 6, schema 2 and world root 1 retained. Dedicated acceptance remains untested; no deployment or publication.

## [0.4.0-dev.17]

- Restore dedicated-server reconstruction of Sort timed actions by queuing native walk and inventory-transfer types with local per-instance authorization guards.
- Add off-by-default, operation-correlated Sort transition diagnostics and a focused native-metatable regression.
- Keep taxonomy protocol 6, configuration schema 2, world root 1 and existing native transfer authority unchanged.

## [0.4.0-dev.16]

- Remove the B47ANCED suffix from the localized inventory Sort button; retain the current movement behavior.
- Audit native placement and ground pickup authority; keep ground sorting disabled pending a verified server-side placed-instance association.

## [0.4.0-dev.15]

- Add deterministic weighted evidence/confidence diagnostics and a generic Medical metadata refinement for modded items; preserve all 5,092 vanilla classifications.
- Audit installed Workshop definitions offline, with package/Mod ID/variant distinctions and duplicate/fallback review.
- Default to category → subcategory → item; add client-local optional Mod grouping without changing saved rules.
- Advance taxonomy protocol to 6 for changed modded membership; retain schema 2 and existing saved IDs.
- Document the native authority blocker for deliberate Place protection and ground/proximity sorting.

## [0.4.0-dev.14]

- Improve first-open discovery and Shopping readiness, building scope, category presentation and player-facing terminology.
- Keep stable taxonomy IDs, protocol 5 and saved configuration formats.

## [0.4.0-dev.13]

- Improve selected-container visibility, UI scaling and catalog reuse.
- Reject active original Quartermaster or Better Sorting by exact Mod ID.
- Preserve taxonomy protocol 5 and saved configuration formats.

## [0.4.0-dev.12]

- Consolidate Medical Supplies and Camping Supplies; retain exact historical narrow rules.
- Correct eight reviewed vanilla item purposes, preserve saved membership, and advance taxonomy protocol to 5.
- Final player-facing taxonomy freeze pending native acceptance; development package only, no deployment or publication.

## [0.4.0-dev.11]

- Consolidate practical storage destinations while preserving dev.10 semantic purpose and every saved narrow rule. Hide unpopulated category rows unless selected. Taxonomy protocol 4; schema/world root unchanged. Development testing only; no deployment/publication or native acceptance.

## [0.4.0-dev.10]

Compatible taxonomy correction and five added storage categories within the 0.4.0 development line. Preserve existing category IDs/configuration and server routing authority; taxonomy protocol advances to 3 for corrected peer parity. Repair beverages, instruments, tobacco, writable papers, farming packaging, household/electrical/material/tool semantics and conservative catalog exclusions. Full static re-audit, focused/full offline regression and clean testing package; native acceptance pending. No deployment/publication.

## [0.4.0-dev.9] - 2026-10-04

- Compatible MINOR feature work within the 0.4.0 prerelease line: independently expand the metadata-driven storage taxonomy. Preserve the original 18 IDs as broad compatibility rules, with specific category routing ahead of broad rules and explicit item rules first.
- Taxonomy version 2 reads previous rules without implicit world writes; mixed-version writers must not be used. Testing package only; no deployment/publication, native gates pending.

## [0.4.0-dev.8] - 2026-10-04

- PATCH-level UI remediation: explicit layout owns widget/scrollbar geometry; suppress overlapping native title/status-bar paint in the owned main window.
- Reserve font-aware footer status space and synchronize visible/hidden scrollbars.
- Preserve selection, protocol, persistence and server authority. Source-only; native verification pending.
- Fix fractional character Z rejecting same-floor discovery/session access; retain distance, locks, safehouse, exact handles and all server validation. Add discovery/opening/local-handler diagnostics.

## [0.4.0-dev.7] - 2026-10-04

- Runtime remediation: bounded client catalog preparation and reuse; remove redundant opening scans.
- Register both transport events with dispatch-side guards, supporting connection changes after shared Lua initialization.
- Include empty native animation/action-group directories for this mod only.
- Distinguish read-only confirmation timeout from uncertain writes; add bounded request diagnostics and retry discovery.
- Preserve dev.6 UI, server authority and staged Save/Cancel. Native verification pending.

## [0.4.0-dev.6] — Unreleased

- Introduce the embedded reusable B47ANCEDUI theme/components and convert owned Quartermaster presentation without changing authoritative gameplay or persistence. Native visual/controller acceptance pending.

## [0.4.0-dev.5] — Unreleased

- Personal Shopping Preferences, Wanted/Needed possession targets, provenance-aware replay-safe additions and bulk Dibs planning; native acceptance pending.

## [0.4.0-dev.4] — Unreleased

- Development checkpoint for clearer collection results and optional Project Cook / Neat Crafting / Neat Building shopping controls.
- Native SP/listen/dedicated validation remains pending.

## [0.4.0-dev.3] — Unreleased

- Current-inventory Wish goals supersede cumulative counters; authoritative remaining demand integrates with Shopping.
- Optional Project Cook frontend integration resolves native CraftRecipe and supported EvolvedRecipe operations; unsupported portions fail closed.
- Native SP/listen/dedicated validation remains pending.

## [0.4.0-dev.2]

- Native Craft/Build planning for supported whole-item consumables, OR alternatives and non-degrading retained tools. Persisted gross projects reconcile current carried supplies once and reuse the native Shopping executor.
- Shared loaded-definition item picker for manual Wish/Shopping additions; physical Wanted establishes an absent target-1 Wish without resetting existing targets/counters.
- Needed-first Dibs details and non-color inventory icon badges; Wanted call order preserved.
- Project Cook and exact cumulative Wish acquisition/remaining bridge remain blocked. Native acceptance is pending; no deployment or publication.

## [0.4.0-dev.1]

Unified Shopping mode, authoritative item Dibs, personal Shopping and inactive Wish definitions; native withdrawal-only collection. Native acceptance pending.

## [0.3.0-dev.8]

Complete owned configuration frontend and server-authoritative preset storage. Remove the Quartermaster runtime dependency; retain read-only legacy container imports. Standalone native and dedicated multiplayer validation pending.

## [0.3.0-dev.7]

Match explicit item rules against both instance and script display names so Vehicle Key includes vehicle-named car keys. Preserve custom-name matches and whole-keyring transfers. Native retest pending.

## [0.3.0-dev.6]

Canonical runtime identity and read-only legacy imports; clean deployment and exact source/package/stage parity gates. Native Save verification pending.

## [0.3.0-dev.5] - Unreleased
- Replace global next() emptiness checks with pairs-based checks for PZ Lua compatibility; regression tests run with next unavailable.

## [0.3.0-dev.4] - Unreleased
- Rename to B47ANCE'd Quartermaster, Mod ID B47ANCEDQuartermaster; retain Workshop ID 3807217050.
- Update source/build identity while preserving Lua, persistence, wire and sandbox compatibility identifiers. Update enabled-mod selections from QuartermasterSorting; do not enable both copies.

## [0.3.0-dev.3] - Unreleased
- Extend owned native sorting execution toward carried bags, trip loading and the production sort command. Native validation pending.

## [0.3.0-dev.2] - Unreleased
- One-item native timed-action executor development; accepted vanilla authority boundary after dispatch. Native multiplayer validation pending.

## [0.3.0-dev.1] - Unreleased
- Standalone extraction in progress: server-issued target handles, owned authoritative persistence and staged Save/Cancel regressions.
- Original native category resolver/catalog and authoritative destination-selection primitive; Better Sorting is reference-only under clean-room rules.
- Static vanilla/modded coverage audit and development-only loaded-catalog diagnostics. Native/dedicated evidence and full frontend/preset/movement replacement remain pending.
- Architectural milestone and canonical-ID migration; not release-ready.

## [0.2.0-dev.2] - Unreleased
- Fix native picker tree bounds so footer controls remain visible on open and resize.
- Compatible presentation fix; no saved-data or gameplay changes.

## [0.2.0-dev.1] - Unreleased

- Renamed Quartermaster - Simple Sorting to Quartermaster - Balanced Sorting. Mod ID changes from QuartermasterSimpleSorting to QuartermasterSorting; Workshop ID remains 3807217050. Update server Mods= and saved mod selections on both server and clients.
- Multi-container editor development; runtime and dedicated multiplayer acceptance pending.
- Retains the unpublished poster/icon and tooltip formatting changes.

## [0.1.4] - Historical

Published under the former identity. Added category/mod/item hierarchy and search, bulk controls and effective counts. Published row-tooltip cleanup separately. See docs/WORKSHOP_PUBLICATION.md for dated evidence.
