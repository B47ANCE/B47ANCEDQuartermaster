require 'B47ANCEDQuartermaster/Schema'
require 'B47ANCEDQuartermaster/Targets'
local T=B47ANCEDQuartermaster.Targets
local V=require 'B47ANCEDQuartermaster/DiscoveryView'
local Trace=require 'B47ANCEDQuartermaster/SortTrace'
local B={sessions={}}
B47ANCEDQuartermaster.Bindings=B
local serial=0
local function id() serial=serial+1; return tostring(getTimestampMs())..':'..serial end
local function integer(n) return type(n)=='number' and n==math.floor(n) and math.abs(n)<10000000 end
local function near(player,position)
    -- Native character Z includes a within-floor offset; scopes use integer grid floors.
    return math.floor(player:getZ())==position.z and math.max(math.abs(player:getX()-position.x),math.abs(player:getY()-position.y))<=3
end
local function live(record,player)
    if record.revoked or not T.valid(record.target,player) then return false end
    local d=T.descriptor(record.target)
    local p=record.position
    -- An object-list index may move while the exact object remains. Never resolve it anew.
    return d.x==p.x and d.y==p.y and d.z==p.z
        and record.target.container:getType()==record.kind
end
function B.session(player,session)
    local s=B.sessions[player]
    if not s or type(session)~='string' or s.id~=session or getTimestampMs()-s.time>1800000 then return end
    local playerSquare=player.getCurrentSquare and player:getCurrentSquare()
    if s.customRoom then
        if not B47ANCEDQuartermaster.Rooms.resolve(player,s.customRoom,s.roomRevision) then return end
    elseif s.buildingDef then
        local current=playerSquare and playerSquare:getBuilding()
        if not current or current:getDef()~=s.buildingDef then return end
    else
        if not near(player,s.origin) then return end
        local sq=getCell():getGridSquare(s.origin.x,s.origin.y,s.origin.z)
        if sq~=s.square then return end
    end
    s.time=getTimestampMs()
    return s
end
function B.target(player,session,token)
    local s=B.session(player,session)
    local r=s and type(token)=='string' and s.records[token]
    if r and live(r,player) then
        if s.customRoom then
            local p=r.position
            if B47ANCEDQuartermaster.Rooms.contains(player,s.customRoom,s.roomRevision,p.x,p.y,p.z) then return r,s end
            return
        end
        local current=player.getCurrentSquare and player:getCurrentSquare()
        local proxy={obj={getSquare=function() return current or s.square end}}
        if T.inArea(proxy,r.target) then return r,s end
        local source=r.scopeSource and s.records[r.scopeSource]
        if source and live(source,player) and T.inArea(proxy,source.target) then
            for _,t in ipairs(T.siblings(source.target,player)) do
                if t.obj==r.target.obj and t.container==r.target.container and t.ci==r.target.ci then return r,s end
            end
        end
    end
