-- Exercised production resolver/render adapter, simulated native objects only.
local presentation={Renderer={}}
package.loaded['B47ANCEDQuartermaster/UIProvider']=presentation
B47ANCEDQuartermaster={};package.loaded['B47ANCEDQuartermaster/Targets']=true
local now,checks=0,0
getTimestampMs=function() return now end
getSpecificPlayer=function() return {} end
local T={};B47ANCEDQuartermaster.Targets=T
function T.valid(t) checks=checks+1;return not t.invalid end
function T.resolve(t) checks=checks+1;return t.live and T.valid(t.live) and t.live end
local S=require 'B47ANCEDQuartermaster/ContainerSprite'
local function object(id)
 local texture={id=id,w=16+id,h=64,dead=false}
 function texture:isDestroyed() return self.dead end
 function texture:getWidth() return self.w end;function texture:getHeight() return self.h end
 local sprite={texture=texture}
 function sprite:getTextureForCurrentFrame(dir,obj) assert(dir==obj.dir);return self.texture end
 local o={sprite=sprite,dir=id,square={}}
 function o:getSquare() return self.square end;function o:getSprite() return self.sprite end;function o:getDir() return self.dir end
 local container={parent=o};function container:getParent() return self.parent end
 return {obj=o,container=container,ci=0,kind='cupboard'},texture
end
local drawn,fallback
presentation.Renderer.icon=function(_,icon) fallback=icon end
local list={drawTextureScaledAspect2=function(_,tex,x,y,w,h,a,r,g,b)
 assert(w==h and x==5 and y==8 and a==1 and r==1 and g==1 and b==1);drawn=tex
end}
-- 30 different physical objects (same display/type), current-frame directions,
-- texture replacements and sibling compartments must retain exact identity.
for i=1,30 do
 now=i*1000;local cache=S.new(i%2);local target,texture=object(i);target.name='Cupboard'
 cache:draw(list,target,'generic',5,8,32);assert(drawn==texture)
 local before=checks;cache:texture(target);assert(checks==before,'per-frame world validation')
 local other,otherTexture=object(i+40);other.name='Cupboard';assert(cache:texture(other)==otherTexture,'display-name cache collision')
 local sibling={obj=target.obj,container=target.container,ci=1};assert(cache:texture(sibling)==texture)
 target.obj.sprite.texture=otherTexture;assert(cache:texture(target)==otherTexture,'texture reload/frame replacement stale')
 target.obj.sprite=other.obj.sprite;assert(cache:texture(target)==otherTexture,'sprite replacement stale')
 target.obj.square=nil;assert(cache:texture(target)==nil,'unloaded object preview survived')
 cache:clear();assert(not next(cache.objects) and not next(cache.bindings))
end
local cache=S.new(0);local t,tex=object(1)
assert(cache:texture(t)==tex);tex.dead=true;assert(select(2,cache:texture(t))=='missing-texture');tex.dead=false
t.container.parent={};assert(select(2,cache:texture(t))=='parent-mismatch');t.container.parent=t.obj
t.obj.sprite=nil;assert(select(2,cache:texture(t))=='missing-sprite')
local live,lt=object(2);local handle={live=live,token='server-handle'};assert(cache:texture(handle)==lt)
local replacement=object(3);handle.live=replacement;now=now+500
assert(select(2,cache:texture(handle))=='replaced-object','stale handle rebound to replacement')
cache:clear();assert(cache:texture(handle)~=nil,'new list generation cannot rebind')
handle.live.invalid=true;now=now+500;assert(cache:texture(handle)==nil,'removed/invalid object retained')
local valid,vt=object(4);vt.w=0;assert(select(2,cache:texture(valid))=='invalid-texture')
cache:draw(list,valid,'generic',5,8,32);assert(fallback=='generic')
local available,at=object(5);cache:draw({},available,'generic',5,8,32)
assert(fallback==at,'missing trimmed renderer substituted generic despite valid sprite')
local logs=0;print=function() logs=logs+1 end;B47ANCEDQuartermaster.ContainerSpriteTraceEnabled=true
for i=1,100 do local bad=object(i);bad.obj.sprite=nil;cache:texture(bad) end
assert(logs==32,'unbounded fallback diagnostics')
