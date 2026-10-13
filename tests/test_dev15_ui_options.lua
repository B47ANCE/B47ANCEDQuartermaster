B47ANCEDQuartermaster=B47ANCEDQuartermaster or {}
local contents
getFileReader=function(name)
    assert(name=='B47ANCEDQuartermasterUI.txt')
    return {readLine=function() return contents end,close=function() end}
end
getFileWriter=function(name)
    assert(name=='B47ANCEDQuartermasterUI.txt')
    return {write=function(_,line) contents=line:gsub('\n$','') end,close=function() end}
end
local O=require 'B47ANCEDQuartermaster/UIOptions'
assert(O.groupByMod()==false)
assert(O.setGroupByMod(true) and O.groupByMod() and contents=='groupByMod=true')
assert(O.setGroupByMod(false) and not O.groupByMod() and contents=='groupByMod=false')
print('PASS OFFLINE dev.15 client-local grouping preference default and persistence')
