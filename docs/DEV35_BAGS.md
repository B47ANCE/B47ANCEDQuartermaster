# dev.35 Bags

[VERIFIED source] Reuse B47_ContainersBags, with Clothing as the first parent and Containers retained as a compatibility parent. The existing Model tree chooses the first available family parent, placing Bags under Clothing & Accessories. Label is Bags in all 29 fallback translations. No duplicate Bags item category, new category ID, item migration or native metadata change. Existing bag selections remain intact; broad Clothing now covers bags, while existing broad Containers rules retain coverage. Bandoliers/holsters/pouches remain Equipment Accessories. No bag armor category is introduced without applicable definition evidence.

Compatible hierarchy/label correction in the ongoing 0.4.0 prerelease series: canonical 0.4.0-dev.35 with synchronized current mirrors. State ownership remains existing server-authoritative sorting configuration/shared classification, with client-local presentation. Match builds on client/server. No new protocol, schema, networking, persistence, sandbox option, discovery, routing or transfer changes.

[TESTED offline] Full suite PASS, including canonical bag ID, primary parent, saved narrow Bags rule, both Clothing and Containers family membership and all 29 language tables. 5,092 corpus items unchanged from dev.34; same 562 cumulative reviewed deviations from the retained historical baseline. 98 physical leaves, 136 supported IDs and 22 legacy aliases unchanged. Native UI acceptance NOT TESTED.

Exact commands using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe from this project:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev35-vanilla-diff.json --approved-changes docs/DEV34_APPROVED_TAXONOMY_CHANGES.json
```

All PASS offline. Logs: dist/handoffs/dev35-tests.log and dev35-vanilla-diff.json. G6 NOT TESTED, G7 BLOCKED / NOT TESTED, G8 BLOCKED. No package/deployment/staging/publication requested/performed. No third-party source/data/assets used.
