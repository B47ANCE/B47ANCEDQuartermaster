# Multi-container editor implementation

Project Version: 0.21.0-dev.2

Current iteration: [Dangerous Load, ledger boundaries and validation](LEDGER_AND_LOAD.md). Existing SupplyAPI, Rooms permissions and container configuration contracts are unchanged.

## Current development iteration

Successful Save keeps the main Quartermaster editor/session open and retains the selected container. Acknowledged originals/revisions are updated and the rail's dirty badges refresh. Select another rail entry to continue; a clean repeat Save makes no new configuration write. Close/Cancel still closes explicitly and discards only unsaved edits. Preset save dialogs retain their existing close behavior. If a Whole Container save invalidates the currently displayed inherited child, reload that child before rebinding; failed reloads disable the stale selection and show the server error. Partial-save errors and dirty failed records remain available.

[VERIFIED SOURCE] The previous successful-save callback explicitly called `closePicker`; removing that close is the behavioral fix. Server `Session.save`, commits, permissions, schemas, protocols and shared gameplay configuration remain unchanged. This is local UI workflow, so no server sandbox option was added.

[TESTED OFFLINE] The modified integration test failed before the fix with `Save closed the editor/session`, then passed. Cases include saving two different containers in one window, selected-record/session continuity, clean repeat Save, explicit Cancel after a successful save, existing conflict/partial-save tests, preset dialogs, and reloading an inherited section after a Whole Container commit. Lua 5.1 syntax and the related UI/Whole Container/physical Shopping fixtures pass. The preceding physical-shopping full regression evidence remains tied to 0.16.0-dev.1; this checkpoint ran the focused suites below.

Exact host check (from the repository root):

```powershell
$env:PYTHONUTF8='1'
@'
from pathlib import Path
from lupa.lua51 import LuaRuntime
r=Path.cwd()
def runtime():
    lua=LuaRuntime(unpack_returned_tuples=True); g=lua.globals()
    base=r/'src/B47ANCEDQuartermaster/42/media/lua'
    g.package.path=(base/'client').as_posix()+'/?.lua;'+(base/'shared').as_posix()+'/?.lua;'+g.package.path
    g.TEST_ROOT=(r/'tests').as_posix()
    g.GAME_ROOT='E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid'
    g.ROOMS_SOURCE='C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDRooms/src/B47ANCEDRooms/42/media/lua'
    lua.execute("package.loaded['B47ANCEDQuartermaster/Progress']={start=function() end,clear=function() end};getActivatedMods=function() return {size=function() return 1 end,get=function() return 'B47ANCEDQuartermaster' end} end")
    return lua
for p in (r/'src/B47ANCEDQuartermaster/42/media/lua').rglob('*.lua'):
    runtime().execute('assert(loadstring(...))',p.read_text(encoding='utf-8'))
for name in ('test_container_ui.lua','test_ui_framework.lua','test_dev26_furniture.lua','test_shopping_paper_ui.lua'):
    runtime().execute((r/'tests'/name).read_text(encoding='utf-8'))
'@ | & 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -B scripts/check_versions.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -B scripts/check_deployment.py
git -c core.safecrlf=false diff --check
```

[RUNTIME GATE] Native client input/visual acceptance NOT TESTED: Save a container, switch to a second container in the rail, save it, then close manually. Also check inherited sections and partial/conflict messages on the server. This UI-only change does not satisfy or reset the branch's pending gameplay G7/stable G8 gates. The later authorized 0.16.0-dev.2 Workshop MP test publication is [recorded separately](WORKSHOP_TEST_0_16_0.md); no local deployment or server changes.

Implementation date: 2026-09-28. [TESTED: offline] Lua 5.1 host fixtures and installed Quartermaster 0.24.0 Picker integration. [RUNTIME GATE] SP, hosted, remote client and dedicated server are NOT TESTED. This is a development candidate, not a release-readiness claim.

## Scope and source map

The preceding [audit](CONTAINER_SELECTOR_AUDIT.md) found no server-authoritative Quartermaster box-settings API. This implementation adds a narrow authority adapter instead of calling the client-only setters repeatedly. It preserves Quartermaster's native persistence/routing semantics and reuses its coordinate registry commands; upstream files remain untouched.

| Module under `src/QuartermasterSorting/42/media/lua` | Responsibility |
| --- | --- |
| shared/QuartermasterSorting/Targets.lua | Eligibility, range/building discovery, native SpriteGrid sibling resolution, descriptors and revalidation |
| shared/QuartermasterSorting/Configuration.lua | Four-field value copies/equality, payload validation, native read adapter |
| shared/QuartermasterSorting/Authority.lua | Server/SP sessions, opaque session/target tokens, conflict checks, native field writes and acknowledgments |
| client/QuartermasterSorting/Session.lua | Lazy originals/working records, explicit sibling staging, independent dirty-target commit, Cancel |
| client/QuartermasterSorting/MultiContainer.lua | Rail, toolbar, target switching, copy/paste, per-target priority/count, Save/X/controller binding |
| client/QuartermasterSorting/Adapter.lua | Existing hierarchy/input adapter, invokes the new extension on real game surfaces |

