-- Offline native-shaped fixtures; no PZ engine or reference implementation.
dofile(TEST_ROOT..'/test_consolidated.lua')
local Q=B47ANCEDQuartermaster;local P,R,E=Q.Personal,Q.ShoppingRequirements,Q.EvolvedRequirements
local f=CONTAINER_FIXTURE;f.network(false,true);local player=f.player;local inventory=player:getInventory()
local movementTemplate=inventory.items[1];inventory.items={}
local _,data=P.identity(player);data.shopping={};data.projects={};data.shoppingSchema=2;data.wish={['Base.Nails']=222}
data.wishSchema=1;data.wishProgress={['Base.Nails']=137}
local serial=1000
local function item(t)
    serial=serial+1;local id=serial
    return {getID=function() return id end,getFullType=function() return t end}
end
local function fill(n) inventory.items={};for _=1,n do inventory.items[#inventory.items+1]=item('Base.Nails') end end
fill(40);local s=P.snapshot(player);assert(data.wishProgress==nil and data.wishSchema==2)
assert(s.wishGoals['Base.Nails'].current==40 and s.wishGoals['Base.Nails'].remaining==182)
local foreign={};for _=1,300 do foreign[#foreign+1]=item('Base.Nails') end
local other=setmetatable({},{__index=player})
function other:getUsername() return 'wish-other-player' end
function other:getInventory() return {getItems=function() return f.list(foreign) end} end
assert(P.change(other,{kind='wish',fullType='Base.Nails',quantity=222,revision=P.snapshot(other).revision}).wishGoals['Base.Nails'].current==300)
assert(P.snapshot(player).wishGoals['Base.Nails'].current==40,'other player inventory credited to actor')
local wanted=item('Base.Glue');local wantedMD={};wanted.container=f.a.containers[1]
function wanted:getModData() return wantedMD end;function wanted:getContainer() return self.container end
wanted.container.items[#wanted.container.items+1]=wanted
assert(Q.Dibs.transition(player,wanted,'wanted'))
assert(P.snapshot(player).wishGoals['Base.Glue'].remaining==1,'stored Wanted credited as carried')
inventory.items[#inventory.items+1]=wanted
for i,it in ipairs(wanted.container.items) do if it==wanted then table.remove(wanted.container.items,i);break end end;wanted.container=inventory
assert(P.snapshot(player).wishGoals['Base.Glue'].fulfilled,'carried Wanted did not fulfill target one')
Q.Dibs.transition(player,wanted,'needed');Q.Dibs.transition(player,wanted,'none');assert(data.wish['Base.Glue']==1)
for _,n in ipairs({0,137,222,247,157,117}) do
    fill(n);s=P.snapshot(player);local g=s.wishGoals['Base.Nails']
    assert(g.current==n and g.remaining==math.max(0,222-n) and g.fulfilled==(n>=222))
end
fill(137);s=P.change(player,{kind='wish',fullType='Base.Nails',quantity=100,revision=data.revision})
assert(s.wishGoals['Base.Nails'].fulfilled and s.wishGoals['Base.Nails'].current==137)
s=P.change(player,{kind='wish',fullType='Base.Nails',quantity=222,revision=data.revision})
-- Same objects moved between root/equipped bag, duplicated references, remote storage excluded.
local original=inventory.items;local bag=item('Base.Bag');bag.bag=true
function bag:getInventory() return {getItems=function() return f.list(original) end} end
function bag:isItemType() return false end;function bag:hasTag() return false end
local oldInstance=instanceof;instanceof=function(it,class) if class=='InventoryContainer' then return it.bag or false end;return false end
function player:isEquipped(it) return it==bag end
inventory.items={bag,original[1]};assert(P.snapshot(player).wishGoals['Base.Nails'].current==137)
player.isEquipped=function() return false end;assert(P.snapshot(player).wishGoals['Base.Nails'].current==1)
instanceof=oldInstance;fill(137)
-- UI stale count is never authoritative; links are idempotent and manual demand persists.
local revision=data.revision;fill(157)
s=P.wishToShopping(player,{fullType='Base.Nails',revision=revision,current=0,remaining=222,progress=999})
assert(s.status=='ok' and s.wishDemand['Base.Nails']==65 and s.outstanding==65 and s.gross==222)
local rev=s.revision;s=P.wishToShopping(player,{fullType='Base.Nails',revision=rev})
assert(s.status=='ok' and s.revision==rev and s.outstanding==65)
s=P.change(player,{kind='shopping',fullType='Base.Nails',quantity=20,revision=s.revision})
assert(s.manual['Base.Nails']==20 and s.outstanding==85 and s.wishDemand['Base.Nails']==65)
local scoped=R.ledger(player,data,{wish='Base.Nails'});assert(scoped.outstanding==65)
fill(222);assert(R.ledger(player,data,{wish='Base.Nails'}).outstanding==0)
assert(P.wishToShopping(player,{fullType='Base.Nails',revision=data.revision}).status=='fulfilled')
assert(P.wishToShopping(player,{fullType='Base.Nails',revision=-1}).status=='conflict')
f.network(true,false);assert(Q.Authority.handle(player,'wishToShopping',{fullType='Base.Nails',revision=data.revision}).status=='invalid');f.network(false,true)
P.change(player,{kind='wish',fullType='Base.Nails',quantity=0,revision=data.revision});assert(not data.wishDemand['Base.Nails'] and data.shopping['Base.Nails']==20)
print('PASS OFFLINE current Wish: migration, 0/partial/exact/over/drop/use/target edits, bag dedup/exclusion, server remaining, idempotence and manual isolation')

-- Actual owned server planner/grant path, with fixture-only native arrivals.
fill(1);P.change(player,{kind='wish',fullType='Base.Nails',quantity=3,revision=data.revision})
assert(P.wishToShopping(player,{fullType='Base.Nails',revision=data.revision}).status=='ok')
local source=f.a.containers[1];source.items={}
for i=1,3 do source.items[i]=setmetatable({id=22000+i,container=source,md={}},{__index=movementTemplate}) end
local begin=Q.Shopping.handle(player,'shoppingBegin',{wish='Base.Nails'});assert(begin.status=='ok')
for _=1,2 do
    local offer=Q.Shopping.handle(player,'shoppingNext',{run=begin.run});assert(offer.status=='ok' and not offer.destination)
    local op=Q.Movement.runs[player].operations[offer.operation]
    assert(Q.Movement.handle(player,'moveTake',{operation=op.id}).status=='ok')
    for i,it in ipairs(source.items) do if it==op.item then table.remove(source.items,i);break end end
    inventory.items[#inventory.items+1]=op.item;op.item.container=inventory
    assert(Q.Movement.handle(player,'moveCarried',{operation=op.id}).status=='ok')
end
assert(Q.Shopping.handle(player,'shoppingNext',{run=begin.run}).status=='done')
assert(P.snapshot(player).wishGoals['Base.Nails'].fulfilled and data.shopping['Base.Nails']==20 and #source.items==1)
-- Supplies acquired between offer and TAKE revoke surplus authorization.
fill(1);begin=Q.Shopping.handle(player,'shoppingBegin',{wish='Base.Nails'});assert(begin.status=='ok')
local offer=Q.Shopping.handle(player,'shoppingNext',{run=begin.run});assert(offer.status=='ok')
fill(3);assert(Q.Movement.handle(player,'moveTake',{operation=offer.operation}).status=='invalid')
Q.Movement.handle(player,'moveCancel',{operation=offer.operation});Q.Shopping.handle(player,'shoppingCancel',{run=begin.run})
assert(#source.items==1)
print('PASS OFFLINE scoped Wish collection: existing server walk/TAKE grants, stop on fulfillment, preserve unrelated manual demand and revoke newly surplus TAKE')

data.shopping={};data.projects={};data.wish={};data.wishDemand={};inventory.items={}
ItemType=ItemType or {};ItemType.FOOD='Food';Perks={Cooking='Cooking'}
function player:getPerkLevel() return self.skill or 0 end
local defs={}
local function definition(t,food,spice)
    local module,short=t:match('^(.-)%.(.+)$')
    local x={getName=function() return short end,getFullName=function() return t end,getModuleName=function() return module end,
        getItemType=function() return food and ItemType.FOOD or 'Normal' end,isSpice=function() return spice or false end,
        getReplaceOnUse=function() end,getReplaceOnDeplete=function() end,getDisplayName=function() return short end}
    defs[t]=x;return x
end
definition('Base.Bowl');definition('Base.Salad',true);definition('Mod.Cabbage',true);definition('Base.Spice',true,true)
local members={Cabbage={getModule=function() return 'Mod' end,getUse=function() return 10 end},
    Spice={getModule=function() return 'Base' end,getUse=function() return 1 end}}
local recipe={water=0,getModule=function() return {getName=function() return 'Mod' end} end,getUntranslatedName=function() return 'Salad' end,getOriginalname=function() return 'Make Salad' end,
    getBaseItem=function() return 'Base.Bowl' end,getFullResultItem=function() return 'Mod.Salad' end,getMaxItems=function() return 6 end,
    getMinimumWater=function(self) return self.water end,getItemsList=function() return {get=function(_,t) return members[t] end} end}
-- Result registration belongs to the recipe module.
definition('Mod.Salad',true)
getScriptManager=function() return {FindItem=function(_,t) return defs[t] end,getAllEvolvedRecipes=function() return f.list({recipe}) end} end
local nativeInstance=instanceof
instanceof=function(it,class) if class=='Food' then return it.food or false end;return nativeInstance and nativeInstance(it,class) or false end
local function food(t,h)
    local x=item(t);x.food=true;x.hunger=E.float(h);x.age=0
    function x:getHungChange() return self.hunger end
    function x:getFluidContainer() return self.fluid end
    function x:isNoRecipes() return self.noRecipes or false end
    function x:isBurnt() return self.burnt or false end
    function x:isRotten() return self.rotten or false end
    function x:isCooked() return self.cooked or false end
    function x:isFrozen() return self.frozen or false end
    function x:getAge() return self.age end;function x:getOffAge() return 10 end
    return x
end
local base=item('Base.Bowl')
function base:haveExtraItems() return false end;function base:getFluidContainer() end;function base:isNoRecipes() return false end
local intent={baseType='Base.Bowl',portion='full',additions={{fullType='Mod.Cabbage',class='ingredient',count=5},{fullType='Base.Spice',class='seasoning',count=1}}}
local nodes,err=R.resolve('evolved','Mod.Salad',1,player,intent);assert(nodes,err)
assert(nodes[1].class=='base' and E.lookup('Mod.Salad')==recipe and not E.lookup('Other.Salad'))
local sameLabel={getModule=recipe.getModule,getOriginalname=recipe.getOriginalname,getUntranslatedName=function() return 'SaladClay' end}
local currentManager=getScriptManager()
getScriptManager=function() currentManager.getAllEvolvedRecipes=function() return f.list({recipe,sameLabel}) end;return currentManager end
assert(E.lookup('Mod.Salad')==recipe and E.lookup('Mod.SaladClay')==sameLabel)
local cabbage=food('Mod.Cabbage',-0.5);local spice=food('Base.Spice',-0.1)
assert(E.capacity(cabbage,10,'ingredient',0)==5)
assert(E.capacity(food('Mod.Cabbage',-0.25),10,'ingredient',0)==2)
assert(E.capacity(food('Mod.Cabbage',-0.05),10,'ingredient',0)==0)
local allocation=R.allocate(nodes,{base,cabbage,spice});assert(allocation.outstanding==0)
-- One cabbage supports five additions, rather than five physical cabbages.
inventory.items={base,cabbage,spice}
s=P.project(player,{kind='evolved',recipe='Mod.Salad',quantity=1,intent=intent,revision=data.revision})
assert(s.status=='ok' and s.outstanding==0 and #s.projects==1)
assert(s.projects[1].intent~=intent)
cabbage.hunger=E.float(-0.25);assert(P.snapshot(player).outstanding==3)
local candidate=food('Mod.Cabbage',-0.3);assert(R.worthTaking(R.ledger(player,data),candidate))
for _,flag in ipairs({'burnt','rotten','cooked','frozen','noRecipes'}) do candidate[flag]=true;assert(not R.worthTaking(R.ledger(player,data),candidate));candidate[flag]=nil end
candidate.age=10;assert(E.capacity(candidate,10,'ingredient',0)==0);candidate.age=0
candidate.fluid={};assert(E.capacity(candidate,10,'ingredient',0)==0);candidate.fluid=nil
local oldRevision=data.revision
recipe.water=1;assert(P.project(player,{kind='evolved',recipe='Mod.Salad',quantity=1,intent=intent,revision=oldRevision}).status=='evolvedUnsupported' and data.revision==oldRevision);recipe.water=0
intent.portion='partial';assert(not R.resolve('evolved','Mod.Salad',1,player,intent));intent.portion='full'
intent.additions[2].count=2;assert(not R.resolve('evolved','Mod.Salad',1,player,intent));intent.additions[2].count=1
intent.additions[1].count=7;assert(not R.resolve('evolved','Mod.Salad',1,player,intent));intent.additions[1].count=5
intent.current=999;assert(not R.resolve('evolved','Mod.Salad',1,player,intent));intent.current=nil
members.Cabbage.getModule=function() return 'Other' end;assert(not R.resolve('evolved','Mod.Salad',1,player,intent));members.Cabbage.getModule=function() return 'Mod' end
defs['Mod.Cabbage'].getReplaceOnUse=function() return 'Base.Bowl' end;assert(not R.resolve('evolved','Mod.Salad',1,player,intent));defs['Mod.Cabbage'].getReplaceOnUse=function() end
data.shopping['Mod.Cabbage']=1;assert(not R.ledger(player,data));data.shopping={}
player.skill=10;assert(E.capacity(food('Mod.Cabbage',-0.25),10,'ingredient',10)==3)
print('PASS OFFLINE native-shaped Evolved resolver: registry/module identity, base/ingredient/seasoning classes, partial physical food capacity, skill, invalid states, modded definition, spoof/fluid/partial/replacement/mixed-demand rejection')
