-- Exact active Mod IDs only. Historical data and installed-but-disabled mods do not count.
B47ANCEDQuartermaster=B47ANCEDQuartermaster or {}
local C={names={Quartermaster='Quartermaster'}}
B47ANCEDQuartermaster.Compatibility=C
local reported,cached,cachedID,cachedName,active
function C.invalidate()
    cached,cachedID,cachedName,reported,active=nil,nil,nil,nil,nil
end
function C.conflict()
    if cached then return cachedID,cachedName end
    if type(getActivatedMods)~='function' then return nil,'active-mod-api-unavailable' end
    local ok,mods=pcall(getActivatedMods)
    if not ok or not mods then return nil,'active-mod-api-unavailable' end
    local count=type(mods.size)=='function' and mods:size() or type(mods)=='table' and #mods or nil
    if type(count)~='number' or count<0 or count>8192 then return nil,'active-mod-api-unavailable' end
    active={}
    for i=0,count-1 do
        local id=type(mods.get)=='function' and mods:get(i) or mods[i+1]
        if type(id)=='string' then active[id]=true end
        if C.names[id] then cached,cachedID,cachedName=true,id,C.names[id];return cachedID,cachedName end
    end
    cached=true
end
function C.explicitCategorySelections()
    C.conflict()
    -- Custom categories can be client-local: send explicit item choices instead.
    return active and (active.EURY_CONTAINERS==true or active.REORDER_CONTAINERS==true
        or active.CAExtendedCategories==true) or false
end
function C.allowed()
    local id,name=C.conflict()
    if id and reported~=id then
        print("[B47ANCEDQuartermaster] INCOMPATIBLE active mod "..id.." ("..name.."); disable one sorting mod before continuing. B47 gameplay requests are disabled.")
        reported=id
    end
    return id==nil and name~='active-mod-api-unavailable',id,name,
        name=='active-mod-api-unavailable' and 'CompatibilityUnknown' or id and 'IncompatibleMod' or 'ok'
end
if Events and Events.OnGameStart then Events.OnGameStart.Add(C.invalidate) end
return C
