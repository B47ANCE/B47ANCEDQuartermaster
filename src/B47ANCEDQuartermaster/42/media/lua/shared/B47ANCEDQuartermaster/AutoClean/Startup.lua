-- Auto-loaded shared entry point. Factories register no ingress before this hook.
B47ANCEDQuartermaster=B47ANCEDQuartermaster or {}
local Q=B47ANCEDQuartermaster
if Q.AutoClean then return Q.AutoClean end -- autoload/require and repeated events
local S={status='waiting'}
Q.AutoClean=S
function S.start()
 if S.instance then return true end
 local role=isClient() and not isServer() and 'client' or isServer() and not isClient() and 'server'
 if not role then S.status='singlePlayerUnsupported';return false end
 local compatible=require 'B47ANCEDQuartermaster/Compatibility'
 local allowed,_,_,reason=compatible.allowed()
 if not allowed then S.status=reason;return false end
 -- Complete Quartermaster's server readers before the first building survey.
 if role=='server' then require 'B47ANCEDQuartermaster/Authority' end
 local ok,instance,why=pcall(function() return require('B47ANCEDQuartermaster/AutoClean/BuildingWire')[role]() end)
 if not ok then
  S.status='installationFailed'
  print('[B47ANCEDQuartermaster] Clean Building installation failed: '..tostring(instance))
  return false
 end
 S.instance=instance;S.status=instance and role or why
 print('[B47ANCEDQuartermaster] Clean Building: '..tostring(S.status))
 return instance~=nil
end
-- Verified vanilla hooks: shared Util/CustomTileProps.lua uses both events.
Events.OnGameStart.Add(S.start)
Events.OnServerStarted.Add(S.start)
return S
