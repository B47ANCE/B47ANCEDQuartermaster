-- Sandbox option aliases only. No sorting-data fallback or legacy routing.
local M={ids={'B47ANCEDSorting','QuartermasterSorting','QuartermasterSimpleSorting'}}
function M.option(name)
    local vars=SandboxVars or {}
    for _,key in ipairs({'B47ANCEDQuartermaster',unpack(M.ids)}) do
        local group=vars[key]
        if type(group)=='table' and group[name]~=nil then return group[name] end
    end
end
return M
