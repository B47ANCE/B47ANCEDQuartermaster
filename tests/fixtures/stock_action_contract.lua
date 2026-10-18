-- Independent host-only action scaffolding. Not copied native code and never
-- shipped. CI cannot load proprietary PZ files; local full tests still do.
local original=dofile
function dofile(path)
 if path~=GAME_ROOT..'/media/lua/shared/TimedActions/ISBaseTimedAction.lua' then return original(path) end
 ISBaseTimedAction=ISBaseObject:derive('StockContractTimedAction')
 function ISBaseTimedAction:new(character) return setmetatable({character=character},{__index=self}) end
 function ISBaseTimedAction:setActionAnim(name) assert(self.action);self.action:setActionAnim(name) end
 function ISBaseTimedAction:stop() self.contractStopped=true end
 function ISBaseTimedAction:perform() self.contractPerformed=true end
 function ISBaseTimedAction:forceStop() self:stop() end
 return ISBaseTimedAction
end
