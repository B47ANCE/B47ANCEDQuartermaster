-- Read-only Windows '93 ledger presentation. Receives authorized page rows only.
require 'B47ANCEDUI/Controls'
local U=B47ANCEDUI;local R=U.Renderer
local T={}
local function tr(k,...) return getText('UI_QMSS_'..k,...) end
local function plain(s) return U.Tooltip.plain(tostring(s or '')) end
function T.key(data)
 if not data then return end
 local p=data.position
 -- Length-prefix fields: names and IDs may contain punctuation/separators.
 local fields={data.fullType,data.roomID,p.x,p.y,p.z,p.ci,data.condition}
 local parts={};for i=1,7 do local s=tostring(fields[i] or '');parts[i]=#s..':'..s end
 return table.concat(parts)
end
function T.lines(data)
 local p=data.position
 return {plain(data.empty and tr('LedgerEmpty') or tr('LedgerItemLine',data.name,data.quantity)),
  plain(tr('LedgerLocationLine',data.room,data.container,p.x,p.y,p.z,p.ci+1)),
  plain(tr('LedgerRecordedLine',data.recorded,data.fullType,data.condition))}
end
local function inset(w,x,y,width,height,p)
 R.rect(w,x,y,width,height,p.white);R.border(w,x,y,width,height,p.light)
 R.rect(w,x,y,width,1,p.shadow);R.rect(w,x,y,1,height,p.shadow)
end
function T.new(panel,list,search,rooms,previous,more,close,m,p)
 local view={columns={},page=1,count=0,status=tr('LedgerLoading'),summary='',emptyLabel=tr('LedgerLoading')}
 list.itemheight=m.font+10;list.altBgColor=nil;list.joypadParent=panel;list.resetSelectionOnChangeFocus=false
 function view:layout()
  local w,h=panel:getWidth(),panel:getHeight();local inputY=m.font+12
  local roomX=math.floor(w*.60)
  U.Layout.place(search,8,inputY,roomX-16,m.button)
  U.Layout.place(rooms,roomX,inputY,w-roomX-8,m.button)
  self.statusY=inputY+m.button+8;self.headerY=self.statusY+m.font+10
  self.detailsY=h-m.button-2*m.font-40
  self.detailsHeight=2*m.font+16
  U.Layout.place(list,8,self.headerY+m.button,w-16,math.max(list.itemheight,self.detailsY-8-self.headerY-m.button))
  U.Layout.scrollbar(list)
  local usable=list:getWidth()-m.scrollbar-2
  local qty=math.min(math.floor(usable*.25),math.max(64,getTextManager():MeasureStringX(U.Theme.fonts.body,tr('LedgerTableQuantity'))+16))
  local item=math.floor((usable-qty)*.43)
  self.columns={{x=1,width=item,label=tr('LedgerTableItem')},{x=item+1,width=qty,label=tr('LedgerTableQuantity')},{x=item+qty+1,width=usable-item-qty,label=tr('LedgerTableLocation')}}
  local bw=math.min(math.floor((w-32)/3),math.max(120,m.font*9))
  U.Layout.place(previous,8,h-m.button-8,bw,m.button)
  U.Layout.place(more,16+bw,h-m.button-8,bw,m.button)
  U.Layout.place(close,w-8-bw,h-m.button-8,bw,m.button)
 end
 function view:drawRow(y,row,alt)
  local height=list.itemheight
  if y+list:getYScroll()+height<=0 or y+list:getYScroll()>=list:getHeight() then return y+height end
  local data=row.item;local selected=list.selected==row.index
  local bg=selected and p.blue or alt and p.light or p.white
  R.rect(list,1,y,list:getWidth()-m.scrollbar-2,height,bg)
  if row.ledgerWidth~=list:getWidth() then
   row.ledgerFull=T.lines(data)
   local cells={data.empty and tr('LedgerEmpty') or data.name,tostring(data.quantity),plain(data.room)..' / '..plain(data.container)}
   row.ledgerCells={}
   local clipped=false
   for i,col in ipairs(self.columns) do local cell=plain(cells[i]);row.ledgerCells[i]=R.fit(cell,col.width-16);clipped=clipped or cell~=row.ledgerCells[i] end
   row.ledgerQuantityWidth=getTextManager():MeasureStringX(U.Theme.fonts.body,row.ledgerCells[2])
   row.tooltip=clipped and table.concat(row.ledgerFull,'<LINE>') or nil;row.ledgerWidth=list:getWidth()
  end
  for i,col in ipairs(self.columns) do
   local x=i==2 and col.x+col.width-8-row.ledgerQuantityWidth or col.x+8
   R.text(list,row.ledgerCells[i],x,y+5,selected and p.white or p.black)
   if i>1 then R.rect(list,col.x,y,1,height,p.grey) end
  end
  return y+height
 end
 function view:draw()
  local w=panel:getWidth();local roomX=math.floor(w*.60)
  R.rect(panel,0,0,w,panel:getHeight(),p.grey)
  R.text(panel,R.fit(tr('LedgerTableSearch'),roomX-16),8,6,p.black)
  R.text(panel,R.fit(tr('LedgerTableRoom'),w-roomX-8),roomX,6,p.black)
  local page=tr('LedgerTablePage',self.page,self.count)
  local pageWidth=math.min(w*.40,getTextManager():MeasureStringX(U.Theme.fonts.body,page))
  R.text(panel,R.fit(self.status,w-pageWidth-36),8,self.statusY,p.black)
  R.text(panel,R.fit(page,pageWidth),w-pageWidth-8,self.statusY,p.muted)
  inset(panel,list.x,list.y,list:getWidth(),list:getHeight(),p)
  if self.count==0 then R.text(panel,R.fit(self.emptyLabel,list:getWidth()-32),list.x+8,list.y+8,p.muted) end
  -- Fixed header is outside the scrolling viewport. Reserve its scrollbar gutter.
  R.rect(panel,8,self.headerY,list:getWidth(),m.button,p.grey)
  for _,col in ipairs(self.columns) do
   local x=8+col.x;local y=self.headerY
   R.border(panel,x,y,col.width,m.button,p.shadow)
   R.rect(panel,x,y,col.width-1,1,p.light);R.rect(panel,x,y,1,m.button-1,p.light)
   R.text(panel,R.fit(col.label,col.width-16),x+8,y+(m.button-m.font)/2,p.black)
  end
  inset(panel,8,self.detailsY,w-16,self.detailsHeight,p)
  local row=list.items[list.selected];local lines=row and T.lines(row.item)
  R.text(panel,R.fit(lines and lines[3] or tr('LedgerTableSelect'),w-32),16,self.detailsY+6,p.black)
  R.text(panel,R.fit(lines and lines[2] or self.summary,w-32),16,self.detailsY+m.font+10,p.muted)
 end
 list.doDrawItem=function(_,y,row,alt) return view:drawRow(y,row,alt) end
 return view
end
return T
