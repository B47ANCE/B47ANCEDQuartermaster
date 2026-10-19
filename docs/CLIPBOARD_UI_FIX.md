# Clipboard UI correction and PC integration

Project Version: 0.24.0-dev.2

## Historical metal clamp correction — 0.19.0-dev.3

[VERIFIED SOURCE] Compatible presentation-only PATCH checkpoint. The previous clip ended at y=47 while paper began at y=52, leaving a visible gap. The original Lua geometry now draws wider beveled steel shoulders, two rivets, a raised spring tab and a rolled jaw through y=62. Its shadow ends at y=64, clear of the title at y=66. All supported font-size minimums contain the clamp. No new engine API, raster asset, gameplay setting or networking is introduced; ledger contents, controls, privacy, native transfers and PC Framework remain unchanged.

[TESTED OFFLINE] Actual-source paper preview visually reviewed. Existing focused ledger/UI fixtures pass at font heights 14/24/32/42, including reader/table/footer bounds, pagination and computer task lifecycle. Version consistency and production-manifest/deployment-parity checks pass. No new implementation-mirroring geometry test was added for this reversible art-only change. The full paired regression suite below belongs to dev.2; it was not rerun for the clamp-only delta.

Exact current commands: `python -B scripts/render_computer_preview.py --pc-framework <paired-PC-Framework-checkout> --output <external-preview-directory>`; focused `tests/test_ledger_ui.lua` through the existing Lua 5.1 fixture harness; `python -B scripts/check_versions.py`; `python -B scripts/check_deployment.py`; `git diff --cached --check`. The preview uses synthetic data and approximate host fonts/widgets, not PZ pixels. Current source: 225 runtime files, SHA-256 `b01e620533ab027152012dda62cfa2d48ccfca64c1dd59fe8ee99df9056e0b66` with the algorithm recorded below. The paired framework remains 0.3.0-dev.1 at 12d320c86a3e22f6db32dc69051167fef589d097.

[RUNTIME GATE] Native clip/large-font acceptance NOT TESTED. Prior G6/G7/stable G8 limits remain; no game/server launch, packaging, deployment or publication.

## Historical dev.2 reconciliation evidence

The remaining report describes the earlier 0.19.0-dev.2 checkpoint. Its source hashes and full-suite results remain historical and are not relabelled as dev.3 evidence.

## Scope and compatibility

The user approved isolated reconciliation with upstream and preservation of the newer CRT/taskbar in PC Framework. Quartermaster branch `fix/clipboard-ui` reconciles owned presentation/clipboard commit `9c8207a7f63a4fbc1abf1307e7ca8f7c2efe08ce` with upstream `17c16901037efe3958879a2566b49f3eaa571cda`. The original branches/checkouts remain untouched. No shared-main merge, package, deployment, game/server launch or Workshop upload is part of this pass.

This is a compatible UI correction within the upstream 0.19 development line. Upstream's required PC Framework dependency is retained; use paired framework **0.3.0-dev.1**, branch `feature/crt-taskbar-integration`, based on main `1d7c5242d4ee34fa21fad7c6679f791b9a6aa363`. That framework increment is a compatible MINOR presentation addition; app registration API and drive schema remain 1. PC Framework has no assigned Workshop item. Its independent source does not import Quartermaster.

## Root cause and fix

[VERIFIED SOURCE / TESTED OFFLINE] The paper reader still inherited a 960x680 landscape desktop default. Its board drew fixed ruled lines behind the header, details and controls; table ruling did not follow the native row scroll phase. Selected details omitted the item name, and hiding the normal window frame also removed visible resize art. A new portrait assertion failed before the fix (`paper clipboard opens as a wide desktop window`) and passes afterward.

Paper now opens with portrait proportions on supported normal-size screens, retaining responsive minimums and user resizing. Background rules exist only in the table and follow row scroll. Three distinct detail lines show selected item/quantity, location and record metadata. Footer controls remain outside the list; a visible grip marks the existing native resize area. Font-scaled minimums preserve one complete row and separate details/footer at 14/24/32/42 font heights. Large-font or short-view layouts may necessarily be wider than portrait.

Changed clipboard production files: `ClipboardArt.lua`, `LedgerTable.lua`, `LedgerUI.lua`. The paired preview executes these actual files with synthetic authorized records. Its host fonts and native-widget paint are approximations, not PZ pixels.

