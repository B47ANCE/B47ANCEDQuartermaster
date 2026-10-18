# Stock goals and Base Ledger

Project Version: 0.23.0-dev.1

Compatible MINOR development: server-owned shared Stock goals and read-only
multi-CD/Base Ledger views. Requires paired PC Framework 0.11.0-dev.1 (Connections
and Notification APIs 1), Rooms 0.2.0-dev.7 schema 2 and UI 0.3.0-dev.1 API 1 for
the current checked offline combination. Existing UI Workshop item: 3822582242.
Prepared for authorized MP testing; upload receipts are separate from runtime proof. Existing Movement 12, Ledger 5 and personal list schemas
remain unchanged; new Stock and BaseLedger command families are version 1.

## Stock workflow

Open **Stock** in the normal Quartermaster menu. Choose the native building or a
B47ANCEDRooms designated room, add exact item types and set minimum quantities.
Edit or remove a target in the same window. These are shared location goals,
not personal Needed goals, reservations, sorting rules or automatic orders.
They do not move, create or reserve inventory. Duplicate display names retain
separate FullType identities. A target of zero removes it; accepted targets are
1–1,000,000 items.

Open a paper ledger or the installed PC application, then **Stock**, to see
Item / Current / Target / Remaining. Current is the authorized ledger's count;
Remaining is max(0, target − current). Paper reports are readable snapshots,
with no automatic notifications or editing privilege. Existing ledger freshness,
coverage and read permissions still apply. Historical, incomplete or redacted
data is never advertised as a complete live shortage report.

The retained PC ledger app checks its known building/room goals periodically.
Only complete, fresh, live, server-approved results generate a low-stock notice
through Framework Notification API 1. The taskbar notice opens the appropriate
Stock scope. Stable IDs suppress repeated toasts while the same shortage remains;
recovery dismisses it, a new shortage alerts again. Permission/errors/history
clear notices. Monitoring ends when the app/PC session closes; there is no global
HUD alert, unloaded-world service or simulation running without a PC app.

## Multiple CDs and Base Ledger

The digital reader offers **This CD**, **Latest local CDs** and **Base ledger**.
Run the installed Quartermaster application using the existing real-media flow.
The latter views discover genuine ledger CDs in accessible storage beside each
contributing PC; they do not burn, move, mount or modify those CDs.

Same-area copies resolve to the newest completed snapshot, then highest revision,
then stable native item ID. Future/invalid completion times are rejected. Each
area appears once; overlapping physical storage rows are deduplicated. Different
areas contribute only through a loaded, powered, authorized PC **inside that
exact native building**, with Quartermaster installed and its own local covering
ledger CD. An off-site copy alone does not supply live data for another building.
Existing single-CD historical/off-site access is preserved.

Use Framework's **PC Network** app: start pairing at one PC, visit another and
enter the first address. Public PCs allow address-based pairing without a private
invitation. Multiple connected PCs form the Base view. Its Network Status screen
shows online and offline/unavailable endpoints. Pairing links PCs, never grants
inventory or Rooms permissions. An offline, private, unloaded or missing-CD
endpoint is excluded; the resulting Base view is marked partial. Stock goals
stay per building/room, not a combined target accidentally applied to the union.

Live versus historical behavior still comes from authoritative ledger sandbox
policy, including manual CD update requirements. Changing views never modifies
saved snapshots. Loss of media/power/access invalidates contributions before a
cached view can be returned. New-CD discovery is cached for up to ten seconds;
permission and selected-media validation are not skipped during that interval.

## Authority, persistence and privacy

Clients send intent only. Server Stock schema 1 uses ModData
`B47ANCEDQuartermasterStock`: native building signatures or `room:<UUID>` keys,
revision and sparse FullType targets. CAS revision, server-derived scope identity
and current configure permissions prevent stale writes, including walking into
another building before Save. Reads require inspect permission. Room stock uses
the owned Rooms validated schema-2 Registry/Geometry/Policy, including delegated
private-room inspection, rather than applying editor distance limits to a remote
loaded Base area. Unknown/missing permission services fail closed. No geometry
or room ownership is copied into Quartermaster.

Existing sorting/preset/personal saves are untouched. New stock storage starts
empty; corrupt/unknown schemas and missing modded FullTypes are preserved safely.
Unknown item definitions cannot be added as new targets. A service reload fixture
checks persistence; actual dedicated restart remains untested.

Counts use separate server ledger readers and the existing authorized projection.
No client-provided counts/cursors decide totals. Any redacted storage makes the
Stock result unavailable rather than revealing a partial total as zero. Every
finished sampling round releases its projection so later checks observe confirmed
changes, not an indefinitely retained inventory cache. Final checks revalidate
physical storage and room revisions. Base views are ephemeral; no network payload
includes internal building signatures or private server snapshots.

## Settings and bounded work

Server options: `StockEnabled=true`; `StockCheckSeconds=30` (5–300 seconds between
complete scope rounds); `LedgerMultipleCDs=true`. Turning them off preserves
records and ordinary single-CD behavior. For multiple scopes, checks are
staggered with bounded waiting retries; the interval is not a real-time guarantee.

Technical limits: 256 profiles, 64 targets/profile; 16 active stock readers;
four ledger pages and 64 final permission checks per request; 120-second work
expiry. Base limits: 32 PCs via Framework, 128 source CDs, 4,096 compartments,
32,768 rows, 256 ephemeral area tokens, 16 jobs. Media traversal is incremental;
no full inventory scan runs per render frame. Technical caps fail explicitly,
not by inventing counts. No native performance improvement is claimed.

## Validation

[TESTED OFFLINE — Windows, Python/Lupa Lua 5.1] Commands from the repository root:

```text
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
python -B tests/run_tests.py --only-stock --ui <UI> --pc-framework <PC Framework>
python -B tests/run_tests.py --require-rooms --rooms <Rooms> --ui <UI> --pc-framework <PC Framework>
```

The focused fixtures use production Stock, BaseLedger, ledger reading, physical
drive scanning, actual stock UI and notification consumer. They cover exact
FullType/CAS/scope identity, history/privacy/partial refusal, new sampling after
inventory changes, two paired native-shaped buildings, newest-CD dedupe, CD/power
loss, missing local copy, paper read-only focus, stale callbacks and notification
recovery/repeat suppression. Framework independently checks status/pairing,
component caps and notification lifecycle. Static checks retain Lua-only, path
case, exact runtime inventory and 29-locale English fallback parity.

The read-only GitHub workflow pins the exact Framework/Rooms/UI source commits.
It uses `--stock-service-contracts` for server Stock/Base fixtures with independent
host action scaffolding, because proprietary PZ files are unavailable on hosted
Linux. This explicit mode does not run native timed-action source or Stock UI;
the local full/focused suites above do. It has no Workshop, server or deployment
credentials. Host CI results remain separate from local tests and runtime gates.

[RUNTIME GATE] Native SP, font/controller/layering, actual remote two-client
privacy and simultaneous goal edits, pairing across chunk unload/reload, PC/CD
loss, latency, reconnect and dedicated persistence/restart NOT TESTED. G7 and
stable-release G8 BLOCKED. Existing published-build acceptance is not evidence
for these new gameplay paths. Current distribution is recorded separately in WORKSHOP_STOCK_TESTING_2026_10_18.md; native acceptance remains pending.
