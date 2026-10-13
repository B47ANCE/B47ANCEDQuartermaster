# dev.37 floor controls and startup

Compatible PATCH correction in the ongoing prerelease series: 0.4.0-dev.37.

[VERIFIED source] Native ISLootWindowContainerControls uses a separate AddFloorHandler registry for floor containers. SortControls previously registered only inventory and object handlers. Register the same owned intent handler with the native floor registry. Floor and parentless aggregate controls remain visible when their lists temporarily become empty. Ordinary empty containers retain their previous behavior.

[VERIFIED runtime failure] The attached 42.21 multiplayer report contains BatchExecutor.lua:5 indexing a nonexistent Executor table during startup/ResetLua, followed by Sorter.lua:66 calling the missing batchSupported function. BatchExecutor now establishes the shared executor table and explicitly loads its native action dependencies. Executor preserves that table. The report also includes the scope-menu parent error addressed in dev.36. The inspected console identifies client/server dev.30; it does not prove acceptance of these fixes.

[TESTED offline] Full suite passes, including loading BatchExecutor before Executor, preserving its methods/table, registering the floor handler, and stable button visibility through alternating empty floor/aggregate lists. No shared gameplay ownership, transfer validation, persistence, protocol, taxonomy or sandbox behavior changes. No third-party implementation copied.

Exact validation commands, using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe from the project directory:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev37-vanilla-diff.json --approved-changes docs/DEV34_APPROVED_TAXONOMY_CHANGES.json
```

Regression log: dist/handoffs/dev37-tests.log. [INFERRED] Missing floor registration and transient emptiness can explain the reported absent/flickering button. [RUNTIME GATE] Actual Proximity Inventory replacement renderer compatibility remains unverified. Retest matching client/server builds: floor/proximity controls before transfers, during list refreshes, after transfers and with controller controls; start Sort and confirm no startup/missing-method exceptions. G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No package, live deployment or publication performed.
