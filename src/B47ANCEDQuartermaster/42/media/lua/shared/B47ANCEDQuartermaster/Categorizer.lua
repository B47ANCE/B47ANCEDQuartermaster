-- Original functional taxonomy, based on vanilla B42 script metadata.
-- No third-party category IDs, item lists, classification code or runtime APIs.
require 'B47ANCEDQuartermaster/Schema'
local Migration=require 'B47ANCEDQuartermaster/Migration'
local R={version=6,overrides={
    ['Base.Hat_Spiffo']='ClothingCostumes',
    ['Base.SpiffoSuit']='ClothingCostumes',
    ['Base.SpiffoTail']='ClothingCostumes',
    ['Base.BunnySuitBlack']='ClothingCostumes',
    ['Base.BunnySuitPink']='ClothingCostumes',
    ['Base.BunnyTail']='ClothingCostumes',
    ['Base.Hat_BunnyEarsBlack']='ClothingCostumes',
    ['Base.Hat_BunnyEarsWhite']='ClothingCostumes',
    ['Base.Scissors']='Stationery', -- User-requested office scissors classification; native metadata remains intact.
    ['Base.ScissorsBlunt']='Stationery', -- Vanilla Safety Scissors; medical shears retain medical classification.
    ['Base.Calculator']='ElectricalOther', -- Household/metal metadata lacks its electronic device purpose.
    ['Base.Buckle']='MaterialsFasteners', -- Vanilla belt crafting consumes this fastening component.
    ['Base.CompassGeometry']='Stationery', -- Drafting compass is primarily stationery despite improvised weapon metadata.
    ['Base.GlassBlowingPipe']='ToolsGeneral', -- Vanilla glassmaking retains this reusable implement with mode:keep.
    ['Base.WaterRationCan_Box']='BeveragesWater', -- Box opens water ration cans, not ordinary canned meals.
    ['Base.WaterRationCan']='BeveragesWater', -- Native OpenWaterRationCan/openWaterCan creates drinking water, despite Food metadata.

    -- Vanilla script metadata has no generic identity for these important commodities.
    ['Base.Battery']='ElectricalPower', -- Generic Electronics; no script-level power-supply tag.
    ['Base.Nails']='MaterialsFasteners', -- Material + fishinghook; that tag also marks paperclips.
    ['Base.Screws']='MaterialsFasteners', -- Generic Material; no fastener tag.
    ['Base.NailsBox']='MaterialsFasteners', -- Generic metal material; opening recipe identifies neither contents nor purpose.
    ['Base.ScrewsBox']='MaterialsFasteners', -- Same generic metadata as unrelated metal supply boxes.
    ['Base.Plank']='MaterialsWood', -- MaterialWeapon; fuel/tinder tags do not identify wood.
    ['Base.BlowTorch']='ToolsMetal', -- Generic Tool, without a role-specific native tag.
    ['Base.Jack']='ToolsMechanics', -- VehicleMaintenance metadata does not distinguish tool from part.
    ['Base.TirePump']='ToolsMechanics', -- Same broad mechanics metadata as parts.
    ['Base.CameraFilm']='ElectricalOther', -- Untagged camera accessory; camera tag covers the devices.
    ['Base.Comb']='HouseholdCare', -- Untagged Junk grooming implement.
    ['Base.Toothbrush']='HouseholdCare', -- Untagged Junk hygiene implement.
    ['Base.Toothpaste']='HouseholdCare', -- Untagged Junk hygiene product.
    ['Base.Soap2']='HouseholdCare', -- Household soap used for personal washing; not every Household item is care.
    ['Base.SteelWool']='HouseholdCleaning', -- Generic Tool/metal/tinder, verified scouring supply.
    ['Base.ToiletPaper']='HouseholdOther', -- Junk/tinder tags cannot establish household paper purpose.
    ['Base.PaperNapkins']='HouseholdOther', -- Untagged household paper; locked storage decision.
    ['Base.PaperNapkins2']='HouseholdOther', -- Drainable household paper with sneeze/fuel tags.
    ['Base.ElectricWire']='ElectricalComponents', -- Electronics without component tag.
    ['Base.ElectronicsScrap']='ElectricalComponents', -- Generic Electronics salvage, not a complete device.
    ['Base.BatteryBox']='ElectricalPower', -- Boxed portable cells; no power tag.
    ['Base.LargePlank']='MaterialsWood', -- Generic Material/heavy item, not uniquely wood.
    ['Base.LargeBranch']='MaterialsWood', -- MaterialWeapon/fuel does not establish wood generically.
    ['Base.Twigs']='MaterialsWood', -- Generic Material fuel/tinder, verified wood stock.
    ['Base.FirewoodBundle']='MaterialsWood', -- Generic Material/fuel bundled wood.
    ['Base.CopperSheet']='MaterialsMetal', -- Untagged sheet stock.
    ['Base.SmallCopperSheet']='MaterialsMetal', -- Untagged sheet stock.
    ['Base.Yarn']='MaterialsTextile', -- Material/dye/fuel lacks textile identity.
    ['Base.WoolRaw']='MaterialsTextile', -- Untagged raw textile fiber, deliberately Textile rather than Animal.
    ['Base.CheeseCloth']='MaterialsTextile', -- Untagged cloth stock.
    ['Base.DuctTapeBox']='MaterialsBinding', -- Box loses native tape tag.
    ['Base.AdhesiveTapeBox']='MaterialsBinding', -- Box loses native adhesive tag.
    ['Base.String']='MaterialsBinding', -- Untagged binding stock.
    ['Base.RopeStack']='MaterialsBinding', -- Untagged rope stack.
    ['Base.WallpaperPastePowder']='MaterialsBinding', -- Untagged adhesive powder.
    ['Base.Tobacco']='Smoking', -- Food/Tool and shelf life lack smoking tags; seeds remain Farming.
    ['Base.TobaccoDried']='Smoking', -- Untagged processed tobacco Tool.
    ['Base.CigaretteCarton']='Smoking', -- Carton lacks smokable tag; refillable cigar boxes remain Containers.
    ['Base.SmokingPipe']='Smoking', -- Untagged finished pipe; unfired pottery remains material.
    ['Base.SmokingPipe_Tobacco']='Smoking', -- Loaded smoking state uses separate script identity without tags.
    ['Base.CanPipe']='Smoking', -- Untagged crafted smoking supply; Base.Pipe is plastic pipe, not smoking.
    ['Base.CanPipe_Tobacco']='Smoking', -- Loaded crafted smoking pipe lacks smoking tags.
    ['Base.Stapler']='Stationery', -- Junk/metal lacks office semantics.
    ['Base.Staples']='Stationery', -- Drainable Junk/metal, not construction fasteners.
    ['Base.HolePuncher']='Stationery', -- Untagged office implement.
    ['Base.Clipboard']='Stationery', -- Household metadata cannot establish office implement.
    ['Base.CorrectionFluid']='Stationery', -- Household/consumable, not grooming or beverage.
    ['Base.Paperclip']='Stationery', -- Material/fishinghook also marks nails; stationery primary identity.
    ['Base.PaperclipBox']='Stationery', -- Untagged boxed stationery.
    ['Base.CardDeck']='Recreation', -- Junk/fuel, not literature.
    ['Base.PokerChips']='Recreation', -- Junk/wallet does not uniquely establish game equipment.
    ['Base.Bellows']='ToolsMetal', -- Untagged Tool, verified smithing implement.
    ['Base.CrudeBenchVise']='ToolsMetal', -- Tool/hasmetal lacks discipline-specific tag.
    ['Base.CrudeBenchViseParts']='MaterialsMetal', -- Parts are material, not functioning vise, despite Tool category.
    ['Base.Note']='LiteratureNotes', -- Junk/uninteresting is not a writable flag; genuine personal document.
    ['Base.LetterHandwritten']='LiteratureNotes', -- Junk/uninteresting personal correspondence.
    ['Base.BadmintonRacket']='Recreation', -- Ordinary racket; SportsWeapon alone is not sufficient for other items.
    ['Base.TennisRacket']='Recreation', -- Ordinary sporting racket, not a weapon-oriented variant.
    ['Base.BowlingPin']='Recreation', -- Ordinary game apparatus.
    ['Base.DumbBell']='Recreation', -- Actual fitness weight, independently reviewed SportsWeapon.
    ['Base.DumbBell_Forged']='Recreation', -- Crafted fitness weight retains the same primary purpose.
    ['Base.BarBell']='Recreation', -- Actual fitness apparatus.
    ['Base.BarBell_Forged']='Recreation', -- Crafted fitness apparatus.
    ['Base.CanoePadel']='Recreation', -- Ordinary canoe paddle, not every blunt SportsWeapon.
    ['Base.CanoePadelX2']='Recreation', -- Ordinary double paddle.
    ['Base.CarBatteryCharger']='ToolsMechanics', -- Maintenance device, not battery/vehicle part.
    ['Base.WeldingRods']='MaterialsMetal', -- Untagged drainable welding metal stock.
    ['Base.BurlapPiece']='MaterialsTextile', -- Material/simple binding tag does not establish textile stock.
    ['Base.SheetRopeBundle']='MaterialsBinding', -- Bundle lacks rope identity tag; binding purpose.
    ['Base.Tsquare']='Stationery', -- Untagged drafting implement.
    ['Base.DishClothWet']='HouseholdCleaning', -- Separate wet script lacks the dry cleaning tag; same implement.
    ['Base.BathTowelWet']='HouseholdCleaning', -- Separate wet script lacks dry cleanstains tag.
    ['Base.ClayPlate']='HouseholdKitchen', -- Untagged fired ceramic plate; unfinished form remains material.
    ['Base.LargeBellows']='ToolsMetal', -- Moveable/Material forge equipment lacks the portable bellows purpose tag.
    ['Base.Dogbane']='MaterialsTextile', -- Untagged fiber stock; vanilla twine and loom recipes share it with processed hemp/flax.
}}
-- Bounded historical memberships for the eight reviewed dev.12 corrections.
-- These preserve saved scopes; they never determine current semantic purpose.
R.priorPurposes={
    ['Base.Calculator']='B47_HouseholdOther',
    ['Base.Buckle']='B47_MaterialsOther',
    ['Base.CompassGeometry']='B47_MeleeOther',
    ['Base.GlassBlowingPipe']='B47_MaterialsOther',
    ['Base.WaterRationCan_Box']='B47_FoodOther',
    ['Base.WaterRationCan']='B47_FoodShelfStable',
    ['Base.Paintbrush']='B47_ToolsGeneral',
    ['Base.PaintbrushCrafted']='B47_ToolsGeneral',
}
B47ANCEDQuartermaster.Categorizer=R
R.labels={Ammo='Ammunition',Firearms='Firearms',Melee='Melee weapons',WeaponParts='Weapon parts',
    Tools='Tools and maintenance',Medical='Medical supplies',Food='Food',Beverages='Beverages',
    Clothing='Clothing and accessories',Literature='Books and written material',Media='Media',
    Materials='Crafting materials',Vehicle='Vehicle parts',Outdoor='Outdoor equipment',
    Containers='Bags and containers',Electrical='Electrical equipment',Household='Household goods',Misc='Miscellaneous'}
