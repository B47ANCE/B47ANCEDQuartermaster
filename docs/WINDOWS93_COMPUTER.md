# Windows '93 computer desktop

Project Version: 0.20.0-dev.1

Current computer hosting is supplied by the required **B47ANCED PC Framework**; Quartermaster registers its ledger reader and CD Writer as apps. Existing ledger/drive data and server permissions are preserved. See [extraction, setup and current evidence](PC_FRAMEWORK_INTEGRATION.md).

Computers open an original Lua-drawn Windows '93 desktop with a CRT bezel, teal desktop, grey beveled controls, Start menu and taskbar. Opening the desktop never auto-runs the ledger.

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

Native buttons/dropdowns, B/controller navigation, keyboard Escape, resize minimums, taskbar/list/footer bounds and light search-entry glyphs remain. Existing native `ISTextEntryBox:setTextRGBA` colors the actual native text-entry glyphs. All 29 UI locales retain English fallbacks. UI code uses existing Lua-exposed ISUI primitives and original symbols; no external OS assets, arbitrary executable loader, filesystem or Java modification is introduced. B47ANCED PC Framework is now a separate required Lua-only mod dependency; Quartermaster registers the ledger reader and CD Writer apps with it.

## Validation

[TESTED OFFLINE] Full regression suite with actual Rooms source and installed native Lua fixtures. UI tests cover no automatic read; explicit storage-CD load/Run/EXE double-click; embedded search/rooms; exact writer choices; minimize/eject/logoff; server-reported CD loss; power loss; Escape/controller; native entry glyph color; and geometry at 14/24/32/42 font heights. These are host fixtures, not native pixels/network execution. See the [current requirement report](LEDGER_REQUIREMENT.md) for exact commands, server-side tests and limits.

The original 0.14.0-dev.2 UI commit is 4a9be2bf7ae664e49880158d996268ee56c61097; its local-only carried-CD mount was replaced by this server-owned storage binding. Historical package/API receipts retain their exact original versions. This source iteration is not packaged/deployed/published.

[RUNTIME GATE] Native client visuals, tooltip/dropdown layering, keyboard/controller focus, scaling, late replies, two-client drive changes and power/permission/media-loss behavior remain NOT TESTED. Dedicated G7 and stable G8 remain BLOCKED. Shared ledger/media gameplay acceptance is not proven by offline geometry tests.

UI iteration 0.20.0-dev.1 uses PC Framework 0.9.0-dev.1's unified B47 / CRT 93 desktop: original beige casing/stand, pixel icons, shared Start menu, in-screen status/taskbar and physical logoff. Select Quartermaster alongside installed apps; its entry opens the CD browser and still requires explicit EXE/Run. CD Writer gets a separate retained tool window, so the ledger can stay open when another app/tool is active. The PC reader shows labeled search/room filters, a compact mode/scope summary, page/row count, Item/Quantity/Location columns and selected-row recorded/full-type/condition/location details. Paper layout and server response data are unchanged. Writer completion targets its originating host rather than the currently focused unrelated app. Disabling Quartermaster retires its sessions while leaving other framework apps available. Physical logoff still cancels owned writer work; it does not change shared electricity.
