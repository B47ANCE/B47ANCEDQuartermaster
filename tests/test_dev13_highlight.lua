-- Client outline ownership and lifecycle; actual native rendering remains untested.
dofile(TEST_ROOT..'/fixtures/containers.lua')
local H=require 'B47ANCEDQuartermaster/WorldHighlight'
local f=CONTAINER_FIXTURE
local calls={}
for _,obj in ipairs({f.a,f.b}) do
 obj.highlighted=false
 obj.isOutlineHighlight=function(self) return self.highlighted end
 obj.setOutlineHighlight=function(self,_,value) self.highlighted=value;calls[#calls+1]={self,value} end
 obj.setOutlineHlAttached=function() end
end
local h=H.new(0)
local first={obj=f.a,ci=0,container=f.a:getContainerByIndex(0)}
local second={obj=f.b,ci=0,container=f.b:getContainerByIndex(0)}
h:select(first);assert(h.owned==f.a and f.a.highlighted)
h:select(first);assert(#calls==1,'repeat selection reset native outline')
h:select(second);assert(not f.a.highlighted and f.b.highlighted and h.owned==f.b)
h:setEnabled(false);assert(not f.b.highlighted and not h.owned)
h:setEnabled(true,first);assert(f.a.highlighted)
h:select(nil);assert(not f.a.highlighted and not h.owned,'virtual row retained world highlight')
f.b.highlighted=true
h:select(second);assert(h.target==f.b and not h.owned)
h:clear();assert(f.b.highlighted,'cleared an outline not owned by Quartermaster')
f.b.highlighted=false
h:select(second);assert(h.owned==f.b)
f.b.sq:getObjects()[1]=nil
h:tick(second);assert(not h.owned and not f.b.highlighted,'removed object retained highlight')
print('PASS OFFLINE dev.13 selected outline, previous cleanup, virtual rows, existing outline ownership, invalid object')
