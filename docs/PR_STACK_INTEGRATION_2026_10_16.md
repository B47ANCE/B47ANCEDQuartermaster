# Quartermaster PR stack integration — 2026-10-16

This is a version-bound integration ledger. Each entry describes the exact source tested; it is not native or dedicated multiplayer acceptance. No package, local deployment, Workshop upload, game/server launch or branch-protection change is authorized by this integration work.

The owner requested testing and merging the development stack. The default branch is `fix/native-transfer-diagnostics`. PRs are moved to that branch in dependency order so merges actually advance the default. Merge commits preserve source ancestry; no rebase/force-push/branch deletion is used. Existing developer-review and owner-self-merge rules remain intact; no required CI is bypassed.

## PR #1 — audit remediation/native item lookup

- Observed version: `0.4.0-dev.48`.
- Original feature head: `6bb064536205ee26aa0d3fad5ad543fcffe45199`.
- Reconciled the remote default's documentation-only commit `0c343ed`. README resolution retains the feature's version-accurate documentation; default documentation and its original README archive remain in Git history/the dated archive. Current mirror definitions match the resolved README. No production/test files changed during conflict resolution.
- Runtime files: 127. Source SHA-256 (sorted relative name + NUL + binary file SHA-256): `0cfe2292c0fa1caa6156148ba8e39c3ec57b4d1e1d9656988d9720061a139e2d`.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py`, `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, `git -c core.safecrlf=false diff --cached --check`; source case/require/Lua-only and public secret/private-diagnostic checks.
- Review: native item IDs replace transient wrapper keys; native validation, server-owned grants, permission/capacity/containment and in-flight observation remain. No direct client inventory mutation was introduced. UI range/hidden-target/preference fixes have production-path regressions. No third-party implementation/assets are added in this PR.
- [RUNTIME GATE] Native SP/listen/dedicated behavior remains NOT TESTED for this exact version. G7/stable G8 remain BLOCKED. Git development integration does not certify a release.

## PR #2 — public script-metadata fallback audit

