# dev.34 Clothing & Accessories

Requested regular sections: Accessories, Equipment Accessories, Jewelry, Gloves, Headware, Shirts, Pants, Undergarments, Footware, Eyeware, Outerware, Other Clothing, Costumes. Labels follow the user's spelling exactly.

Armor sections: Equipment Accessories - Armor, Gloves - Armor, Headware - Armor, Shirts - Armor, Pants - Armor, Undergarments - Armor, Footware - Armor, Eyeware - Armor, Outerware - Armor, Other Clothing - Armor. These are separate physical item categories under Clothing, paired with regular sections as requested; selecting regular Outerware does not select Outerware - Armor. Decorative Accessories/Jewelry and Costumes have no separate armor leaf. Protective collars/wrist equipment use Equipment Accessories - Armor. Unrecognized protective slots fall back to Outerware - Armor; explicitly armor-tagged modded clothing with unknown slots uses Other Clothing - Armor.

[VERIFIED installed native definitions] Armor identity uses explicit DisplayCategory ProtectiveGear; modded clothing can also use namespaced armor tags. Minor ScratchDefense/BiteDefense values alone do not establish armor. Body-location metadata chooses the slot. Existing ClothingProtective ID becomes a saved-rule alias; historical membership is retained on protective definitions so old protective selections still match armor across slots. Native item/script metadata is never mutated.

Eyewear is separated from the former Headwear merge. Masks remain Headware, socks remain Undergarments, skirts/dresses remain Pants according to the existing slot rules. Equipment Accessories uses ammo straps, holsters, belts and wearable pouches; jewelry uses fingers, ears, necklaces and wrists. Existing narrow category rules now cover regular items only; select the relevant armor leaf where desired. Broad Clothing covers all clothing/armor leaves. Explicit item selections remain intact.

Costumes uses eight verified vanilla definitions: Spiffo head/suit/tail, bunny suits black/pink, bunny tail and bunny ears black/white. No blanket Spiffo-name heuristic: ordinary logo shirts/caps remain normal clothing. Explicit costume/mascot tags support compatible modded clothing.

[TESTED offline] Full regression suite PASS, exact 13 regular plus ten armor clothing leaves, all armor slots, explicit modded armor metadata, regular/armor separation, preserved old protective rules, equipment/jewelry mappings, eyewear, costume and branded exclusions, migration/category coverage and all 29 language tables. Native corpus comparison: 5,092 before/after, 562 reviewed cumulative deviations including prior category passes. All 290 native ProtectiveGear items map to armor leaves: 224 Outerware, 56 Headware, six Gloves, one Pants, one Eyeware, one Equipment Accessories, one Undergarments. Historical frozen evidence retained; exact current exceptions in DEV34_APPROVED_TAXONOMY_CHANGES.json. Current taxonomy has 98 physical leaves, 136 supported IDs and 22 legacy aliases.

Canonical 0.4.0-dev.34 is a compatible extension in the ongoing prerelease series. Source ownership remains unchanged: sorting configuration is server-authoritative; classification is shared definition logic; clients own presentation. No new networking, persistence, gameplay sandbox option, routing, discovery, transfer, protocol or schema change. Match client/server builds for taxonomy consistency.

Exact validation commands from this project with C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev34-vanilla-diff.json --approved-changes docs/DEV34_APPROVED_TAXONOMY_CHANGES.json
```

All PASS offline. Logs: dist/handoffs/dev34-tests.log and dev34-vanilla-diff.json. Native SP/dedicated MP NOT TESTED; G6 NOT TESTED, G7 BLOCKED / NOT TESTED, G8 BLOCKED. No package, deployment, staging or publication requested/performed. No third-party implementation/data/assets used.
