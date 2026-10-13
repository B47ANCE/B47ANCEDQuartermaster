dofile(TEST_ROOT..'/fixtures/containers.lua')
local Store=require 'B47ANCEDQuartermaster/Store'
local S=B47ANCEDQuartermaster.Schema
local M=require 'B47ANCEDQuartermaster/Migration'
local f=CONTAINER_FIXTURE
local target={obj=f.a,container=f.a:getContainerByIndex(0),ci=0}
local function envelope(priority)
    local config=S.empty();config.priority=priority
    local e=S.envelope(config,3,false)
    e.schemaVersion=1 -- actual pre-standalone format remains readable
    e.kind=target.container:getType();e.containerCount=f.a:getContainerCount()
    return {schemaVersion=1,containers={['0']=e}}
end
for _,id in ipairs(M.ids) do
    local legacy=envelope(17);f.a.md={[id]=legacy}
    local config,err,revision,imported=Store.load(target)
    assert(config.priority==17 and revision==3 and imported and not err)
    assert(f.a.md[S.key]==nil,'read mutated current data')
    config.priority=18
    local record={target=target,original=select(1,Store.load(target)),revision=revision}
    assert(Store.commit(record,config))
    assert(f.a.md[id]==legacy and legacy.containers['0'].config.priority==17,'legacy writeback')
    assert(f.a.md[S.key].containers['0'].config.priority==18)
    -- Reopen using a fresh record, save again and reload from persisted ModData.
    local reopened,_,rev=Store.load(target);assert(reopened.priority==18 and rev==4)
    record={target=target,original=reopened,revision=rev};config.priority=19
    assert(Store.commit(record,config));assert(select(1,Store.load(target)).priority==19)
    f.a.md[S.key]=envelope(0)
    assert(select(1,Store.load(target)).priority==0,'current empty config lost precedence')
    f.a.md[S.key]={schemaVersion=99}
    local invalid,reason=Store.load(target);assert(invalid==nil and reason=='schema')
end
SandboxVars={B47ANCEDSorting={ClassifyToolsByUse=false},QuartermasterSorting={ContainerRange=23}}
assert(M.option('ClassifyToolsByUse')==false and M.option('ContainerRange')==23)
SandboxVars.B47ANCEDQuartermaster={ContainerRange=10,ClassifyToolsByUse=true}
assert(M.option('ContainerRange')==10 and M.option('ClassifyToolsByUse')==true)
assert(B47ANCEDSorting==nil and QuartermasterSorting==nil and QuartermasterSimpleSorting==nil)
print('PASS identity migration: legacy read-only, canonical-only writes, current precedence, repeat Save/reload (offline)')
