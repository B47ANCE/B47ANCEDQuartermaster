"""Original bounded storage review + current audit tables; no runtime execution."""
from pathlib import Path
import collections, json
ROOT=Path(__file__).resolve().parents[1]
old=json.loads((ROOT/'dist/handoffs/taxonomy-dev10-baseline/CATEGORY_AUDIT.json').read_text(encoding='utf-8'))
new=json.loads((ROOT/'docs/CATEGORY_AUDIT.json').read_text(encoding='utf-8'))
source=old['sources'][0];current=new['sources'][0]
eligible=collections.Counter(row['category'] for row in source['rows'] if row['catalogEligible'])
nowEligible=collections.Counter(row['category'] for row in current['rows'] if row['catalogEligible'])
dest={entry['id']:entry['destination'] for entry in new['taxonomy'] if entry['legacyOnly']}
reasons={
 'B47_AnimalSupplies':'Leash/water dish share animal-husbandry/farm supply storage; two identities do not justify a separate destination.',
 'B47_OutdoorFarming':'Seeds, planting and animal-care supplies share a farm supply area. Use a new union ID so old gardening-only rules do not gain animal equipment.',
 'B47_ElectricalComponents':'Loose wire/electronics salvage and portable batteries share an electrical supply box; a new ID preserves old component-only rules.',
 'B47_ElectricalPower':'Portable cells/boxed cells share electrical supply storage; old battery-only scope stays separate from components and devices.',
 'B47_VehicleBatteries':'Three car battery classes normally share spare-part shelving. Tires remain separately useful; battery-only saved rules remain exact.',
 'B47_VehicleOther':'General spare parts can include batteries on the same shelf. New union ID avoids widening old Other Parts rules.',
 'B47_ClothingHead':'Hats/head coverings, eyewear and face coverings share a head/facewear bin; preserve old headwear-only scope.',
 'B47_ClothingEyes':'Eyewear is a close head/facewear sibling; consolidate destination while retaining exact old eyewear membership.',
 'B47_ClothingFace':'Masks/face coverings belong with head/facewear for practical wardrobe organization; retain old mask-only scope.',
 'B47_ClothingUnderwear':'Underwear and socks plausibly share an underlayers drawer; retain existing underwear-only rules.',
 'B47_ClothingSocks':'Socks do not need a separate seven-identity destination alongside underwear; preserve sock-only saved rules.',
 'B47_BeveragesWater':'Water and ordinary non-alcoholic drinks share drink storage; water-only rules remain narrow rather than becoming all drinks.',
 'B47_BeveragesOther':'Ordinary non-alcoholic drinks share a drinks shelf with water. Alcohol stays separate; existing Other Beverage rules retain their old membership.',
 'B47_FirearmsOther':'Useful mod-extensible ranged-weapon fallback when metadata does not identify handgun/long gun/shotgun; hide until eligible content or a saved rule exists.',
 'B47_MeleeAxes':'Axes are a natural weapon/tool storage concept; default tool policy moves vanilla axes to Cutting Tools. Keep physical support and show when populated under false policy or selected.',
 'B47_OutdoorOther':'Unknown survival equipment needs a safe residual fallback; hide unless actual eligible content or a persisted rule makes it relevant.',
 'B47_Media':'Three shared VHS/CD ScriptItem prototypes represent many distinct recordings/titles; players plausibly keep tape/CD collections together. KEEP Recorded Media without pulling sporting equipment into it.',
 'B47_AmmoLoose':'Loose rounds are an obvious ammo storage concept distinct from loaded magazines or unopened boxes; strong firearm-mod expansion.',
 'B47_AmmoMagazines':'Reusable firearm magazines/clip supplies deserve a ready-magazine bin; modded firearms expand the six vanilla definitions.',
 'B47_Handguns':'Handgun lockers are a natural weapon concept with substantial mod expansion; six script identities are not evidence to merge.',
 'B47_Shotguns':'Shotgun racks are a natural weapon/ammunition distinction; keep despite five vanilla identities and allow mod expansion.',
 'B47_LongGuns':'Long-gun racks are practical and heavily mod-extensible; nine native definitions justify no automatic merger.',
 'B47_VehicleTires':'Bulky spare tires are naturally stored separately from general vehicle parts; three vehicle classes and mod content expand nine identities.',
 'B47_OutdoorTrapping':'Traps/baits are a distinct activity supply stash; six definitions remain useful and mod-extensible.',
 'B47_OutdoorFire':'Lighters/matches/fire-starting supplies form a practical emergency/fire-making kit; distinct from camping gear and generic material fuel.',
 'B47_MedicalBandages':'Dressings are immediate first-aid consumables with distinct storage/use from medicine and reusable tools; keep seven definitions.',
 'B47_MedicalTools':'Reusable first-aid/surgical tools belong in a medical instrument kit separately from dressings/drugs; keep seven definitions.',
 'B47_ToolsMechanics':'Vehicle-repair tools belong at a mechanics workstation, separately from spare parts; seven definitions and mod expansion support KEEP.',
 'B47_ClothingGloves':'Handwear is useful protective/work wardrobe storage distinct from footwear and headwear; twenty definitions justify a glove bin.',
 'B47_ClothingFace':'Masks/face coverings belong with head/facewear for practical wardrobe organization; retain old mask-only scope.',
 'B47_ToolsCarpentry':'Hammer/saw/chisel sets naturally belong together at a carpentry bench; twelve definitions are a useful workstation kit.',
 'B47_ToolsSewing':'Needles/knitting/fleshing implements belong in a sewing kit; fourteen definitions are useful separately from textile stock.',
 'B47_HouseholdCare':'Grooming/hygiene products form a bathroom/care drawer distinct from household cleaners; keep seventeen definitions.',
 'B47_HouseholdCleaning':'Cleaning products/cloth states form a cleaning cupboard; thirteen definitions are not interchangeable with grooming or kitchen tools.',
 'B47_HouseholdOther':'Thirteen residual domestic utility goods still need a household junk drawer; retain after dev.10 specialized purpose corrections.',
 'B47_MaterialsFasteners':'Nails/screws/boxes and verified sewing fasteners belong in a hardware supply box; six definitions represent many usable units.',
 'B47_MaterialsPaint':'Paint supplies belong at painting/decorating storage; sixteen identities are useful separately from adhesives/raw stock.',
 'B47_WeaponParts':'Attachments/accessories belong in a weapon-parts kit; eleven definitions with substantial mod expansion are distinct from weapons/ammo.',
 'B47_LiteratureMaps':'Navigation maps form a useful map/document folder; fifteen script identities and modded regions support KEEP.',
 'B47_Instruments':'Portable instruments and accessories plausibly share an instrument area; fifteen identities solve genuine improvised-weapon leakage.',
 'B47_Smoking':'Tobacco/smoking supplies form a coherent stash; fifteen identities are deliberately separate from food and fire-starting equipment.',
 'B47_ElectricalRadios':'Communications/radio equipment forms a natural equipment shelf; seventeen definitions and mod expansion differ from parts/supplies.',
 'B47_OutdoorFishing':'Fishing rods/tackle supplies form a fishing kit; twenty definitions remain useful and mod-extensible.'
}
familyReasons={
 'B47_Ammo':'Natural ammunition logistics: unopened boxes, loose rounds and magazines have different ready-use storage.',
 'B47_Firearms':'Recognizable weapon type supports natural racks/lockers and substantial mod expansion.',
 'B47_Melee':'Weapon form/skill supports deliberate weapon racks; do not collapse meaningful blade/blunt/spear distinctions to reach a quota.',
 'B47_Tools':'Skill/workstation-oriented tools plausibly share a dedicated bench/kit; retain discipline rather than generic Tools.',
 'B47_Medical':'First-aid supply type distinguishes dressing, drug, reusable instrument and residual kits.',
 'B47_Food':'Shelf-life/seasoning distinction supports pantry/fridge/cooking-supply storage.',
 'B47_Beverages':'Alcohol differs from ordinary drinking supplies; preserve stable product identity rather than current contents.',
 'B47_Clothing':'Remaining garment regions/layers support practical wardrobe bins; protective gear and accessories are recognizable separate concepts.',
 'B47_Literature':'Training, recipe manuals, navigation, periodicals, personal documents and generic books are natural shelf/folder concepts.',
 'B47_Materials':'Raw stock/purpose supports separate workshop supply bins; no technical subdivision quota.',
 'B47_Vehicle':'Vehicle spare-part type supports practical garage organization and mod expansion.',
 'B47_Outdoor':'Activity-specific supplies support fishing/trapping/farming/camping/fire/lighting storage.',
 'B47_Containers':'Wearable bags, fluid vessels and generic carrying containers have recognizable storage/use differences.',
 'B47_Electrical':'Complete equipment differs from loose electrical supplies; supported devices deserve an equipment shelf.',
 'B47_Household':'Domestic purpose supports separate utility cupboards/drawers rather than one unsorted household catch-all.'
}
reviews=[]
for entry in old['taxonomy']:
 if not entry['itemCategory']:continue
 id=entry['id'];count=source['category_counts'].get(id,0);parents=entry['familyIds']
 decision='MERGE' if id in dest else 'CONDITIONAL/HIDDEN' if count==0 else 'KEEP'
 reason=reasons.get(id) or next((familyReasons[p] for p in parents if p in familyReasons),'Recognizable miscellaneous storage fallback; retain genuinely residual items rather than confidently misclassify them.')
 nearest=dest.get(id) or next((p for p in parents),'B47_Misc')
 # Logical sibling is review context, not an automatic merge target.
 siblings=[e['id'] for e in old['taxonomy'] if e['itemCategory'] and e['id']!=id and set(e['familyIds'])&set(parents)]
 reviews.append({'id':id,'label':entry['name'],'vanillaCount':count,'eligiblePickerCount':eligible[id],
 'compatibilityFamilies':parents,'semanticPurpose':id,'dedicatedStoragePlausible':('No separate bin justified' if id=='B47_AnimalSupplies' else 'Possible, but shared destination preferred') if decision=='MERGE' else 'Yes, if populated' if count==0 else 'Yes',
 'moddedExpansionPotential':('[INFERRED] many native recorded titles already share these prototypes; media mods may add more' if id=='B47_Media' else '[INFERRED] high weapon/ammo extension potential' if any(p in ('B47_Firearms','B47_Melee','B47_Ammo') for p in parents) or id=='B47_WeaponParts' else '[INFERRED] high garment/content expansion potential' if 'B47_Clothing' in parents else '[INFERRED] activity/workstation supply expansion; shared purpose remains preferable' if any(p in ('B47_Tools','B47_Outdoor','B47_Materials','B47_Vehicle','B47_Electrical') for p in parents) else '[INFERRED] content may expand this familiar storage concept; no mod-specific database'),
 'nearestLogicalSibling':dest.get(id) or (siblings[0] if siblings else nearest),
 'decision':decision,'newDestination':dest.get(id,id),'reason':reason})
