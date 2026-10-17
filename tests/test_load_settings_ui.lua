dofile(TEST_ROOT..'/test_dev29_appearance.lua')
getPlayerScreenWidth=function() return 1280 end;getPlayerScreenHeight=function() return 720 end
getPlayerScreenLeft=function() return 0 end;getPlayerScreenTop=function() return 0 end
local Q=B47ANCEDQuartermaster;local actor=getSpecificPlayer(0)
actor.isDead=function() return false end
local sent={};local request=Q.Authority.request
Q.Authority.request=function(num,command,args,callback)
 sent[#sent+1]={command=command,args=args}
 if command=='loadGet' then callback({status='ok',hard=50,current=18,comfortable=20,policy={enabled=false,utilization=100,revision=4}})
 else assert(command=='loadChange');callback({status='ok'}) end
end
local V=require 'B47ANCEDQuartermaster/LoadSettingsUI'
V.open(0,Q.picker);local panel=assert(V.active[0])
assert(not panel.slider.visible and #sent==1)
-- The host widget stub omits the engine's instantiate/createChildren dispatch.
ISUIElement={setWidth=ISPanel.setWidth}
panel.slider:createChildren()
panel:setWidth(700);panel:prerender();assert(panel.slider:getWidth()==676 and panel.save:getWidth()==334,'resized controls overlapped')
V.open(0,Q.picker);assert(#sent==1,'repeated open emitted another request')
panel.toggle.onclick();assert(panel.slider.visible)
panel.slider:setCurrentValue(75)
panel.save.onclick()
assert(panel.closed and not V.active[0] and sent[2].args.enabled and sent[2].args.utilization==75 and sent[2].args.revision==4)
V.open(0,Q.picker);panel=V.active[0];local before=#sent
panel:onJoypadDown(Joypad.BButton);assert(panel.closed and #sent==before,'cancel wrote gameplay preference')
local warnings=0;actor.setHaloNote=function() warnings=warnings+1 end
getPlayerScreenHeight=function() return 120 end
V.open(0,Q.picker);assert(not V.active[0] and warnings==1,'short viewport opened clipped controls')
getPlayerScreenHeight=function() return 720 end
local reply
Q.Authority.request=function(_,_,_,callback) reply=callback end
V.open(0,Q.picker)
local old=getSpecificPlayer;getSpecificPlayer=function() return {} end
reply({status='ok'});assert(not V.active[0],'late response opened a previous actor dialog')
getSpecificPlayer=old;Q.Authority.request=request
print('PASS OFFLINE Dangerous Load UI: actual native slider/controller, off-state focus, 75% save/revision, cancel, duplicate open and late actor response')
