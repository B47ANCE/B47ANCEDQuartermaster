-- One pure sparse allocation model. No engine reads, network or inventory writes.
B47ANCEDQuartermaster=B47ANCEDQuartermaster or {}
local A={schema=1};B47ANCEDQuartermaster.AllocationProfile=A
local function plain(t) return type(t)=='table' and getmetatable(t)==nil end
local function id(v,max) return type(v)=='string' and #v>0 and #v<=(max or 1024) and not v:find('%c') end
function A.percent(v) return type(v)=='number' and v==v and v>=0 and v<=100 and v==math.floor(v) end
function A.fullType(v) return id(v,512) and v:find('.',1,true)~=nil and not v:find('%s') end
function A.empty(default) return {schema=1,default=default or 100,cats={},items={},paths={}} end
function A.valid(p)
 if not plain(p) or p.schema~=1 or not A.percent(p.default) or not plain(p.cats) or not plain(p.items) or not plain(p.paths) then return false end
 for k in pairs(p) do if k~='schema' and k~='default' and k~='cats' and k~='items' and k~='paths' then return false end end
 local bytes,count=32,0
 for _,kind in ipairs({'cats','items'}) do for key,value in pairs(p[kind]) do
  if not id(key,kind=='items' and 512 or 1024) or kind=='items' and not A.fullType(key) or not A.percent(value) then return false end
  count=count+1;bytes=bytes+#key+16;if count>8192 or bytes>262144 then return false end
 end end
 for full,path in pairs(p.paths) do
  if p.items[full]==nil or not plain(path) or #path>16 then return false end
  local n,seen=0,{};for k,category in pairs(path) do
   if type(k)~='number' or k~=math.floor(k) or k<1 or k>#path or not id(category) or seen[category] then return false end
   seen[category]=true;n=n+1;bytes=bytes+#category+8
  end
  if n~=#path or bytes>262144 then return false end
 end
 return true
end
function A.copy(p)
 if not p then return nil end
 local out=A.empty(p.default)
 for _,kind in ipairs({'cats','items'}) do for k,v in pairs(p[kind]) do out[kind][k]=v end end
 for full,path in pairs(p.paths) do out.paths[full]={};for n,category in ipairs(path) do out.paths[full][n]=category end end
 return out
end
function A.equal(a,b)
 if a==nil or b==nil then return a==b end
 if not A.valid(a) or not A.valid(b) or a.default~=b.default then return false end
 for _,kind in ipairs({'cats','items'}) do
  for k,v in pairs(a[kind]) do if b[kind][k]~=v then return false end end
  for k,v in pairs(b[kind]) do if a[kind][k]~=v then return false end end
 end
 for full,path in pairs(a.paths) do
  local other=b.paths[full];if not other or #path~=#other then return false end
  for n,v in ipairs(path) do if other[n]~=v then return false end end
 end
 for full in pairs(b.paths) do if not a.paths[full] then return false end end
 return true
end
function A.value(p,full,path)
 if not p then return 100,'legacy' end
 local value,source=p.default,'inherited'
 for _,category in ipairs(path or {}) do if p.cats[category]~=nil then value=p.cats[category] end end
 if p.items[full]~=nil then value,source=p.items[full],'explicit' end
 return value,source
