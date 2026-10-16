# B47ANCE'd Quartermaster

<img src="preview-client.png" alt="B47ANCE'd Quartermaster: wooden storage crate with a supply checklist" width="320">

Organize storage, put supplies away and keep track of what you need in Project Zomboid.

Tell each container what belongs inside, then sort your inventory, a room or an entire building from one menu.

[Get Quartermaster on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3807217050) | [Required: B47ANCE'd Rooms](https://steamcommunity.com/sharedfiles/filedetails/?id=3820077442)

The Workshop feature guide is below. This branch also contains **0.16.0-dev.1 development work**, which has not been deployed or published. [Current Workshop source and build files](https://github.com/B47ANCE/B47ANCEDQuartermaster/tree/feature/rooms-extraction).

## Development work in this branch

- Optional Extended Categories support, including client/server detail differences through explicit category-member selections.
- Dangerous Load: disabled by default, with a server-validated personal 50–100% native-capacity limit for Sort and Collect. Native restrictions and penalties still apply.
- Craft paper Supply Sheets, physically inspect building/safehouse storage, and copy completed snapshots to a selected CD at a powered desktop. Paper pages are read-only history. Computers open a Windows ’93 desktop: insert a CD and run QUARTERMASTER.EXE to search and browse its ledger. See the [workflow, authority and acceptance report](docs/LEDGER_AND_LOAD.md). The shelf experiment remains out of scope.
- Overall Sort/Shopping progress beside vanilla's current-action bar, including room/building job progress.
- Fill a carry before walking, then unload it before the next carry. Vanilla's smaller transfer groups and timing stay unchanged.
- Server-controlled extra carry allowance (0-40 kg, default 0), subject to native capacity and encumbrance.
- Selected native vehicle/trailer cargo and nested storage bags, with native access checks and cargo-area walking.
- Pre-authorization full-crate fallback and permitted source returns; safe retention when a return or native outcome is unavailable.

Movement protocol 10 requires matching server/client builds and reconnect. Saved category rules, selections, presets and priorities are unchanged. No automatic parked-vehicle area sweeps, vehicle destination designations, fluid tanks or unverified virtual storage. Actual PZ SP and dedicated testing for this iteration are pending. See [behavior, clean-room audit, validation and limitations](docs/PROGRESS_CARRY_AND_CONTAINERS.md).

## Sorting

- Choose whole categories or individual items in a searchable tree with native item icons.
- Configure multiple containers in one window, with presets, copy/paste and destination priorities.
- Share Whole Container settings across furniture sections, or customize individual sections.
- Sort carried inventory, a selected container, the current room or an entire building. Room and building operations include carried bags.
- Sort supported floor and Proximity Inventory items into configured storage.
- Search categories and items, filter by Only Checked or Only Contents, and optionally group items by mod.
- Use vanilla categories or categories supplied by Better Sorting, Better Containers or Extended Categories.

## Shopping and Dibs!

Create separate **physical Shopping Lists** with one blank sheet of paper, a notebook and a pen or pencil. Keep the notebook and writing tool; one sheet becomes a named shopping paper. Choose among the lists you carry, rename them, and hand the papers to friends before a loot run. Reading and collecting from an existing list need no writing supplies; editing does. Hold a list in either hand for a small notebook-paper HUD showing what you carry and still need. Longer lists turn pages automatically.

Existing personal shopping plans are preserved. **Import Old List** copies the previous plan onto one new paper once, using the same materials. Server options can restore personal-list mode or remove the writing-supply requirement. See [physical lists, sharing, import and validation](docs/PHYSICAL_SHOPPING_LISTS.md).

Each selected list tracks target quantities, qualifying carried counts and remaining demand. Add items manually or from supported crafting, building and cooking recipes, then collect what is missing from eligible nearby storage.

Shopping Preferences let you choose acceptable condition, food state and remaining uses, including individual item preferences.

Dibs! provides personal item labels and separate Wanted and Needed lists. Set supply targets, track what you carry, send missing amounts to Shopping and collect the remainder. Shopping plans do not automatically craft, build or cook.

## Building Supply Ledger

**Sorting and Shopping collection now require a completed ledger by default.** Carry a paper ledger covering the work location, or load a matching ledger CD at a powered computer in the same building or nearby. Shopping planning and container configuration do not require a supply ledger. Creating/editing physical shopping lists requires their writing supplies. Server options can disable either requirement. See [requirements, computer range and controls](docs/LEDGER_REQUIREMENT.md).

Craft a **Quartermaster Building Supply Sheet** from a sheet of paper or notebook and a retained pen/pencil. Right-click the carried sheet to record or resume a building or safehouse. Your character walks to storage and spends time documenting each physical compartment, including unconfigured storage. Floor loot, dropped bags and carried inventories are excluded.

Read the paper anywhere without electricity. It is a room-by-room historical snapshot with per-container recording times, quantities and locations. Completed entries survive cancellation; storage with uncertain identity after a restart needs reinspection.

Choose **Use computer (Windows '93)** at a supported powered desktop. Open **CD Writer** from the desktop or Start menu, choose a completed sheet and a vanilla CD, then explicitly write it; the paper is retained. Place the **Quartermaster Supply Ledger CD** in an accessible desk/container beside a powered desktop. Open **CD-ROM (D:)**, load that storage CD, then double-click **QUARTERMASTER.EXE** or choose **Run application**. The application opens inside the computer screen with item/FullType search, room browsing and pagination. Opening the desktop or loading a CD does not launch it automatically. Loading/ejecting binds/unbinds the real storage CD without moving it; the computer can remain available for sorting after you leave its screen. See the [computer controls](docs/WINDOWS93_COMPUTER.md). Copying overwrites that CD's original music identity. Historical pages enforce current safehouse/Rooms privacy; they do not provide live or remote inventory access. The initial supported terminal is the stock desktop using `appliances_com_01_72`.

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
- **Better Sorting, Better Containers and [Extended Categories](https://steamcommunity.com/sharedfiles/filedetails/?id=3650035249) are optional alternatives.** Quartermaster reads native category metadata. Better Containers and Extended Categories category clicks save explicit item selections so client-local categories do not control server classification. Reselect after changing category membership. Extended Categories declares Better Sorting incompatible; follow their load rules. Inventory presentation stays with the installed UI mods.
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
- [Artwork sources and exports](assets/branding/README.md)
- [Issues and feedback](https://github.com/B47ANCE/B47ANCEDQuartermaster/issues)

Dedicated multiplayer tests passed for the earlier Quartermaster build according to the owner's report on 2026-10-15; this does not validate the 0.12–0.14 development changes. Historical implementation and validation notes retain their original context in the repository and Git history.

**Mod ID:** `B47ANCEDQuartermaster`

**Workshop ID:** `3807217050`

Created by B47ANCE. Original Lua-only implementation; no third-party mod source or assets are bundled.
