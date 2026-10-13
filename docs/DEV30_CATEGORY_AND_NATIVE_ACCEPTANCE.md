# dev.30 Category integration and native acceptance

## Baseline

[VERIFIED] Canonical version is 0.4.0-dev.30, a compatible UI correction within the 0.4.0 development series. Installed source targets B42.21; metadata minimum remains 42.20.3. Archived dev.29 package SHA-256 matches the supplied baseline: b0c0cc2760227b539364f35311b30ef937c1354f5a6821acd554ccdca16bda0f. Its historical receipt retains its original path and evidence; artifact now lives under dist/history/0.4.0-dev.29.

## Category architecture

[VERIFIED native Lua] ISInventoryPane.refreshContainer creates Lua row tables, assigns row.cat and sorts them. The native Category comparators compare category keys with equipped precedence and item-name tie breaking. Native saveSelection records item identity; restoreSelection adds row-indexed entries, requiring stale selection indices to be cleared before restoring after reordering.

[TESTED offline] The owned refresh wrapper delegates the existing refresh, classifies newly built rows through the unchanged canonical resolver, assigns only row.cat/b47Category/b47NativeCat, and reuses the exact active native Category comparator. Selection is restored by identity after reordering. Other sort comparators retain their existing behavior. Category ordering is stable canonical-key order rather than localized alphabetical order. Labels use the same canonical key through the current localization table.

[VERIFIED source] No InventoryItem or ScriptItem category setter, ModData mutation or network command is introduced. Ammo-menu and memento consumers still read native metadata. Resolver failures leave native rows/display available. Existing conflict policy remains authoritative for whether the adapter operates. Compatibility transitions refresh the model once and retain native sorting/display when blocked.

[TESTED offline] Text replacement is scoped to one pane's render invocation and its native Category region. Ordinary drawText, drawTextRight and drawTextCentre delegates are restored even when rendering throws. Dragged previews, job progress and expanded child detail text retain native behavior. Installation occurs at module load and once at OnGameStart; there is no per-frame hook installation. Startup reconciliation preserves earlier and later delegating wrappers using captured local functions, with idempotent repeated startup and row conversion.

[UNKNOWN / RUNTIME GATE] Actual active replacement-renderer compatibility remains unproven. Installed metadata/capability-presence observations are in dist/handoffs/dev30-renderer-capabilities.json; no third-party implementation was copied or used to derive this implementation. Nondelegating renderers, independent Category caches, custom row structures or custom Category comparators may need an independently verified integration. Offline native-branch tests do not resolve this gate. Historical console evidence cannot certify dev.30.

SOURCE CODE COPIED: NO. IMPLEMENTATION DERIVED FROM REFERENCE: NO. Integration was derived from installed vanilla Lua and the owned canonical resolver. Third-party observations establish capability presence only.

## UI acceptance

Resizing, divider, geometry persistence, transparency, world-highlight visibility, zombie visibility, controller, split-screen and installed-mod coexistence are all NOT TESTED natively for this candidate. Existing dev.28/dev.29 offline tests remain passing. docs/DEV30_NATIVE_ACCEPTANCE.md defines the required human test matrix and evidence capture. No PZ/server was launched and no deployment, staging or publication was performed.

## Performance

[VERIFIED source] Classification runs on existing UI refresh rows, uses the canonical script-identity/option cache and adds no world discovery or database scan. Category sorting adds one native-comparator sort per refresh only when that comparator is active: O(n log n). Other sorts do not get the additional sort. Selection bookkeeping is per refresh. Rendering substitutes text for painted rows and performs constant-time revision/option checks; canonical invalidation or option/policy transitions trigger a single ordinary refresh. No RPCs or background hook polling were introduced. Geometry and opacity remain local preferences; no gameplay sandbox setting is appropriate. Actual frame times with the installed UI set are UNKNOWN.

## Invariants

[TESTED offline] Frozen membership: 5,092 before, 5,092 after, zero changes. Receipt comparison limits changed runtime files to InventoryCategories.lua, Identity.lua and mod.info. Thus protocol 6, schema 2, world root 1, taxonomy, movement authority, routing, discovery, appearance and resizing source remain byte-identical to dev.29. No unauthorized gameplay changes.

## Artifact

Development ZIP rebuilt for authorized publication: dist/current/B47ANCEDQuartermaster-0.4.0-dev.30.zip. Runtime files: 127. SHA-256: 361eb4150e506b692b33e3afa357db8d56e21886a70e7e8abf449260bcfbae43. Full source/package byte parity PASS; detailed hashes and restricted baseline diff in dist/handoffs/dev30-build-receipt.json. Subsequent authorized publication is recorded in docs/WORKSHOP_PUBLICATION.md; the original implementation-stage statements below describe that earlier stage.

## Exact validation commands

Run from this project with the bundled Python executable `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`:

```
python tests/run_tests.py --package
python scripts/check_versions.py --root . --release
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev30-vanilla-diff.json
python scripts/record_dev30_evidence.py
```

[TESTED offline] Full Lua 5.1 suite, installed native comparator/render-branch fixtures, version consistency, 29-language parity, runtime scope and ZIP parity pass. Logs: dist/handoffs/dev30-package.log. No third-party files were modified.

## Gates

G6 native client: NOT TESTED. G7 dedicated multiplayer: BLOCKED / NOT TESTED. G8 release readiness: BLOCKED. Version/artifact checks pass only their own scope. The UI change owns no shared gameplay state; the complete gameplay package still requires dedicated MP acceptance. Development artifact creation is not authorization to deploy or publish.
