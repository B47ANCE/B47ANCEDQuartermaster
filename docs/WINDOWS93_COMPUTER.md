# Windows '93 computer desktop

Project Version: 0.24.0-dev.3

Current application prerequisite: find and run the Quartermaster Application CD installer on each PC before computer ledger reads/writes or automatic knowledge provision (server opt-out supported). The Application CD is released after successful setup and is not required nearby afterward. Paper inspection does not need the app; Sort follows the default paper/writer policy above. Current capabilities are Ledger 5 / Movement 12. [Exact implementation, settings, validation and migration limits](APPLICATION_CD.md). Earlier checkpoint sections retain their original evidence.

Computers open an original Lua-drawn Windows '93 desktop inside a beige CRT monitor. The bulky molded case has a thick front bezel, deep chamfered glass rim, offset vented rear housing, a broad lower control deck, central model badge, green power light and a physical power button. A tall swivel neck and substantial beveled pedestal support the case. The desktop, taskbar and status text stay inside the glass. Opening the desktop never auto-runs the ledger.

CD-ROM, CD Writer and QUARTERMASTER.EXE use original layered pixel artwork on a 32x32 grid. Desktop icons use integer 2x scale, separate centered captions and text shadows; the application entry uses its own monitor/checklist icon. Artwork lives in PC Framework `ComputerArt.lua`, not external images, copied OS resources or a generated texture pack. The renderer uses the already verified native ISUI rectangle/text primitives. No new engine APIs are needed. The required PC Framework hosts this presentation; Quartermaster retains the ledger and writer data/permissions.

The physical power button follows the existing Log Off/close path, including pending-write cancellation. It does not cut shared building electricity or move/eject a real CD. It remains reachable through the controller focus rows. Minimum dimensions reserve the thicker bezel, badge, control deck, stand, status line and taskbar at 14/24/32/42 font heights. No protocol, persistence or gameplay settings change: the chrome is local presentation, not configurable gameplay.

For a reproducible **host preview**, install/use the existing development Pillow and Lupa (Lua 5.1) environment, then run:

```powershell
python -B scripts/render_computer_preview.py --pc-framework <paired-PC-Framework-checkout> --output <local-preview-directory>
```

This executes the current Lua art/layout and exports desktop, Start, loaded-CD, writer, digital-ledger and paper-clipboard views plus a contact sheet. The item names are synthetic fixtures; native widget paint/fonts are approximations. These images are not Project Zomboid screenshots or native acceptance evidence. The script is development-only and excluded from the runtime manifest.

Server Ledger Mode can disable the entire computer/CD path. With Computer Manual Updates on, the configured ledger expiry applies; record storage and write/load a new CD to renew it. With that option off, a powered authorized computer inside the exact native building recorded by a completed CD shows live statistics without expiry. Off-site and safehouse-wide CDs show history under normal expiry. This does not rewrite its CD or paper snapshot. [Modes and limits](LEDGER_FRESHNESS.md).

## Taskbar and presentation

The chunky CRT keeps its vented housing and broad stand, with a quieter molded face and fewer hard concentric stripes. The artwork remains original code-native drawing, not a newly imported texture/photo pack.

CD-ROM, CD Writer and the ledger each have one retained task. Opening an already open app activates its existing panel. Clicking the active task minimizes it; clicking an inactive/minimized task restores/focuses it. The active task uses a pressed border and an icon. Closing one task removes its button and reveals the most recent remaining non-minimized app. Closing all apps leaves the desktop and an empty taskbar, not a fake application button.

Show Desktop minimizes all currently visible apps. Press it again to restore those apps and their prior active task; apps that were already individually minimized stay minimized. Opening/activating another app leaves Show Desktop mode. Query, current page and CD/writer choices survive switching and minimizing. Reopening a closed app starts a new panel. Native full-title hover/controller tooltips identify clipped task labels and the icon-only Show Desktop action.

The ledger is tied to the mounted CD. Removing/ejecting/changing that media closes its active or hidden task; drive and writer windows stay open. Resuming a cached ledger clears old rows and revalidates the preserved query/page through the existing authenticated ledgerRead request. Closed readers ignore late replies. A late CD-mount result may update the reported drive binding but cannot reopen a closed drive window or steal focus from another app. This is presentation cleanup, not new authority or a cancellation guarantee for already completed native media work.