end
-- Only explicit ancestors constrain aggregate occupancy. Inheritance does not
-- create redundant per-descendant aggregate ceilings or multiply percentages.
function A.ceilings(p,full,path)
 if not p then return {} end
 local out={};local inherited=false
 for _,category in ipairs(path or {}) do if p.cats[category]~=nil then
  out[#out+1]={kind='category',key=category,percent=p.cats[category]};inherited=true
 end end
 if p.items[full]~=nil then out[#out+1]={kind='item',key=full,percent=p.items[full]}
 elseif not inherited then out[#out+1]={kind='item',key=full,percent=p.default} end
 return out
end
local function contains(path,category) for _,v in ipairs(path or {}) do if v==category then return true end end;return false end
function A.path(category,resolver)
 local out,seen={},{};local current=category
 while current do
  if seen[current] or #out>=16 then return nil,'AllocationHierarchyInvalid' end
  seen[current]=true;table.insert(out,1,current)
  -- The active native resolver deliberately exposes no invented parents.
  current=resolver and type(resolver.parent)=='function' and resolver.parent(current) or nil
 end
 return out
end
function A.index(entries,resolver)
 local index={items={},categories={},children={}}
 for _,entry in ipairs(entries or {}) do if A.fullType(entry.fullType) and id(entry.category) then
  local path,err=A.path(entry.category,resolver);if not path then return nil,err end
  if path then
   local old=index.items[entry.fullType]
   if old and table.concat(old.path,'\0')~=table.concat(path,'\0') then return nil,'AllocationHierarchyAmbiguous' end
   local row=old or {fullType=entry.fullType,name=entry.name,path=path};index.items[entry.fullType]=row
   for n,category in ipairs(path) do
    index.categories[category]=index.categories[category] or {};index.categories[category][entry.fullType]=row
    if n>1 then index.children[path[n-1]]=index.children[path[n-1]] or {};index.children[path[n-1]][category]=true end
   end
  end
 end end
 return index
end
local function descendant(index,child,parent)
 if child==parent then return true end
 for _,row in pairs(index.categories[child] or {}) do
  local above=false;for _,category in ipairs(row.path) do
   if category==parent then above=true end
   if category==child then return above end
  end
 end
 return false
end
function A.setCategory(p,category,value,index)
 if not A.valid(p) or not A.percent(value) or not id(category) or not index.categories[category] then return nil,'invalid' end
 local out=A.copy(p);local removed=0
 for key in pairs(out.cats) do if key~=category and descendant(index,key,category) then out.cats[key]=nil;removed=removed+1 end end
 for full in pairs(out.items) do
  local row=index.items[full];local path=row and row.path or out.paths[full]
  if contains(path,category) then out.items[full]=nil;out.paths[full]=nil;removed=removed+1 end
 end
 out.cats[category]=value
 return out,nil,removed
end
function A.setItem(p,full,value,path)
 if not A.valid(p) or not A.fullType(full) or not A.percent(value) then return nil,'invalid' end
 local out=A.copy(p);out.items[full]=value;out.paths[full]={}
 for n,category in ipairs(path or {}) do out.paths[full][n]=category end
 if not A.valid(out) then return nil,'invalid' end
 return out
end
function A.reset(p,kind,key)
 if not A.valid(p) or (kind~='category' and kind~='item') then return nil,'invalid' end
 local out=A.copy(p);out[kind=='category' and 'cats' or 'items'][key]=nil
 if kind=='item' then out.paths[key]=nil end
 return out
end
function A.resetBranch(p,category,index)
 local out,e=A.setCategory(p,category,100,index);if not out then return nil,e end
 out.cats[category]=nil;return out
end
function A.state(p,category,index)
 local value,n=nil,0
 for full,row in pairs(index.categories[category] or {}) do
  local v=A.value(p,full,row.path);n=n+1
  if value==nil then value=v elseif value~=v then return nil,'mixed',n end
 end
 if n==0 then return p and p.cats[category] or p and p.default or 100,'orphan',0 end
 return value,p and p.cats[category]~=nil and 'explicit' or p and 'inherited' or 'legacy',n
end
-- Linked presets remain deterministic. Conflicting linked ceilings use the
-- restrictive minimum; explicit local keys override linked keys on that node.
function A.effective(localProfile,profiles)
 local out
 for _,p in ipairs(profiles or {}) do if p then
  if not out then out=A.copy(p) else
   out.default=math.min(out.default,p.default)
   for _,kind in ipairs({'cats','items'}) do for key,value in pairs(p[kind]) do out[kind][key]=math.min(out[kind][key] or 100,value) end end
   for full,path in pairs(p.paths) do if not out.paths[full] then out.paths[full]={};for n,v in ipairs(path) do out.paths[full][n]=v end end end
  end
 end end
 if localProfile then
  if not out then return A.copy(localProfile) end
  out.default=math.min(out.default,localProfile.default)
  for _,kind in ipairs({'cats','items'}) do for key,value in pairs(localProfile[kind]) do out[kind][key]=value end end
  for full,path in pairs(localProfile.paths) do out.paths[full]={};for n,v in ipairs(path) do out.paths[full][n]=v end end
 end
 return out
end
return A
