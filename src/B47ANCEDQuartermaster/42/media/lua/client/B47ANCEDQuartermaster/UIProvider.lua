-- Required presentation provider; no gameplay state or alternate implementation.
local API=require 'B47ANCEDUI/API'
local UI=API.requireVersion(1).forMod('B47ANCEDQuartermaster',{legacyAppearancePrefix='B47ANCEDQuartermasterAppearance'})
B47ANCEDQuartermaster=B47ANCEDQuartermaster or {}
B47ANCEDQuartermaster.UIProvider=UI
return UI