assert len(reviews)==90 and len(dest)==13
output={'projectVersion':new['projectVersion'],'taxonomyVersion':4,'review':reviews,'beforePhysical':90,'afterPhysical':83,
 'beforePopulatedPicker':len(eligible),'afterPopulatedPicker':len(nowEligible),'legacyOnlyIds':sorted(dest),
 'newPhysicalIds':[t['id'] for t in new['taxonomy'] if t['itemCategory'] and t['id'] not in {t['id'] for t in old['taxonomy']}],
 'method':'Storage-purpose judgement, eligible registry evidence and extensibility; no arbitrary final count quota.'}
(ROOT/'dist/handoffs/dev11-taxonomy-consolidation.json').write_text(json.dumps(output,indent=2)+'\n',encoding='utf-8')
lines=['# dev.11 player-facing taxonomy consolidation','',
 f"Project Version: {new['projectVersion']}; taxonomy protocol 4. [TESTED OFFLINE] Static vanilla script/Lua evidence only; native SP/listen/dedicated UNTESTED. G7/G8 BLOCKED. No deployment/publication. Current master status remains docs/MASTER_HANDOFF_STATUS.md.",'',
 '90 -> 83 supported physical categories; 87 -> 80 populated default vanilla picker rows. Thirteen old physical IDs are compatibility-only; six new union IDs avoid repurposing saved narrow rules. Net reduction seven physical destinations; three supported empty categories hidden unless populated or selected. The 70–80 range was not treated as a quota. Mod catalogs and selected old/empty rules can add visible rows.','',
 '## Every dev.10 physical category','',
 '| ID | Label | Vanilla Count | Eligible Picker | Compatibility Family | Semantic Purpose | Dedicated Storage? | Mod Expansion | Nearest Sibling | Decision | New Destination | Reason |',
 '| --- | --- | ---: | ---: | --- | --- | --- | --- | --- | --- | --- | --- |']
