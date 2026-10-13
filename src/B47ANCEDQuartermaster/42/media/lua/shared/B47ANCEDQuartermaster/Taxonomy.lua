-- Original storage families; broad IDs are compatibility rules, not a new UI level.
local F={children={},parents={},defaults={}}
-- Added physical storage purposes; families are compatibility rules, not UI levels.
F.parents.B47_Instruments={'B47_Household'}
F.parents.B47_Smoking={'B47_Household'}
F.parents.B47_Recreation={'B47_Household'}
F.parents.B47_Stationery={'B47_Household'}
F.parents.B47_AnimalSupplies={'B47_Outdoor'}
F.children['B47_Ammo']={'B47_AmmoLoose','B47_AmmoBoxes','B47_AmmoMagazines'}
F.parents['B47_AmmoLoose']={'B47_Ammo'}
F.parents['B47_AmmoBoxes']={'B47_Ammo'}
F.parents.B47_AmmoPackages={'B47_Ammo'}
table.insert(F.children.B47_Ammo,'B47_AmmoPackages')
F.parents['B47_AmmoMagazines']={'B47_Ammo'}
F.defaults['B47_Ammo']='B47_AmmoLoose'
F.children['B47_Firearms']={'B47_Handguns','B47_LongGuns','B47_Shotguns','B47_FirearmsOther'}
F.parents['B47_Handguns']={'B47_Firearms'}
F.parents['B47_LongGuns']={'B47_Firearms'}
F.parents['B47_Shotguns']={'B47_Firearms'}
F.parents['B47_FirearmsOther']={'B47_Firearms'}
F.defaults['B47_Firearms']='B47_FirearmsOther'
F.children['B47_Melee']={'B47_MeleeBlades','B47_MeleeBlunt','B47_MeleeLongBlunt','B47_MeleeAxes','B47_MeleeSpears','B47_MeleeOther'}
F.parents['B47_MeleeBlades']={'B47_Melee'}
F.parents['B47_MeleeBlunt']={'B47_Melee'}
F.parents['B47_MeleeLongBlunt']={'B47_Melee'}
F.parents['B47_MeleeAxes']={'B47_Melee'}
F.parents['B47_MeleeSpears']={'B47_Melee'}
F.parents['B47_MeleeOther']={'B47_Melee'}
F.defaults['B47_Melee']='B47_MeleeOther'
F.children['B47_Tools']={'B47_ToolsGeneral','B47_ToolsCarpentry','B47_ToolsMetal','B47_ToolsMechanics','B47_ToolsSewing','B47_ToolsCutting','B47_ToolsFarming'}
F.parents['B47_ToolsGeneral']={'B47_Tools'}
F.parents['B47_ToolsCarpentry']={'B47_Tools'}
F.parents['B47_ToolsMetal']={'B47_Tools'}
F.parents['B47_ToolsMechanics']={'B47_Tools'}
F.parents['B47_ToolsSewing']={'B47_Tools'}
F.parents['B47_ToolsCutting']={'B47_Tools'}
F.parents['B47_ToolsFarming']={'B47_Tools'}
F.defaults['B47_Tools']='B47_ToolsGeneral'
F.children['B47_Medical']={'B47_MedicalBandages','B47_MedicalMedicine','B47_MedicalTools','B47_MedicalOther'}
F.parents['B47_MedicalBandages']={'B47_Medical'}
F.parents['B47_MedicalMedicine']={'B47_Medical'}
F.parents['B47_MedicalTools']={'B47_Medical'}
F.parents['B47_MedicalOther']={'B47_Medical'}
F.defaults['B47_Medical']='B47_MedicalOther'
F.children['B47_Food']={'B47_FoodPerishable','B47_FoodShelfStable','B47_FoodSeasoning','B47_FoodOther'}
F.parents['B47_FoodPerishable']={'B47_Food'}
F.parents['B47_FoodShelfStable']={'B47_Food'}
F.parents['B47_FoodSeasoning']={'B47_Food'}
F.parents['B47_FoodOther']={'B47_Food'}
F.defaults['B47_Food']='B47_FoodOther'
F.children['B47_Beverages']={'B47_BeveragesWater','B47_BeveragesAlcohol','B47_BeveragesOther'}
F.parents['B47_BeveragesWater']={'B47_Beverages'}
F.parents['B47_BeveragesAlcohol']={'B47_Beverages'}
F.parents['B47_BeveragesOther']={'B47_Beverages'}
F.defaults['B47_Beverages']='B47_BeveragesOther'
F.children['B47_Clothing']={'B47_ClothingHead','B47_ClothingEyes','B47_ClothingFace','B47_ClothingTops','B47_ClothingOuterwear','B47_ClothingBottoms','B47_ClothingUnderwear','B47_ClothingSocks','B47_ClothingFootwear','B47_ClothingGloves','B47_ClothingAccessories','B47_ClothingProtective','B47_ClothingOther'}
F.parents['B47_ClothingHead']={'B47_Clothing'}
F.parents['B47_ClothingEyes']={'B47_Clothing'}
F.parents['B47_ClothingFace']={'B47_Clothing'}
F.parents['B47_ClothingTops']={'B47_Clothing'}
F.parents['B47_ClothingOuterwear']={'B47_Clothing'}
F.parents['B47_ClothingBottoms']={'B47_Clothing'}
F.parents['B47_ClothingUnderwear']={'B47_Clothing'}
F.parents['B47_ClothingSocks']={'B47_Clothing'}
F.parents['B47_ClothingFootwear']={'B47_Clothing'}
F.parents['B47_ClothingGloves']={'B47_Clothing'}
F.parents['B47_ClothingAccessories']={'B47_Clothing'}
F.parents.B47_ClothingJewelry={'B47_Clothing'}
F.parents.B47_ClothingEquipment={'B47_Clothing'}
table.insert(F.children.B47_Clothing,'B47_ClothingEquipment')
F.parents.B47_ClothingCostumes={'B47_Clothing'}
table.insert(F.children.B47_Clothing,'B47_ClothingCostumes')
table.insert(F.children.B47_Clothing,'B47_ClothingJewelry')
F.parents['B47_ClothingProtective']={'B47_Clothing'}
F.parents['B47_ClothingOther']={'B47_Clothing'}
F.defaults['B47_Clothing']='B47_ClothingOther'
F.children['B47_Literature']={'B47_LiteratureSkill','B47_LiteratureManuals','B47_LiteratureMaps','B47_LiteratureMagazines','B47_LiteratureNotes','B47_LiteratureOther'}
F.parents['B47_LiteratureSkill']={'B47_Literature'}
F.parents['B47_LiteratureManuals']={'B47_Literature'}
F.parents['B47_LiteratureMaps']={'B47_Literature'}
F.parents['B47_LiteratureMagazines']={'B47_Literature'}
F.parents['B47_LiteratureNotes']={'B47_Literature'}
F.parents['B47_LiteratureOther']={'B47_Literature'}
F.defaults['B47_Literature']='B47_LiteratureOther'
F.children['B47_Materials']={'B47_MaterialsWood','B47_MaterialsMetal','B47_MaterialsTextile','B47_MaterialsFasteners','B47_MaterialsBinding','B47_MaterialsPaint','B47_ElectricalComponents','B47_MaterialsOther','B47_MaterialsAnimal'}
F.parents['B47_MaterialsWood']={'B47_Materials'}
F.parents['B47_MaterialsMetal']={'B47_Materials'}
F.parents['B47_MaterialsTextile']={'B47_Materials'}
F.parents['B47_MaterialsFasteners']={'B47_Materials'}
F.parents['B47_MaterialsBinding']={'B47_Materials'}
F.parents['B47_MaterialsPaint']={'B47_Materials'}
F.parents['B47_ElectricalComponents']={'B47_Materials'}
F.parents['B47_MaterialsOther']={'B47_Materials'}
F.defaults['B47_Materials']='B47_MaterialsOther'
F.children['B47_Vehicle']={'B47_VehicleTires','B47_VehicleBatteries','B47_VehicleOther'}
F.parents['B47_VehicleTires']={'B47_Vehicle'}
F.parents['B47_VehicleBatteries']={'B47_Vehicle'}
F.parents['B47_VehicleOther']={'B47_Vehicle'}
F.defaults['B47_Vehicle']='B47_VehicleOther'
F.children['B47_Outdoor']={'B47_OutdoorFishing','B47_OutdoorTrapping','B47_OutdoorFarming','B47_OutdoorCamping','B47_OutdoorFire','B47_OutdoorLighting','B47_OutdoorOther'}
F.parents['B47_OutdoorFishing']={'B47_Outdoor'}
F.parents['B47_OutdoorTrapping']={'B47_Outdoor'}
F.parents['B47_OutdoorFarming']={'B47_Outdoor'}
F.parents['B47_OutdoorCamping']={'B47_Outdoor'}
F.parents['B47_OutdoorFire']={'B47_Outdoor'}
F.parents['B47_OutdoorLighting']={'B47_Outdoor'}
F.parents['B47_OutdoorOther']={'B47_Outdoor'}
F.defaults['B47_Outdoor']='B47_OutdoorOther'
F.children['B47_Containers']={'B47_ContainersBags','B47_ContainersFluid','B47_ContainersOther'}
F.parents['B47_ContainersBags']={'B47_Clothing','B47_Containers'}
table.insert(F.children.B47_Clothing,'B47_ContainersBags')
F.parents['B47_ContainersFluid']={'B47_Containers'}
F.parents['B47_ContainersOther']={'B47_Containers'}
F.defaults['B47_Containers']='B47_ContainersOther'
F.children['B47_Electrical']={'B47_ElectricalRadios','B47_ElectricalPower','B47_ElectricalOther'}
F.parents['B47_ElectricalRadios']={'B47_Electrical'}
F.parents['B47_ElectricalPower']={'B47_Electrical'}
F.parents['B47_ElectricalOther']={'B47_Electrical'}
F.defaults['B47_Electrical']='B47_ElectricalOther'
F.children['B47_Household']={'B47_HouseholdKeys','B47_HouseholdKitchen','B47_HouseholdCleaning','B47_HouseholdCare','B47_HouseholdFurnishings','B47_HouseholdOther','B47_HouseholdKeepsakes'}
F.parents['B47_HouseholdKeys']={'B47_Household'}
F.parents['B47_HouseholdKitchen']={'B47_Household'}
F.parents['B47_HouseholdCleaning']={'B47_Household'}
F.parents['B47_HouseholdCare']={'B47_Household'}
F.parents['B47_HouseholdFurnishings']={'B47_Household'}
F.parents['B47_HouseholdOther']={'B47_Household'}
F.defaults['B47_Household']='B47_HouseholdOther'
-- Components have a materials identity and preserve broad electrical-rule coverage.
F.parents.B47_MaterialsAnimal={'B47_Materials'}
F.parents.B47_HouseholdKeepsakes={'B47_Household'}
F.parents.B47_ElectricalComponents={'B47_Materials','B47_Electrical'}
table.insert(F.children.B47_Electrical,'B47_ElectricalComponents')
for _,id in ipairs({'B47_Instruments','B47_Smoking','B47_Recreation','B47_Stationery'}) do table.insert(F.children.B47_Household,id) end
table.insert(F.children.B47_Outdoor,'B47_AnimalSupplies')
-- Misc remains a physical fallback and also preserves formerly unclassified membership.
F.children.B47_Misc={}
-- Merged semantic IDs retain narrow saved-rule membership. Reviewed dev.12
-- semantic corrections retain their prior scope through R.priorPurposes.
F.destinations={
 B47_AnimalSupplies='B47_OutdoorFarmingSupplies',B47_OutdoorFarming='B47_OutdoorFarmingSupplies',
 B47_ElectricalComponents='B47_ElectricalSupplies',B47_ElectricalPower='B47_ElectricalSupplies',
 B47_VehicleBatteries='B47_VehicleParts',B47_VehicleOther='B47_VehicleParts',
 B47_ClothingHead='B47_ClothingHeadwear',B47_ClothingFace='B47_ClothingHeadwear',
 B47_ClothingProtective='B47_ClothingOuterwearArmor',
 B47_ClothingUnderwear='B47_ClothingUnderlayers',B47_ClothingSocks='B47_ClothingUnderlayers',
 B47_MedicalBandages='B47_MedicalSupplies',
 B47_MedicalTools='B47_MedicalSupplies',
 B47_MedicalOther='B47_MedicalSupplies',
 B47_OutdoorFire='B47_CampingSupplies',
 B47_OutdoorCamping='B47_CampingSupplies',
 B47_HouseholdOther='B47_HouseholdUtilities',
 B47_MaterialsOther='B47_MaterialsGeneral',
 B47_ToolsGeneral='B47_ToolsGeneralPurpose',
 B47_FoodOther='B47_FoodGeneral',
 B47_MeleeOther='B47_WeaponsOther',
 B47_FoodShelfStable='B47_FoodPantry'
}
F.parents.B47_OutdoorFarmingSupplies={'B47_Outdoor'}
F.parents.B47_ElectricalSupplies={'B47_Electrical'}
F.parents.B47_VehicleParts={'B47_Vehicle'}
F.parents.B47_ClothingHeadwear={'B47_Clothing'}
F.parents.B47_ClothingUnderlayers={'B47_Clothing'}
F.parents.B47_BeveragesNonAlcoholic={'B47_Beverages'}
-- Retain the former merged ID as a saved-rule family, not a displayed item leaf.
F.children.B47_BeveragesNonAlcoholic={'B47_BeveragesWater','B47_BeveragesOther','B47_BeveragesSoda','B47_BeveragesMilk','B47_BeveragesEmptyWater'}
for _,id in ipairs({'B47_BeveragesWater','B47_BeveragesOther'}) do table.insert(F.parents[id],'B47_BeveragesNonAlcoholic') end
for _,id in ipairs({'B47_BeveragesSoda','B47_BeveragesMilk','B47_BeveragesEmptyWater'}) do
 F.parents[id]={'B47_Beverages','B47_BeveragesNonAlcoholic'}
 table.insert(F.children.B47_Beverages,id)
