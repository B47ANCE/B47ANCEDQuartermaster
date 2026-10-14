# Roadmap

Project Version: 0.4.0-dev.49

## Current dev.25 ground source implementation

Lua-only explicit Floor and resolvable aggregate sources are implemented. Short-lived server references, native queued acquisition and observed carrier/destination confirmations preserve the native PZ authority boundary. Movement capability 3 requires matching builds. Native Proximity Inventory UI and dedicated transfer acceptance remain unverified: G7 NOT TESTED/BLOCKED; G8 BLOCKED. No deployment/publication. See [details and native gates](DEV25_GROUND_SOURCES.md).


## dev.21 Category failure investigation

User confirms dev.20 loaded but visible Category labels remained vanilla with Neat UI. Added OFF-by-default bounded boundary diagnostics; no new renderer or gameplay changes. Full offline suite and 5,092-entry zero-change comparison passed. G6 diagnostic acceptance BLOCKED, G7 NOT TESTED, G8 BLOCKED. Bulk-transfer/collision native audit is separate and implementation remains outstanding. See `dist/handoffs/dev21-category-investigation.md` and `dev21-bulk-and-collision-audit.md`. Published dev.20 remains unchanged.

## dev.20 Inventory Category column hotfix

Compatible PATCH correction on dev.19: Category cells use the canonical resolver cache and current localized labels. Compatibility is checked during rendering rather than permanently skipping registration during early Lua loading. Native row.cat, sorting, grouping and item definitions stay unchanged. Full offline regression and frozen 5,092-item comparison passed; actual B42.21 inventory/loot/controller/scaling and second-language client acceptance remain UNTESTED. Dev.19 Stage A instrumentation is retained; its dedicated timing gate remains BLOCKED. See `dist/handoffs/dev20-inventory-category.md`. No deployment or publication.

Current source version: 0.4.0-dev.49. Stage A adds bounded correlated Sort timing, immediate preparation acknowledgement, and independent B47 carry-allocation regression. Background destination-index optimization awaits correlated native root-cause evidence; no gameplay/cache decisions changed. See `dist/handoffs/dev19-responsiveness.md`. Native dedicated timing remains BLOCKED.

Historical dev.15 definition-based modded classifier audit and optional Mod grouping are implemented for offline review. Placed-item protection is blocked at its native authority/source-path gate. The dev.14 discovery/building, hierarchy and inventory Category presentation pass remains pending runtime review. Next: native SP first-open discovery and Sort transfer acceptance, then native SP and 1080p/1440p/2160p display acceptance, listen and dedicated two-client G7 tests, then G8 review. Verify server activated-Mod-ID API and Better Containers non-category coexistence if its source/runtime is available. No taxonomy or saved-data changes are planned.

Standalone source now owns the frontend, preset library, icons, server rules and native movement. Remaining work is native standalone/dedicated acceptance and any explicitly approved legacy preset-definition migration, tracked in MASTER_HANDOFF_STATUS.md. Deployment/publication require explicit authorization. Entries below are historical milestones.

- 0.1.4: bulk/range controls, category/mod/item search, metadata-based mod subgroups and effective item-name count implemented and host-validated. Published to Workshop item 3807217050 on 2026-09-24. Native and multiplayer acceptance pending; local live-mod deployment unchanged.

- 0.1.0: standalone instance adapter, approved conversion and tri-state hierarchy, filters, stable scrolling, controller support, localization and host regressions.
- Native acceptance: rendering/hitboxes, wheel/scrollbar, controller focus and preset editor, save/restart/removal, large database.
- Multiplayer acceptance: hosted and dedicated clients, unchanged Save authority, replication, late join and preset conflicts.

No automatic launch, live deployment or Workshop publication. Optional persistent expansion and expand-all are outside this initial slice.

## dev.23 container presentation checkpoint

[TESTED — offline] Full regression and package checks passed. dev.22 tooltip positioning/lifecycle retained. Container rail uses current validated physical-object sprite textures with generic fallback, instance caches and bounded optional diagnostics. Presentation only; taxonomy 6, configuration schema 2 and movement protocols unchanged. [RUNTIME GATE] Actual native UI/sprite acceptance and dedicated two-client visual comparison are not tested; overall G7/G8 remain BLOCKED. Category-column investigation, bulk movement and collision recovery remain outstanding. Dev.23 subsequently published as a user-authorized development testing build; local live installation unchanged. Native gates remain pending. See `dist/handoffs/dev23-container-presentation-report.md`.

See [dev.24 pipeline implementation and runtime gates](DEV24_PIPELINE.md).

## dev.26 scope and furniture candidate

See [DEV26_SCOPES_FURNITURE.md](DEV26_SCOPES_FURNITURE.md) for current ownership, persistence, migration, UI behavior and acceptance gates. Offline evidence does not establish native persistence or dedicated multiplayer readiness. G6 NOT TESTED; G7 BLOCKED; G8 BLOCKED.


Current dev.27 UI remediation and bounded route candidate: [implementation, offline evidence and pending native gates](DEV27_IMPLEMENTATION.md). Calibrated native travel-time optimization remains pending.


Current dev.28 resizable-window candidate: [native audit, implementation and pending acceptance](DEV28_WINDOW_LAYOUT.md). Presentation only; inventory category adapter unchanged; no deployment/publication.


Current dev.29 independent tracks: [category audit/blocker and adjustable appearance implementation](DEV29_CATEGORY_AND_APPEARANCE.md). Category integration remains unresolved; transparency passes offline checks only. Native acceptance pending; no deployment/publication.
