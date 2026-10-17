# Physical Shopping Lists

Project Version: 0.18.0-dev.5

Checkpoint dev.2 changes only the container-save window workflow. Physical-shopping code and its dev.1 full-suite/native-source evidence are unchanged; see [the focused current checks](MULTI_CONTAINER_UI_IMPLEMENTATION.md).

Compatible feature iteration from 0.15.0-dev.1, with an explicit default-on workflow change. Old personal data is preserved. This implementation is now distributed in the 0.16.0-dev.2 Workshop MP testing build; see [the exact publication receipt](WORKSHOP_TEST_0_16_0.md). Native and dedicated acceptance remain pending.

Ledger mode Disabled bypasses collection knowledge and hides supply-ledger/CD/computer controls, while physical Shopping Lists and their writing-supply settings remain independent. [Current policy](LEDGER_FRESHNESS.md).

## Player workflow

1. Carry a native Notebook (`Base.Notebook`), a supported pen/pencil and a **blank** sheet (`Base.SheetPaper2`). Written/tagged, favorited, equipped or crafting-consumed paper is not a creation input.
2. Open Shopping, choose **New List...**, enter a name and complete the short native action. Exactly one sheet becomes one named `B47ANCEDQuartermaster.ShoppingPaper`. Notebook and writing tool remain.
3. Pick a carried paper from the dropdown. Add/remove quantities and supported recipe requirements as before. Rename uses the selected paper's revision. Reading does not require writing supplies; editing that paper does.
4. Create additional papers deliberately. Transfer a paper through normal vanilla inventory/trading to give its plan to another player. The holder can select/read it, and edit with supplies. Former possession confers no continuing server read/edit/collection permission.
5. Hold a paper in either hand for the small notebook-style HUD. It shows qualifying carried quantities, targets and remaining demand. More than eight visible rows turn pages every six seconds. It neither captures mouse/keyboard input nor changes native inventory or the current-action bar.

The server accepts the verified native Notebook and Pen/Pencil families (including the inspected colored/fancy/Spiffo variants). Arbitrary modded writing tools/notepads are not assumed compatible. A separate blank sheet is required; this feature does not silently remove notebook pages or consume a notebook.

Reading/collecting needs no notebook or writing tool. **Collect still requires a fresh completed supply ledger covering the location, or an authorized powered stored-CD computer**, unless the server disables that separate requirement. A shopping paper is not a building inventory ledger. Dibs! Wanted/Needed personal goal editing remains separate; adding their demand to a shopping paper requires supplies and the selected paper.

## List semantics and old data

Each paper has its own manual targets, recipe projects, preferences, linked-demand targets, duplicate receipts and revision. Native FullType identity and the existing allocator remain unchanged. Carried credit is calculated for the current holder under that list's preferences, not copied from the previous holder's carried counts. Historical `collected since edit` belongs to the list and is never used as carried credit.

Linked Wanted/Needed target values are written onto the selected paper when added/imported. They travel with that paper and do not silently adopt the recipient's personal goals. Their provenance rows remain visible and removable by the recipient with writing supplies. Personal goals remain personal. Re-add a goal to deliberately write its updated target; existing duplicate-confirmation behavior still applies. Recipe alternatives, reusable tools and supported cooking portions continue through the existing requirement resolver. Unsupported requirements still fail explicitly.

The old account shopping plan is **not erased** and is not silently usable without paper in physical mode. **Import Old List...** consumes one blank sheet and explicitly copies that plan, including projects/preferences/linked target intent, once. The existing pre-schema-2 outstanding-demand migration runs before import when needed; its historical demand is not invented. Import is committed only with a successful physical creation. Its original account record is retained as a backup. No physical item is spawned just by opening or reading the menu.

Switching back to personal mode exposes the retained account plan, not an automatic merge of multiple paper plans. Paper records remain stored. This opt-out is not a promise that an older mod binary can load a save containing new ShoppingPaper items. Preserve a pre-upgrade save for a binary downgrade.

## Authority, storage and synchronization

- Server-only `B47ANCEDQuartermasterShoppingPapers` ModData, schema 1, owns profiles and creation journals. Native paper ModData contains only `{schema=1,id=opaque UUID}`. The registry additionally binds the exact native item ID; copied client markers do not create valid lists.
- `Personal.account` retains original account goals/data. `Personal.identity` projects the selected, currently carried paper's shopping fields into the existing production allocator. A carried paper is the capability; the creator has no permanent remote access.
- Server commands authenticate the requesting player and check actual carried ownership. Mutations also check writing supplies, exact selected paper ID and the list revision. Read requests for a held paper use a temporary context and never change the menu selection.
- Creation reuses the existing native ledger-action constructor `(character, token)`, sender-bound server grant, authenticated challenge and finite native-progress completion check. No client completion RPC creates paper. One exact blank is exchanged for one registered output at the native server completion boundary. Definite retained input rolls back the exact output. Uncertain outcomes remain locked and never mint a replacement.
- Native add/remove notifications synchronize the physical exchange. Native item-field synchronization supplies renamed paper fields. The new registry is not broadcast to all players: only an authenticated current holder receives a requested list snapshot.
- A collection run captures paper identity and revision. New planning/TAKE grants recheck actual possession and revision. Losing/trading/editing the paper stops new grants. Completed native observations, cancellation and safe-return paths remain possible. The actor must still satisfy existing container/safehouse/Rooms permissions and the separate ledger gate.
- Paper items are excluded from automatic sorting/collection in physical mode, preserving the carried list. Manual vanilla transfers/trading remain available.
- Personal protocol **2**, Shopping **3**; matching peers/reconnect required. Ledger **3**, movement **11**, Rooms **3**, existing ledger schema **1**, drive schema **1** and sorting rules remain unchanged. No Java, external mod code or assets were added.

