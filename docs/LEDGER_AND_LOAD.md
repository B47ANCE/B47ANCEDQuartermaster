# Physical Supply Ledger and Dangerous Load

Project Version: 0.23.0-dev.1

Current addition: [Stock targets and multi-CD/Base Ledger views](STOCK_AND_BASE_LEDGER.md). Existing authority and historical evidence below remain distinct.
Current Sort workflow: default-on `SortUpdatesLedger` requires carried paper and pen/pencil, searches accessible loaded building storage for a completed covering ledger first, uses native pickup, accepts carried blank/unfinished fallback and writes confirmed touched storage once after the full successful job. It overrides the older Sort-only freshness/computer exception below while enabled. Shopping collection and computer application installation are unchanged. Movement 12 / Ledger 5 require matching peers. [Current implementation, boundaries and validation](SORT_LEDGER.md). Earlier checkpoint evidence remains historical.

Current application prerequisite: find and run the Quartermaster Application CD installer on each PC before computer ledger reads/writes or automatic knowledge provision (server opt-out supported). The Application CD is released after successful setup and is not required nearby afterward. Paper inspection does not need the app; Sort follows the default paper/writer policy above. Current capabilities are Ledger 5 / Movement 12. [Exact implementation, settings, validation and migration limits](APPLICATION_CD.md). Earlier checkpoint sections retain their original evidence.

Current reader: paper ledgers use a ruled clipboard with three columns and page-turn controls. Computers can show live stock and waive expiry only in the exact native building recorded by their CD. Off-site/outdoor computers and safehouse-wide CDs fall back to recorded history and ordinary freshness. Existing privacy, inspection, CD binding and native transfer boundaries remain. See [current policy and validation](CLIPBOARD_AND_LOCAL_COMPUTER.md).


Historical [0.17 ledger modes/freshness](LEDGER_FRESHNESS.md), retained when SortUpdatesLedger=false: manual inventory/container Sort is free; scoped Sort requires fresh knowledge. The physical inspection/conversion implementation below remains the baseline. Historical snapshots stay immutable; live statistics are separate ephemeral server projections. Prior dated artifacts/tests retain their actual versions.

## Implemented workflow

Sorting/Shopping collection now have a default-on server ledger requirement; details and current evidence are in [LEDGER_REQUIREMENT.md](LEDGER_REQUIREMENT.md). The production Supply Ledger is implemented: craftable physical media, server-owned inspections, native timed completion, persistence/recovery, CD copying and both readers. It replaces the inactive 0.13 prototype as the current implementation. Dangerous Load, Extended Categories interoperability, existing sorting/presets/priorities, movement protocol 10 and vanilla smaller transfer groups/timing are preserved. The shelf experiment remains out of scope. No game/server was launched; no local deployment or Workshop publication occurred.

The compatible MINOR Ledger baseline was implemented on `feature/building-supply-ledger`. The Windows ’93 UI followed on feature/windows93-computer. The current 0.15.0-dev.1 iteration branches from 4a9be2bf7ae664e49880158d996268ee56c61097 on `feature/ledger-required` and adds the [server-enforced requirement and stored-CD bindings](LEDGER_REQUIREMENT.md). It adds the [Windows ’93 desktop and deliberate application launch flow](WINDOWS93_COMPUTER.md), with movement 10, Shopping 2 and Ledger 2 peer capabilities; physical ledger schema stays 1, while drive bindings use a separate schema-1 registry. Parent PR #12 is not silently merged. The unrelated original checkout and prior packages remain untouched. The remote default branch's README-only difference is already represented in the feature ancestry; its older gameplay baseline is not the source for this change.

### Using it

