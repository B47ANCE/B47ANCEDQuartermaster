require 'B47ANCEDQuartermaster/Sorter'
require 'ISUI/InventoryWindow/ISInventoryWindowControlHandler'
require 'ISUI/InventoryWindow/ISInventoryWindowContainerControls'
require 'ISUI/LootWindow/ISLootWindowObjectControlHandler'
require 'ISUI/LootWindow/ISLootWindowFloorControlHandler'
require 'ISUI/LootWindow/ISLootWindowContainerControls'
require 'ISUI/ISContextMenu'
local Q=B47ANCEDQuartermaster
local S=Q.Sorter
local function ledgerWork(num) local work=Q.LedgerUI and Q.LedgerUI.work[num];return work and work.sort end
local function sorting(num) return S.active[num] or Q.RoomSort and Q.RoomSort.active[num] or ledgerWork(num) end
local pendingMenus={}
local Compatibility=require 'B47ANCEDQuartermaster/Compatibility'
local External=require 'B47ANCEDQuartermaster/ContainerSources'
if not Compatibility.allowed() then return end
local function supported(player,container)
    if not Compatibility.allowed() then return false end
    if not container then return false end
    if (container:getType()=='floor' or (not container:getParent() and not container:getContainingItem() and container~=player:getInventory())) then return true end
    -- Floor/aggregate proxies may be transiently empty while their UI rebuilds.
    -- Keep intent controls stable; acquisition still validates actual item sources.
    if container==player:getInventory() then return true end
    if container:isEmpty() then return false end
    if External.hint(container,player) then return true end
    local item=container:getContainingItem()
    if item then return B47ANCEDQuartermaster.Movement.carrier(player,item:getID())==container end
    local obj=container:getParent()
    return obj and obj.getContainerIndex and B47ANCEDQuartermaster.Targets.make(obj,obj:getContainerIndex(container),player)~=nil
