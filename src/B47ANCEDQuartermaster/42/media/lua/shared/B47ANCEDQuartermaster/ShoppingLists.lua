-- Paper is the transferable capability; server ModData is the content authority.
local F={itemType='B47ANCEDQuartermaster.ShoppingPaper',contexts=setmetatable({},{__mode='k'})}
local Q=B47ANCEDQuartermaster
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Options=require 'B47ANCEDQuartermaster/Migration'
Q.ShoppingLists=F
function F.enabled() return Options.option('PhysicalShoppingLists')~=false end
function F.writingRequired() return Options.option('ShoppingWritingSupplies')~=false end
local function integer(n,a,b) return type(n)=='number' and n==n and n%1==0 and n>=a and n<=b end
local function populated(t) for _ in pairs(t or {}) do return true end;return false end
local function root()
 if isClient() then return end
 local r=ModData.getOrCreate('B47ANCEDQuartermasterShoppingPapers')
 if not populated(r) then r.schema=1;r.count=0;r.records={};r.media={};r.creations={} end
 if r.schema~=1 or not integer(r.count,0,8192) or type(r.records)~='table' or type(r.media)~='table' or type(r.creations)~='table' then return end
 return r
end
local function scan(actor)
 local items,seen={},{};local count=0
 local function visit(c,depth)
  if not c or seen[c] or depth>16 then return false end;seen[c]=true
  local list=c:getItems()
  for i=0,list:size()-1 do
   count=count+1;if count>4096 then return false end
   local it=list:get(i);items[#items+1]=it
   if instanceof(it,'InventoryContainer') and not visit(it:getInventory(),depth+1) then return false end
  end
  return true
 end
 if not actor or actor:isDead() or not visit(actor:getInventory(),0) then return nil,'tooLarge' end
 return items
end
function F.binding(actor,id)
 local r=root();if not r then return nil,nil,'schema' end
 local it=Media.owned(actor,id,F.itemType);if not it then return nil,nil,'ShoppingPaperMissing' end
 local key=r.media[tostring(it:getID())];local d=key and r.records[key]
 local marker=it:getModData().B47ShoppingPaper
 if type(d)~='table' or d.schema~=1 or d.item~=it:getID() or type(marker)~='table' or marker.schema~=1 or marker.id~=key
  or not integer(d.revision,0,9007199254740000) or type(d.name)~='string' or #d.name>64 or not d.ready
  or type(d.shopping)~='table' or type(d.projects)~='table' or type(d.wishDemand)~='table' or type(d.neededDemand)~='table'
  or type(d.extras)~='table' or type(d.addReceipts)~='table' or type(d.paperTargets)~='table'
  or type(d.paperTargets.wish)~='table' or type(d.paperTargets.needed)~='table' or type(d.preferences)~='table'
  or not Q.ShoppingPreferences.normalize(d.preferences) then return nil,nil,'schema' end
 return it,d
end
local writers={['Base.Pen']=true,['Base.Pencil']=true,['Base.PencilSpiffo']=true,['Base.PenFancy']=true,['Base.PenMultiColor']=true,['Base.PenSpiffo']=true,['Base.BluePen']=true,['Base.RedPen']=true}
function F.supplies(actor,blank)
 if not F.writingRequired() and not blank then return true end
 local items,err=scan(actor);if not items then return false,err end
 local book,tool,paper
 for _,it in ipairs(items) do
  local t=it:getFullType()
  if not it:getIsCraftingConsumed() then
   if t=='Base.Notebook' then book=it end
   if writers[t] and it:getCondition()>0 then tool=it end
   if t=='Base.SheetPaper2' and Media.usable(it) and it:isEmptyPages() and not it:hasModData() then paper=it end
  end
 end
 if F.writingRequired() and (not book or not tool) then return false,'ShoppingWritingRequired' end
 if blank and not paper then return false,'ShoppingBlankRequired' end
 return true,nil,paper
end
local fields={shopping=true,shoppingSchema=true,projects=true,wishDemand=true,neededDemand=true,extras=true,addReceipts=true,
 addSerial=true,lastAdd=true,collectedSinceEdit=true,preferences=true,revision=true,paperTargets=true}
local function empty(account)
 return {revision=account.revision,shopping={},shoppingSchema=2,projects={},wishDemand={},neededDemand={},extras={},addReceipts={},
  paperTargets={wish={},needed={}},preferences=account.preferences,collectedSinceEdit=0}
end
function F.data(actor,account)
 if not F.enabled() or F.contexts[actor] and F.contexts[actor].legacy then return account end
 local context=F.contexts[actor];local id=context and context.item or account.activeShoppingPaper
 local item,d=F.binding(actor,id)
 if not d then d=empty(account) end
 return setmetatable({}, {__index=function(_,k) if k=='paperItem' then return item elseif fields[k] then return d[k] else return account[k] end end,
  __newindex=function(_,k,v) if fields[k] and (item or k~='revision') then d[k]=v else account[k]=v end end})
end
function F.metadata(actor)
 if not F.enabled() or F.contexts[actor] and F.contexts[actor].legacy then return {enabled=false} end
 local items,err=scan(actor);local _,account=Q.Personal.account(actor)
 if not items or not account or not root() then return {enabled=true,error=err or 'schema',lists={}} end
 local lists={}
 for _,it in ipairs(items) do if it:getFullType()==F.itemType then
  local exact,d=F.binding(actor,it:getID())
  if d then lists[#lists+1]={item=exact:getID(),name=d.name,revision=d.revision};if #lists>64 then return {enabled=true,error='tooLarge',lists={}} end end
 end end
 table.sort(lists,function(a,b) return a.name==b.name and a.item<b.item or a.name<b.name end)
 local context=F.contexts[actor]
 if not context and account.activeShoppingPaper==nil and lists[1] then account.activeShoppingPaper=lists[1].item end
 local selected=context and context.item or account.activeShoppingPaper
 local item=F.binding(actor,selected);local writable,why=F.supplies(actor)
 return {enabled=true,lists=lists,selected=item and item:getID() or nil,writable=writable==true,writingStatus=why,
  legacy=account.shoppingPaperImported==nil and (populated(account.shopping) or populated(account.projects) or populated(account.wishDemand) or populated(account.neededDemand) or populated(account.extras))}
end
function F.guard(actor,args,write,needsPaper)
 if not F.enabled() then return true end
 if write then local ok,why=F.supplies(actor);if not ok then return false,why end end
 if needsPaper then
  local _,account=Q.Personal.account(actor);local id=F.contexts[actor] and F.contexts[actor].item or account and account.activeShoppingPaper
  if args.paper~=id then return false,'ShoppingPaperMissing' end
  local it,unused,err=F.binding(actor,id);if not it then return false,err end
 end
 return true
end
function F.runValid(actor,run)
 if not F.enabled() then return true end
 if not run or not run.paper then return false,'ShoppingPaperMissing' end
 local it,d,err=F.binding(actor,run.paper)
 if not it then return false,err end
 if run.paperRevision and d.revision~=run.paperRevision then return false,'conflict' end
 return true
end
function F.withPaper(actor,id,fn)
 local previous=F.contexts[actor];F.contexts[actor]={item=id}
 local ok,result=pcall(fn);F.contexts[actor]=previous
 if not ok then error(result) end;return result
end
local function name(value)
 if type(value)~='string' or #value>64 or value:find('[%c]') or value:find('[<>]') then return end
 value=value:match('^%s*(.-)%s*$');if value=='' then return end;return value
end
local function copy(v,depth)
 if type(v)~='table' then return v end
 if depth>16 then error('shopping profile too deep') end
 local out={};for k,x in pairs(v) do out[k]=copy(x,depth+1) end;return out
end
function F.begin(actor,args)
 if not F.enabled() then return {status='invalid'} end
 local r=root();local label=name(args.name)
 if not r then return {status='schema'} end
 if not label or type(args.operation)~='string' or #args.operation<1 or #args.operation>100 or args.import~=nil and type(args.import)~='boolean' then return {status='invalid'} end
 local _,account=Q.Personal.account(actor);if not account then return {status='identity'} end
 local key=tostring(Q.Personal.account(actor))..':'..args.operation
 local old=r.creations[key]
 if old then return {status=old.phase=='committed' and 'ShoppingPaperCreated' or 'uncertain'} end
 if args.import and account.shoppingPaperImported then return {status='ShoppingAlreadyImported'} end
 if r.count>=8192 then return {status='tooLarge'} end
 local ok,why,paper=F.supplies(actor,true);if not ok then return {status=why} end
 if not paper:getContainer():isRemoveItemAllowed(paper) then return {status='denied'} end
 local id=getRandomUUID();if type(id)~='string' or #id>80 or r.records[id] then return {status='failed'} end
 -- Register before the timed action: retries cannot mint another paper.
 local j={phase='ready',input=paper:getID(),id=id,name=label,import=args.import==true,owner=Q.Personal.account(actor)}
 r.creations[key]=j;r.count=r.count+1
 local offer=require('B47ANCEDQuartermaster/Ledger').grantShopping(actor,{journal=j,paper=paper,account=account})
 if offer.status~='action' then r.creations[key]=nil;r.count=r.count-1 end
 return offer
end
function F.valid(actor,g)
 return F.enabled() and g.journal.phase=='ready' and Media.owned(actor,g.paper:getID(),'Base.SheetPaper2')==g.paper
  and g.paper:getCount()==1 and Media.usable(g.paper) and g.paper:isEmptyPages() and not g.paper:hasModData() and F.supplies(actor)==true
  and g.paper:getContainer():isRemoveItemAllowed(g.paper) and (not g.journal.import or not g.account.shoppingPaperImported)
end
function F.complete(actor,g)
 local r=root();local j=g.journal;local inv=actor:getInventory();local source=g.paper:getContainer()
 if not r or not F.valid(actor,g) then return 'denied' end
 local out=instanceItem(F.itemType);if not out then j.phase='failed';return 'failed' end
 if not inv:isItemAllowed(out) or not inv:hasRoomFor(actor,out) then j.phase='failed';return 'capacity' end
 local d=empty(g.account);d.schema=1;d.item=out:getID();d.name=j.name;d.revision=0;d.ready=false
 if j.import then
  -- Read the legacy migration before projecting a paper; keep the original as a backup.
  local legacy=Q.Personal.legacySnapshot(actor);if legacy.status~='ok' then j.phase='failed';return legacy.status end
  for k in pairs(fields) do if k~='revision' and k~='paperTargets' and g.account[k]~=nil then d[k]=copy(g.account[k],0) end end
  d.paperTargets={wish=copy(g.account.wish,0),needed=copy(g.account.needed,0)}
 end
 out:getModData().B47ShoppingPaper={schema=1,id=j.id};out:setName(j.name);out:setCustomName(true)
 j.output=out:getID();j.phase='prepared';r.records[j.id]=d;r.media[tostring(out:getID())]=j.id
 local ok=pcall(function()
  inv:AddItem(out);if inv:getItemWithID(out:getID())~=out then error('paper insert failed') end;j.phase='outputAdded'
  if source:getItemWithID(g.paper:getID())~=g.paper then error('blank moved') end
  source:Remove(g.paper);if source:getItemWithID(g.paper:getID())==g.paper then error('blank retained') end
  j.phase='committed';d.ready=true
  if j.import then g.account.shoppingPaperImported=j.id end
  g.account.activeShoppingPaper=out:getID()
 end)
 if not ok then
  if source:getItemWithID(g.paper:getID())==g.paper and inv:getItemWithID(out:getID())==out then
   pcall(function() inv:Remove(out) end)
   if inv:getItemWithID(out:getID())~=out then j.phase='rolledBack';r.records[j.id]=nil;r.media[tostring(out:getID())]=nil;return 'failed' end
  end
  j.phase='uncertain';d.ready=false;return 'uncertain'
 end
 local removed=pcall(sendRemoveItemFromContainer,source,g.paper);local added=pcall(sendAddItemToContainer,inv,out)
 if not removed or not added then
  print('[B47ANCEDQuartermaster] shopping paper committed; native inventory notification failed')
  return 'ShoppingPaperSyncPending'
 end
 return 'ShoppingPaperCreated'
end
function F.handle(actor,command,args)
 if isClient() or not actor or actor:isDead() then return {status='invalid'} end
 if command=='shoppingPaperCreate' then return F.begin(actor,args) end
 if command=='shoppingPaperRead' then
  if not F.binding(actor,args.item) then return {status='ShoppingPaperMissing'} end
  return F.withPaper(actor,args.item,function() return Q.Personal.snapshot(actor) end)
 end
 if Q.Movement.runs[actor] or Q.Movement.operations[actor] then return {status='busy'} end
 local _,account=Q.Personal.account(actor);local it,d,err=F.binding(actor,args.item)
 if not account or not it then return {status=err or 'identity'} end
 if command=='shoppingPaperSelect' then account.activeShoppingPaper=it:getID();return Q.Personal.snapshot(actor) end
 if command=='shoppingPaperRename' then
  local ok,why=F.supplies(actor);if not ok then return {status=why} end
  local label=name(args.name);if not label then return {status='invalid'} end
  if args.revision~=d.revision then return {status='conflict'} end
  d.name=label;d.revision=d.revision+1;it:setName(label);it:setCustomName(true);syncItemModData(actor,it);it:syncItemFields()
  return Q.Personal.snapshot(actor)
 end
 return {status='invalid'}
end
return F
