# dev.26 — discovery scopes and inherited furniture

## BASELINE

[VERIFIED: source] Started at 0.4.0-dev.25. Old Whole Container staged copies onto independently configured physical siblings; it did not provide live inheritance. Existing object ModData uses configuration schema 2, world envelope 1. dev.26 is an additive development feature increment in the ongoing 0.4.0 prerelease series. Movement capability remains 3; configuration capability is now 2. Matching client/server candidates are required. Frozen taxonomy remains 6.

## NATIVE FURNITURE AUDIT

[VERIFIED: installed native API/source] IsoObject.getSpriteGrid and getSpriteGridObjectsIncludingSelf expose engine furniture relationships. Targets checks grid positions, exact object/container identity and every compartment of one physical object. Furniture requires mutual membership, not adjacency, identical names or sprite guesses. Unsupported, ambiguous or asymmetric groups remain independent; inaccessible members cannot authorize shared edits.

RoomDef.getID returns a long; getName, getX/Y/Z and IsoRoom.getRoomDef expose physical rooms. Native DebugChunkState_SquarePanel uses room definitions. Session tokens retain exact RoomDef references; equal room names never identify a room. Duplicate labels receive deterministic numbering.

IsoObject.save/load persist its ModData table through native KahluaTable serialization. Native ISMoveableSpriteProps.saveThumpableParameters copies object ModData; restoreThumpableParameters restores it. Therefore metadata can travel with moved objects. Persisted member identities also include physical coordinates, compartment, type and compartment count: moved/replaced/missing assemblies cannot silently rebind inheritance. Custom sections retain their own raw configuration. Automatic migration/recovery of moved shared assemblies is unsupported; original data remains. Restart/reconnect persistence is source-supported, not native runtime proof.

## CONFIGURATION

Owned B47WholeContainer object root: schema 1, object ID, children keyed by compartment, and parents keyed by canonical compartment. Each parent stores its ID, revision, complete sorting configuration and member map. Each child stores parent ID, inherit/custom mode and revision. IDs are assigned only on explicit shared save; opening or expanding never writes. No global furniture database or combined inventory is created.

Effective rules: ordinary section uses existing raw configuration; custom section uses its complete independent raw configuration; inheriting section uses the verified live parent configuration. Inheritance revisions include both parent and child revision. Parent/custom saves and reset reject stale revisions. Ordinary loads are fresh, not cached snapshots.

First activation preserves every existing explicit configuration, including empty configurations and legacy imports, as custom. Fresh sections inherit. No child is arbitrarily chosen as a parent template. Reset requires explicit confirmation and restores live inheritance without deleting the raw backup. Removing shared settings requires confirmation and materializes effective rules for inheritors; custom rules stay untouched. Malformed/future owned data fails closed.

## UI

Nested parent rows precede their physical sections. Chevron/controller X expands or collapses; body/controller A selects the row; B returns focus. Selecting an inheritor displays read-only effective rules. Customize Section explicitly stages a full override. Reset/Remove require a second confirmation click and then Save. Cancel discards staged work. Inherited/Custom badges are available from discovery metadata before opening sections. Partial scope parents are marked and cannot be edited.

[TESTED: offline UI fixtures] Read-only guards and detached display copies prevent inherited item/preset UI mutation. Native dimension/layout regressions remain covered. Actual controller focus, small-screen rendering and tooltips require native acceptance.

## INTEGRATION

WholeBuilding defaults true for new sandbox configurations and absent fallback values. Existing explicit false values are respected. Initial view is the current physical room, or bounded proximity outdoors. Header choices are Building, individual physical rooms, and Proximity 1–server ContainerRange (existing maximum 30). Proximity uses same-floor Chebyshev tile distance. Building is unavailable when authoritative discovery settings disallow it. Accepted view changes require no rediscovery or gameplay setting writes.

Filtering precedes grouping; hidden sections remain hidden. Parent-wide changes require every member visible and authorized in the server's accepted view. Full destination discovery remains unchanged for Sort. Groups sort by same-floor preference then nearest visible horizontal Euclidean distance, with stable tie ordering. Physical children remain adjacent under their parent and receive unique section numbers in canonical physical order, even when every tile uses compartment 0.

