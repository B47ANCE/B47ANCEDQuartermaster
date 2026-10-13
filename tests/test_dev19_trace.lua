local time,reads,output=1000,0,{}
getTimestampMs=function() reads=reads+1;return time end
isClient=function() return false end
isServer=function() return true end
local originalPrint=print
print=function(line) output[#output+1]=line end
local Trace=require 'B47ANCEDQuartermaster/SortTrace'
Trace.emit('off','stage','ok');assert(Trace.begin()==nil)
Trace.observe('off',{})
assert(reads==0 and #output==0,'disabled trace performed timing/position work')
B47ANCEDQuartermaster.SortTraceEnabled=true
local started=Trace.begin();time=1125
Trace.emit('one','stage','ok',nil,nil,started,7,'miss')
assert(output[1]:find('durationMs=125',1,true) and output[1]:find('count=7 cache=miss',1,true))
local player={x=0,getX=function(self) return self.x end,getY=function() return 0 end}
Trace.observe('one',player);player.x=1;Trace.observe('one',player);Trace.observe('one',player)
assert(#output==2 and output[2]:find('stage=FIRST_POSITION_CHANGE',1,true),'position onset duplicated')
time=900;Trace.emit('one','reverse','ok',nil,nil,started)
assert(output[3]:find('clock=discontinuity',1,true) and output[3]:find('durationMs=unknown',1,true))
time=3000
Trace.emit('unsafe\nID','unsafe\nstage','ok',string.rep('x',300))
assert(not output[#output]:find('\n',1,true) and #output[#output]<650)
local before=#output
for i=1,1000 do Trace.emit('bounded','stage','ok') end
assert(#output-before==192,'operation output unbounded')
time=5000;before=#output
for i=1,1000 do Trace.emit('many:'..i,'stage','ok') end
assert(#output-before==512,'aggregate output unbounded')
-- Old operation state is evicted after at most 32 retained identifiers.
time=6000;Trace.emit('one','new','ok')
assert(output[#output]:find('elapsedMs=0',1,true),'retained operation state was not bounded')
print=originalPrint
B47ANCEDQuartermaster.SortTraceEnabled=false
print('PASS OFFLINE dev.19 trace: disabled cost, stage duration/count/cache, one position onset, wall discontinuity, sanitization and bounded memory/output')
