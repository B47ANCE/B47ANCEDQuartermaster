# Knox Inventory compatibility — 0.24.0-dev.6

## Clean-room provenance

- Third party: **Knox Inventory**, author **SYNTHETIK**, [Workshop 3816775774](https://steamcommunity.com/sharedfiles/filedetails/?id=3816775774), installed stable `KnoxInventory` and beta `KnoxInventoryBeta` packages downloaded 2026-10-28.
- [Source and license](https://github.com/SVNTHETIK/knox-inventory): source available with addon permissions, not a general code/assets redistribution grant. No Knox source, assets, text, or algorithms were imported.
- Research question: how to expose Quartermaster's existing inventory actions while Knox replaces the vanilla inventory window.
- Observed interface: both downloaded variants call the vanilla item context-menu builder for their grid; both expose an active-player check and a closable full-screen inventory. These are observed integration points, not a guaranteed public API contract.

## Independent adapter

Quartermaster adds a guarded client menu entry only for an item in the player's carried inventory when Knox's active-player check succeeds. It closes the Knox screen and calls Quartermaster's existing Sort or Configure action. Sorting authority, permission checks, native movement, persistence, and capacity rules remain unchanged. The adapter does not require or ship Knox or its Java dependency; Quartermaster remains Lua-only and usable without Knox. No sandbox option is needed for an optional UI entry point.

## Evidence and gates

- [VERIFIED source] Downloaded stable and beta packages contain the vanilla item-menu call and the observed UI lifecycle methods. Quartermaster's existing window controls have no surface in a Knox-only inventory.
- [TESTED offline] Version and repository tests are recorded in this iteration's PR. They do not prove visual stacking or transfer behavior in game.
- [RUNTIME GATE] Test stable Knox in SP; test beta Knox on a dedicated server with a remote client. Check carried item menu, Sort/Configure, menu closing, native transfers, controller fallback, and Knox absent. G7 and stable G8 are not established by this adapter.
- Clean-room reviewer signoff: pending independent PR review. No external files were modified.
