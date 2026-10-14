-- Client presentation only: row.cat is a UI key; native items/scripts remain intact.
require 'ISUI/ISInventoryPane'
require 'B47ANCEDQuartermaster/Categorizer'
local Compatibility=require 'B47ANCEDQuartermaster/Compatibility'
local Q=B47ANCEDQuartermaster
local I=Q.InventoryCategories or {}
Q.InventoryCategories=I
local function pack(...) return {n=select('#',...),...} end
local Migration=require 'B47ANCEDQuartermaster/Migration'
local Identity=require 'B47ANCEDQuartermaster/Identity'
-- Internal diagnostic budget, not a gameplay setting. No work/logging while off.
local function diagnostic(stage,detail)
    if Q.InventoryCategoryTraceEnabled~=true or (I.traceCount or 0)>=64 then return end
    I.traceCount=(I.traceCount or 0)+1
    local text=tostring(detail or ''):gsub('[\r\n\t]',' '):sub(1,240)
    print('[B47InventoryCategory] version='..Identity.version..' sample='..I.traceCount..' stage='..stage..' '..text)
end
function I.enableDiagnostics(enabled)
    Q.InventoryCategoryTraceEnabled=enabled==true
    I.traceCount=0
    if enabled then
        diagnostic('SNAPSHOT','file=InventoryCategories.lua class='..tostring(ISInventoryPane~=nil)..' installed='..tostring(I.installed==true)..' renderHeadIsWrapper='..tostring(ISInventoryPane and ISInventoryPane.renderdetails==I.wrapper))
    end
end
diagnostic('FILE_LOADED','class='..tostring(ISInventoryPane~=nil))

function I.label(item,presentationCategory)
    local R=Q.Categorizer
    if not item or not R or type(R.resolve)~='function' or type(R.isLeaf)~='function' or type(R.label)~='function' then diagnostic('FALLBACK','resolver-or-item-unavailable');return end
    -- Canonical resolve caches by ScriptItem identity and ClassifyToolsByUse.
    -- invalidate() clears that cache. Localized labels are never retained here.
    local ok,category=true,presentationCategory
    if not category then ok,category=pcall(R.resolve,item) end
    if not ok or not R.isLeaf(category) then diagnostic('FALLBACK',ok and ('non-leaf='..tostring(category)) or 'resolver-error');return end
    local label=R.label(category)
    if Q.InventoryCategoryTraceEnabled==true then
        local fullType=item.getFullType and item:getFullType() or 'unavailable'
        local script=item.getScriptItem and item:getScriptItem()
        diagnostic('RESOLVED','fullType='..tostring(fullType)..' scriptAvailable='..tostring(script~=nil)..' category='..tostring(category)..' label='..tostring(label))
    end
    return label
end

-- Native refresh creates ordinary Lua row tables. No item fields or ModData are written.
function I.present(pane)
    pane.b47CategoryRevision=I.revision or 0
    pane.b47CategoryTools=Migration.option('ClassifyToolsByUse')~=false
    if not Compatibility.allowed() then return end
    local resolver=Q.Categorizer
    if not resolver or not resolver.resolve or not resolver.isLeaf then return end
    local selected=pane.saveSelection and pane:saveSelection({})
    for _,row in ipairs(pane.itemslist or {}) do
        local item=type(row)=='table' and row.items and row.items[1]
        if item then
            local ok,key=pcall(resolver.resolve,item)
            local previousCategory=row.b47Category
            if previousCategory and row.cat==(row.b47CategorySort or previousCategory) then row.cat=row.b47NativeCat end
            row.b47Category=nil
            if ok and resolver.isLeaf(key) then
                row.b47NativeCat=row.cat
                row.b47Category=key;row.b47CategorySort=resolver.label(key);row.cat=row.b47CategorySort
                diagnostic('ROW_CATEGORY','key='..tostring(key))
            end
        end
    end
    -- Reuse the exact selected native comparator, including equipped/name precedence.
    if pane.itemSortFunc and (pane.itemSortFunc==ISInventoryPane.itemSortByCatInc or pane.itemSortFunc==ISInventoryPane.itemSortByCatDesc) then
        table.sort(pane.itemslist,pane.itemSortFunc)
        if selected and pane.restoreSelection then
            -- Native restore adds indexed entries; clear the previous indices first.
            pane.selected={};pane:restoreSelection(selected)
        end
        diagnostic('SORTED','native-category-comparator')
    end
    pane.b47CategoryRevision=I.revision or 0
    pane.b47CategoryTools=Migration.option('ClassifyToolsByUse')~=false
