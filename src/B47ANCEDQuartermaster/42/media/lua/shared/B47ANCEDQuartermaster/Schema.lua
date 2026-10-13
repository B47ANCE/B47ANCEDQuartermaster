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
function S.envelope(config, revision, imported)
    if not S.valid(config) or not integer(revision) or revision<0 then return nil,'invalid' end
    return {schemaVersion=S.version,taxonomyVersion=6,revision=revision,config=S.copy(config),legacyImported=imported==true}
end
function S.decode(value)
    if not plain(value) then return nil,'invalid' end
    if value.schemaVersion~=1 and value.schemaVersion~=S.version then return nil,'schema' end
    if value.taxonomyVersion~=nil and value.taxonomyVersion~=0 and value.taxonomyVersion~=1 and value.taxonomyVersion~=2 and value.taxonomyVersion~=3 and value.taxonomyVersion~=4 and value.taxonomyVersion~=5 and value.taxonomyVersion~=6 then return nil,'taxonomy' end
    if not integer(value.revision) or value.revision<0 or not S.valid(value.config) then return nil,'invalid' end
    return S.copy(value.config),nil,value.revision
end
-- Import is read-only. A caller must explicitly commit the returned value on authority.
-- Native presence (even corrupt/future data) blocks fallback to legacy data.
function S.read(native, legacy, ci)
    if native~=nil then
        local config,err,revision=S.decode(native)
        return config,err,false,revision
    end
    if not integer(ci) or ci<0 or not plain(legacy or {}) then return nil,'invalid' end
    local config,found=S.empty(),false
    local names={cats='LSBox',items='LSBoxItems',presets='LSBoxPresets',priority='LSBoxPriority'}
    local index=tostring(ci)
    for field,key in pairs(names) do
        local map=legacy and legacy[key]
        if map~=nil and not plain(map) then return nil,'legacy-invalid' end
        local value=map and map[index]
        if value~=nil then config[field]=value;found=true end
    end
    if not S.valid(config) then return nil,'legacy-invalid' end
    return S.copy(config),nil,found,0
end
function S.link(def)
    return def and (def.owned==true and ('b47:'..tostring(def.gen)) or def.gen)
end
function S.resolves(def,link)
    return plain(def) and integer(def.gen) and def.gen>0
        and ((def.owned==true and link==S.link(def)) or (def.owned~=true and (link==true or link==def.gen)))
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
