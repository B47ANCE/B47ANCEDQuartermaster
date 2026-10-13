# dev.31 Stationary correction

[VERIFIED installed B42.21 source] Base.Scissors is ordinary Scissors; Base.ScissorsBlunt is Safety Scissors, confirmed by native ItemName.json. Base.ScissorsBluntMedical is Medical Shears and is outside this request.

[TESTED offline] Both requested full types now use the existing Stationery override/destination. Player label is exactly Stationary, as requested, across all 29 fallback language tables. B47_Stationery remains unchanged, preserving existing category rule identifiers. Native item/script metadata, taxonomy hierarchy, protocol, schema, routing and transfer code are unchanged. No third-party material used.

This is a compatible correction in the ongoing 0.4.0 prerelease series: canonical development version 0.4.0-dev.31 and current mirrors synchronized. Historical dev.30 artifacts moved to dist/history/0.4.0-dev.30 unchanged. Historical membership baseline retained; exactly two user-approved deviations in DEV31_APPROVED_TAXONOMY_CHANGES.json. Previously selecting Cutting Tools alone will no longer include these two items; explicit item selections remain intact.

Exact validation commands, using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe from this project:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev31-vanilla-diff.json --approved-changes docs/DEV31_APPROVED_TAXONOMY_CHANGES.json
```

Full offline suite PASS, version consistency PASS, membership comparison PASS: 5,092 before/after, exactly two approved changes, no others. Regression fixture verifies shared canonical resolution and selection memberships. Translation parity checks cover all 29 folders. Log: dist/handoffs/dev31-tests.log.

State ownership remains the existing server-authoritative sorting configuration; both peers require the same build for canonical classifications. This change creates no new network state, persistence or sandbox option. Native SP/dedicated MP behavior is NOT TESTED. G6 NOT TESTED; G7 BLOCKED / NOT TESTED; G8 BLOCKED. No package, deployment or publication requested/performed in this pass.
