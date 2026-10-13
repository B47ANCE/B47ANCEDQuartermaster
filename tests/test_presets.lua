dofile(TEST_ROOT..'/fixtures/containers.lua')
local A=require 'B47ANCEDQuartermaster/Authority'
local Q=B47ANCEDQuartermaster
local f=CONTAINER_FIXTURE
local S,P=Q.Schema,Q.Presets
local discovery=A.handle(f.player,'discover',{scope={x=0,y=0,z=0}})
local token=discovery.targets[1].token
local config=S.empty();config.items['Vehicle Key']=true
local function request(revision,generation,remove)
    return A.handle(f.player,'presetChange',{session=discovery.session,token=token,name='Keys',
        revision=revision,generation=generation,delete=remove,config=config,owner='forged'})
end
local created=request(0,0);assert(created.status=='ok')
local def=created.library.definitions.Keys
assert(def.gen==1 and def.rev==1 and def.owner=='local:0')
assert(request(0,0).status=='conflict','stale write accepted')
local read=A.handle(f.player,'presetsList',{session=discovery.session})
assert(read.library.definitions.Keys.items['Vehicle Key'])
read.library.definitions.Keys.items['Vehicle Key']=nil
assert(P.snapshot().definitions.Keys.items['Vehicle Key'],'snapshot exposed persistent table')
config.items={['Key Ring']=true}
assert(request(1,1).status=='ok');assert(P.snapshot().definitions.Keys.rev==2)
local linked=S.empty();linked.presets.Keys=S.link(def)
assert(P.resolve(linked).items['Key Ring'])
local legacy=S.empty();legacy.presets.Keys=1
assert(P.resolve(legacy)==nil,'legacy generation silently attached to an owned definition')
legacy.presets.Keys=true;assert(P.resolve(legacy)==nil,'legacy boolean link silently attached')
assert(S.valid(linked) and S.envelope(linked,1).schemaVersion==2)
-- Other players can read/link shared presets, but cannot edit another owner's definition.
f.player.getPlayerNum=function() return 1 end
assert(request(2,1).status=='PresetDenied')
f.player.getPlayerNum=function() return 0 end
assert(request(2,1,true).status=='ok');assert(P.resolve(linked)==nil)
assert(request(3,0).status=='ok')
assert(P.snapshot().definitions.Keys.gen==2 and P.resolve(linked)==nil,'delete/recreate revived stale generation')
-- Reinitializing the module reads the same persisted native ModData contract.
package.loaded['B47ANCEDQuartermaster/Presets']=nil
P=require 'B47ANCEDQuartermaster/Presets'
assert(P.snapshot().definitions.Keys.gen==2)
config.presets.Recursive=1
assert(request(4,2).status=='invalid','recursive preset links accepted')
config.presets={}
local before=P.snapshot().revision
f.network(true,false);assert(request(4,2).status=='invalid');f.network(false,false)
-- MP broadcast carries revision invalidation only; snapshots stay request/response.
f.network(false,true)
local notices=0
sendServerCommand=function(player,module,command,args)
    assert(player==f.player and module=='B47ANCEDQuartermaster' and command=='presetsChanged')
    assert(args.revision==5 and args.definitions==nil);notices=notices+1
end
assert(A.handle(f.player,'presetChange',{session=discovery.session,token=token,name='Server kit',
    revision=4,generation=0,config=config,taxonomyVersion=6}).status=='ok')
assert(notices==1 and P.snapshot().definitions['Server kit'].owner=='fixture-player')
before=5;f.network(false,false)
Q.Bindings.invalidate(Q.Bindings.sessions[f.player].records[token].target.obj)
assert(request(4,2).status=='invalid','revoked target authorized a global edit')
assert(P.snapshot().revision==before)
assert(LootSorter==nil)
print('PASS owned presets: session/target/owner authority, snapshots, conflicts, generations, persistence contract, recursion/client rejection')
