"""Static B42 script inventory audit using the actual original Lua resolver.

Reads definitions without running the game or any third-party Lua. It does not
copy item databases into production. Static inheritance/load-order limits remain.
"""
import argparse
import collections
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.test-deps'))
from lupa.lua51 import LuaRuntime

parser=argparse.ArgumentParser()
parser.add_argument('--game',type=Path,default=Path(r'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'))
parser.add_argument('--mod',type=Path,action='append',default=[])
parser.add_argument('--baseline',type=Path,default=ROOT/'dist/handoffs/taxonomy-dev11-baseline/Categorizer.lua')
args=parser.parse_args()
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().package.path=(ROOT/'src/B47ANCEDQuartermaster/42/media/lua/shared/?.lua').as_posix()+';'+lua.globals().package.path
lua.execute("ComponentType={FluidContainer='FluidContainer'}")
bridge='''function(p)
    local R=require 'B47ANCEDQuartermaster/Categorizer'
    local tags={};for tag in (p.Tags or ''):gmatch('[^;]+') do tags[#tags+1]=tag end
    local category=p.DisplayCategory
    local weapons={};for w in (p.Categories or ''):gmatch('[^;]+') do weapons[#weapons+1]=w end
    local item={getFullName=function() return p.fullType end,getItemType=function() return p.ItemType or p.Type end,
        getTags=function() return tags end,getDisplayCategory=function() return category end,
        getDoubleClickRecipe=function() return p.DoubleClickRecipe end,getWeaponCategories=function() return weapons end,getSwingAnim=function() return p.SwingAnim end,getAmmoType=function() return p.AmmoType end,
        getEatType=function() return p.EatType end,
        isCanBandage=function() return p.CanBandage=='true' end,
        isAlcoholic=function() return p.Alcoholic=='true' end,isSpice=function() return p.Spice=='true' end,
        getDaysFresh=function() return tonumber(p.DaysFresh) or 1000000000 end,
        getSkillTrained=function() return p.SkillTrained end,getFabricType=function() return p.FabricType end,
        hasResearchableRecipes=function() return p.LearnedRecipes~=nil or p.ResearchableRecipes~=nil or p.TeachedRecipes~=nil end,
        getBodyLocation=function() return p.BodyLocation end,getRecordedMediaCat=function() return p.RecordedMediaCat end,
        canBeWrite=p.CanBeWrite=='true',isHidden=function() return p.Hidden=='true' end,getObsolete=function() return p.Obsolete=='true' end,
        getComponentScriptFor=function()
            if not p.initialFluids then return nil end
            local initial={};for _,entry in ipairs(p.initialFluids) do
                local f=entry;initial[#initial+1]={getFluidType=function() return f.type end,getPercentage=function() return f.percent end}
            end
            return {isInitialFluidsIsRandom=function() return p.initialFluidsRandom==true end,getInitialFluids=function() return initial end,getCapacity=function() return tonumber(p.Capacity) end}
        end,
        isRanged=function() return p.Ranged=='true' end,
        isSurvivalGearLoot=function() return p.SurvivalGear=='true' or category=='Camping' end,
        isMedicalLoot=function() return p.Medical=='true' or category=='FirstAid' or category=='FirstAidWeapon' end,
        isMechanicsLoot=function() return p.MechanicsItem=='true' or category=='VehicleMaintenance' or category=='VehicleMaintenanceWeapon' end}
    local cat,reason,legacy,semantic,historical=R.resolve(item);semantic=semantic or cat;historical=historical or semantic
    if R.inspect then
        local _,_,_,matches=R.inspect(item);local eligible,exclusion=R.catalogEligible(item)
        return cat,reason,legacy,matches,eligible,exclusion,semantic,historical
    end
    return cat,reason,legacy
end'''
classify=lua.eval(bridge)
baseline=LuaRuntime(unpack_returned_tuples=True)
baseline.globals().package.path=(args.baseline.parent/'shared/?.lua').as_posix()+';'+baseline.globals().package.path
baseline.execute("ComponentType={FluidContainer='FluidContainer'}")
baseline.globals().BASELINE=baseline.execute(args.baseline.read_text(encoding='utf-8'))
classifyPrevious=baseline.eval(bridge.replace("local R=require 'B47ANCEDQuartermaster/Categorizer'",'local R=BASELINE'))
baselineData=json.loads((ROOT/'dist/handoffs/taxonomy-dev11-baseline/CATEGORY_AUDIT.json').read_text(encoding='utf-8'))
priorSources={source['root']:{row['fullType']:row for row in source['rows']} for source in baselineData['sources']}