No scope, session, rail, mod-group or dirty field is stored in world ModData. The existing LSBox, LSBoxItems, LSBoxPresets and LSBoxPriority names are unchanged. Disabling this mod leaves ordinary Quartermaster configuration. Runtime removal/save/restart proof remains pending.

## Sandbox and discovery

`media/sandbox-options.txt` declares server sandbox namespace `QuartermasterSorting`:

- ContainerRange: integer 1–30, default 10, same-floor Chebyshev distance from the **opening container**.
- WholeBuilding: boolean, default false; registered building rooms/floors supersede range. No building falls back to the same origin/range.

All 29 language folders contain matching UI and Sandbox JSON keys with English fallback. Defaults apply to existing saves lacking the new namespace. There was no old patch sandbox namespace to migrate. Upstream sorting-travel options are not altered or reused as editor discovery settings.

Open/manual Refresh scans only loaded squares; neither selection nor drawing rescans the area. The opening target is inserted first and initially selected. Other targets are ordered by floor/Y/X/object index/container index, deduped by actual ItemContainer. Building iteration uses BuildingDef room definitions and loaded IsoRoom squares, with actual building-definition equality; it does not use BuildingDef:getSquares or bounding-box membership. Separate basement definitions and player-built extensions without engine membership are not guessed into a building. Loaded-only discovery is explicitly described in sandbox text and Refresh status. Large-building native responsiveness remains a runtime gate; discovery currently runs synchronously on open/Refresh, not in a per-frame work queue.

Eligibility is conservative ordinary square-object storage with an indexed-container roundtrip. Ground, item-owned/nested bags, vehicles and static-moving corpses are excluded from new discovery. Native lock and safehouse permissions are checked, including directly on the authority side rather than relying on Quartermaster's client-only helper. Invalid/unloaded targets fail closed. This is intentionally narrower than every target an upstream context branch might incidentally expose.

## Rail and editor

Uses native ISScrollingListBox/ISButton primitives with ContainerButtonIcons and the shelf fallback. Highlighted selection, hover state, tooltips (name, coordinates, compartment), a visible unsaved `*`, scrollbar/wheel navigation and controller rail focus are implemented. The editor remains one instance. **Containers** focuses the rail; A selects; B returns. Existing editor bumper/mouse/keyboard mappings remain. The new toolbar joins the picker joypad focus rows.

Selection captures current working data, lazy-loads a server snapshot once, rebinds the same editor's native selection tables and target references, resets cached contents/range state and updates title, priority and effective selected count. Catalog provider reads are memoized once per editor; a model is rebuilt for the selected target rather than creating editors for every discovered container. Per-target model `introduced` provenance is preserved through switches. Filters/search preferences remain shared; their results/count belong to the selected target.

Native preset links are staged. Quartermaster's global preset **definition** editor remains separate and keeps its existing semantics: saving a preset definition is global and is not undone by Cancel of the container session. This distinction is disclosed in the README. Source-only label/layout verification is not evidence of native clipping or controller correctness.

## Whole Container

Whole Container resets OFF on each actual target switch and is hidden when fewer than two eligible sections resolve. Checkbox toggling and ordinary item/category/bulk clicks do not propagate. **Apply to Siblings** deliberately clones the entire selected working configuration, including priority and preset generation values, to eligible sibling working records. No world writes happen at Apply. Later selection of a sibling resets scope and can independently override it. Final Save does not replay an old Whole Container operation.

Uses `getSpriteGrid()` and `getSpriteGridObjectsIncludingSelf(ArrayList.new())`. Candidate objects must have the same grid-relative physical origin; ambiguous duplicate cells reject the group. All eligible indexed compartments of accepted members are included, decorative members excluded, source retained. Gridless standalone targets remain singletons. Rotations/levels follow grid metadata, not tile-name or adjacency guesses. This adds checks around the native resolver's shared-grid/footprint behavior; it does not invent an assembly UUID or claim malformed/modded furniture support was runtime-tested.

Sibling records outside the visible rail can remain in the session and participate in Save/Cancel. Area discovery does not expand just because Apply includes a physical sibling. Server load/commit checks authorize such targets only through a valid registered source's current native sibling set.

## Session and authority

