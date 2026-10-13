require 'B47ANCEDQuartermaster/Schema'
local R=require 'B47ANCEDQuartermaster/Categorizer'
local P={};B47ANCEDQuartermaster.ItemCatalog=P
-- Reuse the already prepared presentation registry, retaining native script icons.
function P.seed(entries)
    if P.cache then return end
    local rows={}
    for _,entry in ipairs(entries or {}) do
        if not entry.script then return end
        rows[#rows+1]={name=entry.name,fullType=entry.fullType,script=entry.script,search=string.lower(entry.name..' '..entry.fullType..' '..(entry.module or ''))}
    end
    table.sort(rows,function(a,b) return a.name==b.name and a.fullType<b.fullType or a.name<b.name end)
    P.cache=rows
end
function P.catalog()
    if P.cache then return P.cache end
    local rows={};local items=getAllItems and getAllItems() or getScriptManager():getAllItems()
    for i=0,items:size()-1 do
        local script=items:get(i)
        if R.catalogEligible(script) then
            local name,t=script:getDisplayName(),script:getFullName()
            rows[#rows+1]={name=name,fullType=t,script=script,search=string.lower(name..' '..t..' '..script:getModuleName())}
        end
    end
    table.sort(rows,function(a,b) return a.name==b.name and a.fullType<b.fullType or a.name<b.name end)
    P.cache=rows;return rows
end
function P.search(query)
    local rows={};query=string.lower(query or '')
    for _,row in ipairs(P.catalog()) do if string.find(row.search,query,1,true) then rows[#rows+1]=row end end
    return rows
end
function P.invalidate() P.cache=nil end
if Events and Events.OnGameStart then Events.OnGameStart.Add(P.invalidate) end
return P
