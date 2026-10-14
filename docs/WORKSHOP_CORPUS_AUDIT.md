# Installed Workshop item classification audit

Snapshot: 2026-10-14. Compatible PATCH candidate dev.49, based on dev.48.
Purpose: improve owned item classification from public script metadata without
copying third-party classifiers, item databases, implementation code or assets.
This is deterministic classification, not external machine learning.

## Scope and findings

[VERIFIED static] 378 downloaded Workshop packages, 865 mod.info files and 13,893
script files yielded 37,320 item declarations and 27,274 distinct full types.
No parser/classifier exceptions were recorded. The old inventory found 37,107
declarations: the corrected scan includes 213 more declarations across 87 more
script files. It walks each package once and includes sibling common folders
and scripts with no unambiguous mod.info owner. There are 45 common-sibling
declarations and 168 declarations with ambiguous/unowned provenance.

1,362 full types have different classifications across declarations. These are
flagged as load-order/variant questions, not silently treated as one effective
item. 8,730 eligible declarations initially resolved to Misc; many are partial
overrides or use opaque categories such as Item or VFXDistribution.

[TESTED offline] Exactly 298 declarations (274 distinct types) change:

| Metadata meaning | Existing destination | Declarations |
| --- | --- | ---: |
| Ammunition-making supplies with metal tag | Metal materials | 58 |
| Other ammunition-making supplies / minerals | General materials | 124 |
| Vehicle tuning supplies | Vehicle parts | 38 |
| Toys | Keepsakes (consistent with existing toy handling) | 72 |
| Skill journals | Notes and journals | 6 |

37,022 classifications are unchanged. These hints require Normal/Drainable type,
run after stronger structural/tag/tool evidence, and carry medium confidence.
Finished ammunition, firearms, wearable bags, tools and medical items retain
their existing stronger rules. Ammunition-making inputs are not ready-to-fire
ammunition. Opaque labels, art, currency, trash and unknown identities are not
guessed from names. This reduces eligible Misc declarations to 8,432; it does
not claim that every remaining fallback is an error or that all mods are solved.

## Clean-room provenance

Only declarative item fields and mod.info metadata were inspected for this pass;
no third-party Lua was executed or used as an implementation source. The local
inventory records Workshop URL/ID, mod ID/name, reported author/version,
relative file, SHA-256 and per-declaration decisions. Raw item definitions are
kept in local diagnostics, not bundled in the runtime or committed here.

Changed observations originate from these public interface surfaces:

| Workshop item | Reported metadata | Rights |
| --- | --- | --- |
| [2788256295](https://steamcommunity.com/sharedfiles/filedetails/?id=2788256295) | Ammo Maker; STIMP_TM; variants 42.29.2 / 42.34.1 and UNKNOWN | License/permission UNKNOWN; no reuse |
| [3402491515](https://steamcommunity.com/sharedfiles/filedetails/?id=3402491515) | Tsar's Common Library; author UNKNOWN; 3.32 | License/permission UNKNOWN; no reuse |
| [3403870858](https://steamcommunity.com/sharedfiles/filedetails/?id=3403870858) | Lifestyle: Hobbies; Angry; 0.4.0.3 | License/permission UNKNOWN; no reuse |
| [3779162647](https://steamcommunity.com/sharedfiles/filedetails/?id=3779162647) | LG Skill Journal; author UNKNOWN; 1.2.7 | License/permission UNKNOWN; no reuse |
| [498441420](https://steamcommunity.com/sharedfiles/filedetails/?id=498441420) | Hydrocraft; author/version UNKNOWN | License/permission UNKNOWN; no reuse |

Author/version above is installed metadata, not independently verified ownership.
Original design: normalize exposed category hints, restrict eligible types and
preserve stronger metadata evidence. No external item IDs or implementation
lists added. Imported code/assets: NONE. No redistribution attribution
obligation introduced; unknown licensing does not authorize reuse. Independent
clean-room reviewer signoff remains pending on the draft PR.

## Validation and limits

Commands from repository root using configured Python:

```text
python scripts/audit_workshop_corpus.py --workshop-root <installed-108600-root> --output <local-before>
python scripts/audit_workshop_corpus.py --workshop-root <installed-108600-root> --output <local-after> --compare <local-before>/items.jsonl
python tests/test_workshop_corpus.py
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_deployment.py
python scripts/check_vanilla_membership.py --game <installed-game> --output <local-report.json> --approved-changes docs/DEV41_APPROVED_TAXONOMY_CHANGES.json
```

The comparison emits all-items.csv and comparison.json. Synthetic regressions
cover fallback confidence, normalized labels, precedence, false-positive guards,
common folders and ambiguous ownership. Vanilla comparison remains 5,092 items
and exactly 625 previously approved deviations; no additional vanilla changes.

[TESTED offline] Full suite, corpus inventory test, version consistency and
127-file source-manifest checks PASS. SHA-256 rechecks preserve all 1,193
external files containing parsed item declarations. Raw diagnostics remain
local. Independent reviewer signoff and runtime gates are not implied by these
checks.

[UNKNOWN / RUNTIME GATE] Downloaded includes legacy and mutually exclusive
variants. Static parsing cannot resolve effective native inheritance, active
load order, Lua-created items or runtime mutations. Zero exceptions does not
prove complete native script interpretation. Real SP and dedicated MP sorting,
UI and save/reconnect acceptance remain NOT TESTED. Classification is shared
Lua used by authoritative server planning; no networking/state-ownership change
or runtime scanning added. Existing sandbox settings remain unchanged; these
are internal semantic corrections, not new configurable gameplay modes.
G7 NOT TESTED/BLOCKED; stable G8 BLOCKED. No deployment, package or publication.
