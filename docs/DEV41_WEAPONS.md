# dev.41 Weapons hierarchy and tool overlap

Compatible taxonomy/UI extension in ongoing 0.4.0 prerelease: 0.4.0-dev.41. IDs/schema are retained; matching client/server versions are required. No third-party implementation, data or assets used.

Weapons > Explosives; Sharp > Spear and Blade > Long/Short; Blunt > Long/Short; Firearms > Handguns/Shotguns/Sub-Machine Guns/Assault Rifles/Sniper Rifles/Other Firearms/Attachments & Parts > Attachments/Parts. Other Weapons remains a conservative fallback for insufficient non-firearm metadata rather than guessing blunt/sharp. Empty requested branches appear when a Weapons tree is present. Display ancestry is separate from compatibility ancestry, avoiding duplicate historical branches.

[VERIFIED installed vanilla definitions] SmallBlade/LongBlade distinguish blades. Axe and Spear metadata supply secondary weapon purposes; native tool-use purposes remain primary. Explicit Base assault-rifle identities map to Assault Rifles; HuntingRifle, VarmintRifle and MSR7T_Rifle map to Sniper Rifles as scoped long-distance rifle identities. Four other native rifle/carbine definitions lack sufficient subtype evidence and stay Other Firearms. Explicit mod tags support SMG/assault/sniper classification; animation alone does not establish those types. No native SMG definition in the inspected corpus. WeaponPart objects are mountable Attachments; explicitly tagged firearm components are Parts. Verified native aerosol/flame/pipe/smoke devices and Molotov map to Explosives, including remote/sensor variants. Native item/script metadata is never changed.

Tool use always outweighs weapon use, as requested. The old ClassifyToolsByUse sandbox switch is retired from the UI; old values cannot change primary classification. The primary inventory Category remains the tool purpose. The combined Quartermaster catalog also shows weapon-capable tools in the matching weapon leaf. Both rows share existing display-name selection and count once. Server routing accepts secondary leaf rules below primary leaf precedence, and secondary family rules use existing family precedence; live transfer validation is unchanged. Static script identity cache retains primary/secondary evidence. Secondary rows are catalog memberships, not duplicate items or additional transfer offers.

Historical LongGuns and Melee categories are retained as hidden compatibility groups; old Blades and WeaponParts become families; Axes is a retained alias. Historical weapon rules still cover reclassified items. New Weapons and Firearms parent rules intentionally cover their displayed descendants, including Attachments & Parts. Explicit item rules remain higher precedence than any category. An item hidden in one branch can share its name selection with a visible secondary row, consistent with the pre-existing identity contract; visible bulk operations enumerate only visible ITEM rows.

[TESTED offline] Four category levels, search matching every descendant of an intermediate parent, Only Contents, collapsed visibility, bulk selection, unique effective count, dual tool rows and routing, unchanged primary tool identity despite retired saved option, historical rules, explosive/gun identities and existing native queued transfer fixtures. Full tests include all 102 physical leaves, 147 known IDs and 23 aliases. Exact approved cumulative native changes: 625/5,092, of which 63 additional changes are solely weapon splits: 25 explosives, 11 attachments, 18 blades, two assault rifles, three sniper rifles and four other firearms. Existing frozen evidence is retained.

Exact commands using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe:

```
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output dist/handoffs/dev41-vanilla-diff.json --approved-changes docs/DEV41_APPROVED_TAXONOMY_CHANGES.json
./Build-Workshop.ps1
./Prepare-WorkshopVdf.ps1 -OutputPath dist/workshop-publish/B47ANCEDQuartermaster-dev41-submit.vdf
```

No new mutable shared gameplay state or authority protocol. Server evaluates shared canonical metadata and persisted rules; clients present rows and submit existing intents. Join/reconnect uses existing configuration snapshots. No new gameplay micro-setting: user-defined sorting rules express desired destinations. G6 native UI NOT TESTED; G7 dedicated multiplayer BLOCKED / NOT TESTED; G8 readiness BLOCKED. Publication is explicitly authorized as a development testing candidate with these limitations disclosed, not certification. Actual category tree/controller layout, tool overlap, old rules and transfer timing require native dedicated acceptance. Publishing does not update a remote server or prove it loaded the candidate.
