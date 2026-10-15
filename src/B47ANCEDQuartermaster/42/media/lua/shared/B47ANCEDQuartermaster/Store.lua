require 'B47ANCEDQuartermaster/Schema'
require 'B47ANCEDQuartermaster/Categorizer'
local S=B47ANCEDQuartermaster.Schema
local SortingData=require 'B47ANCEDQuartermaster/SortingData'
local Store={}
B47ANCEDQuartermaster.Store=Store
function Store.rawLoad(target)
    local md=target.obj:getModData()
    local root,migrationError=SortingData.object(target.obj)
    if migrationError then return nil,migrationError end
    local native=root and root.containers[tostring(target.ci)]
    if native~=nil and (type(native)~='table' or native.kind~=target.container:getType() or native.containerCount~=target.obj:getContainerCount()) then return nil,'invalid' end
    local config,err,imported,revision=S.read(native)
    return config,err,revision,false,native
end
function Store.rawCommit(record,config)
    if isClient() or not S.valid(config) then return nil,'invalid' end
    local current,err,revision,imported,native=Store.rawLoad(record.target)
    if not current then return nil,err end
    if not B47ANCEDQuartermaster.Categorizer.validRules(config.cats,current.cats) then return nil,'invalid' end
    if not record.original or revision~=record.revision or not S.equal(current,record.original) then return nil,'conflict' end
    for _,link in pairs(config.presets) do if not S.ownedLink(link) then return nil,'invalid' end end
    local envelope=S.envelope(config,revision+1)
    if not envelope then return nil,'invalid' end
    envelope.kind=record.target.container:getType()
    envelope.containerCount=record.target.obj:getContainerCount()
    local md=record.target.obj:getModData()
    local old=md[S.key]
    local root={schemaVersion=1,containers={}}
    if old then for k,v in pairs(old.containers) do root.containers[k]=v end end
    root.containers[tostring(record.target.ci)]=envelope
    -- Commit a complete owned envelope. Never touch LSBox fields or foreign registries.
    md[S.key]=root
    record.target.obj:transmitModData()
    record.original=S.copy(config);record.revision=revision+1
    return S.copy(config)
end
local F=require 'B47ANCEDQuartermaster/Furniture'
function Store.routing(target,player)
 if isClient() or not B47ANCEDQuartermaster.RoomAccess.can(player,target,'deposit') then return nil,'RoomAccessDenied' end
 return F.load(target,player,false,false,'deposit')
end
function Store.configuration(target,player)
 if not B47ANCEDQuartermaster.RoomAccess.can(player,target,'configure') then return nil,'RoomAccessDenied' end
 return F.load(target,player,false,false,'configure')
end
function Store.load(target,player)
 if player and not B47ANCEDQuartermaster.RoomAccess.can(player,target,'inspect') then return nil,'RoomAccessDenied' end
 return F.load(target,player,false)
end
function Store.commit(record,config,player)
 if not B47ANCEDQuartermaster.RoomAccess.can(player,record.target,'configure') then return nil,'RoomAccessDenied' end
 if F.state(record.target) then return nil,'invalid' end
 return Store.rawCommit(record,config)
end
return Store
