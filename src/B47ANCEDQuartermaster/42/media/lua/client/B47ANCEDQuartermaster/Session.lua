require 'B47ANCEDQuartermaster/Authority'
require 'B47ANCEDQuartermaster/Configuration'
local Q=B47ANCEDQuartermaster
local C,T,A=Q.Configuration,Q.Targets,B47ANCEDQuartermaster.Authority
Q.Authority=A
local S={}; S.__index=S; Q.Session=S
function S.new(origin,playerNum)
    return setmetatable({origin=origin,originPosition=origin and T.descriptor(origin),playerNum=playerNum,records={},nextKey=0,whole=false,targets={},discoveryState='uninitialized',discoveryGeneration=0},S)
end
function S:parent(token)
 local child=self.records[token];if not child then return end
 local key='whole:'..token;local r=self.records[key]
 if not r then
  local target={};for k,v in pairs(child.target) do target[k]=v end;target.whole=true
  self.nextKey=self.nextKey+1;r={key=self.nextKey,token=token,target=target,introduced={}};self.records[key]=r
 end
 local target={};for k,v in pairs(child.target) do target[k]=v end;target.whole=true;r.target=target
 return r
end
function S:setView(view,done)
 if self.busy then return end
 self.busy=true;self:request('viewSelect',{view=view},function(result) self.busy=false;if result.status=='ok' then self.view=result.view end;done(result.status) end)
end
function S:customize()
 local r=self.selected;if not r or r.configMode~='inherit' then return false end
 r.pendingAction='custom';return true
end
function S:reset()
 local r=self.selected;if not r or not r.parentConfig then return false end
 r.pendingAction='reset';r.working=C.clone(r.parentConfig);return true
end
function S:scope()
    local player=getSpecificPlayer(self.playerNum)
    local square=player and player.getCurrentSquare and player:getCurrentSquare()
    if square then return {x=square:getX(),y=square:getY(),z=square:getZ()} end
    return self.originPosition
end
function S:record(t)
    if type(t)=='string' then return self.records[t] end
    if t and t.token then return self.records[t.whole and 'whole:'..t.token or t.token] end
    if not isClient() and t then
        for _,r in ipairs(self.targets) do
            if r.target.obj==t.obj and r.target.container==t.container and r.target.ci==t.ci then return r end
        end
    end
end
function S:request(command,args,done)
    args.session=self.id
    A.request(self.playerNum,command,args,function(result)
        if not self.closed then done(result) end
    end)
