# Paper clipboard and local computer inventory

Project Version: 0.18.0-dev.8

## 0.18.0-dev.8 recipe checkpoint

The native in-hand Supply Sheet recipe now requires one `Base.Clipboard` with `mode:keep`. The clipboard and pen/pencil are retained; one sheet of paper or notebook is consumed and one Supply Sheet is produced. The clipboard requirement applies only to creating a new blank supply sheet. Existing ledgers, read/record/CD workflows and physical Shopping Lists are unchanged; no item migration or new networking is needed. This is a compatible recipe correction within the current 0.18 development line, using the existing native craft system rather than custom inventory mutation. No separate sandbox micro-setting is introduced for this one ingredient.

[VERIFIED SOURCE] Installed Build 42.21 / Steam build 25485521 defines vanilla `Base.Clipboard` in `media/scripts/generated/items/normal.txt`. Existing B42 recipe syntax and the retained pen/pencil input establish `mode:keep` usage. [TESTED OFFLINE] The ledger metadata check verifies the required kept clipboard, actual native FullType, retained writing tool, consumed paper/notebook, single output and translation parity. Version/source-manifest checks pass. This small recipe-only slice does not rerun unrelated gameplay regressions; the full dev.7 suite below remains historical evidence.

Current source inventory: 225 runtime files. Runtime SHA-256: `e7cdc5aa317ca617c844cf3214a63cd09ad9f244a92042ed3e3581c811a647fe` (sorted relative UTF-8 path, NUL, binary file SHA-256). Native clipboard definition source was inspected read-only; no external assets or custom runtime code were added.

Exact commands:

```powershell
python -B tests/test_ledger_metadata.py
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
git -c core.safecrlf=false diff --cached --check
```

[RUNTIME GATE] Native crafting and dedicated multiplayer NOT TESTED; G7/stable G8 BLOCKED. Verify crafting refuses a missing clipboard, retains clipboard/writing tool on success and produces one Supply Sheet on an actual client/server. No package, deployment, game/server launch or Workshop upload.

## Historical 0.18.0-dev.7 implementation and validation

The source hashes and full regression results below belong to dev.7 and are preserved unchanged. The dev.8 recipe/source hash is recorded in its checkpoint above.

Compatible UI and restrictive computer-policy checkpoint within the existing 0.18 minor development line. No shared schema, protocol or item identity changes. Existing current mirrors are synchronized; historical packages and dated reports remain unchanged.

## Clipboard

Paper supply ledgers open an original Lua-drawn wooden clipboard with a folded metal clip, layered ruled sheets and a red margin. Item / Quantity / Location columns share the digital reader's authorized page data, exact row identity, quantity alignment, clipping, selection and recording/location details. Previous/Next Sheet buttons use the existing opaque cursors; counts mean entries on this returned sheet, not a whole-ledger total. Paper has no digital search or room selector. Native dragging/resizing and controller list/buttons remain; Escape or B closes only the reader. View/error/blank/waiting states use readable ink. No artwork textures, external OS assets or physical clipboard item are created.

The shared table draws a bounded number of ruled lines and skips offscreen row formatting. It does not scan inventories or emit requests while drawing. Existing bounded polling/page requests remain. No native performance claim is made.

## Computer scope and authority

The server resolves the actual mounted storage CD and computer through the existing drive service. It derives that computer's native-building signature with the existing canonical building capture, including room IDs and geometry. Only an exact match to a building-scoped snapshot qualifies for computer live reads or the automatic no-expiry exemption. Native rooms remain internal building geometry, never organizational room scopes.

An off-site or outdoor computer shows recorded history even in Periodic/No updates modes. It uses ordinary mode/interval freshness, not the computer exemption. A safehouse-wide CD has no unique native building, so receives that conservative historical fallback. The CD remains readable subject to current Safehouse/Rooms inspection permissions. An unexpired nearby historical CD can still satisfy existing coverage/range rules; an expired off-site CD cannot gain scoped sorting/collection eligibility from automatic refresh. A carried paper retains its existing ledger mode. Manual inventory/selected-container Sort remains independent.

