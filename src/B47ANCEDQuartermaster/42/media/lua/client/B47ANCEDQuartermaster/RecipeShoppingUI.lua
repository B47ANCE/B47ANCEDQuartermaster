local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
require 'B47ANCEDQuartermaster/Authority'
require 'B47ANCEDQuartermaster/ShoppingAddUI'
local Q=B47ANCEDQuartermaster
local U={};Q.RecipeShoppingUI=U
local function tr(k) return getText('UI_QMSS_'..k) end
function U.submit(playerNum,kind,name,quantity,callback,intent,origin,owner)
    Q.ShoppingAddUI.send(playerNum,{kind=kind,recipe=name,quantity=quantity,intent=intent,origin=origin},callback,owner)
end
function U.prompt(default,callback,playerNum,owner)
    local dialog=ISTextBox:new(0,0,360,180,tr('ProjectQuantity'),tostring(default or 1),nil,function(_,button)
        if button.internal=='OK' then callback(tonumber(button.parent.entry:getInternalText())) end
    end,playerNum)
    dialog:initialise();dialog:addToUIManager();SharedUI.Dialog.decorate(dialog,playerNum,owner)
    return dialog
end
function U.explain(playerNum,key,owner)
    require 'ISUI/ISModalDialog'
    local dialog=ISModalDialog:new(0,0,480,220,tr(key),false,nil,nil,playerNum)
    dialog:initialise();dialog:addToUIManager();SharedUI.Dialog.decorate(dialog,playerNum,owner);setJoypadFocus(playerNum,dialog)
    return dialog
end
function U.install(class,kind)
    if not class or class.b47ShoppingInstalled then return end
    class.b47ShoppingInstalled=true
    local create,layout,update=class.createChildren,class.calculateLayout,class.update
    class.createChildren=function(self,...)
        create(self,...)
        local button
        button=ISButton:new(0,0,30,24,'+',self,function(owner)
            local recipe=owner.logic:getRecipe();if not recipe then return end
            local name=recipe:getName()
            local n=kind=='craft' and owner.entryBox and tonumber(owner.entryBox:getInternalText()) or 1
            U.prompt(n and n>0 and n or 1,function(quantity)
                U.submit(owner.player:getPlayerNum(),kind,name,quantity,function(result)
                    if result.status=='ok' then button:setTooltip(tr('ProjectAdded'))
                    else button:setTooltip(tr(result.status)) end
                end,nil,nil,owner)
            end,owner.player:getPlayerNum(),owner)
        end)
        button:initialise();button:instantiate();SharedUI.skin(button,'button');button:setTooltip(tr('AddToShopping'));self:addChild(button);self.b47Shopping=button
    end
    class.calculateLayout=function(self,...)
        layout(self,...)
        local button,native=self.b47Shopping,self.buttonCraft
        if button and native then
            local w=native:getWidth();native:setWidth(math.max(20,w-34))
            button:setX(native:getX()+native:getWidth()+4);button:setY(native:getY());button:setWidth(30);button:setHeight(native:getHeight())
            self:insertNewLineOfButtons(button)
        end
    end
    class.update=function(self,...)
        if update then update(self,...) end
        local button=self.b47Shopping;if not button then return end
        local recipe=self.logic:getRecipe()
        if recipe~=self.b47ShoppingRecipe then
            self.b47ShoppingRecipe=recipe
            local nodes=recipe and Q.ShoppingRequirements.resolve(kind,recipe:getName(),1,self.player)
            self.b47ShoppingSupported=nodes~=nil
            button:setEnable(nodes~=nil);button:setTooltip(nodes and tr('AddToShopping') or tr('unsupported'))
        end
        local manual=self.logic.isManualSelectInputs and self.logic:isManualSelectInputs() or false
        button:setEnable(recipe~=nil and self.b47ShoppingSupported and not manual or false)
        if manual then button:setTooltip(tr('ManualRecipeUnsupported'))
        elseif self.b47ShoppingManual then button:setTooltip(self.b47ShoppingSupported and tr('AddToShopping') or tr('unsupported')) end
        self.b47ShoppingManual=manual
    end
end
function U.start()
    require 'Entity/ISUI/CraftRecipe/ISWidgetHandCraftControl'
    require 'Entity/ISUI/BuildRecipe/ISWidgetBuildControl'
    require 'ISUI/ISTextBox'
    U.install(ISWidgetHandCraftControl,'craft');U.install(ISWidgetBuildControl,'build')
end
if Events and Events.OnGameStart then Events.OnGameStart.Add(U.start) end
return U
