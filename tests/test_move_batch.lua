dofile(TEST_ROOT..'/fixtures/containers.lua')
local A=require 'B47ANCEDQuartermaster/Authority'
local M=B47ANCEDQuartermaster.Movement
local f=CONTAINER_FIXTURE
local original=M.handle;local leaves=0
M.handle=function(player,command,args)
 if command~='moveBatch' then leaves=leaves+1 end
 return original(player,command,args)
end
local function batch(phase,operations,player)
 return M.handle(player or f.player,'moveBatch',{phase=phase,operations=operations})
end
for _,operations in ipairs({{}, {'a','a'}, {[1]='a',[3]='b'}, {[0]='a',[1]='b'}, {'a',false}, {{id='forged'}}}) do
 local before=leaves;assert(batch('movePut',operations).status=='invalid' and leaves==before,'invalid shape partially processed')
end
local oversized={};for i=1,101 do oversized[i]='op:'..i end
assert(batch('movePut',oversized).status=='invalid' and leaves==0)
assert(batch('moveBatch',{'a'}).status=='invalid' and leaves==0,'recursive batch phase accepted')
assert(batch('movePlan',{'a'}).status=='invalid' and leaves==0,'batch created new operations')
local response=batch('movePut',{'unknown:1','unknown:2'})
assert(response.status=='ok' and #response.results==2 and leaves==2)
assert(response.results[1].operation=='unknown:1' and response.results[1].status=='invalid' and response.results[1].reason=='operationNotFound')
local owned={id='owned',time=getTimestampMs(),phase='planned'};M.operations[f.player]=owned
response=batch('moveDone',{'owned'},{})
assert(response.results[1].status=='invalid' and M.operations[f.player]==owned,'foreign actor consumed grant')
f.network(true,false);local before=leaves
assert(batch('movePut',{'owned'}).status=='invalid' and leaves==before,'client ran authority')
f.network(false,false);M.handle=original
local P=require 'B47ANCEDQuartermaster/Protocol'
assert(P.version('moveBatch')==9 and not P.accepts('moveBatch',{protocol=5}) and not P.accepts('moveBatch',{protocol=8}) and P.accepts('moveBatch',{protocol=9}) and P.version('moveRevert')==9 and P.version('moveReverted')==9)
print('PASS OFFLINE moveBatch: bounded atomic shape validation, duplicate/sparse/forged rejection, same owner checks, per-operation correlation and mixed-peer rejection')
