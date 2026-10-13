-- Client presentation only. One outline per open picker and local player.
require 'B47ANCEDQuartermaster/Targets'
local T=B47ANCEDQuartermaster.Targets
local H={};H.__index=H
B47ANCEDQuartermaster.WorldHighlight=H
local function safe(method,obj,...)
    if not obj or type(obj[method])~='function' then return end
    local ok,result=pcall(obj[method],obj,...)
    if ok then return result end
end
function H.new(playerNum)
    return setmetatable({playerNum=playerNum,enabled=true},H)
end
function H:clear()
    local object=self.owned
    self.owned=nil;self.target=nil
    local attachedBefore=self.attachedBefore
    self.attachedBefore=nil
    if not object then return end
    -- Never undo an outline that existed before our selection.
    safe('setOutlineHighlight',object,self.playerNum,false)
    safe('setOutlineHlAttached',object,self.playerNum,attachedBefore==true)
    if ISInventoryPage and ISInventoryPage.OnObjectHighlighted then
        ISInventoryPage.OnObjectHighlighted(self.playerNum,object,false)
    end
end
function H:resolve(target)
    if not target then return end
    local player=getSpecificPlayer(self.playerNum)
    if not player then return end
    local live
    if target.obj then
        if T.valid(target,player) then live=target end
    elseif target.x and target.y and target.z and target.index and target.ci then
        live=T.resolve(target,player)
    end
    return live and live.obj or nil
end
function H:select(target)
    local object=self.enabled and self:resolve(target) or nil
    if object==self.owned or object==self.target then return end
    self:clear()
    if not object then return end
    self.target=object
    if safe('isOutlineHighlight',object,self.playerNum) then return end
    if type(object.setOutlineHighlight)~='function' then return end
    if not pcall(object.setOutlineHighlight,object,self.playerNum,true) then return end
    self.attachedBefore=safe('isOutlineHlAttached',object,self.playerNum)==true
    safe('setOutlineHlAttached',object,self.playerNum,true)
    self.owned=object
    if ISInventoryPage and ISInventoryPage.OnObjectHighlighted then
        ISInventoryPage.OnObjectHighlighted(self.playerNum,object,true)
    end
end
function H:setEnabled(enabled,target)
    if self.enabled==enabled then return end
    self.enabled=enabled
    if not enabled then self:clear() else self:select(target) end
end
function H:tick(target)
    if not self.enabled or not self.target then return end
    if self:resolve(target)~=self.target then self:clear() end
end
return H
