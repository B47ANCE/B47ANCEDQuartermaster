# Native categories and sorting-data retirement

Project Version: 0.14.0-dev.2

## Current development iteration

Optional Extended Categories (CAExtendedCategories, Workshop 3650035249) support uses native getters and the existing explicit category-member selection path. No third-party classifier is called or copied. Client detail differences cannot become server category authority. See [clean-room provenance, limitations and review](THIRD_PARTY_RESEARCH.md). Dangerous Load and the physical Supply Ledger are documented in the [current iteration report](LEDGER_AND_LOAD.md).

## Compatibility decision

The owner explicitly requests deletion of obsolete sorting formats and category
rules, while preserving current native rules, item selections, priorities and
valid owned preset links. This is an intentional breaking cleanup in the 0.x
line. New active/routed categories remain native: vanilla alone, or metadata
exposed by Better Sorting / Better Containers. Better Containers category clicks
still save explicit member selections, so client-local categories never become
server category authority. Reselect after category membership changes.

## One-way cleanup and ownership

SortingData runs only on authority when owned container data is accessed. It
validates and stages every slot before any object write. Recognized schema 1/2
envelopes and taxonomy revisions 0-6 are retired into the current schema 2 /
taxonomy 7 envelope. Only canonical native category tokens, explicit item names,
priority and owned b47:generation preset links survive. This parser is a bounded
one-way retirement step; it cannot route retired categories or recreate aliases.
Current entries win over old aliases. Known old owned namespaces are removed
after their entries have been safely carried forward. All slots are committed
with native transmitModData; changed configurations receive new revisions.

Whole Container parents are normalized without changing physical membership,
parent identity or child inherit/custom modes. Owned preset definitions retain
their name, generation, owner and explicit items; removal of retired categories
bumps definition/library revisions. Existing owned links keep their generation;
missing/deleted presets are not recreated. Numeric/boolean foreign preset links
are removed from container configs. Unresolved owned generation links remain
inert under the existing preset validation.

Foreign LSBox registries are no longer read or imported and are left untouched.
Unrelated object ModData, Shopping, Wanted/Needed, Dibs!, personal state and
sandbox-option aliases are outside this cleanup. There is no unbounded world or
inventory scan, new network mutation command, client cleanup or gameplay option.
This is a storage-format transition, not a configurable alternate taxonomy.

Unknown/corrupt/future schemas, invalid config shapes or mismatched physical
container identity fail closed with no staged object writes. Repeated loads are
idempotent. Do not downgrade after cleanup expecting retired rules to return;
restore a save backup for recovery. No real save is modified by offline tests.

Configuration capability 4, presets 2, movement 7, rooms 1 and taxonomy 7 reject older
peers on the affected paths. All clients/server must update together. Existing
server access checks, object handles, revisions and native item movement remain
required. Dedicated restart/reconnect/sync acceptance is a runtime gate.

## Runtime removal

LegacyCategorizer, Taxonomy and StorageSemantics are removed from production
source/manifest. Owned snapshots remain only under tests/historical as historical
evidence; they are not loaded, tested as current contracts or packaged. Their
previous taxonomy-specific tests remain historical. Current native category,
UI/grouping, persistence, authority and movement tests remain active. Catalog
preparation uses the existing custom B47 UI. No inventory labels are overridden.

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
only as historical test evidence outside runtime source. No new third-party attribution obligation is
introduced; this is not a legal clearance or permission to redistribute mods.
Original Quartermaster remains an exact-ID conflict.

## Validation

Commands from repository root with configured Python:

```text
python tests/run_tests.py
python scripts/check_native_categories.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output <local-native-report.json>
python scripts/check_versions.py --root .
python scripts/check_deployment.py
```

[TESTED offline] Full regression suite PASS. Native metadata comparison: 5,105
declarations / 5,092 unique types / zero mismatches. Version consistency and
126-file runtime source manifest PASS. Disposable fixtures cover native/item/priority
and owned-link preservation, all former owned namespaces, current precedence,
repeat load/save/reload, malformed/future data, physical identity, client rejection,
whole-container state, preset ownership/generations and unrelated data. Source
manifest excludes retired runtime modules.

The published 0.5.0-dev.1 ZIP was moved from dist/current to its historical
archive without deletion; SHA-256 remains
505ea0b59f155c39e8130620ffb30aac0995072029ee2b4db053066a302e0c9b.
Its release manifest/receipt and earlier published packages remain unchanged.

[RUNTIME GATE] Native save/load, optional mods, dedicated two-client concurrent
editing, join/rejoin, persistence, object replication and server restart NOT TESTED.
G7 NOT TESTED/BLOCKED; stable G8 BLOCKED. The dev.3 candidate includes this
cleanup and is authorized for Workshop MP testing distribution. Its manifest and
receipt record the actual upload outcome. Published 0.5.0-dev.1 package and
provenance are retained for recovery. No live deployment or game/server launch.
