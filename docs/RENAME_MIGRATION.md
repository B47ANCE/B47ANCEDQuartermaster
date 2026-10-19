# Rename and technical-ID migration

Project Version: 0.24.0-dev.2

## Current development iteration

Identity remains B47ANCEDQuartermaster / Workshop 3807217050, with B47ANCEDRooms required. No rename or save migration occurs. Movement capability 9 requires matching peers. Old deployment/version statements below are historical checkpoints. See [implementation and evidence](PROGRESS_CARRY_AND_CONTAINERS.md).

## Current identity — 0.4.0-dev.1

B47ANCE'd Quartermaster / `B47ANCEDQuartermaster` / Workshop `3807217050`.
Source: `src/B47ANCEDQuartermaster/42`. Current dev.8 source has no Quartermaster dependency. Standalone dev.8 is deployed locally. Enable only B47ANCEDQuartermaster among these sorting mods; disable Quartermaster and the legacy identities.
Do not enable any previous identity alongside the canonical mod.

Current modules/globals, network traffic, sandbox declarations and owned persistence use `B47ANCEDQuartermaster`. Legacy `B47ANCEDSorting`, `QuartermasterSorting` and `QuartermasterSimpleSorting` schema-1 envelopes are read-only imports, newest first, per container. Owned preset links use a namespaced generation and new container envelopes use schema 2 (schema 1 remains readable). Older experimental builds cannot safely write the new format. Current data wins, including explicit empty selections; malformed present data blocks fallback. Successful authoritative Save writes only the canonical namespace. Original LSBox imports remain supported; old versions that wrote LSBox do not need fictional legacy envelopes.

Sandbox reads prefer an explicit current value, then available legacy values. Native registration may populate current defaults before legacy values can be observed; existing-save custom sandbox settings must be reviewed under the canonical page. Automatic migration of native serialized sandbox options is not proven. No legacy options are registered or written.

The dev.8 standalone correction adds owned UI/preset storage. External preset definitions are not automatically imported: existing missing links remain visible and must be recreated/relinked. See MASTER_HANDOFF_STATUS.md for deployment and actual runtime evidence. Earlier rename records below are historical.

## Historical rename record — 0.2.0 development

The remainder records the earlier rename and its original evidence. It does not define the current identity.

## Canonical identity

| Field | Before | Now |
| --- | --- | --- |
| Public name | Quartermaster - Simple Sorting | Quartermaster - Balanced Sorting |
| PZ Mod ID | QuartermasterSimpleSorting | QuartermasterSorting |
| Workshop item | 3807217050 | 3807217050 (unchanged) |
| Dependency Mod ID | Quartermaster | Quartermaster (unchanged) |
| Dependency Workshop item | 3761216758 | 3761216758 (unchanged) |
| Project version | 0.1.4 from source mod.info | 0.2.0-dev.1 from root VERSION |

The pre-1.0 MINOR development increment groups new UI functionality with an explicitly breaking activation-ID migration. It is not a backward-compatible PATCH and not a declaration of stable 1.0. No prior canonical VERSION/checker existed; the authorized rename/versioning handoff adopts the framework policy/checker with a project-specific inventory. Current mirrors are declared in version-inventory.json, packages read VERSION, and old dependency/game versions remain independent.

## Reference classification and changes

The repository-wide case-insensitive pre-edit search is saved in RENAME_REFERENCE_BASELINE.txt (58 matching paths). Classification:

- Runtime source/mod.info, Lua global and require paths: active project identity, migrated. Global is QuartermasterSorting; no old global alias is installed.
- Source mod directory and client module directory: renamed. New shared modules use QuartermasterSorting. Project root itself is now `Quartermaster - Balanced Sorting`.
- Tests, Build.ps1, Build-Workshop.ps1, README, current architecture/audit and WORKSHOP_DESCRIPTION: active references, migrated. Root docs/WORKSHOP_DESCRIPTIONS.md points to the new project.
- New network module and sandbox namespace: QuartermasterSorting on all sides. The old patch had neither custom network traffic nor sandbox settings, so no old wire/sandbox key migration is required. Quartermaster's own module/keys are untouched.
- UI_QMSS translation keys and internal `qmss` instance field are retained internal identifiers, not the PZ Mod ID, network namespace or persistent data. All callers remain consistent; changing them for spelling would add no migration benefit.
- Historical V014_IMPLEMENTATION.md, WORKSHOP_PUBLICATION.md, prior version sections in TESTING/ROADMAP, dated audit baseline, reference baseline and archives outside dist/current: historical evidence, intentionally retained. Old archive bytes are not relabeled or included in the new artifact.
- Current changelog and Workshop change note contain the old name/ID solely as required administrator migration instructions (REQUIRED COMPATIBILITY documentation).
- No unrelated descriptive “simple sorting” usage required editing. No old identity remains in active source.

