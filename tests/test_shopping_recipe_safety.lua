dofile(TEST_ROOT..'/test_recipe_shopping.lua')
local Q=B47ANCEDQuartermaster;local f=CONTAINER_FIXTURE;f.network(false,true)
local P,A=Q.Personal,Q.ShoppingAdds;local player=f.player;local _,d=P.identity(player)
d.shopping={};d.projects={};d.wish={};d.wishDemand={};d.needed={};d.neededDemand={};d.extras={};d.addReceipts={};d.lastAdd=nil;player:getInventory().items={}
local time=90000;getTimestampMs=function() return time end
local serial=0
local function add(kind,name,origin)
 time=time+1000;serial=serial+1
 local args={kind=kind,recipe=name,quantity=2,origin=origin,operation='recipe:'..serial,revision=d.revision}
 return Q.Authority.handle(player,'shoppingAdd',args),args
end
for _,case in ipairs({{'craft','Boards'},{'build','Frame'},{'craft','Boards','cook'}}) do
 local kind,name,origin=unpack(case)
 local first,args=add(kind,name,origin);assert(first.status=='ok')
 assert(A.handle(player,args).replayed)
 local result,again=add(kind,name,origin);assert(result.status=='duplicate')
 again.confirmation=result.confirmation;again.mode='again';assert(A.handle(player,again).status=='ok')
 local key=Q.ShoppingRequirements.projectKey(kind,name,nil,origin);assert(d.projects[key].quantity==4)
 assert(A.handle(player,again).replayed and d.projects[key].quantity==4)
end
assert(d.projects['craft:Boards'].quantity==4 and d.projects['craft:Boards@cook'].quantity==4,'Project Cook provenance merged into ordinary crafting')
assert(Q.Authority.handle(player,'personalProject',{kind='craft',recipe='Boards',quantity=2,add=true,revision=d.revision}).status=='invalid','legacy add flag bypassed operation safety')
local before=d.revision;local unsupported=add('craft','Fluid');assert(unsupported.status=='unsupported' and d.revision==before)
assert(P.project(player,{kind='craft',recipe='Boards',quantity=0,revision=d.revision}).status=='ok' and d.projects['craft:Boards@cook'],'ordinary source removal deleted Cook source')
print('PASS OFFLINE Crafting/Building/Project Cook add provenance: same protected dispatcher, duplicate challenge, intentional repeat and replay, unsupported atomic rejection, independent source removal and legacy-add bypass rejection')
