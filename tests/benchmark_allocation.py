"""Measured host Lua 5.1 work only; no native frames, game or server ticks."""
from pathlib import Path
import json, time
from lupa.lua51 import LuaRuntime

ROOT=Path(__file__).resolve().parents[1]
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().package.path=(ROOT/'src/B47ANCEDQuartermaster/42/media/lua/shared').as_posix()+'/?.lua;'+lua.globals().package.path
lua.execute("require 'B47ANCEDQuartermaster/Schema'")
setup=lua.eval('''function()
 local A=require 'B47ANCEDQuartermaster/AllocationProfile'
 local C=require 'B47ANCEDQuartermaster/AllocationCapacity'
 local entries={};for n=1,8192 do entries[n]={name='Item '..n,fullType='Fixture.Item'..n,category='Category'..(n%32)} end
 local index=assert(A.index(entries));local profile=A.empty();profile.cats.Category1=50
 local parts={}
 for n=1,256 do
  local container={};local rows={};for m=1,32 do rows[m]={ref={},fullType='Fixture.Item'..m,path={'Category'..(m%32)},weight=.25} end
  local scope=assert(C.measure({{container=container,capacity=50,used=8,items=rows}}))
  parts[n]={container=container,capacity=50,used=8,scope=scope}
 end
 return {index=index,profile=profile,parts=parts,scope=assert(C.combine(parts)),A=A,C=C}
end''')
def measure(fn, iterations):
    start=time.perf_counter()
    fn(iterations)
    return round((time.perf_counter()-start)*1000,3)
start=time.perf_counter();ctx=setup();setup_ms=round((time.perf_counter()-start)*1000,3)
edit=lua.eval('''function(c,n) for i=1,n do c.profile=assert(c.A.setItem(c.profile,'Fixture.Item'..(i%200+1),i%101,{'Category'..(i%32)})) end end''')
resolve=lua.eval('''function(c,n) for i=1,n do assert(c.A.value(c.profile,'Fixture.Item'..(i%8192+1),{'Category'..(i%32)})~=nil) end end''')
admit=lua.eval('''function(c,n) for i=1,n do assert(c.C.check(c.profile,c.scope,{}, {ref={},destination=c.parts[1].container,fullType='Fixture.Other',path={'Category2'},weight=.1})) end end''')
combine=lua.eval('''function(c,n) for i=1,n do assert(c.C.combine(c.parts).capacity==12800) end end''')
lua.execute('collectgarbage("collect")');before=lua.eval('collectgarbage("count")')
report={'environment':'Host Python + Lupa Lua 5.1; native/dedicated NOT TESTED','catalog_items':8192,'physical_containers':256,'captured_item_instances':8192,'setup_ms':setup_ms,
        '200_sparse_edits_ms':measure(lambda n:edit(ctx,n),200),
        '100000_value_resolutions_ms':measure(lambda n:resolve(ctx,n),100000),
        '1000_admissions_ms':measure(lambda n:admit(ctx,n),1000),
        '100_combined_room_scopes_ms':measure(lambda n:combine(ctx,n),100)}
lua.execute('collectgarbage("collect")');report['retained_growth_kib']=round(lua.eval('collectgarbage("count")')-before,3)
print(json.dumps(report,indent=2))
