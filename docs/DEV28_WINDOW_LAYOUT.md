# dev.28 resizable window and adaptive layout

Baseline 0.4.0-dev.27; target 0.4.0-dev.28, additive compatible UI feature in the ongoing 0.4.0 development series. Canonical VERSION and current mirrors synchronized. No gameplay, taxonomy, discovery, transfer, route, protocol or persistence-schema changes. BetterSortCC research is separate; the unresolved Category adapter is unchanged.

## Native audit

[VERIFIED installed B42.21 source] ISCollapsableWindow.createChildren (:33-49) creates ISResizeWidget for the bottom-right corner and a y-only bottom edge. ISResizeWidget.onMouseDown captures the pointer, onMouseMove/onMouseMoveOutside resize during capture, and both release handlers clear capture. Its resizeFunction callback permits owned geometry clamping without changing the widget globally. Native right-edge-only and top/left resizing are not supplied by this window; this candidate supports the verified corner and bottom edge only.

ISUIElement.setWidth (:230) and setHeight (:245) update Lua and Java dimensions; onResize (:563) refreshes geometry, enforces minima and updates scrollbars. setCapture (:588) delegates to the native UI element. getWidth/getHeight instantiate when Java is absent: geometry restoration therefore uses explicit width values before initialization and does not call getters prematurely. ISCollapsableWindowJoypad reuses the native window methods. Existing title-bar dragging, collapse, pin and close remain.

[VERIFIED owned source] Picker is ISCollapsableWindowJoypad. Adapter and ShoppingUI supply existing layout layers; UI.lua owns final geometry and measured theme metrics. The custom frame previously disabled native frame painting, including its resize glyph. The owned paint now restores that glyph; existing native capture widgets remain. Explicit widget geometry disables conflicting delayed anchors. Lists retain independently synchronized native scrollbars and existing stencil/occlusion behavior.

## Implementation

New client WindowLayout.lua owns viewport bounds, font-derived minima, divider constraints, restore/save and layout actions. UI.lua remains the single final child-placement path; it reads the shared rail width instead of a fixed percentage. Existing controls are moved, not recreated. Main tree, container list, Shopping, Wanted, Needed and presets retain their existing list objects, selected items, search state and scrolling. Hidden Shopping rail/divider are not interactive; presets without a rail retain the layout controls.

Default requested size: 1120x780. At ordinary 14-pixel body font the derived minimum is 640x498. Formula: width max(640, rail + max(420, 18*font) +32); height max(460, header +2*tabs +5*buttons +2*rows +font +10*gaps). Larger fonts increase the minimum. Maximum is the owning player viewport. An undersized viewport necessarily caps those minima; acceptance on screens below these control requirements remains a limitation, not a demonstrated guarantee of readability.

Divider minimums preserve a usable rail and a main width max(300,12*font). Drag uses parent-space pointer coordinates and native capture; release outside completes the gesture. Repeated moves do not lose the origin as the divider changes x. Ratio is clamped against current widths and saved. Geometry actions use the same functions for mouse/controller: Larger Window, Smaller Window, Wider/Narrower Container Panel, Reset Window Layout. The persistent Layout header button belongs to the controller focus rows; menus return focus through existing native context handling. Reset changes geometry only.

## Local persistence and authority

Files B47ANCEDQuartermasterWindow<localPlayerNumber>.txt contain x, y, width, height and normalized divider ratio. Uses the existing native getFileReader/getFileWriter preference mechanism; separate from the grouping preference file and all server/world/player ModData. Five bounded reads; finite numeric validation; missing, malformed, NaN/infinite values fall back or clamp. Close and completed resize/divider/controller actions save. Viewport/font changes and title movement clamp to the owner viewport. File failure does not prevent opening.

No networking or server sandbox option is appropriate: window geometry is personal presentation only. No gameplay values were introduced. Existing inherited furniture handles, sprites/cache identity, tooltip plain-text/bounds/disposal, inspection and controller rows remain. All 29 UI translation folders have English fallback coverage.

## Performance and validation

Geometry updates reuse widgets and existing row/list data. No catalog rebuild, resolver pass, physical discovery, route planning or inventory action is called by WindowLayout. Existing layout layers retain their current per-row height updates. Steady viewport checks compare scalar fields without constructing per-frame key tables/strings. Preferences are not written every frame.

[TESTED offline] tests/run_tests.py passes, including actual owned-window fixtures for bounds, divider extremes/capture and stable pointer coordinates, controller menu actions, preference round trip/corrupt data, resolution/split viewport changes, early-instantiation protection, unchanged selections/list identity and zero Authority requests. Existing UI geometry/font, tooltip, nested furniture, sprite, source/29-language and gameplay regression tests pass. Log: dist/handoffs/dev28-tests.log. Installed native source/API inspection is not native rendering evidence.

Exact commands use C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe from this project: tests/run_tests.py; scripts/check_versions.py; scripts/check_deployment.py. Development packaging validation is recorded separately in dist/handoffs/dev28-build.log and the source/hash receipt when completed.

## Acceptance / remaining gates

[RUNTIME GATE] G6 NOT TESTED: corner/bottom-edge dragging and grip layering, resize capture/release, title movement, minimum/default/wide-short/narrow-tall/maximum layouts; divider extremes; all modes/preset editor; long labels and tooltips; resolution/font changes; split-screen; controller focus/menu recovery; close/reopen across sessions; installed UI-mod environment. Test malformed preferences and ensure no requests/actions during resize. No PZ or server launched.

G7 for this proven local-presentation slice: N/A (no shared gameplay or custom synchronization); whole-project dedicated gameplay acceptance remains BLOCKED / NOT TESTED. G8 overall BLOCKED, with no readiness claim. No local deployment, Workshop staging or publication authorized/performed. The attached handoff requests a package report; only a development artifact is built, never treated as native acceptance.


## Development package result

[TESTED offline] Build.ps1 exit 0: full regression, deployment-gate fixtures, source/package parity and scripts/check_versions.py --release PASS. Package: dist/current/B47ANCEDQuartermaster-0.4.0-dev.28.zip. Runtime files: 125. SHA-256: `7045cc1438f7b81340be8a2dcc9508438be369cd54f3a1955f39755fd42185b5`. Receipt/source hashes: dist/handoffs/dev28-build-receipt.json. The builder's temporary-local parity fixture is not a live-mod deployment. No Workshop staging or live files changed.
