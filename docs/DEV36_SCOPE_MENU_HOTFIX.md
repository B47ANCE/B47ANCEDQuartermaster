# dev.36 scope menu hotfix

[VERIFIED runtime failure] C:/Users/willi/Zomboid/console.txt, last updated 2026-10-11 05:27:37 local, contains repeated scope-menu exceptions: attempted index: player of non-table: null. Stack: native ISContextMenu.getNew:1200 -> owned MultiContainer.Containers:219 -> button callback:164 -> vanilla ISButton.onMouseUp:47. Latest client identity and server acknowledgements both report 0.4.0-dev.30. This proves the failure, not hotfix acceptance; no dev.36 native session was run.

[VERIFIED installed native Lua] `function ISContextMenu:getNew(parentContext)` immediately accesses parentContext.player. Owned Room and Proximity code called ISContextMenu.getNew(menu), leaving parentContext nil. Corrected both to ISContextMenu:getNew(menu). Other owned callers already use colon syntax. Building's option exists before submenu construction, explaining why it can work while Room construction fails. The existing room-token list and callbacks remain intact; no new discovery/room-picker architecture is needed for this exception.

[TESTED offline] Fixture now enforces parentContext and player presence, rather than ignoring the argument. Actual picker callback builds two named room choices and proximity radii; selecting Building then either room passes the correct room token, and selecting a radius passes the expected intent. Full regression suite PASS, version consistency PASS, native corpus exact approved deviations unchanged. Source change is only two colon operators plus version mirrors; taxonomy/authority/routing unchanged. Client UI constructs choices from server-provided room tokens; existing server scope validation is untouched. No new shared state, networking, persistence or sandbox option.

Compatible PATCH-style UI correction in ongoing 0.4.0 prerelease series: canonical 0.4.0-dev.36; published dev.35 artifacts archived unchanged under dist/history/0.4.0-dev.35. No packaging, deployment, staging or publication requested in this turn.

Exact validation commands using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe from this project:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev36-vanilla-diff.json --approved-changes docs/DEV34_APPROVED_TAXONOMY_CHANGES.json
```

All PASS offline. Logs: dist/handoffs/dev36-tests.log and dev36-vanilla-diff.json. Native retest: after authorized deployment, use matching client/server build, open scope menu, choose Building, reopen Room and select another named room, then Proximity; verify correct rail filtering, no null-parent exception, staged edits intact and controller focus. G6 NOT TESTED; dedicated G7 BLOCKED / NOT TESTED; G8 BLOCKED. Offline fixture does not prove native menu interaction. No third-party implementation used.