end
local function nothing(reasons)
    if reasons and type(reasons.LedgerRequired)=='number' and reasons.LedgerRequired>0 then return getText('UI_QMSS_LedgerRequired') end
    local parts={}
    for _,key in ipairs({'carryCapacity','destinationRejected','noMatchingRule','alreadySorted','sourceChanged','itemProtected'}) do
        local count=reasons and reasons[key]
        if type(count)=='number' and count>0 then parts[#parts+1]=getText('UI_B47_Skip_'..key,math.floor(count)) end
    end
    return #parts>0 and getText('UI_B47_SortNothingReasons',table.concat(parts,'; ')) or getText('UI_B47_SortNothing')
end
local function report(player,text,outcome)
    if outcome then
        local saved=outcome=='SortLedgerSaved' or outcome=='SortLedgerSyncPending' or outcome=='SortLedgerUnchanged' or outcome=='SortLedgerSkipped'
        local detail=getText('UI_QMSS_'..outcome)
        text=text..'\n'..(saved and detail or getText('UI_QMSS_SortLedgerWriteIncomplete',detail))
    end
    player:setHaloNote(text)
end
local function singleSort(playerNum,container)
    local player=getSpecificPlayer(playerNum)
    if not player or isGamePaused() then return end
    if B47ANCEDQuartermaster.RoomSort and B47ANCEDQuartermaster.RoomSort.active[playerNum] then B47ANCEDQuartermaster.RoomSort.cancel(playerNum);return end
    if S.active[playerNum] then S.cancel(playerNum);return end
    if ledgerWork(playerNum) then Q.LedgerUI.cancelSort(playerNum);return end
    local ok=S.start(playerNum,container,function(status,completed,failed,reasons,ledgerOutcome)
        local text
        if status=='ok' and completed==0 then text=nothing(reasons)
        elseif status=='ok' or status=='cancelled' then text=getText(status=='ok' and 'UI_B47_SortFinished' or 'UI_B47_SortStopped',completed,failed)
        else text=getText('UI_B47_SortFailed',getText('UI_QMSS_'..status),completed,failed) end
        report(player,text,ledgerOutcome)
    end)
    if not ok then player:setHaloNote(getText('UI_B47_SortBusy')) end
end
local function perform(playerNum,container)
    local player=getSpecificPlayer(playerNum)
    if not player or isGamePaused() then return end
    local area=require 'B47ANCEDQuartermaster/RoomSort'
    if area.active[playerNum] then area.cancel(playerNum);return end
    if S.active[playerNum] then S.cancel(playerNum);return end
    if ledgerWork(playerNum) then Q.LedgerUI.cancelSort(playerNum);return end
    if pendingMenus[playerNum] then return end
    pendingMenus[playerNum]=player
    Q.Authority.request(playerNum,'areaOptions',{},function(result)
        pendingMenus[playerNum]=nil
        if getSpecificPlayer(playerNum)~=player then return end
        if result.status~='ok' then player:setHaloNote(getText('UI_QMSS_'..result.status));return end
        local menu=ISContextMenu.get(playerNum,getMouseX(),getMouseY())
        local function start(view)
            local ok=area.start(playerNum,view,function(status,moved,skipped,reasons,ledgerOutcome)
                report(player,status=='ok' and moved==0 and nothing(reasons) or getText('UI_QMSS_RoomSortSummary',getText('UI_QMSS_'..(status=='ok' and 'RoomSortComplete' or status=='cancelled' and 'RoomSortCancelled' or status)),moved,skipped),ledgerOutcome)
            end)
            if not ok then player:setHaloNote(getText('UI_B47_SortBusy')) end
        end
        if result.building then menu:addOption(getText('UI_QMSS_SortEntireBuilding'),nil,function() start({kind='building'}) end) end
        local rooms=result.rooms or {}
        local function selectRoom(room) start({kind='customRoom',room=room.id,revision=room.revision}) end
        if #rooms==1 then menu:addOption(getText('UI_QMSS_SortRoom'),nil,function() selectRoom(rooms[1]) end)
        elseif #rooms>1 then
            local option=menu:addOption(getText('UI_QMSS_SortRoom'));local sub=ISContextMenu:getNew(menu);menu:addSubMenu(option,sub)
            for _,room in ipairs(rooms) do local selected=room;sub:addOption(selected.label or selected.name,nil,function() selectRoom(selected) end) end
        end
        if supported(player,container) then
            menu:addOption(getText(container==player:getInventory() and 'UI_QMSS_SortOnlyInventory' or 'UI_QMSS_SortOnlyContainer'),nil,function() singleSort(playerNum,container) end)
        end
        menu:addOption(getText('UI_QMSS_DangerousLoadTitle'),nil,function() require('B47ANCEDQuartermaster/LoadSettingsUI').open(playerNum) end)
        if B47ANCEDUI and B47ANCEDUI.menu then B47ANCEDUI.menu(menu) end
        if player:getJoypadBind()~=-1 then setJoypadFocus(playerNum,menu) end
    end)
end
local function install(base,registry,name,floor)
    local handler=base:derive(name)
    function handler:new() return base.new(self) end
    function handler:playerIndex() return self.playerNum or (self.inventoryWindow and self.inventoryWindow.player) or (self.lootWindow and self.lootWindow.player) or 0 end
    function handler:shouldBeVisible()
        local player=getSpecificPlayer(self:playerIndex())
        return player and (sorting(self:playerIndex()) or supported(player,self.container))
    end
    function handler:getControl()
        return self:getButtonControl(getText(sorting(self:playerIndex()) and 'UI_B47_StopSorting' or 'UI_B47_Sort'))
    end
    function handler:perform() perform(self:playerIndex(),self.container) end
    function handler:handleJoypadContextMenu(context)
        self:addJoypadContextMenuOption(context,getText(sorting(self:playerIndex()) and 'UI_B47_StopSorting' or 'UI_B47_Sort'))
    end
    local register=floor and registry.AddFloorHandler or registry.AddHandler
    register(handler)
end
install(ISInventoryWindowControlHandler,ISInventoryWindowContainerControls,'B47InventorySortControl')
install(ISLootWindowObjectControlHandler,ISLootWindowContainerControls,'B47LootSortControl')
install(ISLootWindowFloorControlHandler,ISLootWindowContainerControls,'B47FloorSortControl',true)
