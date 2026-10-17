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
