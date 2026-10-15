-- Optional local UI storage must not make a server room inaccessible on IO failure.
B47ANCEDQuartermaster={}
local lines,writes,closed={},'',0
getFileReader=function() local i=0;return {readLine=function() i=i+1;return lines[i] end,close=function() closed=closed+1 end} end
getFileWriter=function() writes='';return {write=function(_,s) writes=writes..s end,close=function() closed=closed+1 end} end
local P=require 'B47ANCEDQuartermaster/RoomPreferences'
local world='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
local id=world..':bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
lines={'not a room',world..'|forged',world..'|'..id}
assert(P.get(0,world)==id and closed==1)
P.set(0,world,nil);assert(not P.get(0,world) and writes=='')
P.set(0,world,id);assert(writes==world..'|'..id..'\n')
P.set(0,world,id..'x');assert(P.get(0,world)==id)
getFileReader=function() error('fixture read failure') end
assert(P.get(1,world)==nil)
getFileWriter=function() error('fixture write failure') end
P.set(1,world,id);assert(P.get(1,world)==id,'optional file failure discarded current selection')
getFileReader=function() return {readLine=function() error('fixture read failure') end,close=function() closed=closed+1 end} end
local count=closed;assert(not P.get(2,world) and closed==count+1)
getFileWriter=function() return {write=function() error('fixture write failure') end,close=function() closed=closed+1 end} end
P.set(2,world,id);assert(closed==count+2)
print('PASS OFFLINE room preferences: exact world/room identity, malformed records, invalidation, optional IO failure and handle cleanup')
