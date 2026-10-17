# Ledger modes and scoped sorting

Project Version: 0.18.0-dev.8

Inventory and selected-container Sort do not need a ledger, including supported ground/proximity/vehicle sources. Room/Building Sort includes carried inventory and requires fresh location knowledge by default. Shopping planning/physical papers remain independent; collection retains its separate server requirement. Native capacity, access, routing, smaller transfer groups and timing are preserved.

## Server settings

| Setting | Default | Behavior |
| --- | --- | --- |
| LedgerMode = 1 | Periodic live | A completed inspection is fresh for LedgerUpdateDays. While fresh, show current confirmed contents of its recorded compartments. After expiry, show its original historical snapshot. |
| LedgerMode = 2 | Disabled | No supply-ledger inspection, reading, crafting, CD writing/mounting or computer UI. Bypass ledger prerequisites. Preserve items, snapshots and drive records for re-enabling; physical Shopping Lists remain functional. |
| LedgerMode = 3 | No updates | Completed ledgers never expire and show live statistics. Initial physical recording is still required for scoped operations. |
| LedgerMode = 4 | Historical | Show actual recorded quantities, not current stock. A record can be inaccurate immediately after storage changes; it remains eligible until the update interval expires. Outdated pages stay readable. |
| LedgerUpdateDays | 7, integer 1–365 | In-game days after completed inspection; applies to Periodic and Historical modes. Exact expiry is finished + days × 24 world hours. |
| LedgerComputerManualUpdates | true | On: record storage and write/load a new CD when expired. Off: a completed building CD at a powered authorized computer inside that exact recorded building provides live statistics and knowledge without expiry, even in Historical mode. Off-site/safehouse-wide CDs stay historical under ordinary expiry. Does not rewrite paper/CD history. |
| RequireLedgerForSorting | true | Existing identifier/values retained; now applies only to Room/Building Sort. |
| RequireLedgerForCollecting | true | Existing collection requirement retained. |
| LedgerComputerRange | 10, integer 1–30 | Existing nearby same-floor range outside the work building. Same-building providers retain their existing behavior. |

Mode numbers correspond to the user's requested four ledger types. Computer updating is a separate boolean. These are authoritative SandboxVars, with native enum/integer/boolean definitions and English fallback names/tooltips/options across all 29 locale folders. Invalid new values fall back to defaults. No client-local setting can grant gameplay access.

## Current same-building restriction

As of 0.18.0-dev.7, all computer live reads require a match between the actual computer's native-building signature and the snapshot's saved building signature. A nearby computer in another building, an outdoor computer, or a safehouse-wide CD gets no computer freshness exemption and no live projection, including in No updates mode. Ordinary ledger freshness still applies; the record stays readable with existing privacy checks. An unexpired nearby historical CD can still satisfy the existing scoped requirement; an expired off-site CD cannot. Safehouse records have no unique building and fall back conservatively. Carried paper retains the chosen ledger mode. [Implementation and current evidence](CLIPBOARD_AND_LOCAL_COMPUTER.md).

## Existing records and renewal

No schema rewrite or deletion is needed: Ledger schema 1 already stores `finished` in server world-age hours, individual recording times, server item bindings, scope signatures, entries and revisions. Existing booleans are preserved. Missing new settings use Periodic/7 days/manual computers. A prior completed record may already be expired under these new defaults. Nonfinite, missing or future completion times cannot prove freshness. A stopped/partial/limited record never qualifies, including in No updates mode.

Updating a completed paper allocates a new snapshot generation, walks to storage and uses the existing native inspection actions. The old snapshot remains in server history. CDs keep their original generation; updating a paper does not silently update an older CD. An interrupted renewal remains partial and resumable. The existing 2,048-snapshot resource bound includes preserved generations; there is no implicit history pruning. Changes to scope signatures still require valid matching location coverage.

Disabled mode cancels inspection work and clears ephemeral readers without leaving an actor lock that blocks independent Shopping Paper creation. Burn/inspection completion revalidates policy; physical Shopping Paper grants remain independent. Items/data are retained, not destroyed. The supply-sheet recipe uses the installed native CraftRecipe `OnTest` convention; disabled mode refuses it while preserving its item definition for save loading.

## Live display and privacy

`LedgerLive.lua` builds an ephemeral, actor-private projection. It resolves each recorded physical object/compartment, verifies its persisted incarnation marker and exact current native identity, then reuses `ContentAnalysis` against confirmed inventory instances. It does not mutate items, saved snapshots, drive media or appearance. Planned/native-in-flight transfers are never credited as completed stock.

