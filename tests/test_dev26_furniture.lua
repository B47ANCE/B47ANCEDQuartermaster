dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
require 'B47ANCEDQuartermaster/Authority'
local f=CONTAINER_FIXTURE;local Q=B47ANCEDQuartermaster;local A,T,F,Store,S=Q.Authority,Q.Targets,Q.Furniture,Q.Store,Q.Schema
local player=f.player
local function config(n) local c=S.empty();c.priority=n;c.items.RoundA=true;return c end
local function discover() local d=assert(Q.Bindings.discover(player,{scope={x=0,y=0,z=0}}));local a,b;for _,m in ipairs(d.targets) do local r=Q.Bindings.sessions[player].records[m.token];if r.target.obj==f.a then a=m.token elseif r.target.obj==f.b then b=m.token end end;return d,a,b end
local d,a,b=discover();local ta,tb=T.make(f.a,0,player),T.make(f.b,0,player)
local function load(token,whole) local r=A.handle(player,'load',{session=d.session,token=token,whole=whole});assert(r.status=='ok',r.status);return r end
local function change(token,whole,c,action,revision,confirm)
 return A.handle(player,'groupChange',{session=d.session,token=token,whole=whole,config=c,action=action,revision=revision,confirm=confirm,taxonomyVersion=7})
end
local before=f.sent();local p=load(a,true);assert(p.revision==0 and p.config.priority==0 and f.sent()==before,'viewing created shared data')
local r=change(a,true,config(5),nil,p.revision);assert(r.status=='ok');assert(Store.load(ta,player).priority==5 and Store.load(tb,player).priority==5)
local beforeCleanup=assert(F.group(ta,player));local groupID=beforeCleanup.parent.id
beforeCleanup.parent.config.cats.B47_Food=true
assert(Store.load(ta,player).priority==5 and not F.group(ta,player).parent.config.cats.B47_Food)
assert(F.group(ta,player).parent.id==groupID and F.state(tb).mode=='inherit')
local parent=F.group(ta,player).parent;parent.schema=99;parent.config.cats.B47_Food=true
local unchanged=f.sent();assert(not Store.load(ta,player) and parent.config.cats.B47_Food and f.sent()==unchanged,'future parent mutated')
parent.schema=1;parent.config.cats.B47_Food=nil
local child=load(b,false);assert(child.mode=='inherit')
assert(change(b,false,config(8),nil,child.revision).status=='invalid','implicit override allowed')
assert(change(b,false,config(8),'custom',child.revision).status=='ok');assert(Store.load(tb,player).priority==8)
p=load(a,true);assert(change(a,true,config(9),nil,p.revision).status=='ok');assert(Store.load(ta,player).priority==9 and Store.load(tb,player).priority==8)
child=load(b,false);assert(child.mode=='custom' and child.parentConfig.priority==9)
assert(change(b,false,nil,'reset',child.revision,false).status=='invalid')
assert(change(b,false,nil,'reset',child.revision,true).status=='ok');assert(Store.load(tb,player).priority==9)
p=load(a,true);assert(change(a,true,config(10),nil,p.revision).status=='ok');assert(Store.load(tb,player).priority==10)
assert(change(a,true,config(11),nil,p.revision).status=='conflict','stale parent write accepted')
child=load(b,false);p=load(a,true);assert(change(a,true,config(12),nil,p.revision).status=='ok')
assert(change(b,false,config(13),'custom',child.revision).status=='conflict','stale inherited snapshot accepted')
child=load(b,false);assert(change(b,false,config(3),'custom',child.revision).status=='ok')
p=load(a,true);assert(change(a,true,nil,'remove',p.revision,false).status=='invalid')
assert(change(a,true,nil,'remove',p.revision,true).status=='ok');assert(Store.load(ta,player).priority==12 and Store.load(tb,player).priority==3,'detach lost effective data')
-- Lossless activation cases: absent, one, identical, different, explicit empty and legacy imports.
for _,case in ipairs({{nil,nil},{4,nil},{4,4},{4,7},{0,0},{'legacy',7}}) do
 f.a.md={};f.b.md={};Q.Bindings.sessions={}
 local vals={}
 for i,t in ipairs({ta,tb}) do local v=case[i]
  if v=='legacy' then local e=S.envelope(config(6),2);e.schemaVersion=1;e.taxonomyVersion=6;e.kind=t.container:getType();e.containerCount=t.obj:getContainerCount();t.obj.md.QuartermasterSorting={schemaVersion=1,containers={['0']=e}};vals[i]=6
  elseif v~=nil then local old,_,rev=Store.rawLoad(t);assert(Store.rawCommit({target=t,original=old,revision=rev},config(v)));vals[i]=v end
 end
 d,a,b=discover();p=load(a,true);assert(change(a,true,config(15),nil,p.revision).status=='ok')
 for i,t in ipairs({ta,tb}) do assert(Store.load(t,player).priority==(vals[i] or 15),'activation overwrote section configuration') end