end
-- Existing family coverage is computed from the semantic ID, not the union
-- destination (e.g. Materials must not gain portable batteries).
for _,pair in ipairs({{'B47_Outdoor','B47_OutdoorFarmingSupplies'},
 {'B47_Electrical','B47_ElectricalSupplies'},{'B47_Vehicle','B47_VehicleParts'},
 {'B47_Clothing','B47_ClothingHeadwear'},{'B47_Clothing','B47_ClothingUnderlayers'},
 {'B47_Beverages','B47_BeveragesNonAlcoholic'}}) do table.insert(F.children[pair[1]],pair[2]) end
F.parents.B47_MedicalSupplies={'B47_Medical'};table.insert(F.children.B47_Medical,'B47_MedicalSupplies')
F.parents.B47_CampingSupplies={'B47_Outdoor'};table.insert(F.children.B47_Outdoor,'B47_CampingSupplies')
F.parents.B47_HouseholdUtilities={'B47_Household'};table.insert(F.children.B47_Household,'B47_HouseholdUtilities')
F.parents.B47_MaterialsGeneral={'B47_Materials'};table.insert(F.children.B47_Materials,'B47_MaterialsGeneral')
F.parents.B47_ToolsGeneralPurpose={'B47_Tools'};table.insert(F.children.B47_Tools,'B47_ToolsGeneralPurpose')
F.parents.B47_FoodGeneral={'B47_Food'};table.insert(F.children.B47_Food,'B47_FoodGeneral')
F.parents.B47_WeaponsOther={'B47_Melee'};table.insert(F.children.B47_Melee,'B47_WeaponsOther')
F.parents.B47_FoodPantry={'B47_Food'};table.insert(F.children.B47_Food,'B47_FoodPantry')
-- Separate physical armor leaves by clothing slot; regular clothing stays separate.
F.armorDestinations={}
for _,base in ipairs({'ClothingEquipment','ClothingGloves','ClothingHeadwear','ClothingTops','ClothingBottoms','ClothingUnderlayers','ClothingFootwear','ClothingEyes','ClothingOuterwear','ClothingOther'}) do
 local id='B47_'..base..'Armor'
 F.armorDestinations['B47_'..base]=id
 F.parents[id]={'B47_Clothing'};table.insert(F.children.B47_Clothing,id)