for r in reviews:lines.append('| '+' | '.join(str(r[k]) if k not in ('compatibilityFamilies',) else ', '.join(r[k]) for k in ('id','label','vanillaCount','eligiblePickerCount','compatibilityFamilies','semanticPurpose','dedicatedStoragePlausible','moddedExpansionPotential','nearestLogicalSibling','decision','newDestination','reason'))+' |')
lines+=['','## Every category below ten vanilla identities','']
for r in reviews:
 if r['vanillaCount']<10:lines.append('- **'+r['id']+' ('+str(r['vanillaCount'])+'): '+r['decision']+'** — '+r['reason'])
lines+=['','## Categories with 10–20 identities','']
for r in reviews:
 if 10<=r['vanillaCount']<=20:lines.append('- **'+r['id']+' ('+str(r['vanillaCount'])+'): '+r['decision']+'** — '+r['reason'])
lines+=['','## Migration/routing contract','',
 'No old ID is repurposed: the semantic classifier retains each exact dev.10 result; one destination map produces the new physical ID. resolve returns physical category/reason/original broad identity/semantic purpose. Server routing ranks explicit Item (4) > current physical (3) > historical semantic alias (2) > broad family (1), then existing fill priority/distance/tie-break. All thirteen narrow IDs match only their original semantic membership. Existing broad family coverage is computed from semantic purpose, preserving the component/power Materials boundary. Serialized cats/items/presets/priority structure is unchanged; taxonomy 0–4 accepted for loading, new envelopes use 4. Mixed old peer protocol rejects safely.','',
 'New picker catalogs contain populated current physical destinations only. Existing Model.new unions selected persisted IDs into the tree; aliases use their narrow item membership and compatibility handling for normalization. Empty supported rules remain inspectable/editable. New catalog selections do not create narrow aliases. This uses the existing category/mod/item and filtering architecture, with no extra UI hierarchy or second classifier.','',
 '## Full vanilla audit','',f"5,105 declarations / 5,092 unique FullTypes / 13 duplicate declarations. {current['changed_from_previous']} changed physical destinations; {current['unchanged_from_previous']} unchanged; {current['semantic_changes_from_previous']} semantic changes. Misc 34; 4,948 eligible / 144 excluded. Every old narrow membership and broad-family coverage is regression-checked for every row, not only representative cases.",'',
 '| Current Physical ID | Label | Registry Count | Eligible Count |','| --- | --- | ---: | ---: |']