end
function S:acceptDiscovery(result)
    self.id=result.session;self.targets={};self.building=result.building
    Q.DiscoveryView.accept(self,result)
    for _,meta in ipairs(result.targets) do
        local r=self.records[meta.token]
        if not r then
            self.nextKey=self.nextKey+1
            r={key=self.nextKey,token=meta.token,introduced={}}
            self.records[r.token]=r
        end
        local target=A.localTarget(self.playerNum,self.id,meta.token) or {}
        for k,v in pairs(meta) do target[k]=v end
        target.whole=false;r.target=target
        self.targets[#self.targets+1]=r
    end
    local selectedPresent=false
    for _,r in ipairs(self.targets) do if r==self.selected then selectedPresent=true;break end end
    if not selectedPresent then self.selected=nil end
    self.discoveryStats=result.discoveryStats or {}
    self.discoveryState='ready'
end
function S:open(done)
    local valid,reason=self.origin and T.valid(self.origin,getSpecificPlayer(self.playerNum))
    if self.origin and not valid and not self.invalidatedRoom then
        print('[B47ANCEDQuartermaster] opening rejected reason='..tostring(reason))
        self.discoveryState='failed';done('invalid');return
    end
    self.busy=true
    self.discoveryState='discovering';self.discoveryGeneration=self.discoveryGeneration+1
    local generation=self.discoveryGeneration
    local d=self:scope()
    if not d then self.busy=false;self.discoveryState='failed';done('invalid');return end
    self:request('discover',{scope={x=d.x,y=d.y,z=d.z},invalidateView=self.invalidatedRoom},function(result)
        if generation~=self.discoveryGeneration then return end
        self.busy=false
        if result.status~='ok' then self.discoveryState='failed';done(result.status);return end
        if result.taxonomyVersion~=Q.Categorizer.version then self.discoveryState='failed';done('TaxonomyPeerMismatch');return end
        self:acceptDiscovery(result);self.invalidatedRoom=nil
        -- Only SP shares exact engine references. MP must explicitly select a returned handle.
        local original=self:record(self.origin)
        if original then self:select(original.target,done) else done('ChooseTarget') end
    end)
end
function S:refresh(done)
    if self.busy or not self.id then return end
    self.busy=true
    self.discoveryState='discovering';self.discoveryGeneration=self.discoveryGeneration+1
    local generation=self.discoveryGeneration
    local d=self:scope()
    self:request('discover',{scope={x=d.x,y=d.y,z=d.z}},function(result)
        if generation~=self.discoveryGeneration then return end
        if result.status=='invalid' then
            self.busy=false;self.id=nil;self.selected=nil;self.targets={};self.invalidatedRoom=true
            self:open(done);return
        end
        if result.status=='ok' and result.taxonomyVersion~=Q.Categorizer.version then result.status='TaxonomyPeerMismatch' end
        if result.status=='ok' then
            self:acceptDiscovery(result)
            if self.selected then
                self:load(self.selected.target,nil,function(_,status) self.busy=false;done(status) end)
                return
            end
        end
        self.busy=false
        if result.status~='ok' then self.discoveryState='failed' end
        done(result.status)
    end)
end
function S:load(t,source,done)
    local r=self:record(t)
    if not r then done(nil,'invalid');return end
    self:request('load',{token=r.token,whole=r.target.whole},function(result)
        if result.status=='ok' then
            if not r.working or not self:dirty(r) then
                r.original,r.working=C.clone(result.config),C.clone(result.config)
                r.revision=result.revision;r.configMode=result.mode;r.groupActive=result.groupActive;r.parentConfig=result.parentConfig
            end
            r.configMode=result.mode;r.groupActive=result.groupActive;r.parentConfig=result.parentConfig
            r.contents=result.contents or {};r.observed=result.observed or {};r.catalog=nil
        end
        done(result.status=='ok' and r or nil,result.status)
    end)
end
function S:select(t,done)
    if self.busy or not self.id then return end
    self.busy=true
    self:load(t,nil,function(r,status)
        self.busy=false
        if r then self.selected=r;self.whole=false end
        done(status)
    end)
end
function S:dirty(r) return r.pendingAction~=nil or r.working and not C.equal(r.original,r.working) or false end
function S:applyWhole(done)
    if self.busy or not self.whole or not self.selected then return end
    local source=self.selected
    local targets=source.target.siblings or {}
    if #targets<2 then done('invalid');return end
    local config=C.clone(source.working)
    local records,index={},0
    self.busy=true
    local function advance()
        index=index+1
        if index>#targets then
            for _,r in ipairs(records) do r.working=C.clone(config);r.introduced={};if r.configMode=='inherit' then r.pendingAction='custom' end end
            self.busy=false;done('ok');return
        end
        self:load(targets[index],source.token,function(r,status)
            if not r then self.busy=false;done(status);return end
            records[#records+1]=r;advance()
        end)
    end
    advance()
end
function S:save(done)
    if self.busy or not self.id then return end
    local dirty={}
    for _,r in pairs(self.records) do if self:dirty(r) then dirty[#dirty+1]=r end end
    table.sort(dirty,function(a,b) return a.key<b.key end)
    local index,failures=0,0
    self.busy=true
    local function advance()
        index=index+1
        local r=dirty[index]
        if not r then self.busy=false;done(failures==0 and 'ok' or 'partial');return end
        local sent=C.clone(r.working)
        local grouped=r.target.whole or r.configMode=='inherit' or r.configMode=='custom'
        self:request(grouped and 'groupChange' or 'commit',{token=r.token,config=sent,revision=r.revision,whole=r.target.whole,action=r.pendingAction,confirm=r.pendingAction=='reset' or r.pendingAction=='remove',view=self.view},function(result)
            if result.status=='ok' then r.original=C.clone(result.config);r.working=C.clone(result.config);r.revision=result.revision;r.error=nil;r.pendingAction=nil;r.configMode=result.mode or r.configMode
                if grouped then for _,other in pairs(self.records) do if other~=r and other.configMode=='inherit' and not self:dirty(other) then other.working=nil;other.original=nil end end end
            else r.error=result.status;failures=failures+1 end
            advance()
        end)
    end
    advance()
end
function S:close()
    if self.busy and self.discoveryState~='discovering' then return false end
    if self.id then self:request('close',{},function() end) end
    self.closed=true;self.discoveryGeneration=self.discoveryGeneration+1;return true
end
return S
