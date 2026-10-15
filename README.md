# B47ANCE'd Quartermaster

Organize storage, put supplies away and keep track of what you need in Project Zomboid.

Tell each container what belongs inside, then sort your inventory, a room or an entire building from one menu.

[Get Quartermaster on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3807217050) | [Required: B47ANCE'd Rooms](https://steamcommunity.com/sharedfiles/filedetails/?id=3820077442)

This guide describes the current Workshop release. [Current Workshop source and build files](https://github.com/B47ANCE/B47ANCEDQuartermaster/tree/feature/rooms-extraction).

## Sorting

- Choose whole categories or individual items in a searchable tree with native item icons.
- Configure multiple containers in one window, with presets, copy/paste and destination priorities.
- Share Whole Container settings across furniture sections, or customize individual sections.
- Sort carried inventory, a selected container, the current room or an entire building. Room and building operations include carried bags.
- Sort supported floor and Proximity Inventory items into configured storage.
- Search categories and items, filter by Only Checked or Only Contents, and optionally group items by mod.
- Use vanilla categories or categories supplied by Better Sorting and Better Containers.

## Shopping and Dibs!

Keep a Shopping List with target quantities, carried counts and remaining demand. Add items manually or from supported crafting, building and cooking recipes, then collect what is missing from eligible nearby storage.

Shopping Preferences let you choose acceptable condition, food state and remaining uses, including individual item preferences.

Dibs! provides personal item labels and separate Wanted and Needed lists. Set supply targets, track what you carry, send missing amounts to Shopping and collect the remainder. Shopping plans do not automatically craft, build or cook.

## Getting started

1. Subscribe to Quartermaster and B47ANCE'd Rooms, then enable both mods.
2. Open **Quartermaster** from your player inventory.
3. Select a container and choose its categories, individual items or sorting presets.
4. Save the configuration. Repeat for other storage, or reuse settings with copy/paste and presets.
5. Press **Sort** and choose your inventory/selected container, current room or entire building.

Use **Designate Room** inside Quartermaster to open Rooms' editor. Resize the window, adjust the container divider and set background transparency to suit your screen. Mouse, keyboard and controller controls are included.

## Selection controls

| Control | Action |
| --- | --- |
| Click a checkbox | Select or clear a category/item |
| Click a category or mod label | Expand or collapse its items |
| Shift-click | Apply the target's resulting selection state across the visible range |
| Ctrl-click | Toggle one row while retaining the range anchor |
| Ctrl+A | Select all visible item rows |
| Ctrl+Shift+A | Clear all visible item rows |
| Invert Visible | Toggle the displayed item selections |

Visible-list operations affect displayed item rows. Category and mod-group actions can explicitly select their complete groups. Search, Only Checked and Only Contents determine which item rows are visible.

## Compatibility

- **Project Zomboid Build 42.21.**
- **B47ANCE'd Rooms is required.** Enable `B47ANCEDRooms` alongside `B47ANCEDQuartermaster` on the server and every client.
- **Better Sorting and Better Containers are optional.** Quartermaster uses their exposed categories; inventory presentation stays with the installed UI mods.
- **Project Cook, Neat Crafting and Neat Building are optional.** Shopping controls support compatible recipes; partial portions, fluids and other unsupported cooking demands are not handled.
- Disable original Quartermaster and older B47 sorting copies.
- Use matching mod versions on the server and all clients.

Quartermaster checks supported container and room access when sorting. Room policies do not lock unrelated vanilla transfers, entry or doors.

For automated cleaning, install the separate [B47ANCE'd Auto Clean](https://steamcommunity.com/sharedfiles/filedetails/?id=3820151540) mod. It requires Quartermaster and Rooms. Quartermaster does not require Auto Clean.

## Development and documentation

Use the [current Workshop source branch](https://github.com/B47ANCE/B47ANCEDQuartermaster/tree/feature/rooms-extraction) for current source and build instructions. Each checkout's root `VERSION` is its canonical source version. Runtime source lives under `src/B47ANCEDQuartermaster/42`; tooling dependencies are not game dependencies.

From that source checkout, with Python and the host-only Lupa dependency available:

```powershell
python -B scripts/check_versions.py
python -B tests/run_tests.py --require-rooms
./Build.ps1 -PythonPath <python.exe>
```

- [Native categories and compatibility](https://github.com/B47ANCE/B47ANCEDQuartermaster/blob/feature/rooms-extraction/docs/NATIVE_CATEGORIES_COMPATIBILITY.md)
- [Rooms integration](https://github.com/B47ANCE/B47ANCEDQuartermaster/blob/feature/rooms-extraction/docs/ROOMS_INTEGRATION.md)
- [Supply API for other mods](https://github.com/B47ANCE/B47ANCEDQuartermaster/blob/feature/rooms-extraction/docs/SUPPLY_API.md)
- [Version policy](https://github.com/B47ANCE/B47ANCEDQuartermaster/blob/feature/rooms-extraction/docs/VERSION_POLICY.md)
- [Issues and feedback](https://github.com/B47ANCE/B47ANCEDQuartermaster/issues)

Dedicated multiplayer tests passed according to the owner's report on 2026-10-15. Historical implementation and validation notes retain their original context in the repository and Git history.

**Mod ID:** `B47ANCEDQuartermaster`

**Workshop ID:** `3807217050`

Created by B47ANCE. Original Lua-only implementation; no third-party mod source or assets are bundled.
