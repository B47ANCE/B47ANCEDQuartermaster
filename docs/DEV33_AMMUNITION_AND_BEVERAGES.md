# dev.33 ammunition and beverages

Requested hierarchy:

- Ammunition → Containers / Boxes & Cartons / Loose Ammo / Magazines & Clips
- Beverages → Alcoholic / Soda / Water / Empty Water Containers / Milk / Other Drinks
- Books (renamed broad Books and written material)
- Bandoliers → Clothing / Accessories

[VERIFIED installed source] Reusable ammunition cases are container definitions tagged ammocase; packages are normal items with opening recipes/tags. All five vanilla bandoliers use body location base:ammostrap, including the three without ammocase. That location takes precedence over ammunition/bag rules in both canonical and broad membership resolution.

[VERIFIED owned implementation] Retain B47_AmmoBoxes for Containers, add B47_AmmoPackages for Boxes & Cartons. Old AmmoBoxes rules therefore now refer to reusable containers only; add Boxes & Cartons to cover packaged supplies. Loose/magazine IDs unchanged. Broad Ammunition retains all four leaves; it no longer selects bandoliers. Native item metadata and container-transfer semantics remain untouched.

BeveragesWater and BeveragesOther become physical leaves again; Soda, Milk and Empty Water Containers are new leaves. Existing B47_BeveragesNonAlcoholic remains a hidden saved-rule family with coverage of those five non-alcoholic leaves. Alcoholic is excluded. Existing explicit item rules and broad Beverages rules remain valid. No new item migration is required; unknown preserved saved rules use the existing server validation. Use matching builds on client and server.

Soda/milk/water classifications use declared initial fluids, never current runtime contents. Random fluid choices enter a specific leaf only when every declared option agrees; mixed choices retain existing conservative classification. Milk food and vanilla canned-milk families are recognized using existing metadata-gated evidence. Juice, tea/coffee and mixed non-alcoholic drinks retain Other Drinks, per user clarification. Water-filled bags retain Bags. Empty Water Containers requires an empty fluid-container definition with WaterContainer semantics or waterbottle tag; generic material jars remain Fluid containers. Refillable bottles do not switch categories when consumed/refilled: classification remains stable by ScriptItem identity.

[TESTED offline] Full regression suite PASS, including category coverage, four beverage-specific paths, mixed/random fluids, generic jar/hydration-pack exclusions, bandolier canonical/broad exclusion from Ammunition, existing Non-alcoholic Drinks family coverage, migration and all 29 localization tables. 86 physical leaves, 124 supported IDs, 22 legacy aliases. Historical frozen baseline retained; 5,092 items before/after, 119 explicitly reviewed cumulative deviations: 26 from dev.31/dev.32 plus 93 in this pass. These include 18 ammunition packages, five bandoliers and 70 beverage/container definitions.

Exact commands, from this project using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev33-vanilla-diff.json --approved-changes docs/DEV33_APPROVED_TAXONOMY_CHANGES.json
```

Logs: dist/handoffs/dev33-tests.log and dev33-vanilla-diff.json. Canonical 0.4.0-dev.33 is a compatible extension within the 0.4.0 prerelease series; all current version mirrors synchronized. Routing/discovery/transfer/protocol/schema remain unchanged. No third-party implementation/data/assets used. No sandbox setting is appropriate for this fixed category-definition correction. Authoritative shared sorting configuration still belongs to the server; clients own UI presentation only.

Native SP/dedicated MP acceptance NOT TESTED. G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No package, deployment, staging or publication requested/performed.
