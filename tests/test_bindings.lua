dofile(TEST_ROOT..'/fixtures/containers.lua')
require 'B47ANCEDQuartermaster/Configuration'
require 'B47ANCEDQuartermaster/Targets'
CONTAINER_FIXTURE.origin=B47ANCEDQuartermaster.Targets.make(CONTAINER_FIXTURE.a,0,CONTAINER_FIXTURE.player)
local f=CONTAINER_FIXTURE
local B=require 'B47ANCEDQuartermaster/Bindings'
local player=f.player
local response=assert(B.discover(player,{scope={x=0,y=0,z=0}}))
local function handleFor(obj,ci)
    for token,r in pairs(B.sessions[player].records) do if r.target.obj==obj and r.target.ci==(ci or 0) then return token end end
end
local token=assert(handleFor(f.a))
assert(B.target(player,response.session,token).target.obj==f.a)
assert(not B.target({},response.session,token),'foreign actor accepted')
assert(not B.target(player,response.session,{}),'malformed handle accepted')
local T=B47ANCEDQuartermaster.Targets
local stale=T.descriptor(f.origin)
assert(not B.discover(player,{target=stale,scope={x=0,y=0,z=0}}),'legacy descriptor accepted')
-- Same-floor fractional character height must not reject an eligible scope/handle.
local z,x=0.02,0
player.getZ=function() return z end
player.getX=function() return x end
assert(B.target(player,response.session,token),'fractional same-floor height rejected session')
assert(B.discover(player,{scope={x=0,y=0,z=0},session=response.session}),'fractional same-floor discovery rejected')
z=1.02;assert(not B.discover(player,{scope={x=0,y=0,z=0}}),'different floor accepted')
assert(not B.target(player,response.session,token),'different-floor session accepted')
z=-0.02;assert(not B.discover(player,{scope={x=0,y=0,z=0}}),'negative lower floor accepted')
z=0.02;x=3.01;assert(not B.discover(player,{scope={x=0,y=0,z=0}}),'distant scope accepted')
x=3;assert(B.discover(player,{scope={x=0,y=0,z=0},session=response.session}),'distance boundary changed')
x=0;z=0
local old=f.a;local replacement={}
for k,v in pairs(old) do replacement[k]=v end
replacement.md={}; replacement.containers={}
for i,c in ipairs(old.containers) do local copy={};for k,v in pairs(c) do copy[k]=v end;replacement.containers[i]=copy end
old.sq.objects[stale.index+1]=replacement
assert(not B.target(player,response.session,token),'pre-load identical replacement accepted')
local refreshed=assert(B.discover(player,{scope={x=0,y=0,z=0},session=response.session}))
assert(not B.target(player,refreshed.session,token),'refresh rebound stale token')
local newToken=assert(handleFor(replacement))
assert(newToken~=token and B.target(player,refreshed.session,newToken).target.obj==replacement)
-- Native removal notification revokes even if the same userdata later reappears.
B.invalidate(replacement)
assert(not B.target(player,refreshed.session,newToken))
-- Two storage sections on one object must have independent handles.
local multi=f.unrelatedObject
local second={};for k,v in pairs(multi.containers[1]) do second[k]=v end
multi.containers[2]=second
refreshed=assert(B.discover(player,{scope={x=0,y=0,z=0},session=response.session}))
local one,two=assert(handleFor(multi,0)),assert(handleFor(multi,1))
assert(one~=two and B.target(player,refreshed.session,two).target.container==second)
multi.containers[1],multi.containers[2]=multi.containers[2],multi.containers[1]
assert(not B.target(player,refreshed.session,one) and not B.target(player,refreshed.session,two),'container slot replacement accepted')
-- Unloading the anchor square expires access even if old userdata remain reachable.
f.squares['0,0,0']=nil
assert(not B.target(player,refreshed.session,one),'unloaded scope accepted')
print('PASS bindings: server discovery, valid target, stale initial handle, identical replacement, no rebinding, revocation')
