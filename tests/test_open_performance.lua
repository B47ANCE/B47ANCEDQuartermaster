-- Bounded host work and request order, not a native frame-time benchmark.
dofile(TEST_ROOT..'/test_ui_framework.lua')
local Q=B47ANCEDQuartermaster;local C=Q.Catalog;local f=CONTAINER_FIXTURE
local total,reads,scans=2048,0,0
local manager=getScriptManager();local callback
local handlers,loadHook={}
Events={OnTick={Add=function(fn) handlers[#handlers+1]=fn end},OnGameStart={Add=function() end},
 LoadGridsquare={Add=function(fn) loadHook=fn end}}
getScriptManager=function() return {FindItem=manager.FindItem,getAllItems=function()
 scans=scans+1
 return {size=function() return total end,get=function(_,i)
  reads=reads+1
  return {getDisplayName=function() return 'Example '..i end,getFullName=function() return 'Fixture.Example'..i end,getModuleName=function() return 'Fixture' end,getModID=function() return 'pz-vanilla' end,getItemType=function() return 'normal' end,getDisplayCategory=function() return 'Food' end,isHidden=function() return false end,getObsolete=function() return false end}
 end}
end} end
C.invalidate();Q.ItemCatalog.invalidate()
local loading=Q.openPicker(f.a,0,0)
assert(loading and not loading.qmsSession and reads==0,'open synchronously scanned registry or discovered before preparation')
assert(Q.openPicker(f.a,0,0)==loading,'double open started another job')
handlers[1]();assert(reads<=64 and not loading.closed,'catalog work exceeded per-tick item bound')
while not loading.closed do local before=reads;handlers[1]();assert(reads-before<=64,'unbounded scan tick') end
local p=Q.picker
assert(p.qmsSession.selected and reads==total and scans==1)
assert(loadHook,'loaded-square invalidation was not registered')
local initialTargets=#p.qmsSession.targets
local newSquare=f.square(2,2,0)
f.object(newSquare)
loadHook(newSquare)
assert(p.discoveryDirty and #p.qmsSession.targets==initialTargets,'load event rebuilt synchronously')
p:update()
assert(#p.qmsSession.targets==initialTargets+1 and not p.discoveryDirty and p.qmsSession.discoveryState=='ready',
 'same open window did not receive completed discovery')
p.qmsSession.busy=true
Q.ShoppingUI.switch(p,'shopping')
assert(p.shoppingUI.mode=='shopping','Shopping was coupled to physical discovery')
p.qmsSession.busy=false
Q.ShoppingUI.switch(p,'sorting')
assert(#p.shoppingUI.catalogList.items==0,'opening populated hidden full catalog')
assert(#Q.ItemCatalog.catalog()==total and scans==1,'Shopping rescanned already prepared scripts')
local firstStats=C.diagnostics()
local prepared=C.ready();local known=prepared.entries[1]
assert(C.forObserved(prepared,{{name=known.name,category=known.category,fullType=known.fullType}})==prepared,'known observed row rebuilt full index')
p:closePicker();p=Q.openPicker(f.a,0,0);assert(p.qmsSession and scans==1 and reads==total,'second open repeated registry scan')
local secondStats=C.diagnostics()
assert(secondStats.generation==firstStats.generation and secondStats.cacheMisses==firstStats.cacheMisses and secondStats.cacheHits>firstStats.cacheHits,'repeat open rebuilt stable catalog')
assert(secondStats.totalScriptItems==total and secondStats.classified>=total and secondStats.prepared and secondStats.buildElapsedMs>=0)
p:closePicker()
-- Failed initial discovery can retry, with no client-authored writes.
local request=Q.Authority.request;local first=true
Q.Authority.request=function(player,command,args,done)
 if command=='discover' and first then first=false;done({status='timeout'}) else request(player,command,args,done) end
end
p=Q.openPicker(f.a,0,0)
assert(not p.qmsSession.id and p.qmsSession.discoveryState=='failed' and not p.qmsSession.busy and p.title:find('UI_QMSS_ContainersFailed',1,true))
p.containerUI.buttons.refresh.onclick(p)
assert(p.qmsSession.id and p.qmsSession.selected,'Refresh could not recover failed initial discovery')
p:closePicker();Q.Authority.request=request
-- Cancellation leaves preparation read-only and never opens a hidden editor.
C.invalidate();local previous=Q.picker
loading=Q.openPicker(f.a,0,0);loading:close()
for i=1,40 do handlers[1]() end
assert(Q.picker==previous and loading.closed,'cancelled preparation opened editor')
print('PASS OFFLINE menu preparation: bounded native reads, visible loading/cancel, no network before ready, one registry scan, reused Shopping cache, no hidden full catalog, second-open reuse and initial discovery retry')
