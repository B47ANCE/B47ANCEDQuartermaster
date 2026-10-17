# Allocation integration — 2026-10-17

Project Version: 0.18.0-dev.1

MINOR development addition to 0.17.0-dev.1 default commit
1176c825b53ea7c1351fba9a5054ebb5d0ccc25c. Ported allocation candidate
910cb2b98359413f17f07bbaa85f520c4f2a59e1 without restoring its obsolete movement,
shopping, personal, Rooms or ledger contracts. Merge ancestry retains both heads;
original checkouts, instructions, settings and history are preserved.

## Resolution and preserved behavior

- Retain ledger 3/freshness, Windows'93 computers/CDs, physical Shopping Lists,
  carried list HUD, carry-first planning, native smaller groups, source returns
  and completed native outcome handling. Movement/personal/shopping/Rooms stay
  11/2/3/3; load-policy remains 1. Allocation adds wire family 1 and updates
  configuration/presets to 6/3 without downgrading any other family.
- Port sparse profiles, percentage UI, full Whole/child/preset persistence,
  revision/nonce checks, native-weight arithmetic and bounded advisory diagnostics
  together. Existing permissions, priorities, name rules, generation links and
  foreign ModData remain authoritative. See ALLOCATION_SYSTEM.md for recovery.
- Use current paired Rooms 0.2.0-dev.6, based on main
  fade0a0bf34c4cda6de0c1fd663c6d32eb17ef97. Designated UUIDs only; editor,
  permission copying, cleaning and safehouse contracts remain. No vanilla-room
  overrides are restored. Current Rooms omits nativeRooms; metadata discovery now
  accepts that omission while rejecting malformed supplied collections.
- Allocation editing requires current provider capabilities. Complete-footprint
  native configuration permission is separate from deposit/withdraw/inspect.
  Target membership does not disappear outside editor range. No client receives
  private occupancy data through allocation metadata.
- AllocationRuntime.enforcing()==false and live routing remain closed. No new
  inventory mutation or native interception claim is introduced.

## Reproducible offline validation

Use Python with Lupa 2.6 (Lua 5.1). Set PYTHONPATH to your developer-local dependency
directory if needed; never commit that directory. Supply the paired checkout:

```powershell
python -u -B tests/run_tests.py --require-rooms --rooms ../Rooms
python -B tests/benchmark_allocation.py
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
git -c core.safecrlf=false diff --check
# From the paired Rooms root:
python -B tests/run_tests.py
python -B scripts/check_versions.py
```

The existing Quartermaster native-source fixtures expect the developer-local
installed game path configured in tests/run_tests.py. Missing source is a blocked
suite, not permission to fabricate vanilla files or claim full PASS. A transient
unavailable game drive blocked the initial baseline; later unmodified runs used
the restored source. Lua-only syntax/require/case, 29-locale fallback parity,
source manifests, protocol preservation, legacy migration/backups, Whole/preset,
paired privacy/revisions/replay, carry/ledger/shopping and independent binary32
checks are offline evidence only. Current outcomes are recorded in the PR.

Native SP G6 and dedicated G7 NOT TESTED; stable G8 BLOCKED. No package, deployment,
Workshop upload, game/server launch, stable tag or saved-data mutation is part of
this integration. Historical reports retain their original version/environment.
