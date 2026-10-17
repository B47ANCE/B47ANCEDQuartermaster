# Changelog

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

## [0.4.0-dev.3] â€” Unreleased

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