1. Craft **Quartermaster Building Supply Sheet** by consuming one whole `Base.Notebook` (`mode:destroy`), plus one retained `Base.Clipboard` and a retained `Base.Pen` or `Base.Pencil`. The B42 in-hand native craft recipe creates one blank ledger. Loose pages are not accepted; recording and post-sort updates reuse the resulting ledger.
2. Carry the sheet and a writing implement. Right-click the sheet and choose **Record / resume building supply sheet**, or the safehouse option when a supported native safehouse contains the character.
3. The character walks through storage and performs a timed inspection for each physical compartment. Unconfigured storage is included. Cancel safely; completed records stay on the sheet.
4. Use **Read supply sheet** without electricity. It shows static room/container sections, actual quantities, exact FullTypes/condition, coordinates and each inspection's world-hour timestamp. Empty containers are shown. There is no paper search, filtering or digital sort control.
5. Right-click a supported powered desktop and choose **Use computer (Windows '93)**. Open **CD Writer**, choose the completed sheet and the vanilla CD, then choose **Write Supply Ledger CD**. The original paper is retained. One CD becomes one **Quartermaster Supply Ledger CD**; its original music/media identity is replaced.
6. Carry that disc to a supported powered desktop. Place the CD in accessible physical storage beside the computer. Open **CD-ROM (D:)**, select and load it, then double-click **QUARTERMASTER.EXE** or choose **Run application**. Desktop opening/insertion never auto-runs it. The embedded computer reader adds literal case-insensitive item/FullType search, an authorized room browser and pagination. It closes on power/reachability/possession loss. A remote/unloaded origin is historical data, not an instruction to load or inspect remote inventories.

The initial verified terminal identity is the stock desktop sprite `appliances_com_01_72` (`Base.Mov_DesktopComputer`). Other sprites are not guessed to be working computers. `Base.Disc_Retail` covers the verified vanilla music CD definition, including its different recorded-media instances. VHS tapes and other disc-like or modded media are not accepted by resemblance. These are explicit compatibility limits, not stubbed actions.

## Server sandbox settings

| Stable option | Default | Bounds | Meaning |
| --- | --- | --- | --- |
| LedgerBaseSeconds | 10 | 0–120 integer | Charged once, at the first confirmed inspection |
| LedgerContainerSeconds | 5 | 1–15 integer | Per successfully inspected physical compartment |
| LedgerEntrySeconds | 1 | 1–5 integer | Per distinct conservative stack-equivalent recorded entry |
| LedgerBurnSeconds | 30 | 10–120 integer | Native CD-copying action |

Duration is calculated by the server from actual prepared contents: uncharged base + compartment time + entry count × entry time. A client cannot supply a smaller count/duration. The class uses 50 native action units per nominal second, matching inspected 20 ms native timing conversion. Native timing modifiers and walking remain additional; actual fast-forward/health/modifier timing needs native acceptance. Confirmed actions follow the native clock rather than an invented wall-clock multiplier. Unconfirmed offers expire after ten seconds. No setting overrides native carrying capacity, penalties or transfer timing.

All 29 supported locale folders contain the established English fallback UI/Sandbox strings plus ItemName/Recipes JSON. This is fallback parity, not a claim of 29 human translations. Stock game icon/model references (Notebook/EmptyNotebook and Disc/Disk) are used; no new image assets or external mod files are distributed.

## Physical scope, inspection and counting

[VERIFIED SOURCE] `LedgerScope` derives the selected building from the character's native BuildingDef and RoomDef bounds/IDs. Safehouse scope uses the authoritative native list, exact house identity/bounds and exposed native cell floor range. No client radius/geometry is trusted. Native getGridSquare reads only loaded world state. Missing chunks produce an incomplete snapshot; no fake complete claim is made. Safehouse scanning starts on the character's floor.

Discovery advances at most 32 cell/object/compartment steps per request and exposes a reachable candidate as soon as it is available. Pending discovered work is chosen by deterministic nearest distance/floor cost; it does not preplan the whole building or alter sorting routes. Native `luautils.walkAdj`/the native walk action performs navigation. The server separately checks native `canReachTo` and adjacency at inspection, start and completion. A failed walk stops after three retries. Adjacent compartments avoid redundant walking.

Eligible sources are current exact physical object/compartment references through Targets.make/valid, native safehouse loot checks and Rooms discover/inspect authorization. Floor inventories, world inventory objects, dropped bags, player inventories and nested carried inventories are excluded. The analyser enumerates top-level contents; a contained bag is one item with native weight, never a second recursive inventory count.

ContentAnalysis reads at most 64 native records per step and detects changes to reference, containment, ID, FullType, name, count, condition, weights and canonical category. Timing uses conservative aggregation: same FullType/name/condition/weight and bidirectional native CanStack, with no merging of food, drainables, fluid containers, inventory bags, recorded media or item ModData. Sealed ammo boxes stay boxes. At native completion the server makes a final non-yielding bounded pass against the retained exact references. A change requires reinspection; it is not credited as a completed record. Per-container completion is recorded with its own timestamp; the building-wide document is **not an atomic whole-building snapshot**.

Resource guards: 256 native room bounds, 262,144 scope cells, 512 objects per tile, 100 compartments per object, 4,096 compartments, 4,096 item instances per analysed container, 4,096 distinct rows per compartment and 32,768 rows per sheet. Oversized work returns an explicit limit error instead of truncating or claiming completion. These are internal resource limits. Very large single-container ammo inventories exceeding the instance limit require a smaller physical inventory before recording; no item is changed by a refusal.

## Native action authority

`LedgerAction` registers one shared native class on server and clients. Its constructor serializes only `(character, token)`. The server retains the exact action, actor, physical container/media, content analysis and authoritative duration. Constructor reconstruction is single-use and time-bounded. A serverStart challenge must be confirmed through the existing authenticated OnClientCommand transport by the actual player; constructor character alone is insufficient. Native progress must be finite and complete before multiplayer mutation/record credit. There is no client complete RPC.

Access, scope, exact target/position, reachability, paper possession and writing implement are rechecked. CD completion also rechecks the actual selected CD, its protection/removal flags, exact computer, power, current access and completed paper. User cancellation, native stop, death, disconnect, object removal, ownership or permission changes invalidate affected grants. Existing sorting/shopping and ledger mutation jobs do not start over each other. A stale UI/confirmation callback cannot cancel a newer job or another local actor.

Gameplay intent uses a separate ledger capability family 3 on the existing Quartermaster request transport, with bounded per-player rates. Movement capability 11 and Rooms 4 distinguish the new scoped requirements; native inventory transfer grouping is unchanged. Require this new build on server and clients to use the new definitions and class. Native hooks are source-verified and exercised in host fixtures; actual dedicated execution is a separate gate.

## Persistence, resume and CD conservation

Server-only `B47ANCEDQuartermasterLedger` ModData schema 1 stores snapshots, native item-ID bindings, sparse conversion journals and opaque output associations. Physical media contain only a small schema/snapshot reference/completion flag, never full private inventories. Possession plus the server binding is required; editing an item ModData snapshot ID does not grant access. Paper/discs remain normal carryable/tradeable native items. Future/corrupt registry/schema data fails closed without resetting saves.

Each inspection replaces one compartment record without duplicate order entries. Records are arranged by room and physical location; timing remains per actual inspection. Completed snapshots are immutable. Missing/replaced storage yields stale status; unloaded coverage yields partial status; access limitations are marked without hidden names/counts. Idle unfinished jobs expire after 30 minutes while confirmed native work is retained until its own completion/stop. Persistent completed records survive cancellation/reconnect. After server restart or uncertain object identity, missing weak native-reference evidence forces reinspection rather than trusting a copied object marker. Base preparation is not charged again. Earlier records remain readable historical evidence until replaced by confirmed reinspection.

Conversion uses vanilla server-side instanceItem/AddItem/Remove and inventory synchronization, inside native complete after validation. Output capacity/item admission is checked. A per-input journal is established before native mutation, including the expected output ID. Only exact live native membership proves removal: ItemContainer.Remove can leave a stale getContainer pointer. Definite failure with a retained original CD rolls back the exact inserted output. Native notification failure after a known commit is reported as synchronization pending, never replayed as another conversion.

Recovery removes a definitely owned uncommitted output only when the original input is also definitely present. Already committed output bindings can be restored. Absent inventory IDs are **not proof** that an item was consumed: traded/missing/unknown outcomes remain locked, preserve existing items and do not automatically respawn, delete or retry media. A process/host/storage crash is not claimed to be an atomic transaction across the game's separate save streams. Test real save/restart and item conservation on the dedicated server. Registry bounds are 2,048 sheets and 8,192 input journals; unknown references are retained rather than garbage-collected against real saves.

## Portable history and privacy

Loaded origin squares use the existing public native safehouse and Rooms inspect checks. Unloaded origin history uses a stricter native current-safehouse membership + playerAllowed check, then Rooms' own schema-2 validated registry/geometry/private-storage policy helpers (API 1, feature checked). Quartermaster does not clone policy logic or create a second room registry. Missing/unavailable/future helpers fail closed. This path grants **historical disclosure only**, never physical discovery, deposit or withdrawal authority. Tests use actual Rooms source at commit 62de4839564ea4c1afff2c51171322286d055daa. Rooms production files are untouched.

Each page reauthorizes records and withholds inaccessible room names, contents and quantities. Network pagination uses server-owned opaque continuation tokens and opaque revision tags; raw row/container ordinals and hidden totals are not exposed. At most 128 candidates, 32 result rows and 16 authorized room labels are processed/returned per request, with a conservative 16 KB text budget. Room selection/search affect only historical presentation. The reader refreshes authorization periodically without refreshing stored contents; redacted room choices are cleared. Previously learned information cannot be erased from a player's memory or an earlier copy. No absolute timing-side-channel guarantee is claimed.

## Production files and native evidence

New runtime modules: Ledger.lua, LedgerAction.lua, LedgerMedia.lua, LedgerScope.lua, LedgerAccess.lua, client LedgerUI.lua, shared B47ANCEDQuartermasterLedger.lua; plus media/scripts/b47_supply_ledger.txt and 58 ItemName/Recipes fallback files. Authority/Protocol wire the new family; ContentAnalysis adds condition validation. Existing sandbox/translation/source manifests and current documentation/version mirrors are synchronized. The 0.13 domain model remains historical outside runtime/current acceptance.

The dated [native evidence](LEDGER_NATIVE_EVIDENCE_2026-10-16.json) binds installed game/JAR/native Lua/script fingerprints, signatures and findings. Installed target is 42.21.0, Steam build 25485521. No Java runtime mod, bytecode patch, third-party classifier, copied assets or external mod edits are introduced. The [0.14.0-dev.1 development artifact receipt](LEDGER_ARTIFACT_2026-10-16.json) binds that earlier source/package, not this UI iteration. Version 0.15.0-dev.1 is source-only, with 206 declared runtime files and no package/deployment/publication; see its [current validation report](WINDOWS93_COMPUTER.md). Earlier packages/evidence keep their original versions and gates.

## Validation and remaining acceptance

[TESTED OFFLINE] Lua 5.1/Lupa production service/action and UI fixtures, including installed native base action/ComboBox Lua and actual Rooms integration. Coverage includes 200-round aggregation; distinct quantities and empty compartments; server duration; paper retention; no paper search; static timestamps; changed-content refusal; partial/resume; safehouse bounds; exact reachability; power loss; rollback and unknown-outcome locking; CD conservation; literal 5.56 search; delegated privacy with unloaded origins; native constructor/challenge/actor/replay checks; opaque paging; resize/footer/controller close; explicit CD selection and 29-folder metadata fallback parity. These are not game execution or pixel/latency evidence.

The earlier physical-ledger baseline used these commands (including packaging). Its exact receipt remains dated/versioned above. Current source-only UI validation commands are in [WINDOWS93_COMPUTER.md](WINDOWS93_COMPUTER.md); no current package or release validation is claimed. Python is the host runtime with Lupa; the installed native audit helper also uses host-only Jawa:

```powershell
python -B scripts/check_versions.py
python -B tests/run_tests.py --require-rooms --rooms 'C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDRooms' --package
python -B scripts/check_native_categories.py --game 'E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid' --output dist/diagnostics/native-categories.json
python -B scripts/check_deployment.py --package
python -B tests/test_deployment.py
python -B scripts/check_versions.py --release
git -c core.safecrlf=false diff --check
```

[UNKNOWN / NOT MEASURED NATIVE] Native first-movement latency, actual inspection/burning seconds with modifiers/fast-forward, network bytes, frame/server tick impact, lifecycle/save ordering under a process crash and large-base throughput. No native performance gain is claimed from host fixtures. Safehouse/building coverage is limited to loaded native storage; oversized work is explicitly refused. Native rendering/controller/font acceptance remains required.

[RUNTIME GATE] **G6 native client NOT TESTED; G7 dedicated multiplayer NOT TESTED / BLOCKED; stable G8 BLOCKED.** Required live cases: craft/retain pen; paper trade/drop/pickup/save; record 20/100 containers and large ammo; cancel/rejoin/restart/reinspect; changed/removed storage; computer walking/grid/generator/power loss; explicit CD overwrite and exact counts; two-client concurrent burns/inspections; permission revocation/private-room ownership; portable read at an unloaded origin; native constructor/stop/clock behavior and actual UI scaling/controller. Implementation is ready for these tests, not claimed accepted. No live deployment or Workshop publication is authorized by this development pass.

## Current desktop integration

The required B47ANCED PC Framework now hosts the computer desktop and reusable drive engine. Quartermaster supplies the ledger reader, ComputerWriter and authoritative data/privacy adapters. Supported hardware is the four verified vanilla PC orientations or placed tiles declaring exact CustomName=Computer metadata; the one-facing initial implementation above is historical. Use paired framework 0.3.0-dev.1 for the preserved CRT/taskbar. Paper opens a portrait clipboard with scroll-aligned rules and three-line selection details. [Integration](PC_FRAMEWORK_INTEGRATION.md) / [current UI evidence](CLIPBOARD_UI_FIX.md).
