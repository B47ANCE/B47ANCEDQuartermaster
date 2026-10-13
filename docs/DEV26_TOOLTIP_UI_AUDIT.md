# Tooltip UI audit — 0.4.0-dev.26

Audit date: 2026-10-11. Read-only production audit; no runtime code, metadata, translations or version changed. Report and offline logs only. Scope: every tooltip producer under client/B47ANCEDQuartermaster and client/B47ANCEDUI, English/fallback translation coverage, sandbox descriptions, installed native tooltip/list/button/label/text-entry/rich-text contracts, and existing UI tests.

## Findings

No P0/P1 defect established. Six P2 issues and four P3 issues below. Source evidence establishes implementation behavior; visible in-game effects remain runtime gates unless explicitly tested offline.

### 1. P2 — Hidden widget tooltip registrations are not removed

[VERIFIED source; TESTED offline] UI.lua:9 hides a widget and directly calls tooltipUI:setVisible(false), without removeFromUIManager. Native button/list/label/text-entry cleanup removes only an already-visible tooltip. Therefore an invisible tooltip can remain registered after panel/list switches, and the normal cleanup predicate subsequently skips it. This is a lifecycle leak, not proof of a continuously visible popup. Reopening can attempt registration again; whether Java deduplicates and its cost require runtime evidence.

Production-helper probe: tooltip initially visible with one manager registration; after visible(widget,false), visibility false and registrations still one. Output: dist/handoffs/dev26-tooltip-audit-probe.json. The rail's setVisible/clear wrappers clean up before this helper hides it, so this finding primarily affects ordinary widgets and shopping lists.

Recommended fix: one owner-aware hide/dispose helper removes registered tooltip UI independently of its current visible flag; use it on mode changes, close/removal and transient panels. Test repeated switches and closing while hovering/focused, including UI manager counts.

### 2. P2 — Most tooltips lack player-viewport bounds

[VERIFIED source; INFERRED visible effects] RowTooltip is attached only to the container rail. Shopping rows (UI.lua:82), sorting shared-name rows (Adapter.lua:58), buttons, labels, quantity fields, recipe integrations and Dibs context tips retain native placement. Native ISScrollingListBox uses maxLineWidth=1000; native ISToolTip button overlap avoidance uses global screen bounds, not the owning split-screen viewport, and ordinary following list tips have no equivalent rail clamp. Long names, large fonts or edge-positioned windows can therefore overflow/cover controls or another player's region. Not a claim that every normal tooltip overflows.

Recommended fix: reuse bounded owner-aware placement across surfaces, while preserving native hit-testing, occlusion and context-menu handling. Test all screen edges, resized dialogs, split-screen and large tooltip fonts using actual layout dimensions.

### 3. P2 — The combined sorting-mode hover still contains a large manual

[VERIFIED source] Adapter.lua:351 joins RulesTip and ControlsTip. English text totals 15 explicit lines, before wrapping. Category rows themselves no longer carry the unwanted usage manual, but hovering Categories & Items still produces it. Native tooltip bounds do not cap its height.

Recommended fix: keep a short mode summary; move full controls/rule explanations into the existing Help dialog. Preserve the useful shared-name exception tip.

### 4. P2 — Dibs participant tooltips have no length/height cap

[VERIFIED source; INFERRED visible effects] DibsUI.lua:20–22 adds one line per Needed/Wanted player; :56 renders all lines in a native context tooltip. Dibs validates up to 256 player records, with labels up to 80 bytes. Multiple selected items use a compact summary, but one heavily reserved item can produce a very tall popup.

Recommended fix: show a bounded summary and an explicit additional-participant count, with full detail available on deliberate inspection. Verify native context placement for many participants and large fonts.

### 5. P2 — Needed duplicate race displays the Wanted explanation

[VERIFIED source] ItemPicker.lua:92 unconditionally sets WishExists after its fresh duplicate check. For kind=needed it checks snapshot.needed but tells the user to edit Dibs! Wanted. Initial enable logic correctly distinguishes NeededExists, making this late response inconsistent.

Recommended fix: select the message by current goal kind in every duplicate path. Test a Needed target created between opening the picker and submitting it, as well as normal Wanted behavior.

### 6. P2 — Rail tooltip information is inaccessible through controller focus

[VERIFIED source] RowTooltip.lua:38 retains native mouse-based list eligibility. MultiContainer.lua:153 controller handling selects/expands/returns but provides no selected-row tooltip or inspect action. Coordinate/access-error tips depend on a mouse-hovered row even when the controller has focused the rail. Native buttons do support focus tooltips; lists here do not.

Recommended fix: selected-row inspection via a controller action or persistent detail area, with safe focus lifecycle. Test without a mouse over the focused row.

### 7. P3 — Truncated titles/labels have no automatic full-text recovery

[VERIFIED source] Controls.lua:31,41–43 fits labels and buttons but never supplies the full label as a tooltip when shortened. Long translated scope names, container room labels and action titles can become ambiguous. Existing explicit explanatory tips should take precedence over any fallback.

Recommended fix: reveal full text only when truncation occurs and no semantic tooltip already exists. Keep the full value distinct from temporary drawing text.

