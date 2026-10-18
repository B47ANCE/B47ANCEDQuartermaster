# Stock and Base Ledger Workshop MP test upload

2026-10-18 — Version 0.23.0-dev.1, Mod ID B47ANCEDQuartermaster, existing Workshop item 3807217050, App ID 108600.

[VERIFIED distribution] Feature PR #28 and Framework PR #11 merged after green CI. Quartermaster release-description/dependency follow-ups #29, #30 and #31 also passed CI and merged using the repository's existing owner self-merge rule. No protection or required checks were disabled. SteamCMD exited 0 and reported `Committing update...Success`; the public Steam API matches every canonical description line after CRLF/LF normalization, with unchanged title and public visibility 0. The owner-visible page independently shows version 0.23.0-dev.1, the Stock/Base Ledger section, MP testing label and all three required items.

## Exact release

- Source/release commit: `9d82d1e7f367d67ed2c8ab579722759c07be1628`; clean HEAD matched the remote default branch before final staging and immediately before upload. Exact merged-head Ubuntu CI passed.
- ZIP SHA-256: `c27d994f07a46ce8e0a1625c170f45dd9630677d28540a20fa75393f9bff7407`; 228 exact runtime files, with CRC, duplicate/path/case safety and byte parity across final source, ZIP and uploaded stage.
- The retained ZIP was created from 31f19a5bd3d7c8c030c91cb3f1ec80c92d278d9e. Later commits changed only root Workshop prose; the exact packaged runtime still matches the final release commit. No archive was overwritten or deleted. Earlier staging stopped at the description-size guard; fresh staging was used for the successful upload. Final listing is 7,711 UTF-8 bytes with LF / 7,779 with Windows CRLF.
- Required items: Rooms 3820077442, PC Framework 3822042011 and UI 3822582242. The existing UI item was discovered by freshness checks, so no duplicate item was created. Public UI 0.3.0-dev.1 retains client API 1. Framework 0.11.0-dev.1 was separately uploaded successfully from d8b80d4c1cee6d4c7c29bdd9ca41ece97e0c722e; its package SHA-256 is d10a6abc4a21dcdf9846de75781e79ec0404e80b39c76b40003de078e017edb7.
- Approved artwork unchanged: thumbnail 26dff08533cf806b56c106e5cd72d3627dd57179d00db505e7d201fe9d9db0c1; poster 7caf79e7474cc3de3bb773ba3bf22b6ce860ed94b0df886966ba159d78fbe673; icon 4f181298819236792b26aa2ee193024ea77659ac4b8967e48d2c4fbdb1b48da5.
- Canonical listing/note remain WORKSHOP_DESCRIPTION.txt and WORKSHOP_CHANGE_NOTE.txt. Prepare-WorkshopVdf.ps1 produced submission.vdf; visibility was omitted to preserve the existing setting. No credentials are in source/packages.
- Retained ignored evidence in the stock-network-release worktree: dist/workshop-publish/0.23.0-dev.1-9d82d1e7f367/B47ANCEDQuartermaster/release-manifest.json, upload-result.json, metadata-before.json, metadata-after.json, submission.vdf and workshop-confirmation.png. Earlier partial staging and original ZIP/sidecar are preserved.

## Checks and boundaries

[TESTED OFFLINE — Windows, Python/Lupa Lua 5.1] Full paired suite with Rooms 0.2.0-dev.7, Framework 0.11.0-dev.1 and UI 0.3.0-dev.1 passed. Commands from this release checkout:

```text
python -B tests/run_tests.py --require-rooms --rooms <Rooms checkout> --ui ../B47ANCEDUI --pc-framework ../B47ANCEDPCFramework
python -B scripts/check_native_categories.py --game <installed 42.21 game> --output <temporary native category report>
python -B tests/run_tests.py --package --require-rooms --rooms <Rooms checkout> --pc-framework ../B47ANCEDPCFramework --ui ../B47ANCEDUI
python -B scripts/check_deployment.py --package
python -B tests/test_deployment.py
python -B scripts/check_versions.py --release
python -B scripts/check_deployment.py --package --stage dist/workshop-publish/0.23.0-dev.1-9d82d1e7f367/B47ANCEDQuartermaster
```

Build.ps1 completed its native-category, full-suite, packaging, disposable deployment, dependency and version checks. Build-Workshop.ps1 initially refused the long root description; it did not authorize an upload. The corrected listing was staged freshly from the retained verified ZIP and passed Prepare-WorkshopVdf.ps1, source/ZIP/stage parity and version gates. Explicit host-contract CI remains separate from the locally installed native-source fixtures, as documented in STOCK_AND_BASE_LEDGER.md. None executes PZ.

The user explicitly approved restarting Steam after both successful uploads. The verified running executable was asked to shut down gracefully, exited within the bounded wait and the same executable started again; its running process was confirmed. No process was killed forcibly. A restart is not proof that subscriptions downloaded or the game loaded them.

MP testing build - dedicated multiplayer NOT TESTED. [RUNTIME GATE] Native SP, actual download/dependency loading, PC pairing across unloaded areas, two-client stock/privacy concurrency, permission/power/CD loss, reconnect, persistence and dedicated restart NOT TESTED. G7 and stable-release G8 BLOCKED. Existing prior-build acceptance is not reused. No local deployment, game/server launch or remote server modification.
