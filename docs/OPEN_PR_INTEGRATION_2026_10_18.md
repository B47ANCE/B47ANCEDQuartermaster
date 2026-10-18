# Open PR integration — 2026-10-18

Project Version: 0.21.0-dev.5

PATCH checkpoint within the pending 0.21 release. User authorized all open Quartermaster PR merges, the approved mod icon, unchanged thumbnail and publication after checks.

Integrated heads: #19 9c8207a7, #21 09b852a3, #22 7692a3ac, #23 a2ecffbd and #25 a9db0388. Start from the publication branch, then merge the complete sort-ledger stack. Preserve original worktrees and all prior artifacts.

Conflicts resolve to the mature clipboard/LedgerTable and challenged server ledger/install workflows while retaining the unified desktop writer-host ownership and public dependency metadata. Translation dictionaries retain both branches' keys. No third-party code or assets are imported. Native transfer timing/grouping, server permissions and shared state ownership remain unchanged.

Approved art replaces only 42/icon.png. Thumbnail and poster exact hashes are checked in assets/branding/icon-transparent-20261018.json. Original PNG master is retained as the runtime icon without resizing.

[TESTED OFFLINE] Full tests/run_tests.py with --require-rooms and actual Rooms 0.2.0-dev.7 plus public PC Framework 0.9.0-dev.3 passes. Targeted --only-sort-ledger passes. Updated desktop fixtures use the public framework, preserving table geometry/selection/privacy tests and independent background-writer completion. Old retired ComputerArt/taskbar internals are no longer a consumer contract.

Release checks: Build-Workshop.ps1 with explicit dependency paths, scripts/check_versions.py --release, scripts/check_deployment.py --package --stage and tests/test_deployment.py. [TESTED OFFLINE] Build.ps1, 229-file package/source/stage parity, disposable deployment checks and --release versions all PASS. Workshop staging initially rejected the description length; after shortening prose the unchanged script staging/parity phase PASS. Packaging/source/stage integrity passes before upload; the ignored release manifest binds the final release commit and artifact hashes.

[RUNTIME GATE] Native client visual/gameplay acceptance and dedicated MP are NOT TESTED for this combined checkpoint. G7 and stable G8 remain BLOCKED. The explicit publish request authorizes an MP testing upload only. No live deployment, server launch/change, Framework publication or Steam desktop restart is implicit.
