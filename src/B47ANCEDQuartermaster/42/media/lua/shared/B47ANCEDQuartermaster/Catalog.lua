require 'B47ANCEDQuartermaster/Schema'
local C={}
B47ANCEDQuartermaster.Catalog=C
require 'B47ANCEDQuartermaster/Categorizer'
local R=B47ANCEDQuartermaster.Categorizer
local Migration=require 'B47ANCEDQuartermaster/Migration'
local cache,cacheKey,job,hooked
local diagnostics={generation=0,totalScriptItems=0,classified=0,cacheHits=0,cacheMisses=0,overlayFallbacks=0,buildElapsedMs=0,modelElapsedMs=0,lastReason='not-prepared'}
local function key() return true end -- Tool purpose is always primary; weapon rows are secondary.
function C.invalidate(reason)
    cache,cacheKey=nil,nil;R.invalidate()
    if job then
        local pending=job.listeners;job=nil
        for _,listener in ipairs(pending) do if not listener.cancelled then listener.callback(nil,'invalidated') end end
    end
    diagnostics.lastReason=type(reason)=='string' and reason or 'session-start'
end
function C.ready() return cache and cacheKey==key() and cache or nil end
function C.diagnostics()
    local out={prepared=C.ready()~=nil,preparing=job~=nil}
    for k,v in pairs(diagnostics) do out[k]=v end
    return out
end
function C.modelBuilt(elapsed) diagnostics.modelElapsedMs=elapsed end
local function text(s) return type(s)=='string' and s~='' and s or nil end
function C.category(value) return R.resolve(value) end
function C.observed(container)
    local out={}
    local items=container:getItems()
    for i=0,items:size()-1 do
        local item=items:get(i)
        local category,_,legacy,semantic,historical,secondary=C.category(item)
        local script=item:getScriptItem()
        out[#out+1]={name=item:getDisplayName(),category=category,legacy=legacy,semantic=semantic,historical=historical,secondary=secondary,fullType=item:getFullType(),
            owner=script and script:getModID() or nil}
    end
    return out
