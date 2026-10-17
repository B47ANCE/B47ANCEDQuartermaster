-- Vanilla/installed UI mods own inventory category labels, row keys and sorting.
require 'B47ANCEDQuartermaster/Categorizer'
local Q=B47ANCEDQuartermaster
local I={installed=false};Q.InventoryCategories=I
function I.label(item) return Q.Categorizer.label(Q.Categorizer.resolve(item)) end
function I.enableDiagnostics(enabled) Q.InventoryCategoryTraceEnabled=enabled==true end
function I.install() end -- Retained developer API; no UI interception.
function I.present() end
return I