### 8. P3 — New nested controls omit their important semantics from tooltips

[VERIFIED source] MultiContainer.lua:158 creates buttons without tooltips; Whole/Customize/Reset/Remove and the scope header are examples. Rail tips at :120 contain only the name and coordinates. They do not explain inherited read-only state, custom independence, partial-group edit restrictions, reset confirmation or that scope filtering does not change Sort destination discovery. Names alone are particularly weak when the title is truncated.

Recommended fix: short, state-specific explanations with one field per line where needed; include the same explanation for disabled actions. Do not restore a manual to every category row. Existing WholeContainerTip translation describes the old copy-only behavior, but is currently unused; replace it if repurposed, rather than attaching stale text.

### 9. P3 — Tooltip theme styling does not style the final native frame

[VERIFIED source] Controls.lua:51 sets tooltip backgroundColor/borderColor. Installed ISToolTip.render draws the final rectangle and border using hardcoded native colors. The custom values affect prerender, while the native final frame still paints over them. RowTooltip intentionally sets background alpha zero to avoid mismatched native passes; other skinned tooltips do not receive that special handling.

Recommended fix: deliberately retain native tooltip appearance or own a coordinated render/prerender implementation; do not claim the current color assignment creates a fully themed tooltip. Actual flicker/ghosting is a native visual gate, not established here.

### 10. P3 — Shopping tooltip names bypass the rail's plain-text protection

[VERIFIED source; INFERRED visual impact] UI.lua:82 passes row.fullType or row.name directly to native rich text. Recipe/project names and mod-provided names can contain rich-text-shaped characters. Native ISRichTextPanel parses tags; the rail strips angle brackets before displaying names. Dibs newly written display names strip brackets server-side, which is a useful protection already present.

Recommended fix: plain-text escaping/normalization for externally supplied name fields, retaining deliberate markup only in trusted translated descriptions. Test names containing angle brackets and line breaks. No code execution or network-authority exploit is claimed.

## What is already correct

[VERIFIED source] Container rail preserves native scrollbar exclusion and occluding-window checks. Tips are per list instance, noninteractive/native always-on-top, placed next to the actual visible row, and clamped to the owning player's viewport. Text is capped to eight lines, fitted to a width, normalized to plain text and recalculated on font/viewport changes. Clear/hide/select/close/removal paths call rail cleanup. Renderer.fit preserves UTF-8 character boundaries. Rails do not put giant instructional text on category rows.

[VERIFIED native source] Both newline characters and <LINE> are accepted: ISRichTextPanel.paginate converts newlines. Shopping's newline delimiter is not itself a bug. Button tooltips display for mouse or joypad focus even when disabled; useful unavailable reasons can be attached without enabling unsafe actions. Native tooltip widgets do not consume mouse events.

[TESTED offline] Existing full regression suite passes, including 30 row-tooltip geometry/lifecycle fixtures, occlusion, instance isolation, explicit split-screen placement and installed native tooltip render/prerender draw-contract checks. Localization/29-language fallback parity and upstream-file immutability checks pass. These tests stub layout and engine drawing: they do not prove pixels, final native font wrapping, visual z-order or multiplayer UI timing. Their current coverage misses the ordinary-widget lifecycle defect above.

## Coverage and acceptance

Inspected sorting rows/tab tips, furniture rail and controls, Shopping/Wanted/Needed rows and summaries, item-picker actions/quantities, preferences availability messages, Dibs context tips, vanilla crafting/building additions, Project Cook/Neat integrations, Help/search controls, theme wrappers and all sandbox tooltip keys. No duplicate independent gameplay architecture is introduced by tooltip presentation.

Sandbox descriptions reflect the current Whole Building default and preserved saved values. No missing tooltip key was established by existing localization parity checks. English fallback parity does not prove translated wording/RTL layout.

Priority order: lifecycle cleanup; bounded owner-aware placement; reduce the large tab/participant popups; duplicate message; controller inspection; then fallback/state explanations and styling/plain-text consistency.

Native acceptance matrix: hover each surface at every screen edge; large fonts; long/non-ASCII/markup-shaped names; scroll/offscreen rows; switch Sorting/Shopping/Wanted/Needed while hovering; open/close modal dialogs; close/resize/collapse parent; repeated reopen with UI-manager counts; two split-screen players; mouse-free controller inspection; disabled controls; late async results and many Dibs participants. Include the user's full installed-mod test environment to check UI coexistence. No game/server was launched for this audit.

## Evidence and changes

Command from project directory: `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe tests/run_tests.py` — exit 0. Log: dist/handoffs/dev26-tooltip-audit-tests.log. Separate Lupa probe executes the actual UI.visible helper with a manager-registration fixture and the source-verified native cleanup predicate.

Runtime SHA-256 comparison against dist/handoffs/dev26-source-hashes.json: zero changed files. No code fixes, version bump, packaging, deployment or publishing. G6 native visual acceptance: NOT TESTED. Dedicated multiplayer visual/coexistence acceptance: NOT TESTED. Existing G7/G8 blocks remain; this audit does not waive them.
