require 'B47ANCEDQuartermaster/Authority'
require 'ISUI/ISModalDialog'
require 'B47ANCEDUI/Dialog'
local Q=B47ANCEDQuartermaster;local U={pending={},recent={}};Q.ShoppingAddUI=U
local serial=0
local function tr(k) return getText('UI_QMSS_'..k) end
function U.confirm(playerNum,text,callback,owner,newOnly)
    return B47ANCEDUI.Dialog.confirm(playerNum,text,{accept=tr('AddAgain'),cancel=tr('Cancel'),extra=newOnly and tr('AddNewOnly') or nil},function(mode)
        callback(mode=='accept' and 'again' or mode=='extra' and 'newOnly' or 'cancel')
    end,owner)
end
function U.send(playerNum,args,callback,owner)
    local key=tostring(playerNum)..':'..tostring(args.kind)..':'..tostring(args.fullType or args.recipe or 'bulk')
    local now=getTimestampMs()
    for old,time in pairs(U.recent) do if now<time or now-time>=350 then U.recent[old]=nil end end
    if U.pending[key] or U.recent[key] and now-U.recent[key]>=0 and now-U.recent[key]<350 then return false end
    U.pending[key]=true;U.recent[key]=now
    serial=serial+1;args.operation=tostring(now)..':'..serial
    local function finish(result) U.pending[key]=nil;if callback then callback(result) end end
    Q.Authority.request(playerNum,'personalList',{},function(snapshot)
        if snapshot.status~='ok' then finish(snapshot);return end
        args.revision=snapshot.revision
        Q.Authority.request(playerNum,'shoppingAdd',args,function(result)
            if result.status~='duplicate' then finish(result);return end
            local text=getText(args.bulk and 'UI_QMSS_DuplicateBulk' or 'UI_QMSS_DuplicateWarning',result.new or 0,result.duplicate or 0)
            U.confirm(playerNum,text,function(mode)
                if mode=='cancel' then finish({status='cancelled'});return end
                args.confirmation=result.confirmation;args.mode=mode
                Q.Authority.request(playerNum,'shoppingAdd',args,finish)
            end,owner,args.bulk and (result.new or 0)>0)
        end)
    end)
    return true
end
return U
