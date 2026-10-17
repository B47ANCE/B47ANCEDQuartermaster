# Native categories and optional inventory mods

Project Version: 0.5.0-dev.1

## Decision and behavior

The user explicitly retires the B47 taxonomy. This starts the 0.5 development
line: an intentional change to default category presentation in this 0.x
project. Persisted config/schema and movement capability are unchanged. There
is no B47/native taxonomy switch: active categories always come from native
DisplayCategory, then native getCategory/type fallback when absent.

- Standalone: vanilla category values and vanilla inventory presentation.
- Better Sorting: category values it exposes through native item/script metadata
  appear in B47's picker and are resolved on actual server items for routing.
- Better Containers: native metadata exposes its customized categories in the
  picker; B47 leaves its inventory labels, filtering, pinned ordering and render
  methods untouched. Its category edits can be client-local, so category clicks
  store the displayed members as ordinary explicit item-name selections.
- Both enabled: use whatever native metadata the configured mods/load order
  expose. B47 neither imports nor arbitrates their category databases.

Better Containers selections are snapshots of known script types, not counts of
physical items. New instances with matching names remain eligible. Reselect a
category after changing its membership or installing new types. Existing shared
display-name semantics remain: identical names share explicit selections.
Normal visible-range/bulk operations still edit only displayed item rows.

Category IDs use an owned bounded canonical hex encoding of the native token;
localized display names never become persisted keys. Vanilla IGUI_ItemCat_
translations are read through getText, including translations injected by mods.
No temporary items, native mutation or external classifier calls are needed.

## Authority, configuration and previous rules

Clients submit container configuration intent. Server access/revision validation
and native movement guards are unchanged. The server independently reads each
real item's native category when evaluating a native category rule. A forged or
different client category token does not recategorize a server item. Explicit
item selections are existing authorized configuration, not category assertions.
Better Containers local metadata is never promoted into shared server authority.

The retired owned resolver is frozen as LegacyCategorizer for compatibility
with previous saved B47 rules and presets. It does not choose active categories.
Previous selected rules are visibly prefixed and shown without recreating the
old hierarchy; opening a window does not rewrite or delete saved data. Their
original priorities/membership evidence remain available. External mods changing
metadata can affect interpretation of old rules; review previous selections
when changing the mod set. Removing those mods leaves their stored native rules
intact but inert if their category no longer exists. No destructive migration or
automatic rollback is claimed.

There is no new meaningful global gameplay mode to configure: the owner removed
the alternate taxonomy. Existing server sandbox settings remain authoritative.
The category-token size/encoding bounds are internal protocol safety limits.
All peers must run the same intended version and optional shared mods. Client
local UI preferences do not grant shared item movement or bypass access checks.

## Preparation UI

The loading window disables native frame/title painting and paints the B47
background, border, product heading, preparation text and progress itself.
Existing native drag/close/controller actions remain. Cancel, progress and title
geometry follow current font metrics; cancel does not open a hidden editor or
start gameplay requests. Better Containers sessions rebuild the bounded local
catalog on opening so changed local script categories are picked up.

## Clean-room provenance

Research was limited to public metadata/API signatures, native getter/setter
boundaries and entry-point placement. No external implementation, classifiers,
category tables, translations or assets are copied or executed in tests. No
external files are modified. Their licenses are UNKNOWN; no reuse authorized.
Independent clean-room reviewer signoff is pending on the draft PR.

- [Better Sorting](https://steamcommunity.com/sharedfiles/filedetails/?id=2313387159):
  BetterSortCC, ChthonicKnight, installed 2.1.5, 42 variant. Observed native
  category setters/shared data and client refresh entry points. No private API
  dependency added. mod.info SHA-256:
  `2fd72c06722bd6248d747d262ada697760e8a0f21ab1feb34f7d7c495154694c`.
- [Better Containers](https://steamcommunity.com/sharedfiles/filedetails/?id=3586216562):
  Eurymachus, current installed 42.20 variant EURY_CONTAINERS; older 42 variant
  REORDER_CONTAINERS. Installed modversion UNKNOWN. Public page and installed
  entry points show native category changes, category filters, pinned order,
  nested/proximity UI and custom categories. Categorization/customization code
  is client-side. mod.info SHA-256:
  `ff8b6fd6341dff1ed65a8725278e41fff8197a89d716f5a553a10428a4fabcef`.
  Inspected category-interface file SHA-256:
  `692bbe5c0633dbae6d5a1fdcd467657756de1a8e0c5fc8b15c732ea682d707ee`;
  proximity-controls interface:
  `b8d6018ee316263c1317bd895ca191ccaf4d14548dda9caaf61f23910d1ea23c`.

Source/data/assets imported: NONE. Existing team-owned taxonomy code is retained
as retired compatibility evidence. No new third-party attribution obligation is
introduced; this is not a legal clearance or permission to redistribute mods.
Original Quartermaster remains an exact-ID conflict.

## Validation and runtime gates

Commands using configured Python from repository root:

```text
python tests/run_tests.py
python scripts/check_native_categories.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output <local-native-report.json>
python scripts/check_versions.py --root .
python scripts/check_deployment.py
```

The native audit reads script definitions and vanilla class getCategory constants
without executing/building Java. It compares the Lua resolver to native metadata,
including fallbacks. Historical owned-taxonomy tests now explicitly exercise
LegacyCategorizer; the removed inventory-interception contract tests are retained
as historical files and replaced by a no-interception assertion. Active authority,
planner/executor, 701-item transfers, native queue, UI, filters, ranges, data,
persistence and safety regressions still run against the current native resolver.
New tests cover native metadata, category tokens, server mismatch rejection,
retired rules, standalone/optional-mod combinations, explicit category snapshots,
selection counts, untouched inventory methods and loading layout at 14/24/32 fonts.

[TESTED offline] Full suite PASS. Native metadata comparison: 5,105 declarations,
5,092 unique full types, zero mismatches. Version consistency and the 128-file
source manifest PASS. These replace the former 625 approved B47 deviations as
the current category comparison; the old audit/baselines remain historical.

[RUNTIME GATE] Offline optional-mod fixtures do not execute third-party Lua or
the native UI. Verify standalone, each optional mod, both, custom category edits,
load-order changes, native/proximity controls, filters/pins, game restart,
client join/rejoin, shared persistence and cancellation on dedicated MP. Existing
source validation for physical/ground handles remains; unresolved nested or
synthetic sources still fail closed. Better Containers nested MP restrictions
are not bypassed. No blanket compatibility or MP PASS is claimed.

G7 NOT TESTED/BLOCKED; stable G8 BLOCKED. No package, deploy, Workshop upload,
Steam restart or game/server launch is performed for this source iteration.