Remaining old-name matches must be confined to the historical and migration categories above. Existing external local mods and Workshop staging folders were not automatically renamed, removed or deployed in this task; those are operational copies, not the current source/package. Archived upload VDFs are historical and must not be used for a new publish without regeneration.

Post-migration classification is saved in RENAME_REMAINING_REFERENCES.json (275 matching text paths including historical staging backups). The old-ID rejection assertion in tests/run_tests.py is REQUIRED COMPATIBILITY verification, not a runtime namespace. The generated classification report and IMPLEMENTATION_DIFF.patch themselves retain old names as audit evidence. No unexplained active-source occurrence remains. IMPLEMENTATION_DIFF.patch compares runtime source against the historical 0.1.4 ZIP (SHA-256 `1cc597cfdad488f9e56150784b88c3a50186a7e7cc3d373202ea8d28b1325737`); the archive is unchanged. There is no Git baseline in this workspace.

## Persistent data and compatibility

There were no patch-owned persistent ModData keys. LSBox, LSBoxItems, LSBoxPresets and LSBoxPriority stay unchanged, as do upstream preset definitions/generations and registry keys. No destructive data migration is performed. Source inspection supports continued native field compatibility; existing-save runtime behavior is NOT TESTED, so this report does not certify automatic compatibility.

Administrators must replace `QuartermasterSimpleSorting` with `QuartermasterSorting` in `Mods=` on hosts/dedicated servers and in saved mod presets/loadouts. Keep `Quartermaster` enabled and keep WorkshopItems entry 3807217050 (and dependency 3761216758). Clients must use the same new Mod ID/version as the server. Existing saves' enabled-mod selections must be updated; Steam subscription updates alone do not rewrite those selections. Remove/disable the old local copy when deliberately deploying the new one; do not enable both globals/adapters. Any third-party dependency listing the old ID needs its owner's update.

New sandbox settings are `SandboxVars.QuartermasterSorting.ContainerRange` (10) and `.WholeBuilding` (false). No old sandbox namespace existed in 0.1.4; existing saves use defaults until configured. New shared gameplay operations require the new mod on server and client; missing support fails with no authoritative Save acknowledgment.

## Validation

[TESTED: offline] Lua syntax, renamed imports/global callers, source identity scan, 29 locale parity, original regressions, staged model/transport and actual upstream Picker host integration. `scripts/check_versions.py --root <project>` passes explicit current mirrors. Build.ps1 runs normal host tests and creates only the new-ID archive under dist/current, then checks embedded version with `--release` (version consistency only).

The exact final build/package result is recorded in the task response and current validation record. No Workshop publication, live deployment, PZ launch or server launch is part of this migration. [RUNTIME GATE] SP/new-ID recognition, hosted/dedicated matching, old-save activation migration, sandbox loading, native UI, authority/replication/persistence and patch removal are NOT TESTED. G6/G7 are not passed; G8 release remains blocked regardless of offline package consistency.

[TESTED: offline, 2026-09-28] `& '.\Quartermaster - Balanced Sorting\Build.ps1'` passed all suites, source/archive byte parity for 70 runtime files, identity checks and before/after artifact version checks. Inspected ZIP contains only QuartermasterSorting paths and canonical mod.info. Development ZIP SHA-256: `9d30a877e013fb6037a29737804176abafaa30e3fc0026da1bb346c1c77e7cdd`. An initial ZIP version-regex check failed on CRLF; the inventory's member regex was corrected, then the full build passed. No runtime evidence was relabeled as passing.