- Observed version: `0.4.0-dev.49`; original feature head `d9f6c8d73af1f97d093a1a6c1135ec2be548d085`.
- Merged the updated default branch cleanly for evaluation; production/test sources are unchanged by that merge.
- Runtime files: 127. Source SHA-256 using the convention above: `1fce9f8f870e0ecd121f0f3ad94b4a6d81733bde43b29431b9ec0bbb0cd23b7a`.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py` passed, including synthetic Workshop inventory/provenance fixtures and native-transfer fixtures. Version/source-manifest/whitespace checks passed. Downloaded third-party Lua was not executed and no new corpus scan or raw item export was performed.
- Source review: five normalized public display-category hints apply only as Normal/Drainable fallback metadata after stronger native/tag/tool evidence. No imported mod implementation, item lists, assets, RPC, permissions or movement changes.
- Clean-room source review completed by Codex under the owner's explicit development-merge authorization and existing owner self-merge policy. The initially proposed independent-agent review was not performed and is not claimed. Generic metadata hints, provenance and no-import boundaries were reviewed; no unresolved copying/redistribution issue was found. This is not legal clearance or independent human review.
- [RUNTIME GATE] Native/dedicated NOT TESTED; G7/stable G8 BLOCKED. Original dated corpus figures remain historical and were not relabeled as a new installed-mod census.

## Supplemental independent clean-room review — 2026-10-16

The owner subsequently authorized a read-only review agent. That agent inspected PR #2 (`d9f6c8d73af1f97d093a1a6c1135ec2be548d085`), #4 (`f8b51b6c07a1d14244e22707ef7eee0c65bf157e`), #11 (`f1be19acaba4e4704f34696a76136425fad1a365`) and #12 (`2bc847af921cbe5baf06583928898e0164250b5f`) and returned clean-room engineering signoff: no material blocker found within those source/provenance ranges. No third-party code/assets were imported; native metadata and independently implemented adapters are used. Better Sorting/Better Containers reuse rights remain UNKNOWN; Extended Categories restrictive licensing remains recorded, without assumed reuse permission. This supplements the earlier owner-authorized review; it is not human/legal clearance, external-mod runtime proof or dedicated MP acceptance. The agent also confirmed that PR #9 needs substantive protocol/schema porting and must not be merged by merely resolving conflict markers.

## PR #3 — dev.50: queue authorized native batch before first transfer

- Observed version: `0.4.0-dev.50`; original tested feature head `7cf261de765fa98223b4cd30dda8bc2671a983e3`. Reconciled default predecessor `45da68e40ef5a8ca370d26419f799a4de644101b` using a non-rewriting merge.
- Runtime files: 127. Source SHA-256: `c6faa88c82bb57c849f5721544342a93ae6e162c57d03b73386c34b3e39ae1f9`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Native queue assembly retains vanilla transfer timing/group splitting, stable item IDs, guarded donors and cancellation; no direct inventory mutation or capacity bypass.
- Codex source review completed under the owner’s explicit merge request. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #4 — Use native categories and optional inventory mods in 0.5.0-dev.1

- Observed version: `0.5.0-dev.1`; original tested feature head `f8b51b6c07a1d14244e22707ef7eee0c65bf157e`. Reconciled default predecessor `6243569fe2faab79273e76ba6f93a507b654ea31` using a non-rewriting merge.
- Runtime files: 128. Source SHA-256: `b7faccdb1d71b55db53c093446acba7f4da5adb15001623a9012754d20a80fea`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Native display-category metadata replaces the owned classifier; exact optional mod detection and explicit item membership preserve server-held item/configuration checks. No external implementation or assets imported.
- Independent read-only clean-room agent signoff is recorded above for this exact runtime head. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #5 — Retire obsolete sorting data and taxonomy in 0.6.0-dev.1

- Observed version: `0.6.0-dev.1`; original tested feature head `2c3d5a8370e0c02135eb22f4d0408294e862290f`. Reconciled default predecessor `3db3faa69cc29c2a126665f8171e963f00a62c36` using a non-rewriting merge.
- Runtime files: 126. Source SHA-256: `b88d8d1a539e3fd2fb0e4010c6c235be79ee8b27e596f77f06f4ec588716dad0`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Retired formats are validated and staged before authoritative writes; native rules, explicit items, priorities and valid owned presets are retained. Migration is bounded/idempotent and rejects corrupt/future data.
- Codex source review completed under the owner’s explicit merge request. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #6 — Fix category lookup and reduce transfer queue overhead in 0.6.0-dev.3

- Observed version: `0.6.0-dev.3`; original tested feature head `674ad3809701c772d7e6ee2bb4670d8b4a4aae58`. Reconciled default predecessor `ab8762f9045b84c107a6bacac8c4313e6cb24115` using a non-rewriting merge.
- Runtime files: 126. Source SHA-256: `32a901e83d349e5634bcd5c3ae2631f3b24bf1ee2ee127717c316fa1ef56cc80`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Native category lookup and bounded queue/planning work preserve server grants, native transfer groups, carry capacity and cancellation.
- Codex source review completed under the owner’s explicit merge request. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #7 — Add server-owned custom rooms and room sorting (0.7.0-dev.1)

- Observed version: `0.7.0-dev.1`; original tested feature head `de6101c45f6d09f6c926cb8afe09105c4c0dec30`. Reconciled default predecessor `7fe8a56ce0dc9309b3c8faa7c08844ca43345699` using a non-rewriting merge.
- Runtime files: 133. Source SHA-256: `cc29182b46d0c08de06487bcc5ee19a1e2eb94e2d88ba0ed495f8cfba9c26e6c`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Custom room registry, revisions and safehouse/creator permissions remain server-owned; scope selection does not grant container access.
- Codex source review completed under the owner’s explicit merge request. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #8 — Require Rooms and expose guarded supply API (0.11.0-dev.1)

- Observed version: `0.11.0-dev.1`; original tested feature head `154a0a1e73ac0dd0f741770cd33e9d13a7c331d8`. Reconciled default predecessor `dbb673f8543cfebc96c29721596301e2313e1beb` using a non-rewriting merge.
- Runtime files: 131. Source SHA-256: `0df078b2d51c3ee529d6e787758b70b68317636095135f6df01b64362fd18460`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py --require-rooms --rooms <verified B47ANCEDRooms repository>` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Standalone Rooms extraction uses guarded versioned APIs and fails closed for unavailable protected-room permission services. This PR does not merge or modify Rooms itself.
- Codex source review completed under the owner’s explicit merge request. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #11 — 0.12.0-dev.1: full carries, overall progress and native vehicle sources

