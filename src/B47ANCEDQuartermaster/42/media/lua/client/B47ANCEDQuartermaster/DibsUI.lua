local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
require 'B47ANCEDQuartermaster/Authority'
require 'ISUI/ISPanelJoypad'
local Q=B47ANCEDQuartermaster
local D={};Q.DibsUI=D
local function tr(k) return getText('UI_QMSS_'..k) end
function D.options(rows)
    local wanted,needed,clear=false,false,false
    for _,row in ipairs(rows) do wanted=wanted or row.state~='wanted';needed=needed or row.state~='needed';clear=clear or row.state~='none' end
    return wanted,needed,clear
end
function D.presentation(rows)
    local priority='none';local lines={}
    for _,row in ipairs(rows) do
        local state=Q.Dibs.priority(row.details)
        if state=='needed' then priority='needed'
        elseif state=='wanted' and priority=='none' then priority='wanted' end
    end
    if #rows>1 then
        lines[1]=getText('UI_QMSS_DibsMultiTip',#rows)
    elseif rows[1] then
        for _,record in ipairs(rows[1].details.needed) do lines[#lines+1]=tr('Needed')..': '..SharedUI.Tooltip.plain(record.label) end
        -- Wanted call order remains the authoritative order returned by Dibs.details.
        for i,record in ipairs(rows[1].details.wanted) do lines[#lines+1]=tr('Wanted')..' '..i..'. '..SharedUI.Tooltip.plain(record.label) end
    end
    local label=tr('Dibs')
    if priority=='needed' then label=label..' [!] '..tr('Needed')
    elseif priority=='wanted' then label=label..' '..tr('Wanted') end
    return label,lines,priority
end
function D.fill(playerNum,context,items)
    local actual=ISInventoryPane.getActualItems(items);local ids,seen={},{}
    for _,item in ipairs(actual) do
        if not seen[item] then seen[item]=true;ids[#ids+1]=item:getID() end
    end
    if #ids==0 or #ids>256 then return end
    for _,option in ipairs(context.options or {}) do if option.b47Dibs then return end end
    local stamp={};context.b47DibsRequest=stamp
    Q.Authority.request(playerNum,'dibsInspect',{ids=ids},function(result)
        if result.status~='ok' or context.b47DibsRequest~=stamp then return end
        local menu=ISContextMenu:getNew(context)
        if SharedUI then SharedUI.menu(menu) end
        local label,lines=D.presentation(result.rows)
        local option=context:addOption(label);option.b47Dibs=true;context:addSubMenu(option,menu)
        local wanted,needed,clear=D.options(result.rows)
        local function add(label,state)
            menu:addOption(tr(label),nil,function() Q.Authority.request(playerNum,'dibsChange',{token=result.token,state=state},function(reply)
                if reply.status~='ok' then
                    local player=getSpecificPlayer(playerNum)
                    if player then player:setHaloNote(tr(reply.status)) end
                end
            end) end)
        end
        if wanted then add('Wanted','wanted') end
        if needed then add('Needed','needed') end
        if clear then add('DibsClear','none') end
        if #lines>0 and ISWorldObjectContextMenu.addToolTip then
            local preview={};for i=1,math.min(6,#lines) do preview[#preview+1]=lines[i] end;if #lines>6 then preview[#preview+1]=getText('UI_QMSS_DibsMore',#lines-6) end;SharedUI.Tooltip.context(option,table.concat(preview,' <LINE> '),playerNum,context)
            menu:addOption(tr('InspectDibs'),nil,function() D.inspect(playerNum,lines,context) end)
        end
    end)
end
function D.inspect(playerNum,lines,owner) return SharedUI.Tooltip.inspect(playerNum,table.concat(lines,' <LINE> '),owner) end
function D.installIconHook()
    if D.iconHook or not ISInventoryItem or not ISInventoryItem.renderItemIcon then return end
    D.iconHook=true
    local native=ISInventoryItem.renderItemIcon
    ISInventoryItem.renderItemIcon=function(panel,item,x,y,alpha,w,h)
        local result=native(panel,item,x,y,alpha,w,h)
        -- Inspect just the displayed instance's synchronized ModData. No inventory
        -- scans/rebuilds, network requests or cached stale player state in render.
        if item then
            local state=Q.Dibs.state(item);local priority='none'
            if state then for _,record in pairs(state.players) do
                if record.state=='needed' then priority='needed';break end
                if record.state=='wanted' then priority='wanted' end
            end end
            if priority~='none' then
                local fontHeight=getTextManager():getFontHeight(UIFont.Small)
                local size=priority=='needed' and math.max(18,fontHeight+4) or math.max(14,fontHeight+2)
                panel:drawRect(x,y,size,size,1,0,0,0)
                panel:drawRectBorder(x,y,size,size,1,1,1,1)
                panel:drawText(priority=='needed' and '!' or tr('WantedBadge'),x+3,y,1,1,1,1,UIFont.Small)
            end
        end
        return result
    end
end
if Events and Events.OnGameStart then Events.OnGameStart.Add(D.installIconHook) end
if Events then Events.OnFillInventoryObjectContextMenu.Add(D.fill) end
return D
