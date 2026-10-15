# Auto Clean offline authority experiment

This directory is outside packaged `src` and is not a runnable mod. It has no
Mod ID, sandbox registration or persistent save data. Requiring its modules
does not register events, classes or network handlers. Do not copy it into a
live installation. No game/server execution, deployment or publication is
authorized by this experiment.

`NativeWire.lua` now supplies explicit server/client installers for the native
command and timed-action paths. `ServerTransport.lua` preserves the server-held
guarded action on reconstruction, then requires a fresh confirmation from the
connection-bound `OnClientCommand` player before mutations. `NativeAction.lua`
provides the shared fixed constructor and preserves raw native callback fields;
`ClientTransport.lua` queues presentation and sends intent only. Plain `Poc`
instances must still never be submitted directly through native transport.

The server-selected fixture uses an empty 10 L bucket, 10 mL pure bleach first,
then native water filling, then one native blood-cleaning action. Supplies are
already carried; the water source and full cleaning footprint must be accessible.
It has no dependency on Quartermaster room code or the separate Rooms project.

See the [native transport report, exact offline commands and remaining gates](../../docs/audits/AUTO_CLEAN_NATIVE_TRANSPORT.md).
The [earlier guard milestone](../../docs/audits/AUTO_CLEAN_GUARD_IMPLEMENTATION.md)
and its evidence retain their historical version and activation boundaries.

## Clean Building integration

`BuildingWire.lua` now connects one localized Clean Building context action to
`BuildingJob.lua` and `BuildingNative.lua`: actual Rooms building scope and clean
permission, bounded configured-storage survey, exact native supply fetching,
normal walking/equipment, bleach-first preparation, target sequencing/top-ups,
and eligible original-storage returns. The class/command guard above still
owns the final mutations. Client movement never counts as server arrival.

Only explicit installers exist; there is no automatic entry point or Mod ID.
This remains offline research outside packaged `src`. Do not install it as a
live mod. The one-click workflow is tested in a simulated engine/network, not in
PZ. See [building integration, settings, exact commands and limitations](../../docs/audits/AUTO_CLEAN_BUILDING_INTEGRATION.md).