end
-- Weapons display hierarchy. Compatibility parents remain separate from the
-- single display parent so historical saved rules do not create duplicate rows.
F.displayParents={};F.displayHidden={B47_Melee=true,B47_LongGuns=true,B47_MeleeAxes=true}
local function branch(id,parent,children)
 F.parents[id]=F.parents[id] or {};if parent then table.insert(F.parents[id],1,parent);F.displayParents[id]=parent end
 if children then F.children[id]=children end
end
branch('B47_Weapons',nil,{'B47_Explosives','B47_Sharp','B47_Blunt','B47_Firearms','B47_WeaponsOther'})
branch('B47_Explosives','B47_Weapons')
branch('B47_Sharp','B47_Weapons',{'B47_MeleeSpears','B47_MeleeBlades'})
branch('B47_MeleeSpears','B47_Sharp')
branch('B47_MeleeBlades','B47_Sharp',{'B47_MeleeLongBlade','B47_MeleeShortBlade'})
branch('B47_MeleeLongBlade','B47_MeleeBlades')
branch('B47_MeleeShortBlade','B47_MeleeBlades')
table.insert(F.parents.B47_MeleeLongBlade,'B47_Melee');table.insert(F.parents.B47_MeleeShortBlade,'B47_Melee')
branch('B47_Blunt','B47_Weapons',{'B47_MeleeLongBlunt','B47_MeleeBlunt'})
branch('B47_MeleeLongBlunt','B47_Blunt');branch('B47_MeleeBlunt','B47_Blunt')
branch('B47_Firearms','B47_Weapons',{'B47_Handguns','B47_Shotguns','B47_SubMachineGuns','B47_AssaultRifles','B47_SniperRifles','B47_FirearmsOther','B47_WeaponParts'})
for _,id in ipairs({'B47_Handguns','B47_Shotguns','B47_SubMachineGuns','B47_AssaultRifles','B47_SniperRifles','B47_FirearmsOther'}) do F.displayParents[id]='B47_Firearms' end
branch('B47_WeaponParts','B47_Firearms',{'B47_WeaponAttachments','B47_WeaponComponents'})
branch('B47_WeaponAttachments','B47_WeaponParts');branch('B47_WeaponComponents','B47_WeaponParts')
F.displayParents.B47_WeaponsOther='B47_Weapons'
F.children.B47_LongGuns={'B47_SubMachineGuns','B47_AssaultRifles','B47_SniperRifles','B47_FirearmsOther'}
F.destinations.B47_MeleeAxes='B47_MeleeLongBlade'
-- Materialize ancestor memberships once, without changing the display graph.
for id in pairs(F.displayParents) do
 local seen={};for _,p in ipairs(F.parents[id] or {}) do seen[p]=true end
 local p=F.displayParents[id]
 while p do if not seen[p] then F.parents[id]=F.parents[id] or {};table.insert(F.parents[id],p);seen[p]=true end;p=F.displayParents[p] end
end
function F.destination(id) return F.destinations[id] or id end
return F