end
-- Explicit developer call only: never invoked by rendering, events or normal logging.
-- Inspect this on both peers after scripts have loaded; static audits cannot prove parity.
function C.audit()
    local out={taxonomyVersion=R.version,counts={},fallbacks={},overrides={},ambiguous={},unresolved={},items={},excluded={}}
    local names,identities={},{}
    local scripts=getScriptManager():getAllItems()
    for i=0,scripts:size()-1 do
        local item=scripts:get(i)
        local eligible,excludedReason=R.catalogEligible(item)
        if not eligible then out.excluded[#out.excluded+1]={fullType=item:getFullName(),reason=excludedReason} end
        if not item:isHidden() and not item:getObsolete() then
            local category,reason,legacy,semantic,historical,secondary=R.resolve(item)
            local row={fullType=item:getFullName(),name=item:getDisplayName(),owner=item:getModID(),category=category,semanticPurpose=semantic,historicalPurpose=historical,compatibility=R.memberships(category,legacy,semantic,historical,secondary),reason=reason,catalogEligible=eligible}
            out.items[#out.items+1]=row
            out.counts[category]=(out.counts[category] or 0)+1
            if reason=='fallback' or reason=='vanilla-category' then out.fallbacks[#out.fallbacks+1]=row end
            if reason=='override' then out.overrides[#out.overrides+1]=row end
            if reason=='fallback' then out.unresolved[#out.unresolved+1]=row end
            if identities[row.fullType] then out.ambiguous[#out.ambiguous+1]={kind='duplicate-identity',item=row.fullType} end
            identities[row.fullType]=true
            local previous=names[row.name]
            if previous and (previous.category~=category or previous.owner~=row.owner) then
                out.ambiguous[#out.ambiguous+1]={kind='shared-display-name',first=previous,second=row}
            end
            names[row.name]=row
        end
    end
    table.sort(out.items,function(a,b) return a.fullType<b.fullType end)
    return out
end
function C.build(observed,baseEntries)
    local reusable=not observed and not baseEntries
    if reusable and C.ready() then diagnostics.cacheHits=diagnostics.cacheHits+1;return cache end
    local categories,names,groups,types,owners,coverage={},{},{},{},{},{}
    local function add(name,category,fullType,owner,legacy,semantic,historical,secondary)
        if not text(name) then return end
        names[name]=true
        if text(fullType) and (not types[name] or fullType<types[name]) then types[name]=fullType end
        if not text(category) then return end
        semantic=semantic or category;category=R.families.destination(category)
        categories[category]=true
        if secondary then categories[secondary]=true end
        local memberships=R.memberships(category,legacy,semantic,historical,secondary)
        for membership in pairs(memberships) do
            groups[membership]=groups[membership] or {};groups[membership][name]=true
            local key=membership..'\0'..name
            coverage[key]=coverage[key] or {}
            for rule in pairs(memberships) do coverage[key][rule]=true end
            local id=text(owner) or 'unknown:'
            if owners[key] and owners[key]~=id then owners[key]='unknown:' else owners[key]=id end
        end
    end
    local sourceEntries=baseEntries or {}
    if not baseEntries then
        local scripts=getScriptManager():getAllItems()
        for i=0,scripts:size()-1 do
            local item=scripts:get(i)
            if R.catalogEligible(item) then
                local category,_,legacy,semantic,historical,secondary=C.category(item)
                sourceEntries[#sourceEntries+1]={name=item:getDisplayName(),category=category,legacy=legacy,semantic=semantic,historical=historical,secondary=secondary,fullType=item:getFullName(),owner=item:getModID()}
            end
        end
    end
    local scriptNames={}
    for _,item in ipairs(sourceEntries) do
        add(item.name,item.category,item.fullType,item.owner,item.legacy,item.semantic,item.historical,item.secondary)
        if item.fullType then scriptNames[item.fullType]=item.name end
    end
    -- Configure Sorting edits script-name rules, including renamed vehicle keys.
    -- Keep runtime-only names only when no corresponding script is indexed.
    for _,item in ipairs(observed or {}) do add(scriptNames[item.fullType] or item.name,item.category,item.fullType,item.owner,item.legacy,item.semantic,item.historical,item.secondary) end
    local function keys(set) local a={};for k in pairs(set) do a[#a+1]=k end;table.sort(a);return a end
    local catList,nameList=keys(categories),keys(names)
    local entries={}
    for cat,set in pairs(groups) do
        entries[cat]={}
        for _,name in ipairs(keys(set)) do entries[cat][#entries[cat]+1]={name=name,fullType=types[name]} end
    end
    local api={entries=sourceEntries,isFamily=R.isCompatibility,categoryLabel=R.label,getCategories=function() return catList end,getItemNames=function() return nameList end,
        getItemsInCategory=function(cat) return entries[cat] or {} end,
        getItemFullType=function(name) return types[name] end,
        getScriptName=function(fullType) return scriptNames[fullType] end}
    api.covered=function(category,name,cats)
        for rule in pairs(coverage[(category or '')..'\0'..name] or {}) do if cats[rule] then return true end end
        return false
    end
    local labels={}
    api.owner=function(category,name)
        local id=owners[(category or '')..'\0'..name] or 'unknown:'
        if not labels[id] then
            if id=='pz-vanilla' then labels[id]=getText('UI_QMSS_Vanilla')
            elseif id=='unknown:' then labels[id]=getText('UI_QMSS_Unknown')
            else
                local info=getModInfoByID(id)
                labels[id]=info and info:getName() or id
            end
        end
        return id,labels[id]
    end
    if reusable then
        cache,cacheKey=api,key();diagnostics.generation=diagnostics.generation+1
        diagnostics.lastReason='synchronous-build'
    end
    return api
end
-- The stable script index is shared across selected containers. Server-observed
-- names that are already represented need no full index reconstruction.
function C.forObserved(base,observed)
    for _,item in ipairs(observed or {}) do
        local name=base.getScriptName and base.getScriptName(item.fullType) or item.name
        if not item.category or base.getItemFullType(name)~=item.fullType or not base.covered(item.category,name,{[item.category]=true}) then
            diagnostics.overlayFallbacks=diagnostics.overlayFallbacks+1
            return C.build(observed,base.entries)
        end
    end
    diagnostics.cacheHits=diagnostics.cacheHits+1
    return base
end
-- Client presentation preparation: native script reads are bounded per tick.
-- No container, world-state or server command is read/written by this job.
function C.step()
    if not job then return end
    local j=job;local started=getTimestampMs();local processed=0;local complete
    if j.key~=key() then
        j.key=key();j.index=0;j.entries={};j.started=started
        R.invalidate();diagnostics.lastReason='tool-policy-change'
    end
    local ok,err=pcall(function()
        while j.index<j.total and processed<64 do
            local item=j.scripts:get(j.index);j.index=j.index+1;processed=processed+1
            if R.catalogEligible(item) then
                local category,_,legacy,semantic,historical,secondary=C.category(item)
                diagnostics.classified=diagnostics.classified+1
                j.entries[#j.entries+1]={name=item:getDisplayName(),category=category,legacy=legacy,semantic=semantic,historical=historical,secondary=secondary,fullType=item:getFullName(),owner=item:getModID(),script=item,module=item:getModuleName()}
            end
            if getTimestampMs()-started>=4 then break end
        end
        if j.index==j.total then
            cache=C.build(nil,j.entries);cacheKey=j.key;job=nil
            diagnostics.generation=diagnostics.generation+1
            diagnostics.buildElapsedMs=getTimestampMs()-j.started
            diagnostics.lastReason='prepared'
            print('[B47ANCEDQuartermaster] catalog ready items='..#j.entries..' elapsedMs='..(getTimestampMs()-j.started))
            complete=true
        end
    end)
    if not ok then
        job=nil;print('[B47ANCEDQuartermaster] catalog preparation failed: '..tostring(err))
        for _,listener in ipairs(j.listeners) do if not listener.cancelled then listener.callback(nil,'failed') end end
        return
    end
    -- UI failures must retain their native Lua stack; never call the opening
    -- callback twice or mislabel them as another catalog preparation failure.
    if complete then for _,listener in ipairs(j.listeners) do if not listener.cancelled then listener.callback(cache) end end end
end
function C.prepare(callback)
    local ready=C.ready();if ready then diagnostics.cacheHits=diagnostics.cacheHits+1;callback(ready);return {done=true} end
    diagnostics.cacheMisses=diagnostics.cacheMisses+1
    if not Events or not Events.OnTick then callback(C.build());return {done=true} end
    if not hooked then
        Events.OnTick.Add(C.step)
        if Events.OnGameStart then Events.OnGameStart.Add(C.invalidate) end
        hooked=true
    end
    if not job then
        local scripts=getScriptManager():getAllItems()
        job={scripts=scripts,index=0,total=scripts:size(),entries={},listeners={},key=key(),started=getTimestampMs()}
        diagnostics.totalScriptItems=job.total
        diagnostics.lastReason=cache and 'tool-policy-change' or 'first-preparation'
    end
    local listener={callback=callback};job.listeners[#job.listeners+1]=listener
    listener.progress=function() return job and job.total>0 and job.index/job.total or 1 end
    listener.cancel=function() listener.cancelled=true end
    return listener
end
-- Pure destination ranking after authority has resolved live candidates/configurations.
-- The server supplies real inventory items, never a client-provided category.
function C.destination(item,candidates,presets,accepts)
    local category,_,legacy,semantic,historical,secondary=C.category(item)
    local name=item:getDisplayName()
    -- Picker rules use script display names; real instances may be renamed by
    -- vanilla (vehicle keys) or the player. Retain explicit instance-name rules.
    local script=item:getScriptItem()
    local scriptName=script and script:getDisplayName()
    local best,rank
    local matched=0
    for _,candidate in ipairs(candidates) do
        local config=candidate.effective or B47ANCEDQuartermaster.Schema.effective(candidate.config,presets or {})
        local explicit=config.items[name] or (scriptName and config.items[scriptName])
        local match=explicit and 4 or R.match(category,config.cats,legacy,semantic,historical,secondary)
        if match>0 and candidate.container~=item:getContainer() then matched=matched+1 end
        if match>0 and candidate.container~=item:getContainer() and (not accepts or accepts(candidate,item)) then
            local r={match,config.priority,-(candidate.distance or 0)}
            local wins=not best
            if best then
                for i=1,3 do if r[i]~=rank[i] then wins=r[i]>rank[i];break end end
                if r[1]==rank[1] and r[2]==rank[2] and r[3]==rank[3] then wins=tostring(candidate.key)<tostring(best.key) end
            end
            if wins then best,rank=candidate,r end
        end
    end
    return best,matched
end
return C