local function read(item,key)
    local ok,value=pcall(function() local fn=item and item[key];return fn and fn(item) end)
    if ok then return value end
end
local function atom(value)
    if value==nil then return '' end
    return string.lower(tostring(value)):gsub('^.*:',''):gsub('[ _%-]','')
end
local function tagSet(item)
    local set={}
    local tags=read(item,'getTags')
    if not tags then return set end
    local ok=pcall(function()
        local it=tags:iterator()
        while it:hasNext() do set[atom(it:next())]=true end
    end)
    if not ok and type(tags)=='table' then for _,tag in ipairs(tags) do set[atom(tag)]=true end end
    return set
end
local function any(tags,keys) for _,key in ipairs(keys) do if tags[key] then return true end end end
-- These fallback keys are vanilla DisplayCategory values, not third-party taxonomy.
local fallback={Ammo='Ammo',WeaponPart='WeaponParts',FirstAid='Medical',FirstAidWeapon='Medical',
    Food='Food',Clothing='Clothing',Accessory='Clothing',Literature='Literature',Cartography='Literature',
    SkillBook='Literature',Entertainment='Media',Material='Materials',MaterialWeapon='Materials',
    VehicleMaintenance='Vehicle',VehicleMaintenanceWeapon='Vehicle',Fishing='Outdoor',Trapping='Outdoor',
    Gardening='Outdoor',Camping='Outdoor',Container='Containers',Electronics='Electrical',
    Household='Household',Cooking='Household',Appearance='Household',Cleaning='Household',
    Paint='Materials',Tool='Tools',ToolWeapon='Tools',Water='Beverages',WaterContainer='Containers',
    FireSource='Outdoor',LightSource='Outdoor'}
