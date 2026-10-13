dofile(TEST_ROOT..'/test_consolidated.lua')
local Q=B47ANCEDQuartermaster;local R,P=Q.ShoppingRequirements,Q.Personal
local f=CONTAINER_FIXTURE;f.network(false,true)
local player=f.player;local carried=player:getInventory();carried.items={}
local id,data=P.identity(player);data.shopping={};data.projects={};data.shoppingSchema=2
local function item(id,t) return {getID=function() return id end,getFullType=function() return t end} end
local function input(types,n,keep,unsupported)
    local scripts={};for _,t in ipairs(types) do scripts[#scripts+1]={getFullName=function() return t end} end
    local x={}
    for _,name in ipairs({'hasParentScript','isAutomationOnly','isHandcraftOnly','isExclusive','isVariableAmount','isApplyOnTick','hasCreateToItem','hasConsumeFromItem','isReplace','isAcceptsAnyItem','mayDegrade','mayDegradeLight','mayDegradeVeryLight','mayDegradeHeavy','sharpnessCheck','isUsesPartialItem'}) do x[name]=function() return false end end
    function x:isValid() return true end
    function x:getResourceType() return unsupported or ResourceType.Item end
    function x:getIntAmount() return n end
    function x:getPossibleInputItems() return f.list(scripts) end
    function x:isKeep() return keep or false end
    function x:getItemApplyMode() return keep and ItemApplyMode.Keep or ItemApplyMode.Normal end
    function x:isItemCount() return true end
    function x:hasFlag() return false end
    function x:isTool() return keep or false end
    return x
end
ResourceType={Item='item',Fluid='fluid'}
ItemApplyMode={Normal='normal',Keep='keep',Destroy='destroy'}
InputFlag={ItemIsUses='uses',ItemIsFluid='fluid',ItemIsEnergy='energy',Unseal='unseal',SetActivated='activated',InheritUsesAndEmpty='empty'}
CraftRecipeManager={isItemValidForInputScript=function(x,it,p)
    for _,script in ipairs((function() local a={};local j=x:getPossibleInputItems();for i=0,j:size()-1 do a[#a+1]=j:get(i) end;return a end)()) do
        if script:getFullName()==it:getFullType() then return true end
    end
    return false
end}
local recipes={}
local function recipe(name,inputs,build)
    local r={};function r:getName() return name end
    function r:isBuildableRecipe() return build or false end
    function r:hasOnTickInputs() return false end;function r:hasOnTickOutputs() return false end
    function r:getInputs() return f.list(inputs) end
    recipes[name]=r;return r
end
recipe('Boards',{input({'Base.Plank'},1)})
recipe('Frame',{input({'Base.Plank'},2),input({'Base.Hammer'},1,true)},true)
recipe('OtherFrame',{input({'Base.Plank'},1),input({'Base.Hammer'},1,true)},true)
recipe('Fluid',{input({'Base.Water'},1,false,ResourceType.Fluid)})
local manager={getCraftRecipe=function(_,name) return recipes[name] end,FindItem=function(_,t) return {getDisplayName=function() return t end} end}
getScriptManager=function() return manager end
carried.items={item(101,'Base.Plank'),item(102,'Base.Plank'),item(103,'Base.Plank')}
local function add(kind,name,n)
    local snapshot=P.snapshot(player)
    return P.project(player,{kind=kind,recipe=name,quantity=n,add=true,revision=snapshot.revision})
end
local s=add('craft','Boards',10);assert(s.status=='ok' and s.gross==10 and s.carried==3 and s.outstanding==7)
s=add('craft','Boards',2);assert(s.status=='ok' and s.gross==12 and s.carried==3 and s.outstanding==9 and s.projects[1].quantity==12)
assert(P.change(player,{kind='shopping',fullType='Base.Plank',quantity=2,revision=s.revision}).outstanding==11,'manual/recipe credit duplicated')
table.remove(carried.items);assert(P.snapshot(player).outstanding==12,'dropped supply did not restore need')
carried.items[#carried.items+1]=item(104,'Base.Plank');assert(P.snapshot(player).outstanding==11,'new supply did not reduce need')
-- Current-state credit deduplicates root/equipped-bag appearances.
local plank=carried.items[1]
local bag={getID=function() return 100 end,getFullType=function() return 'Base.Bag' end,getInventory=function() return {getItems=function() return f.list({plank}) end} end}
carried.items[#carried.items+1]=bag
instanceof=function(it,kind) return it==bag and kind=='InventoryContainer' end
function player:isEquipped(it) return it==bag end
assert(P.snapshot(player).carried==3,'bag movement credited the same instance twice')
carried.items={item(105,'Base.Plank'),item(106,'Base.Hammer')};data.shopping={};data.projects={}
s=add('build','Frame',3);assert(s.outstanding==5 and s.gross==7)
s=add('build','OtherFrame',2);assert(s.outstanding==7,'reusable hammer multiplied or double-consumed')
local oldRevision=s.revision
assert(P.project(player,{kind='craft',recipe='Fluid',quantity=1,add=true,revision=oldRevision}).status=='unsupported')
assert(P.snapshot(player).revision==oldRevision)
assert(P.project(player,{kind='craft',recipe='Frame',quantity=1,revision=oldRevision}).status=='invalid')
assert(P.project(player,{kind='craft',recipe='Boards',quantity=1,revision=-1}).status=='conflict')
assert(P.project(player,{kind='craft',recipe='Boards',quantity=0.5,revision=oldRevision}).status=='invalid')
assert(P.project(player,{kind='cook',recipe='Boards',quantity=1,revision=oldRevision}).status=='invalid')
f.network(true,false);assert(Q.Authority.handle(player,'personalProject',{}).status=='invalid');f.network(false,true)
-- OR matching must reroute a flexible earlier assignment to keep an exact one.
local nodes={{key='flex',amount=1,alternatives={'A','B'},accepts=function(it) return it:getFullType()=='A' or it:getFullType()=='B' end},
 {key='exact',amount=1,alternatives={'A'},accepts=function(it) return it:getFullType()=='A' end}}
local a,b=item(201,'A'),item(202,'B');assert(R.allocate(nodes,{a,b}).outstanding==0)
local ledger=R.allocate(nodes,{a});ledger.nodes=nodes;ledger.items={a};assert(R.worthTaking(ledger,b))
-- Tool counts remain fixed across executions; weighted/partial uses fail closed.
local partial=input({'Base.Plank'},1);partial.isUsesPartialItem=function() return true end
recipe('Partial',{partial});assert(not R.resolve('craft','Partial',1,player))
local variable=input({'Base.Plank'},1);variable.isVariableAmount=function() return true end
recipe('Variable',{variable});assert(not R.resolve('craft','Variable',1,player))
local tool=input({'Base.Hammer'},1,true);tool.mayDegrade=function() return true end
recipe('Degrading',{tool});assert(not R.resolve('craft','Degrading',1,player))
-- Historical progress is retired; authoritative possession supplies Wish state.
data.wish['Base.Nails']=222;data.wishSchema=1;data.wishProgress={['Base.Nails']=137}
s=P.snapshot(player);assert(s.wishGoals['Base.Nails'].current==0 and s.wishGoals['Base.Nails'].remaining==222 and data.wishProgress==nil)
s=P.change(player,{kind='wish',fullType='Base.Nails',quantity=100,revision=s.revision})
assert(s.wishGoals['Base.Nails'].current==0 and not s.wishGoals['Base.Nails'].fulfilled)
P.collected(player,'Base.Nails');assert(P.snapshot(player).wishGoals['Base.Nails'].current==0)
assert(P.establishWish(player,'Base.Nails') and P.snapshot(player).wish['Base.Nails']==100)
print('PASS OFFLINE native-shaped recipe ledger and current-inventory Wish migration')

getActivatedMods=function() return {contains=function() return false end} end
assert(Q.ProjectCookAdapter.status()=='absent' and not R.resolve('cook','dish',1,player))
getActivatedMods=function() return {contains=function() return true end} end
assert(Q.ProjectCookAdapter.status()=='optional' and not R.resolve('cook','dish',1,player))
print('PASS OFFLINE optional Cook absence/presence fail closed without external code or client ingredients')

local before=P.snapshot(player)
assert(P.change(player,{kind='shopping',fullType='Base.Hammer',quantity=1,revision=before.revision}).shoppingBlocked=='unsupported','ambiguous consumed/retained allocation silently accepted')
assert(Q.Shopping.handle(player,'shoppingBegin',{}).status=='unsupported')
assert(P.change(player,{kind='shopping',fullType='Base.Hammer',quantity=0,revision=P.snapshot(player).revision}).shoppingBlocked==nil)
-- Removing unavailable projects must stay possible while other projects block.
data.projects.bad1={kind='craft',recipe='Missing1',quantity=1};data.projects.bad2={kind='craft',recipe='Missing2',quantity=1}
-- Persisted canonical project keys are stable recipe identities.
data.projects['craft:Missing1']=data.projects.bad1;data.projects.bad1=nil
data.projects['craft:Missing2']=data.projects.bad2;data.projects.bad2=nil
local removed=P.project(player,{kind='craft',recipe='Missing1',quantity=0,revision=data.revision});assert(removed.status=='ok' and removed.shoppingBlocked)
removed=P.project(player,{kind='craft',recipe='Missing2',quantity=0,revision=data.revision});assert(removed.status=='ok' and not removed.shoppingBlocked)
print('PASS OFFLINE ambiguous tool/consumable ledger blocks collection; missing project removal repairs blocked lists')

local physical=item(310,'Base.Glue');local itemMD={}
function physical:getModData() return itemMD end
function physical:getContainer() return carried end
carried.items[#carried.items+1]=physical;data.wish['Base.Glue']=nil
assert(Q.Dibs.transition(player,physical,'needed') and not P.snapshot(player).wish['Base.Glue'])
assert(Q.Dibs.transition(player,physical,'wanted') and P.snapshot(player).wish['Base.Glue']==1)
local wish=P.snapshot(player);P.change(player,{kind='wish',fullType='Base.Glue',quantity=9,revision=wish.revision})
assert(Q.Dibs.transition(player,physical,'none') and data.wish['Base.Glue']==9)
assert(Q.Dibs.transition(player,physical,'wanted') and data.wish['Base.Glue']==9)
local order=Q.Dibs.details(physical).wanted[1].order
P.change(player,{kind='wish',fullType='Base.Glue',quantity=0,revision=data.revision})
assert(Q.Dibs.details(physical).wanted[1].order==order,'removing Wish cleared/reordered Dibs')
assert(Q.Dibs.transition(player,physical,'wanted') and data.wish['Base.Glue']==1 and Q.Dibs.details(physical).wanted[1].order==order)
data.wish['Mod.Missing']=10
local find=manager.FindItem;manager.FindItem=function(self,t) if t~='Mod.Missing' then return find(self,t) end end
assert(P.snapshot(player).wishGoals['Mod.Missing'].current==0)
local changedMissing=P.change(player,{kind='wish',fullType='Mod.Missing',quantity=20,revision=data.revision})
assert(changedMissing.status=='ok' and changedMissing.wishGoals['Mod.Missing'].current==0)
assert(P.change(player,{kind='wish',fullType='Mod.Missing',quantity=0,revision=data.revision}).status=='ok')
print('PASS OFFLINE physical Wanted/Wish lifecycles, Needed alone, preserved targets/current counts/order and missing-item removal')

-- Resolved native-shaped alternatives and output metadata retain execution units.
local orRecipe=recipe('Alternatives',{input({'Base.A','Base.B'},1)})
function orRecipe:getOutputs() return f.list({getIntAmount=function() return 4 end}) end
carried.items={item(400,'Base.A'),item(401,'Base.B')};data.shopping={};data.projects={}
local alternatives=add('craft','Alternatives',2)
assert(alternatives.status=='ok' and alternatives.gross==2 and alternatives.outstanding==0)
local many={};for i=1,257 do many[#many+1]='Large.Type'..i end
recipe('TooManyAlternatives',{input(many,1)})
local nodes,err=R.resolve('craft','TooManyAlternatives',1,player);assert(not nodes and err=='tooLarge')
-- Newly obtained supplies invalidate a queued surplus TAKE before dispatch.
carried.items={};data.projects={};data.shopping={['Base.Nails']=1}
local source=f.a.containers[1]
local sourceItem=item(500,'Base.Nails');local sourceMD={}
function sourceItem:getContainer() return source end
function sourceItem:getModData() return sourceMD end
function sourceItem:isFavorite() return false end
function sourceItem:isEquipped() return false end
function sourceItem:getAttachedSlot() return -1 end
function sourceItem:getIsCraftingConsumed() return false end
function sourceItem:getActualWeight() return 1 end
source.items={sourceItem}
local start=Q.Shopping.handle(player,'shoppingBegin',{});assert(start.status=='ok')
local offer=Q.Shopping.handle(player,'shoppingNext',{run=start.run});assert(offer.status=='ok')
carried.items={item(501,'Base.Nails')}
assert(Q.Movement.handle(player,'moveTake',{operation=offer.operation}).status=='invalid','surplus TAKE remained authorized')
assert(source.items[1]==sourceItem and P.snapshot(player).outstanding==0)
Q.Movement.handle(player,'moveCancel',{operation=offer.operation});Q.Shopping.handle(player,'shoppingCancel',{run=start.run})
print('PASS OFFLINE native OR/output execution semantics, payload bound and current-credit revalidation before TAKE')

local condition=input({'Base.Plank'},1);condition.hasParentScript=function() return true end
recipe('Compound',{condition});assert(not R.resolve('craft','Compound',1,player))
condition=input({'Base.Plank'},1);condition.getItemApplyMode=function() return 'unknown-future-mode' end
recipe('UnknownMode',{condition});assert(not R.resolve('craft','UnknownMode',1,player))
condition=input({'Base.Plank'},1);condition.isItemCount=function() return false end;condition.hasFlag=function(_,flag) return flag==InputFlag.ItemIsUses end
recipe('UsesFlag',{condition});assert(not R.resolve('craft','UsesFlag',1,player))
condition=input({'Base.Plank'},1,true);condition.hasFlag=function(_,flag) return flag==InputFlag.Unseal end
recipe('UnsealingKeep',{condition});assert(not R.resolve('craft','UnsealingKeep',1,player))
print('PASS OFFLINE compound/mode/use-unit/state-changing inputs reject whole projects')