Minimize, Show Desktop and task switching preserve panels while clearing their tooltips. Hidden panels do not consume Escape. Controller B returns an app to the taskbar; its existing explicit Close/X remains available. Escape dismisses Start first; otherwise the existing active-app/desktop close flow remains. CD insertion/removal updates controller rows so QUARTERMASTER.EXE stays reachable. Power and Start-menu Log Off close every task and retain the existing pending-CD-write cancellation path. Closing only the Writer window remains a presentation action; it does not replace that existing job-cancellation policy.

## Using the drive

1. Create a completed Supply Sheet and use **CD Writer** to write a selected carried vanilla CD, keeping the paper.
2. Put the resulting ledger CD in an accessible physical desk/container within one square of the computer, on the same floor. This approved Lua-only storage path avoids creating an unverified computer inventory or virtual item.
3. Choose **Use computer (Windows '93)**, open **CD-ROM (D:)**, select the storage CD and press **Load selected storage CD**. The server validates the real item, storage and computer, then saves a drive binding. No item is moved or consumed.
4. Double-click **QUARTERMASTER.EXE** or press **Run application**. The embedded reader supports literal search, authorized room browsing and pages. Merely loading a CD does not fetch ledger pages.
5. Minimize/restore and switch between retained apps through the taskbar. Eject/unload closes the app and removes only its drive binding; the CD stays in storage. Log Off/closing the screen cancels this player's active CD writing but leaves an established storage-CD binding available. It does not switch off shared world electricity.

The **sorting/collection requirement** is described in [LEDGER_REQUIREMENT.md](LEDGER_REQUIREMENT.md). A powered loaded computer can provide the matching record while players work around its building. Private computer/storage permissions, real CD presence and power are checked by the server for every new grant. Carrying a ledger CD by itself does not qualify. Paper reading/recording remains independent.

## UI and authority

ComputerUI owns presentation and proxies returned by server drive discovery, never authoritative item ownership. Drive choices are bounded, authenticated, sender-bound opaque offers. A mounted proxy cannot authorize sorting. Drive List/Mount/Eject/Read use Ledger capability 3; physical ledger schema stays 1. The stored CD is re-resolved on server reads and grants. The client polls authorized drive status at most once per two seconds while using the screen; native transfer authority does not wait for that UI poll.

Native buttons/dropdowns, B/controller navigation, keyboard Escape, resize minimums, taskbar/list/footer bounds and light search-entry glyphs remain. Existing native `ISTextEntryBox:setTextRGBA` colors the actual native text-entry glyphs. All 29 UI locales retain English fallbacks. UI code uses existing Lua-exposed ISUI primitives and original symbols; no external OS assets, arbitrary executable loader, filesystem or Java modification is introduced. B47ANCED PC Framework is now a separate required Lua-only mod dependency; Quartermaster registers the ledger reader and CD Writer apps with it.

## Ledger application

The digital reader now uses an original Windows '93 table inside QUARTERMASTER.EXE. A labelled Find item entry and Room selector sit above a compact location/freshness strip and current-page entry count. Raised fixed column headers label Item, Quantity and Location; quantities align to the right, rows alternate, and the selected entry uses navy/white contrast. The column gutter is reserved for the native scrollbar. Long cells truncate safely, with full authorized data in clipped-row tooltips and a two-line details area (recording time, FullType, condition and exact compartment location). No fake menu commands or external OS assets are introduced.

Search remains literal/case-insensitive through existing server requests. Room options and rows come from the authenticated page only. Native list/controller selection is reachable and B returns to the app; minimum window height now reserves a complete row and the fixed details/footer at large fonts. Automatic refresh preserves exact FullType/location/condition identity and clamped scroll position; a changed search, room or page starts at its top. Empty/redacted/waiting results clear old rows and details. Counts describe this returned page, not a fabricated whole-building total. Paper now uses the matching three-column clipboard reader; computer live/freshness behavior is constrained to the recorded building. See [current clipboard and server-policy evidence](CLIPBOARD_AND_LOCAL_COMPUTER.md). UI dimensions are internal presentation constants; no shared gameplay setting is added.

## Validation

Current 0.18.0-dev.7 clipboard and server-policy validation is recorded in [CLIPBOARD_AND_LOCAL_COMPUTER.md](CLIPBOARD_AND_LOCAL_COMPUTER.md). Earlier versioned results below remain historical.

### Historical 0.18.0-dev.6 ledger application - 2026-10-17

[TESTED OFFLINE] Focused production-path ledger UI fixture PASS. Checks include separate column widths, quantity alignment, selected-row contrast/details, clipping and reserved native scrollbar space; offscreen rows skip formatting/drawing. Forty synthetic rows verify refresh selection/scroll preservation with exact item/location identities, page/search reset, empty/redacted/waiting cleanup, no per-render requests, and controller row access. Minimum and enlarged layouts pass at 14/24/32/42 font heights. Existing desktop/taskbar/media-loss/late-response/power and paper fixtures pass.

Current source preview executes the actual LedgerUI and LedgerTable with synthetic authorized responses. Fonts and native widget painting are approximated, so preview pixels are not PZ evidence. Full paired regression PASS against Rooms 0.2.0-dev.6. After that run, the strengthened reordered-row selection fixture also PASSed in the focused suite. Version checks and source-manifest parity PASS for 224 runtime files. Runtime SHA-256: `a80ef09fcd0f28f0e3e1c84013eb50c6b1b789d828d119ac6f353ad0e2a3c67f` (sorted relative UTF-8 path, NUL, binary file SHA-256).

Exact commands (development Lupa/Pillow environment; never launches PZ):

```powershell
python -B tests/run_tests.py --require-rooms --rooms 'C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDRooms'
python -B scripts/render_computer_preview.py --output 'C:/Users/willi/.codex/visualizations/quartermaster-ledger-windows93'
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
git -c core.safecrlf=false diff --cached --check
```

The focused suite executes `tests/test_ledger_ui.lua` with the runner's same Lua 5.1 path/globals. Shared source differences are only the project Identity version and 12 English-fallback UI labels in all 29 locales; no server code changes. New production file: `42/media/lua/client/B47ANCEDQuartermaster/LedgerTable.lua`. Other implementation files: `LedgerUI.lua` and the computer window minimum-height calculation in `ComputerUI.lua`. Tests, development preview renderer, version mirrors, manifest, README/changelog and reviewed overview are maintained in this branch. No external assets or runtime dependencies. G6 native visual/controller NOT TESTED; inherited G7/stable G8 remains BLOCKED. No package, deployment, game/server launch or Workshop publication.


### Historical 0.18.0-dev.5 taskbar and artwork cleanup - 2026-10-17

[TESTED OFFLINE] Final full paired regression PASS with Rooms 0.2.0-dev.6 after the keyboard/tooltip/controller corrections. Current UI fixtures verify independent retained tasks, no duplicate app launches, query/page/choice preservation, active-task minimize, inactive restore, most-recent visible fallback, per-app close/X, Show Desktop restoration excluding individually minimized apps, and taskbar bounds at minimum size and 14/24/32/42 font heights. The controller taskbar is one horizontal row matching its layout.

Additional regressions cover EXE controller rows after mount, hidden panels ignoring Escape, Start consuming Escape before the app behind it, native full-title tooltip updates/cleanup, cached ledger rows clearing before authenticated resume, late mount/read replies not resurrecting closed tasks, media loss invalidating a hidden ledger while preserving drive/writer, power cancellation and disabled-mode cleanup. Native button updateTooltip and panel removeChild/bringToTop contracts were checked in the installed ISUI Lua; no new engine methods are assumed.

Version/source-manifest and source-rendered preview checks PASS; runtime inventory remains 223 files. Runtime SHA-256: `bed23305e5949d3376182a6968806486691d387bf676aa87bd3c32761fea2c99` (sorted relative UTF-8 path, NUL, binary file SHA-256). Shared gameplay changes are limited to the canonical version mirror and the localized Show Desktop label. There are no new commands, protocol/schema changes, native transfer changes, copied assets or runtime dependencies. Artwork remains original code-native drawing; the preview uses approximate host fonts/native widgets and is not a game screenshot.

Exact commands are the full regression, preview, version/source-manifest and whitespace commands listed under the historical dev.3 section below; they were rerun for this source. No package was created. G6 native UI/controller NOT TESTED; inherited G7/stable G8 remains BLOCKED. No game/server launch, deployment or Workshop upload.

### Historical 0.18.0-dev.4 bulky CRT pass - 2026-10-17

[TESTED OFFLINE] Full paired regression PASS with Rooms 0.2.0-dev.6. The current UI fixture verifies thick surround dimensions, control-deck/stand separation, usable minimum geometry, large fonts, controller reachability and the existing media workflow. A pending CD-writing fixture now proves the physical power callback closes the UI, marks the work closed, stops its queued local native action and sends the existing ledgerCancel request. This is source/host evidence, not an in-game power test or proof of a remote cancellation outcome.

Version and source-manifest checks PASS (223 runtime files). Current source-rendered desktop, Start, loaded-CD and writer previews were inspected; the preview contact sheet now preserves the case aspect ratio. Commands are the full runner, preview renderer, version/source-manifest and whitespace commands listed below. No native performance claim or package was produced.

Runtime SHA-256: `efac190e589799088fcf8eb5e4ddda0d2699a22e1d4626473790cabc2ccfdf77` (sorted relative UTF-8 path, NUL, binary file SHA-256). Changes are original code-native geometry, influenced by the user-supplied hardware proportions; no reference photograph, product logo or third-party asset is shipped. Protocols, saves, authoritative ledger handling and physical inventory remain unchanged.

[RUNTIME GATE] Native visual/controller G6 remains NOT TESTED; inherited gameplay G7/stable G8 remains BLOCKED. No game/server launch, deployment, packaging or Workshop publication.

### Historical 0.18.0-dev.3 CRT pass - 2026-10-17

[TESTED OFFLINE] Full paired regression passed against Rooms 0.2.0-dev.6. After the final font-aware case badge and physical-power tooltip adjustments, reran the focused ledger/computer UI fixture successfully. Rendering the four preview states from current source also passed. Code-native icons satisfy their 32x32 bounds/palette checks; the shared geometry tests verify current minimum sizes, separate icon captions, glass-contained taskbar, physical power placement and controller reachability. No native frame-time claim is made; drawing uses fixed-size artwork/layer loops and no world scans.

Exact commands (development Lupa/Pillow environment):

```powershell
python -B tests/run_tests.py --require-rooms --rooms <verified-Rooms-checkout>
python -B scripts/render_computer_preview.py --pc-framework <paired-PC-Framework-checkout> --output <local-preview-directory>
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
git -c core.safecrlf=false diff --cached --check
```

The final focused run executes `tests/test_ledger_ui.lua` through the same Lua 5.1 runtime and native-fixture globals used by the full runner. Source-manifest parity covers 223 runtime files; no package/deployment is implied. Runtime SHA-256: `ceb77a01663520ead5f32b91cfed77779e689543aa6d1d89b06ebed941c1acf5` (sorted relative UTF-8 path, NUL, binary file SHA-256). Overview digest binds the current source, README and VERSION separately. Earlier source reports and artifact receipts remain historical and unchanged.

G6 native visual/controller acceptance is NOT TESTED. This slice is client presentation only, but the combined source candidate still inherits pending gameplay G7/stable G8 gates. No stable-readiness claim, game/server launch, package, deployment or Workshop upload.

[TESTED OFFLINE] Full regression suite with actual Rooms source and installed native Lua fixtures. UI tests cover no automatic read; explicit storage-CD load/Run/EXE double-click; embedded search/rooms; exact writer choices; minimize/eject/logoff; server-reported CD loss; power loss; Escape/controller; native entry glyph color; and geometry at 14/24/32/42 font heights. These are host fixtures, not native pixels/network execution. See the [current requirement report](LEDGER_REQUIREMENT.md) for exact commands, server-side tests and limits.

The original 0.14.0-dev.2 UI commit is 4a9be2bf7ae664e49880158d996268ee56c61097; its local-only carried-CD mount was replaced by this server-owned storage binding. Historical package/API receipts retain their exact original versions. This source iteration is not packaged/deployed/published.

[RUNTIME GATE] Native client visuals, tooltip/dropdown layering, keyboard/controller focus, scaling, late replies, two-client drive changes and power/permission/media-loss behavior remain NOT TESTED. Dedicated G7 and stable G8 remain BLOCKED. Shared ledger/media gameplay acceptance is not proven by offline geometry tests.
