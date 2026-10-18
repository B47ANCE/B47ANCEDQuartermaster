local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
-- Local previews only. Never selects a gameplay target or changes a server handle.
require 'B47ANCEDQuartermaster/Targets'
local Q=B47ANCEDQuartermaster;local T=Q.Targets
local S={};S.__index=S;Q.ContainerSprite=S
function S.new(playerNum) return setmetatable({playerNum=playerNum,bindings={},objects={},logs=0},S) end
function S:clear() self.bindings={};self.objects={} end
function S:reason(binding,reason)
    if binding.reason~=reason and Q.ContainerSpriteTraceEnabled and self.logs<32 then
        self.logs=self.logs+1
        print('[B47ContainerSprite] fallback='..reason)
    end
    binding.reason=reason
    return nil,reason
end
function S:texture(target)
    if not target then return nil,'missing-target' end
    local b=self.bindings[target]
    if not b then b={};self.bindings[target]=b end
    local now=getTimestampMs()
    if not b.checked or now<b.checked or now-b.checked>=500 then
        b.checked=now
        local player=getSpecificPlayer(self.playerNum)
        local live=player and (target.obj and T.valid(target,player) and target or not target.obj and T.resolve(target,player))
        if not live then b.live=nil;return self:reason(b,'unavailable-object') end
        if b.object and (b.object~=live.obj or b.container~=live.container) then
            b.live=nil;b.replaced=true
        end
        if b.replaced then return self:reason(b,'replaced-object') end
        b.object,b.container,b.live=live.obj,live.container,live
    end
    if not b.live then return self:reason(b,b.replaced and 'replaced-object' or 'unavailable-object') end
    local ok,texture,reason=pcall(function()
        local object=b.object
        if not object:getSquare() then return nil,'unloaded-object' end
        if b.container:getParent()~=object then return nil,'parent-mismatch' end
        local sprite=object:getSprite()
        if not sprite then return nil,'missing-sprite' end
        local current=sprite:getTextureForCurrentFrame(object:getDir(),object)
        if not current or current:isDestroyed() then return nil,'missing-texture' end
        if current:getWidth()<=0 or current:getHeight()<=0 then return nil,'invalid-texture' end
        local cached=self.objects[object]
        if not cached or cached.sprite~=sprite or cached.texture~=current then
            self.objects[object]={sprite=sprite,texture=current}
        end
        return current
    end)
    if not ok then return self:reason(b,'native-preview-error') end
    if not texture then return self:reason(b,reason) end
    b.reason=nil
    return texture
end
function S:draw(list,target,fallback,x,y,size)
    local texture=self:texture(target)
    if texture and list.drawTextureScaledAspect2 then
        -- Native variant 2 fits the atlas's trimmed width/height, centered, without
        -- treating the original isometric tile canvas/offset as visible content.
        list:drawTextureScaledAspect2(texture,x,y,size,size,1,1,1,1)
    else SharedUI.Renderer.icon(list,texture or fallback,x,y,size) end
end
return S
