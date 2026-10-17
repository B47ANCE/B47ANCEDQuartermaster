-- Native item ownership/conversion. Called only by the authenticated server service.
local M={sheet='B47ANCEDQuartermaster.SupplySheet',disc='B47ANCEDQuartermaster.SupplyDisc'}
function M.owned(actor,id,kind)
 if type(id)~='number' or id~=id or id~=math.floor(id) or id< -2147483648 or id>2147483647 then return end
 local item=actor:getInventory():getItemWithIDRecursiv(id)
 if item and (not kind or item:getFullType()==kind) then return item end
end
function M.reachable(actor,obj)
 local sq=obj and obj:getSquare();local here=actor:getCurrentSquare()
 if not sq or not here or here:getZ()~=sq:getZ() then return false end
 if math.max(math.abs(here:getX()-sq:getX()),math.abs(here:getY()-sq:getY()))>1 then return false end
 return here==sq or here:canReachTo(sq)
end
function M.object(d)
 if type(d)~='table' then return end
 for _,k in ipairs({'x','y','z','index'}) do local n=d[k];if type(n)~='number' or n~=math.floor(n) or math.abs(n)>10000000 then return end end
 local sq=getCell():getGridSquare(d.x,d.y,d.z)
 if sq and d.index>=0 and d.index<sq:getObjects():size() then return sq:getObjects():get(d.index) end
end
function M.computer(actor,obj,near)
 local sq=obj and obj:getSquare();local sprite=obj and obj:getSprite()
 if not sq or not sprite or sprite.name~='appliances_com_01_72' or getCell():getGridSquare(sq:getX(),sq:getY(),sq:getZ())~=sq then return false end
 local index=obj:getObjectIndex();if index<0 or sq:getObjects():get(index)~=obj then return false end
 if near and not M.reachable(actor,obj) then return false end
 if (isServer() or isClient()) and (not SafeHouse or not SafeHouse.isSafehouseAllowLoot(sq,actor) or not SafeHouse.isSafehouseAllowInteract(sq,actor)) then return false end
 if not B47ANCEDQuartermaster.RoomAccess.can(actor,{obj=obj},'inspect') then return false end
 return sq:haveElectricity() or sq:hasGridPower() and sq:getRoom()~=nil
end
function M.cd(item) return item and item:getFullType()=='Base.Disc_Retail' end
function M.usable(item)
 return item and not item:isFavorite() and not item:isEquipped() and item:getAttachedSlot()==-1 and not item:getIsCraftingConsumed()
end
function M.stamp(actor,item,id,complete)
 item:getModData().B47Ledger={schema=1,snapshot=id,complete=complete}
 syncItemModData(actor,item)
end
-- The service holds a per-input lock before this non-yielding native mutation.
-- Any uncertain result stays journalled and cannot be retried as another burn.
function M.convert(actor,input,snapshot,journal,register)
 local inv=actor:getInventory();local source=input:getContainer()
 if not source or not M.cd(input) or not M.usable(input) or not source:isRemoveItemAllowed(input) then return nil,'invalid' end
 local output=instanceItem(M.disc);if not output then return nil,'failed' end
 output:getModData().B47Ledger={schema=1,snapshot=snapshot}
 if not inv:isItemAllowed(output) or not inv:hasRoomFor(actor,output) then return nil,'capacity' end
 journal.output=output:getID();journal.phase='prepared'
 if register then register(output:getID()) end
 local function inputExists()
  local c=input:getContainer()
  if c and c:getItemWithID(input:getID())==input then return true end
  local w=input:getWorldItem();local sq=w and w:getSquare()
  return sq and sq:getWorldObjects():contains(w) and w:getItem()==input or false
 end
 local ok=pcall(function()
  inv:AddItem(output)
  if output:getContainer()~=inv then error('output not inserted') end
  journal.phase='outputAdded'
  if source:getItemWithID(input:getID())~=input then error('input moved') end
  source:Remove(input)
  if inputExists() then error('input not removed') end
  journal.phase='committed'
 end)
 if not ok then
  -- Roll back only a definitely retained input and exact owned output.
  if inputExists() and inv:getItemWithID(output:getID())==output then
   local rolled=pcall(function() inv:Remove(output) end)
   if rolled and inv:getItemWithID(output:getID())~=output then journal.phase='rolledBack';return nil,'failed' end
  end
  journal.phase='uncertain';return nil,'uncertain'
 end
 -- A failed notification never replays the already committed conversion.
 local removed=pcall(sendRemoveItemFromContainer,source,input);local added=pcall(sendAddItemToContainer,inv,output)
 if not removed or not added then
  print('[B47ANCEDQuartermaster] ledger conversion committed; native inventory notification failed')
  return output,'LedgerSyncPending'
 end
 return output,'ok'
end
function M.recover(actor,journal)
 local input=M.owned(actor,journal.input);local output=journal.output and M.owned(actor,journal.output,M.disc)
 if output and not input and journal.phase=='committed' then return output end
 if input and not output and journal.output==nil then journal.phase='rolledBack';return end
 if input and output and M.cd(input) then
  -- A restart/exception retained both native items. Restore the unconverted input.
  local c=output:getContainer();local ok=pcall(function() c:Remove(output) end)
  if ok and c:getItemWithID(output:getID())~=output then pcall(sendRemoveItemFromContainer,c,output);journal.phase='rolledBack';return end
 end
 journal.phase='uncertain'
end
return M