Vanilla native transfer execution remains the final movement authority. Lua cannot retract an already dispatched native transfer or lock unrelated manual vanilla actions; no such protection is claimed. A completed transfer is never undone solely because the paper was handed off afterward.

## Server configuration and bounds

| Sandbox option | Default | Behavior |
| --- | --- | --- |
| `PhysicalShoppingLists` | true | Use carried papers; false restores the previous personal workflow without deleting either format. Missing values on existing saves use true. |
| `ShoppingWritingSupplies` | true | Notebook plus pen/pencil for creating/editing physical lists; false removes those retained-tool requirements. Creation still consumes a blank sheet. Ignored in personal mode. |

Both use stable IDs and all 29 existing locale folders contain the established English fallback keys. This is fallback completeness, not human translation.

Implementation-only limits bound request/storage work: 4,096 inspected carried instances, 16 nested bag levels, 64 carried lists, 64-byte names, 256 requirements/source entries inherited from the current allocator, and 8,192 server creation records including failed/cancelled journal history. These are safety limits, not transfer speed/gameplay tuning. An exhausted/corrupt/future registry fails closed without deletion. No automatic journal pruning is implemented.

The HUD checks held-item identity at most every 250 ms and requests at most one in-flight snapshot per player every 1.5 seconds. It performs no nearby-container/catalog scan in rendering. Drawing uses original Lua geometry, including ruled paper and an uneven top edge. Native smaller transfer groups/timing, carry planning, sorting routes and Auto Clean remain unchanged. No native frame-time/network-throughput measurements are claimed.

## Evidence and validation

**[VERIFIED SOURCE]** Installed PZ **42.21.0**, Steam build **25485521**, jar SHA-256 `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`. Native Lua confirms Notebook/SheetPaper2 definitions, blank-page checks, hand-item access, item naming, ComboBox `setEnabled`, and player-scoped non-capturing UI methods. Native read-only inspection corroborates the server branch of `InventoryItem.syncItemFields()`. Exact portable fingerprints are in [the dated evidence record](SHOPPING_PAPER_NATIVE_EVIDENCE_2026-10-16.json). The existing source-verified native action/creation mechanics are reused with new production-path fixtures; older evidence is not relabeled as new runtime proof.

**[TESTED OFFLINE]** Production handlers and engine-shaped Lua fixtures cover materials retained/consumed, written-sheet refusal, native action sender/challenge/replay, stale/missing list IDs, two independent lists, trade, former-holder refusal, per-holder carried credit, frozen linked demand, explicit one-time import and backup preservation, corrupt/future schemas, rollback, loss before TAKE, completed withdrawal credit, cancellation and supported opt-out. UI/HUD fixtures cover writable/read-only controls, lower-revision independent lists, font/geometry cases, either hand, single-panel identity, bounded reads, late callbacks, pagination and unequip/death/disconnect cleanup. These are host tests, not PZ execution or pixels.

Exact validation commands from the `feature/physical-shopping-lists` worktree (configured host interpreter with Lupa Lua 5.1):

```powershell
$python = 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
$env:PYTHONUTF8 = '1'
& $python -B tests/run_tests.py --require-rooms --rooms 'C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDRooms'
& $python -B scripts/check_deployment.py
& $python -B scripts/check_versions.py
git -c core.safecrlf=false diff --check
```

Source manifest: **209 runtime files**. The original source-only checkpoint produced no package. The later authorized 0.16.0-dev.2 distribution has package/source/stage and release-version checks PASS; see its version-bound publication receipt.

**[RUNTIME GATE] G6 NOT TESTED:** native create/cancel with pen loss and bag movement; physical item/icon/name display; mouse/controller picker, naming dialogs, resized/large-font menus and held HUD placement during play.

**[RUNTIME GATE] G7 BLOCKED / NOT TESTED:** dedicated server with two remote clients; simultaneous editing/handoff, stale revisions, ownership lost during walking/native transfer, current holder credit, native add/remove/name synchronization, disconnect/rejoin, native save/restart, partial/cancelled creation, exact item conservation and no unauthorized disclosure/movement. Host fixtures do not prove these cases on a server.

**G8 stable release BLOCKED.** The source-implementation checkpoint itself did not package or publish; the later authorized dev.2 MP test distribution is recorded separately. No local deployment, game/server launch or stable-release claim was made.
