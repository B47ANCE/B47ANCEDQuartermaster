-- Read-only recognition of previous identities. Never register legacy modules or write them.
local M={ids={'B47ANCEDSorting','QuartermasterSorting','QuartermasterSimpleSorting'}}
function M.envelope(md,ci)
    for _,key in ipairs({'B47ANCEDQuartermaster',unpack(M.ids)}) do
        local root=md[key]
        if root~=nil then
            if type(root)~='table' or root.schemaVersion~=1 or type(root.containers)~='table' then return nil,'schema' end
            local value=root.containers[tostring(ci)]
            if value~=nil then return value,nil,key~='B47ANCEDQuartermaster' end
        end
    end
end
function M.option(name)
    local vars=SandboxVars or {}
    for _,key in ipairs({'B47ANCEDQuartermaster',unpack(M.ids)}) do
        local group=vars[key]
        if type(group)=='table' and group[name]~=nil then return group[name] end
    end
end
return M