Client records are keyed by ItemContainer reference with a session-local numeric presentation key; names are never identity. Server open validates an ordinary opening target within three tiles and on the player's floor; it binds actual object/container references in a per-player session. This three-tile interaction bound is an internal anti-remote-open safeguard, not the configurable discovery radius. The origin must remain valid, at the opening location and near the player for operations. Session timeout (30 minutes), callback timeout (15 seconds), packet-size validation and payload type limits are technical safeguards, not gameplay tuning options.

Client sends the `QuartermasterSorting` module with open/load/commit/close commands and request tokens. Requests include the actual selected player number. Server handlers use the authenticated event player, never a client-supplied player identity. Lazy load resolves a coordinate/object-index/container descriptor and returns an opaque target token and copied configuration. Thereafter commit uses the server-bound references; removal, replacement, container-index mismatch or movement fails validation. Initial descriptor resolution still depends on client/server world synchronization before the token is issued; this is a dedicated-server gate, not a persistent identity guarantee. The inspected engine entity ID is position-derived, so it was not substituted as an invented immutable GUID.

Commit revalidates origin, target permissions/locks, range/building or native sibling authorization and the unchanged four-field original snapshot. New preset links must resolve against the authoritative preset store. It rejects unexpected fields, invalid sets, nonintegral/out-of-range priority, malformed names and oversized configuration. The adapter writes all four native fields coherently on the server/SP authority, copies each target's sets independently, transmits object ModData once and calls Quartermaster's addCoord/removeCoords path. No client writes or client fallback are used by this editor. No upstream client/Core module is loaded on a dedicated server.

Unchanged targets are not written. Save commits dirty records serially with per-target acknowledgments, not as a claimed all-or-nothing batch. Successful originals are updated; failed/conflicting records stay dirty with an error. A timeout reports uncertain outcome, not success. Retrying is checked against the server's current baseline; subsequent unrelated edits cause conflict. The protocol is not a durable transaction log, and restart/reconnect discards transient sessions. World configuration remains in native ModData and registry channels. If a transmit/registry call throws after mutation, the user receives a failure and must verify state; no rollback is attempted over possibly replicated state. This is a remaining failure-injection runtime gate.

Cancel/X closes without commit; while a request/save is pending close waits for its response or timeout. It does not pretend to undo already acknowledged writes from a partial Save. Closing discards remaining staged changes. A separately saved global preset definition is outside that transaction.

Copy in this editor snapshots **working** sorting fields into a local clipboard. Paste replaces only selected working state; it can also import Quartermaster's native clipboard. Native clipboard boolean-link behavior is preserved on import; internal copies preserve generation values. Whole Container, discovery, dirty and filter state are excluded. External Quartermaster world-context Copy/Paste is unchanged and still follows upstream immediate-save behavior.

## Validation record and gates

[TESTED: offline] Exact commands from workspace root:

```powershell
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'Quartermaster - Balanced Sorting/tests/run_tests.py'
& 'C:\Users\willi\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'Quartermaster - Balanced Sorting/scripts/check_versions.py' --root 'Quartermaster - Balanced Sorting'
```

The new focused suites are test_containers.lua, test_container_ui.lua and test_transport.lua, run by that runner. Existing model/ownership/bulk/installed-Picker regressions also pass. Coverage: range boundaries 1/5/10/20/30; loaded registered building rooms/floors; unrelated membership exclusion; source initial selection; same-grid/different-origin exclusion; decorative members; staged edits/overrides; clean-target suppression; Cancel/X; copied scope absence; generation-value preservation; conflict and replaced object rejection; server permission denial; client authority refusal; simulated deferred transport acknowledgment and timeout. Actual Picker host checks cover binding, layout drift, scrollbar dimensions, controller rail focus/return, Paste and Save callbacks. Source syntax, 29-language parity, identity and upstream hash checks are included.

No game or server was launched. SP G6 and hosted/remote/dedicated/multi-client G7 are NOT TESTED; G8 publication is BLOCKED. Remaining runtime matrix: native list/toolbar clipping and scrolling, input during network waits, all furniture orientations/placement sources, large-building latency, unloaded or modified rooms/basements, safehouse server API behavior, duplicate names, destroyed/moved targets, partial network writes, late join/reconnect, preset conflicts, persistence/restart and disabling the patch. Packaging for inspection is authorized by the rename handoff; an offline ZIP is not a release gate pass.

## dev.26 scope and furniture candidate

See [DEV26_SCOPES_FURNITURE.md](DEV26_SCOPES_FURNITURE.md) for current ownership, persistence, migration, UI behavior and acceptance gates. Offline evidence does not establish native persistence or dedicated multiplayer readiness. G6 NOT TESTED; G7 BLOCKED; G8 BLOCKED.
