# Required Rooms dependency

Project Version: 0.19.0-dev.1

## Current development iteration

Rooms remains required. Vehicle/nested sources repeat existing safehouse/Rooms
access checks. Current allocation metadata uses designated-only Rooms capabilities
and the paired 0.2.0-dev.6 provider tests. Update all Quartermaster peers together:
movement 11, personal 2, shopping 3, ledger 3, Rooms 4, load-policy 1,
configuration 6, presets 3 and allocation 1. Auto Clean remains separate.
Enforcement/live allocation routing remain disabled. See
[integration and evidence](ALLOCATION_INTEGRATION.md).

Current source still requires Rooms. Auto Clean is now a separate consumer requiring Quartermaster SupplyAPI 1 and Rooms, described in [SUPPLY_API.md](SUPPLY_API.md). The bundled Auto Clean statements below describe the historical 0.9/0.10 publication.

The dependency/publication record below is historical to 0.9.0-dev.1; current SP support is documented in [CLEAN_BUILDING_SINGLE_PLAYER.md](CLEAN_BUILDING_SINGLE_PLAYER.md). Rooms remains required.

The user explicitly replaced the optional-Rooms contract with a required
dependency for Quartermaster and Auto Clean. This is a breaking 0.x dependency
change, advancing 0.8.0-dev.1 to 0.9.0-dev.1. It does not change save/registry
schemas, network protocol versions, recipes or authoritative mutation guards.

Quartermaster Mod ID B47ANCEDQuartermaster now declares exactly one native
dependency: require=B47ANCEDRooms in 42/mod.info. Minimum game version 42.21.0
matches Rooms. Steam Workshop item 3807217050 now lists Rooms item 3820077442
under Required Items, selected and saved through the authenticated owner UI.
The visible item page confirmed B47ANCE'd Rooms beneath the Required Items label.

Auto Clean / Clean Building is embedded in this Quartermaster Mod ID and item;
there is no separately packaged Auto Clean Mod ID or published item in this
workspace. These two dependency declarations therefore cover both features.
No new Auto Clean item was created. Rooms itself remains independent of
Quartermaster; no reverse dependency or cycle was introduced.

Subscribe to both items and enable B47ANCEDRooms and B47ANCEDQuartermaster on
the server and every client. Workshop Required Items is the distribution link;
the native mod.info declaration supplies the game's mod dependency. Dedicated
operators must still include both items/mods in their intended configuration.
No server configuration, restart or local SP deployment is performed here.

[VERIFIED source] Installed Steam build 25485521, Build 42.21: the native
ChooseGameInfo.readModInfoAux parser recognizes require=, and vanilla
ModSelectorModel.lua consumes modInfo:getRequire() at lines 121, 142, 408 and 409.
This is metadata evidence; it does not prove native enabling/load order or
dedicated acceptance. A fingerprint-only observation was recorded in the local
API audit library. No custom Java/JAR code was implemented, built or required.

[TESTED offline] Full source/build checks, 83 guard/transport/building/startup
scenarios and 141-file source/package/stage parity pass. Packaging now rejects
missing, wrong and duplicate require declarations, with disposable regression
fixtures. The exact previous 0.8.0-dev.1 ZIP, hash and provenance were preserved
under dist/history/0.8.0-dev.1-required-rooms-predecessor before rotation; prior
runtime/research evidence keeps its original version and scope.

Validation commands from this repository, using the configured Python runtime:

```
python scripts/check_versions.py --root .
python tests/test_deployment.py
python tests/run_auto_clean_building.py --source --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --rooms ../B47ANCEDRooms
Build-Workshop.ps1 -WorkshopRoot <isolated-workshop-staging-root>
python scripts/check_deployment.py --package --stage <isolated-stage>
python scripts/check_versions.py --root . --release
```

Canonical Workshop prose remains WORKSHOP_DESCRIPTION.txt and
WORKSHOP_CHANGE_NOTE.txt, rendered into an immutable VDF by
Prepare-WorkshopVdf.ps1. Fresh manifests and actual upload/download receipts
belong under ignored dist/workshop-publish/0.9.0-dev.1-required-rooms/.

[VERIFIED distribution] Published 0.9.0-dev.1 from public source commit
247ec7b11f14f03b902082704b83eb35882aa448 to existing Workshop item 3807217050.
SteamCMD reported successful upload and fresh download. All 141 downloaded
runtime files exactly match the source/stage/package SHA-256 inventory,
including require=B47ANCEDRooms and modversion=0.9.0-dev.1. Package SHA-256:
e1fd0d6365d4b6ac3caa18fb34fad28584602b4f82383794e78ca5a3c08aa80b.
The live public description matches the canonical text, visibility remains
public, and the owner page still shows Rooms item 3820077442 under Required
Items after upload. Steam desktop was gracefully restarted and its process
verified. These observations prove distribution only; no game/server was
launched and no dedicated configuration was changed.

[RUNTIME GATE] Native enabling and load-order behavior, SP UI, real save/load,
dedicated joins/rejoins, observers and server restarts remain NOT TESTED. G7
BLOCKED / NOT TESTED; stable G8 BLOCKED. Single-player was disabled in 0.9.0-dev.1 and is now enabled through the guarded local adapter. The source's conservative cross-level footprint restriction remains
intact and can skip many or all targets. No game/server launch is authorized.
