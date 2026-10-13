dofile(TEST_ROOT..'/test_shopping_ui.lua')
local Q=B47ANCEDQuartermaster;local U=require 'B47ANCEDQuartermaster/ProjectCookUI'
function ISButton:getX() return self.x end;function ISButton:getY() return self.y end
function ISTextEntryBox:getY() return self.y end
local window=Q.openPicker(CONTAINER_FIXTURE.a,0,0);local shopping=window.shoppingUI
local requests={};Q.Authority.request=function(_,command,args,callback)
    if command=='personalList' then callback({status='ok',revision=19})
    else requests[#requests+1]={command=command,args=args};callback({status='ok'}) end
end
shopping.lists={revision=1,manual={},wish={['Base.Nails']=222},wishGoals={['Base.Nails']={target=222,current=137,remaining=85,fulfilled=false}},requirements={}}
shopping.selected='Base.Nails';shopping.rebuild()
assert(shopping.remaining.enable and shopping.collectRemaining.enable)
local collectWish;Q.Collector={active={},start=function(_,_,_,wish) collectWish=wish;return true end}
package.loaded['B47ANCEDQuartermaster/Collector']=true
local standardRequest=Q.Authority.request
Q.Authority.request=function(_,command,args,callback)
    if command=='personalList' then callback(shopping.lists);return end
    assert(command=='shoppingAdd' and args.kind=='wanted' and args.operation and args.fullType=='Base.Nails' and args.revision==1)
    callback(shopping.lists)
end
shopping.lists.status='ok';shopping.collectRemaining.onclick(window);assert(collectWish=='Base.Nails')
shopping.lists.wishGoals['Base.Nails']={target=222,current=247,remaining=0,fulfilled=true};shopping.rebuild()
assert(not shopping.remaining.enable and not shopping.collectRemaining.enable)
local replies={};Q.Authority.request=function(_,_,_,cb) replies[#replies+1]=cb end
shopping.refresh();shopping.refresh()
local newer={status='ok',revision=1,manual={},wish={},wishGoals={},requirements={},marker='newer'}
replies[2](newer);replies[1]({status='ok',revision=1,manual={},wish={},wishGoals={},requirements={},marker='older'})
assert(shopping.lists==newer,'same-revision older inventory snapshot replaced newer possession')
Q.Authority.request=standardRequest
local probes=0;Q.ShoppingRequirements.resolve=function(kind,id,n,player,intent)
    probes=probes+1;return {{accepts=function() return true end}}
end
local recipe={getName=function() return 'NativeCookingRecipe' end}
local created,updated,laid=0,0,0
local craft=ISPanel:derive('CookCraftFixture')
function craft:createChildren()
    created=created+1;self.craftButton=ISButton:new(60,10,40,40,'Craft',self,function() error('native craft executed') end)
    self.quantityInput=ISTextEntryBox:new('4',10,130,80,20);self.quantityInput:setText('4');self:addChild(self.craftButton);self:addChild(self.quantityInput)
end
function craft:update() updated=updated+1 end
U.install(craft,'craft');U.install(craft,'craft')
local p=craft:new(0,0,160,160);p.player={getPlayerNum=function() return 0 end};p.logic={getRecipe=function() return recipe end}
p:createChildren();p:update();assert(created==1 and updated==1 and p.b47CookShopping.enable)
assert(p.craftButton.x==60 and p.craftButton.width==40 and p.quantityInput.y==130)
assert(p.b47CookShopping.y>=50 and p.b47CookShopping.y+24<p.quantityInput.y)
local name,intent,n=U.selection(p,'craft');assert(name=='NativeCookingRecipe' and n==4 and not intent)
Q.RecipeShoppingUI.submit(0,'craft',name,n,function() end)
assert(requests[1].args.recipe==name and requests[1].args.quantity==4 and requests[1].args.revision==19 and requests[1].args.ingredients==nil)
local evolved={getModule=function() return {getName=function() return 'Base' end} end,getUntranslatedName=function() return 'Salad' end}
local queued={{portionPolicy='full_only',panelType='Ingredient',displayItem={getFullType=function() return 'Base.Cabbage' end}},
    {portionPolicy='full_only',panelType='Ingredient',displayItem={getFullType=function() return 'Base.Cabbage' end}},
    {portionPolicy='full_only',panelType='Seasoning',displayItem={getFullType=function() return 'Base.Salt' end}}}
local evo={getRecipe=function() return evolved end,getBaseItem=function() return {getFullType=function() return 'Base.Bowl' end} end,
    getPreCookItems=function() return queued end}
local info=ISPanel:derive('CookInfoFixture')
function info:createChildren() created=created+1;self.normal=ISButton:new(1,2,20,20,'Switch',self,function() end);self:addChild(self.normal) end
function info:calculateLayout(w,h) laid=laid+1;self:setWidth(w or 160);self:setHeight(math.max(100,h));self.normal:setX(1);self.normal:setY(2) end
function info:update() updated=updated+1 end
U.install(info,'evolved');local v=info:new(0,0,160,160);v.player=p.player;v.EvoPanel=evo
v:createChildren();v:calculateLayout(160,160);v:update();assert(v.b47CookShopping.enable and v.normal.x==1 and v.normal.y==2)
local h=v:getHeight();v:calculateLayout(160,160);assert(v:getHeight()==h and v.b47CookShopping.y+24<=h)
name,intent,n=U.selection(v,'evolved');assert(name=='Base.Salad' and n==1 and intent.portion=='full' and intent.additions[1].count==2)
Q.RecipeShoppingUI.submit(0,'evolved',name,2,function() end,intent)
assert(requests[2].args.intent==intent and requests[2].args.quantity==2 and requests[2].args.ingredients==nil)
queued[1].portionPolicy='partial_first';assert(U.selection(v,'evolved')==nil);queued[1].portionPolicy='full_only'
local owned=require;local optionalRequires=0
require=function(name) if name:find('Project_Cook/',1,true) then optionalRequires=optionalRequires+1;error('absent') end;return owned(name) end
getActivatedMods=function() return {contains=function() return false end} end;U.start();assert(optionalRequires==0)
getActivatedMods=function() return {contains=function() return true end} end;U.start();assert(optionalRequires==2)
require=owned
-- Selected unsupported recipes explain themselves without sending a project.
local explained,prompts,submitted=nil,0,{}
Q.RecipeShoppingUI.explain=function(_,key) explained=key end
Q.RecipeShoppingUI.prompt=function(default,callback) prompts=prompts+1;callback(default) end
Q.RecipeShoppingUI.submit=function(playerNum,kind,id,quantity,callback,intent)
    submitted[#submitted+1]={playerNum=playerNum,kind=kind,id=id,quantity=quantity,intent=intent};callback({status='ok'})
end
local supported=Q.ShoppingRequirements.resolve
Q.ShoppingRequirements.resolve=function() return nil,'unsupported' end
p.b47CookRefresh=0;p.b47CookSignature=nil;p:update()
assert(p.b47CookShopping.enable,'selected unsupported recipe cannot explain itself')
p.b47CookShopping.onclick(p);assert(explained=='unsupported' and prompts==0 and #submitted==0)
queued[1].portionPolicy='partial_first';v.b47CookRefresh=0;v:update()
assert(v.b47CookShopping.enable);v.b47CookShopping.onclick(v)
assert(explained=='evolvedUnsupported' and #submitted==0)
queued[1].portionPolicy='full_only';Q.ShoppingRequirements.resolve=supported
p.b47CookShopping.onclick(p);assert(submitted[1].kind=='craft' and submitted[1].quantity==4)
-- Optional Neat hooks use their native recipe/quantity interface and reserve
-- independent footer space; original actions are never invoked by Shopping.
local neatCraft=ISPanel:derive('NeatCraftFixture')
function neatCraft:createChildren() self.quantityInput=ISTextEntryBox:new('3',0,0,80,24);self.quantityInput:setText('3') end
function neatCraft:calculateLayout(w,h)
    self.quantityInput:setY(self:getHeight()-28);self:setWidth(w);self:setHeight(h)
end
local neatBuild=ISPanel:derive('NeatBuildFixture')
function neatBuild:createChildren() end
function neatBuild:calculateLayout(w) self:setWidth(w);self:setHeight(90) end
NC_CraftActionPanel=neatCraft;NB_BuildingInfoDetailPanel=neatBuild
local imported={}
getActivatedMods=function() return {contains=function(_,id) return id=='Neat_Crafting' or id=='Neat_Building' end} end
require=function(path)
    if path=='Neat_Crafting/NC_CraftActionPanel' or path=='Neat_Building/nb_buildinginfodetailpanel' then imported[path]=(imported[path] or 0)+1;return true end
    if path:find('Project_Cook/',1,true) then error('Project Cook should remain optional') end
    return owned(path)
end
U.start();require=owned
assert(imported['Neat_Crafting/NC_CraftActionPanel']==1 and imported['Neat_Building/nb_buildinginfodetailpanel']==1)
for _,entry in ipairs({{class=neatCraft,kind='craft',quantity=3},{class=neatBuild,kind='build',quantity=1}}) do
    local panel=entry.class:new(0,0,240,160);panel.player=p.player;panel.logic=p.logic
    panel:createChildren();panel:calculateLayout(240,160);panel:update()
    local height=panel:getHeight();panel:calculateLayout(240,160)
    assert(panel:getHeight()==height and panel.b47CookShopping.y+24<=height)
    if panel.quantityInput then assert(panel.quantityInput.y+24<panel.b47CookShopping.y,'Neat footer overlaps quantity controls') end
    assert(panel.b47CookShopping.enable);panel.b47CookShopping.onclick(panel)
    local sent=submitted[#submitted];assert(sent.kind==entry.kind and sent.quantity==entry.quantity and sent.id=='NativeCookingRecipe' and sent.intent==nil)
    panel.logic={getRecipe=function() return nil end};panel.b47CookRefresh=0;panel:update();assert(not panel.b47CookShopping.enable)
end
-- Periodic inventory refresh preserves the outcome rather than hiding it.
shopping.lists={revision=1,gross=2,carried=1,outstanding=1,collected=1,manual={},wish={},requirements={}}
shopping.collectionResult='done';shopping.rebuild()
local message=shopping.status.name;assert(message:find('UI_QMSS_CollectionResult',1,true))
shopping.rebuild();assert(shopping.status.name==message and shopping.status.tooltip:find('UI_QMSS_ShoppingTotals',1,true))
print('PASS OFFLINE optional Cook frontend: native recipe/execution identity, queued minimal intent, unsupported partial mode, additive stable geometry/delegation, absent-mod no require and unavailable-hook safety')
print('PASS OFFLINE Neat Crafting/Building: optional imports, footer geometry, recipe/execution intent, no-selection disable, unsupported explanation without project and persistent collection outcome')
