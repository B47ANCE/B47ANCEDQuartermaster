require 'B47ANCEDQuartermaster/Schema'
local C={};B47ANCEDQuartermaster.ProjectCookAdapter=C
function C.status()
    if not getActivatedMods then return 'unknown' end
    return getActivatedMods():contains('Project_Cook') and 'optional' or 'absent'
end
function C.resolve()
    -- Project Cook is a frontend, never a server recipe authority. Its native
    -- craft/evolved identities route directly through ShoppingRequirements.
    return nil,'unsupported'
end
return C
