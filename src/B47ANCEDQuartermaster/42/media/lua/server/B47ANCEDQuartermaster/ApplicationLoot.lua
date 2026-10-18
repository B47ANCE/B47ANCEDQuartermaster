-- Only new native loot rolls; never retrofit items into existing inventories.
require 'Items/ProceduralDistributions'
local Options=require 'B47ANCEDQuartermaster/Migration'
local Policy=require 'B47ANCEDQuartermaster/LedgerPolicy'
local item='B47ANCEDQuartermaster.ApplicationCD'
-- Commercial offices (including warehouse offices using native office rooms),
-- office supply storage and computer stock. No home desks or general cargo.
local locations={
 OfficeDesk=true,OfficeDeskSecretary=true,OfficeDeskStressed=true,
 OfficeCounter=true,OfficeShelfSupplies=true,CrateOfficeSupplies=true,
 ElectronicStoreComputers=true,CrateComputer=true,
 -- Remove our previous generic-electronics entries on repeated loads only.
 ElectronicStoreMisc=false,CrateElectronics=false,
}
local function populate()
 local weight=Options.option('ApplicationCDLootWeight')
 if type(weight)~='number' or weight~=weight or weight<0 or weight>10 then weight=1 end
 if not Policy.enabled() then weight=0 end
 for name,enabled in pairs(locations) do
  local pool=ProceduralDistributions.list[name];local items=pool and pool.items
  if type(items)=='table' and #items%2==0 then
   -- Repeated event/load remains idempotent, and changed settings replace our
   -- existing entry rather than adding another chance.
   for n=#items-1,1,-2 do if items[n]==item then table.remove(items,n+1);table.remove(items,n) end end
   if enabled and weight>0 then items[#items+1]=item;items[#items+1]=weight end
  end
 end
end
Events.OnPreDistributionMerge.Add(populate)
return populate
