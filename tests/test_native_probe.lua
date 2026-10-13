-- Offline diagnostic guard tests ONLY. No native transfer is simulated as a PASS.
dofile(TEST_ROOT..'/fixtures/containers.lua')
LootSorter=nil;B47ANCEDQuartermaster=nil
local f=CONTAINER_FIXTURE
local source,destination=f.a.containers[1],f.b.containers[1]
local item={id=71}
function item:getID() return self.id end
function item:getContainer() return source end
function item:getFullType() return 'Fixture.Probe' end
function item:isHumanCorpse() return false end
function item:isFavorite() return false end
local sourceItems,destinationItems={item},{}
local function configure(obj,container,items)
    function obj:getContainerIndex(value) return value==container and 0 or -1 end
    function container:getParent() return obj end
    function container:getItems() return f.list(items) end
    function container:getItemWithID(id) for _,value in ipairs(items) do if value:getID()==id then return value end end end
    function container:isRemoveItemAllowed() return true end
    function container:isItemAllowed() return true end
    function container:hasRoomFor() return true end
end
configure(f.a,source,sourceItems);configure(f.b,destination,destinationItems)
function f.player:isEquipped() return false end
local queued=0
local queue={queue={}}
ISTimedActionQueue={getTimedActionQueue=function() return queue end,add=function() queued=queued+1 end}
ISInventoryTransferUtil={newInventoryTransferAction=function(player,value,src,dst)
    assert(player==f.player and value==item and src==source and dst==destination)
    return {diagnostic=true}
end}
package.loaded['TimedActions/ISTimedActionQueue']=true
package.loaded['TimedActions/ISInventoryTransferUtil']=true
local P=dofile(TEST_ROOT..'/probes/NativeTransferProbe.lua')
assert(queued==0 and not LootSorter and not B47ANCEDQuartermaster,'probe auto-ran or required a mod')
local baseline=P.watch('ordinary',source,71,destination)
assert(baseline.sourceCount==1 and baseline.destinationCount==0)
P.transfer('ordinary',f.player);assert(queued==1)
assert(not pcall(P.transfer,'ordinary',f.player),'probe allowed retry')
assert(not pcall(P.watch,'self',source,71,source),'self probe accepted')
assert(not pcall(P.watch,'wrong-id',source,72,destination),'equivalent item lookup accepted')
P.watch('server',source,71,destination)
f.network(false,true);assert(not pcall(P.transfer,'server',f.player),'server entered client timed-action path')
f.network(false,false)
P.watch('busy',source,71,destination);queue.queue={true}
assert(not pcall(P.transfer,'busy',f.player),'batched actions accepted');queue.queue={}
P.watch('stale',source,71,destination)
f.b.sq.objects[1]=f.object(f.b.sq)
assert(not pcall(P.transfer,'stale',f.player),'probe rebound replacement')
assert(not P.snapshot('stale').destinationLive and queued==1)
print('PASS OFFLINE probe guard/snapshot checks only; native movement remains UNTESTED')
