dofile(TEST_ROOT..'/test_ledger_ui.lua')
local Q=B47ANCEDQuartermaster;local f=CONTAINER_FIXTURE;local S=require 'B47ANCEDQuartermaster/StockUI'
local targets={['Fixture.TypeA']=10};local revision=0;local changes=0;local delayed
local old=Q.Authority.request
Q.Authority.request=function(_,command,args,reply)
 if command=='stockOptions' then reply({status='ok',scopes={{kind='building',label='Building'}}})
 elseif command=='stockGet' or command=='stockSet' then
  if command=='stockSet' then
   assert(args.revision==revision and args.kind=='building');changes=changes+1;revision=revision+1;targets[args.fullType]=args.quantity>0 and args.quantity or nil
  end
  local copy={};for k,v in pairs(targets) do copy[k]=v end;reply({status='ok',targets=copy,revision=revision,canEdit=true})
 elseif command=='ledgerStock' then reply({status='ok',rows={{fullType='Fixture.TypeA',name='Item A',current=2,target=10,remaining=8}},live=false,fresh=false,complete=true,canNotify=false,interval=30})
 else return old(0,command,args,reply) end
end
local p=assert(S.open(0));p:prerender();local c=p.stockControls
assert(#c.list.items==1 and c.add.enable and c.quantity:isVisible())
c.list.onmousedown(p,c.list.items[1].item);c.quantity:setText('20');c.save.onclick()
assert(changes==1 and targets['Fixture.TypeA']==20)
c.remove.onclick();assert(changes==2 and targets['Fixture.TypeA']==nil)
local picker=require 'B47ANCEDQuartermaster/ItemPicker';local open=picker.open;local kind
picker.open=function(_,k,callback) kind=k;callback({fullType='Fixture.TypeB',quantity=7}) end
c.add.onclick();assert(kind=='stock' and targets['Fixture.TypeB']==7,'stock Add fell through to personal shopping/Needed')
picker.open=open;p:onKeyRelease(Keyboard.KEY_ESCAPE);assert(p.closed)
-- A carried paper can report stock without granting target-edit controls.
local paper={item=900};p=assert(S.open(0,nil,paper));p:prerender();c=p.stockControls
assert(#c.list.items==1 and not c.add:isVisible() and not c.quantity:isVisible() and not c.save:isVisible())
for _,row in ipairs(p.joypadButtonsY) do for _,widget in ipairs(row) do assert(widget:isVisible(),'hidden editing control in readonly focus') end end
c.save.onclick();assert(changes==3,'readonly paper mutated stock targets');p:close()
-- Stale replies cannot repopulate a closed stock window.
Q.Authority.request=function(_,command,args,reply) if command=='stockOptions' then delayed=reply else return old(0,command,args,reply) end end
p=assert(S.open(0));p:close();delayed({status='ok',scopes={{kind='building'}}});assert(p.closed)
Q.Authority.request=old
-- Production PC consumer: one stable notification, no paper/background writes.
local PC=require 'B47ANCEDPCFramework/API';local live=PC.ComputerUI.isLive;local notices=PC.Notifications
local posted,dismissed=0,0;local notice;local response={status='ok',canNotify=true,interval=30,rows={{fullType='Fixture.TypeA',name='Test',current=2,target=10,remaining=8}}}
PC.Notifications={version=1,post=function(_,n) posted=posted+1;notice=n;return true end,dismiss=function() dismissed=dismissed+1 end}
PC.ComputerUI.isLive=function() return true end
Q.Authority.request=function(_,command,args,reply) assert(command=='ledgerStock' and args.stockKind=='building');reply(response) end
local host={content={}};local watch=require('B47ANCEDQuartermaster/StockWatch').new(0,host,{item=900},host.content,function() return {} end)
watch:update();assert(posted==1 and notice.id=='stock.low' and not notice.silent)
watch.due=0;watch:update();assert(posted==2 and notice.silent,'continued low stock restarted the alert')
response.rows[1].remaining=0;watch.due=0;watch:update();assert(dismissed>0)
response.rows[1].remaining=8;watch.due=0;watch:update();assert(not notice.silent,'new shortage was suppressed')
response.canNotify=false;watch.due=0;local before=posted;watch:update();assert(posted==before,'historical stock emitted a live notification')
watch:close();watch.due=0;watch:update();assert(posted==before)
PC.Notifications=notices;PC.ComputerUI.isLive=live;Q.Authority.request=old
print('PASS OFFLINE PC stock watcher: stable alert IDs, silent repeats, recovery dismissal, new shortage alert, historical suppression and close cleanup')
print('PASS OFFLINE stock UI: normal-menu editor, scope/CAS payloads, minimum edit/remove/catalog callback, paper readonly quantities/focus and stale-close guard')
