-- Owned implementation with synthetic native-shaped objects; never native MP proof.
dofile(TEST_ROOT..'/test_consolidated.lua')
local Q=B47ANCEDQuartermaster;local P,F,R,A=Q.Personal,Q.ShoppingPreferences,Q.ShoppingRequirements,Q.ShoppingAdds
local f=CONTAINER_FIXTURE;f.network(false,true);local player=f.player;local inv=player:getInventory()
local movementTemplate=inv.items[1]
local _,d=P.identity(player)
local clock=100000;getTimestampMs=function() return clock end
local nonce=0
ItemType={WEAPON='weapon',CLOTHING='clothing',ALARM_CLOCK_CLOTHING='alarmClothing',FOOD='food',DRAINABLE='drainable',NORMAL='normal'}
local definitions={['Base.Nails']='normal',['Base.Glue']='normal',['Base.Knife']='weapon',['Base.Coat']='clothing',['Base.Soup']='food',['Base.Bottle']='drainable'}
getScriptManager=function() return {FindItem=function(_,t) if definitions[t] then return {getDisplayName=function() return t end,getItemType=function() return definitions[t] end} end end} end
instanceof=function(it,c) return it.class==c end
local serial=40000
local function item(t,class)
 serial=serial+1;local id=serial
 local i=setmetatable({id=id,class=class,container=inv,md={},condition=5,max=10,uses=.5,age=0,off=10},{__index=movementTemplate})
 function i:getFullType() return t end
 function i:getCondition() return self.condition end;function i:getConditionMax() return self.max end
 function i:getCurrentUsesFloat() return self.uses end
 function i:getAge() return self.age end;function i:getOffAge() return self.off end
 function i:isRotten() return self.rotten or false end;function i:isCooked() return self.cooked or false end;function i:isFrozen() return self.frozen or false end
 return i
end
local function reset()
 d.shopping={};d.projects={};d.wish={};d.wishDemand={};d.needed={};d.neededDemand={};d.extras={};d.addReceipts={};d.lastAdd=nil
 d.shoppingSchema=2;d.wishSchema=2;d.dibsListSchema=1;d.preferences=F.normalize(nil);inv.items={}
 Q.Movement.runs[player]=nil;Q.Movement.operations[player]=nil
end
local function change(kind,t,n) return P.change(player,{kind=kind,fullType=t,quantity=n,revision=d.revision}) end
local function add(kind,t,n,bulk)
 clock=clock+1000;nonce=nonce+1
 local args={kind=kind,fullType=t,quantity=n,bulk=bulk,revision=d.revision,operation='test:'..nonce}
 return A.handle(player,args),args
end
local function preference(args) args.revision=d.revision;return F.edit(player,args) end
reset()
local knife=item('Base.Knife','HandWeapon');local food=item('Base.Soup','Food');local bottle=item('Base.Bottle','DrainableComboItem')
knife.condition=0;food.rotten=true;food.cooked=true;food.frozen=true;bottle.uses=0
local any=F.compile(nil);assert(any(knife) and any(food) and any(bottle),'default ANY narrowed physical eligibility')
for _,threshold in ipairs({25,50,75,100}) do
 knife.max=100;knife.condition=threshold;bottle.uses=threshold/100
 local accepts=F.compile({schema=1,global={condition=threshold,uses=threshold},overrides={},confirm=true})
 assert(accepts(knife) and accepts(bottle));knife.condition=threshold-1;bottle.uses=(threshold-.1)/100
 assert(not accepts(knife) and not accepts(bottle))