## Framework boundary

[VERIFIED SOURCE] Quartermaster ComputerUI is a compatibility alias, with ledger registration in LedgerUI and app-specific writing in ComputerWriter. Its old ComputerArt module is removed from current source/manifest because the owned art now lives in the framework, with Git history preserved. Framework ComputerUI/ComputerArt supply the bulky CRT, icons, drive/tool/app tasks, minimize/restore, MRU switching, Show Desktop, close/focus/tooltip cleanup and media invalidation. Optional tool hooks and registration API 1 remain supported. Immediate Run checks preserve application access validation in addition to regular screen checks. A regression revokes access between render and Run. A closed-writer guard prevents stale callbacks from submitting burn intent; its regression passes after ejecting the media.

Quartermaster keeps domain data, privacy, snapshots, native media identity, conversion and authenticated server commands. The extraction adapter retains existing stored bindings. Dev.7 exact-building live/freshness policy and dev.8 retained-clipboard recipe remain. No new server command, protocol/schema change, inventory mutation, native capacity change or transfer-group/timing change is introduced by the clipboard/CRT correction. New geometry/art are local presentation constants; no meaningful shared gameplay configuration was added.

## Validation

[TESTED OFFLINE, Windows/Python 3.12/Lupa Lua 5.1] Full Quartermaster suite passes with actual Rooms **0.2.0-dev.6** and paired PC Framework source. After restoring the immediate application guard, standalone framework tests and the focused actual ledger/UI suite pass again. Coverage includes ledger permissions/freshness/persistence, native-shaped conservation fixtures, existing sorting/shopping regressions, reusable clipboard recipe, paired media/writer lifecycle, taskbar retention and late replies, plus portrait defaults, scroll ruling, details/footer bounds, paging, mouse/keyboard/controller doubles and four font sizes. Offline mocks do not prove in-game behavior or performance.

Version/source-manifest/deployment-parity tests pass. The parity test uses disposable temporary directories, not the installed mod. Lua-only, case-correct owned requires, filename collision and 29-locale English fallback checks pass; fallback parity is not translation quality or native glyph acceptance. Installed native PC tile definitions are verified read-only for all four orientations (42.21.0 / Steam build 25485521); no new native API was assumed.

Commands executed from Quartermaster:

```powershell
python -B tests/run_tests.py --require-rooms --rooms <actual-Rooms-checkout> --pc-framework <paired-PC-Framework-checkout>
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
python -B tests/test_deployment.py
python -B scripts/render_computer_preview.py --pc-framework <paired-PC-Framework-checkout> --output <external-preview-directory>
git -c core.safecrlf=false diff --cached --check
```

Commands executed from PC Framework:

```powershell
python -B tests/run_tests.py
python -B scripts/check_versions.py
python -B tests/check_native_computers.py --game <installed-42.21-game-root>
git -c core.safecrlf=false diff --cached --check
```

Host Python: Codex primary runtime Python 3.12; Lupa from the existing Quartermaster `.test-deps`. Explicit worktree paths supply dependencies rather than guessed siblings. The source-rendered paper and digital previews were visually inspected; no texture generation or third-party assets are involved.

## Source identity and remaining gates

Current Quartermaster source: **225 runtime files**, SHA-256 `21d834714b82c839cb4a49a435b3b84d7a0a3b4d0760c5442c23526e5c79a196`.
Paired PC Framework source: **80 runtime files**, SHA-256 `4d8506d1372e2ae8aebbfa4468f7720ba4866c3fce47416329e81335065fa819`.
Algorithm: sorted source-relative UTF-8 path, NUL, binary SHA-256 of each file, folded through SHA-256. These are source receipts, not package or native-runtime evidence. No package was produced. Previous reports/hashes retain their original version/environment.

[RUNTIME GATE] G6 native clipboard/computer visual/input acceptance NOT TESTED; G7 dedicated multiplayer NOT TESTED / BLOCKED; stable G8 BLOCKED. Required checks: actual page scroll/ruling/selection, resize and font settings, keyboard/controller/taskbar behavior, local/off-site CD reads, power/media/permission loss, delayed replies, two-client drive/writer interactions, existing-save reload and reconnect/restart. Native transfer authority limits are unchanged. Distribution of the separate framework must be arranged before any Workshop test upload.
