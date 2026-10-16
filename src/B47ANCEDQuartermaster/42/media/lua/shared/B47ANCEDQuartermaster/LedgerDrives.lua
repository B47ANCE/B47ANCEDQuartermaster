-- Server-owned read-only bindings to REAL CDs in existing adjacent storage.
-- Never creates a computer inventory, moves a CD or copies private contents.
local D={offers=setmetatable({},{__mode='k'})};B47ANCEDQuartermaster.LedgerDrives=D
local Q=B47ANCEDQuartermaster;local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local function uuid() local s=getRandomUUID();return type(s)=='string' and #s<=80 and s or nil end
local function pos(obj,ci) local s=obj:getSquare();return {x=s:getX(),y=s:getY(),z=s:getZ(),index=obj:getObjectIndex(),ci=ci} end
local function same(a,b) return a.x==b.x and a.y==b.y and a.z==b.z and a.index==b.index end
local function integer(n) return type(n)=='number' and n==n and n%1==0 and math.abs(n)<=10000000 end
local function position(p) if type(p)~='table' then return false end;for _,k in ipairs({'x','y','z','index'}) do if not integer(p[k]) then return false end end;return true end
local cached,index
local function root()
 if isClient() then return end
 local r=ModData.getOrCreate('B47ANCEDQuartermasterLedgerDrives')
 if r.schema==nil then local empty=true;for _ in pairs(r) do empty=false end;if empty then r.schema=1;r.records={};r.revision=0 end end
 if r.schema~=1 or type(r.records)~='table' or type(r.revision)~='number' or r.revision%1~=0 or r.revision<0 or r.revision>9007199254740000 then return end
 if not cached or cached.r~=r or cached.rev~=r.revision then
  local n=0;local byBuilding,byGrid,byItem={},{},{}
  for id,v in pairs(r.records) do
   n=n+1;if n>256 or type(id)~='string' or #id>80 or type(v)~='table' or not position(v.computer) or not position(v.source)
    or not integer(v.source.ci) or v.source.ci<0 or v.source.ci>99 or type(v.storage)~='string' or #v.storage>80
    or type(v.item)~='number' or v.item%1~=0 or v.item< -2147483648 or v.item>2147483647 or type(v.building)~='string' or #v.building>32768 then return end
   local bucket=math.floor(v.computer.x/32)..':'..math.floor(v.computer.y/32)
   byBuilding[v.building]=byBuilding[v.building] or {};byBuilding[v.building][#byBuilding[v.building]+1]=id
   byGrid[bucket]=byGrid[bucket] or {};byGrid[bucket][#byGrid[bucket]+1]=id
   byItem[v.item]=byItem[v.item] or {};byItem[v.item][#byItem[v.item]+1]=id
  end
  cached={r=r,rev=r.revision};index={building=byBuilding,grid=byGrid,item=byItem,count=n}
 end
 return r
end
local function beside(computer,target)
 local a,b=computer:getSquare(),target.obj:getSquare()
 return a:getZ()==b:getZ() and math.max(math.abs(a:getX()-b:getX()),math.abs(a:getY()-b:getY()))<=1
end
local function accessible(actor,t)
 return t and Q.Targets.valid(t,actor) and Q.RoomAccess.can(actor,t,'inspect')
end
local function lookup(actor,id,computer,near)
 local r=root();local v=r and type(id)=='string' and #id<=80 and r.records[id]
 if not v then return end
 computer=computer or Media.object(v.computer)
 if not computer or not same(pos(computer),v.computer) or computer:getModData().B47LedgerDrive~=id or not Media.computer(actor,computer,near) then return end
 local obj=Media.object(v.source);local t=obj and Q.Targets.make(obj,v.source.ci,actor)
 if not accessible(actor,t) or not beside(computer,t) or obj:getModData().B47LedgerDriveStorage~=v.storage then return end
 local item=t.container:getItemWithID(v.item)
 if not item or item:getFullType()~=Media.disc or item:getContainer()~=t.container then return end
 local s=require('B47ANCEDQuartermaster/Ledger').snapshotFor(item)
 if s then return item,s,computer end
end
function D.read(actor,id,computer) return lookup(actor,id,computer,true) end
function D.occupied(computer)
 local r=root();if not r then return true end
 local id=computer and computer:getModData().B47LedgerDrive
 return id and r.records[id] and same(pos(computer),r.records[id].computer) or false
end
function D.busy(computer)
 for _,g in pairs(Q.Ledger and Q.Ledger.grants or {}) do if g.computer==computer then return true end end
 return false
end
function D.protected(item)
 local r=root();if not r then return true end -- preserve unknown/future bound media
 for _,id in ipairs(index.item[item:getID()] or {}) do
  local v=r.records[id];local computer=Media.object(v.computer);local source=Media.object(v.source)
  local c=source and source:getContainerByIndex(v.source.ci)
  if computer and computer:getModData().B47LedgerDrive==id and source and source:getModData().B47LedgerDriveStorage==v.storage
   and c and item:getContainer()==c and c:getItemWithID(v.item)==item and beside(computer,{obj=source}) then return true end
 end
 return false
end
function D.candidates(building,sq,range)
 local r=root();if not r then return nil end
 local out,seen={},{}
 local function add(ids) for _,id in ipairs(ids or {}) do if not seen[id] then seen[id]=true;out[#out+1]=id end end end
 if building then add(index.building[building]) end
 for x=math.floor((sq:getX()-range)/32),math.floor((sq:getX()+range)/32) do
  for y=math.floor((sq:getY()-range)/32),math.floor((sq:getY()+range)/32) do add(index.grid[x..':'..y]) end
 end
 return out
end
function D.provider(actor,id) return lookup(actor,id,nil,false) end
local function description(item,id)
 local name=item:getDisplayName();if type(name)~='string' or #name>512 then name=item:getFullType() end
 return {id=item:getID(),name=name:gsub('%c',' '),fullType=item:getFullType(),drive=id}
end
function D.handle(actor,command,args)
 if isClient() or not actor or actor:isDead() then return {status='invalid'} end
 local computer=Media.object(args.computer)
 if not Media.computer(actor,computer,true) then return {status='LedgerPower'} end
 if (command=='ledgerDriveMount' or command=='ledgerDriveEject') and not Q.RoomAccess.can(actor,{obj=computer},'configure') then return {status='RoomAccessDenied'} end
 local r=root();if not r then return {status='schema'} end
 local id=computer:getModData().B47LedgerDrive
 if type(id)~='string' or not r.records[id] or not same(pos(computer),r.records[id].computer) then id=nil end
 if command=='ledgerDriveEject' then
  if id and r.records[id] and args.drive~=id then return {status='LedgerDriveChanged'} end
  if type(id)=='string' and r.records[id] and same(pos(computer),r.records[id].computer) then r.records[id]=nil;r.revision=r.revision+1 end
  D.offers[actor]=nil;return {status='ok'}
 end
 if command=='ledgerDriveMount' then
  if D.busy(computer) then return {status='busy'} end
  local offer=D.offers[actor];local v=offer and offer.choices[args.token]
  if not v or offer.computer~=computer or getTimestampMs()-offer.at>30000 then return {status='LedgerDriveChanged'} end
  if id and r.records[id] then
   local current=lookup(actor,id,computer,true);if current==v.item then return {status='ok',mounted=description(current,id)} end
   return {status='LedgerDriveOccupied'}
  end
  if not accessible(actor,v.target) or not beside(computer,v.target) or v.target.container:getItemWithID(v.item:getID())~=v.item
   or v.item:getContainer()~=v.target.container or not require('B47ANCEDQuartermaster/Ledger').snapshotFor(v.item) then return {status='LedgerDriveChanged'} end
  if index.count>=256 then return {status='tooLarge'} end
  id=uuid();local storage=v.target.obj:getModData().B47LedgerDriveStorage
  if not storage then storage=uuid();v.target.obj:getModData().B47LedgerDriveStorage=storage;v.target.obj:transmitModData() end
  if not id or r.records[id] or type(storage)~='string' or #storage>80 then return {status='failed'} end
  local scope=Scope.capture({getCurrentSquare=function() return computer:getSquare() end},'building')
  r.records[id]={computer=pos(computer),source=pos(v.target.obj,v.target.ci),storage=storage,item=v.item:getID(),building=scope and scope.key or ''}
  computer:getModData().B47LedgerDrive=id;computer:transmitModData();r.revision=r.revision+1;D.offers[actor]=nil
  return {status='ok',mounted=description(v.item,id)}
 end
 if command~='ledgerDriveList' then return {status='invalid'} end
 local offer={computer=computer,choices={},at=getTimestampMs()};D.offers[actor]=offer
 local result={status='ok',choices={}};local mounted=id and lookup(actor,id,computer,true)
 if id and r.records[id] and same(pos(computer),r.records[id].computer) then result.slot=id end
 if mounted then result.mounted=description(mounted,id) elseif id and r.records[id] then result.occupied=true end
 local origin=computer:getSquare();local visits,compartments,objectCount=0,0,0
 for x=origin:getX()-1,origin:getX()+1 do for y=origin:getY()-1,origin:getY()+1 do
  local sq=getCell():getGridSquare(x,y,origin:getZ());local objects=sq and sq:getObjects()
  if objects then
   if objects:size()>512 then return {status='tooLarge'} end
   for n=0,objects:size()-1 do local obj=objects:get(n)
    objectCount=objectCount+1;if objectCount>1024 then return {status='tooLarge'} end
    if obj:getContainerCount()>100 then return {status='tooLarge'} end
    for ci=0,obj:getContainerCount()-1 do
     compartments=compartments+1;if compartments>512 then return {status='tooLarge'} end
     local t=not instanceof(obj,'IsoWorldInventoryObject') and Q.Targets.make(obj,ci,actor)
     if accessible(actor,t) then
      local items=t.container:getItems()
      for i=0,items:size()-1 do
       visits=visits+1;if visits>4096 then return {status='tooLarge'} end
       local item=items:get(i)
       if item:getFullType()==Media.disc and item:getContainer()==t.container and require('B47ANCEDQuartermaster/Ledger').snapshotFor(item) then
        if #result.choices>=32 then return {status='tooLarge'} end
        local token=uuid();if not token or offer.choices[token] then return {status='failed'} end
        offer.choices[token]={target=t,item=item};local row=description(item);row.token=token;result.choices[#result.choices+1]=row
       end
      end
     end
    end
   end
  end
 end end
 return result
end
return D
