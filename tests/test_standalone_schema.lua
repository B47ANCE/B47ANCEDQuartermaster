-- No Quartermaster globals or installed files are needed by the replacement schema.
assert(LootSorter==nil,'standalone test must not load Quartermaster')
local savedNext=next; next=nil
local S=require 'B47ANCEDQuartermaster/Schema'
local c=S.empty(); c.cats.Food=true;c.items.Apple=true;c.presets.Meals=7;c.priority=12
assert(S.valid(c))
local e=S.envelope(c,1,true);c.cats.Food=nil
assert(e.config.cats.Food,'commit alias')
local legacy={LSBox={['0']={Tools=true}},LSBoxItems={['0']={Hammer=true}},LSBoxPresets={['0']={Meals=7}},LSBoxPriority={['0']=4}}
local got,err,imported,rev=S.read(nil,legacy,0)
assert(not err and imported and rev==0 and got.items.Hammer and got.presets.Meals==7 and got.priority==4)
got.items.Hammer=nil;assert(legacy.LSBoxItems['0'].Hammer,'import mutated legacy')
got,err,imported=S.read(e,legacy,0);assert(not err and not imported and got.items.Apple)
assert(not S.read({schemaVersion=99},legacy,0),'future native schema fell back to legacy')
assert(not S.read({},legacy,0),'corrupt native data fell back to legacy')
e.taxonomyVersion=99;assert(not S.read(e,legacy,0),'future taxonomy accepted');e.taxonomyVersion=1
assert(S.read(nil,nil,0).priority==0)
assert(not S.read(nil,{LSBox=true},0))
assert(not S.read(nil,{LSBoxPriority={['0']='oops'}},0))
for _,value in ipairs({math.huge,-math.huge,0.5,2^53}) do local x=S.empty();x.priority=value;assert(not S.valid(x)) end
local x=S.empty();x.items.x=x;assert(not S.valid(x),'recursive payload accepted')
x=S.empty();x.whole=true;assert(not S.valid(x),'UI state accepted')
x=S.empty();x.items['']=true;assert(not S.valid(x))
x=S.empty();x.items.x=false;assert(not S.valid(x))
local effective=S.effective(e.config,{Meals={gen=7,cats={Drinks=true},items={Water=true}}})
assert(effective.items.Water and effective.cats.Food and not e.config.items.Water)
assert(not S.effective(e.config,{Meals={gen=8,cats={},items={Water=true}}}).items.Water,'recreated preset relinked')
assert(S.equal(e.config,S.copy(e.config)))
next=savedNext
print('PASS standalone schema: validation, independent copies, legacy precedence, absent dependency, preset generations')