end
knife.max=10;knife.condition=0;bottle.uses=0
local explicitAny=F.compile({schema=1,global={condition=100,uses=100},overrides={['Base.Knife']={condition=0},['Base.Bottle']={uses=0}},confirm=true})
knife.max=0;assert(explicitAny(knife) and explicitAny(bottle),'explicit ANY performed restrictive state checks');knife.max=10
assert(not F.rule({condition=-1}) and not F.rule({uses=101}) and not F.rule({uses=0/0}) and not F.rule({cooked='bad'}) and not F.rule({mystery=1}))
assert(F.rule({freshness='any',rotten='exclude'}).rotten=='exclude')
assert(not F.compile({schema=1,global={freshness='any',rotten='exclude'},overrides={},confirm=true})(food))
assert(preference({action='global',rule={condition=50,uses=50,freshness='fresh',cooked='no',frozen='no',rotten='exclude'}}).status=='ok')
assert(not F.compile(d.preferences)(knife) and not F.compile(d.preferences)(food) and not F.compile(d.preferences)(bottle))
knife.condition=5;bottle.uses=.5;food.rotten=false;food.cooked=false;food.frozen=false
assert(F.compile(d.preferences)(knife) and F.compile(d.preferences)(food) and F.compile(d.preferences)(bottle))
knife.condition=4;bottle.uses=.49;food.age=10
assert(not F.compile(d.preferences)(knife) and not F.compile(d.preferences)(food) and not F.compile(d.preferences)(bottle))
assert(preference({action='override',fullType='Base.Knife',rule={condition=0}}).status=='ok' and F.compile(d.preferences)(knife))
assert(preference({action='override',fullType='Base.Knife',rule={freshness='fresh'}}).status=='invalid')
assert(preference({action='override',fullType='Base.Nails',rule={}}).status=='invalid')
assert(preference({action='remove',fullType='Base.Knife'}).status=='ok' and not F.compile(d.preferences)(knife))
assert(preference({action='override',fullType='Base.Knife',rule={}}).status=='ok' and not d.preferences.overrides['Base.Knife'],'inherit-only override persisted redundant defaults')
assert(preference({action='resetAll'}).status=='ok' and F.compile(d.preferences)(knife) and d.preferences.confirm)
d.preferences={schema=123};local preserved=d.preferences
assert(P.snapshot(player).status=='schema' and d.preferences==preserved,'future preferences were erased by a read')
d.preferences={schema=1,global={condition='invalid'},overrides={},confirm=true};preserved=d.preferences
assert(P.snapshot(player).status=='schema' and d.preferences==preserved,'corrupt preferences silently relaxed filters')
d.preferences=nil;assert(P.snapshot(player).preferences.confirm,'absent preferences did not initialize defaults')
-- Both goal lists share actual qualifying carried stock, without adding overlap.
reset();d.wishSchema=1;d.wish['Base.Nails']=4;d.wishProgress={['Base.Nails']=3};d.dibsListSchema=nil
local s=P.snapshot(player);assert(s.wanted['Base.Nails']==4 and s.wantedGoals['Base.Nails'].current==0 and not s.needed['Base.Nails'] and not d.wishProgress)
change('needed','Base.Nails',2);inv.items={item('Base.Nails'),item('Base.Nails'),item('Base.Nails')}
s=P.snapshot(player);assert(s.wantedGoals['Base.Nails'].remaining==1 and s.neededGoals['Base.Nails'].current==3 and s.neededGoals['Base.Nails'].fulfilled)
local x=item('Base.Glue');inv.items[#inv.items+1]=x
assert(Q.Dibs.transition(player,x,'needed'));assert(d.needed['Base.Glue']==1 and not d.wish['Base.Glue'])
change('needed','Base.Glue',8);Q.Dibs.transition(player,x,'none');Q.Dibs.transition(player,x,'needed');assert(d.needed['Base.Glue']==8)
change('needed','Base.Glue',0);assert(Q.Dibs.state(x).players[P.identity(player)].state=='needed','list removal cleared physical mark')
Q.Dibs.transition(player,x,'none')
reset();change('wanted','Base.Nails',4);change('needed','Base.Nails',2)
assert(add('wanted','Base.Nails').status=='ok');assert(add('needed','Base.Nails').status=='ok')
s=P.snapshot(player);assert(s.gross==4 and s.outstanding==4 and s.summaries.wanted.remaining==4 and s.summaries.needed.remaining==2)
inv.items={item('Base.Nails'),item('Base.Nails'),item('Base.Nails')}
s=P.snapshot(player);assert(s.outstanding==1 and s.wantedGoals['Base.Nails'].current==3 and s.neededGoals['Base.Nails'].current==3)
inv.items={};change('wanted','Base.Nails',6);assert(P.snapshot(player).outstanding==6)
assert(A.remove(player,{kind='wanted',fullType='Base.Nails',revision=d.revision}).status=='ok' and P.snapshot(player).gross==2 and d.wish['Base.Nails']==6)
change('needed','Base.Nails',0);assert(not d.neededDemand['Base.Nails'] and d.wish['Base.Nails']==6)
-- Manual addition: challenge does not mutate, repeated pending token stable,
-- confirmed addition accumulates once; replay/rapid fresh nonce cannot repeat.
reset();local first,initial=add('shopping','Base.Nails',5);assert(first.status=='ok' and d.shopping['Base.Nails']==5)
assert(A.handle(player,initial).replayed and d.shopping['Base.Nails']==5)
local result,args=add('shopping','Base.Nails',40);assert(result.status=='duplicate' and d.shopping['Base.Nails']==5)
assert(A.handle(player,args).confirmation==result.confirmation)
args.confirmation='spoof';args.mode='again';assert(A.handle(player,args).status=='conflict')
args.confirmation=result.confirmation;assert(A.handle(player,args).status=='ok' and d.shopping['Base.Nails']==45)
assert(A.handle(player,args).replayed and d.shopping['Base.Nails']==45)
args.quantity=1;assert(A.handle(player,args).status=='invalid');args.quantity=40
local rapid={kind='shopping',fullType='Base.Nails',quantity=40,revision=d.revision,operation='rapid'}
assert(A.handle(player,rapid).replayed and d.shopping['Base.Nails']==45)
local stale={kind='shopping',fullType='Base.Nails',quantity=40,revision=-1,operation='stale'};assert(A.handle(player,stale).status=='conflict')
assert(preference({action='confirm',value=false}).status=='ok')
local off,offArgs=add('shopping','Base.Nails',2);assert(off.status=='ok' and d.shopping['Base.Nails']==47)
assert(A.handle(player,offArgs).replayed and d.shopping['Base.Nails']==47)
-- A reconnect uses the existing account identity and persisted receipt, not an
-- object-reference trust boundary or a newly credited history counter.
local reconnect=setmetatable({},{__index=player});assert(A.handle(reconnect,offArgs).replayed and P.identity(reconnect)==P.identity(player))
f.network(true,false);assert(Q.Authority.handle(player,'shoppingAdd',offArgs).status=='invalid');f.network(false,true)
-- Mixed bulk is one atomic challenge. Cancel means no second request; newOnly
-- links only new sources. Confirmed repeat creates independent extra demand.
reset();change('wanted','Base.Nails',4);change('wanted','Base.Glue',2);assert(add('wanted','Base.Nails').status=='ok')
result,args=add('wanted',nil,nil,true);assert(result.status=='duplicate' and result.new==1 and result.duplicate==1 and not d.wishDemand['Base.Glue'])
assert(P.snapshot(player).gross==4,'opening/cancelling challenge mutated shopping')
args.confirmation=result.confirmation;args.mode='newOnly';assert(A.handle(player,args).status=='ok' and P.snapshot(player).gross==6 and #P.snapshot(player).extras==0)
result,args=add('wanted',nil,nil,true);assert(result.status=='duplicate' and result.duplicate==2)
args.confirmation=result.confirmation;args.mode='again';assert(A.handle(player,args).status=='ok')
s=P.snapshot(player);assert(s.gross==12 and #s.extras==2)
change('wanted','Base.Glue',0);s=P.snapshot(player);assert(s.gross==10 and #s.extras==2,'removing goal deleted explicit extra provenance')
assert(A.remove(player,{kind='extra',key=s.extras[1].key,revision=d.revision}).status=='ok')
reset();change('needed','Base.Nails',3);preference({action='confirm',value=false});assert(add('needed','Base.Nails').status=='ok')
assert(add('needed','Base.Nails').status=='ok' and #P.snapshot(player).extras==0,'confirmation OFF destroyed linked idempotence')
clock=clock+1000;nonce=nonce+1;assert(A.handle(player,{kind='needed',fullType='Base.Nails',again=true,operation='explicit:'..nonce,revision=d.revision}).status=='ok' and #P.snapshot(player).extras==1)
-- Preferences change both possession credit and all ordinary ledger nodes.
reset();change('wanted','Base.Knife',2);change('needed','Base.Knife',1);change('shopping','Base.Knife',1)
knife.condition=4;inv.items={knife};preference({action='global',rule={condition=50}})
s=P.snapshot(player);assert(s.wantedGoals['Base.Knife'].current==0 and s.neededGoals['Base.Knife'].current==0 and s.carried==0)
assert(add('wanted','Base.Knife').status=='ok');assert(add('needed','Base.Knife').status=='ok')
assert(P.snapshot(player).gross==3 and P.snapshot(player).outstanding==3)
knife.condition=5;assert(P.snapshot(player).outstanding==2 and P.snapshot(player).neededGoals['Base.Knife'].fulfilled)
-- Same native movement grant: Needed first, then Wanted, then ordinary manual;
-- physical condition changes between offer and TAKE revoke authorization.
reset();change('shopping','Base.Glue',1);change('wanted','Base.Nails',1);change('needed','Base.Knife',1)
add('wanted','Base.Nails');add('needed','Base.Knife');preference({action='global',rule={condition=50}})
local source=f.a.containers[1];source.items={item('Base.Glue'),item('Base.Nails'),item('Base.Knife','HandWeapon'),item('Base.Knife','HandWeapon')}
for _,i in ipairs(source.items) do i.container=source end
local begin=Q.Shopping.handle(player,'shoppingBegin',{});assert(begin.status=='ok')
local offer=Q.Shopping.handle(player,'shoppingNext',{run=begin.run});assert(offer.status=='ok')
local op=Q.Movement.runs[player].operations[offer.operation];assert(op.item:getFullType()=='Base.Knife','Needed priority lost to closer/earlier ordinary stock')
local ranked=R.ledger(player,d);assert(R.priority(ranked,source.items[1])==1 and R.priority(ranked,source.items[2])==2 and R.priority(ranked,source.items[3])==3)
assert(Q.Authority.handle(player,'shoppingPreference',{action='resetAll',revision=d.revision}).status=='busy')
op.item.condition=1;assert(Q.Movement.handle(player,'moveTake',{operation=op.id}).status=='invalid','final TAKE ignored physical preference change')
Q.Movement.handle(player,'moveCancel',{operation=op.id})
offer=Q.Shopping.handle(player,'shoppingNext',{run=begin.run});assert(offer.status=='ok' and Q.Movement.runs[player].operations[offer.operation].item~=op.item)
Q.Shopping.handle(player,'shoppingCancel',{run=begin.run})
print('PASS OFFLINE dev.5: ANY/native-state preferences, inheritance/reset/corruption; legacy migration and Wanted/Needed possession overlap; manual/bulk duplicate challenge, replay/reconnect/rapid activation, linked versus extra provenance; Needed priority and final TAKE revalidation')
