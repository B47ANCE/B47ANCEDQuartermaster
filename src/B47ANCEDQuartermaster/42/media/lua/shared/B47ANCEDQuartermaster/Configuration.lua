B47ANCEDQuartermaster = B47ANCEDQuartermaster or {}
require 'B47ANCEDQuartermaster/Store'
local C={fields={cats=true,items=true,presets=true,priority=true}}
B47ANCEDQuartermaster.Configuration=C
function C.clone(value)
    if type(value)~='table' then return value end
    local out={}; for k,v in pairs(value) do out[k]=C.clone(v) end; return out
end
function C.equal(a,b)
    if type(a)~=type(b) then return false end
    if type(a)~='table' then return a==b end
    for k,v in pairs(a) do if not C.equal(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
function C.read(t) return B47ANCEDQuartermaster.Store.load(t) end
function C.valid(config) return B47ANCEDQuartermaster.Schema.valid(config) end
return C
