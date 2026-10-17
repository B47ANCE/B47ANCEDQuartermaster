# Windows '93 computer desktop

Project Version: 0.14.0-dev.2

## Player workflow

1. At a supported powered desktop, choose **Use computer (Windows '93)**. The character uses the existing native adjacent-walking path. A CRT-style screen opens onto a teal desktop, not a ledger page.
2. Open **CD-ROM (D:)** using its desktop icon or the Start menu. Choose a carried ledger CD and press **Insert selected CD**. Insertion does not run anything.
3. Double-click **QUARTERMASTER.EXE** in the drive window, or press **Run application**. The existing searchable ledger reader opens inside the computer's application window. An ordinary music CD has no runnable ledger application.
4. Use item/FullType search, authorized room browsing and pages inside that application. Minimize to the desktop and use the taskbar to return. Ejecting the CD closes its application. Dropping/trading/losing the exact carried disc also clears the mount and closes cached pages.
5. To make a ledger CD, open **CD Writer** from the desktop or Start menu. Select a completed Supply Sheet and the exact compatible CD, then explicitly press **Write Supply Ledger CD**. The on-screen overwrite notice states that the selected CD is replaced and the paper is kept. Eject any mounted disc first. Server-granted native timing/conversion is unchanged.
6. **Shut Down** closes the screen and cancels that player's active CD-writing operation. Power, access, reachability or exact-computer loss also closes the screen. Native stop/server completion checks remain authoritative.

Paper reading/recording stays available through the paper's inventory context actions and does not require this desktop. A powered computer can be opened without a CD or completed sheet; its applications show empty-media choices rather than manufacturing media or records.

The desktop/drive is original Lua presentation, not an emulator, real filesystem or arbitrary executable loader. A mounted CD is a client-local reference to an already carried native item. Inserting/ejecting neither moves nor creates an item, invents a physical computer inventory nor persists an OS session. The server independently requires native media possession for every read/write. The EXE is the deliberate UI entry into the existing ledger application.

## Implementation and invariants

- New `ComputerUI.lua` draws the CRT bezel, original monitor/disc/writer symbols, grey beveled controls, teal desktop, navy application bars, Start menu and taskbar using existing Lua-exposed native ISUI primitives. No bitmap generation, outside OS logos/artwork, third-party source/assets, Java mod or runtime dependency is introduced.
- `LedgerUI.lua` routes computer context interaction through the desktop. It embeds its digital reader in the app frame only after the active screen has the exact selected disc mounted. Merely opening a desktop/drive or inserting a disc sends no `ledgerRead`. Direct digital-reader entry without that screen returns to the desktop instead of auto-running it.
- CD Writer calls the existing `ledgerBurn` intent only after explicit sheet/CD choice and Write. The existing server owns timing, grants, completion, item mutation, journaling, snapshot access and persistence. The OS owns no gameplay state. Old ledger protocol/schema 1, movement 9, saved sorting and transfer grouping/timing are unchanged.
- Native computer identity remains `appliances_com_01_72`; compatible writable input remains `Base.Disc_Retail`. The user-defined scope does not imply support for arbitrary modded computer sprites or executable discs. Existing native safehouse/Rooms inspection gates remain active; the server still redacts unauthorized snapshot contents.
- Native buttons/dropdowns and controller rows remain interactive. B closes an application or returns from a desktop/menu; keyboard Escape returns to the desktop/shuts down. Reader search uses native keyboard text entry. Resizing preserves the active reader/search/page state and keeps footer/taskbar controls separate. Minimum dimensions grow with native font metrics; too-small viewports use the existing refusal notice.
- Inventory choices reuse the existing bounded recursive carried-media discovery (4,096 instances, depth 16, 16 entries per media class). Drive/writer refreshes reuse a one-second client cache instead of scanning during every paint. Desktop opening alone performs no inventory scan or ledger request. These are presentation/resource constants, not shared gameplay configuration; no new sandbox option is necessary.
- All 29 UI locale folders have the established English fallback keys. This is fallback coverage, not 29 human translations.

## Source and evidence

This compatible UI prerelease follows `0d95b2872b7d8f83c9a775925788e02365a737ca` (the physical Ledger baseline) on `feature/windows93-computer`. Freshness review confirms the parent branch matches that commit. The old remote default differs only by a README change already represented in the feature ancestry; no missing gameplay commit was bypassed. Prior worktrees, packages and dated evidence remain unchanged.

[VERIFIED SOURCE] Target remains installed Project Zomboid 42.21.0, Steam build 25485521. Existing native ISButton and ISCollapsableWindow/ISPanelJoypad handle clicks, double-click hooks, focus, child layering and resizing. Installed `ISHutchUI.lua` lines 884–893 and 970 provide the Escape/isKeyConsumed/onKeyRelease + setWantKeyEvents convention. Installed ISTextEntryBox.lua lines 117–119 provide setTextRGBA for native entry glyphs, which cannot be recolored solely through a Lua textColor field; the embedded search explicitly uses that wrapper for black-on-white text. These observations are recorded in the developer's unmanaged API draft; it is not native execution proof. The existing [native ledger evidence](LEDGER_NATIVE_EVIDENCE_2026-10-16.json) still applies to the unchanged server/native-action paths without relabeling its original version.

[TESTED OFFLINE] Production LedgerUI/ComputerUI against owned geometry/input fixtures, installed native ComboBox/base-action Lua and the full regression suite with actual Rooms source. Coverage: no automatic desktop/insertion read; explicit Run and EXE double-click; embedded application; literal search/room pages; writer exact choices; minimize/taskbar; eject; exact media loss; shutdown cancellation; power loss; duplicate screen; Escape/controller; taskbar/list/footer and writer text bounds at 14/24/32/42 font heights. Existing paper tests remain. Host geometry checks are not pixel proof or native input/latency evidence.

Commands (host Python with Lupa, from this worktree):

```powershell
python -B tests/run_tests.py --require-rooms --rooms 'C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDRooms'
python -B scripts/check_deployment.py
python -B scripts/check_versions.py
git -c core.safecrlf=false diff --check
```

Source manifest: 204 runtime files. This iteration is source-only: **no current package, local deployment, Workshop upload or game/server launch**. The [0.14.0-dev.1 receipt](LEDGER_ARTIFACT_2026-10-16.json) remains an earlier exact package record, not proof for this UI change. All changed production behavior is client presentation; no server mutation/authorization logic changed. The parent physical-ledger gameplay still lacks native/dedicated acceptance.

## Native acceptance remaining

[RUNTIME GATE] G6 native visuals/input NOT TESTED. G7 dedicated parent-ledger gameplay NOT TESTED/BLOCKED; stable G8 BLOCKED. No native frame-time, network/latency or performance improvement is claimed.

Verify actual CRT/application rendering, clipping, tooltip layering, font scaling and resizing; mouse double-click and controller focus through desktop/Start/dropdowns/reader; keyboard Escape with active search/dropdown; insert/run/eject with paper and multiple CDs; CD writing completion and shutdown cancellation; power/grid/generator loss; walking away; object removal; disc transfer/drop; split-screen focus; late read responses after closing; and two-client server privacy/media conservation. UI fixtures cannot replace these tests.