Work is request-driven, with at most 16 pending readers. The existing 250 ms ledger tick advances at most four reader jobs, with a 4 ms deadline between bounded steps. Analysis/verification and row aggregation use slices of at most 64 instances. Existing bounds apply: 4,096 instances/compartment, 32,768 projected rows/session, 32 returned rows/16 KB per response and opaque pagination. No inventory scan runs in render or per-item transfer code. First-page construction can span ticks; the five-second refresh epoch begins only after a page is successfully served, so a large first analysis cannot repeatedly expire itself. Expired live cursors return Page Changed and the UI reloads the current result set.

Read permissions are checked again for every page, including cached rows. Safehouse and Rooms policies remain authoritative. New jobs, targets, grants and power/CD bindings revalidate independently. Unloaded/replaced/denied storage is never described as live: the reader reports unavailable/changed or redacts it. Live mode covers **recorded compartments**, not newly installed or newly placed storage; physically update the ledger to include those. Live values may lag by the bounded refresh/analysis interval and are not a remote inventory interface. No native tick/frame/network performance claim has been measured.

## Scoped transfer authorization

The server checks knowledge before area discovery and Trip Begin/Next, at source/destination selection, and before new native TAKE/PUT grants. The server's area context is retained on every operation, including carried items in an area sweep and spill destinations. Manual Sort retains all existing physical/native/Rooms checks, with no ledger prerequisite.

Expiry, paper loss, power/CD loss or permission changes stop new scoped grants. Already completed native transfers, confirmation, cancellation and permitted source-return paths remain valid. Lua cannot retract a native transfer already dispatched or impose a ledger requirement on unrelated vanilla transfers; this accepted native boundary is unchanged.

Capabilities are now movement 11, Ledger 3 and Rooms 4; Shopping remains 3 and Personal 2. Server and clients must use the same build and reconnect. Storage/profile schemas remain unchanged. No Java, upstream edits, external mod implementation/assets, deployment or publication are part of this iteration.

## Validation

[VERIFIED SOURCE] Existing local Build 42.21.0 Lua APIs are reused: world-age time, exact native item/container/object identity, exposed ISUI controls, native timed actions and CraftRecipe OnTest. The installed native SandboxOptions enum UI uses an ISComboBox. Historical native fingerprints remain tied to their original audited versions.

[TESTED OFFLINE] `test_ledger_freshness.lua` uses actual production inspection/conversion to establish bindings before testing all four modes, defaults/invalid settings, exact expiry/future timestamps, manual Sort without proof, area refusal, live stock changes, revoked permissions, immutable historical data, native renewal and old CD preservation, automatic computer eligibility/reads, power/CD loss, disabled/re-enabled persistent drive data, a slow first-page analysis exceeding five seconds, disabled-job cleanup and older-peer refusal. A dedicated-shaped native challenge/confirmation/completion fixture also creates a Shopping Paper while supply ledgers are disabled. Existing requirement tests retain positive TAKE/PUT/return/observation and scope/privacy cases. Ledger UI regressions include menu suppression, disabled-open refusal and active-screen closure. The full offline suite includes actual Rooms source and installed native Lua transfer fixtures.

Run from this worktree with the bundled Python (`C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`, UTF-8 enabled):

```powershell
python -B tests/run_tests.py --require-rooms --rooms 'C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories/B47ANCEDRooms'
python -B scripts/check_deployment.py
python -B scripts/check_versions.py
git -c core.safecrlf=false diff --check
```

Source inventory: 211 runtime files. This is a MINOR development iteration targeting 0.17.0 after acceptance (no stable release approval implied), from `2cac3ae5497bdbf793e119d12f3ef61ceb457457`, in `feature/ledger-freshness`. The published 0.16.0-dev.2 package and its exact provenance remain untouched in the prior worktree. No current package is produced; absent-package checks are deferred, not package verification. Startup fetch verified the base feature branch exact at 2cac3ae5497bdbf793e119d12f3ef61ceb457457 (0 ahead/0 behind). Freshness remained REVIEW against the older remote default (40 ahead/1 behind): missing commit 0c343ed changes only README, changelog, version inventory and a historical README copy. Its documentation differences were reviewed; no omitted runtime changes or unfinished Git operation were found. No branch was auto-merged or reset.

[RUNTIME GATE] Native G6 NOT TESTED. Dedicated G7 NOT TESTED/BLOCKED; stable G8 BLOCKED. Two remote clients must verify modes/defaults/options changes, long inspections, expiry while walking/transferring, manual vs scoped Sort, live refresh/pagination, server performance, private Rooms/Safehouses, simultaneous CD changes, canceled renewal, item conservation, reconnect, actual world-age persistence across save/restart, disabled recipe/menu behavior and Linux case safety. Offline results are not native MP evidence.
