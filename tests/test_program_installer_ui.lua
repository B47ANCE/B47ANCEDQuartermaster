-- Actual descriptor/host/context and Quartermaster client action path.
dofile(TEST_ROOT..'/test_ledger_ui.lua')
local Q=B47ANCEDQuartermaster;local V=Q.LedgerUI;local PC=require 'B47ANCEDPCFramework/API'
local P=require 'B47ANCEDQuartermaster/LedgerProgram';local f=CONTAINER_FIXTURE;local actor=f.player;local computer=f.a
SandboxVars.B47ANCEDQuartermaster.RequireComputerApplication=true
computer:getModData().B47QMProgramVersion=nil
ISTimedActionQueue.getTimedActionQueue(actor).queue={}
local mounted=false;local denied=false;local runs,installs,cancels=0,0,0
local descriptor={id=809,name='Quartermaster Application CD',fullType=P.disc,drive='setup-binding',token='setup-choice'}
Q.Authority.request=function(_,command,args,reply)
 if command=='ledgerSetupList' then reply({status='ok',choices={descriptor},mounted=mounted and descriptor or nil})
 elseif command=='ledgerSetupMount' then mounted=true;reply({status='ok',mounted=descriptor})
 elseif command=='ledgerSetupEject' then mounted=false;reply({status='ok'})
 elseif command=='ledgerProgramRun' then
  runs=runs+1
  assert(args.program==P.id and args.media==809 and args.drive=='setup-binding')
  if denied then reply({status='unavailable'}) else reply({status='ok',program={id=P.id,version=P.version},media=descriptor}) end
 elseif command=='ledgerProgramInstall' then
  installs=installs+1;assert(args.program==P.id and args.media==809 and args.drive=='setup-binding')
  reply({status='action',token='native-install-'..installs,seconds=20,kind='programInstall'})
 elseif command=='ledgerCancel' then cancels=cancels+1;reply({status='ok'})
 elseif command=='ledgerDriveList' then reply({status='ok',choices={}})
 else error('unexpected installer UI command '..tostring(command)) end
end
local ids=PC.availableApplications(0,computer)
for _,id in ipairs(ids) do assert(id~='quartermaster','uninstalled PC exposed ordinary app') end
local host=assert(V.computer(0,computer));assert(host.application==P.id and runs==0 and installs==0)
local drive=host:openDrive();drive.insert.onclick();assert(runs==0 and installs==0,'mount auto-installed program')
denied=true;host:runDisc();assert(not host.content.install,'refused program created installer')
denied=false;host:runDisc();local panel=host.content;assert(panel.install and installs==0,'opening installer installed immediately')
panel.install.onclick();assert(installs==1 and V.work[0].actionPending and not panel.install.enable)
panel.install.onclick();assert(installs==1,'double-click queued duplicate native install')
host:close();assert(not V.work[0] and cancels>0,'power/close left native installation running')
ISTimedActionQueue.getTimedActionQueue(actor).queue={}
host=assert(V.computer(0,computer));host:openDrive();host:runDisc();panel=host.content;panel.install.onclick()
local op=V.work[0];local beforeComplete=cancels;computer:getModData().B47QMProgramVersion=P.version -- simulated server ModData notification
Q.Ledger.clientResult(actor,{token=op.token,status='ProgramInstalled'})
host:prerender();assert(not V.work[0] and not panel.install.enable and cancels==beforeComplete,'completed install sent a broad cancellation')
host:eject();assert(not host.mounted,'installer CD remained mounted after explicit eject')
host=assert(V.computer(0,computer));assert(host.application=='quartermaster' and host.writerIcon:isVisible(),'installed PC lost ordinary reader/writer')
host:close()
local measure,width,height=getTextManager,getPlayerScreenWidth,getPlayerScreenHeight
getPlayerScreenWidth=function() return 3840 end;getPlayerScreenHeight=function() return 2160 end
computer:getModData().B47QMProgramVersion=nil
for _,font in ipairs({14,24,32,42}) do
 getTextManager=function() return {getFontHeight=function() return font end,MeasureStringX=function(_,_,text) return #text*font/2 end} end
 host=assert(V.computer(0,computer));host:setWidth(host.minimumWidth);host:setHeight(host.minimumHeight);host:prerender()
 drive=host:openDrive();if not mounted then drive.insert.onclick() end;host:runDisc();panel=host.content;panel:updateComputer()
 for _,child in ipairs(panel.children) do
  assert(child.x>=0 and child.x+child.width<=panel.width and child.y+child.height<=panel.height,'installer child escaped at font '..font)
  if child.captionText then assert(child.y+child.height<panel.install.y,'installer instruction overlaps action at font '..font) end
 end
 host:close()
end
getTextManager,getPlayerScreenWidth,getPlayerScreenHeight=measure,width,height
print('PASS OFFLINE Quartermaster installer UI: genuine CD descriptor, explicit mount/run/install, denial, native queue, double-click guard, cancellation, server completion/notification, eject and installed app availability')
