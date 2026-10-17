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
