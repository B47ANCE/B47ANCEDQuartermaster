# PC Framework extraction

Project Version: 0.24.0-dev.1

Current addition: [Stock/Base Ledger integration with PC Framework 0.11.0-dev.1](STOCK_AND_BASE_LEDGER.md). Existing authority and historical evidence below remain distinct.
Current Sort policy is the separate default-on [paper search/pickup and deferred writing workflow](SORT_LEDGER.md), Movement 12 / Ledger 5. Application installation and computer/CD behavior below remain otherwise unchanged; older capability/evidence checkpoints retain their original identity.

Quartermaster requires `B47ANCEDRooms`, `B47ANCEDPCFramework` and now `B47ANCEDUI` on the server and every client. Shared presentation uses UI's public client API 1; [source-only extraction and validation](UI_EXTRACTION.md). PC Framework 0.11.0-dev.1 / registration, CD program, notification and connections APIs 1 is the development companion for the unified desktop and genuine installer CD. Powered-PC support first appeared in framework 0.2.0-dev.1. PC Framework is distributed as Workshop item 3822042011; UI is distributed as Workshop item 3822582242; the current paired offline source is 0.3.0-dev.1. Current integration is checked against development companion 0.11.0-dev.1, retaining API 1. This source work does not change Quartermaster's existing Workshop item 3807217050.

[VERIFIED source] The desktop, shared native computer helpers and server drive engine are extracted into the standalone [B47ANCED PC Framework](https://github.com/B47ANCE/B47ANCEDPCFramework). Framework runtime has no Quartermaster imports. Quartermaster's `ComputerUI.lua` is now a compatibility alias; `LedgerUI.lua` registers `quartermaster`, `QUARTERMASTER.EXE`, the reader, and `ComputerWriter.lua`. Only the framework subscribes its world computer menu. Bare framework use opens without Quartermaster or ledger data. Disabling Quartermaster ledgers removes its app while leaving the independent desktop available; disabling the framework closes all framework desktops and fails computer access.

Quartermaster retains paper inspections, ledger settings/freshness, snapshots, supply rules, safehouse/Rooms privacy, genuine media identity, CD conversion, native action grants, server transport and command names. `LedgerMedia.computer` composes framework Device checks with Rooms inspect permissions. Its server-owned `LedgerDrives` adapter supplies target/access/snapshot callbacks to the framework engine. Clients still submit intent; no framework proxy authorizes a ledger read, burn, sort or collection. Current Rooms/privacy/power/media access is checked server-side for every read/grant. Unknown authority state continues to fail closed.

Save compatibility: canonical ledger schema 1 and drive schema 1 remain unchanged. `B47ANCEDQuartermasterLedgerDrives`, object `B47LedgerDrive`, storage `B47LedgerDriveStorage`, item FullTypes and server ledger data remain in place. No clearing, reissuing media or migration of existing records occurs. Live reads still resolve the real physical CD. Existing-save reload is tested using disposable offline persisted-store fixtures; native save/restart/reconnect remains untested. Back up disposable runtime test saves and use matching peers after adding the dependency.

Version classification: new standalone framework starts at 0.1.0-dev.1. Quartermaster 0.18.0-dev.2 -> 0.19.0-dev.1 is a 0.x MINOR dependency/integration change with preserved save and network schemas; the new required enabled mod is an explicit installation compatibility change. Protocol versions remain independent. Current mirrors and source manifest are synchronized; historical reports/packages retain their original identities.

Configuration candidates: framework Enabled is server sandbox configuration (default true, existing records retained). Ledger mode/expiry/range/manual updates remain Quartermaster settings. UI geometry, two-second polling, supported sprite, exact-item identity and bounded-scan/offer limits are technical constraints and stay internal. No duplicate gameplay slider or client gameplay override is added.

[TESTED OFFLINE] Framework-only Lua 5.1 tests and the complete Quartermaster suite with real Rooms source pass, including persisted bindings, privacy, power/media loss, UI geometry and CD conservation. Exact commands:

```powershell
python -B scripts/check_versions.py
python -B tests/run_tests.py --require-rooms --rooms <Rooms checkout> --pc-framework <PC Framework checkout>
python -B scripts/check_deployment.py
python -B tests/test_deployment.py
```

The runner requires a separate PC Framework checkout; pass `--pc-framework` from a worktree. Build.ps1 accepts `-PCFrameworkPath` / `-RoomsPath` and does not bundle either dependency. Its packaging entry point is not run by this task.

[RUNTIME GATE] Native SP and dedicated multiplayer NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Test standalone framework load, dependency absence, compatible peers, two-client drive contention, privacy/power/media loss, delayed replies, app switching, native rendering/input and restart/rejoin with existing bindings. No deployment, packaging, Workshop publication or game/server launch occurred.

PC Framework 0.2.0-dev.1 removes the one-facing hardware restriction: all four powered vanilla PC orientations and other placed `CustomName=Computer` tiles qualify. Quartermaster inherits this through its existing `LedgerMedia.computer` delegate and retains its Rooms/privacy checks. The consumer API and all data formats are unchanged, so this dependency expansion does not independently bump Quartermaster's version. Untagged modded PC graphics cannot be identified from appearance alone. Power loss, access denial and moved/deleted objects still revoke access.

## Reconciliation checkpoint — 0.19.0-dev.2

The user approved reconciling upstream extraction with the owned clipboard/CRT branch, and preserving the newer CRT/taskbar in the framework. Quartermaster contains no second desktop or ComputerArt module. PC Framework 0.3.0-dev.1 supplies retained drive/writer/app tasks and original art; Quartermaster ComputerWriter uses the existing writer callback and its ledger reader revalidates cached pages on resume. The portrait clipboard and table ruling fixes are local presentation. Existing exact-building live/freshness checks, kept clipboard recipe, schemas, permissions and native transfer grouping remain. [Current evidence and commands](CLIPBOARD_UI_FIX.md). Prior checkpoint evidence above retains its original scope.

## Application CD consumer

Quartermaster registers quartermaster.setup through PC.registerCDProgram and validates launch/installation through the framework CDPrograms server service. Application media uses its own actual DriveService bindings; the existing data-CD service remains separate. Quartermaster coordinates both drive namespaces to prevent mounting setup and ledger media simultaneously, and blocks writing while setup media remains loaded. The framework does not install or mutate inventory: Quartermaster owns the per-PC receipt and existing challenged native-action completion. [Current contract and runtime gates](APPLICATION_CD.md). The earlier 0.5.0-dev.2 pairing is historical; the current public 0.9.0-dev.3 companion preserves program API 1.

## Unified desktop reconciliation — 0.21.0-dev.5

The public companion retains independent application/tool host facades in one native desktop. Writer completion keeps the originating host, and closed or background applications do not receive another application's status. The shared LedgerTable remains the single digital/paper table renderer. Earlier paired-version observations above are historical checkpoints.
