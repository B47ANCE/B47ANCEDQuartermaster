# dev.39 inventory menu opener

Compatible PATCH UI fix in the ongoing 0.4.0 prerelease series: 0.4.0-dev.39.

[VERIFIED source] ConfigureControls previously registered in the native loot-object control list and required an eligible world container. It now registers only in ISInventoryWindowContainerControls. Visibility depends on a live local player and the existing compatibility gate, never inventory contents or the displayed carried bag. Keyboard/mouse and the native handler's controller menu use the same target-free opener. Native UI creation may temporarily have no displayed container; vanilla builds controls after that initialization.

MultiContainer and Session now support an absent initial container. Discovery still sends the player's location through the existing server-authoritative discover command; no invented target, shared-state mutation or authority bypass. Existing explicit-object openers still validate their supplied origin. Save is disabled until selecting a server-discovered target. No new gameplay settings, protocols, persistence or localization keys. Sort controls and world-object right-click navigation are preserved.

[TESTED offline] Regression checks inventory-only handler registration, visible empty/unbound inventory, target-free nearby discovery and disabled Save without a selected target. Existing explicit-object, scope, staged edits and authority regressions remain included. Commands using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe from the project:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev39-vanilla-diff.json --approved-changes docs/DEV34_APPROVED_TAXONOMY_CHANGES.json
```

[RUNTIME GATE] Native inventory footer/controller visibility with empty inventory, carried-bag tab, no nearby destinations and active UI mods. Source change is local presentation/navigation through existing gameplay authority; G7 N/A for this slice, but existing dedicated gameplay gates remain BLOCKED / NOT TESTED and project G8 BLOCKED. No package, live deployment or publication. Offline results are not native acceptance.
