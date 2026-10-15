-- No Quartermaster globals or installed files are needed by the replacement schema.
assert(LootSorter==nil,'standalone test must not load Quartermaster')
local savedNext=next; next=nil
local S=require 'B47ANCEDQuartermaster/Schema'
local c=S.empty(); c.cats.B47_Native_466F6F64=true;c.items.Apple=true;c.presets.Meals='b47:7';c.priority=12
assert(S.valid(c))
local e=S.envelope(c,1,true);c.cats.B47_Native_466F6F64=nil
assert(e.config.cats.B47_Native_466F6F64,'commit alias')
local legacy={LSBox={['0']={Tools=true}},LSBoxItems={['0']={Hammer=true}},LSBoxPresets={['0']={Meals=7}},LSBoxPriority={['0']=4}}
local got,err,imported,rev=S.read(nil,legacy,0)
assert(not err and not imported and rev==0 and not got.items.Hammer and got.priority==0)
got,err,imported=S.read(e,legacy,0);assert(not err and not imported and got.items.Apple)
assert(not S.read({schemaVersion=99},legacy,0),'future schema accepted')
assert(not S.read({},legacy,0),'corrupt schema accepted')
e.taxonomyVersion=99;assert(not S.read(e));e.taxonomyVersion=7
assert(S.read(nil).priority==0)
for _,value in ipairs({math.huge,-math.huge,0.5,2^53}) do local x=S.empty();x.priority=value;assert(not S.valid(x)) end
local x=S.empty();x.items.x=x;assert(not S.valid(x),'recursive payload accepted')
x=S.empty();x.whole=true;assert(not S.valid(x),'UI state accepted')
x=S.empty();x.items['']=true;assert(not S.valid(x))
x=S.empty();x.items.x=false;assert(not S.valid(x))
local effective=S.effective(e.config,{Meals={owned=true,gen=7,cats={B47_Native_4472696E6B73=true},items={Water=true}}})
assert(effective.items.Water and effective.cats.B47_Native_466F6F64 and not e.config.items.Water)
assert(not S.effective(e.config,{Meals={owned=true,gen=8,cats={},items={Water=true}}}).items.Water,'recreated preset relinked')
assert(S.equal(e.config,S.copy(e.config)))
next=savedNext
print('PASS standalone schema: validation, independent copies, no legacy fallback, absent dependency, preset generations')