for entry in new['taxonomy']:
 if entry['itemCategory']:lines.append(f"| {entry['id']} | {entry['name']} | {current['category_counts'].get(entry['id'],0)} | {nowEligible[entry['id']]} |")
lines+=['','## Mod samples','']
for s in new['sources'][1:]:lines.append(f"- {s['root']}: {s['items']} unique identities; {s['changed_from_previous']} physical changes / {s['semantic_changes_from_previous']} semantic changes; no third-party Lua executed. Complete metadata, old/new physical results and narrow/broad coverage in CATEGORY_AUDIT.json.")
lines+=['','## Deferred judgement calls','',
 'Recorded Media remains dedicated because prototypes represent many distinct titles. No automatic recreation/media merger. Separate weapon/tool/material/medical categories survive where storage purpose is intuitive; no count quota. Existing dev.10 semantic ambiguities (sports versus weapon identity, occult collectibles, process vessels, raw/finished materials, foreign writable metadata and unproven internal obtainability) are preserved, not reinterpreted in this pass. Runtime controller/rendering/registry/routing acceptance remains required.','']
(ROOT/'dist/handoffs/dev11-taxonomy-consolidation.md').write_text('\n'.join(lines),encoding='utf-8')
print('Wrote all 90 decisions, 83 physical counts, tiny/empty reviews and compatibility contract')
