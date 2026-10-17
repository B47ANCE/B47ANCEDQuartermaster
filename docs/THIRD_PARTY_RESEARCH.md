# Third-party interoperability provenance

## Extended Categories — 2026-10-15

Purpose: let Quartermaster consume the installed category mod's native item metadata, while preserving dedicated-server routing when different players choose different category detail settings.

**Identity:** [Extended categories – Better Hoarding!](https://steamcommunity.com/sharedfiles/filedetails/?id=3650035249), Workshop 3650035249, author Kechna, exact Mod ID `CAExtendedCategories`, locally installed version 1.9.0. Local metadata/license/interface fingerprints are in [the dated evidence record](EXTENDED_CATEGORIES_EVIDENCE_2026-10-15.json). The public page advertises dynamic item categories and three detail choices. This does not establish runtime correctness with Quartermaster.

**License:** the installed LICENSE.txt reserves copyright and prohibits redistribution/adaptation of code/assets without permission; it permits Workshop use and separately describes function-call dependencies without copying. No license permitting code/asset reuse was granted or assumed. This adapter requires no external function calls, copied category tables or bundled dependency: it reads vanilla `getDisplayCategory` metadata when the user independently enables the external mod. Source/data/assets/text imported: **NONE**. Upstream files modified: **NONE**. No new attribution/redistribution obligation is claimed; this is not legal clearance.

### Neutral observed contract

- Native category metadata is the interoperability boundary. Runtime item categories can differ from their script defaults as contents/state change.
- Client-selected detail levels can differ from the dedicated server's detail. Local source interface comments/settings entry points corroborate the author's public explanation. There is no documented server-wide category agreement API relied upon here.
- The installed mod.info declares Better Sorting variants incompatible and loads after EURY_CONTAINERS/CleanUI. Quartermaster does not change those mods' load-order/conflict rules or merge their classifiers.
- No category inference algorithm, mappings, colors, refresh implementation, translation text or timed-action overrides were inspected for reproduction or copied. Research used metadata/license, public page claims and narrow interface signatures/settings placement only.

### Independent design

1. Add the exact active Mod ID to Quartermaster's existing `explicitCategorySelections()` mode (already used for client-local Better Containers categories).
2. Continue reading native script/runtime category getters and native translation keys. Do not call or require the external classifier or overwrite inventory render/sort/refresh methods.
3. A group checkbox resolves to the currently represented item-name selections, using the existing Model/Catalog/preset/configuration paths. It does not persist a new client-only category rule as authoritative truth.
4. Existing picker-open invalidation refreshes the bounded native catalog for this mode. No per-frame scan, new RPC, category schema, hidden gameplay option or source/destination permission bypass is introduced.
5. Server routing treats explicit member selections as configuration intent and still validates native items, physical handles, permissions, revisions and transfer capacity.

This preserves Quartermaster's established display-name selection semantics, including identical names sharing selection. It is **not** a new FullType-only configuration format. Category selections are snapshots of represented members: new members/detail changes require reselection, and a selected food/fluid item remains explicitly selected if its dynamic category later changes. Runtime observed categories may appear alongside script-default categories. Category colors and detail switching belong to the external mod; Quartermaster does not force a setting on another player. Existing saved category rules are preserved rather than silently rewritten; reselect affected categories to use explicit membership. The external mod remains optional and absent/disabled sessions retain vanilla behavior.

### Validation and review

[TESTED OFFLINE] Independent native-shaped fixtures cover exact Mod ID activation, similarly named/inactive absence, coexistence with Better Containers, three synthetic peer-detail labels, select/clear/count behavior, explicit member routing with a different server category, and unchanged native inventory renderer/sorter/refresh methods. No external Lua is executed by tests; no external category table is duplicated. Tests exercise existing production Model/Catalog/destination paths.

[RUNTIME GATE] Native SP, dedicated remote client/server, dynamic food/fluid updates, existing presets, mixed client detail settings and inventory UI combinations remain NOT TESTED. Dedicated G7 and stable G8 remain blocked for the current iteration.

Clean-room PR checklist:

- [x] Exact source/author/version/license and portable fingerprints recorded.
- [x] Neutral interface contract separated from implementation.
- [x] No external code, assets, classifier, translations or copied documentation imported.
- [x] Upstream files remain read-only; no new dependency or private API introduced.
- [x] Server authority preserved; optional/absent behavior and differing-peer categories tested offline.
- [ ] Independent reviewer signoff. Required before merging this compatibility PR; author self-check is not independent signoff.

No user approval is required to develop this independent adapter. The remaining review is a merge gate, not a reason to copy upstream code or to claim native compatibility already verified.
