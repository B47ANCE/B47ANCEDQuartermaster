require 'B47ANCEDQuartermaster/RecipeShoppingUI'
local Q=B47ANCEDQuartermaster;local U={};Q.ProjectCookUI=U
local function tr(k) return getText('UI_QMSS_'..k) end
function U.selection(panel,kind)
    if kind~='evolved' then
        local recipe=panel.logic and panel.logic:getRecipe()
        if not recipe or (panel.logic.isManualSelectInputs and panel.logic:isManualSelectInputs()) then return end
        return recipe:getName(),nil,kind=='craft' and (tonumber(panel.quantityInput and panel.quantityInput:getInternalText()) or 1) or 1
    end
    local evo=panel.EvoPanel;local recipe=evo and evo:getRecipe();local base=evo and evo:getBaseItem()
    if not recipe or not base then return end
    local intent={baseType=base:getFullType(),portion='full',additions={}};local byType={}
    for _,request in ipairs(evo:getPreCookItems()) do
        if request.portionPolicy~='full_only' or not request.displayItem then return end
        local t=request.displayItem:getFullType();local class=request.panelType=='Ingredient' and 'ingredient'
            or request.panelType=='Seasoning' and 'seasoning' or nil
        if not class then return end
        if byType[t] then if byType[t].class~=class then return end;byType[t].count=byType[t].count+1
        else local a={fullType=t,class=class,count=1};intent.additions[#intent.additions+1]=a;byType[t]=a end
    end
    local id=Q.EvolvedRequirements.identity(recipe)
    local nodes=Q.ShoppingRequirements.resolve('evolved',id,1,panel.player,intent)
    if not nodes or not nodes[1].accepts(base) then return end
    return id,intent,1
end
function U.install(class,kind,footer)
    if not class or class.b47CookInstalled then return end
    class.b47CookInstalled=true
    local create,update=class.createChildren,class.update
    local function place(self)
        local b=self.b47CookShopping;if not b then return end
        if kind=='craft' and not footer then
            local native=self.craftButton;local bottom=self.quantityInput
            local top=native and native:getY()+native:getHeight()+4 or 0
            local available=(bottom and bottom:getY() or self:getHeight())-top-4
            b:setX(4);b:setY(top);b:setWidth(math.max(24,self:getWidth()-8));b:setVisible(available>=24)
        end
    end
    class.createChildren=function(self,...)
        if create then create(self,...) end
        if self.b47CookShopping then return end
        local b=ISButton:new(0,0,80,24,tr('AddToShopping'),self,function(owner)
            local id,intent,n=U.selection(owner,kind)
            local reason=kind=='evolved' and 'evolvedUnsupported' or 'unsupported'
            if owner.logic and owner.logic.isManualSelectInputs and owner.logic:isManualSelectInputs() then reason='ManualRecipeUnsupported' end
            if not id then Q.RecipeShoppingUI.explain(owner.player:getPlayerNum(),reason,owner);return end
            local nodes,err=Q.ShoppingRequirements.resolve(kind,id,1,owner.player,intent)
            if not nodes then Q.RecipeShoppingUI.explain(owner.player:getPlayerNum(),err or reason,owner);return end
            Q.RecipeShoppingUI.prompt(n>0 and n or 1,function(quantity)
                Q.RecipeShoppingUI.submit(owner.player:getPlayerNum(),kind,id,quantity,function(result)
                    if result.status=='cancelled' then return end
                    owner.b47CookShopping:setTooltip(tr(result.status=='ok' and 'ProjectAdded' or result.status))
                    if result.status~='ok' then Q.RecipeShoppingUI.explain(owner.player:getPlayerNum(),result.status,owner) end
                end,intent,(class==PJCK_CraftActionPanel or class==PJCK_CookingInfo) and 'cook' or nil,owner)
            end,owner.player:getPlayerNum(),owner)
        end)
        b:initialise();b:instantiate();B47ANCEDUI.skin(b,'button');self:addChild(b);self.b47CookShopping=b;place(self)
        if self.insertNewLineOfButtons and self.joypadButtonsY and self.allJoypadButtons then self:insertNewLineOfButtons(b) end
    end
    if kind=='evolved' or footer then
        local layout=class.calculateLayout
        class.calculateLayout=function(self,width,height,...)
            local bodyHeight=math.max(0,(height or self:getHeight())-28)
            -- Neat Crafting reads self.height while positioning its quantity
            -- controls, before assigning the preferred height at layout end.
            if footer then self:setHeight(bodyHeight) end
            if layout then layout(self,width,bodyHeight,...) end
            local b=self.b47CookShopping
            if b then b:setX(4);b:setY(self:getHeight()+2);b:setWidth(math.max(24,self:getWidth()-8));self:setHeight(self:getHeight()+28) end
        end
    end
    class.update=function(self,...)
        if update then update(self,...) end
        place(self)
        local b=self.b47CookShopping;if not b then return end
        local now=getTimestampMs();if now<(self.b47CookRefresh or 0) then return end;self.b47CookRefresh=now+1000
        local id,intent=U.selection(self,kind)
        local signature=id and (kind=='evolved' and Q.EvolvedRequirements.key(id,intent) or id)
        if kind=='evolved' or signature~=self.b47CookSignature then
            self.b47CookSignature=signature
            local nodes=id and Q.ShoppingRequirements.resolve(kind,id,1,self.player,intent)
            self.b47CookSupported=nodes~=nil
            b:setTooltip(tr(nodes and 'AddToShopping' or (kind=='evolved' and 'evolvedUnsupported' or 'unsupported')))
        end
        -- A selected unsupported recipe is still clickable so the player can
        -- receive an explanation. Availability of crafting inputs is unrelated
        -- to planning Shopping; authority still validates the complete request.
        local selected=kind=='evolved' and self.EvoPanel and self.EvoPanel:getRecipe()
            or kind~='evolved' and self.logic and self.logic:getRecipe()
        b:setEnable(selected~=nil and selected~=false)
    end
    local joy=class.onJoypadDown
    class.onJoypadDown=function(self,key,...)
        if key==Joypad.YButton and self.b47CookShopping and self.b47CookShopping:isVisible() and self.b47CookShopping.enable then
            self.b47CookShopping:forceClick();return
        end
        if joy then return joy(self,key,...) end
    end
end
function U.start()
    local mods=getActivatedMods and getActivatedMods()
    local function active(id) return mods and mods:contains(id) end
    -- Optional client-only definitions, never instantiate a reference UI or call
    -- its cooking/transfer engine. No require is attempted when the mod is absent.
    if Q.ProjectCookAdapter.status()=='optional' then
        local ok=pcall(require,'Project_Cook/HandCraftPanel/PJCK_CraftActionPanel')
        if ok then U.install(PJCK_CraftActionPanel,'craft') end
        ok=pcall(require,'Project_Cook/EvolvedRecipePanel/PJCK_CookingInfo')
        if ok then U.install(PJCK_CookingInfo,'evolved') end
    end
    if active('Neat_Crafting') then
        local ok=pcall(require,'Neat_Crafting/NC_CraftActionPanel')
        if ok then U.install(NC_CraftActionPanel,'craft',true) end
    end
    if active('Neat_Building') or active('Neat_Building_UIOnly') then
        local ok=pcall(require,'Neat_Building/nb_buildinginfodetailpanel')
        if ok then U.install(NB_BuildingInfoDetailPanel,'build',true) end
    end
end
if Events and Events.OnGameStart then Events.OnGameStart.Add(U.start) end
return U
