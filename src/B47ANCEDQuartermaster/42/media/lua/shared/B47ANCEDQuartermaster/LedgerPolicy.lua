-- Server sandbox policy; time is persisted native world age, never client time.
local Options=require 'B47ANCEDQuartermaster/Migration'
local P={}
local function integer(n,lo,hi) return type(n)=='number' and n==n and n%1==0 and n>=lo and n<=hi end
function P.mode()
 local n=Options.option('LedgerMode');return integer(n,1,4) and n or 1
end
function P.enabled() return P.mode()~=2 end
function P.days()
 local n=Options.option('LedgerUpdateDays');return integer(n,1,365) and n or 7
end
function P.manualComputer() return Options.option('LedgerComputerManualUpdates')~=false end
function P.complete(s) return s and s.complete==true and s.status=='LedgerComplete' or false end
function P.computerMatches(s,signature)
 -- The caller derives the signature from the verified computer's native building,
 -- never a client-supplied scope. Safehouse ledgers have no single building.
 return type(s)=='table' and type(s.scope)=='table' and s.scope.kind=='building'
  and type(signature)=='string' and signature==s.signature or false
end
function P.fresh(s,computer)
 if not P.enabled() or not P.complete(s) then return false end
 local now=getGameTime():getWorldAgeHours();local finished=s.finished
 if type(now)~='number' or now~=now or now<0 or now==math.huge or type(finished)~='number' or finished~=finished or finished<0 or finished>now then return false end
 if P.mode()==3 or computer and not P.manualComputer() then return true end
 return now-finished<P.days()*24
end
function P.deadline(s,computer)
 if P.mode()==3 or computer and not P.manualComputer() then return end
 local n=s and s.finished
 if type(n)=='number' and n==n and n>=0 and n<math.huge then return n+P.days()*24 end
end
function P.live(s,computer)
 return P.fresh(s,computer) and (P.mode()~=4 or computer and not P.manualComputer()) or false
end
-- Native recipe OnTest hook: definitions/items remain loadable when disabled.
function B47SupplyLedgerEnabled() return P.enabled() end
return P
