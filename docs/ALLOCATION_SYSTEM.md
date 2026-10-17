# Advisory allocation system

Project Version: 0.18.0-dev.7

Current designated-only scope correction: native room selectors/requests are retired; B47ANCEDRooms designations provide room identity and native buildings provide building scope. Quartermaster Rooms capability is 4; movement remains 11. Existing ledger signatures, upstream complete-footprint configuration permission and provider-capability checks remain. Enforcement/live role routing stay disabled. [Exact validation and limitations](DESIGNATED_ROOM_SCOPES.md).

This is a development foundation. AllocationRuntime.enforcing() returns false;
live role routing is closed. Legacy/native sorting, carry filling and completed
transfer handling remain authoritative. Shadow failures cannot deny a legacy
transfer. Native SP and dedicated multiplayer NOT TESTED; G7/stable G8 BLOCKED.

## Profiles and editing

One sparse profile supports category IDs and exact item FullTypes, 0–100 percent,
inheritance, explicit aggregate ceilings, Mixed display state and preserved orphan
keys. Missing values inherit; explicit 0 is a hard ceiling in the advisory model.
Category edits propagate through the profile without changing legacy checkbox
rules, exact-name priorities or generation-linked presets. UI changes are staged;
percentage controls, reset, exact input, Whole/child edits and cancellation do not
write until Save. They do not change physical storage or move inventory.

Configuration protocol 6 and preset protocol 3 require matching peers. Other
families retain movement 11, personal 2, shopping 3, ledger 3, Rooms 4 and
load-policy 1. Saved container schema 2 is read without schema-only rewriting;
explicit saves write schema 3 with the original envelope retained in owned
allocationBackups. Preset schema 1 similarly upgrades on writes to schema 2 with
presetAllocationBackup. Whole parent schema 1 is read; explicit saves write schema
2 while retaining the original parent. Legacy sorting retirement keeps its
existing rules and recovery snapshots. Foreign ModData and independent ledger,
shopping-paper, carry and personal roots are preserved.

Older writers do not understand these fields. Downgrade requires offline
restoration from pre-migration backups and the matching old source; automatic
downgrade is unsupported. Use disposable fixtures, never real player saves, for
destructive migration or rollback tests. Lua reload is not disk/save proof.

## Room profiles and permissions

Current Rooms supplies designated UUIDs, geometry, type/designation and independent
action permissions. It must advertise designatedRooms=true, nativeOverrides=false,
roomDesignations=1 and storageScopes=1. Retired native-room overrides are not
restored. Old native/alias profile data is retained but cannot grant a new current
room identity. Room metadata changes never grant inventory access.

Quartermaster owns ModData.B47ANCEDQuartermaster.roomAllocations, schema 1, with
profile/library revisions, owner, generation links, active flag, priority and
Primary/Secondary thresholds. Editing requires metadata policy authority and
native configure permission across the complete loaded footprint. Target-based
storage membership is independent of editor range; stale revisions fail closed.
Malformed providers and unavailable permissions are not treated as empty rooms.

The room editor reuses the allocation picker. Presets use actual native category
identities; missing mappings are reported rather than guessed. Defaults for new
profiles come from authoritative sandbox PrimaryOverflowAt=60 and
SecondaryReturnAt=80 (0–100). Existing explicit thresholds survive default changes.
AllocationMode is Off or Shadow (default Shadow). Thresholds describe advisory
Primary/Secondary preference only, not activated gameplay routing.

## Capacity, admission and privacy

Snapshots reconcile actual instance weights using native-shaped binary32
accumulation and native capacity getters. Nested weight is included once; physical
compartments are deduplicated. Quota arithmetic uses C*P/100 without rounding up.
Missing getters, unloaded geometry, changed lists, inconsistent weights or work
limits yield UNKNOWN, never partial quota authorization.

Bounds are technical safety limits: 256 compartments, 4,096 items per compartment,
32,768 total items, 16 active overlapping profiles and an 8 ms work window.
Opaque private stock contributes conservative occupancy, never disclosed capacity
or an accessible destination. Metadata edits read no private contents. Inspection
requires inspect permission. Room summaries do not return opaque item identities,
counts or coordinates. Existing excess stock is never deleted, evicted or dropped.

Internal admission tests cover exact server-held refs, current access/revisions,
cross-actor reservations, replay and expiry. Unknown issued PUTs retain reservations
until authoritative observation or expiry. No direct inventory mutation, universal
vanilla interception or final-native security guarantee is claimed. Production
admission hooks cannot execute while enforcing() is false.

Shadow planning samples at most once per actor per two seconds, eight queued
globally. Cooperative scans use four jobs/64 steps in a shared 4 ms tick window.
Changed sources are discarded as unknown. Diagnostics are SP/admin only and
bounded aggregate counters. Advisory ranking preserves exact rule rank and hard
container priority before role preference; live routing is unchanged.

## Validation

See [ALLOCATION_INTEGRATION.md](ALLOCATION_INTEGRATION.md) for the current source
baseline, paired commands, preservation tests and evidence limits. The original
0.8 baseline in ALLOCATION_BASELINE.md is historical. No prior host benchmark,
package, Workshop success or older runtime evidence is current acceptance.

Remaining runtime gates include native capacity modifiers/special containers,
two-client reservation exhaustion and late cancellation, conservation, geometry
changes while walking, native UI/controller/fonts, optional-mod parity, real save,
join/rejoin and dedicated restart. Enforcement requires separate validated work.
