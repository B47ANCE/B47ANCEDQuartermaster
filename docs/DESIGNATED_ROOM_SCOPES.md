# Designated-room scope follow-up

Project Version: 0.24.0-dev.4

## Purpose and preserved boundaries

PR #9 was concurrently merged as 0.18.0-dev.1 (`bec375b0483ec8d9d4bbf1565cd897c50d6fb887`). The original in-progress worktree is preserved. This fresh follow-up starts from that merged default and carries forward only remaining scope/capacity corrections; it does not replace upstream allocation, complete-footprint configuration permissions or provider-capability checks.

This is a compatible correction within the 0.18 prerelease series, with an explicitly changed 0.x wire family: Quartermaster Rooms 4 rejects retired `room`/`nativeRoom` kinds. Movement 11, ledger 3, loadPolicy 1, Personal 2, Shopping 3, configuration 6, presets 3 and allocation 1 remain unchanged. Saved schemas are unchanged from dev.1; matching peers must reconnect.

- Room organization uses B47ANCEDRooms designations; native PZ BuildingDef supplies building scope. Current designation defaults choose one stable ID, never union overlaps; proximity is the fallback.
- Retire native-room UI choices, server requests and carry grouping. Building+floor/nearby-cell clusters are planning hints only; all current native capacity/access/reference checks still authorize movement. Native smaller transfer groups, carry filling, spill/return and completed-result handling remain intact.
- Canonical designated IDs alone bind room profiles. Old native:* rows remain dormant and unchanged, including when a provider supplies a historical alias. List/get/commit/routing regressions cover this boundary.
- Keep building ledger capture/signatures/drive keys unchanged. Native room-bound rectangles/IDs remain internal building geometry, not selectable room identities. Historical row labels remain recorded history; new unassigned rows use a localized label. Engine room queries for native power stay engine checks only.
- Fix absent allocation profiles in Shadow capacity evaluation: no extra quota, unchanged route, no item mutation; physical/native capacity checks still apply. Invalid profiles stay invalid.
- Server-authoritative metadata/configuration, current safehouse/Rooms permissions, provider capabilities, revisions, backups and native transfers remain. Allocation enforcement and live Primary/Secondary routing remain disabled.

## Validation

Independent read-only source review on 2026-10-17 found no remaining actionable findings after correcting the route tooltip. The reviewer independently reran the full paired offline suite successfully. This is engineering/source and offline evidence, not native or dedicated acceptance.

[TESTED OFFLINE] Final reconciled full suite PASS on 2026-10-17 with actual paired Rooms `0.2.0-dev.6` at `e9d3b0965155ef6bb5ae067eb42d50e96d2de7b2`. Regressions include upstream provider capabilities/complete-footprint permissions and physical state preservation, plus designated-only UI/server defaults, rejected legacy kinds, outside-building/stale-session refusal, native-alias list/get/commit/routing refusal, nil-profile Shadow/native capacity and fixed building-ledger signature. Native queue fixture conserves 24 designated-room moves and two subsequent building moves with original smaller grouping. Current ledger, physical shopping, optional categories, carry/spill/return, vehicle and binary32 cases pass. Later changes were mod-browser and route-tooltip wording only, covered by metadata/version/translation/source checks; Lua/test code is unchanged from the full run.

Runtime inventory: 222 files; SHA-256 `f133d13425e1676e7bfeca1d3d4f64df289f60831f1f8bfae04afcaf46149a49` (sorted relative UTF-8 name + NUL + binary per-file SHA-256). Source overview digest is maintained in docs/MOD_OVERVIEW.json. Prior worktree test results and historical PR9 reports are not relabelled as this run. No package or native performance measurement is claimed.

Use host Python with Lupa 2.6 / Lua 5.1. Final environment reuses the existing ignored development dependency directory through PYTHONPATH; it is never committed or shipped. Supply the verified standalone Rooms checkout explicitly:

```powershell
python -B tests/run_tests.py --require-rooms --rooms "$ROOMS_REPOSITORY"
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
git -c core.safecrlf=false diff --check
git -c core.safecrlf=false diff --cached --check
```

`check_deployment.py` checks the source manifest here; no local deployment/package/staging is requested. Public push checks include credentials/private diagnostic exclusions, Lua-only inventory, case collisions and owned requires. The project overview is updated against its exact source/README/VERSION digest; a reviewed descriptor is source evidence only.

[RUNTIME GATE] Native client G6 and dedicated two-remote-client G7 NOT TESTED; stable G8 BLOCKED. Acceptance still needs large-font/controller UI, save/reconnect/restart, permission changes during native work, concurrent deposits and actual server/frame timing. No package, deployment, Workshop publication, Steam change or game/server launch.
