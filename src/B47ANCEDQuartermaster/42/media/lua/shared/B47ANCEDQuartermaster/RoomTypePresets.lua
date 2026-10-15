-- Editable profile templates, not an item classifier. Only category IDs present
-- in the actual authoritative catalog are ever materialized.
local A=require 'B47ANCEDQuartermaster/AllocationProfile'
local R=require 'B47ANCEDQuartermaster/Categorizer'
local P={};B47ANCEDQuartermaster.RoomTypePresets=P
local families={
 kitchen={'Food','Cooking','CookingWeapon','Water','WaterContainer'},pantry={'Food','Water','WaterContainer'},medical={'FirstAid','FirstAidWeapon','Bandage'},
 armory={'Weapon','WeaponCrafted','WeaponImprovised','BrokenWeapon','WeaponPart','Ammo','Explosives'},workshop={'Tool','ToolWeapon','Material','MaterialWeapon','RecipeResource','Paint'},garage={'VehicleMaintenance','VehicleMaintenanceWeapon','Tool','ToolWeapon'},
 library={'Literature','SkillBook','Cartography'},bedroom={'Clothing','Accessory','Bag','Container','ProtectiveGear'},
 bathroom={'FirstAid','Household','Junk'},laundry={'Clothing','Household'},storage=false,
 garden={'Gardening','GardeningWeapon','Tool','ToolWeapon'},electronics={'Electronics','Communications'},utility={'Tool','ToolWeapon','LightSource','Household','FireSource'}
}
function P.build(kind,entries)
 if families[kind]==nil then return nil,'AllocationPresetUnavailable' end
 local present={};for _,entry in ipairs(entries or {}) do if R.known(entry.category) then present[entry.category]=true end end
 local profile=A.empty(kind=='storage' and 100 or 0);local matched,missing={},{}
 for _,nativeName in ipairs(families[kind] or {}) do
  local id=R.nativeID(nativeName)
  if present[id] then profile.cats[id]=100;matched[#matched+1]=id else missing[#missing+1]=nativeName end
 end
 if kind~='storage' and #matched==0 then return nil,'AllocationPresetUnmapped',{missing=missing} end
 return profile,nil,{matched=matched,missing=missing,defaultsOnly=true,doesNotModifyContainers=true}
end
return P
