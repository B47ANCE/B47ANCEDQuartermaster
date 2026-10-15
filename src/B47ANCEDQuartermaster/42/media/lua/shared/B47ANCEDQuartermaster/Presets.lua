require 'B47ANCEDQuartermaster/Schema'
local S=B47ANCEDQuartermaster.Schema
local SortingData=require 'B47ANCEDQuartermaster/SortingData'
local P={}
B47ANCEDQuartermaster.Presets=P
local function integer(v) return type(v)=='number' and v>=0 and v<2^53 and v==math.floor(v) end
local function name(v) return type(v)=='string' and #v>0 and #v<=128 and not v:find('%c') and v:find('%S') end
local copy
local function root()
    if isClient() or not ModData then return nil end
    local data=ModData.getOrCreate('B47ANCEDQuartermaster')
    if data.presetLibrary==nil then data.presetLibrary={schema=1,revision=0,serial=0,definitions={}} end
    local lib=data.presetLibrary
    if type(lib)~='table' or (lib.schema~=1 and lib.schema~=2) or not integer(lib.revision) or not integer(lib.serial)
        or type(lib.definitions)~='table' then return nil end
    if not P.validDefinitions(lib.definitions) then return nil end
    local definitions={};local changed=false
    for key,def in pairs(lib.definitions) do
        local config,err,cleaned=SortingData.config({cats=def.cats,items=def.items,presets={},priority=0,allocation=def.allocation})
        if not config then return nil end
        if cleaned then
            if not integer(def.rev+1) then return nil end
            definitions[key]={cats=config.cats,items=config.items,allocation=config.allocation,label=def.label,gen=def.gen,rev=def.rev+1,owner=def.owner,owned=true};changed=true
        else definitions[key]=def end
    end
    if changed then
        if not integer(lib.revision+1) then return nil end
        if not data.presetAllocationBackup then data.presetAllocationBackup={schema=lib.schema,serial=lib.serial,revision=lib.revision,definitions=copy(lib.definitions)} end
        lib={schema=lib.schema,revision=lib.revision+1,serial=lib.serial,definitions=definitions};data.presetLibrary=lib
    end
    return lib,data
end
function P.validDefinitions(defs)
    if type(defs)~='table' then return false end
    local count,bytes=0,0
    for key,def in pairs(defs) do
        if not name(key) or type(def)~='table' or def.owned~=true or type(def.owner)~='string' or #def.owner==0 or #def.owner>256
            or not integer(def.gen) or def.gen==0 or not integer(def.rev)
            or def.label~=nil and not name(def.label)
            or not S.valid({cats=def.cats,items=def.items,presets={},priority=0,allocation=def.allocation}) then return false end
        count=count+1;bytes=bytes+#key+32
        for _,values in ipairs({def.cats,def.items}) do for k in pairs(values) do bytes=bytes+#k+16 end end
        if def.allocation then
            for _,values in ipairs({def.allocation.cats,def.allocation.items}) do for k in pairs(values) do bytes=bytes+#k+16 end end
            for full,path in pairs(def.allocation.paths) do bytes=bytes+#full;for _,k in ipairs(path) do bytes=bytes+#k+8 end end
        end
    end
    -- Bounded snapshot/network payload, not a gameplay balance setting.
    return count<=128 and bytes<=131072
end
copy=function(defs)
    local out={}
    for key,def in pairs(defs) do
        local config=S.copy({cats=def.cats,items=def.items,presets={},priority=0,allocation=def.allocation})
        out[key]={cats=config.cats,items=config.items,allocation=config.allocation,label=def.label,gen=def.gen,rev=def.rev,owner=def.owner,owned=true}
    end
    return out
end
function P.snapshot()
    local lib=root()
    if not lib or not P.validDefinitions(lib.definitions) then return nil end
    return {revision=lib.revision,definitions=copy(lib.definitions)}
end
function P.resolve(config)
    local snapshot=P.snapshot()
    for key,link in pairs(config.presets) do
        if not snapshot or not S.resolves(snapshot.definitions[key],link) then return nil end
    end
    return S.effective(config,snapshot and snapshot.definitions or {})
end
function P.change(args,player)
    if isClient() or type(args)~='table' or not name(args.name) then return {status='invalid'} end
    local lib,data=root()
    if not lib or not P.validDefinitions(lib.definitions) then return {status='schema'} end
    if args.revision~=lib.revision then return {status='conflict'} end
    local defs=copy(lib.definitions)
    local old=defs[args.name]
    local owner=player and (isServer() and player:getUsername() or ('local:'..tostring(player:getPlayerNum())))
    if type(owner)~='string' or owner=='' then return {status='invalid'} end
    -- Creation is open to validated participants; changing another player's
    -- shared definition requires a server administrator. Never trust a payload owner.
    if old and old.owner~=owner and player:getAccessLevel()~='admin' then return {status='PresetDenied'} end
    local serial=lib.serial
    if args.delete==true then
        if not old or args.generation~=old.gen then return {status='conflict'} end
        defs[args.name]=nil
    elseif args.renameTo~=nil then
        if not old or args.generation~=old.gen or not name(args.renameTo) then return {status='invalid'} end
        for key,definition in pairs(defs) do if key~=args.name and (definition.label or key)==args.renameTo then return {status='conflict'} end end
        old.label=args.renameTo;old.rev=old.rev+1
    else
        if args.duplicateOf~=nil then
            local source=defs[args.duplicateOf]
            if old or not source or args.sourceGeneration~=source.gen then return {status='conflict'} end
            args={name=args.name,generation=0,config={cats=source.cats,items=source.items,presets={},priority=0,allocation=source.allocation}}
        end
        if not S.valid(args.config) or not B47ANCEDQuartermaster.Categorizer.validRules(args.config.cats,old and old.cats) then return {status='invalid'} end
        for _ in pairs(args.config.presets) do return {status='invalid'} end
        if (old and args.generation~=old.gen) or (not old and args.generation~=0) then return {status='conflict'} end
        if not old then serial=serial+1 end
        local config=S.copy(args.config)
        defs[args.name]={cats=config.cats,items=config.items,allocation=config.allocation,label=old and old.label,gen=old and old.gen or serial,rev=old and old.rev+1 or 1,owner=old and old.owner or owner,owned=true}
    end
    if not P.validDefinitions(defs) then return {status='invalid'} end
    if lib.schema==1 and not data.presetAllocationBackup then
        data.presetAllocationBackup={schema=1,serial=lib.serial,revision=lib.revision,definitions=copy(lib.definitions)}
        print('[B47ANCEDQuartermaster] allocation migration: preserved original preset library schema 1')
    end
    data.presetLibrary={schema=2,serial=serial,revision=lib.revision+1,definitions=defs}
    return {status='ok',library=P.snapshot()}
end
return P
