require 'TimedActions/ISBaseTimedAction'
local L=require 'B47ANCEDQuartermaster/Ledger'
ISB47SupplyLedgerAction=ISBaseTimedAction:derive('ISB47SupplyLedgerAction')
local C=ISB47SupplyLedgerAction
-- These exact constructor fields are the only native serialized input.
function C:new(character,token)
 if not isClient() then return L.reconstruct(character,token) end
 local offer=L.clientOffers[token]
 if not offer or offer.actor~=character then return end
 return C.raw(character,token,offer.seconds)
end
function C.raw(character,token,seconds)
 local o=ISBaseTimedAction.new(C,character);o.token=token;o.seconds=seconds;o.maxTime=seconds*50
 o.stopOnWalk=true;o.stopOnRun=true;o.stopOnAim=true;return o
end
function C:getDuration() return self.seconds*50 end
function C:isValid()
 if isClient() then return L.clientOffers[self.token]~=nil end
 return L.valid(self.character,self.token,self)
end
function C:serverStart() return L.start(self.character,self.token,self) end
function C:start()
 if not isClient() and not isServer() and not L.start(self.character,self.token,self) then self:forceStop();return end
 self:setActionAnim('Loot')
end
function C:complete() return L.complete(self.character,self.token,self) end
local function cancel(self)
 if isClient() then
  B47ANCEDQuartermaster.Authority.request(self.character:getPlayerNum(),'ledgerCancel',{token=self.token},function() end)
  L.clientOffers[self.token]=nil
 else L.stop(self.character,self.token) end
end
function C:serverStop() return L.stop(self.character,self.token) end
function C:stop() cancel(self);if not isServer() then ISBaseTimedAction.stop(self) end end
function C:forceCancel() cancel(self) end
function C:perform()
 if not isClient() and not isServer() then self:complete() end
 ISBaseTimedAction.perform(self)
end
return C