def items(path):
    text=path.read_text(encoding='utf-8-sig',errors='replace')
    text=re.sub(r'/\*.*?\*/|//[^\n]*','',text,flags=re.S)
    modules=list(re.finditer(r'\bmodule\s+([\w.]+)\s*\{',text))
    for m in re.finditer(r'^\s*item\s+([\w.]+)\s*\{',text,re.M):
        depth=1;end=m.end()
        while end<len(text) and depth:
            depth+=(text[end]=='{')-(text[end]=='}');end+=1
        if depth: raise ValueError(f'Unclosed item in {path}: {m.group(1)}')
        fields=dict(re.findall(r'^\s*(\w+)\s*=\s*([^\r\n,]*),?',text[m.end():end-1],re.M))
        module='Base'
        for mm in modules:
            if mm.start()<m.start(): module=mm.group(1)
        fields={k:v.strip() for k,v in fields.items()}
        fields['fullType']=module+'.'+m.group(1)
        # Preserve ALL initial-fluid entries from the component block, including mixtures.
        body=text[m.end():end-1]
        component=re.search(r'component\s+FluidContainer\s*\{',body)
        if component:
            level=1;stop=component.end()
            while stop<len(body) and level:
                level+=(body[stop]=='{')-(body[stop]=='}');stop+=1
            definition=body[component.end():stop-1]
            values=re.findall(r'^\s*fluid\s*=\s*([\w:.-]+)',definition,re.M)
            fields['initialFluids']=[{'type':v.split(':')[0],'percent':float(v.split(':')[1])}
                                     for v in values if len(v.split(':'))>1 and re.fullmatch(r'[0-9.]+',v.split(':')[1])]
            fields['initialFluidsRandom']=bool(re.search(r'(?:InitialFluidsIsRandom|PickRandomFluid)\s*=\s*true',definition))
        yield fields

