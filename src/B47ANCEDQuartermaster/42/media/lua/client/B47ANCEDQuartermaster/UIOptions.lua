-- Client-local tree presentation only. No world/player ModData or network write.
local Q=B47ANCEDQuartermaster
local O={}
Q.UIOptions=O
local filename='B47ANCEDQuartermasterUI.txt'
local loaded=false
local grouped=false
function O.groupByMod()
    if not loaded then
        loaded=true
        if getFileReader then
            local ok,reader=pcall(getFileReader,filename,true)
            if ok and reader then
                local line=reader:readLine()
                grouped=line=='groupByMod=true'
                reader:close()
            end
        end
    end
    return grouped
end
function O.setGroupByMod(value)
    value=value==true
    if O.groupByMod()==value then return true end
    if getFileWriter then
        local ok,writer=pcall(getFileWriter,filename,true,false)
        if not ok or not writer then return false end
        writer:write('groupByMod='..tostring(value)..'\n')
        writer:close()
    end
    grouped=value
    if Q.onGroupByModChanged then Q.onGroupByModChanged() end
    return true
end
return O
