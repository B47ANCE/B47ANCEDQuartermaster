# Windows '93 computer desktop

Project Version: 0.18.0-dev.4

Computers open an original Lua-drawn Windows '93 desktop inside a beige CRT monitor. The bulky molded case has a thick front bezel, deep chamfered glass rim, offset vented rear housing, a broad lower control deck, central model badge, green power light and a physical power button. A tall swivel neck and substantial beveled pedestal support the case. The desktop, taskbar and status text stay inside the glass. Opening the desktop never auto-runs the ledger.

CD-ROM, CD Writer and QUARTERMASTER.EXE use original layered pixel artwork on a 32x32 grid. Desktop icons use integer 2x scale, separate centered captions and text shadows; the application entry uses its own monitor/checklist icon. Artwork lives in `ComputerArt.lua`, not external images, copied OS resources or a generated texture pack. The renderer uses the already verified native ISUI rectangle/text primitives. No new engine APIs or runtime dependencies are needed.

The physical power button follows the existing Log Off/close path, including pending-write cancellation. It does not cut shared building electricity or move/eject a real CD. It remains reachable through the controller focus rows. Minimum dimensions reserve the thicker bezel, badge, control deck, stand, status line and taskbar at 14/24/32/42 font heights. No protocol, persistence or gameplay settings change: the chrome is local presentation, not configurable gameplay.

For a reproducible **host preview**, install/use the existing development Pillow and Lupa (Lua 5.1) environment, then run:

```powershell
python -B scripts/render_computer_preview.py --output <local-preview-directory>
```

This executes the current Lua art/layout and exports desktop, Start, loaded-CD and writer views plus a contact sheet. The item names are synthetic fixtures; native widget paint/fonts are approximations. These images are not Project Zomboid screenshots or native acceptance evidence. The script is development-only and excluded from the runtime manifest.

Server Ledger Mode can disable the entire computer/CD path. With Computer Manual Updates on, the configured ledger expiry applies; record storage and write/load a new CD to renew it. With that option off, a powered authorized computer with a matching completed CD shows live statistics without expiry. This does not rewrite its CD or paper snapshot. [Modes and limits](LEDGER_FRESHNESS.md).

## Using the drive