function R.label(id)
    local short=type(id)=='string' and id:match('^B47_(.+)$')
    return short and R.labels[short] and getText('UI_B47_Category_'..short) or id
end
function R.legacyResolve(value)
    local item=read(value,'getScriptItem') or value
    local fullType=read(item,'getFullName') or read(value,'getFullType')
    local tags=tagSet(item)
    local kind=atom(read(item,'getItemType'))
    local function result(cat,reason) return 'B47_'..cat,reason end
    if atom(read(item,'getBodyLocation'))=='ammostrap' then return result('Clothing','bandolier-location') end
    if any(tags,{'ammo','ammocase','ammobox','magazine'}) then return result('Ammo','tag') end
    if kind=='weaponpart' then return result('WeaponParts','type') end
    if read(item,'isMedicalLoot')==true or any(tags,{'bandage','suture','disinfectant','medical'}) then return result('Medical','medical') end
    if read(item,'isMechanicsLoot')==true or any(tags,{'brake','suspension','tire','carbattery'}) then return result('Vehicle','mechanics') end
    if read(item,'isRanged')==true then return result('Firearms','ranged') end
    local preferTools=true
    if any(tags,{'hammer','ballpeenhammer','screwdriver','saw','weldingmask','blowtorch','pliers',
        'wrench','crowbar','canopener','scissors','needle','sewingneedle','axe','digplow','takedirt','awl'}) then
        return result((preferTools or kind~='weapon') and 'Tools' or 'Melee','tool-tag')
    end
    if any(tags,{'fishingrod','fishingnet','tent','campfirekit','startfire','flashlight'}) then return result('Outdoor','outdoor-tag') end
    if any(tags,{'alcoholicbeverage','waterbottle','beverage','sealedbeveragecan'}) then return result('Beverages','beverage-tag') end
    if kind=='food' then return result('Food','type') end
    if kind=='clothing' or kind=='alarmclockclothing' or read(item,'getBodyLocation')~=nil then return result('Clothing','type') end
    if kind=='container' then return result('Containers','type') end
    if kind=='literature' or kind=='map' then return result('Literature','type') end
    if kind=='radio' or kind=='alarmclock' then return result('Electrical','type') end
    if kind=='moveable' or kind=='key' or kind=='keyring' then return result('Household','type') end
    local media=read(item,'getRecordedMediaCat')
    if type(media)=='string' and media~='' then return result('Media','media') end
    if any(tags,{'thread','fabric','leather','barstock','sheetmetal','plank','nails','screws','wire','rope','twine'}) then return result('Materials','material-tag') end
    local existing=read(item,'getDisplayCategory')
    if not preferTools and kind=='weapon' and (existing=='Tool' or existing=='ToolWeapon') then return result('Melee','tool-setting') end
    if fallback[existing] then return result(fallback[existing],'vanilla-category') end
    if kind=='weapon' then return result('Melee','type') end
    if any(tags,{'bowl','mug','cup','plate','cookingpot','pan'}) then return result('Household','household-tag') end
    return result('Misc','fallback')
end
-- New rules extend the same resolver; the original resolver above is retained only
-- to preserve the exact membership of existing broad saved rules across corrections.
local F=require 'B47ANCEDQuartermaster/Taxonomy'
local H=require 'B47ANCEDQuartermaster/StorageSemantics'
R.families=F
for id in pairs(F.parents) do R.labels[id:sub(5)]=true end
function R.known(id) return type(id)=='string' and R.labels[id:sub(5)]~=nil and id:sub(1,4)=='B47_' end
function R.isFamily(id) return F.children[id]~=nil end
function R.isLegacy(id) return F.destinations[id]~=nil end
function R.isCompatibility(id) return R.isFamily(id) or R.isLegacy(id) end
function R.isLeaf(id) return R.known(id) and not R.isLegacy(id) and (not R.isFamily(id) or id=='B47_Misc') end
function R.validRules(cats,previous)
    for id,on in pairs(cats) do
        if on~=true or (not R.known(id) and not (previous and previous[id]==true)) then return false end
    end
    return true
