-- Standalone data contract. No engine access, networking, or world mutation.
B47ANCEDQuartermaster = B47ANCEDQuartermaster or {}
local S = {version=2, key='B47ANCEDQuartermaster'}
B47ANCEDQuartermaster.Schema = S
local fields={cats=true,items=true,presets=true,priority=true}
local function integer(n)
    return type(n)=='number' and n==n and math.abs(n)<2^53 and n==math.floor(n)
end
local function plain(t) return type(t)=='table' and getmetatable(t)==nil end
local function ownedLink(v)
    local n=type(v)=='string' and v:match('^b47:(%d+)$')
    n=n and tonumber(n)
    return n and integer(n) and n>0 and v=='b47:'..tostring(n)
end
S.ownedLink=ownedLink
function S.empty() return {cats={},items={},presets={},priority=0} end
function S.copy(config)
    local out=S.empty()
    for _,field in ipairs({'cats','items','presets'}) do
        for k,v in pairs(config[field]) do out[field][k]=v end
    end
    out.priority=config.priority
    return out
end
function S.valid(config)
    if not plain(config) or not integer(config.priority) then return false end
    for k in pairs(config) do if not fields[k] then return false end end
    local bytes,count=0,0
    for _,field in ipairs({'cats','items','presets'}) do
        if not plain(config[field]) then return false end
        for k,v in pairs(config[field]) do
            if type(k)~='string' or #k==0 or #k>1024 then return false end
            if v~=true and not (field=='presets' and ((integer(v) and v>0) or ownedLink(v))) then return false end
            count=count+1; bytes=bytes+#k+16
            -- Protocol safety bounds; not gameplay options.
            if count>50000 or bytes>524288 then return false end
        end
    end
    return true
end
function S.equal(a,b)
    if not S.valid(a) or not S.valid(b) or a.priority~=b.priority then return false end
    for _,f in ipairs({'cats','items','presets'}) do
        for k,v in pairs(a[f]) do if b[f][k]~=v then return false end end
        for k,v in pairs(b[f]) do if a[f][k]~=v then return false end end
    end
    return true
end
function S.current(config)
    if not S.valid(config) or not require('B47ANCEDQuartermaster/Categorizer').validRules(config.cats) then return false end
    for _,link in pairs(config.presets) do if not ownedLink(link) then return false end end
    return true
end
function S.envelope(config, revision)
    if not S.current(config) or not integer(revision) or revision<0 then return nil,'invalid' end
    return {schemaVersion=S.version,taxonomyVersion=7,revision=revision,config=S.copy(config)}
end
function S.decode(value)
    if not plain(value) then return nil,'invalid' end
    if value.schemaVersion~=S.version then return nil,'schema' end
    if value.taxonomyVersion~=7 then return nil,'taxonomy' end
    if not integer(value.revision) or value.revision<0 or not S.current(value.config) then return nil,'invalid' end
    return S.copy(value.config),nil,value.revision
end
-- Only the current owned envelope is read. Old owned data is retired by SortingData.
-- Foreign Quartermaster registries are neither imported nor modified.
function S.read(native)
    if native~=nil then
        local config,err,revision=S.decode(native)
        return config,err,false,revision
    end
    return S.empty(),nil,false,0
end
function S.link(def)
    return def and def.owned==true and ('b47:'..tostring(def.gen)) or nil
end
function S.resolves(def,link)
    return plain(def) and integer(def.gen) and def.gen>0
        and def.owned==true and ownedLink(link) and link==S.link(def)
        and S.valid({cats=def.cats,items=def.items,presets={},priority=0})
end
function S.effective(config,presets)
    local out=S.copy(config)
    for name,link in pairs(config.presets) do
        local def=presets and presets[name]
        if S.resolves(def,link) then
            for k in pairs(def.cats) do out.cats[k]=true end
            for k in pairs(def.items) do out.items[k]=true end
        end
    end
    return out
end
return S
