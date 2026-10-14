local R=require 'B47ANCEDQuartermaster/Categorizer'
local function resolve(display,kind,tags)
 local item={getFullName=function() return 'IndependentFixture.Example' end,
  getDisplayCategory=function() return display end,getItemType=function() return kind or 'base:normal' end,
  getTags=function() return tags or {} end}
 return R.resolve(item)
end
assert(resolve('Toy')=='B47_HouseholdKeepsakes')
assert(resolve('Mineral')=='B47_MaterialsGeneral')
assert(resolve('base:AMMO_PARTS')=='B47_MaterialsGeneral')
assert(resolve('AmmoParts','base:normal',{'base:hasmetal'})=='B47_MaterialsMetal')
assert(resolve('Tuning')=='B47_VehicleParts')
assert(resolve('SkillJournal','base:drainable')=='B47_LiteratureNotes')
assert(resolve('Toy','base:container')=='B47_ContainersOther')
assert(resolve('Tuning','base:normal',{'base:spoon'})=='B47_HouseholdKitchen')
assert(resolve('Tuning','base:normal',{'base:hammer'})=='B47_ToolsCarpentry')
assert(resolve('AmmoParts','base:normal',{'base:bandage'})=='B47_MedicalSupplies')
assert(resolve('Toy','base:food')~='B47_HouseholdKeepsakes')
assert(resolve('AmmoParts','base:weaponpart')=='B47_WeaponAttachments')
for _,label in ipairs({'Raccoon','VFXDistribution','Item','Trash','Art','Money','BadlandsChess'}) do
 assert(resolve(label)=='B47_Misc','opaque display category was guessed: '..label)
end
local hint={getFullName=function() return 'IndependentFixture.Hint' end,
 getDisplayCategory=function() return 'Toy' end,getItemType=function() return 'normal' end}
local _,_,weight,confidence=R.rank(hint)
assert(weight==550 and confidence=='medium','display hint overstated as strong evidence')
print('PASS OFFLINE dev49 mod metadata fallback, normalized labels, stronger evidence and ambiguous-label rejection')
