-- Conflicting Mod ID is known before module entry-point registration.
local registered={client=0,server=0}
Events=setmetatable({
 OnClientCommand={Add=function() registered.client=registered.client+1 end},
 OnServerCommand={Add=function() registered.server=registered.server+1 end}},
 {__index=function() return {Add=function() end} end})
getActivatedMods=function() return {size=function() return 2 end,get=function(_,i) return ({'B47ANCEDQuartermaster','Quartermaster'})[i+1] end} end
function isClient() return false end
function isServer() return true end
local A=require 'B47ANCEDQuartermaster/Authority'
assert(registered.client==0 and registered.server==0,'routing handlers installed despite conflict')
assert(A.handle({},'discover',{}).status=='IncompatibleMod')
print('PASS OFFLINE dev.13 conflict prevents routing-handler registration and authority mutation')