end
function R.memberships(category,legacy,semantic,historical,secondary)
    semantic=semantic or category;historical=historical or semantic
    local out={[F.destination(category)]=true}
    if not R.isLegacy(semantic) then out[semantic]=true end
    if R.isLegacy(historical) then out[historical]=true end
    if ({B47_MeleeOther=true,B47_MeleeAxes=true,B47_MeleeBlades=true,B47_LongGuns=true,B47_WeaponParts=true})[historical] then
        out[F.destination(historical)]=true
    end
    for _,purpose in ipairs({semantic,historical}) do
        for _,parent in ipairs(F.parents[purpose] or {}) do out[parent]=true end
    end
    if R.isFamily(legacy) then out[legacy]=true end
    if secondary and R.known(secondary) then
        out[secondary]=true
        for _,parent in ipairs(F.parents[secondary] or {}) do out[parent]=true end
    end
    return out
end
function R.match(category,cats,legacy,semantic,historical,secondary)
    if not R.known(category) then return 0 end
    semantic=semantic or category;historical=historical or semantic;category=F.destination(category)
    if cats[category] then return 3 end
    if secondary and cats[secondary] then return 2 end
    if (R.isLegacy(historical) or historical~=semantic) and (cats[historical] or cats[F.destination(historical)]) then return 2 end
    for rule in pairs(R.memberships(category,legacy,semantic,historical,secondary)) do
        if R.isFamily(rule) and cats[rule] then return 1 end
    end
    return 0
end
local function listSet(value)
    local out={};if not value then return out end
    local ok=pcall(function()
        local it=value:iterator()
        while it:hasNext() do out[atom(it:next())]=true end
    end)
    if not ok and type(value)=='table' then for _,v in ipairs(value) do out[atom(v)]=true end end
    return out
end
local locations={
 ClothingJewelry={'rightmiddlefinger','leftmiddlefinger','rightringfinger','leftringfinger','ears','necklace','necklacelong','rightwrist','leftwrist'},
 ClothingEquipment={'ammostrap','holster','holsterleft','holsterright','holsterdouble','shoulderholster','belt','beltextra','fannypackfront','fannypackback'},
 ClothingHead={'hat','fullhat'},ClothingEyes={'eyes'},ClothingFace={'mask','maskeyes'},
 ClothingTops={'tshirt','shirt','shortsleeveshirt','tanktop','sweater','sweatervest','jersey'},
 ClothingOuterwear={'jacket','jacketsuit','jacketbulky','jacketdown','jacketlong','jacketlongdown','jacketlongbulky','coat'},
 ClothingBottoms={'pants','pantsskinny','shortpants','shortsshort','skirt','longskirt','dress','longdress'},
 ClothingUnderwear={'underwear','underweartop','underwearbottom','underwearextra1','underwearextra2'},
 ClothingSocks={'socks'},ClothingFootwear={'shoes'},ClothingGloves={'hands'},
 ClothingAccessories={'neck','tie','scarf'}
}
local locationCategory={}
for cat,list in pairs(locations) do for _,loc in ipairs(list) do locationCategory[loc]=cat end end
local tools={
 {'ToolsMetal',{'smithinghammer','ballpeenhammer','metalworkingchisel','metalworkingpliers','metalworkingpunch','weldingmask','blowtorch','sheetmetalsnips','lightmetalsnips','drillmetal'}},
 {'ToolsMechanics',{'wrench','lugwrench','jack','tirepump'}},
 {'ToolsSewing',{'sewingneedle','needle','knittingneedles','awl'}},
 {'ToolsCarpentry',{'hammer','saw','carpentrychisel','drillwood','drillwoodpoor','smallsaw','crudesaw'}},
 {'ToolsFarming',{'digplow','takedirt','digworms','scythe','shear'}},
 {'ToolsCutting',{'axe','choptree','scissors','sharpknife'}},
 {'ToolsGeneral',{'screwdriver','pliers','crowbar','canopener'}}
}
local display={
 Ammo='AmmoLoose',WeaponPart='WeaponAttachments',FirstAid='MedicalOther',FirstAidWeapon='MedicalOther',
 Food='FoodOther',Clothing='ClothingOther',Accessory='ClothingAccessories',ProtectiveGear='ClothingProtective',
 Literature='LiteratureOther',Cartography='LiteratureMaps',SkillBook='LiteratureSkill',RecipeResource='LiteratureManuals',
 Entertainment='Media',Material='MaterialsOther',MaterialWeapon='MaterialsOther',VehicleMaintenance='VehicleOther',VehicleMaintenanceWeapon='VehicleOther',
 Fishing='OutdoorFishing',FishingWeapon='OutdoorFishing',Trapping='OutdoorTrapping',Gardening='OutdoorFarming',GardeningWeapon='ToolsFarming',Camping='OutdoorCamping',
 Container='ContainersOther',Bag='ContainersBags',WaterContainer='ContainersFluid',Electronics='ElectricalOther',Communications='ElectricalRadios',
 Household='HouseholdOther',HouseholdWeapon='HouseholdOther',Cooking='HouseholdKitchen',CookingWeapon='HouseholdKitchen',
 Appearance='HouseholdCare',Cleaning='HouseholdCleaning',Paint='MaterialsPaint',Tool='ToolsGeneral',ToolWeapon='ToolsGeneral',
 Water='BeveragesWater',FireSource='OutdoorFire',LightSource='OutdoorLighting',Furniture='HouseholdFurnishings',Security='HouseholdKeys'
}
local cache=setmetatable({},{__mode='k'})
local firearmTypes={['Base.AssaultRifle']='AssaultRifles',['Base.AssaultRifle2']='AssaultRifles',
 ['Base.HuntingRifle']='SniperRifles',['Base.VarmintRifle']='SniperRifles',['Base.MSR7T_Rifle']='SniperRifles'}