- Observed version: `0.12.0-dev.1`; original tested feature head `f1be19acaba4e4704f34696a76136425fad1a365`. Reconciled default predecessor `674c8e8b2721ad65cb769209b652c1376ea0571a` using a non-rewriting merge.
- Runtime files: 134. Source SHA-256: `3446d8ee8b83db1fdc40eb1635feece1ddb059428d50c494e82435f491729512`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py --require-rooms --rooms <verified B47ANCEDRooms repository>` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Closed carries fill before walking and unload before another carry; vanilla small transfer groups remain. Local progress is presentation only. Generic vehicle/trailer/bag handles use native physical identities/access checks; no vehicle sweep or bulk-fluid path.
- Independent read-only clean-room agent signoff is recorded above for this exact runtime head. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #12 — Add Dangerous Load and Extended Categories support (0.13.0-dev.1)

- Observed version: `0.13.0-dev.1`; original tested feature head `2bc847af921cbe5baf06583928898e0164250b5f`. Reconciled default predecessor `fd75e29d8b463812c09572bff820d043f7cf1cbe` using a non-rewriting merge.
- Runtime files: 137. Source SHA-256: `98d9f6bf0240b6cf829b934126134926825254b2d6ae29c61a4f222b7a59a40a`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py --require-rooms --rooms <verified B47ANCEDRooms repository>` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Dangerous Load defaults off and uses server policy/native root capacity without changing capacity or vanilla penalties. Extended Categories consumes native metadata via exact optional Mod ID. Unwired historical ledger analysis is not claimed as completed functionality; shelf work remains excluded.
- Independent read-only clean-room agent signoff is recorded above for this exact runtime head. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #13 — Complete physical Supply Ledger inspections and CD workflow (0.14.0-dev.1)

- Observed version: `0.14.0-dev.1`; original tested feature head `0d95b2872b7d8f83c9a775925788e02365a737ca`. Reconciled default predecessor `0e12bc4034e3b6f82252d2d2cefbbc438c9d3b5b` using a non-rewriting merge.
- Runtime files: 203. Source SHA-256: `4cb17899200c25c6033a089f89e54b1565148521645499d8671bff8701e6846c`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py --require-rooms --rooms <verified B47ANCEDRooms repository>` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Server-bound physical ledgers use one-use native action challenges, bounded immutable snapshots, current access/privacy checks and conservative conversion journals. Uncertain conversion outcomes do not respawn inputs.
- Codex source review completed under the owner’s explicit merge request. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #14 — Run Ledger CDs inside a Windows '93 computer desktop

- Observed version: `0.14.0-dev.2`; original tested feature head `4a9be2bf7ae664e49880158d996268ee56c61097`. Reconciled default predecessor `3bffd68e567aff3d95efcf4457138b358a2b842e` using a non-rewriting merge.
- Runtime files: 204. Source SHA-256: `f633689aba7db163f9eb07064aabd9ee07016b8c4778e5afa7bb86c50326342b`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py --require-rooms --rooms <verified B47ANCEDRooms repository>` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Windows '93 is a local desktop presentation requiring explicit CD load/run; it adds no arbitrary execution, copied OS assets or new shared-state authority.
- Codex source review completed under the owner’s explicit merge request. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #15 — Require matching ledger knowledge for Sort and Shopping collection