Read and provider checks use the same policy helper. Clients cannot supply the matching signature. Existing live/fresh session-policy keys invalidate cached projections when eligibility changes; power, CD presence, exact binding and current read permissions are still revalidated. All changed data is ephemeral presentation/eligibility. No inventory, saved snapshot, drive record, allocation, native capacity, native transfer grouping or timing is mutated. Joining/reconnecting uses the server's current policy; no migration is required. Save/restart recovery retains the existing fail-closed binding/identity limits. Already-dispatched native actions keep the accepted native boundary; this change cannot secure unrelated vanilla inventory actions.

The response adds optional `computerOffsite` presentation information without changing requests or protocol capability. Older readers ignore it; matching build requirements remain. The existing authoritative LedgerComputerManualUpdates setting and all 29 fallback tooltips now explain the building restriction. It adds no independent setting because this is a correctness constraint on that existing behavior, not an optional gameplay mode.

## Source and validation

[VERIFIED SOURCE] Steam build 25485521, existing Build 42.21.0 native/source evidence. Installed server ClientCommands.lua lines 675–678 uses a current square's getBuilding/getDef chain. This change reuses existing LedgerScope capture/signature APIs and verified ISUI methods; no new engine call, Java bridge or third-party source is introduced. Local API-library entry records the observed server getBuilding call, not a claim of runtime execution. Native source fingerprints: ClientCommands.lua SHA-256 `c9de3d3024a46e2b3ab1670c11f98885647bfb6d73114ff7896bf41e263923fd`; projectzomboid.jar SHA-256 `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`, identical to the existing 42.21.0 evidence.

[TESTED OFFLINE] Focused production Ledger/native-action fixtures pass: exact full signatures with colliding room IDs, off-site/outdoor/safehouse-shaped history, ignored client signature, no remote analysis calls, normal expiry and No updates behavior, fresh historical nearby coverage, expired provider refusal and recovery in the matching building. Power/CD loss and original paper renewal/privacy tests remain. Safehouse-shaped negative fixtures are not a native multi-building safehouse acceptance test.

[TESTED OFFLINE] UI fixtures pass clipboard/table/details/page-control bounds at 14/24/32/42 font heights, ink contrast, no digital controls on paper, paging, Escape/B and visible read failures. Existing computer taskbar and media tests remain. Preview executes actual reader/table/art with synthetic data and approximate host fonts/widgets, never PZ pixels.

[TESTED OFFLINE] Full paired regression PASS with Rooms 0.2.0-dev.6. Version consistency, source-manifest, Lua-only/case/owned-require checks, 29-locale fallback parity and actual source-rendered previews PASS. The production inventory has 225 files. Runtime SHA-256: `da368a4cebc6733110f57656117a6a9fea811538fc52f77361450ebf1bbe82c0` (sorted relative UTF-8 path, NUL, binary file SHA-256). This binds source bytes, not a package or runtime result.

Changed production paths: new client `ClipboardArt.lua`; client `LedgerTable.lua` and `LedgerUI.lua`; shared `Ledger.lua`, `LedgerPolicy.lua`, `LedgerRequirement.lua` and Identity version mirror; mod.info and all 29 UI/Sandbox fallback files. Tests: `test_ledger_ui.lua` and `test_ledger_freshness.lua`. Updated development preview, runtime manifest, README, changelog, current version mirrors, feature overview, ledger docs and canonical future Workshop text. Existing native movement and appearance paths are untouched. No package was generated.

```powershell
python -B tests/run_tests.py --require-rooms --rooms 'C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDRooms'
python -B scripts/render_computer_preview.py --output 'C:/Users/willi/.codex/visualizations/quartermaster-paper-clipboard'
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
git -c core.safecrlf=false diff --cached --check
```

[RUNTIME GATE] G6 native clipboard/window/controller and G7 dedicated multiplayer NOT TESTED; stable G8 BLOCKED. Required acceptance: paper pages/resizing/fonts, two clients reading local/off-site CDs in every ledger mode, same-building and neighboring/outdoor computers, safehouse-wide fallback, expired-provider denial, power/media/permission changes, delayed pages, reconnect and server restart. No game/server launch, package, deployment or Workshop publication.
