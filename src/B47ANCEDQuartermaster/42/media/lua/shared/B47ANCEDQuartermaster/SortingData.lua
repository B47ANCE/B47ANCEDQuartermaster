-- One-way retirement of owned sorting formats. No world scan or direct save-file edits.
require 'B47ANCEDQuartermaster/Schema'
local R=require 'B47ANCEDQuartermaster/Categorizer'
local S=B47ANCEDQuartermaster.Schema
local D={aliases={'B47ANCEDSorting','QuartermasterSorting','QuartermasterSimpleSorting'}}
B47ANCEDQuartermaster.SortingData=D
local function revision(n) return type(n)=='number' and n>=0 and n<2^53-1 and n==math.floor(n) end
local function copy(value) local out={};for k,v in pairs(value) do out[k]=v end;return out end
function D.config(config)
    if not S.valid(config) then return nil,'invalid' end
    local out=S.copy(config);local changed=false
    for id in pairs(out.cats) do if not R.known(id) then out.cats[id]=nil;changed=true end end
    for name,link in pairs(out.presets) do if not S.ownedLink(link) then out.presets[name]=nil;changed=true end end
    return out,nil,changed
end
function D.object(obj)
    if isClient() then return nil,'invalid' end
    local md=obj:getModData();local current=md[S.key]
    local roots={};if current~=nil then roots[#roots+1]={key=S.key,value=current} end
    for _,key in ipairs(D.aliases) do if md[key]~=nil then roots[#roots+1]={key=key,value=md[key]} end end
    if #roots==0 then return end
    local result=current and type(current)=='table' and copy(current) or {schemaVersion=1}
    result.containers={};local changed=false;local count=0
    -- Validate and stage every owned slot before changing any ModData. Current
    -- entries win; aliases never overwrite an existing current configuration.
    for _,entry in ipairs(roots) do
        local root=entry.value
        if type(root)~='table' or root.schemaVersion~=1 or type(root.containers)~='table' then return nil,'schema' end
        for slot,envelope in pairs(root.containers) do
            count=count+1;if count>4096 then return nil,'invalid' end
            local ci=type(slot)=='string' and tonumber(slot)
            if not ci or ci<0 or ci~=math.floor(ci) or tostring(ci)~=slot or ci>=obj:getContainerCount() then return nil,'invalid' end
            if type(envelope)~='table' or (envelope.schemaVersion~=1 and envelope.schemaVersion~=S.version)
                or not revision(envelope.revision) then return nil,'schema' end
            local tax=envelope.taxonomyVersion
            if tax~=nil and (type(tax)~='number' or tax<0 or tax>R.version or tax~=math.floor(tax)) then return nil,'taxonomy' end
            local container=obj:getContainerByIndex(ci)
            if not container or envelope.kind~=container:getType() or envelope.containerCount~=obj:getContainerCount() then return nil,'invalid' end
            local config,err,cleaned=D.config(envelope.config);if not config then return nil,err end
            if not result.containers[slot] then
                local replace=entry.key~=S.key or cleaned or envelope.schemaVersion~=S.version or tax~=R.version or envelope.legacyImported~=nil
                if replace then
                    local value=S.envelope(config,envelope.revision+1)
                    if not value then return nil,'invalid' end
                    value.kind=envelope.kind;value.containerCount=envelope.containerCount
                    result.containers[slot]=value;changed=true
                else result.containers[slot]=envelope end
            end
        end
        if entry.key~=S.key then changed=true end
    end
    if changed then
        md[S.key]=result
        for _,key in ipairs(D.aliases) do md[key]=nil end
        obj:transmitModData()
    end
    return changed and result or current
end
function D.furniture(obj,data)
    if isClient() or not data then return data end
    local result=copy(data);result.parents={};local changed=false
    for slot,parent in pairs(data.parents) do
        if type(parent)~='table' or parent.schema~=1 or type(parent.id)~='string' or type(parent.members)~='table'
            or not revision(parent.revision) then return nil,'schema' end
        local config,err,cleaned=D.config(parent.config);if not config then return nil,err end
        if cleaned then
            local value=copy(parent);value.config=config;value.revision=parent.revision+1
            result.parents[slot]=value;changed=true
        else result.parents[slot]=parent end
    end
    if changed then obj:getModData().B47WholeContainer=result;obj:transmitModData() end
    return changed and result or data
end
return D
