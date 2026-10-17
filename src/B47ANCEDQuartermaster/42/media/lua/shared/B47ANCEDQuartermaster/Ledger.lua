require 'B47ANCEDQuartermaster/Targets'
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local Analysis=require 'B47ANCEDQuartermaster/ContentAnalysis'
local HistoricalAccess=require 'B47ANCEDQuartermaster/LedgerAccess'
local Options=require 'B47ANCEDQuartermaster/Migration'
local Policy=require 'B47ANCEDQuartermaster/LedgerPolicy'
local Live=require 'B47ANCEDQuartermaster/LedgerLive'
local Q=B47ANCEDQuartermaster
local L={jobs={},grants={},actors={},readers={},clientOffers={},recordCache={}};Q.Ledger=L
local function integer(n,min,max) return type(n)=='number' and n==n and n%1==0 and n>=min and n<=max end
local checked=setmetatable({},{__mode='k'})
local phases={ready=true,prepared=true,outputAdded=true,committed=true,rolledBack=true,uncertain=true}
local function journalValid(j)
 return type(j)=='table' and phases[j.phase] and type(j.snapshot)=='string' and #j.snapshot<=80 and type(j.owner)=='string' and #j.owner<=256
  and integer(j.input,-2147483648,2147483647) and (j.output==nil or integer(j.output,-2147483648,2147483647))
end
local function root()
 if isClient() then return end
 local r=ModData.getOrCreate('B47ANCEDQuartermasterLedger')
 if r.schema==nil then local empty=true;for _ in pairs(r) do empty=false end
  if empty then r.schema=1;r.count=0;r.snapshots={};r.media={};r.burns={};r.outputs={};r.burnCount=0 end
 end
 if r.schema~=1 or not integer(r.count,0,2048) or not integer(r.burnCount,0,8192) or type(r.snapshots)~='table' or type(r.media)~='table' or type(r.burns)~='table' or type(r.outputs)~='table' then return end
 return r
end
local function uuid() local id=getRandomUUID();return type(id)=='string' and #id<=80 and id or nil end
local function stamp() return getGameTime():getWorldAgeHours() end
local function option(name,min,max,default)
 local n=Options.option(name);if not integer(n,min,max) then return default end;return n
