-- Read-only multi-disc/base views. Every contribution has a powered physical
-- host, a real adjacent ledger CD and current native/Rooms inspection access.
require 'B47ANCEDQuartermaster/Schema'
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local Policy=require 'B47ANCEDQuartermaster/LedgerPolicy'
local Program=require 'B47ANCEDQuartermaster/LedgerProgram'
local Options=require 'B47ANCEDQuartermaster/Migration'
local hasNetwork,Network=pcall(require,'B47ANCEDPCFramework/Connections')
local V={areaIDs={},previous=setmetatable({},{__mode='k'}),jobs=setmetatable({},{__mode='k'})}
local function permitted(actor,pc)
 return require('B47ANCEDQuartermaster/LedgerMedia').computer(actor,pc,false) and Program.has(actor,pc,false)
end
local function members(actor,computer,mode)
 if mode=='local' then return {{computer=computer}},nil,1 end
 if not hasNetwork then return nil,'PCNetworkUnavailable' end
 return Network.members(actor,computer)
end
local function fingerprint(list,total)
 local values={tostring(total)}
 for _,row in ipairs(list) do local s=row.computer:getSquare();values[#values+1]=tostring(row.id or '')..':'..s:getX()..':'..s:getY()..':'..s:getZ() end
 return table.concat(values,'|')
end
local function recorded(s)
 local n=s.finished;local now=getGameTime():getWorldAgeHours()
 return type(n)=='number' and n==n and n>=0 and n~=math.huge and n<=now and n or nil
end
local function newer(a,b)
 local x,y=a.snapshot,b.snapshot;local at,bt=recorded(x) or 0,recorded(y) or 0
 return at>bt or at==bt and (x.revision>y.revision or x.revision==y.revision and a.item:getID()>b.item:getID())
end
function V.resolve(actor,computer,mode,hold)
 if isClient() or mode~='local' and mode~='base' or Options.option('LedgerMultipleCDs')==false then return nil,'BaseLedgerDisabled' end
 local Drives=require 'B47ANCEDQuartermaster/LedgerDrives'
 if type(Drives.scanMedia)~='function' then return nil,'PCNetworkUnavailable' end
 local list,why,total=members(actor,computer,mode);if not list then return nil,why or 'PCNetworkUnavailable' end
 local time=getTimestampMs()
 for who,job in pairs(V.jobs) do if who:isDead() or time-(job.used or job.at)>120000 then V.jobs[who]=nil;V.previous[who]=nil end end
 local stamp=fingerprint(list,total);local j=V.jobs[actor]
 if j and (j.computer~=computer or j.mode~=mode or j.fingerprint~=stamp or getTimestampMs()-(j.used or j.at)>120000) then V.jobs[actor]=nil;j=nil end
 if j and j.view then
  if getTimestampMs()-j.finished<10000 or hold and getTimestampMs()-j.at<120000 then
   local good=true
   for _,row in ipairs(j.sources) do
    local s=permitted(actor,row.computer) and Drives.validateMedia(actor,row.computer,row)
    if s~=row.snapshot or s.revision~=row.revision then good=false;break end
   end
   if good then
    j.used=getTimestampMs()
    local fresh,live=true,true;local expires
    for _,row in pairs(j.chosen) do
     fresh=fresh and not row.offline and Policy.fresh(row.snapshot,true)
     live=live and not row.offline and Policy.live(row.snapshot,true)
     local deadline=Policy.deadline(row.snapshot,not row.offline);if deadline then expires=math.min(expires or deadline,deadline) end
    end
    j.view.baseFresh=fresh;j.view.baseLive=live;j.view.baseExpires=expires
    return j.view
   end
  end
  V.previous[actor]={view=j.view,generation=j.generation,mode=j.mode,computer=j.computer}
  V.jobs[actor]=nil;j=nil
 end
 if not j then
  local count=0;for _ in pairs(V.jobs) do count=count+1 end;if count>=16 then return nil,'busy' end
  j={computer=computer,mode=mode,fingerprint=stamp,at=getTimestampMs(),members=list,index=1,sources={},chosen={},carried={},partial=#list<(total or #list)};V.jobs[actor]=j
 end
 local member=j.members[j.index]
 if member then
  local pc=member.computer
  if not permitted(actor,pc) then j.partial=true;j.index=j.index+1;return nil,'waiting' end
  if not j.scan then j.scan=Drives.scanMedia(actor,pc);if not j.scan then V.jobs[actor]=nil;return nil,'StockUnavailable' end end
  local rows,status;local deadline=getTimestampMs()+4
  for _=1,8 do rows,status=j.scan.step();if status~='waiting' or getTimestampMs()>=deadline then break end end
  if status=='waiting' then return nil,'waiting' end
  if status~='done' then V.jobs[actor]=nil;return nil,status end
  local scope=Scope.capture({getCurrentSquare=function() return pc:getSquare() end},'building');local signature=scope and Scope.signature(scope)
  local found=false
  for _,row in ipairs(rows) do
   local s=row.snapshot
   if s.scope.kind=='building' and Policy.complete(s) and recorded(s) and (s.signature==signature or mode=='base' and pc==computer) then
    if #j.sources>=128 then V.jobs[actor]=nil;return nil,'tooLarge' end
    row.computer=pc;row.revision=s.revision;j.sources[#j.sources+1]=row;found=true
    if s.signature==signature then
     if not j.chosen[signature] or newer(row,j.chosen[signature]) then j.chosen[signature]=row end
    elseif not j.carried[s.signature] or newer(row,j.carried[s.signature]) then j.carried[s.signature]=row end
   end
  end
  if not found then j.partial=true end
  j.index=j.index+1;j.scan=nil;return nil,'waiting'
 end
 -- A foreign disc at this PC can supply only its recorded history. Prefer an
 -- available PC in that building when both sources cover the same area.
 for signature,row in pairs(j.carried) do
  if not j.chosen[signature] then row.offline=true;j.chosen[signature]=row;j.partial=true end
 end
 local chosen={};for _,row in pairs(j.chosen) do chosen[#chosen+1]=row end
 table.sort(chosen,function(a,b)
  if a.computer==computer and b.computer~=computer then return true end
  if b.computer==computer and a.computer~=computer then return false end
  return a.snapshot.signature<b.snapshot.signature
 end)
 if #chosen==0 then V.jobs[actor]=nil;return nil,'BaseLedgerNoCopies' end
 local generation={};for _,row in ipairs(chosen) do
  generation[#generation+1]=row.snapshot.id..':'..row.snapshot.revision..':'..row.item:getID()..':'..tostring(row.offline==true)
 end
 j.generation=table.concat(generation,'|')
 local previous=V.previous[actor]
 local first=chosen[1].snapshot
 local view={id=getRandomUUID(),schema=1,scope=first.scope,signature=first.signature,revision=0,entries={},order={},totalRows=0,
  status=j.partial and 'LedgerPartial' or 'LedgerComplete',complete=not j.partial,began=first.began,finished=first.finished,
  base=true,baseFresh=true,baseLive=true,stockAreas={},areaTokens={}}
 for _,row in ipairs(chosen) do
  if not permitted(actor,row.computer) or Drives.validateMedia(actor,row.computer,row)~=row.snapshot or row.snapshot.revision~=row.revision then V.jobs[actor]=nil;return nil,'LedgerDriveChanged' end
  local s=row.snapshot;local pcScope=Scope.capture({getCurrentSquare=function() return row.computer:getSquare() end},'building')
  local same=pcScope and Policy.computerMatches(s,Scope.signature(pcScope))
  view.baseFresh=view.baseFresh and not row.offline and Policy.fresh(s,same)
  view.baseLive=view.baseLive and not row.offline and Policy.live(s,same)
  local deadline=Policy.deadline(s,same);if deadline then view.baseExpires=math.min(view.baseExpires or deadline,deadline) end
  local sq=row.computer:getSquare();local token=V.areaIDs[s.signature]
  if not token then local count=0;for _ in pairs(V.areaIDs) do count=count+1 end;if count>=256 then V.jobs[actor]=nil;return nil,'tooLarge' end;token=getRandomUUID();V.areaIDs[s.signature]=token end
  local position=row.offline and s.entries[s.order[1]] and s.entries[s.order[1]].position
  local label=position and getText('UI_QMSS_BaseLedgerArea',position.x,position.y)
   or row.offline and s.scope.label or getText('UI_QMSS_BaseLedgerArea',sq:getX(),sq:getY())
  if row.offline then label=label..' — '..getText('UI_QMSS_BaseLedgerOfflineCD',s.finished) end
  local area={id=token,label=label,key=s.signature,offline=row.offline==true,recorded=s.finished}
  view.stockAreas[#view.stockAreas+1]=area;view.areaTokens[token]=area
  for _,key in ipairs(s.order) do
   if not view.entries[key] then
    local entry={};for k,v in pairs(s.entries[key]) do entry[k]=v end
    entry.stockArea=token;entry.stockKey=s.signature
    if #chosen>1 then entry.roomName=label..' / '..entry.roomName end
    view.entries[key]=entry;view.order[#view.order+1]=key;view.totalRows=view.totalRows+#entry.rows
    if #view.order>4096 or view.totalRows>32768 then V.jobs[actor]=nil;return nil,'tooLarge' end
   end
  end
 end
 view.scope={kind='building',label=mode=='base' and getText('UI_QMSS_BaseLedgerTitle') or first.scope.label}
 if previous and previous.generation==j.generation and previous.mode==mode and previous.computer==computer then view.id=previous.view.id end
 V.previous[actor]=nil
 j.view=view;j.finished=getTimestampMs();j.used=j.finished;return view
end
function V.cleanup(actor) V.jobs[actor]=nil;V.previous[actor]=nil end
return V
