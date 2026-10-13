-- Diagnostic for extraction Gate C, not a passing safety regression.
dofile(TEST_ROOT..'/test_containers.lua')
local f=CONTAINER_FIXTURE
local T=B47ANCEDQuartermaster.Targets
local descriptor=T.descriptor(f.origin)
local old=f.a
local replacement={}
for k,v in pairs(old) do replacement[k]=v end
replacement.md={}
replacement.containers={}
for i,c in ipairs(old.containers) do
    local copy={};for k,v in pairs(c) do copy[k]=v end
    replacement.containers[i]=copy
end
local objects=old.sq.objects
objects[descriptor.index+1]=replacement
assert(not T.valid(f.origin,f.player),'removed original should be invalid')
local resolved=T.resolve(descriptor,f.player)
assert(resolved and resolved.obj==replacement)
print('REPRODUCED: pre-session stale descriptor resolves a replacement object; no save performed')
