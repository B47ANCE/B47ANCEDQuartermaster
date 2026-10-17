-- Native-shaped active-mod list; no external Lua loaded.
dofile(TEST_ROOT..'/fixtures/containers.lua')
local C=require 'B47ANCEDQuartermaster/Compatibility'
local A=require 'B47ANCEDQuartermaster/Authority'
local function active(ids)
 getActivatedMods=function() return {size=function() return #ids end,get=function(_,i) return ids[i+1] end} end
 C.invalidate()
end
active({'B47ANCEDQuartermaster'})
assert(C.allowed() and A.handle(nil,'discover',{}).status=='invalid')
active({'SimilarBetterSortCC','QuartermasterLegacy'})
assert(C.allowed(),'display/name similarity must not reject')
local historical={Quartermaster={cats={B47_MedicalBandages=true}}}
assert(historical.Quartermaster and C.allowed(),'historical data is not an active mod')
active({'B47ANCEDQuartermaster','BetterSortCC','EURY_CONTAINERS'})
assert(C.allowed() and C.explicitCategorySelections(),'optional mods were rejected')
for _,id in ipairs({'Quartermaster'}) do
 active({'B47ANCEDQuartermaster',id})
 local allowed,found,label=C.allowed()
 assert(not allowed and found==id and label==C.names[id])
 assert(A.handle(nil,'discover',{}).status=='IncompatibleMod','server authority accepted conflicting setup')
 local result;A.request(0,'discover',{},function(r) result=r end)
 assert(result and result.status=='IncompatibleMod','client request was sent')
end
active({'B47ANCEDQuartermaster'})
assert(C.allowed(),'conflict state leaked into new session')
print('PASS OFFLINE dev.13 exact active Mod ID rejection, harmless historical data, no false positives, authority fail-closed')
