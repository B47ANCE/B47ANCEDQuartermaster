dofile(TEST_ROOT..'/test_wish_cooking.lua')
local Q=B47ANCEDQuartermaster;local P,A=Q.Personal,Q.ShoppingAdds;local f=CONTAINER_FIXTURE;f.network(false,true)
local player=f.player;local _,d=P.identity(player);local original=P.snapshot(player).projects[1]
assert(original and original.kind=='evolved')
d.shopping={};d.projects={};d.wish={};d.wishDemand={};d.needed={};d.neededDemand={};d.extras={};d.addReceipts={};d.lastAdd=nil
local now=400000;getTimestampMs=function() return now end
local args={kind='evolved',recipe=original.recipe,intent=original.intent,origin='cook',quantity=1,operation='cook-evolved-1',revision=d.revision}
local first=A.handle(player,args);assert(first.status=='ok' and first.projects[1].origin=='cook')
assert(A.handle(player,args).replayed)
now=now+1000;args={kind='evolved',recipe=original.recipe,intent=original.intent,origin='cook',quantity=1,operation='cook-evolved-2',revision=d.revision}
local duplicate=A.handle(player,args);assert(duplicate.status=='duplicate')
args.confirmation=duplicate.confirmation;args.mode='again';assert(A.handle(player,args).status=='ok' and P.snapshot(player).projects[1].quantity==2)
assert(A.handle(player,args).replayed and P.snapshot(player).projects[1].quantity==2)
local before=P.snapshot(player).carried
assert(Q.ShoppingPreferences.edit(player,{action='global',rule={cooked='yes'},revision=d.revision}).status=='ok')
assert(P.snapshot(player).carried<before,'Evolved node bypassed shared preference evaluator')
print('PASS OFFLINE Project Cook Evolved add safety: native intent re-resolution, Cook provenance, duplicate/replay/execution increment and shared food preference predicate')