end
local function snapshot(r,item)
 local id=r and item and r.media[tostring(item:getID())];local s=id and r.snapshots[id]
 if type(s)~='table' or s.schema~=1 or type(s.scope)~='table' or type(s.entries)~='table' or type(s.order)~='table'
  or not integer(s.revision,0,9007199254740000) or not integer(s.totalRows,0,32768) or #s.order>4096 then return end
 if type(s.scope.label)~='string' or #s.scope.label>256 or type(s.id)~='string' or #s.id>80 or type(s.signature)~='string' or #s.signature>32768 or s.complete~=nil and type(s.complete)~='boolean' then return end
 if checked[s]~=s.revision then
  local names={};local rows=0;local count=0
  for n,key in pairs(s.order) do
   if not integer(n,1,#s.order) or type(key)~='string' or #key>256 or names[key] then return end
   names[key]=true;count=count+1
   local entry=s.entries[key];if type(entry)~='table' or type(entry.rows)~='table' or #entry.rows>4096 then return end
   if entry.key~=key or type(entry.position)~='table' or type(entry.room)~='string' or #entry.room>256 or type(entry.roomName)~='string' or #entry.roomName>256
    or type(entry.container)~='string' or #entry.container>256 or type(entry.recorded)~='number' or entry.recorded~=entry.recorded or math.abs(entry.recorded)==math.huge then return end
   for _,k in ipairs({'x','y','z','index','ci'}) do if not integer(entry.position[k],-10000000,10000000) then return end end
   rows=rows+#entry.rows
  end
  if count~=#s.order or rows~=s.totalRows then return end
  checked[s]=s.revision
 end
 return s
end
-- Server binding only; an item ModData snapshot label never proves ownership.
function L.snapshotFor(item)
 local r=root();if not r or not item then return end
 local input=r.outputs[tostring(item:getID())];local j=input and r.burns[input]
 if j and (not journalValid(j) or j.phase~='committed' or j.output~=item:getID()) then return end
 return snapshot(r,item)
end
local function allowed(actor,t)
 return Q.Targets.valid(t,actor) and Q.RoomAccess.can(actor,t,'inspect')
end
local function stationary(record)
 local d=Q.Targets.descriptor(record.target);local p=record.position
 return d.x==p.x and d.y==p.y and d.z==p.z and d.ci==p.ci
end
local function physical(t)
 local md=t.obj:getModData();local id=md.B47LedgerPhysical
 if type(id)~='string' or #id>80 then id=uuid();if not id then return end;md.B47LedgerPhysical=id;t.obj:transmitModData() end
 local d=Q.Targets.descriptor(t)
 return id..':'..d.x..':'..d.y..':'..d.z..':'..t.ci,d
end
local function liveJob(actor,j,full)
 if not j or j.actor~=actor or actor:isDead() or Media.owned(actor,j.paper:getID(),Media.sheet)~=j.paper then return false end
 if not full then return Scope.includes(j.scope,actor:getCurrentSquare()) end
 local scope=Scope.capture(actor,j.scope.kind)
 return scope and Scope.signature(scope)==j.signature
end
local function binding(actor,id)
 local item=Media.owned(actor,id)
 if not item or item:getFullType()~=Media.sheet and item:getFullType()~=Media.disc then return end
 local r=root();if not r then return item end
 local input=r.outputs[tostring(item:getID())];local journal=input and r.burns[input]
 if journal and not journalValid(journal) then return end
 if journal and journal.output~=item:getID() then return end
 if journal and journal.phase=='committed' and r.media[tostring(item:getID())]==nil then r.media[tostring(item:getID())]=journal.snapshot end
 if journal and journal.phase~='committed' then
  local who=Q.Personal.identity(actor)
  if journal.owner~=who then return end
  local recovered=Media.recover(actor,journal)
  if recovered then r.media[tostring(recovered:getID())]=journal.snapshot else return item,nil,r,'uncertain' end
 end
 return item,snapshot(r,item),r
end
local function emit(actor,command,data)
 if isServer() then sendServerCommand(actor,'B47ANCEDQuartermasterLedger',command,data)
 elseif L.clientResult and command=='result' then L.clientResult(actor,data) end
end
function L.cleanup(actor)
 local token=L.actors[actor];local g=token and L.grants[token]
 if g then L.grants[token]=nil end
 L.actors[actor]=nil;L.jobs[actor]=nil;L.readers[actor]=nil
end
local function retire(g,status,committed)
 L.grants[g.token]=nil;if L.actors[g.actor]==g.token then L.actors[g.actor]=nil end
 emit(g.actor,'result',{token=g.token,status=status});return committed==true or status=='ok'
end
local function writer(actor)
 local inv=actor:getInventory()
 return inv:containsTypeRecurse('Base.Pen') or inv:containsTypeRecurse('Base.Pencil')
end
local function insertEntry(s,key)
 local a=s.entries[key];local low,high=1,#s.order
 local function less(b)
  if a.roomName~=b.roomName then return a.roomName<b.roomName end
  if a.room~=b.room then return a.room<b.room end
  for _,k in ipairs({'z','y','x','ci'}) do if a.position[k]~=b.position[k] then return a.position[k]<b.position[k] end end
  return key<b.key
 end
 while low<=high do
  local mid=math.floor((low+high)/2);local other=s.entries[s.order[mid]]
  if less(other) then high=mid-1 else low=mid+1 end
 end
 table.insert(s.order,low,key)
end
local function prepareRows(g)
 local items=g.analysis.items;local refs=g.analysis.refs;local c=g.target.container
 if c:getItems():size()~=#refs then return end
 local rows,previous={},{}
 for n,item in ipairs(refs) do local row=items[n]
  if c:getItems():get(n-1)~=item or item:getContainer()~=c or item:getID()~=row.id or item:getFullType()~=row.fullType
   or item:getCount()~=row.quantity or item:getDisplayName()~=row.name or item:getActualWeight()~=row.actualWeight
   or item:getUnequippedWeight()~=row.weight or item:getCondition()~=row.condition or Q.Categorizer.resolve(item)~=row.category then return end
  local key=row.fullType..'\0'..row.name..'\0'..item:getCondition()..'\0'..row.weight
  local last=previous[key]
  local simple=not instanceof(item,'Food') and not instanceof(item,'DrainableComboItem') and not instanceof(item,'InventoryContainer') and not item:getFluidContainer() and not item:hasModData() and not item:getMediaData()
  if simple and last and last.item:CanStack(item) and item:CanStack(last.item) then last.row.quantity=last.row.quantity+row.quantity
  else
   local out={fullType=row.fullType,name=row.name,quantity=row.quantity,condition=item:getCondition(),category=row.category}
   rows[#rows+1]=out;previous[key]=simple and {row=out,item=item} or nil
  end
 end
 return rows
end
local function grant(actor,kind,seconds,fields)
 if L.actors[actor] then return {status='busy'} end
 local token=uuid();if not token or L.grants[token] then return {status='failed'} end
 local g=fields;g.actor=actor;g.kind=kind;g.seconds=seconds;g.token=token;g.created=getTimestampMs()
 L.grants[token]=g;L.actors[actor]=token
 local class=require 'B47ANCEDQuartermaster/LedgerAction'
 g.action=class.raw(actor,token,seconds)
 return {status='action',token=token,seconds=seconds,kind=kind,position=g.target and Q.Targets.descriptor(g.target)}
end
function L.grantShopping(actor,fields)
 if L.actors[actor] or L.jobs[actor] or Q.Movement.runs[actor] or Q.Movement.operations[actor] then return {status='busy'} end
 return grant(actor,'shoppingPaper',1,fields)
end
function L.reconstruct(actor,token)
 local g=L.grants[token]
 if isClient() or not g or g.actor~=actor or g.reconstructed or getTimestampMs()-g.created>10000 then return end
 g.reconstructed=true;return g.action
end
function L.valid(actor,token,action)
 local g=L.grants[token]
 if not g or g.actor~=actor or g.action~=action or actor:isDead() then return false end
 -- Confirmed work follows the native clock/modifiers; a guessed wall-time
 -- multiplier must not cancel a legitimate long writing action.
 if g.kind=='shoppingPaper' then return require('B47ANCEDQuartermaster/ShoppingLists').valid(actor,g) end
 if not Policy.enabled() then return false end
 if g.kind=='inspect' then return liveJob(actor,g.job) and allowed(actor,g.target) and stationary(g.record) and Scope.includes(g.job.scope,g.target.obj:getSquare()) and Media.reachable(actor,g.target.obj) and writer(actor) end
 return Media.owned(actor,g.paper:getID(),Media.sheet)==g.paper and Media.owned(actor,g.cd:getID())==g.cd
  and Media.usable(g.cd) and Media.computer(actor,g.computer,true) and g.snapshot.complete==true
  and not require('B47ANCEDQuartermaster/LedgerDrives').occupied(g.computer)
end
function L.start(actor,token,action)
 local g=L.grants[token]
 if not g or not g.reconstructed or g.started or not L.valid(actor,token,action) then return false end
 if g.kind=='inspect' and not liveJob(actor,g.job,true) then return false end
 g.started=true
 if isServer() then
  g.challenge=uuid();if not g.challenge then return false end
  emit(actor,'challenge',{token=token,challenge=g.challenge})
 else g.confirmed=getSpecificPlayer(actor:getPlayerNum())==actor end
 return true
end
function L.stop(actor,token)
 local g=L.grants[token];if g and g.actor==actor then return retire(g,'cancelled') end
end
function L.complete(actor,token,action)
 local g=L.grants[token]
 if not g or not g.started or not g.confirmed or not L.valid(actor,token,action) then if g then return retire(g,'denied') end;return false end
 if g.kind=='inspect' and not liveJob(actor,g.job,true) then return retire(g,'LedgerScopeChanged') end
 if isServer() then
  local ok,progress=pcall(function() return action.netAction:getProgress() end)
  if not ok or type(progress)~='number' or progress~=progress or progress==math.huge or progress<1 then return retire(g,'denied') end
 end
 if g.kind=='shoppingPaper' then
  local status=require('B47ANCEDQuartermaster/ShoppingLists').complete(actor,g)
  return retire(g,status,status=='ShoppingPaperCreated' or status=='ShoppingPaperSyncPending')
 end
 if g.kind=='inspect' then
  local rows=prepareRows(g);if not rows then g.job.prepared=nil;return retire(g,'LedgerChanged') end
  local s=g.job.snapshot;local key=g.record.key;local previous=s.entries[key]
  local total=s.totalRows-(previous and #previous.rows or 0)+#rows
  if total>32768 then return retire(g,'tooLarge') end
  local rid,name=Scope.room(actor,g.target.obj:getSquare());if not rid then return retire(g,'denied') end
  local label=g.target.container:getCustomName();if type(label)~='string' or #label==0 or #label>256 then label=g.target.container:getType() end
  s.entries[key]={key=key,position=g.record.position,room=rid,roomName=name,container=label,recorded=stamp(),rows=rows}
  if previous and (previous.room~=rid or previous.roomName~=name) then
   for n,v in ipairs(s.order) do if v==key then table.remove(s.order,n);break end end
   insertEntry(s,key)
  elseif not previous then insertEntry(s,key) end
  s.totalRows=total;s.revision=s.revision+1;s.baseCharged=true;g.job.recorded[key]=true;g.job.cache[key]=g.target.container;g.job.prepared=nil
 else
  local r=root();if not r then return retire(g,'schema') end
  local id=tostring(g.cd:getID());local prior=r.burns[id]
  if prior and not journalValid(prior) then return retire(g,'schema') end
  if prior and prior.phase~='rolledBack' then return retire(g,'uncertain') end
  if not prior then if r.burnCount>=8192 then return retire(g,'tooLarge') end;r.burnCount=r.burnCount+1 end
  if prior and prior.output then r.outputs[tostring(prior.output)]=nil end
  local journal={snapshot=g.snapshot.id,input=g.cd:getID(),owner=Q.Personal.identity(actor),phase='ready'};r.burns[id]=journal
  local output,status=Media.convert(actor,g.cd,g.snapshot.id,journal,function(outputID) r.outputs[tostring(outputID)]=id end)
  if journal.output then r.outputs[tostring(journal.output)]=id end
  if output then r.media[tostring(output:getID())]=g.snapshot.id end
  return retire(g,status,output~=nil)
 end
 return retire(g,'ok')
end
local function begin(actor,args)
 if select(2,Q.RoomAccess.service())=='unknown' then return {status='RoomPermissionUnavailable'} end
 local r=root();local paper=Media.owned(actor,args.item,Media.sheet)
 if not r or not paper or not writer(actor) then return {status='invalid'} end
 local count=0;for _ in pairs(L.jobs) do count=count+1 end;for _ in pairs(L.grants) do count=count+1 end
 if not L.jobs[actor] and count>=16 then return {status='busy'} end
 local scope=Scope.capture(actor,args.scopeKind);local cursor=scope and Scope.cursor(scope)
 if not cursor then return {status='LedgerScopeUnavailable'} end
 local s=snapshot(r,paper)
 if r.media[tostring(paper:getID())] and not s then return {status='schema'} end
 if s and s.signature~=Scope.signature(scope) then return {status='LedgerScopeChanged'} end
 -- Renew into a new generation. Existing CDs retain their original snapshot.
 if not s or s.complete then
  if r.count>=2048 then return {status='tooLarge'} end
  local id=uuid();if not id or r.snapshots[id] then return {status='failed'} end
  s={schema=1,id=id,scope={kind=scope.kind,label=scope.label},signature=Scope.signature(scope),revision=0,entries={},order={},totalRows=0,began=stamp()}
  r.count=r.count+1;r.snapshots[id]=s;r.media[tostring(paper:getID())]=id;Media.stamp(actor,paper,id)
 end
 L.recordCache[s.id]=L.recordCache[s.id] or setmetatable({},{__mode='v'})
 L.jobs[actor]={actor=actor,paper=paper,snapshot=s,scope=scope,signature=Scope.signature(scope),cursor=cursor,records={},seen={},keys={},cache=L.recordCache[s.id],recorded={},time=getTimestampMs()}
 return {status='ok'}
end
local function discover(actor,j)
 for _=1,32 do
  if j.objects then
   if j.oi>=j.objects:size() then j.objects=nil
   else local obj=j.objects:get(j.oi);local count=obj:getContainerCount()
    if count>100 then return 'tooLarge' end
    if j.ci>=count then j.oi=j.oi+1;j.ci=0
    else local t=not instanceof(obj,'IsoWorldInventoryObject') and Q.Targets.make(obj,j.ci,actor);j.ci=j.ci+1
     if t and not j.seen[t.container] then
      j.seen[t.container]=true
      if not allowed(actor,t) then j.limited=true
      else local key,d=physical(t);if not key then return 'failed' end
       if j.keys[key] and j.keys[key]~=t.container then
        t.obj:getModData().B47LedgerPhysical=nil;key,d=physical(t);if not key or j.keys[key] then return 'failed' end
       end
       j.keys[key]=t.container
       if #j.records>=4096 then return 'tooLarge' end
       local token=uuid();if not token then return 'failed' end
       local record={key=key,position=d,target=t,token=token};j.records[#j.records+1]=record
       -- Persisted object ModData is not an authority proof. After restart or
       -- object replacement, re-inspect instead of trusting a copied marker.
       if j.snapshot.entries[key] and j.cache[key]==t.container then j.recorded[key]=true end
      end
     end
    end
   end
  else
   local p=j.cursor.next();if not p then j.done=true;return end
   local sq=getCell():getGridSquare(p.x,p.y,p.z)
   if not sq then
    local cell=getCell();if not cell.getChunkForGridSquare or not cell:getChunkForGridSquare(p.x,p.y,p.z) then j.unloaded=true end
   elseif Scope.includes(j.scope,sq) and not j.cursor.visited[sq] then
    j.cursor.visited[sq]=true
    -- Denied tiles contribute no hidden container identities or counts.
    if (not isServer() or SafeHouse and SafeHouse.isSafehouseAllowLoot(sq,actor)) and Q.RoomAccess.can(actor,{obj={getSquare=function() return sq end}},'inspect') and Q.RoomAccess.can(actor,{obj={getSquare=function() return sq end}},'discover') then
     j.objects=sq:getObjects();j.oi=0;j.ci=0;if j.objects:size()>512 then return 'tooLarge' end
    else j.limited=true end
   end
  end
 end
end
local function nextWork(actor,j,args)
 if select(2,Q.RoomAccess.service())=='unknown' then return {status='RoomPermissionUnavailable'} end
 if not liveJob(actor,j,true) then L.cleanup(actor);return {status='LedgerScopeChanged'} end
 j.time=getTimestampMs()
 if L.actors[actor] then return {status='busy'} end
 if not j.done then local failed=discover(actor,j);if failed then return {status=failed} end end
 local record
 if args.target then for _,v in ipairs(j.records) do if v.token==args.target then record=v;break end end
 else
  local best
  for _,v in ipairs(j.records) do if not j.recorded[v.key] then
   local p=v.position;local d=(p.x-actor:getX())^2+(p.y-actor:getY())^2+100*(p.z-math.floor(actor:getZ()))^2
   if not best or d<best then record,best=v,d end
  end end
 end
 if record and not j.recorded[record.key] then
  if not allowed(actor,record.target) or not stationary(record) then j.limited=true;return {status='denied'} end
  if not Media.reachable(actor,record.target.obj) then return {status='walk',target=record.token,position=record.position} end
  if not j.prepared or j.prepared.record~=record then
   local job,e=Analysis.begin(record.target.container,actor,function() return allowed(actor,record.target) and Media.reachable(actor,record.target.obj) end)
   if not job then return {status=e or 'failed'} end
   j.prepared={record=record,analysis=job}
  end
  local data,status=j.prepared.analysis.step()
  if status=='waiting' then return {status='waiting',target=record.token} end
  if status~='done' then j.prepared=nil;return {status='LedgerChanged'} end
  local g={target=record.target,record=record,analysis=j.prepared.analysis,job=j}
  local rows=prepareRows(g);if not rows then j.prepared=nil;return {status='LedgerChanged'} end
  local seconds=(j.snapshot.baseCharged and 0 or option('LedgerBaseSeconds',0,120,10))+option('LedgerContainerSeconds',1,15,5)+#rows*option('LedgerEntrySeconds',1,5,1)
  return grant(actor,'inspect',seconds,g)
 end
 if not j.done then return {status='waiting'} end
 local current={};for _,v in ipairs(j.records) do if allowed(actor,v.target) and stationary(v) then current[v.key]=true else j.limited=true end end
 local stale=false;for _,key in ipairs(j.snapshot.order) do if not current[key] then stale=true end end
 local s=j.snapshot;s.complete=not j.unloaded and not stale;s.status=j.unloaded and 'LedgerPartial' or stale and 'LedgerStale' or j.limited and 'LedgerLimited' or 'LedgerComplete';s.finished=stamp();s.revision=s.revision+1
 Media.stamp(actor,j.paper,s.id,s.complete)
 L.jobs[actor]=nil;return {status='done',summary=s.status}
end
local function read(actor,args)
 local item,s,unused,error,computer
 if args.drive~=nil then
  item,s,computer=require('B47ANCEDQuartermaster/LedgerDrives').read(actor,args.drive,Media.object(args.computer))
 else item,s,unused,error=binding(actor,args.item) end
 if not item then return {status='invalid'} end
 if not s then return {status=error or 'LedgerBlank'} end
 local digital=item:getFullType()==Media.disc
 computer=computer or digital and Media.object(args.computer)
 if digital and not Media.computer(actor,computer,true) then return {status='LedgerPower'} end
 if type(args.query or '')~='string' or #(args.query or '')>128 or type(args.room or '')~='string' or #(args.room or '')>128 then return {status='invalid'} end
 if not digital and ((args.query or '')~='' or (args.room or '')~='') then return {status='invalid'} end
 if args.entry~=nil or args.row~=nil or args.cursor~=nil and (type(args.cursor)~='string' or #args.cursor>80) then return {status='invalid'} end
 local query=string.lower(args.query or '');local room=args.room or '';local session=L.readers[actor]
 local computerScope=digital and Scope.capture({getCurrentSquare=function() return computer:getSquare() end},'building')
 local localComputer=digital and Policy.computerMatches(s,computerScope and Scope.signature(computerScope)) or false
 local fresh=Policy.fresh(s,localComputer);local live=(not digital or localComputer) and Policy.live(s,localComputer) or false
 local policy=Policy.mode()..':'..Policy.days()..':'..tostring(Policy.manualComputer())..':'..tostring(fresh)..':'..tostring(live)
 if not session or session.item~=item:getID() or session.snapshot~=s.id or session.revision~=s.revision or session.query~=query or session.room~=room or session.policy~=policy or live and session.liveServedAt and getTimestampMs()-session.liveServedAt>=5000 then
  local tag=uuid();if not tag then return {status='failed'} end
  session={item=item:getID(),snapshot=s.id,revision=s.revision,publicRevision=tag,query=query,room=room,tokens={},positions={},count=0,policy=policy,liveEntries={},liveRows=0};L.readers[actor]=session
 end
 session.time=getTimestampMs()
 local position=args.cursor and session.tokens[args.cursor]
 if args.cursor and not position then return {status='LedgerPageChanged'} end
 local entry,index=position and position.entry or 1,position and position.row or 1
 local result={status='ok',rows={},rooms={},scope=s.scope.label,began=s.began,finished=s.finished,summary=s.status or 'LedgerPartial',revision=session.publicRevision,digital=digital,live=live,fresh=fresh,expires=Policy.deadline(s,localComputer),computerOffsite=digital and not localComputer or false}
 local rooms={};local bytes=0;local permissions={};local disclosure={}
 local function addRoom(e)
  if not rooms[e.room] and #result.rooms<16 then
   local size=#e.room+#e.roomName+64
   if bytes+size<=16000 then bytes=bytes+size;rooms[e.room]=true;result.rooms[#result.rooms+1]={id=e.room,name=e.roomName} end
  end
 end
 for _=1,128 do
  local key=s.order[entry];if not key then session.liveServedAt=session.liveServedAt or getTimestampMs();return result end
  local e=s.entries[key]
  if type(e)~='table' or type(e.rows)~='table' or #e.rows>4096 or type(e.position)~='table' or type(e.room)~='string' or #e.room>256 or type(e.roomName)~='string' or #e.roomName>256 or type(e.container)~='string' or #e.container>256 then return {status='schema'} end
  for _,k in ipairs({'x','y','z'}) do if not integer(e.position[k],-10000000,10000000) then return {status='schema'} end end
  if permissions[key]==nil then permissions[key]=HistoricalAccess.read(actor,e,disclosure) end
  if permissions[key] and live then
   local projected,why=Live.entry(actor,session,e)
   if not projected then
    if why=='waiting' then return {status='waiting',summary='LedgerLiveLoading'} end
    -- Never label old/private/unloaded contents as current statistics.
    return {status=why or 'LedgerLiveUnavailable'}
   end
   e=projected
  end
  if not permissions[key] then entry=entry+1;index=1;result.redacted=true
  elseif #e.rows==0 then
   addRoom(e)
   if query=='' and (not digital or args.room==nil or args.room=='' or args.room==e.room) then
    bytes=bytes+#e.roomName+#e.container+300;if bytes>16000 then break end
    result.rows[#result.rows+1]={name=getText('UI_QMSS_LedgerEmpty'),fullType='',quantity=0,condition='',room=e.roomName,roomID=e.room,container=e.container,position=e.position,recorded=e.recorded,empty=true}
   end
   entry=entry+1;index=1;if #result.rows>=32 then break end
  elseif index>#e.rows then entry=entry+1;index=1
  else local row=e.rows[index];index=index+1
   if type(row)~='table' or type(row.fullType)~='string' or #row.fullType>256 or type(row.name)~='string' or #row.name>512 or not integer(row.quantity,1,4096000000) then return {status='schema'} end
   addRoom(e)
   if (not digital or args.room==nil or args.room=='' or args.room==e.room) and (query=='' or string.find(string.lower(row.name..' '..row.fullType),query,1,true)) then
    bytes=bytes+#row.name+#row.fullType+#e.roomName+#e.container+256
    if bytes>16000 then index=index-1;break end
    result.rows[#result.rows+1]={name=row.name,fullType=row.fullType,quantity=row.quantity,condition=row.condition,room=e.roomName,roomID=e.room,container=e.container,position=e.position,recorded=e.recorded}
    if #result.rows>=32 then break end
   end
  end
 end
 if entry<=#s.order then
  local key=entry..':'..index;local token=session.positions[key]
  if not token then
   if session.count>=2048 then return {status='tooLarge'} end
   token=uuid();if not token or session.tokens[token] then return {status='failed'} end
   session.tokens[token]={entry=entry,row=index};session.positions[key]=token;session.count=session.count+1
  end
  result.cursor=token
 end
 session.liveServedAt=session.liveServedAt or getTimestampMs()
 return result
end
function L.handle(actor,command,args)
 if isClient() or not actor or actor:isDead() or type(args)~='table' then return {status='invalid'} end
 local confirming=command=='ledgerConfirm' and type(args.token)=='string' and L.grants[args.token]
 if not Policy.enabled() and command~='ledgerCancel' and not (confirming and confirming.actor==actor and confirming.kind=='shoppingPaper') then return {status='LedgerDisabled'} end
 if command=='ledgerDriveList' or command=='ledgerDriveMount' or command=='ledgerDriveEject' then return require('B47ANCEDQuartermaster/LedgerDrives').handle(actor,command,args) end
 if command=='ledgerBegin' then if L.actors[actor] or Q.Movement.runs[actor] or Q.Movement.operations[actor] then return {status='busy'} end;return begin(actor,args) end
 if command=='ledgerNext' then local j=L.jobs[actor];return j and nextWork(actor,j,args) or {status='invalid'} end
 if command=='ledgerCancel' then if args.token and L.actors[actor]~=args.token then return {status='invalid'} end;L.cleanup(actor);return {status='ok'} end
 if command=='ledgerRead' then return read(actor,args) end
 if command=='ledgerConfirm' then
  local g=type(args.token)=='string' and L.grants[args.token]
  if not g or g.actor~=actor or not g.started or g.challenge~=args.challenge or getTimestampMs()-g.created>10000 then return {status='denied'} end
  local ok,p=pcall(function() return g.action.netAction:getProgress() end)
  if not ok or type(p)~='number' or p~=p or p<0 or p>=1 then return {status='denied'} end
  g.confirmed=true;return {status='ok'}
 end
 if command=='ledgerBurn' then
  if L.actors[actor] or L.jobs[actor] or Q.Movement.runs[actor] or Q.Movement.operations[actor] then return {status='busy'} end
  local paper,s,r=binding(actor,args.item);local cd=Media.owned(actor,args.cd);local computer=Media.object(args.computer)
  if not paper or paper:getFullType()~=Media.sheet or not s or not s.complete or not Media.cd(cd) or not Media.usable(cd) then return {status='invalid'} end
  if not Media.computer(actor,computer,true) then return {status='LedgerPower'} end
  local drives=require 'B47ANCEDQuartermaster/LedgerDrives'
  if drives.occupied(computer) then return {status='LedgerDriveOccupied'} end
  if drives.busy(computer) then return {status='busy'} end
  local journal=r.burns[tostring(cd:getID())]
  if journal and not journalValid(journal) then return {status='schema'} end
  if journal and journal.phase~='rolledBack' then
   if journal.owner~=Q.Personal.identity(actor) then return {status='uncertain'} end
   Media.recover(actor,journal)
   if journal.phase~='rolledBack' then return {status='uncertain'} end
  end
  return grant(actor,'burn',option('LedgerBurnSeconds',10,120,30),{paper=paper,snapshot=s,cd=cd,computer=computer})
 end
 return {status='invalid'}
end
local nextTick=0
function L.tick()
 if isClient() then return end
 if getTimestampMs()<nextTick then return end;nextTick=getTimestampMs()+250
 if not Policy.enabled() then
  -- Preserve records, but disabled inspection jobs must not occupy the actor
  -- and block the independent physical Shopping List creation workflow.
  for actor in pairs(L.jobs) do
   local g=L.actors[actor] and L.grants[L.actors[actor]]
   if g and g.kind~='shoppingPaper' then retire(g,'LedgerDisabled') end
   L.jobs[actor]=nil
  end
  for actor in pairs(L.readers) do L.readers[actor]=nil end
 end
 local active=false;for _ in pairs(L.jobs) do active=true;break end;for _ in pairs(L.grants) do active=true;break end;for _ in pairs(L.readers) do active=true;break end;if not active then return end
 local connected
 if isServer() then connected={};local players=getOnlinePlayers();for n=0,players:size()-1 do connected[players:get(n)]=true end end
 local liveJobs={}
 for actor,reader in pairs(L.readers) do
  if reader.livePending and not actor:isDead() and (not connected or connected[actor]) then liveJobs[#liveJobs+1]={actor=actor,reader=reader} end
 end
 table.sort(liveJobs,function(a,b) return (a.reader.liveStepAt or 0)<(b.reader.liveStepAt or 0) end)
 local deadline=getTimestampMs()+4
 for n=1,math.min(4,#liveJobs) do
  local j=liveJobs[n];j.reader.liveStepAt=getTimestampMs()
  if Policy.enabled() then Live.step(j.actor,j.reader) else j.reader.livePending=nil end
  if getTimestampMs()>=deadline then break end
 end
 for actor,reader in pairs(L.readers) do if actor:isDead() or connected and not connected[actor] or getTimestampMs()-reader.time>1800000 then L.readers[actor]=nil end end
 for actor,j in pairs(L.jobs) do if actor:isDead() or connected and not connected[actor] or not L.actors[actor] and getTimestampMs()-j.time>1800000 then L.cleanup(actor) end end
 for _,g in pairs(L.grants) do
  if g.actor:isDead() or connected and not connected[g.actor] or not g.confirmed and getTimestampMs()-g.created>10000 or g.started and not L.valid(g.actor,g.token,g.action) then retire(g,'cancelled') end
 end
end
if Events and Events.OnTick then Events.OnTick.Add(L.tick) end
return L