Actual world sprite resolver and tooltip lifecycle are retained; logical parents use their physical anchor presentation. Presets and Copy/Paste use existing complete configuration semantics. Header Copy to visible sibling sections stages explicit independent copies and is disabled for partial groups. No item/category taxonomy changes.

## MULTIPLAYER

Client submits session/physical token, intended configuration, revision and explicit action. Server resolves live physical identities, access and existing discovery limits, validates configuration and full-parent membership against its accepted view, then persists native object ModData and sends configuration-change hints. Client view cannot expand server gameplay authority.

[TESTED: offline production handlers] Two authenticated fixture sessions demonstrate stale shared-parent rejection and independent overrides on different children. Effective rules flow through Store.load(target, authenticatedPlayer) in Planner and Movement. Logical parent records exist only in client configuration UI; transfer grants and destinations stay physical.

[UNKNOWN / RUNTIME GATE] Native ModData replication, restart, late join/reconnect, two-client timing and network failures need dedicated evidence. Configuration notifications reuse existing event-driven refresh; no claim of native atomic multi-object writes is made.

## PERFORMANCE

Retains session/catalogue caches and scroll state. Expansion, scope changes and drawing do not scan the building. Relationship validation runs during discovery/load/write, bounded to 64 physical sections (technical safety limit, not gameplay setting). Ordinary and custom effective loads avoid group discovery. Inheritance revalidates native membership rather than caching stale identities. World-load/configuration hints invalidate existing discovery; no second discovery architecture was introduced. Group sorting occurs on rail rebuild, not every rendered frame. No native timing measurements exist for this candidate.

## VALIDATION

[TESTED: offline, Python + Lupa Lua 5.1] Full tests/run_tests.py includes production scope/authority/inheritance/revision/migration/replacement fixtures, UI regression fixtures, and the existing dev.24 native-action source harness and dev.25 floor pipeline. Native-action harness uses installed Lua with mocked engine/network boundaries; it is not dedicated multiplayer proof.

Exact commands from project directory (Python executable: C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe):

- `python tests/run_tests.py`
- `python scripts/check_versions.py`
- `python scripts/check_deployment.py` (source manifest only)
- `python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev26-vanilla-diff.json`

Version consistency PASS; source manifest PASS (122 runtime files); vanilla membership PASS (5,092 items, zero changes).

Results/log: dist/handoffs/dev26-final-tests.log. Native client and dedicated two-client results: NOT TESTED.

Acceptance: new and existing sandbox defaults; repeated room names on different floors; Building/Room/Proximity switches; partial groups; parent edit while another client customizes; stale reset; cancel/presets/copy; explicit empty/legacy saves; inaccessible sections; restart/late join; removal/replacement/move; physical sorting into inherited and custom sections; controller/resize/tooltip behavior. Moved shared assemblies must be presented as unavailable, not silently inherited.

## PACKAGE

Development version 0.4.0-dev.26. Runtime source files: 122. Source hash inventory: dist/handoffs/dev26-source-hashes.json. Manifest SHA-256 (canonical sorted JSON file-to-SHA mapping): 12c73fe9f0539d39afe778c2240648d2fe5e4c33df16176a641ec795c841b764. No package created; source/package parity is NOT TESTED because packaging was not requested. Starting dev.25 hashes retained separately; historical packages were not rewritten. No live deployment/publication occurred.

## GATES

G6 native client: NOT TESTED. G7 dedicated multiplayer: BLOCKED / NOT TESTED. G8 release readiness: BLOCKED. Offline passes do not waive these gates. Safe server authority is established at source/fixture level; native synchronization and moved-furniture recovery remain runtime/feature limitations.

## Native audit provenance

SHA-256 of inspected installed files:

- projectzomboid.jar: E1A69EB743EDE60B213A0FE7F8B83D4FCAB773036D256CC4543A336F3B058A33
- shared/Moveables/ISMoveableSpriteProps.lua: A6A5AB5B36DA07CE53587218BFFD33963D9CAF0B53E571107CC66DBE9F77AB4C
- client/DebugUIs/DebugChunkState/DebugChunkState_SquarePanel.lua: CC569A59E3A0C59CA79BF37CBE1330A9429075BAC7B2298C027D98C39CB9C20F

API/source inspection is distinct from running these paths in PZ. Third-party source/assets were not used for this implementation.