def audit(folder):
    if not folder.is_dir(): raise ValueError(f'Missing audit source: {folder}')
    counts=collections.Counter();reasons=collections.Counter();fallback=[];duplicates=[];seen={};sources={};examples={};invalid=[];inspected=0;excluded=0
    for path in sorted(folder.rglob('*.txt')):
        if 'scripts' not in path.parts: continue
        sources[str(path)]=hashlib.sha256(path.read_bytes()).hexdigest()
        for entry in items(path):
            inspected+=1
            if entry.get('Hidden')=='true' or entry.get('Obsolete')=='true': excluded+=1;continue
            name=entry['fullType']
            try:
                category,reason,legacy,matches,eligible,exclusion,semantic,historical=classify(lua.table_from(entry,recursive=True))
                old=classifyPrevious(baseline.table_from(entry,recursive=True));oldCategory=old[0] if isinstance(old,tuple) else old;oldSemantic=old[6] if isinstance(old,tuple) else oldCategory
                saved=priorSources.get(str(folder),{}).get(name)
                if saved: assert oldCategory==saved['category'],('dev.11 baseline drift',name,oldCategory,saved['category'])
            except Exception as error:
                invalid.append({'item':name,'error':str(error)});continue
            if name in seen:
                duplicates.append(name)
                previous=seen[name];counts[previous[0]]-=1;reasons[previous[1]]-=1
            alternatives=[dict(v.items()) for v in matches.values()]
            seen[name]=(category,reason,entry,legacy,oldCategory,eligible,exclusion,alternatives,semantic,historical,oldSemantic);counts[category]+=1;reasons[reason]+=1
            examples.setdefault(category,[])
            if len(examples[category])<8:examples[category].append(name)
    familyCounts=collections.Counter()
    resolver=lua.eval("require('B47ANCEDQuartermaster/Categorizer')")
    for name,value in seen.items():
        category,reason,entry,legacy=value[:4]
        compatible={id for id in resolver.memberships(category,legacy,value[8],value[9]).keys() if resolver.isFamily(id)}
        saved=priorSources.get(str(folder),{}).get(name)
        if saved:
            assert compatible>=set(saved['compatibilityFamilies']),('broad coverage lost',name,compatible,saved['compatibilityFamilies'])
            assert value[5]==saved['catalogEligible'],('catalog eligibility changed',name)
        for narrow in resolver.families.destinations.keys():
            rank=resolver.match(category,lua.table_from({narrow:True}),legacy,value[8],value[9])
            assert (rank==2)==(value[9]==narrow),('legacy membership widened/lost',name,narrow,rank)
        familyCounts.update(compatible)
        if reason in ('fallback','vanilla-category'):
            fallback.append({'item':name,'category':category,'reason':reason,
                'declared_type':entry.get('ItemType',entry.get('Type')),
                'declared_category':entry.get('DisplayCategory'),'tags':entry.get('Tags')})
    if not seen: raise ValueError(f'No script items audited: {folder}')
    return {'environment':'STATIC_SCRIPT_OFFLINE; not runtime/load-order certification','root':str(folder),
        'definitions_inspected':inspected,'excluded':excluded,'invalid_unreadable':invalid,
        'items':len(seen),'family_coverage_counts':dict(sorted(familyCounts.items())),'category_counts':dict(sorted(counts.items())),'reason_counts':dict(sorted(reasons.items())),
        'fallback_review':fallback,'duplicate_definitions':sorted(set(duplicates)),'examples':examples,'source_sha256':sources,
        'rows':[{'fullType':name,'category':v[0],'reason':v[1],'previousCategory':v[4],'changed':v[0]!=v[4],
                 'changeReason':('reviewed semantic correction: '+v[10]+' -> '+v[8]) if v[8]!=v[10] else ('destination-consolidation: '+v[8]+' -> '+v[0]) if v[0]!=v[4] else None,'semanticPurpose':v[8],'previousSemanticPurpose':v[10],'semanticChanged':v[8]!=v[10],'historicalPurpose':v[9],'physicalDestinationChanged':v[0]!=v[4],'legacySpecificMembership':[v[9]] if resolver.isLegacy(v[9]) else [],'legacyBroadCategory':v[3],
                 'compatibilityFamilies':sorted(id for id in resolver.memberships(v[0],v[3],v[8],v[9]).keys() if resolver.isFamily(id)),
                 'catalogEligible':v[5],'catalogExclusionReason':v[6],'competingRules':v[7],
                 'nativeMetadata':{k:e for k,e in v[2].items() if k in ('CanBeWrite','CanBandage','DaysFresh','DaysTotallyRotten','Alcoholic','Spice','initialFluids','initialFluidsRandom','Capacity','DoubleClickRecipe','Categories','SwingAnim','AmmoType','LearnedRecipes','Researchablerecipes','Medical','SurvivalGear','MechanicsItem','FabricType','SkillTrained','EatType')},
                 'type':v[2].get('ItemType',v[2].get('Type')),'displayCategory':v[2].get('DisplayCategory'),
                 'tags':v[2].get('Tags'),'bodyLocation':v[2].get('BodyLocation')} for name,v in sorted(seen.items())],
        'changed_from_previous':sum(v[0]!=v[4] for v in seen.values()),
        'unchanged_from_previous':sum(v[0]==v[4] for v in seen.values()),
        'excluded_from_catalog':sum(not v[5] for v in seen.values()),'semantic_changes_from_previous':sum(v[8]!=v[10] for v in seen.values())}

report={'projectVersion':(ROOT/'VERSION').read_text().strip(),'taxonomyVersion':int(lua.eval("require('B47ANCEDQuartermaster/Categorizer')").version),
        'taxonomy_sha256':hashlib.sha256((ROOT/'src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Taxonomy.lua').read_bytes()).hexdigest(),
        'resolver_sha256':hashlib.sha256((ROOT/'src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Categorizer.lua').read_bytes()).hexdigest(),
        'semantics_sha256':hashlib.sha256((ROOT/'src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/StorageSemantics.lua').read_bytes()).hexdigest(),
        'sources':[audit(args.game/'media/scripts')]+[audit(p) for p in args.mod],
        'limits':'No third-party Lua executed. Script overrides/inheritance, runtime script mutation and full loaded-mod ownership require native diagnostics.'}