1. Create a completed Supply Sheet and use **CD Writer** to write a selected carried vanilla CD, keeping the paper.
2. Put the resulting ledger CD in an accessible physical desk/container within one square of the computer, on the same floor. This approved Lua-only storage path avoids creating an unverified computer inventory or virtual item.
3. Choose **Use computer (Windows '93)**, open **CD-ROM (D:)**, select the storage CD and press **Load selected storage CD**. The server validates the real item, storage and computer, then saves a drive binding. No item is moved or consumed.
4. Double-click **QUARTERMASTER.EXE** or press **Run application**. The embedded reader supports literal search, authorized room browsing and pages. Merely loading a CD does not fetch ledger pages.
5. Minimize/restore through the taskbar. Eject/unload closes the app and removes only its drive binding; the CD stays in storage. Log Off/closing the screen cancels this player's active CD writing but leaves an established storage-CD binding available. It does not switch off shared world electricity.

The **sorting/collection requirement** is described in [LEDGER_REQUIREMENT.md](LEDGER_REQUIREMENT.md). A powered loaded computer can provide the matching record while players work around its building. Private computer/storage permissions, real CD presence and power are checked by the server for every new grant. Carrying a ledger CD by itself does not qualify. Paper reading/recording remains independent.

## UI and authority

ComputerUI owns presentation and proxies returned by server drive discovery, never authoritative item ownership. Drive choices are bounded, authenticated, sender-bound opaque offers. A mounted proxy cannot authorize sorting. Drive List/Mount/Eject/Read use Ledger capability 3; physical ledger schema stays 1. The stored CD is re-resolved on server reads and grants. The client polls authorized drive status at most once per two seconds while using the screen; native transfer authority does not wait for that UI poll.

Native buttons/dropdowns, B/controller navigation, keyboard Escape, resize minimums, taskbar/list/footer bounds and light search-entry glyphs remain. Existing native `ISTextEntryBox:setTextRGBA` colors the actual native text-entry glyphs. All 29 UI locales retain English fallbacks. New UI code uses existing Lua-exposed ISUI primitives and original symbols; no external OS assets, arbitrary executable loader, filesystem, Java modification or separate runtime dependency is introduced.

## Validation

### 0.18.0-dev.4 bulky CRT pass - 2026-10-17

[TESTED OFFLINE] Full paired regression PASS with Rooms 0.2.0-dev.6. The current UI fixture verifies thick surround dimensions, control-deck/stand separation, usable minimum geometry, large fonts, controller reachability and the existing media workflow. A pending CD-writing fixture now proves the physical power callback closes the UI, marks the work closed, stops its queued local native action and sends the existing ledgerCancel request. This is source/host evidence, not an in-game power test or proof of a remote cancellation outcome.

Version and source-manifest checks PASS (223 runtime files). Current source-rendered desktop, Start, loaded-CD and writer previews were inspected; the preview contact sheet now preserves the case aspect ratio. Commands are the full runner, preview renderer, version/source-manifest and whitespace commands listed below. No native performance claim or package was produced.

Runtime SHA-256: `efac190e589799088fcf8eb5e4ddda0d2699a22e1d4626473790cabc2ccfdf77` (sorted relative UTF-8 path, NUL, binary file SHA-256). Changes are original code-native geometry, influenced by the user-supplied hardware proportions; no reference photograph, product logo or third-party asset is shipped. Protocols, saves, authoritative ledger handling and physical inventory remain unchanged.

[RUNTIME GATE] Native visual/controller G6 remains NOT TESTED; inherited gameplay G7/stable G8 remains BLOCKED. No game/server launch, deployment, packaging or Workshop publication.

### Historical 0.18.0-dev.3 CRT pass - 2026-10-17

[TESTED OFFLINE] Full paired regression passed against Rooms 0.2.0-dev.6. After the final font-aware case badge and physical-power tooltip adjustments, reran the focused ledger/computer UI fixture successfully. Rendering the four preview states from current source also passed. Code-native icons satisfy their 32x32 bounds/palette checks; the shared geometry tests verify current minimum sizes, separate icon captions, glass-contained taskbar, physical power placement and controller reachability. No native frame-time claim is made; drawing uses fixed-size artwork/layer loops and no world scans.

Exact commands (development Lupa/Pillow environment):

```powershell
python -B tests/run_tests.py --require-rooms --rooms <verified-Rooms-checkout>
python -B scripts/render_computer_preview.py --output <local-preview-directory>
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
git -c core.safecrlf=false diff --cached --check
```

The final focused run executes `tests/test_ledger_ui.lua` through the same Lua 5.1 runtime and native-fixture globals used by the full runner. Source-manifest parity covers 223 runtime files; no package/deployment is implied. Runtime SHA-256: `ceb77a01663520ead5f32b91cfed77779e689543aa6d1d89b06ebed941c1acf5` (sorted relative UTF-8 path, NUL, binary file SHA-256). Overview digest binds the current source, README and VERSION separately. Earlier source reports and artifact receipts remain historical and unchanged.

G6 native visual/controller acceptance is NOT TESTED. This slice is client presentation only, but the combined source candidate still inherits pending gameplay G7/stable G8 gates. No stable-readiness claim, game/server launch, package, deployment or Workshop upload.

[TESTED OFFLINE] Full regression suite with actual Rooms source and installed native Lua fixtures. UI tests cover no automatic read; explicit storage-CD load/Run/EXE double-click; embedded search/rooms; exact writer choices; minimize/eject/logoff; server-reported CD loss; power loss; Escape/controller; native entry glyph color; and geometry at 14/24/32/42 font heights. These are host fixtures, not native pixels/network execution. See the [current requirement report](LEDGER_REQUIREMENT.md) for exact commands, server-side tests and limits.

The original 0.14.0-dev.2 UI commit is 4a9be2bf7ae664e49880158d996268ee56c61097; its local-only carried-CD mount was replaced by this server-owned storage binding. Historical package/API receipts retain their exact original versions. This source iteration is not packaged/deployed/published.

[RUNTIME GATE] Native client visuals, tooltip/dropdown layering, keyboard/controller focus, scaling, late replies, two-client drive changes and power/permission/media-loss behavior remain NOT TESTED. Dedicated G7 and stable G8 remain BLOCKED. Shared ledger/media gameplay acceptance is not proven by offline geometry tests.
