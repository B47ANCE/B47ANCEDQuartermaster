dofile(TEST_ROOT..'/fixtures/containers.lua');dofile(TEST_ROOT..'/fixtures/catalog.lua')
require 'B47ANCEDQuartermaster/Authority'
local Q=B47ANCEDQuartermaster;local R=Q.AllocationRuntime;local f=CONTAINER_FIXTURE
local category=Q.Categorizer.nativeID('Food');local script=CATALOG_FIXTURE.script('Steak','normal',nil,'Food')
local item={getDisplayCategory=function() return 'Food' end,getDisplayName=function() return 'Steak' end,getScriptItem=function() return script end,getContainer=function() return f.a.containers[1] end}
local function result(key,role,used,distance,priority)
 local config=Q.Schema.empty();config.cats[category]=true;config.priority=priority or 0
 local physical={container={},capacity=100,used=used}
 return {candidate={key=key,container=physical.container,config=config,effective=config,distance=distance or 0},
  detail={rooms={{key=key,room={id=key,roomType='kitchen',designation=role},record={priority=0,primaryAt=60,secondaryAt=80},scope={parts={physical}}}}}}
end
local primary=result('primary','primary',59,100)
local secondary=result('secondary','secondary',0,0)
assert(R.rank(item,{primary,secondary},{}).key=='primary','distance overrode valid primary preference')
primary.detail.rooms[1].scope.parts[1].used=60
assert(R.rank(item,{primary,secondary},{}).key=='secondary')
secondary.detail.rooms[1].scope.parts[1].used=80
assert(R.rank(item,{primary,secondary},{}).key=='primary')
secondary.candidate.config.priority=1
assert(R.rank(item,{primary,secondary},{}).key=='secondary','role overrode hard container priority')
secondary.candidate.config.priority=0;secondary.candidate.config.items.Steak=true
assert(R.rank(item,{primary,secondary},{}).key=='secondary','role overrode explicit item match')
secondary.candidate.config.items.Steak=nil
assert(R.rank(item,{secondary},{}).key=='secondary','missing Primary discarded valid Secondary capacity')
local another=result('a-primary','primary',10,100)
assert(R.rank(item,{primary,secondary,another},{}).key=='a-primary','multiple Primaries lacked deterministic fallback')
assert(R.rank(item,{another,secondary,primary},{}).key=='a-primary','candidate order changed choice')
local before=R.diagnostics().pending
R.observe(f.player,{candidates={primary.candidate,secondary.candidate}},item,primary.candidate,{})
assert(R.diagnostics().pending==before+1 and R.enforcing()==false)
R.cleanup(f.player);assert(R.diagnostics().pending==before)
print('PASS OFFLINE advisory routing: threshold edges, missing groups, hard priority and exact-name precedence, multiple-role deterministic ties and nonblocking bounded shadow queue')