end
-- Cache invalidation is a client observer: delegate canonical behavior unchanged.
if not I.invalidateOriginal and Q.Categorizer and Q.Categorizer.invalidate then
    I.invalidateOriginal=Q.Categorizer.invalidate
    Q.Categorizer.invalidate=function(...) I.revision=(I.revision or 0)+1;return I.invalidateOriginal(...) end
end
function I.install(reconcile)
    diagnostic('REGISTRATION_ATTEMPT','class='..tostring(ISInventoryPane~=nil)..' installed='..tostring(I.installed==true))
    if not ISInventoryPane then return end
    if I.installed and not reconcile then return end
    if type(ISInventoryPane.refreshContainer)=='function' and ISInventoryPane.refreshContainer~=I.refreshWrapper then
        local refresh=ISInventoryPane.refreshContainer
        I.originalRefresh=refresh
        I.refreshWrapper=function(self,...)
            local result=pack(refresh(self,...));I.present(self)
            return unpack(result,1,result.n)
        end
        ISInventoryPane.refreshContainer=I.refreshWrapper
    end
    local render=ISInventoryPane.renderdetails
    if render==I.wrapper then return end
    if type(render)~='function' then diagnostic('REGISTRATION_DEFERRED','renderdetails-unavailable');return end
    I.original=render
    I.wrapper=function(self,doDragged,...)
        local allowed,conflict,name,reason=Compatibility.allowed()
        if Q.InventoryCategoryTraceEnabled==true then diagnostic('WRAPPER_INVOKED','dragged='..tostring(doDragged)..' allowed='..tostring(allowed)..' reason='..tostring(reason or name or conflict or 'ok')) end
        local tools=Migration.option('ClassifyToolsByUse')~=false
        if not doDragged and
            ((self.b47CategoryRevision==nil and self.inventory~=nil) or self.b47CategoryRevision~=nil and
            (self.b47CategoryRevision~=(I.revision or 0) or self.b47CategoryTools~=tools or self.b47CategoryAllowed~=nil and self.b47CategoryAllowed~=allowed)) then
            self:refreshContainer()
        end
        self.b47CategoryAllowed=allowed
        if doDragged or not allowed then return render(self,doDragged,...) end
        local previous={};local installed={}
        for _,method in ipairs({'drawText','drawTextRight','drawTextCentre'}) do
            local draw=self[method]
            if type(draw)=='function' then
                previous[method]=rawget(self,method);installed[#installed+1]=method
                self[method]=function(pane,value,x,y,...)
                    if Q.InventoryCategoryTraceEnabled==true then diagnostic('DRAW_TEXT','x='..tostring(x)..' categoryX='..tostring(pane.column3+8)..' text='..tostring(value)) end
                    -- Verified native logical Category region; tolerate renderer padding/alignment.
                    if pane.column3 and x>=pane.column3 and (not pane.column4 or x<=pane.column4) then
                        local row=pane.items and pane.items[#pane.items]
                        local item=type(row)=='table' and row.items and row.items[1]
                        if Q.InventoryCategoryTraceEnabled==true then diagnostic('CATEGORY_POSITION','rowType='..type(row)..' item='..tostring(item~=nil)) end
                        if item and (not item.getJobDelta or item:getJobDelta()<=0) then
                            local native=item:getDisplayCategory() or item:getCategory()
                            if native and value==getText('IGUI_ItemCat_'..native) then
                                diagnostic('CATEGORY_DRAW','native='..tostring(native))
                                local label=I.label(item,row.b47Category)
                                if label then value=label;diagnostic('SUBSTITUTED',label) end
                            else diagnostic('FALLBACK','native-text-mismatch') end
                        end
                    end
                    return draw(pane,value,x,y,...)
                end
            end
        end
        local result=pack(pcall(render,self,doDragged,...))
        for _,method in ipairs(installed) do self[method]=previous[method] end
        if not result[1] then error(result[2],0) end
        return unpack(result,2,result.n)
    end
    ISInventoryPane.renderdetails=I.wrapper;I.installed=true
    diagnostic('REGISTERED','row-refresh-and-scoped-render')
end
I.install()
if not I.eventRegistered and Events and Events.OnGameStart then
    Events.OnGameStart.Add(function()
        if I.startupReconciled then return end;I.startupReconciled=true
        diagnostic('DEFERRED_REGISTRATION','OnGameStart');I.install(true)
    end)
    I.eventRegistered=true
end
return I
