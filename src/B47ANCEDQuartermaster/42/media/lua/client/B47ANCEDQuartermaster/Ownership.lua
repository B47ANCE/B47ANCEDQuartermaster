B47ANCEDQuartermaster = B47ANCEDQuartermaster or {}
local Ownership = {}
B47ANCEDQuartermaster.Ownership = Ownership

-- Engine provenance, not module-name or path inference. A shared display name may
-- represent several script types; use Unknown if their reported owners disagree.
function Ownership.build()
    local owners, labels = {}, {}
    local ok = pcall(function()
        local items = getScriptManager():getAllItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            local success, cat, name, mod = pcall(function()
                if item:isHidden() or item:getObsolete() then return end
                return item:getDisplayCategory(), item:getDisplayName(), item:getModID()
            end)
            if success and name and name ~= '' then
                local key = (cat or '') .. '\0' .. name
                local id = type(mod) == 'string' and mod ~= '' and mod or 'unknown:'
                if owners[key] and owners[key] ~= id then owners[key] = 'unknown:'
                else owners[key] = id end
            end
        end
    end)
    if not ok then owners = {} end
    return function(category, name)
        local id = owners[(category or '') .. '\0' .. name] or 'unknown:'
        if not labels[id] then
            if id == 'pz-vanilla' then labels[id] = getText('UI_QMSS_Vanilla')
            elseif id == 'unknown:' then labels[id] = getText('UI_QMSS_Unknown')
            else
                local success, label = pcall(function()
                    local info = getModInfoByID(id)
                    return info and info:getName()
                end)
                labels[id] = success and type(label) == 'string' and label ~= '' and label or id
            end
        end
        return id, labels[id]
    end
end
return Ownership
