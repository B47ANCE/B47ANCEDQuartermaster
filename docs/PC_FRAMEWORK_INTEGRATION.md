# PC Framework extraction

Project Version: 0.20.0-dev.2

Quartermaster requires `B47ANCEDRooms` and `B47ANCEDPCFramework` on the server and every client. PC Framework 0.9.0-dev.3 / registration API 1 is the companion MP testing build, available as [Workshop item 3822042011](https://steamcommunity.com/sharedfiles/filedetails/?id=3822042011). Enable and update it on all peers. This source work does not change Quartermaster's existing Workshop item 3807217050.

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

Unified UI follow-up: pair Quartermaster 0.20.0-dev.1 with Framework 0.9.0-dev.1. App callbacks/media transport remain API 1. The framework now retains independent app/tool host facades in one native root; `ComputerUI.active` represents foreground focus, while `ComputerUI.isLive(host)` checks retained lifetime and `host.root` is the native widget. Quartermaster keeps its server permission/binding/read/burn validation. A writer intent stores its UI host for completion status, preventing another active app from receiving that message. No snapshot, binding, capability or gameplay protocol changes. The Item/Quantity/Location table and selected details consume the same authorized response rows. No items, private records or gameplay authority are moved into UI state. The loader dependency remains B47ANCEDPCFramework; this source pair is not automatically packaged or deployed.

Publication checkpoint 0.20.0-dev.2 records the authorized companion Workshop distribution and preserves all APIs, authority, sandbox settings and save formats. It changes metadata and isolated-worktree build arguments only. Native SP/dedicated acceptance remains NOT TESTED; upload success is distribution evidence.
