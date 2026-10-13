require 'B47ANCEDQuartermaster/Sorter'
require 'ISUI/InventoryWindow/ISInventoryWindowControlHandler'
require 'ISUI/InventoryWindow/ISInventoryWindowContainerControls'
require 'ISUI/LootWindow/ISLootWindowObjectControlHandler'
require 'ISUI/LootWindow/ISLootWindowFloorControlHandler'
require 'ISUI/LootWindow/ISLootWindowContainerControls'
local S=B47ANCEDQuartermaster.Sorter
local Compatibility=require 'B47ANCEDQuartermaster/Compatibility'
if not Compatibility.allowed() then return end
local function supported(player,container)
    if not Compatibility.allowed() then return false end
    if not container then return false end
    if (container:getType()=='floor' or (not container:getParent() and not container:getContainingItem() and container~=player:getInventory())) then return true end
    -- Floor/aggregate proxies may be transiently empty while their UI rebuilds.
    -- Keep intent controls stable; acquisition still validates actual item sources.
    if container:isEmpty() then return false end
    if container==player:getInventory() then return true end
    local item=container:getContainingItem()
    if item then return B47ANCEDQuartermaster.Movement.carrier(player,item:getID())==container end
    local obj=container:getParent()
    return obj and B47ANCEDQuartermaster.Targets.make(obj,obj:getContainerIndex(container),player)~=nil
end
local function perform(playerNum,container)
    local player=getSpecificPlayer(playerNum)
    if not player or isGamePaused() then return end
    if S.active[playerNum] then S.cancel(playerNum);return end
    local ok=S.start(playerNum,container,function(status,completed,failed)
        if status=='ok' and completed==0 then player:setHaloNote(getText('UI_B47_SortNothing'))
        elseif status=='ok' or status=='cancelled' then player:setHaloNote(getText(status=='ok' and 'UI_B47_SortFinished' or 'UI_B47_SortStopped',completed,failed))
        else player:setHaloNote(getText('UI_B47_SortFailed',getText('UI_QMSS_'..status),completed,failed)) end
    end)
    if not ok then player:setHaloNote(getText('UI_B47_SortBusy')) end
end
local function install(base,registry,name,floor)
    local handler=base:derive(name)
    function handler:new() return base.new(self) end
    function handler:playerIndex() return self.playerNum or (self.inventoryWindow and self.inventoryWindow.player) or (self.lootWindow and self.lootWindow.player) or 0 end
    function handler:shouldBeVisible()
        local player=getSpecificPlayer(self:playerIndex())
        return player and (S.active[self:playerIndex()]~=nil or supported(player,self.container))
    end
    function handler:getControl()
        return self:getButtonControl(getText(S.active[self:playerIndex()] and 'UI_B47_StopSorting' or 'UI_B47_Sort'))
    end
    function handler:perform() perform(self:playerIndex(),self.container) end
    function handler:handleJoypadContextMenu(context)
        self:addJoypadContextMenuOption(context,getText(S.active[self:playerIndex()] and 'UI_B47_StopSorting' or 'UI_B47_Sort'))
    end
    local register=floor and registry.AddFloorHandler or registry.AddHandler
    register(handler)
end
install(ISInventoryWindowControlHandler,ISInventoryWindowContainerControls,'B47InventorySortControl')
install(ISLootWindowObjectControlHandler,ISLootWindowContainerControls,'B47LootSortControl')
install(ISLootWindowFloorControlHandler,ISLootWindowContainerControls,'B47FloorSortControl',true)