labels=json.loads((ROOT/'src/B47ANCEDQuartermaster/42/media/lua/shared/Translate/EN/UI.json').read_text(encoding='utf-8'))
resolver=lua.eval("require('B47ANCEDQuartermaster/Categorizer')")
report['taxonomy']=[{'id':'B47_'+short,'name':labels['UI_B47_Category_'+short],'familyIds':list((resolver.families.parents['B47_'+short] or {}).values()) if resolver.families.parents['B47_'+short] is not None else [],
                    'compatibilityFamily':bool(resolver.isFamily('B47_'+short)),'itemCategory':bool(resolver.isLeaf('B47_'+short)),'legacyOnly':bool(resolver.isLegacy('B47_'+short)),'destination':resolver.families.destination('B47_'+short)} for short in sorted(resolver.labels)]
report['quality_review']={}
assert len({entry['id'] for entry in report['taxonomy']})==len(report['taxonomy'])
assert {entry['id'] for entry in baselineData['taxonomy']} <= {entry['id'] for entry in report['taxonomy']},'dev.10 IDs removed'
assert len([entry for entry in report['taxonomy'] if entry['itemCategory']])==98
overrideCode=(ROOT/'src/B47ANCEDQuartermaster/42/media/lua/shared/B47ANCEDQuartermaster/Categorizer.lua').read_text(encoding='utf-8')
report['explicitOverrides']=[{'fullType':m.group(1),'category':'B47_'+m.group(2),'reason':m.group(3)} for m in re.finditer(r"\['(Base\.[^']+)'\]='([^']+)', -- ([^\n]+)",overrideCode)]
for entry in report['explicitOverrides']:
 entry['semanticPurpose']=entry['category'];entry['physicalCategory']=resolver.families.destination(entry['category'])
overrideReasons={entry['fullType']:entry['reason'] for entry in report['explicitOverrides']}
for source in report['sources']:
 for row in source['rows']:
  if row['reason']=='override':row['winningReasonExplanation']=overrideReasons[row['fullType']]
helper=lua.eval("require('B47ANCEDQuartermaster/StorageSemantics')")
report['scopedFamilies']=[{'id':family['id'],'category':'B47_'+family['category'],'module':'Base','pattern':family['pattern'],
 'kind':family['kind'],'displayCategories':sorted(family['display'].keys()),
 'matchedFullTypes':[row['fullType'] for row in report['sources'][0]['rows'] if any(match['reason']=='family:'+family['id'] for match in row['competingRules'])]} for family in helper.families.values()]
