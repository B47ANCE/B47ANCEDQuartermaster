-- Quartermaster's domain-specific CD writer app.
local C=require 'B47ANCEDPCFramework/ComputerUI'
local U=B47ANCEDPCUI
return function(screen,hooks)
 local m=U.Theme.metrics();local actor=getSpecificPlayer(screen.playerNum)
 local function tr(k,...) return hooks.text(k,...) end
 local last=-10000;local sheets,discs,cds={},{},{}
 local function scan()
  if getTimestampMs()-last>=1000 then last=getTimestampMs();sheets,discs,cds=hooks.inventory(actor) end
  return sheets,discs,cds
 end
 local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
 local function view(title) return screen:view(title) end
 local function picked(c) return C.picked(c) end
 local function options(...) return C.options(...) end
 local function choice(v) return C.choice(v) end
 local function button(...) return C.button(...) end
 local function text(...) return C.text(...) end
 local P=C.colors
 local self=screen
  self:refreshDrive();local v=view(tr('ComputerWriter'));v.paper=choice(v);v.cd=choice(v)
  v.write=button(v,tr('ComputerWrite'),function()
   if screen.closed or screen.content~=v then return end
   local paper,cd=picked(v.paper),picked(v.cd)
   if v.closed or screen.closed or not paper or not cd or hooks.busy() then return end
   if screen.mounted or screen.occupied or not screen.driveReady or screen.drivePending then screen:message('ComputerEjectFirst');return end
   if not Media.computer(actor,screen.computer,true) then screen:close();return end
   hooks.burn(paper,cd,screen);screen:message('ComputerWriting')
  end)
  v.prerender=function(self)
   screen:refreshDrive();local sheets,discs,cds=scan();local complete={};for _,p in ipairs(sheets) do if p:getModData().B47Ledger and p:getModData().B47Ledger.complete then complete[#complete+1]=p end end
   local destinations={};for _,cd in ipairs(cds) do destinations[#destinations+1]=cd end
   for _,cd in ipairs(discs) do if Media.usable(cd) then destinations[#destinations+1]=cd end end
   options(self.paper,complete,'ComputerNoSheet');options(self.cd,destinations,'ComputerNoCD')
   local w,h=self:getWidth(),self:getHeight();text(self,tr('ComputerSource'),12,8,w-24)
   U.Layout.place(self.paper,12,12+m.font,w-24,m.button);text(self,tr('ComputerDestination'),12,24+m.font+m.button,w-24)
   U.Layout.place(self.cd,12,28+2*m.font+m.button,w-24,m.button)
   text(self,tr('ComputerOverwrite'),12,40+2*m.font+2*m.button,w-24,P.muted)
   self.write:setEnable(screen.driveReady and not screen.drivePending and not screen.occupied and not hooks.busy() and not screen.mounted and picked(self.paper)~=false and picked(self.cd)~=false)
   U.Layout.place(self.write,12,h-m.button-12,w-24,m.button)
  end
  v:insertNewLineOfButtons(v.paper);v:insertNewLineOfButtons(v.cd);v:insertNewLineOfButtons(v.write);v:prerender();self:refreshFocus();return v
 end
