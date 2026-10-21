# Shared UI extraction

Project Version: 0.24.0-dev.3

## Current public-API integration audit (2026-10-21)

[VERIFIED source] UI 0.5.0-dev.11 (`33ef6e3` on `origin/main`) retains public client API major 1. Quartermaster continues to import only `B47ANCEDUI/API` via `UIProvider`, and now routes its own layout, container-scope, active-room-sort and Sort context menus, including created submenus, through the scoped `menu` adapter. Existing gameplay callbacks, permission checks, server requests and saved state are unchanged. The adapter is instance-scoped; it does not restyle unrelated native/other-mod menus.

[TESTED offline] UI provider version and full offline suite pass. Quartermaster's paired UI fixtures, public-provider boundary and full offline regression suite pass against UI 0.5.0-dev.11. This is API/source evidence only; native PZ visual, controller and dedicated MP validation remain [RUNTIME GATE]. Historical UI 0.3.0-dev.1 pairing below remains tied to its original candidate, not this source iteration. No local deployment or Workshop publication was performed.

Current distribution follow-up: UI API 1 is available as Workshop item 3822582242. Quartermaster 0.23.0-dev.1 is retested with UI 0.3.0-dev.1 / PC Framework 0.11.0-dev.1 for the authorized MP testing candidate. The original source-only extraction checkpoint below retains its historical scope; it is not native acceptance.
2026-10-18: current baseline Quartermaster 0.21.0-dev.5 commit `2c1d663dadd68ec1757845ff90e14b6225908904`. Fresh clean feature worktree; old root checkout remains untouched. Source-only 0.x MINOR adds the required B47ANCEDUI dependency and public API 1; install the new dependency on both peers. No UI Workshop item is assigned, so this source iteration is not yet distributable through Workshop. Existing item IDs/visibility untouched.

Shared Theme/Appearance/Renderer/Controls/Dialog/Tooltip/RowTooltip, appearance editor and original clipboard drawing now live in [B47ANCEDUI](https://github.com/B47ANCE/B47ANCEDUI). Quartermaster's UIProvider requires `B47ANCEDUI/API`, asserts API 1, registers its scoped facade and legacy preference prefix. No duplicate library or fallback source is packaged. AppearanceUI/ClipboardArt are thin public-API adapters; all application consumers import UIProvider. Sorting/Shopping/Dibs/application screens keep their business rows, callbacks and server reply/action ownership. WindowLayout retains Quartermaster-specific rail/minimum/layout policy and window filename; PC Framework remains separate.

Old appearance `B47ANCEDQuartermasterAppearance<player>.txt` imports read-only into the scoped UI API if no valid scoped value exists. Explicit saves write cache/Lua/B47ANCEDUI/appearance/B47ANCEDQuartermaster.<player>.txt. Old files preserved; downgrade does not inherit newer scoped changes automatically. Per-app and local-player settings are isolated. No gameplay/world save schema, capability protocol, sandbox setting or server module changes. No new custom networking or authority. Styling cannot grant gameplay permission.

Baseline offline full suite and version consistency passed with actual Rooms and PC Framework 0.9.0-dev.3 (commit `c77cac2add9702e846d2c16adef9e88064ada136`). Current evidence JSON tied to old Sort/Application work remains historical, not relabeled. [TESTED — offline Windows, 2026-10-18, bundled Python/Lupa 2.6 Lua 5.1] PASS: standalone UI suite, focused paired UI/provider suite and full Quartermaster suite, including unchanged authority/transfer fixtures, physical Shopping controls, layout/font scaling, native-slider-shaped appearance, tooltips, clipboard and digital ledger. PASS: version consistency, 223-file exact source inventory, dependency/API/no-bundled-provider boundary and installed vanilla Lua UI contract audit. No package generated. Host/vanilla-source execution is offline, not runtime proof.

Exact commands from this Quartermaster checkout (Python executable may be the bundled host runtime):

```powershell
python -B scripts/check_versions.py
python -B tests/run_tests.py --only-ui --ui '<repositories>/B47ANCEDUI' --rooms '<repositories>/B47ANCEDRooms' --require-rooms --pc-framework '<worktrees>/pc-workshop-publication/B47ANCEDPCFramework'
python -B tests/run_tests.py --ui '<repositories>/B47ANCEDUI' --rooms '<repositories>/B47ANCEDRooms' --require-rooms --pc-framework '<worktrees>/pc-workshop-publication/B47ANCEDPCFramework'
python -B scripts/check_deployment.py
python -B tests/test_ui_boundary.py --ui '<repositories>/B47ANCEDUI'
python -B tests/audit_ui_native.py --ui '<repositories>/B47ANCEDUI'
```

UI commands from its checkout: `python -B scripts/check_versions.py`; `python -B tests/run_tests.py`. Test runner fails explicitly if the real UI provider is unavailable. No bundled test-only copy. `python -B tests/test_deployment.py` verifies source comparison gates in temporary directories, including missing UI refusal; it does not deploy or package. The legacy host pixel-preview helper now accepts `--ui`; its independent `ComputerArt.lua` prerequisite is absent from the current paired PC checkout, so preview generation is BLOCKED at that existing assertion. It did not produce visual proof; actual provider behavior is covered by paired UI tests, not the preview's native-widget approximations.

G6 native client/controller/split-screen NOT TESTED; dedicated G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Operator must test UI-only startup, required-mod disable/refusal, editor/settings reload, tooltips/modals/controller focus, clipboard/paper/digital ledger and two-player viewports, then dedicated two-client Sort/Shopping/ledger intent, join/reconnect/restart. No package, deployment, Workshop upload or game/server launch. Public GitHub source backup does not validate runtime behavior.