for source in report['sources']:
 rows=source['rows']
 source['review_flags']={
  'food_in_tools':[row['fullType'] for row in rows if row['type']=='base:food' and row['category'].startswith('B47_Tools')],
  'printed_material_in_ammo':[row['fullType'] for row in rows if row['type']=='base:literature' and row['category'].startswith('B47_Ammo')],
  'weapon_parts_outside_parts':[row['fullType'] for row in rows if row['type']=='base:weaponpart' and row['category']!='B47_WeaponParts'],
  'keys_outside_keys':[row['fullType'] for row in rows if row['type']=='base:key' and row['category']!='B47_HouseholdKeys'],
  'clothing_in_household':[row['fullType'] for row in rows if row['type']=='base:clothing' and row['category'].startswith('B47_Household')],
  'cookware_in_materials':[row['fullType'] for row in rows if row['displayCategory'] in ('Cooking','CookingWeapon') and row['category'].startswith('B47_Materials')]
 }
 assert source['semantic_changes_from_previous']==(8 if source is report['sources'][0] else 0),('unexpected dev.11 semantic changes',source['root'])
 if source is report['sources'][0]:
  corrected={row['fullType'] for row in source['rows'] if row['semanticChanged']}
  assert corrected=={'Base.Calculator','Base.Buckle','Base.CompassGeometry','Base.GlassBlowingPipe','Base.Paintbrush','Base.PaintbrushCrafted','Base.WaterRationCan_Box','Base.WaterRationCan'},corrected
  assert all(row['historicalPurpose']==row['previousSemanticPurpose'] for row in source['rows']),'historical scopes changed'
 assert not source['invalid_unreadable'],source['invalid_unreadable']
 assert sum(source['category_counts'].values())==source['items']
 assert not any(source['review_flags'].values()),source['review_flags']
 expected={
 'B47_BeveragesAlcohol':['BeerCan','Wine','Whiskey','Vodka','Gin','Rum','Tequila','Champagne','Scotch','Port','Sherry','Vermouth','WineRed_Boxed','WineWhite_Boxed'],
 'B47_BeveragesOther':['JuiceOrange','JuiceCranberry','JuiceTomato','Milk','Pop','PopBottle','PopBottleRare','CannedFruitBeverage','CannedFruitBeverageOpen','CannedMilk'],
 'B47_Instruments':['GuitarAcoustic','GuitarElectric','GuitarElectricBass','Banjo','Violin','Trumpet','Saxophone','Flute','Keytar','Drumstick','Harmonica','GuitarPick','TuningFork','Whistle','Whistle_Bone'],
 'B47_Smoking':['CigaretteSingle','CigarettePack','CigaretteRolled','Cigar','Cigarillo','Tobacco','TobaccoDried','TobaccoLoose','TobaccoChewing','CigaretteRollingPapers','SmokingPipe','SmokingPipe_Tobacco','CanPipe_Tobacco'],
 'B47_LiteratureNotes':['Notebook','Journal','Notepad','SheetPaper2','GraphPaper','Diary1','Diary2','Note','LetterHandwritten'],
 'B47_ElectricalOther':['Camera','CameraDisposable','CameraExpensive','CameraFilm','Bullhorn'],
 'B47_ElectricalComponents':['Wire','ElectricWire','ElectronicsScrap'],
 'B47_HouseholdCare':['Cologne','Perfume','Comb','Razor','Toothbrush','Toothpaste','Soap2'],
 'B47_HouseholdCleaning':['Bleach','CleaningLiquid2','SteelWool','DishClothWet','BathTowelWet'],
 'B47_HouseholdOther':['ToiletPaper','PaperNapkins2'],
 'B47_ToolsMetal':['BlacksmithAnvil','BlockAnvil','BenchAnvil','StoneAnvil','Bellows','LargeBellows','HeadingTool','Tongs','BlowTorch'],
 'B47_MaterialsTextile':['FabricRoll_Cotton','FabricRoll_DenimBlue','DenimStripsBundle','LeatherStripsBundle','WoolRaw','Yarn','FlaxScutched','HempScutched'],
 'B47_MaterialsAnimal':['FurTuft_Black','FurTuft_Browndark','FurTuft_Brownlight','FurTuft_Grey','FurTuft_White'],
 'B47_AnimalSupplies':['Leash','WaterDish']}
 if source is report['sources'][0]:
  byId={row['fullType']:row for row in rows}
  for category,ids in expected.items():
   for name in ids:
    row=byId['Base.'+name];assert row['semanticPurpose']==category,(row['fullType'],row['semanticPurpose'],category)
  for row in rows:
   if re.fullmatch(r'Base\.[A-Za-z]+BagSeed_Empty',row['fullType']):assert row['semanticPurpose']=='B47_OutdoorFarming',row
   if row['nativeMetadata'].get('CanBeWrite')=='true':assert row['category']=='B47_LiteratureNotes',row
  for name in ('Base.BaseballBat','Base.Golfclub','Base.Generator','Base.CorpseMale','Base.Frog','Base.TinCanEmpty'):
   assert byId[name]['catalogEligible'],('legitimate item hidden',name)
  assert byId['Base.Generator']['category']=='B47_ElectricalOther'
  assert byId['Base.SheetMetalSnips']['category']=='B47_ToolsMetal'
  assert byId['Base.Multitool']['category']=='B47_ToolsGeneralPurpose'
  assert byId['Base.GrillBrush']['category']=='B47_HouseholdCleaning'
  for name in ('CannedFruitCocktailOpen','CannedBologneseOpen','CannedCornedBeefOpen','CannedSardinesOpen','TunaTinOpen','TinnedSoupOpen','Icecream','IcecreamMelted','JamFruit','JamMarmalade','OatsRaw','PeanutButter','Coffee2','CocoaPowder','Yoghurt','DogfoodOpen'):
   assert byId['Base.'+name]['category'].startswith('B47_Food'),('CanDrink animation is not beverage purpose',name)
  assert not byId['Base.TestDebugWater']['catalogEligible']
 physical=[t['id'] for t in report['taxonomy'] if t['itemCategory']]
 source['quality_gates']={
  'empty_categories':[id for id in physical if not source['category_counts'].get(id)],
  'few_member_categories':{id:source['category_counts'].get(id) for id in physical if 0<source['category_counts'].get(id,0)<=9},
  'competing_rule_items':[row['fullType'] for row in rows if len({m['category'] for m in row['competingRules']})>1],
  'residual_category_counts':{id:source['category_counts'].get(id,0) for id in ('B47_Misc','B47_MaterialsGeneral','B47_ToolsGeneralPurpose','B47_HouseholdUtilities','B47_ClothingOther','B47_FoodGeneral','B47_ContainersOther','B47_VehicleParts','B47_LiteratureOther')},
  'required_semantic_assertions':'PASS' if source is report['sources'][0] else 'generic contamination PASS; no per-mod database'}
