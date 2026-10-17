-- One local UI selection per world; no shared geometry or gameplay permissions.
local P={};B47ANCEDQuartermaster.RoomPreferences=P
local values={}
local warned=false
local function ioResult(ok)
 if not ok and not warned then warned=true;print('[B47ANCEDQuartermaster] room UI preference file unavailable; current selection remains usable') end
end
local function valid(world,id)
 return type(world)=='string' and #world==36 and world:match('^[%x%-]+$')
  and type(id)=='string' and #id==73 and id:sub(1,37)==world..':' and id:sub(38):match('^[%x%-]+$')
end
local function load(num)
 if values[num] then return values[num] end
 local entries={};values[num]=entries
 if not getFileReader then return entries end
 local reader
 local ok=pcall(function()
  reader=getFileReader('B47ANCEDQuartermasterRooms'..num..'.txt',false)
  if reader then
  for _=1,16 do local line=reader:readLine();if not line then break end
   if #line<=140 then local world,id=line:match('^([^|]+)|([^|]+)$');if valid(world,id) then entries[#entries+1]={world,id} end end
  end
  end
 end)
 ioResult(ok)
 if reader then ioResult(pcall(function() reader:close() end)) end
 return entries
end
function P.get(num,world)
 for _,e in ipairs(load(num)) do if e[1]==world then return e[2] end end
end
function P.set(num,world,id)
 if type(world)~='string' or #world~=36 or not world:match('^[%x%-]+$') or id and not valid(world,id) then return end
 local entries=load(num)
 for i=#entries,1,-1 do if entries[i][1]==world then table.remove(entries,i) end end
 if id then entries[#entries+1]={world,id} end
 while #entries>16 do table.remove(entries,1) end
 if getFileWriter then
  local writer
  local ok=pcall(function()
   writer=getFileWriter('B47ANCEDQuartermasterRooms'..num..'.txt',true,false)
   if writer then for _,e in ipairs(entries) do writer:write(e[1]..'|'..e[2]..'\n') end end
  end)
  ioResult(ok)
  if writer then ioResult(pcall(function() writer:close() end)) end
 end
end
return P
