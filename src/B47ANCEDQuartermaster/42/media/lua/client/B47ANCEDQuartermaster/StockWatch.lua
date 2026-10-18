-- A PC-only consumer of Notification API 1. No client inventory scans.
local PC=require 'B47ANCEDPCFramework/API'
local W={}
function W.new(num,host,source,owner,rooms)
 local api=PC.Notifications;local self={due=0,pending=false,low={},lowScopes={},lowIDs={},scopes={{kind='building'}},index=1,closed=false}
 if not api or api.version~=1 then function self:update() end;function self:close() end;return self end
 local function tr(k,...) return getText('UI_QMSS_'..k,...) end
 local function clear() api.dismiss(host,'stock.low');self.low={};self.lowScopes={};self.lowIDs={} end
 function self:close() self.closed=true;clear() end
 function self:update()
  if self.closed or self.pending or getTimestampMs()<self.due then return end
  if not PC.ComputerUI.isLive(host) or host.content~=owner then self:close();return end
  local scopes={{kind='building'}}
  for _,r in ipairs(rooms()) do if r.building then scopes[#scopes+1]={kind='building',building=r.building} elseif r.id and r.id~='' and not r.id:find('^unassigned:') then scopes[#scopes+1]={kind='room',id=r.id} end end
  if self.index>#scopes then self.index=1 end
  local scope=scopes[self.index];local args={};for k,v in pairs(source) do args[k]=v end
  args.stockKind=scope.kind;args.stockRoom=scope.id;args.stockBuilding=scope.building;self.pending=true
  B47ANCEDQuartermaster.Authority.request(num,'ledgerStock',args,function(result)
   if self.closed or not PC.ComputerUI.isLive(host) or host.content~=owner then return end
   self.pending=false
   if result.status=='waiting' then self.due=getTimestampMs()+500;return end
   self.due=getTimestampMs()+1000;self.index=self.index+1
   if self.index>#scopes then self.index=1;self.due=getTimestampMs()+(result.interval or 30)*1000 end
   if result.status~='ok' or not result.canNotify then clear();return end
   local key=scope.kind..':'..tostring(scope.id or scope.building);local values={};local nextIDs={};local newlyLow=false
   for _,row in ipairs(result.rows or {}) do if row.remaining>0 then values[#values+1]=tr('StockLowItem',row.name,row.current,row.target);local id=key..'\0'..row.fullType;nextIDs[id]=true;if not self.lowIDs[id] then newlyLow=true end end end
   for id in pairs(self.lowIDs) do if id:sub(1,#key+1)==key..'\0' then self.lowIDs[id]=nil end end
   for id in pairs(nextIDs) do self.lowIDs[id]=true end
   self.low[key]=#values>0 and values or nil;self.lowScopes[key]=#values>0 and scope or nil
   local lines={};for _,items in pairs(self.low) do for _,line in ipairs(items) do if #lines<4 then lines[#lines+1]=line end end end
   if #lines==0 then api.dismiss(host,'stock.low');return end
   local message=table.concat(lines,'; ');if #message>500 then
    local n=497;while n>0 and message:byte(n+1)>=128 and message:byte(n+1)<192 do n=n-1 end
    message=message:sub(1,n)..'...'
   end
   local posted=api.post(host,{id='stock.low',title=tr('StockLowTitle'),message=message,severity='warning',silent=not newlyLow,
    onOpen=function() local preferred;for key in pairs(self.low) do preferred=self.lowScopes[key];break end;require('B47ANCEDQuartermaster/StockUI').open(num,owner,source,host,rooms(),preferred) end})
   if not posted then self.lowIDs={} end
  end)
 end
 return self
end
return W
