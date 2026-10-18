# Quartermaster Application CD and PC installation

Project Version: 0.20.0-dev.2

## Workflow

Find **Quartermaster Application CD** in new commercial office-desk/counter, office supply shelf/crate or computer retail/stock loot. Put it in accessible existing storage within one square of a powered computer, on the same floor. Select **Quartermaster Setup** from the computer context menu (Quartermaster's opener routes an uninstalled PC there). Open **CD-ROM (D:)**, load the Application CD, explicitly run **SETUP.EXE**, then click **Install Quartermaster**. Complete the native action (default 20 seconds). The disc remains a real, reusable item in storage. Eject it, reopen Quartermaster, then use CD Writer or load a separate Supply Ledger CD. Loading media or opening Setup never installs automatically.

The Application CD is executable-program identity; the Supply Ledger CD is recorded inventory data. Neither is interchangeable. Installation belongs to the physical PC, not the player, carried CD, building or entire server. An installed PC needs no Application CD present for normal use. Data-CD loading/reading and same-building freshness retain their existing rules. Paper ledgers, inspection, physical Shopping Lists and ordinary inventory/container Sort are unchanged.

## Framework ownership

[VERIFIED SOURCE] Uses PC Framework CD program API 1: PC.registerCDProgram, server CDPrograms.new, authorize and resolve, genuine DriveService bindings, guarded requestRun/create and hosted ctx.window controls. Program identity is quartermaster.setup, compatibility version 1, media FullType B47ANCEDQuartermaster.ApplicationCD. This is an independent compatibility value, not the project version. Code comes from trusted Lua mods, never executable CD bytes.

Framework API source is 10041fc77124b9845a946474400f66e718c1b030 (0.5.0-dev.1). Its docs deliberately leave installation/writing to consumers. Quartermaster owns the installation receipt and challenged native action. The isolated **PC Framework 0.5.0-dev.2** integration reconciles that SDK/API with CRT/taskbar 12d320c86a3e22f6db32dc69051167fef589d097. Original source branches are preserved. A newer unrelated Minesweeper commit 1588a0e99601fbd9c91f7abb22a33da151b43609 is not included in this selected integration; its CD API source is unchanged. This is a pinned consumer test branch, not a claim to contain the latest unrelated framework features. It also prevents hidden SDK windows consuming Escape and clears the CD checking status after successful launch. No reusable installer or duplicate CD program API was invented in Quartermaster.

## Authority and persistence

Authenticated Quartermaster transport owns five new Ledger-family intents: setup list/mount/eject, program Run and program Install. Ledger capability advances 3 -> **4**, with bounded admission rates. Clients must update/reconnect with the server. Other capabilities, movement/native transfer groups and timing stay unchanged.

The framework re-resolves current native sender, loaded powered PC, exact mounted CD/binding/type, real adjacent storage and permissions. The registered server predicate additionally requires PC configure permission. Install intent creates an actor-bound native LedgerAction grant with exact media/PC references. Reconstruction is single-use. Existing serverStart challenge, sender confirmation and full native progress are required before shared state changes. Completion resolves the CD and access again. Cancellation, moving away, CD loss, power loss, PC replacement and permission revocation prevent completion. Duplicate completion cannot add another receipt. Closing Setup cancels its token; completed installs do not send a broad cancellation.

Installation root **B47ANCEDQuartermasterPrograms**, schema 1: bounded count/records of opaque PC receipt ID, independent program version and native x/y/z/object index. The PC stores B47QMProgram (opaque receipt reference) and B47QMProgramVersion (presentation hint); server object ModData is transmitted. A client-visible installed flag never authorizes gameplay: every protected server operation checks its own receipt and current exact PC/access. A copied receipt fails on a different position/index. Missing/corrupt/future records fail closed and are preserved.

Setup media bindings use independent **B47ANCEDQuartermasterProgramDrives** schema 1 with B47QMSetupDrive/B47QMSetupStorage markers through the framework service. Quartermaster coordinates these with existing ledger drives and native jobs: setup and data media cannot be mounted simultaneously; writing is refused while setup CD is loaded. Bindings and installs do not create, consume, move or clone any item.

Checks cover digital ledgerRead, ledgerBurn admission AND native completion, plus automatic computer knowledge provision for scoped Sort/Collect. Safehouse and Rooms inspection/configuration remain separate, additional requirements. Installation grants no new access. The inherited vanilla/native-action boundary does not secure unrelated vanilla inventory or object-metadata actions; no broader claim is made.

Receipts and framework bindings use native server ModData persistence. Service-reload fixtures pass, not native save/restart acceptance. Existing PCs begin uninstalled by default; existing ledger snapshots, papers, discs, sorting rules, presets and bindings remain untouched. Moving/replacing a PC or changing its native object identity/index may require reinstalling; no guessed identity migration grants access. The sandbox opt-out restores immediate computer access without deleting receipts. Downgrading preserves the independent installation root but old peers must never be mixed. Native rollback/restart requires disposable-save testing and backups.

## Server sandbox settings

| Identifier | Default | Supported values | Meaning |
| --- | --- | --- | --- |
| RequireComputerApplication | true | boolean | Require a valid per-PC installation for digital use/knowledge. Invalid/missing means required. |
| ApplicationInstallSeconds | 20 | integer 5-120 | Server native action duration; invalid/missing falls back to 20. |
| ApplicationCDLootWeight | 1 | double 0-10 | Relative weight in eight verified native office/computer pools; zero removes our entries. Not a percentage. Invalid/missing falls back to 1. Restart to apply distribution settings. |

All have stable names/tooltips in the project's 29-locale English fallback policy. Existing saves get defaults. Loot code is server-only, adds only to new native rolls, replaces its own entries idempotently and preserves unrelated entries. Disabled Ledger mode also removes our new-loot entries. Existing inventories are not refilled. Native weighted-loot outcomes/event ordering remain runtime gates. Record/offer caps, coordinates and compatibility IDs are internal technical constraints.

## Changes and evidence

Production: new shared LedgerProgram.lua, client ProgramInstaller.lua, server ApplicationLoot.lua; Ledger.lua, LedgerUI.lua, LedgerRequirement.lua, Protocol.lua, Authority.lua; ApplicationCD in existing native item script; sandbox definitions, all fallback item/UI/sandbox files, identity/mod metadata and manifest. No new bitmap/model assets or Java. Framework integration only changes original owned code. [Native/API provenance](APPLICATION_CD_EVIDENCE.json) contains portable installed-source fingerprints (PZ 42.21.0 / Steam build 25485521). No third-party implementation or game source was copied.

[TESTED OFFLINE at 0.20.0-dev.1, Windows / Python 3.12 / Lupa Lua 5.1] Full Quartermaster suite passed with actual Rooms 0.2.0-dev.6 and the paired framework. After the final narrow cancellation/status/disabled-loot corrections, focused program/legacy UI suites pass again. Framework's independent full suite passes, including CD API/SDK examples, malformed/late/duplicate authorization responses, wrong versions/media, media/power/access loss, cleanup errors and retained taskbar. No performance claim or native execution is inferred.

New actual-production fixtures cover default prerequisite, forged client flags, uninstalled read/burn denial, paper independence, real setup drive/CD authorization, cancellation, media/power/access loss, native sender challenge, retained CD, duplicate completion, exact-PC receipt, persisted service reload, future schema, client refusal, opt-out, idempotent zero/NaN loot, explicit UI load/run/install, double-click, close cancellation, server completion, eject and app availability. Legacy ledger/UI fixtures explicitly opt out to isolate previous behavior. The installer and existing reader/taskbar/paper fixtures cover bounds at font heights 14/24/32/42. Source-rendered installer preview visually reviewed; its synthetic records and host paint/fonts are approximations, not PZ pixels.

Exact checks from Quartermaster:

```powershell
python -B tests/run_tests.py --only-program --pc-framework <paired-framework>
python -B tests/run_tests.py --require-rooms --rooms <actual-Rooms> --pc-framework <paired-framework>
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
python -B tests/test_deployment.py
python -B scripts/render_computer_preview.py --pc-framework <paired-framework> --output <external-preview-directory>
git -c core.safecrlf=false diff --cached --check
```

Framework: `python -B tests/run_tests.py`; `python -B scripts/check_versions.py`; staged diff and public credential/artifact scans. Python/Lupa/Pillow are host-only tools. All filename case, owned requires, Lua-only, source manifest and 29-locale fallback checks are offline evidence.

Historical 0.20.0-dev.1 source receipts: Quartermaster **228 files**, SHA-256 `f6e6ea32aa322bff24c7c99578d900f69d168097b62ce6d8f5e924ee70db972a`; paired framework **84 files**, SHA-256 `14fb6ebca4bd0623bc42645504f4c8bb405fc492634ba7911b138fd2afd6b430`. Algorithm: sorted source-relative UTF-8 path, NUL, binary per-file SHA-256 folded through SHA-256. These bind source bytes, not an artifact or runtime result. Historical reports/hashes retain their original versions/environments.

[RUNTIME GATE] G6 native SP NOT TESTED; G7 dedicated multiplayer NOT TESTED / BLOCKED; stable G8 BLOCKED. Required: actual new CD loot/name/icon, adjacency and power, timed Install/cancel, two clients contending, permission revocation, CD relocation, real notification/update, late replies, computer object removal/movement/index changes, native save/restart/reconnect, existing ledger-CD reads/writes, same-building automated knowledge and all opt-outs. Framework has no assigned Workshop item; distribution still needs explicit arrangement. No package, deploy, publication, shared-main merge or game/server launch.

## 0.20.0-dev.2 loot placement correction

Compatible PATCH checkpoint within the 0.20 prerelease. [VERIFIED SOURCE] Uses OfficeDesk, OfficeDeskSecretary, OfficeDeskStressed, OfficeCounter, OfficeShelfSupplies, CrateOfficeSupplies, ElectronicStoreComputers and CrateComputer. All use the existing server ApplicationCDLootWeight (default 1), without extra multipliers. Removed our entries from ElectronicStoreMisc and CrateElectronics. No changes to home desks, general warehouse cargo, native room mappings or unrelated items.

Native office/office-storage mappings supply the desks, counters, shelves and office-supply crates; warehouse offices using these room definitions are included. The warehouse cargo room itself uses industrial pools and is intentionally unchanged. This does not guarantee a CD in every warehouse, alter modded map definitions or identify actual map coordinates. Computer retail/stock pools provide another plausible source. The relative weight is not a drop percentage.

[TESTED OFFLINE] Focused program/UI/metadata fixtures and native-table integration (loading the installed distributions in host Lua 5.1) cover all eight pools, untouched unrelated pools, duplicate removal, repeated merges, weight replacement, zero/NaN, disabled Ledger mode and missing/malformed pools. The native table harness substitutes unused clutter helpers; it does not run native loot generation. Previous dev.1 full-suite results above remain historical and are not relabeled as dev.2 tests. This change does not touch installation, transfers, protocols or persistence.

Commands: `python -B tests/run_tests.py --only-program --pc-framework <paired-framework>`; `python -B tests/test_application_loot_native.py --game-root <installed-PZ>`; `python -B scripts/check_versions.py`; `python -B scripts/check_deployment.py`; `python -B tests/test_deployment.py`; `git -c core.safecrlf=false diff --cached --check`.

[RUNTIME GATE] Actual new-container loot rolls and dedicated MP are NOT TESTED. G7/stable G8 remain BLOCKED. No packaging, deployment or publication.

0.20.0-dev.2 source receipt: **228 files**, SHA-256 `2322f506ca6e72d1f35ab2908263820dc84aea683795d4982423d87da09cb356` (same sorted-source algorithm above; no package).
