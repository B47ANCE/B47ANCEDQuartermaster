# dev.32 woodworking label and rings

[VERIFIED source] ToolsCutting retains its stable B47_ToolsCutting ID and membership; all 29 translations now display Woodworking Tools. There was no Jewelry leaf; B47_ClothingJewelry is added under Clothing, classified using normalized right/left middle-finger and ring-finger native body locations. Existing necklaces, earrings and other accessories remain in Accessories. Key rings remain unaffected. Native item/script metadata is unchanged.

[TESTED offline] Full regression suite passes, including all four finger slots, namespaced modded metadata, key-ring exclusion, category coverage, saved-rule handling and 29-language parity. Native corpus remains 5,092 items: 24 finger-ring variants move from Other clothing to Jewelry, plus the two previously approved scissors moves. No other membership differences. Physical leaf count is 81; supported IDs 120; legacy aliases 24. The historical frozen baseline is preserved and exact cumulative deviations are explicitly inventoried in DEV32_APPROVED_TAXONOMY_CHANGES.json.

Compatible extension in the ongoing 0.4.0 prerelease series, canonical version 0.4.0-dev.32. Existing category IDs/explicit item selections remain valid. Other clothing rules no longer cover rings; broad Clothing still does. Shared sorting configuration remains server-authoritative through unchanged validation/synchronization. New Jewelry is recognized by the existing category-rule validator and catalog. No new gameplay option, networking, persistence or protocol/schema change. Clients and server must use matching builds for classification consistency.

Exact commands from this project, using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev32-vanilla-diff.json --approved-changes docs/DEV32_APPROVED_TAXONOMY_CHANGES.json
```

Logs: dist/handoffs/dev32-tests.log and dev32-vanilla-diff.json. Native SP/dedicated testing NOT TESTED. G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No package, deployment, staging or publication requested/performed.
