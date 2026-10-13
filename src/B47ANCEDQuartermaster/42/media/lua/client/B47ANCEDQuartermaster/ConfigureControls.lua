require 'B47ANCEDQuartermaster/Adapter'
require 'B47ANCEDQuartermaster/Targets'
require 'B47ANCEDQuartermaster/DibsUI'
require 'ISUI/InventoryWindow/ISInventoryWindowControlHandler'
require 'ISUI/InventoryWindow/ISInventoryWindowContainerControls'
local Q=B47ANCEDQuartermaster
local Compatibility=require 'B47ANCEDQuartermaster/Compatibility'
if not Compatibility.allowed() then return end
local Control=ISInventoryWindowControlHandler:derive('B47ConfigureControl')
function Control:new() return ISInventoryWindowControlHandler.new(self) end
function Control:playerIndex() return self.playerNum or (self.inventoryWindow and self.inventoryWindow.player) or 0 end
function Control:shouldBeVisible() return Compatibility.allowed() and getSpecificPlayer(self:playerIndex())~=nil end
function Control:getControl() return self:getButtonControl(getText('UI_QMSS_OpenMenu')) end
function Control:perform()
    if not Compatibility.allowed() then return end
    if getSpecificPlayer(self:playerIndex()) then Q.openPicker(nil,nil,self:playerIndex()) end
end
function Control:handleJoypadContextMenu(context) self:addJoypadContextMenuOption(context,getText('UI_QMSS_OpenMenu')) end
ISInventoryWindowContainerControls.AddHandler(Control)
-- Native world-object menu entry; test passes discover availability only.
function Control.fill(playerNum,context,objects,test)
    if not Compatibility.allowed() then return end
    local player=getSpecificPlayer(playerNum)
    local found,seen={},{}
    local function inspect(obj)
        if not obj or seen[obj] then return end
        seen[obj]=true
        for ci=0,obj:getContainerCount()-1 do
            local target=Q.Targets.make(obj,ci,player)
            if target then found[#found+1]=target end
        end
    end
    if objects and objects.size and objects.get then
        for i=0,objects:size()-1 do inspect(objects:get(i)) end
    else for _,obj in ipairs(objects or {}) do inspect(obj) end end
    if #found==0 then return end
    if test then return ISWorldObjectContextMenu.setTest() end
    for _,option in ipairs(context.options or {}) do if option.b47OpenMenu then return end end
    local option=context:addOption(getText('UI_QMSS_OpenMenu'),found[1],function(t) Q.openPicker(t.obj,t.ci,playerNum) end)
    option.b47OpenMenu=true
    if context.prerender and not context.b47BottomWrapper then
        context.b47BottomWrapper=true
        local prerender=context.prerender
        context.prerender=function(self)
            local hovered=self.options[self.mouseOver or 0]
            for i,entry in ipairs(self.options) do
                if entry.b47OpenMenu and i<#self.options then
                    table.remove(self.options,i);self.options[#self.options+1]=entry;break
                end
            end
            for i,entry in ipairs(self.options) do entry.id=i;if entry==hovered then self.mouseOver=i end end
            prerender(self)
        end
    end
end
if Events then Events.OnFillWorldObjectContextMenu.Add(Control.fill) end
return Control
