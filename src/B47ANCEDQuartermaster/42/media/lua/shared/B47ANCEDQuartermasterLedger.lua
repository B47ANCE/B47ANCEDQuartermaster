-- Register on both peers; the native constructor never accepts data or duration.
require 'B47ANCEDQuartermaster/LedgerAction'
if not isServer() then
 require 'B47ANCEDQuartermaster/LedgerUI'
 require 'B47ANCEDQuartermaster/ShoppingPaperHUD'
end