report['quality_review']['scope']='Six retained contamination gates plus requested exact vanilla semantic families, all writable definitions, all empty seed packaging, legitimate catalog controls, empty/small/residual/competing-rule flags. No universal semantic perfection claim.'
report['baseline_sha256']=hashlib.sha256(args.baseline.read_bytes()).hexdigest() if args.baseline.exists() else None
report['comparison']='Previous classifications independently execute the frozen owned dev.11 source and match every corresponding immutable dev.11 audit row. Legacy broad membership retains owned dev.8 resolution. No Better Sorting Lua/database executed.'
report['ambiguities']=[
 {'family':'Residual Misc cases','decision':'Every current Misc identity is listed below with metadata. Live animals, carriable corpses, financial tokens, props, loose junk and empty waste stay residual; no speculative purpose/name rule. Obtaining and intended use of props/dummy identities requires runtime evidence.'},
 {'family':'Sports weapons','decision':'Reviewed rackets, weights, paddles and bowling pin use Recreation; bats, golf clubs, pool cues, hockey/lacrosse sticks and broken instrument necks retain native melee purpose. Generic foreign SportsWeapon stays melee. Alternate player expectations need a human policy decision.'},
 {'family':'Collectible games','decision':'Tarot/Ouja and collectible game objects with memento identity retain Keepsakes where no stronger recreation rule applies. Decide whether occult collectibles should become Recreation before extending that rule.'},
 {'family':'Fluid mixtures and ingredients','decision':'Initial script fluids determine stable product purpose. Refilling, unknown mixtures and current fluid contents do not recategorize instances. Grenadine, syrup and lemon juice remain ingredients; condensed canned milk follows its reviewed drink family. Further ingredient/beverage distinctions require a human decision.'},
 {'family':'Writable/printed materials','decision':'Verified vanilla writable families use bounded Base identity plus literature/display metadata because CanBeWrite has no exposed instance getter. Foreign writable books without exposed semantic metadata retain literature fallback; no arbitrary name guessing.'},
 {'family':'Containers versus production equipment','decision':'Empty fired ceramic vessels/crucibles with native fluid components use Fluid Containers; unfired/cast definitions remain General Materials. Whether foundry/glassworking vessels should instead be specialized tools needs a human decision.'},
 {'family':'Raw versus finished materials','decision':'Wooden molds/casts and finished mixed objects remain General Materials; fiber/fabric and fur inputs follow their verified identities. Buttons/beads used as fasteners use Fasteners. Do not classify every wooden finished object as raw wood.'},
 {'family':'Broad residual categories','decision':'Complete dev.12 General Materials, General Tools, Household Utilities, General Food, Other Containers, General Literature, Other Weapons and Misc member lists are in dev12-final-taxonomy-review.md. Calculator, buckle, drafting compass, paintbrushes, finished glassblowing pipe and ration water are corrected; remaining residual objects retain the reviewed practical storage purposes.'},
 {'family':'Internal-looking catalog entries','decision':'Verified hidden/display-hidden, Base wound/zed-damage representations and four exact development definitions are excluded only from default catalog. Hair/beard/makeup and Book props, TestWaterMug, corpses, animal placeholders and unfamiliar foreign definitions remain available where evidence is insufficient. Native obtainability is untested.'},
 {'family':'Empty/small categories','decision':'FirearmsOther, MeleeAxes with tool policy on and OutdoorOther remain supported physical fallbacks, hidden until populated or selected. Water, AnimalSupplies, ElectricalComponents/Power and VehicleBatteries are now narrow semantic/legacy identities mapped into consolidated destinations. Recorded Media remains physical: few script prototypes represent many recorded titles. Native mod ownership/load order requires runtime audit. Every dev.12 category under 15 identities is justified in dev12-final-taxonomy-review.md.'}
]
output=ROOT/'docs/CATEGORY_AUDIT.json'
output.write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
for source in report['sources']:
    print(source['root'],source['items'],'items',source['category_counts'],'reasons',source['reason_counts'])