local function explosive(item,tags)
 if any(tags,{'explosive','grenade','molotov','smokebomb','pipebomb'}) then return true end
 local full=read(item,'getFullName') or ''
 if full=='Base.Molotov' then return true end
 for _,base in ipairs({'Aerosolbomb','FlameTrap','PipeBomb','SmokeBomb'}) do
  for _,suffix in ipairs({'','Remote','SensorV1','SensorV2','SensorV3','Triggered'}) do
   if full=='Base.'..base..suffix then return true end
  end
 end
 return false
end
local function classify(item,tags,kind,existing,preferTools,skipPurpose)
    local function result(cat,why) return 'B47_'..cat,why end
    if kind=='weaponpart' then return result('WeaponAttachments','type') end
    if any(tags,{'firearmpart','gunpart','firearmcomponent'}) then return result('WeaponComponents','firearm-component') end
    if kind=='weapon' and explosive(item,tags) then return result('Explosives','explosive-identity') end
    if tags.paintbrush and existing=='Tool' then return result('MaterialsPaint','paintbrush-purpose') end
    if kind=='key' or kind=='keyring' or tags.keyring then return result('HouseholdKeys','key-semantics') end
    if locationCategory[atom(read(item,'getBodyLocation'))]=='ClothingEquipment' then
        return result((existing=='ProtectiveGear' or tags.armor) and 'ClothingEquipmentArmor' or 'ClothingEquipment','equipment-location')
    end
    if not skipPurpose and kind~='clothing' and kind~='alarmclockclothing' and (kind=='container' or read(item,'getBodyLocation')==nil) then
        local rules=H.matches(item,tags,kind,existing,read(item,'getFullName'))
        for _,rule in ipairs(rules) do
            -- Primary instruments/recreation are independent of the tool option.
            -- Multipurpose weapon-tools and cutting kitchen tools retain its meaning.
            if not (kind=='weapon' and not preferTools and (rule.category:match('^B47_Tools') or rule.category=='B47_HouseholdKitchen')) then return rule.category,rule.reason end
        end
    end
    -- Printed magazines share vanilla's generic magazine tag with firearm clips.
    if kind~='literature' then
        if any(tags,{'pistolmagazine','riflemagazine'}) or (tags.magazine and existing=='Ammo') then return result('AmmoMagazines','firearm-magazine') end
        if kind=='container' and any(tags,{'ammocase','ammobox'}) then return result('AmmoBoxes','ammo-container') end
        if any(tags,{'ammocase','ammobox'}) then return result('AmmoPackages','ammo-package') end
        if tags.ammo then return result('AmmoLoose','ammo-tag') end
        if existing=='Ammo' and type(read(item,'getDoubleClickRecipe'))=='string' and read(item,'getDoubleClickRecipe')~='' then return result('AmmoPackages','ammo-opening-recipe') end
    end
    if kind=='weaponpart' then return result('WeaponAttachments','type') end
    if kind=='key' or kind=='keyring' or tags.keyring then return result('HouseholdKeys','key-semantics') end
    if tags.cleanstains then return result('HouseholdCleaning','cleaning-tag') end
    if read(item,'isCanBandage')==true or any(tags,{'bandage','reusablebandage'}) then return result('MedicalBandages','bandage') end
    if kind=='clothing' or kind=='alarmclockclothing' or (kind~='container' and read(item,'getBodyLocation')~=nil) then
        if tags.costume or tags.mascot then return result('ClothingCostumes','costume-tag') end
        local slot=locationCategory[atom(read(item,'getBodyLocation'))] or (existing=='ProtectiveGear' and 'ClothingOuterwear' or 'ClothingOther')
        if existing=='ProtectiveGear' or tags.armor then
            -- Armored collars/wrist gear are equipment, not decorative jewelry.
            local base=(slot=='ClothingJewelry' or slot=='ClothingAccessories') and 'B47_ClothingEquipment' or F.destination('B47_'..slot)
            local armor=F.armorDestinations[base]
            if armor then return armor,'armor-body-location' end
        end
        return result(slot,'body-location')
    end
    if read(item,'isMedicalLoot')==true or any(tags,{'medical','suture','disinfectant'}) then
        if any(tags,{'removebullet','removeglass','mortarpestle','scissors','suture','sutureneedle'}) then return result('MedicalTools','medical-tool') end
        if kind=='food' or tags.consumable then return result('MedicalMedicine','medical-consumable') end
        return result('MedicalOther','medical')
    end
    if tags.carbattery then return result('VehicleBatteries','vehicle-battery') end
    if any(tags,{'wholetire','tire'}) then return result('VehicleTires','vehicle-tire') end
    if tags.toolhead then return result('MaterialsMetal','tool-component') end
    if tags.fakeweapon then return result('HouseholdKeepsakes','toy-tag') end
    local weapon=listSet(read(item,'getWeaponCategories'))
    if read(item,'isRanged')==true then
        if atom(read(item,'getAmmoType'))=='shotgunshells' then return result('Shotguns','shotgun-ammo') end
        if any(tags,{'submachinegun','smg'}) then return result('SubMachineGuns','firearm-tag') end
        if tags.assaultrifle then return result('AssaultRifles','firearm-tag') end
        if any(tags,{'sniperrifle','boltactionrifle'}) then return result('SniperRifles','firearm-tag') end
        local typed=firearmTypes[read(item,'getFullName')]
        if typed then return result(typed,'vanilla-firearm-identity') end
        local anim=atom(read(item,'getSwingAnim'))
        if anim=='handgun' then return result('Handguns','firearm-animation') end
        return result('FirearmsOther','ranged')
    end
    local function melee()
        if weapon.axe then return result('MeleeLongBlade','weapon-category') end
        if weapon.spear then return result('MeleeSpears','weapon-category') end
        if weapon.smallblade then return result('MeleeShortBlade','weapon-category') end
        if weapon.longblade then return result('MeleeLongBlade','weapon-category') end
        if weapon.smallblunt then return result('MeleeBlunt','weapon-category') end
        if weapon.blunt then return result('MeleeLongBlunt','weapon-category') end
        return result('MeleeOther','weapon-type')
    end
    if kind=='weapon' and not preferTools and (weapon.axe or existing=='Tool' or existing=='ToolWeapon' or existing=='GardeningWeapon') then return melee() end
    for _,rule in ipairs(tools) do
        if any(tags,rule[2]) then
            if kind=='weapon' and not preferTools then return melee() end
            return result(rule[1],'tool-use')
        end
    end
    if kind=='weapon' and weapon.axe and preferTools then return result('ToolsCutting','axe-use') end
    if read(item,'isMechanicsLoot')==true then return result('VehicleOther','mechanics') end
    if any(tags,{'flashlight','litlantern','unlitlantern','lightbar'}) then return result('OutdoorLighting','light-tag') end
    if any(tags,{'startfire','lighter','lighterfluid'}) then return result('OutdoorFire','fire-tag') end
    if any(tags,{'fishingrod','fishingnet'}) or existing=='Fishing' then return result('OutdoorFishing','fishing') end
    if existing=='Trapping' then return result('OutdoorTrapping','vanilla-category') end
    if any(tags,{'tent','tentbed','campfirekit'}) or existing=='Camping' then return result('OutdoorCamping','camping') end
    -- Seed packets are literature in vanilla; storage purpose is identified by Gardening.
    if existing=='Gardening' or tags.farmingloot then return result('OutdoorFarming','farming') end
    if existing=='WaterContainer' then return result('ContainersFluid','fluid-container-category') end
    if kind=='container' then
        if read(item,'getBodyLocation')~=nil or existing=='Bag' then return result('ContainersBags','bag') end
        return result('ContainersOther','container')
    end
    if kind=='radio' then return result('ElectricalRadios','type') end
    if kind=='alarmclock' then return result('ElectricalOther','type') end
    if kind=='moveable' then return result('HouseholdFurnishings','type') end
    if read(item,'isAlcoholic')==true or (tags.alcoholicbeverage and not tags.herbaltea) then return result('BeveragesAlcohol','alcohol') end
    if any(tags,{'waterbottle','beverage','sealedbeveragecan'}) or (tags.alcoholicbeverage and tags.herbaltea) then return result('BeveragesOther','beverage-tag') end
    if existing=='Water' then return result('BeveragesWater','vanilla-category') end
    if kind=='literature' or kind=='map' then
        if kind=='map' or existing=='Cartography' then return result('LiteratureMaps','map') end
        if type(read(item,'getSkillTrained'))=='string' and read(item,'getSkillTrained')~='' or existing=='SkillBook' then return result('LiteratureSkill','trained-skill') end
        local recipes=read(item,'getLearnedRecipes')
        local hasRecipes=false
        if recipes then
            local ok,count=pcall(function() return type(recipes)=='table' and #recipes or recipes:size() end)
            hasRecipes=ok and type(count)=='number' and count>0
        end
        local recipeCount=read(item,'hasResearchableRecipes')
        if recipeCount==true or hasRecipes then return result('LiteratureManuals','recipe-learning') end
        if any(tags,{'magazine','newspaper','newspaperread'}) then return result('LiteratureMagazines','printed-periodical') end
        if tags.write then return result('LiteratureNotes','writing') end
        if existing=='RecipeResource' then return result('LiteratureManuals','vanilla-category') end
        return result('LiteratureOther','literature-type')
    end
    if tags.write and existing=='Literature' then return result('LiteratureNotes','writing') end
    local media=read(item,'getRecordedMediaCat')
    if (type(media)=='string' and media~='') or existing=='Entertainment' then return result('Media','media') end
    if kind=='weapon' and existing~='MaterialWeapon' then
        if existing=='CookingWeapon' then return result('HouseholdKitchen','kitchen-category') end
        if existing=='FishingWeapon' then return result('OutdoorFishing','fishing-category') end
        return melee()
    end
    if tags.battery then return result('ElectricalPower','power-tag') end
    -- Material tags are applied only after equipment/clothing/literature handling.
    if any(tags,{'nails','screws'}) then return result('MaterialsFasteners','material-tag') end
    if tags.wire then return result('ElectricalComponents','material-tag') end
    local textile,wood,metal=false,false,false
    for tag in pairs(tags) do
        if tag:match('^leather') then textile=true end
        if tag:match('^makewoodcharcoal') then wood=true end
        if tag:match('^smeltable') then metal=true end
    end
    if textile or any(tags,{'thread','fabric','leather','heavythread'}) or (existing=='Material' and any({[atom(read(item,'getFabricType'))]=true},{'cotton','denim','leather'})) then return result('MaterialsTextile','material-tag') end
    if wood or any(tags,{'plank','woodhandle','giveslongstick'}) then return result('MaterialsWood','material-tag') end
    if any(tags,{'barstock','sheetmetal','smallsheetmetal','steelmaterial','ironmaterial','ingot','metalpiece'}) or ((existing=='Material' or existing=='MaterialWeapon') and (metal or tags.hasmetal)) then return result('MaterialsMetal','material-tag') end
    if any(tags,{'rope','twine','glue','tape','binding','wallpaperpaste'}) then return result('MaterialsBinding','material-tag') end
    if tags.paint or tags.paintbrush or existing=='Paint' then return result('MaterialsPaint','material-tag') end
    if existing=='Material' or existing=='MaterialWeapon' then return result('MaterialsOther','vanilla-category') end
    if kind=='food' then
        if read(item,'isSpice')==true then return result('FoodSeasoning','spice') end
        if any(tags,{'preservedfood','driedfood'}) then return result('FoodShelfStable','preserved-tag') end
        local fresh=read(item,'getDaysFresh')
        if type(fresh)=='number' and fresh==fresh and fresh>=0 and fresh<1000000000 then return result('FoodPerishable','script-shelf-life') end
        if fresh==1000000000 then return result('FoodShelfStable','script-shelf-life') end
        return result('FoodOther','food-type')
    end
    if existing=='AnimalPart' or tags.animalbone then return result('MaterialsAnimal','animal-material') end
    if existing=='Memento' or tags.ismemento or read(item,'isMementoLoot')==true then return result('HouseholdKeepsakes','memento') end
    if display[existing] then return result(display[existing],'vanilla-category') end
    if kind=='weapon' then return melee() end
    if read(item,'isSurvivalGearLoot')==true then return result('OutdoorOther','survival-metadata') end
    if any(tags,{'bowl','mug','cup','plate','cookingpot','pan','fork','spoon'}) then return result('HouseholdKitchen','kitchen-tag') end
    return result('Misc','fallback')
end
-- Rank evidence from the same canonical detector. Scores express evidence
-- priority, while confidence describes the strength of the winning evidence.
-- The explicit semantic-rule order preserves existing vanilla membership.
local function ranked(item,tags,kind,existing,preferTools,detailed)
    local current,reason=classify(item,tags,kind,existing,preferTools)
    local candidates={}
    local function add(category,why,weight)
        local physical=F.destination(category)
        if not R.isLeaf(physical) then return end
        candidates[#candidates+1]={category=category,physical=physical,reason=why,weight=weight}
    end
    local strong=reason=='type' and (kind=='weaponpart' or kind=='key' or kind=='keyring')
        or reason=='key-semantics' or reason=='paintbrush-purpose'
    add(current,reason,strong and 1000 or reason=='fallback' and 0 or reason=='vanilla-category' and 550 or 950)
    -- The canonical result already has a strictly higher score than any
    -- secondary signal. Only diagnostics need to enumerate those signals.
    if detailed==false and current~='B47_Misc' then
        local top=candidates[1]
        return top.category,top.reason,top.weight,top.weight>=700 and 'high' or 'medium',candidates
    end
    for index,rule in ipairs(H.matches(item,tags,kind,existing,read(item,'getFullName'))) do
        if not (kind=='weapon' and not preferTools and (rule.category:match('^B47_Tools') or rule.category=='B47_HouseholdKitchen')) then
            add(rule.category,rule.reason,900-index)
        end
    end
    local structural,structuralReason=classify(item,tags,kind,existing,preferTools,true)
    add(structural,structuralReason,structuralReason=='fallback' and 0 or structuralReason=='vanilla-category' and 300 or 500)
    -- A mod's own DisplayCategory is item-definition evidence. This specific
    -- label was found in the installed corpus; vanilla B42.21 uses FirstAid.
    if existing=='Medical' and current=='B47_Misc' then
        add('B47_MedicalOther','medical-display-category',550)
    end
    table.sort(candidates,function(a,b)
        if a.weight~=b.weight then return a.weight>b.weight end
        -- Explicit taxonomy-ID order, never hash iteration or Workshop order.
        return a.category<b.category
    end)
    local winner=candidates[1]
    local confidence=winner.weight>=700 and 'high' or winner.weight>=500 and 'medium' or 'low'
    return winner.category,winner.reason,winner.weight,confidence,candidates
end
function R.rank(value,detailed)
    local item=read(value,'getScriptItem') or value
    if not item then return 'B47_Misc','fallback',0,'low',{} end
    local fullType=read(item,'getFullName') or read(value,'getFullType')
    local override=fullType and R.overrides[fullType]
    if override and R.labels[override] then
        local id=F.destination(F.defaults['B47_'..override] or 'B47_'..override)
        return id,'override',1000,'high',{{category=id,physical=id,reason='override',weight=1000}}
    end
    return ranked(item,tagSet(item),atom(read(item,'getItemType')),read(item,'getDisplayCategory'),true,detailed)
end
function R.weaponPurpose(value)
 local item=read(value,'getScriptItem') or value
 if atom(read(item,'getItemType'))~='weapon' or read(item,'isRanged')==true or tagSet(item).fakeweapon then return nil end
 local weapons=listSet(read(item,'getWeaponCategories'))
 if explosive(item,tagSet(item)) then return 'B47_Explosives' end
 if weapons.spear then return 'B47_MeleeSpears' end
 if weapons.axe or weapons.longblade then return 'B47_MeleeLongBlade' end
 if weapons.smallblade then return 'B47_MeleeShortBlade' end
 if weapons.blunt then return 'B47_MeleeLongBlunt' end
 if weapons.smallblunt then return 'B47_MeleeBlunt' end
 return 'B47_WeaponsOther'
end
local function priorWeapon(item,semantic)
 local weapons=listSet(read(item,'getWeaponCategories'))
 if semantic=='B47_MeleeLongBlade' or semantic=='B47_MeleeShortBlade' then return weapons.axe and 'B47_MeleeAxes' or 'B47_MeleeBlades' end
 if semantic=='B47_WeaponAttachments' then return 'B47_WeaponParts' end
 if semantic=='B47_Explosives' then return 'B47_MeleeOther' end
 if read(item,'isRanged')==true and atom(read(item,'getSwingAnim'))=='rifle' and atom(read(item,'getAmmoType'))~='shotgunshells' then return 'B47_LongGuns' end
 return nil
end
function R.resolve(value)
    local item=read(value,'getScriptItem') or value
    if item==nil then return 'B47_Misc','fallback','B47_Misc','B47_Misc','B47_Misc' end
    local fullType=read(item,'getFullName') or read(value,'getFullType')
    local preferTools=true
    local saved=cache[item]
    if saved and saved.tools==preferTools then return saved.category,saved.reason,saved.legacy,saved.semantic,saved.historical,saved.secondary end
    local override=fullType and R.overrides[fullType]
    if override and R.labels[override] then
        local id='B47_'..override;local category=F.defaults[id] or id;local legacy=R.legacyResolve(value)
        local semantic=category;local historical=R.priorPurposes[fullType] or (read(item,'getDisplayCategory')=='ProtectiveGear' and 'B47_ClothingProtective') or priorWeapon(item,semantic) or semantic;category=F.destination(semantic)
        cache[item]={category=category,reason='override',legacy=legacy,semantic=semantic,historical=historical,tools=preferTools,secondary=R.weaponPurpose(item)}
        return category,'override',legacy,semantic,historical,R.weaponPurpose(item)
    end
    local category,reason=R.rank(item,false)
    local legacy=R.legacyResolve(value)
    local semantic=category;local historical=R.priorPurposes[fullType] or (read(item,'getDisplayCategory')=='ProtectiveGear' and 'B47_ClothingProtective') or priorWeapon(item,semantic) or semantic;category=F.destination(semantic)
    cache[item]={category=category,reason=reason,legacy=legacy,semantic=semantic,historical=historical,tools=preferTools,secondary=R.weaponPurpose(item)}
    return category,reason,legacy,semantic,historical,R.weaponPurpose(item)
end
function R.semantic(value) local _,_,_,purpose=R.resolve(value);return purpose end
function R.invalidate() cache=setmetatable({},{__mode='k'}) end
-- Diagnostic only: expose every purpose match and the existing structural fallback
-- so review can see competing rules instead of merely the winning first match.
function R.inspect(value)
    local item=read(value,'getScriptItem') or value
    local category,reason,legacy=R.resolve(value)
    local tags=tagSet(item);local kind=atom(read(item,'getItemType'));local existing=read(item,'getDisplayCategory')
    local matches=H.matches(item,tags,kind,existing,read(item,'getFullName'))
    local function add(cat,why,on) if on then matches[#matches+1]={category='B47_'..cat,reason=why} end end
    for _,rule in ipairs(tools) do add(rule[1],'candidate:tool-tags',any(tags,rule[2]) and (kind~='weapon' or Migration.option('ClassifyToolsByUse')~=false)) end
    add(display[existing] or 'Misc','candidate:display-fallback',display[existing]~=nil)
    add('HouseholdKeepsakes','candidate:memento',existing=='Memento' or tags.ismemento or read(item,'isMementoLoot')==true)
    add('MaterialsAnimal','candidate:animal-material',existing=='AnimalPart' or tags.animalbone)
    local media=read(item,'getRecordedMediaCat')
    add('Media','candidate:recorded-media',(type(media)=='string' and media~='') or existing=='Entertainment')
    if kind=='food' then
        local fresh=read(item,'getDaysFresh');local food='FoodOther'
        if read(item,'isSpice')==true then food='FoodSeasoning'
        elseif any(tags,{'preservedfood','driedfood'}) or fresh==1000000000 then food='FoodShelfStable'
        elseif type(fresh)=='number' and fresh>=0 and fresh<1000000000 then food='FoodPerishable' end
        add(food,'candidate:food-metadata',true)
    end
    if kind=='weapon' and read(item,'isRanged')~=true then
        local weapons=listSet(read(item,'getWeaponCategories'));local melee='MeleeOther'
        for _,rule in ipairs({{'axe','MeleeAxes'},{'spear','MeleeSpears'},{'smallblade','MeleeBlades'},{'longblade','MeleeBlades'},{'smallblunt','MeleeBlunt'},{'blunt','MeleeLongBlunt'}}) do if weapons[rule[1]] then melee=rule[2];break end end
        add(melee,'candidate:weapon-metadata',true)
    end
    local lower,why=classify(item,tags,kind,existing,Migration.option('ClassifyToolsByUse')~=false,true)
    matches[#matches+1]={category=lower,reason=why}
    if reason=='override' then table.insert(matches,1,{category=category,reason=reason}) end
    return category,reason,legacy,matches
end
-- User catalog filtering only. Classification/routing never reject runtime items
-- here. Actual observed instances and existing explicit rules remain supported.
function R.catalogEligible(item)
    if read(item,'isHidden')==true or read(item,'getObsolete')==true then return false,'native-hidden-obsolete' end
    local full=read(item,'getFullName');local display=read(item,'getDisplayCategory')
    if display=='Hidden' then return false,'native-hidden-category' end
    if type(full)=='string' and full:match('^Base%.') and atom(read(item,'getItemType'))=='clothing' and (display=='Wound' or display=='ZedDmg') then return false,'native-body-damage-representation' end
    if full=='Base.Animal_Item_Dummy' or full=='Base.FISH_DEV_ITEM' or full=='Base.TestDebugWater' or full=='Base.DebugFluid' then return false,'verified-development-definition' end
    return true
end
function R.migrate(categories,fromVersion)
    if fromVersion~=0 and fromVersion~=1 and fromVersion~=2 and fromVersion~=3 and fromVersion~=4 and fromVersion~=5 and fromVersion~=R.version then return nil,'taxonomy' end
    local out={};for key,on in pairs(categories) do out[key]=on end;return out
end
return R
