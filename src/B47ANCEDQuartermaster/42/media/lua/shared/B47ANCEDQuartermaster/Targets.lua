B47ANCEDQuartermaster = B47ANCEDQuartermaster or {}
local T = {}
local Migration=require 'B47ANCEDQuartermaster/Migration'
B47ANCEDQuartermaster.Targets = T

-- Character Z includes a within-floor offset; square Z is an integer grid floor.
function T.sameFloor(player,square)
    if not player or not square then return false end
    local z=player:getZ()
    return type(z)=='number' and z==z and z~=math.huge and z~=-math.huge and math.floor(z)==square:getZ()
end

function T.options()
    local r = tonumber(Migration.option('ContainerRange')) or 10
    if r ~= r or r == math.huge or r == -math.huge then r = 10 end
    local whole=Migration.option('WholeBuilding');if whole==nil then whole=true end
    return math.max(1, math.min(30, math.floor(r))), whole == true
end

function T.valid(t, player)
    if not t or not t.obj or not t.container or type(t.ci) ~= 'number' then return false,'target-shape' end
    local ok, valid, reason = pcall(function()
        local sq = t.obj:getSquare()
        if not sq or getCell():getGridSquare(sq:getX(),sq:getY(),sq:getZ()) ~= sq then return false,'unloaded-square' end
        local found = false
        local objects = sq:getObjects()
        for i=0,objects:size()-1 do if objects:get(i) == t.obj then found = true; break end end
        if not found then return false,'object-removed' end
        if t.obj:getContainerByIndex(t.ci) ~= t.container then return false,'container-replaced' end
        if t.container:getType() == 'floor' or t.container:getContainingItem() then return false,'unsupported-container' end
        if instanceof(t.obj,'IsoThumpable') and t.obj:isLockedToCharacter(player) then return false,'locked' end
        if (isClient() or isServer()) and (not SafeHouse or not SafeHouse.isSafehouseAllowLoot(sq,player)) then return false,'safehouse' end
        return true
    end)
    if not ok then return false,'native-validation-error' end
    return valid == true,reason
end

function T.make(obj,ci,player)
    if not obj then return end
    local ok,t = pcall(function()
        return {obj=obj,ci=ci,container=obj:getContainerByIndex(ci)}
    end)
    if ok and T.valid(t,player) then return t end
end

function T.descriptor(t)
    local sq=t.obj:getSquare()
    return {x=sq:getX(),y=sq:getY(),z=sq:getZ(),index=t.obj:getObjectIndex(),ci=t.ci}
end

function T.resolve(d,player)
    if type(d)~='table' then return end
    for _,k in ipairs({'x','y','z','index','ci'}) do
        local n=d[k]
        if type(n)~='number' or n~=n or math.abs(n)>10000000 or n~=math.floor(n) then return end
    end
    if d.index<0 or d.ci<0 or d.ci>100 then return end
    local sq=getCell():getGridSquare(d.x,d.y,d.z)
    if not sq then return end
    local objects=sq:getObjects()
    if d.index>=objects:size() then return end
    return T.make(objects:get(d.index),d.ci,player)
end