review=ROOT/'dist/handoffs/dev12-category-review.md'
lines=['# Static taxonomy review — '+report['projectVersion'], '', report['limits'], '', '| ID | Name | Direct classification count | Broad-rule coverage count | Examples |','| --- | --- | ---: | ---: | --- |']
vanilla=report['sources'][0]
for t in report['taxonomy']:
 lines.append('| '+t['id']+' | '+t['name']+(' (compatibility family)' if t['compatibilityFamily'] else '')+' | '+str(vanilla['category_counts'].get(t['id'],0))+' | '+str(vanilla['family_coverage_counts'].get(t['id'],0))+' | '+', '.join(vanilla['examples'].get(t['id'],[]))+' |')
lines.extend(['','## Miscellaneous — review required',''])
for row in vanilla['rows']:
 if row['category']=='B47_Misc':lines.append('- '+row['fullType']+'; type='+str(row['type'])+'; display category='+str(row['displayCategory'])+'; tags='+str(row['tags']))
lines.extend(['','## Unresolved semantic families / human decisions',''])
for entry in report['ambiguities']:lines.append('- **'+entry['family']+':** '+entry['decision'])
for title,selected in (
 ('Excluded from the user catalog',[row for row in vanilla['rows'] if not row['catalogEligible']]),
 ('All classification changes from dev.11',[row for row in vanilla['rows'] if row['changed']]),
 ('All competing purpose / structural rules',[row for row in vanilla['rows'] if len({m['category'] for m in row['competingRules']})>1]),
 ('All new-category members',[row for row in vanilla['rows'] if row['category'] in ('B47_Instruments','B47_Smoking','B47_Recreation','B47_Stationery','B47_AnimalSupplies')])):
 lines.extend(['','## '+title,'','| FullType | dev.11 | Current | Winner | Catalog exclusion | Competing rules |','| --- | --- | --- | --- | --- | --- |'])
 for row in selected:
  lines.append('| '+row['fullType']+' | '+row['previousCategory']+' | '+row['category']+' | '+row['reason']+' | '+str(row['catalogExclusionReason'] or '')+' | '+'; '.join(m['category']+': '+m['reason'] for m in row['competingRules'])+' |')
lines.extend(['','## Every explicit override','','| FullType | Category | Reason |','| --- | --- | --- |'])
for entry in report['explicitOverrides']:lines.append('| '+entry['fullType']+' | '+entry['category']+' | '+entry['reason']+' |')
lines.extend(['','## Every bounded vanilla family selector','','All selectors require Base module and the displayed metadata gates; no localized name matching.','','| Family | Pattern | Kind | Display categories | Category | All matched FullTypes |','| --- | --- | --- | --- | --- | --- |'])
for entry in report['scopedFamilies']:lines.append('| '+entry['id']+' | `'+entry['pattern']+'` | '+str(entry['kind'] or '')+' | '+', '.join(entry['displayCategories'])+' | '+entry['category']+' | '+', '.join(entry['matchedFullTypes'])+' |')
lines.extend(['','## Quality flags','',json.dumps(vanilla['quality_gates'],indent=2),'','## Complete broad residual review',''])
for id in vanilla['quality_gates']['residual_category_counts']:
 lines.extend(['','### '+id,''])
 for row in vanilla['rows']:
  if row['category']==id:lines.append('- '+row['fullType']+'; winner='+row['reason']+'; display='+str(row['displayCategory'])+'; tags='+str(row['tags'])+'; catalog='+str(row['catalogEligible']))
review.write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('Wrote',output,review)

