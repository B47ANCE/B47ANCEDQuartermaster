# dev.30 native acceptance record

Status: NOT TESTED. No PZ launch, server launch, deployment or Workshop staging authorized by this handoff. This document is a human runtime checklist, not proof.

Use the dev.30 artifact and matching client/server versions after deployment is authorized. Record ZIP SHA-256, game version, active exact mod IDs, renderer diagnostics and console/server logs. Preserve the established Quartermaster/BetterSortCC conflict policy. Treat all downloaded Workshop mods as the intended test environment; list any conflicts explicitly rather than silently excluding them.

| Area | Required native checks | Result |
|---|---|---|
| Category labels/order | Player, bag, world loot, vehicle and proximity panes; canonical label and ascending/descending Category order; equipped/name ties; Name and Weight headers unchanged | NOT TESTED |
| Lifecycle | Existing/new modded items, transfers, refresh, cache invalidation, reconnect and language change; selected group/expanded item identity preserved | NOT TESTED |
| Native metadata | Ammo context menu and memento behavior unchanged; no gameplay category mutation | NOT TESTED |
| Renderer chain | Full installed UI-mod set, Neat UI, BookTracker/pzopt if active; diagnostics show wrapper, Category draw and substitution. Nondelegating renderers or custom sort comparators are unresolved until observed | NOT TESTED |
| Resize | Corner and bottom edges, smallest supported viewport, ultrawide, maximized/restored viewport; all footer controls reachable, no clipping/overlap | NOT TESTED |
| Divider | Drag to both limits; capture outside divider; panels retain minimum width; scrolling/selection/tooltips remain correct | NOT TESTED |
| Geometry | Close/reopen/restart, viewport change, corrupt/missing preferences, reset layout, independent players | NOT TESTED |
| Opacity | 20%, 50%, 82%, 100%; live preview, reset and persistence. Text/icons/buttons/selection/scrollbars/resize handles readable | NOT TESTED |
| World visibility | Zombies and highlighted containers visible through the background at lower opacity; no added opaque nested backgrounds; controls retain input capture | NOT TESTED |
| Controller | Resize/layout menu, divider actions, appearance slider, focus return, cancel/close and sorting controls | NOT TESTED |
| Split-screen | Separate player geometry/opacity; viewport bounds and controller focus; no settings leak | NOT TESTED |
| Dedicated multiplayer | Matching dev.30 peers, reconnect, inventory panes and unrelated sort/shopping workflows; authoritative state unchanged | NOT TESTED |

G6 native client: NOT TESTED. G7 dedicated MP: BLOCKED / NOT TESTED. G8: BLOCKED. The Category change is local presentation only, but the package retains gameplay features requiring dedicated validation. Offline comparator/renderer fixtures cannot establish actual replacement-renderer compatibility.

Enable the owned bounded Category diagnostic only for the test session: `B47ANCEDQuartermaster.InventoryCategories.enableDiagnostics(true)`. It prints at most 64 samples; disable after capturing. A REGISTERED line alone is insufficient: require actual SUBSTITUTED samples from each relevant pane and screenshots of header sorting. Capture failures and exact mod IDs without editing third-party source.