local function appendObject(out,seen,obj,player)
    for ci=0,(obj:getContainerCount() or 0)-1 do
        local t=T.make(obj,ci,player)
        if t and not seen[t.container] then seen[t.container]=true; out[#out+1]=t end
    end
end

function T.inArea(origin,target)
    local a,b=origin.obj:getSquare(),target.obj:getSquare()
    if not a or not b then return false end
    local r,whole=T.options()
    local building=whole and a:getBuilding()
    if building then
        local other=b:getBuilding()
        return other and other:getDef()==building:getDef() or false
    end
    return a:getZ()==b:getZ() and math.max(math.abs(a:getX()-b:getX()),math.abs(a:getY()-b:getY()))<=r
end

function T.discoverAt(square,player,origin)
    local out,seen={},{}
    if not square then return out end
    if origin and T.valid(origin,player) then out[1],seen[origin.container]=origin,true end
    local stats={candidateObjects=0,eligibleContainers=0,loadedSquares=0}
    local function visit(sq)
        if not sq then return end
        stats.loadedSquares=stats.loadedSquares+1
        local objects=sq:getObjects()
        for i=0,objects:size()-1 do stats.candidateObjects=stats.candidateObjects+1;appendObject(out,seen,objects:get(i),player) end
    end
    local r,whole=T.options()
    local building=whole and square:getBuilding()
    if building then
        -- RoomDef bounds are native building membership, independent of Tile
        -- Radius and of which IsoRoom instances have already been assembled.
        -- getGridSquare never loads a missing square; validate live identity.
        local rooms=building:getDef():getRooms()
        local visited={}
        for i=0,rooms:size()-1 do
            local def=rooms:get(i)
            if def.getX and def.getX2 and def.getY and def.getY2 and def.getZ then
                for y=def:getY(),def:getY2()-1 do for x=def:getX(),def:getX2()-1 do
                    local sq=getCell():getGridSquare(x,y,def:getZ())
                    local actual=sq and sq:getBuilding()
                    if actual and actual:getDef()==building:getDef() and not visited[sq] then
                        visited[sq]=true;visit(sq)
                    end
                end end
            else
                -- Older host fixtures and engines without RoomDef bounds.
                local room=def:getIsoRoom()
                if room then
                    local squares=room:getSquares()
                    for j=0,squares:size()-1 do
                        local sq=squares:get(j)
                        local actual=sq and sq:getBuilding()
                        if actual and actual:getDef()==building:getDef() and not visited[sq] then
                            visited[sq]=true;visit(sq)
                        end
                    end
                end
            end
        end
    else
        for dy=-r,r do for dx=-r,r do
            visit(getCell():getGridSquare(square:getX()+dx,square:getY()+dy,square:getZ()))
        end end
    end
    local rest={}
    local first=origin and 2 or 1
    for i=first,#out do rest[#rest+1]=out[i] end
    table.sort(rest,function(a,b)
        local x,y=T.descriptor(a),T.descriptor(b)
        for _,k in ipairs({'z','y','x','index','ci'}) do if x[k]~=y[k] then return x[k]<y[k] end end
        return false
    end)
    for i,t in ipairs(rest) do out[i+first-1]=t end
    stats.eligibleContainers=#out
    return out,building~=nil and building~=false,stats
end

function T.discover(origin,player)
    if not T.valid(origin,player) then return {} end
    return T.discoverAt(origin.obj:getSquare(),player,origin)
end

-- Physical Dibs reach is already limited to two horizontal tiles. Do not scan
-- the sandbox's entire building merely to inspect one inventory context menu.
function T.reachableAt(square,player)
    local out,seen={},{}
    if not square then return out end
    for y=-2,2 do for x=-2,2 do
        local sq=getCell():getGridSquare(square:getX()+x,square:getY()+y,square:getZ())
        if sq then local objects=sq:getObjects()
            for i=0,objects:size()-1 do appendObject(out,seen,objects:get(i),player) end
        end
    end end
    return out
end

function T.siblings(source,player)
    if not T.valid(source,player) then return {} end
    local out,seen={source},{[source.container]=true}
    appendObject(out,seen,source.obj,player) -- multiple compartments are one verified physical object
    local ok=pcall(function()
        local grid=source.obj:getSpriteGrid()
        if not grid or not grid:validate() then return end
        local sq,sprite=source.obj:getSquare(),source.obj:getSprite()
        local ax=sq:getX()-grid:getSpriteGridPosX(sprite)
        local ay=sq:getY()-grid:getSpriteGridPosY(sprite)
        local az=sq:getZ()-grid:getSpriteGridPosZ(sprite)
        local objects=ArrayList.new()
        source.obj:getSpriteGridObjectsIncludingSelf(objects)
        local members,cells={},{}
        for i=0,objects:size()-1 do
            local obj=objects:get(i)
            local s,sp=obj:getSquare(),obj:getSprite()
            if s and obj:getSpriteGrid()==grid and s:getX()-grid:getSpriteGridPosX(sp)==ax
                and s:getY()-grid:getSpriteGridPosY(sp)==ay and s:getZ()-grid:getSpriteGridPosZ(sp)==az then
                local key=s:getX()..','..s:getY()..','..s:getZ()
                if cells[key] then error('Ambiguous sprite-grid cell') end
                cells[key]=true; members[#members+1]=obj
            end
        end
        for _,obj in ipairs(members) do appendObject(out,seen,obj,player) end
    end)
    if not ok then return {source} end
    return out
end

return T