end
function B.discover(player,args)
    local function reject(reason)
        print('[B47ANCEDQuartermaster] discovery rejected reason='..reason)
        return nil,'invalid'
    end
    if isClient() or not player or type(args)~='table' or args.target~=nil then return reject('request') end
    local pos=args.scope
    if type(pos)~='table' then return reject('scope') end
    for _,k in ipairs({'x','y','z'}) do if not integer(pos[k]) then return reject('coordinate') end end
    if not near(player,pos) then return reject('out-of-range playerZ='..tostring(player:getZ())..' scopeZ='..pos.z) end
    local square=getCell():getGridSquare(pos.x,pos.y,pos.z)
    if not square then return reject('unloaded-square') end
    local s
    if args.session then
        s=B.session(player,args.session)
        if not s or not s.customRoom and not s.buildingDef and s.square~=square then return reject('session') end
    else
        s={id=id(),origin={x=pos.x,y=pos.y,z=pos.z},square=square,records={},lookup={},time=getTimestampMs(),count=0}
    end
    local measured=Trace.begin()
    Trace.emit(args.trace,'DISCOVERY_BEGIN','scan',nil,nil,nil,nil,'no-destination-cache')
    local targets,building,stats
    if args.customRoom then
        local room,e=B47ANCEDQuartermaster.Rooms.resolve(player,args.customRoom,args.roomRevision)
        if not room then return nil,e end
        targets,e=B47ANCEDQuartermaster.Rooms.discover(player,args.customRoom,args.roomRevision,args.roomScan)
        if not targets then return nil,e end
        s.customRoom=room.id;s.roomRevision=room.revision
        stats={candidateObjects=0,eligibleContainers=#targets,loadedSquares=0}
    else
        s.customRoom=nil;s.roomRevision=nil;targets,building,stats=T.discoverAt(square,player)
    end
    Trace.emit(args.trace,'DISCOVERY_SCAN','complete',nil,nil,measured,stats and stats.candidateObjects,'miss')
    local handlesAt=Trace.begin()
    s.buildingDef=building and square:getBuilding():getDef() or nil
    s.square=square;s.origin={x=pos.x,y=pos.y,z=pos.z}
    local list,seen,overflow={},{},false
    local function register(t,source)
        if s.customRoom and not T.valid(t,player) then overflow=true;return end
        if seen[t.container] then return seen[t.container] end
        local record=s.lookup[t.container]
        if record and (record.target.obj~=t.obj or record.target.ci~=t.ci or not live(record,player)) then record=nil end
        if not record then
            if s.count>=4096 then overflow=true;return end -- reject rather than silently truncate discovery
            record={token=id(),target=t,position=T.descriptor(t),kind=t.container:getType(),scopeSource=source}
            s.records[record.token]=record;s.count=s.count+1
            s.lookup[t.container]=record
        end
        record.scopeSource=source or record.scopeSource
        seen[t.container]=record
        list[#list+1]=record
        return record
    end
    for _,t in ipairs(targets) do register(t) end
    for _,t in ipairs(targets) do
        local source=seen[t.container]
        if source then for _,sibling in ipairs(T.siblings(t,player)) do
            local p=T.descriptor(sibling)
            if not s.customRoom or B47ANCEDQuartermaster.Rooms.contains(player,s.customRoom,s.roomRevision,p.x,p.y,p.z) then register(sibling,source.token) end
        end end
    end
    if overflow then return reject('capacity') end
    local metadata={}
    for _,r in ipairs(list) do
        local d=T.descriptor(r.target)
        local state=B47ANCEDQuartermaster.Furniture and B47ANCEDQuartermaster.Furniture.state(r.target)
        local siblings={}
        for _,t in ipairs(T.siblings(r.target,player)) do
            local other=seen[t.container]
            if other then siblings[#siblings+1]=other.token end
        end
        metadata[#metadata+1]={token=r.token,x=d.x,y=d.y,z=d.z,index=d.index,ci=d.ci,
            kind=r.kind,name=r.target.container:getCustomName(),siblings=siblings,configMode=type(state)=='table' and state.mode or nil}
    end
    local assigned={}
    for _,meta in ipairs(metadata) do
        if not assigned[meta.token] and (#meta.siblings>1 or s.customRoom) and #meta.siblings<=64 then
            local verified=B47ANCEDQuartermaster.Furniture and B47ANCEDQuartermaster.Furniture.members(s.records[meta.token].target,player)
            local members={};for _,t in ipairs(verified or {}) do if seen[t.container] then members[#members+1]=seen[t.container] end end
            if #members>=1 and #(verified or {})>1 then
            table.sort(members,function(a,b) local x,y=a.position,b.position;for _,k in ipairs({'z','y','x','index','ci'}) do if x[k]~=y[k] then return x[k]<y[k] end end;return a.token<b.token end)
            local group=members[1].token
            local sections={}
            for ordinal,t in ipairs(verified) do local record=seen[t.container];if record then assigned[record.token]=group;sections[record.token]=ordinal end end
            for _,m in ipairs(metadata) do if assigned[m.token]==group then m.group=group;m.groupCount=#verified;m.groupSection=sections[m.token] end end
            end
        end
    end
    local viewInfo=V.metadata(s,metadata,player,building)
    s.viewTargets=metadata;s.viewInfo=viewInfo
    if args.invalidateView==true then s.appliedView={kind='room',room=false} end
    s.appliedView=s.appliedView or (viewInfo.currentRoom and {kind='room',room=viewInfo.currentRoom} or {kind='proximity',radius=viewInfo.maxRadius})
    if s.customRoom then s.appliedView={kind='customRoom',room=s.customRoom,revision=s.roomRevision} end
    if not s.customRoom and s.appliedView.kind=='customRoom' then s.appliedView={kind='proximity',radius=viewInfo.maxRadius} end
    B.sessions[player]=s
    Trace.emit(args.trace,'HANDLE_GENERATION','complete',nil,nil,handlesAt,#metadata)
    print('[B47ANCEDQuartermaster] discovery ready candidates='..(stats and stats.candidateObjects or 0)..' eligible='..(stats and stats.eligibleContainers or 0)..' physical='..#metadata..' loadedSquares='..(stats and stats.loadedSquares or 0)..' building='..tostring(building==true)..' floor='..pos.z)
    return {status='ok',taxonomyVersion=B47ANCEDQuartermaster.Categorizer.version,session=s.id,targets=metadata,building=building==true,discoveryStats=stats,viewInfo=viewInfo,view=s.appliedView}
end
function B.invalidate(obj)
    for _,s in pairs(B.sessions) do
        for _,r in pairs(s.records) do if r.target.obj==obj then r.revoked=true end end
    end
end
if Events and Events.OnObjectAboutToBeRemoved then Events.OnObjectAboutToBeRemoved.Add(B.invalidate) end
return B
