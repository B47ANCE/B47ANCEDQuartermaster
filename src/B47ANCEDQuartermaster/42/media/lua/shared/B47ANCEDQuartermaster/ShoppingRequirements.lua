require 'B47ANCEDQuartermaster/Schema'
require 'B47ANCEDQuartermaster/ProjectCookAdapter'
require 'B47ANCEDQuartermaster/EvolvedRequirements'
require 'B47ANCEDQuartermaster/ShoppingPreferences'
local R={};B47ANCEDQuartermaster.ShoppingRequirements=R
local function integer(n) return type(n)=='number' and n==math.floor(n) and n>0 and n<=1000000 end
local function list(java) local t={};for i=0,java:size()-1 do t[#t+1]=java:get(i) end;return t end
function R.carried(player)
    local items,seen={},{}
    local function add(c)
        for _,it in ipairs(list(c:getItems())) do if not seen[it] then seen[it]=true;items[#items+1]=it end end
    end
    local root=player:getInventory();add(root)
    for _,it in ipairs(list(root:getItems())) do
        if instanceof and instanceof(it,'InventoryContainer') and
            ((player.isEquipped and player:isEquipped(it)) or
            (ItemType and it:isItemType(ItemType.KEY_RING)) or (ItemTag and it:hasTag(ItemTag.KEY_RING))) then add(it:getInventory()) end
    end
    table.sort(items,function(a,b) return a:getID()<b:getID() end)
    return items
end
function R.counts(items)
    local counts={};for _,item in ipairs(items) do local t=item:getFullType();counts[t]=(counts[t] or 0)+1 end
    return counts
end
function R.projectKey(kind,name,intent,origin)
    if type(name)~='string' or #name>256 then return end
    if origin~=nil and origin~='cook' then return end
    local key
    if kind=='evolved' then key=B47ANCEDQuartermaster.EvolvedRequirements.key(name,intent)
    elseif kind=='craft' or kind=='build' then key=kind..':'..name end
    return key and (origin and key..'@'..origin or key)
end
local function resolve(kind,name,executions,player)
    if (kind~='craft' and kind~='build') or type(name)~='string' or #name>256 or not integer(executions) then return nil,'invalid' end
    local manager=getScriptManager()
    if not manager.getCraftRecipe or not CraftRecipeManager then return nil,'unsupported' end
    local recipe=manager:getCraftRecipe(name)
    if not recipe or recipe:isBuildableRecipe()~=(kind=='build') then return nil,'invalid' end
    if recipe:hasOnTickInputs() or recipe:hasOnTickOutputs() then return nil,'unsupported' end
    local nodes={};local reusableTypes={}
    for i,input in ipairs(list(recipe:getInputs())) do
        if not input:isValid() or input:getResourceType()~=ResourceType.Item or input:isVariableAmount()
            or input:isApplyOnTick() or input:hasCreateToItem() or input:hasConsumeFromItem() or input:isReplace()
            or input:hasParentScript() or input:isAutomationOnly() or input:isHandcraftOnly() or input:isExclusive()
            or input:isAcceptsAnyItem() or input:mayDegrade() or input:mayDegradeLight() or input:mayDegradeVeryLight()
            or input:mayDegradeHeavy() or input:sharpnessCheck() then return nil,'unsupported' end
        local mode=input:getItemApplyMode()
        if mode~=ItemApplyMode.Normal and mode~=ItemApplyMode.Keep and mode~=ItemApplyMode.Destroy then return nil,'unsupported' end
        if not input:isItemCount() and (input:hasFlag(InputFlag.ItemIsUses) or input:hasFlag(InputFlag.ItemIsFluid)
            or input:hasFlag(InputFlag.ItemIsEnergy)) then return nil,'unsupported' end
        if input:hasFlag(InputFlag.Unseal) or input:hasFlag(InputFlag.SetActivated)
            or input:hasFlag(InputFlag.InheritUsesAndEmpty) then return nil,'unsupported' end
        local n=input:getIntAmount();if not integer(n) then return nil,'unsupported' end
        local types={};local names={}
        for _,script in ipairs(list(input:getPossibleInputItems())) do
            local t=script:getFullName()
            if input:isUsesPartialItem(script) or input:getIntAmount(t)~=n then return nil,'unsupported' end
            if not types[t] then types[t]=true;names[#names+1]=t end
            if #names>256 then return nil,'tooLarge' end
        end
        if #names==0 then return nil,'unsupported' end
        table.sort(names)
        if input:isTool() and not input:isKeep() then return nil,'unsupported' end
        local keep=input:isKeep()
        -- Multiple simultaneous reusable slots with overlapping candidates need
        -- the native slot allocator; do not falsely credit one tool twice.
        if keep then for t in pairs(types) do if reusableTypes[t] then return nil,'unsupported' end;reusableTypes[t]=true end end
        local amount=keep and n or n*executions
        if amount>1000000 then return nil,'tooLarge' end
        local nativeInput=input
        nodes[#nodes+1]={key=kind..':'..name..':'..i,amount=amount,reusable=keep,types=types,alternatives=names,
            accepts=function(item) return types[item:getFullType()] and CraftRecipeManager.isItemValidForInputScript(nativeInput,item,player) end}
    end
    if #nodes==0 then return nil,'unsupported' end
    return nodes
end
function R.resolve(...)
    if select(1,...)=='evolved' then return B47ANCEDQuartermaster.EvolvedRequirements.resolve(...) end
    local ok,nodes,err=pcall(resolve,...)
    if not ok then return nil,'unsupported' end
    return nodes,err
end
-- Capacitated bipartite matching credits each actual consumed instance once.
-- Re-routing earlier choices preserves OR alternatives without a greedy bias.
function R.allocate(nodes,items)
    local assigned,occupants,candidates={},{},{}
    for i,node in ipairs(nodes) do
        occupants[i]={}
        if not node.reusable and not node.units then for _,t in ipairs(node.alternatives) do
            candidates[t]=candidates[t] or {};candidates[t][#candidates[t]+1]=i
        end end
    end
    local function place(item,visited)
        for _,i in ipairs(candidates[item:getFullType()] or {}) do
            local node=nodes[i]
            if not node.reusable and not visited[i] and node.accepts(item) then
                visited[i]=true;local slot=occupants[i]
                if #slot<node.amount then slot[#slot+1]=item;assigned[item]=i;return true end
                for j,old in ipairs(slot) do
                    if place(old,visited) then slot[j]=item;assigned[item]=i;return true end
                end
            end
        end
        return false
    end
    for _,item in ipairs(items) do place(item,{}) end
    local rows={};local gross,credit,outstanding=0,0,0
    for i,node in ipairs(nodes) do
        local count=#occupants[i]
        if node.units then
            count=0
            for _,item in ipairs(items) do if not assigned[item] and node.accepts(item) then
                count=count+node.units(item);assigned[item]=i
            end end
            count=math.min(count,node.amount)
        end
        if node.reusable then
            count=0
            for _,item in ipairs(items) do if not assigned[item] and node.accepts(item) then count=count+1 end end
            count=math.min(count,node.amount)
        end
        local missing=node.amount-count
        rows[#rows+1]={key=node.key,gross=node.amount,carried=count,outstanding=missing,reusable=node.reusable,alternatives=node.alternatives,
            units=node.units and true or nil,class=node.class}
        gross=gross+node.amount;credit=credit+count;outstanding=outstanding+missing
    end
    return {rows=rows,gross=gross,carried=credit,outstanding=outstanding}
end
function R.ledger(player,data,scope,items)
    local nodes={}
    local wishes,seen={},{}
    for _,kind in ipairs({'wish','needed'}) do
        local targets=data[kind] or {};local linked=data[kind=='wish' and 'wishDemand' or 'neededDemand'] or {}
        for t in pairs(linked) do if targets[t] and (not scope or (scope.wish==t and (scope.list or 'wish')==kind)) and not seen[t] then
            seen[t]=true;wishes[#wishes+1]=t
        end end
    end
    table.sort(wishes,function(a,b)
        local x=(data.neededDemand or {})[a] and 1 or 0;local y=(data.neededDemand or {})[b] and 1 or 0
        return x~=y and x>y or x==y and a<b
    end)
    for _,t in ipairs(wishes) do local fullType=t
        local wanted=(data.wishDemand[t] and data.wish[t]) or 0
        local needed=((data.neededDemand or {})[t] and (data.needed or {})[t]) or 0
        if scope then if scope.list=='needed' then wanted=0 else needed=0 end end
        nodes[#nodes+1]={key='dibs:'..t,amount=math.max(wanted,needed),priority=needed>0 and 3 or 2,alternatives={t},types={[t]=true},accepts=function(it) return it:getFullType()==fullType end}
    end
    if scope then
        if not scope.wish or #nodes~=1 then return nil,'invalid' end
        items=items or R.carried(player)
        local accepts=B47ANCEDQuartermaster.ShoppingPreferences.compile(data.preferences)
        for _,node in ipairs(nodes) do local native=node.accepts;node.accepts=function(it) return native(it) and accepts(it) end end
        local allocation=R.allocate(nodes,items);allocation.nodes=nodes;allocation.items=items;return allocation
    end
    local names={};for t in pairs(data.shopping) do names[#names+1]=t end;table.sort(names)
    for _,t in ipairs(names) do
        local fullType=t
        nodes[#nodes+1]={key='manual:'..t,amount=data.shopping[t],alternatives={t},types={[t]=true},accepts=function(it) return it:getFullType()==fullType end}
    end
    local projects={};for k in pairs(data.projects or {}) do projects[#projects+1]=k end;table.sort(projects)
    for _,key in ipairs(projects) do
        local p=data.projects[key];local resolved,err=R.resolve(p.kind,p.recipe,p.quantity,player,p.intent)
        if not resolved then return nil,err end
        for _,node in ipairs(resolved) do if p.origin then node.key=node.key..'@'..p.origin end;nodes[#nodes+1]=node end
    end
    -- The supported allocator shares retained tools, but does not solve a
    -- simultaneous consumed/retained allocation of the same candidate type.
    -- Reject that ambiguity rather than collecting an unnecessary extra tool.
    for key,extra in pairs(data.extras or {}) do local fullType=extra.fullType
        nodes[#nodes+1]={key='extra:'..key,amount=extra.quantity,priority=extra.source=='needed' and 3 or 2,types={[fullType]=true},alternatives={fullType},accepts=function(it) return it:getFullType()==fullType end}
    end
    if #nodes>256 then return nil,'tooLarge' end
    local consumed,kept={},{}
    for _,node in ipairs(nodes) do
        for t in pairs(node.types) do
            if node.reusable then kept[t]=true else consumed[t]=true end
        end
    end
    for t in pairs(kept) do if consumed[t] then return nil,'unsupported' end end
    -- Portion nodes pool only identical native use/class semantics. Mixing a
    -- portion's physical item with whole-item/other-use demand is unsupported.
    local weighted,plain={},{};local merged={}
    for _,node in ipairs(nodes) do
        if node.units then
            local t=node.alternatives[1];local old=weighted[t]
            if plain[t] or (old and old.pool~=node.pool) then return nil,'evolvedUnsupported' end
            if old then old.amount=old.amount+node.amount;if old.amount>1000000 then return nil,'tooLarge' end
            else weighted[t]=node;merged[#merged+1]=node end
        else
            for t in pairs(node.types) do if weighted[t] then return nil,'evolvedUnsupported' end;plain[t]=true end
            merged[#merged+1]=node
        end
    end
    nodes=merged;items=items or R.carried(player)
    local accepts=B47ANCEDQuartermaster.ShoppingPreferences.compile(data.preferences)
    for _,node in ipairs(nodes) do local native=node.accepts;node.accepts=function(it) return native(it) and accepts(it) end end
    local allocation=R.allocate(nodes,items)
    allocation.nodes=nodes;allocation.items=items
    return allocation
end
function R.priority(ledger,item)
    local priority=0
    for i,node in ipairs(ledger.nodes) do
        if ledger.rows[i].outstanding>0 and node.accepts(item) then priority=math.max(priority,node.priority or 1) end
    end
    return priority
end
function R.worthTaking(ledger,item)
    if ledger.outstanding==0 then return false end
    local any=false
    for _,node in ipairs(ledger.nodes) do if node.accepts(item) then any=true;break end end
    if not any then return false end
    local items={};for _,it in ipairs(ledger.items) do if it==item then return false end;items[#items+1]=it end
    items[#items+1]=item
    return R.allocate(ledger.nodes,items).outstanding<ledger.outstanding
end
return R