end
-- Two authenticated sessions share parent revisions, while child overrides remain independent.
f.a.md={};f.b.md={};Q.Bindings.sessions={};d,a,b=discover();p=load(a,true)
assert(change(a,true,config(20),nil,p.revision).status=='ok')
local peer=setmetatable({},{__index=player})
local pd=assert(Q.Bindings.discover(peer,{scope={x=0,y=0,z=0}}));local pa,pb
for _,m in ipairs(pd.targets) do local obj=Q.Bindings.sessions[peer].records[m.token].target.obj;if obj==f.a then pa=m.token elseif obj==f.b then pb=m.token end end
local pp=A.handle(peer,'load',{session=pd.session,token=pa,whole=true})
p=load(a,true);assert(change(a,true,config(21),nil,p.revision).status=='ok')
assert(A.handle(peer,'groupChange',{session=pd.session,token=pa,whole=true,config=config(99),revision=pp.revision,taxonomyVersion=7}).status=='conflict')
child=load(a,false);assert(change(a,false,config(22),'custom',child.revision).status=='ok')
local pc=A.handle(peer,'load',{session=pd.session,token=pb})
assert(A.handle(peer,'groupChange',{session=pd.session,token=pb,config=config(23),action='custom',revision=pc.revision,taxonomyVersion=7}).status=='ok')
assert(Store.load(ta,player).priority==22 and Store.load(tb,player).priority==23)
-- Engine-shaped reload with native ModData retained; live inheritance resolves new physical references.
child=load(a,false);assert(change(a,false,nil,'reset',child.revision,true).status=='ok')
local oa,ob=f.a,f.b
local na=f.object(oa.sq,f.grid,oa.pos);local nb=f.object(ob.sq,f.grid,ob.pos)
local function copy(v) if type(v)~='table' then return v end;local out={};for k,x in pairs(v) do out[k]=copy(x) end;return out end
na.md=copy(oa.md);nb.md=copy(ob.md);oa.sq.objects=f.list({na});ob.sq.objects=f.list({nb});na.members={na,nb};nb.members=na.members
assert(Store.load(T.make(na,0,player),player).priority==21)
assert(Store.load(T.make(nb,0,player),player).priority==23)
-- Copying native moveable metadata to a new position cannot silently reuse the parent.
local moved=f.square(5,0,0);na.sq.objects=f.list();na.sq=moved;moved.objects=f.list({na})
local movedB=f.square(6,0,0);nb.sq.objects=f.list();nb.sq=movedB;movedB.objects=f.list({nb})
assert(not Store.load(T.make(na,0,player),player),'moved inherited assembly silently rebound')
assert(Store.load(T.make(nb,0,player),player).priority==23,'moved custom rules lost')
na.sq=oa.sq;nb.sq=ob.sq;oa.sq.objects=f.list({oa});ob.sq.objects=f.list({ob});oa.members={oa,ob};ob.members=oa.members
-- Invalid future owned schema is rejected and not rewritten.
local saved=oa.md;oa.md={[F.key]={schema=99}};local invalid=Store.load(ta,player);assert(not invalid and oa.md[F.key].schema==99);oa.md=saved
-- New object at the anchor's coordinates has no persistent identity and cannot inherit.
local old=f.a;local replacement=f.object(old.sq,f.grid,{x=0,y=0,z=0});old.sq.objects=f.list({replacement});replacement.members={replacement,f.b};f.b.members=replacement.members
local rt=T.make(replacement,0,player);assert(Store.load(rt,player).priority==0);assert(Store.load(tb,player).priority==23,'custom orphan lost independent rules')
assert(not Q.Bindings.target(player,d.session,a),'stale handle rebound to replacement')
-- Multiple storage compartments belong to one actual physical object without adjacency inference.
local one=f.unrelatedObject;local second={getType=function() return 'freezer' end,getContainingItem=function() end,getItems=function() return f.list() end};one.containers[2]=second
assert(#F.members(T.make(one,0,player),player)==2)
assert(#T.siblings(rt,player)==2 and not F.members(T.make(f.decor,0,player),player))
print('PASS OFFLINE dev26 furniture: production inheritance, explicit overrides/reset, revisions, detach, lossless migrations, compartments and replacement rejection')
