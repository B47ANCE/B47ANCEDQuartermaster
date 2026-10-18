local UI=require 'B47ANCEDQuartermaster/UIProvider'
local A={colors=UI.Clipboard.colors}
function A.draw(panel,view,metrics) return UI.Clipboard.draw(panel,view,metrics,getText('UI_QMSS_LedgerClipboardTitle')) end
return A
