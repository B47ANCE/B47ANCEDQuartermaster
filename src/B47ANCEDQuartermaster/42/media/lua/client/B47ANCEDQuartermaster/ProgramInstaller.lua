-- Real CD launch/host lifecycle is PC Framework API 1; Quartermaster owns the
-- challenged install action and per-computer server receipt.
return function(PC,V)
 local Program=require 'B47ANCEDQuartermaster/LedgerProgram'
 local Policy=require 'B47ANCEDQuartermaster/LedgerPolicy'
 local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
 local function tr(k) return getText('UI_QMSS_'..k) end
 assert(type(PC.supports)=='function' and PC.supports('cd-programs') and PC.getAPIInfo().cdProgramVersion==1,'Quartermaster requires PC Framework CD program API 1')
 local function request(ctx,command,args,reply)
  local s=ctx.computer:getSquare();if not s then reply({status='LedgerPower'});return end
  args.computer={x=s:getX(),y=s:getY(),z=s:getZ(),index=ctx.computer:getObjectIndex()}
  B47ANCEDQuartermaster.Authority.request(ctx.playerNum,command,args,reply)
 end
 PC.registerCDProgram({id=Program.id,version=Program.version,titleKey='UI_QMSS_ProgramSetup',file='SETUP.EXE',mediaTypes={Program.disc},
  enabled=function() return Policy.enabled() end,
  canUse=function(ctx,near) return Media.computer(ctx.player,ctx.computer,near) end,
  drive=function(ctx,command,args,reply)
   request(ctx,({list='ledgerSetupList',mount='ledgerSetupMount',eject='ledgerSetupEject'})[command],args,reply)
  end,
  requestRun=function(ctx,args,reply) request(ctx,'ledgerProgramRun',args,reply) end,
  onDenied=function(ctx) ctx.player:setHaloNote(tr('ProgramInstallDenied')) end,
  onClose=function(ctx) local op=V.work[ctx.playerNum];if op and op.install then V.cancel(ctx.playerNum) end end,
  create=function(ctx)
   local UI=PC.UI;local labels={};local status=tr('ProgramInstallReady');local working=false
   local window=ctx.window({titleKey='UI_QMSS_ProgramSetup',onResize=function(self,w,h)
    local m=UI.metrics()
    for n,label in ipairs(labels) do UI.place(label,12,12+(n-1)*(m.font+10),w-24,m.font+6) end
    UI.place(self.install,12,h-m.button-12,w-24,m.button)
   end,onUpdate=function(self)
    local installed=ctx.computer:getModData().B47QMProgramVersion==Program.version
    self.install:setEnable(not working and not installed)
    labels[4]:setText(installed and tr('ProgramInstalledHelp') or status)
   end})
   for _,key in ipairs({'ProgramInstallIntro','ProgramInstallRetained','ProgramInstallStorage','ProgramInstallReady'}) do
    labels[#labels+1]=UI.label(window,{text=tr(key)})
   end
   window.install=UI.button(window,{textKey='UI_QMSS_ProgramInstall',onClick=ctx.guard(function()
    if working then return end;working=true;status=tr('ProgramInstalling');window.install:setEnable(false)
    V.installProgram(ctx.playerNum,ctx.computer,ctx.media,function(result)
     working=false
     if ctx.isActive() then status=tr(result=='ProgramInstalled' and 'ProgramInstalledHelp' or result) end
    end)
   end)})
   UI.focus(window,{{window.install}});window:updateComputer();return window
  end
 })
end
