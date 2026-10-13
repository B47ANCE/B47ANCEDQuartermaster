# v0.1.4 implementation and evidence

This record and the current README supersede historical two-level hierarchy and v0.1.3 select-only range descriptions in the earlier architecture/testing notes.

## Ownership investigation before grouping

Inspected installed Build 42.20.4 projectzomboid.jar using a host-only Java class-file reader. No Java runtime component was added. `zombie.scripting.objects.Item` inherits `zombie.scripting.entity.GameEntityScript`, whose public `getModID(): String` returns the stored modId. `InitLoadPP` obtains it from `ScriptManager.getCurrentLoadFileMod()`. The engine's vanilla sentinel is exactly `pz-vanilla`; it is explicitly distinguished from installed mod IDs by the loader. This is metadata of the loaded definition, not a script-module name or a parsed file path.

Human-readable names use `getModInfoByID(id):getName()`, independently evidenced by vanilla `ISPauseModListUI.lua`. If the engine reports an ID but its title is unavailable, the actual ID is displayed. Missing/failed provenance and conflicting owner IDs among same-category/same-display-name variants go under the localized Other / Unknown group. Vanilla uses its own localized label. A runtime override can change the active script definition; no claim is made to reconstruct original authorship or the full override chain.

Ownership.build enumerates loaded item scripts once per picker, excludes hidden/obsolete entries and caches category/name attribution plus mod labels. Quartermaster still supplies selectable names and category membership. A failed ownership scan falls back to Unknown without hiding selectable items. No ownership resolution or script enumeration happens during draw/filter/bulk operations. Reopening rebuilds the catalog for the current load.

## Counting investigation

Quartermaster 0.24.0 Picker.prerender uses countSet(selectedCats), countSet(selectedItems), countSet(selectedPresets) for separate tab labels. It has no effective expanded item count. Picker.countChecked also counts keys of the active selection set. Adding those counts would violate the requested semantics.

Simple Sorting counts the union of known display names covered by effective category rules plus explicit item names (including stale explicit names), deduped by Quartermaster's actual display-name identity. Effective rules are obtained through the unchanged LootSorter.resolveEffective and getPresetStore, so valid linked presets contribute; category/mod UI headers never contribute directly. Unknown categories without known children contribute zero unless explicit names are also present. The label always uses `Categories & Items (N)`, including zero.

The count updates during each single/batch rebuild and immediately after original preset-selection callbacks. Between edits, the lightweight signature of linked preset names/generations/revisions detects upstream preset changes; a changed signature recomputes the count once. Filtering and expansion do not alter its meaning. The combined rows continue to represent manual selections, with preset contributions disclosed in the tooltip.

## Reused conversion pipeline

Model.applyRows is the common transaction behind ordinary item/category clicks, mod checkboxes, same-type ranges, context commands and visible-item bulk commands. Existing Model.setItem/setGroup/selectFiltered delegate to it. It snapshots intended states before mutation, converts each affected native full category once, applies explicit-name edits and normalizes once. A full category command uses its native category flag. Mod groups never gain persistence fields.

Visible operations collect only currently materialized ITEM rows. Category and mod-group ranges collect only same-type visible header rows and are explicit full-group commands, intentionally including the descendants of those groups. This follows the later subgroup specification and the existing whole-category behavior; collapsed unrelated groups are skipped by item ranges/visible-list commands. Global shared display-name rules necessarily affect their aliases even if an alias is hidden. Duplicate visible names invert from a single pre-edit snapshot rather than toggling twice. If aliases have differing native category coverage, a requested clear wins for their common explicit rule while unrelated native category flags remain.

## Input and focus

Instance-only mouse callbacks retain separate checkbox/expansion hitboxes. Ctrl-click preserves a stable-ID anchor. Shift applies the target's post-click state in either direction. Mixed-type endpoints fall back to a normal target action with a new anchor. Every rebuild checks anchor visibility; mode/filter changes also invalidate it.

Keyboard uses the window's normal setWantKeyEvents/isKeyConsumed/onKeyPress APIs, evidenced by vanilla ISWorldMap and ISMultiplayerZoneEditor. Ctrl+A/Ctrl+Shift+A are disabled while either text entry has focus, the picker is hidden/removed, the preset editor dimmer is active, or Presets mode is active. No global key handler is installed.

Normal ISContextMenu menus provide group operations and a visible-list submenu. The Bulk actions button is inserted into this instance's native controller navigation and sits below the existing preset-editor dimmer. A/B/X/Y and LB/RB mappings remain unchanged. Controller ranges use menu actions to set an anchor, navigate, and apply the target state rather than taking an existing button chord. The window minimum width is increased modestly to accommodate the canonical count label and four bottom controls. Original priority/save/preset callbacks remain owned by Quartermaster.

## Validation

PASS: Lua 5.1 parse; original model regressions; ownership metadata/ambiguity/fallback/cache tests; exact/partial/case-insensitive category search; mod and item search; literal-pattern safety; combined matches; Only Checked/Only Contents; search restoration; range select/clear/forward/reverse/mixed types/Ctrl anchors; hidden-anchor invalidation; category and mod ranges; visible select/clear/invert; context group actions; expand/collapse shortcuts; native Picker callbacks, controller reachability and focus handoff; effective counts/preset revision changes; icon alignment; scrollbar geometry and stable scroll; actual Quartermaster Core getters/setters and patch removal; 20,000-item single-normalization bulk fixture; all 29 language key/value parity; source/archive byte parity; installed Quartermaster hashes unchanged.

UNVERIFIED: actual native item metadata calls under Kahlua, keyboard capture alongside other windows, controller context-menu navigation, visual rendering/clipping, save/restart and hosted/dedicated multiplayer. API/bytecode inspection plus host tests do not substitute for those runtime gates. No game/server was launched and v0.1.4 was not deployed/published in this implementation.
