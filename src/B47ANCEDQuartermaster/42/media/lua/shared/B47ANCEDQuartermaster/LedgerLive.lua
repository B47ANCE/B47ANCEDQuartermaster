-- Ephemeral, actor-private projections of recorded compartments. Never writes
-- historical media or inventories, discovers hidden storage, or grants access.
local Analysis=require 'B47ANCEDQuartermaster/ContentAnalysis'
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local Q=B47ANCEDQuartermaster
local V={}
local function resolve(actor,e)
 local t=Q.Targets.resolve(e.position,actor)
 if not t or not Q.RoomAccess.can(actor,t,'inspect') then return end
 local p=Q.Targets.descriptor(t);local id=t.obj:getModData().B47LedgerPhysical
 if type(id)~='string' or id..':'..p.x..':'..p.y..':'..p.z..':'..t.ci~=e.key then return end
 return t
end
function V.entry(actor,session,e)
 local t=resolve(actor,e);if not t then return nil,'LedgerLiveUnavailable' end
 local cache=session.liveEntries[e.key]
 if cache then
  if cache.target.obj~=t.obj or cache.target.container~=t.container then return nil,'LedgerLiveUnavailable' end
  return cache.entry
 end
 if session.liveFailure then return nil,session.liveFailure end
 if not session.livePending then
  local active=0;for _,reader in pairs(Q.Ledger.readers) do if reader.livePending then active=active+1 end end
  for _,reader in pairs(Q.Ledger.stockReaders or {}) do if reader.livePending then active=active+1 end end
  if active>=16 then return nil,'busy' end
  local function valid()
   local current=resolve(actor,e)
   return not actor:isDead() and current and current.obj==t.obj and current.container==t.container
  end
  local job,why=Analysis.begin(t.container,actor,valid)
  if not job then return nil,why=='tooLarge' and 'tooLarge' or 'LedgerLiveUnavailable' end
  session.livePending={job=job,target=t,entry=e,valid=valid,index=1,rows={},previous={}}
 end
 return nil,'waiting'
end
function V.step(actor,session)
 local p=session.livePending;if not p then return end
 if not p.valid() then session.livePending=nil;session.liveFailure='LedgerLiveUnavailable';return end
 if not p.ready then
  local _,status=p.job.step()
  if status=='waiting' then return end
  if status~='done' then session.livePending=nil;session.liveFailure='LedgerChanged';return end
  p.ready=true
 end
 local items,refs=p.job.items,p.job.refs
 if p.target.container:getItems():size()~=#refs then session.liveFailure='LedgerChanged';session.livePending=nil;return end
 for _=1,64 do
  local item=refs[p.index];local row=items[p.index]
  if not item then
   local rid,name=Scope.room(actor,p.target.obj:getSquare())
   if not rid then session.liveFailure='RoomPermissionUnavailable';session.livePending=nil;return end
   session.liveRows=session.liveRows+#p.rows
   if session.liveRows>32768 then session.liveFailure='tooLarge';session.livePending=nil;return end
   local label=p.target.container:getCustomName()
   if type(label)~='string' or #label==0 or #label>256 then label=p.target.container:getType() end
   local entry={rows=p.rows,position=p.entry.position,room=rid,roomName=name,container=label,recorded=getGameTime():getWorldAgeHours()}
   session.liveEntries[p.entry.key]={entry=entry,target=p.target};session.livePending=nil;return
  end
  if p.target.container:getItems():get(p.index-1)~=item or item:getContainer()~=p.target.container
   or item:getID()~=row.id or item:getCount()~=row.quantity or item:getDisplayName()~=row.name
   or item:getFullType()~=row.fullType or item:getCondition()~=row.condition or item:getUnequippedWeight()~=row.weight
   or item:getActualWeight()~=row.actualWeight or Q.Categorizer.resolve(item)~=row.category then
   session.liveFailure='LedgerChanged';session.livePending=nil;return
  end
  local key=row.fullType..'\0'..row.name..'\0'..row.condition..'\0'..row.weight
  local last=p.previous[key]
  local simple=not instanceof(item,'Food') and not instanceof(item,'DrainableComboItem') and not instanceof(item,'InventoryContainer')
   and not item:getFluidContainer() and not item:hasModData() and not item:getMediaData()
  if simple and last and last.item:CanStack(item) and item:CanStack(last.item) then last.row.quantity=last.row.quantity+row.quantity
  else
   local out={fullType=row.fullType,name=row.name,quantity=row.quantity,condition=row.condition,category=row.category}
   p.rows[#p.rows+1]=out;p.previous[key]=simple and {row=out,item=item} or nil
  end
  p.index=p.index+1
 end
end
return V