- Observed version: `0.15.0-dev.1`; original tested feature head `91426ac2ea49930476a9bee73d67975fb4739ec0`. Reconciled default predecessor `11f0d0ef7a44cb25d0f4af047f9247bc6816b882` using a non-rewriting merge.
- Runtime files: 206. Source SHA-256: `76d4c9d3c74c0175aa60615cef4222e0b6216237ea773ff8823a5daffcb74348`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py --require-rooms --rooms <verified B47ANCEDRooms repository>` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Location knowledge requires server-verified carried ledger or actual CD membership in accessible adjacent computer storage. Configuration/grant validation is server-owned; completed native observations, cancellation and safe returns remain possible.
- Codex source review completed under the owner’s explicit merge request. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #16 — Add physical shopping lists and keep container setup open after Save

- Observed version: `0.16.0-dev.2`; original tested feature head `2cac3ae5497bdbf793e119d12f3ef61ceb457457`. Reconciled default predecessor `61715f313083320ff03671766a94c9c29f66d183` using a non-rewriting merge.
- Runtime files: 209. Source SHA-256: `6f24f3bf0c1b352896802bea7c36949520e4932b9a910d30100f012ce6d9a1fb`. Production, tests and validation scripts remain byte/blob-equivalent to the original tested head; reconciliation changes only documentation/evidence.
- [TESTED OFFLINE] Full `python -B tests/run_tests.py --require-rooms --rooms <verified B47ANCEDRooms repository>` passed on the exact original head; this evidence applies unchanged to the identical runtime/test/tool tree. Re-ran `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --cached --check` after reconciliation. Public secret/private-diagnostic, runtime Lua-only and case-uniqueness checks passed. No package was created; absent development artifacts are deferred, not a packaging PASS.
- Source review: Physical shopping lists use server-held exact item identity, native-action completion proof, one-sheet consumption and retained notebook/tool checks. Trading revokes prior-holder edit rights; HUD reads are bounded and local.
- Codex source review completed under the owner’s explicit merge request. No required CI checks are configured/reported for this candidate; owner self-merge uses the existing authorized rule without changing protections.
- [RUNTIME GATE] Native SP/optional-mod execution/dedicated acceptance for this exact head remain NOT TESTED. G7/stable G8 BLOCKED; development merge does not certify a stable release.

## PR #17 — ledger freshness and scoped requirements

- Observed version: `0.17.0-dev.1`; original feature head `fc0b79aa3be0c48a76c57add4b5b946fc4180212`. Reconciled default predecessor `554d7844aa373dbb237319f8234c4b2954fbd95b` with a non-rewriting merge.
- Corrected only the stale `mod.info` description: manual Sort needs no ledger, scoped Sort/collection honor freshness modes, computer updating policy is configurable, and protocol versions match production. Added an explanatory current changelog bullet. No Lua/test/script source changed from the original head. This is a compatible metadata correction within the existing unpublished development candidate, not a new gameplay/version iteration.
- Final runtime files: 211. Final source SHA-256: `ce9f402817f1399e790889c11287f57fe16d9c801642fe6f648f51bc1aa25ccb`. Original tested-head hash remains recorded in the table below; the hash difference is only the corrected description.
- [TESTED OFFLINE] Re-ran the **full final suite** after correction: `python -B tests/run_tests.py --require-rooms --rooms "$ROOMS_REPOSITORY"`, `python -B scripts/check_versions.py`, `python -B scripts/check_deployment.py`, and `git -c core.safecrlf=false diff --check`; staged whitespace/public-push/Lua-only/case checks also pass. `ROOMS_REPOSITORY` was the verified local standalone checkout, version `0.2.0-dev.5`, commit `8ba8586b7cfa8ef263a2f162f1231577570a9e78`, runtime hash `74036b03c7f2c3a6e69e61f8729a9a021e5e3be51efcdcd4e3fc4f52c84e1419` using the same convention. Its commit/runtime bytes remained unchanged throughout the run. This is paired offline evidence, not a Rooms PR merge or deployment.
- Source review: Server world-age policy scopes freshness to Room/Building Sort and Shopping collection, leaves manual Sort available, and keeps completed observations/safe returns unblocked. Disabled mode preserves authenticated shopping-paper completion. Computer refresh and recorded-storage live views remain bounded/server-authorized.
- No required CI configured/reported; existing owner self-merge rule retained. No package/deployment/Workshop upload.
- [RUNTIME GATE] Native SP and dedicated NOT TESTED for this exact candidate; G7/stable G8 BLOCKED.

## Original-head offline test inventory

All rows below ran version/source-manifest/whitespace/full offline regression commands at the exact listed heads. These are original-head results, not claims about untested conflict resolution. Main-stack reconciliation preserved each corresponding runtime/test/tool tree except the explicitly documented PR #17 metadata correction, whose final suite was rerun. No packaging or native/dedicated execution is claimed.

| PR | Version | Original head | Runtime files | Runtime SHA-256 | Offline |
| --- | --- | --- | ---: | --- | --- |
| #3 | 0.4.0-dev.50 | `7cf261de765fa98223b4cd30dda8bc2671a983e3` | 127 | `c6faa88c82bb57c849f5721544342a93ae6e162c57d03b73386c34b3e39ae1f9` | PASS |
| #4 | 0.5.0-dev.1 | `f8b51b6c07a1d14244e22707ef7eee0c65bf157e` | 128 | `b7faccdb1d71b55db53c093446acba7f4da5adb15001623a9012754d20a80fea` | PASS |
| #5 | 0.6.0-dev.1 | `2c3d5a8370e0c02135eb22f4d0408294e862290f` | 126 | `b88d8d1a539e3fd2fb0e4010c6c235be79ee8b27e596f77f06f4ec588716dad0` | PASS |
| #6 | 0.6.0-dev.3 | `674ad3809701c772d7e6ee2bb4670d8b4a4aae58` | 126 | `32a901e83d349e5634bcd5c3ae2631f3b24bf1ee2ee127717c316fa1ef56cc80` | PASS |
| #7 | 0.7.0-dev.1 | `de6101c45f6d09f6c926cb8afe09105c4c0dec30` | 133 | `cc29182b46d0c08de06487bcc5ee19a1e2eb94e2d88ba0ed495f8cfba9c26e6c` | PASS |
| #8 | 0.11.0-dev.1 | `154a0a1e73ac0dd0f741770cd33e9d13a7c331d8` | 131 | `0df078b2d51c3ee529d6e787758b70b68317636095135f6df01b64362fd18460` | PASS |
| #11 | 0.12.0-dev.1 | `f1be19acaba4e4704f34696a76136425fad1a365` | 134 | `3446d8ee8b83db1fdc40eb1635feece1ddb059428d50c494e82435f491729512` | PASS |
| #12 | 0.13.0-dev.1 | `2bc847af921cbe5baf06583928898e0164250b5f` | 137 | `98d9f6bf0240b6cf829b934126134926825254b2d6ae29c61a4f222b7a59a40a` | PASS |
| #13 | 0.14.0-dev.1 | `0d95b2872b7d8f83c9a775925788e02365a737ca` | 203 | `4cb17899200c25c6033a089f89e54b1565148521645499d8671bff8701e6846c` | PASS |
| #14 | 0.14.0-dev.2 | `4a9be2bf7ae664e49880158d996268ee56c61097` | 204 | `f633689aba7db163f9eb07064aabd9ee07016b8c4778e5afa7bb86c50326342b` | PASS |
| #15 | 0.15.0-dev.1 | `91426ac2ea49930476a9bee73d67975fb4739ec0` | 206 | `76d4c9d3c74c0175aa60615cef4222e0b6216237ea773ff8823a5daffcb74348` | PASS |
| #16 | 0.16.0-dev.2 | `2cac3ae5497bdbf793e119d12f3ef61ceb457457` | 209 | `6f24f3bf0c1b352896802bea7c36949520e4932b9a910d30100f012ce6d9a1fb` | PASS |
| #17 | 0.17.0-dev.1 | `fc0b79aa3be0c48a76c57add4b5b946fc4180212` | 211 | `8eef5ec3e192ae085026124aecbc6ab9f617ad90e6ad39c9ada0c49d0d644d67` | PASS |
| #9 | 0.9.0-dev.1 | `910cb2b98359413f17f07bbaa85f520c4f2a59e1` | 152 | `ddf4e99e9061a07e70f4218cc3a620966466c97937843732f93f5a77a3a2041f` | PASS |

## PR #9 — reviewed, original head tested, merge deferred

PR #9 remains a draft requiring a dedicated port. Independent read-only review agreed. The allocation candidate at `910cb2b98359413f17f07bbaa85f520c4f2a59e1` diverged at `caa75c75a58cc491d468d827e58e1d0a5e36b043`; its original offline suite passed, but that does not validate integration with the newer main stack.

- Old movement/personal/shopping/rooms protocols are `8/1/1/2`; the newer stack uses `11/2/3/3` plus ledger/load-policy families. Configuration/preset schemas also differ (`6/3` versus `5/2`).
- Substantive conflicts include Authority, Movement, Identity, Protocol, version/current documentation and Sandbox/UI translations. An old version or protocol must not replace the newer source.
- Port sparse profile/schema migrations, container/Whole/preset persistence, permission-checked room APIs, shadow evaluator hooks, UI and native-capacity/reservation fixtures together onto the new baseline. Retain ledger/physical-paper/computer workflows, carry/native small grouping, source identity and completed-result handling.
- Preserve `AllocationRuntime.enforcing()==false` and the live-routing activation gate. Paired Rooms metadata capabilities and two-client native acceptance must be revalidated. No Rooms PR is merged by this Quartermaster-only task.
- [RUNTIME GATE] Combined allocation port is NOT IMPLEMENTED / NOT TESTED; native and dedicated acceptance remain blocked. This is a documented unsafe-merge boundary, not a claim that original-head tests failed.
