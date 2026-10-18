local SharedUI=require 'B47ANCEDQuartermaster/UIProvider'
-- Read-only Windows '93 ledger presentation. Receives authorized page rows only.
local U=SharedUI;local R=U.Renderer
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
function T.new(panel,list,search,rooms,previous,more,close,m,p,paper)
 local view={columns={},page=1,count=0,status=tr('LedgerLoading'),summary='',emptyLabel=tr('LedgerLoading'),paper=paper,left=paper and 38 or 8,rowHeight=m.font+10}
 list.itemheight=m.font+10;list.altBgColor=nil;list.joypadParent=panel;list.resetSelectionOnChangeFocus=false
 function view:layout()
  local w,h=panel:getWidth(),panel:getHeight();local inputY=m.font+12;local left=self.left
  local mode=panel.ledgerControls and panel.ledgerControls.networkMode
  local roomX=math.floor(w*(mode and .45 or .60));local roomRight=mode and math.floor(w*.70) or w
  if not paper then
   U.Layout.place(search,8,inputY,roomX-16,m.button)
   U.Layout.place(rooms,roomX,inputY,roomRight-roomX-8,m.button)
   if mode then U.Layout.place(mode,roomRight,inputY,w-roomRight-8,m.button) end
  end
  self.statusY=paper and 66+m.font+12 or inputY+m.button+8;self.headerY=self.statusY+m.font+10
  self.detailsHeight=paper and 3*m.font+24 or 2*m.font+16
  self.detailsY=paper and h-m.button-22-self.detailsHeight-8 or h-m.button-2*m.font-40
  U.Layout.place(list,left,self.headerY+m.button,w-2*left,math.max(list.itemheight,self.detailsY-8-self.headerY-m.button))
  U.Layout.scrollbar(list)
  local usable=list:getWidth()-m.scrollbar-2
  local qty=math.min(math.floor(usable*.25),math.max(64,getTextManager():MeasureStringX(U.Theme.fonts.body,tr('LedgerTableQuantity'))+16))
  local item=math.floor((usable-qty)*.43)
  self.columns={{x=1,width=item,label=tr('LedgerTableItem')},{x=item+1,width=qty,label=tr('LedgerTableQuantity')},{x=item+qty+1,width=usable-item-qty,label=tr('LedgerTableLocation')}}
  local stock=panel.ledgerControls and panel.ledgerControls.stock
  local count=stock and 4 or 3
  local bw=math.min(math.floor((w-2*left-8*(count-1))/count),math.max(120,m.font*9));local footer=h-m.button-(paper and 22 or 8)
  U.Layout.place(previous,left,footer,bw,m.button)
  U.Layout.place(more,left+8+bw,footer,bw,m.button)
  if stock then U.Layout.place(stock,left+16+2*bw,footer,bw,m.button) end
  U.Layout.place(close,w-left-bw,footer,bw,m.button)
 end
 function view:drawRow(y,row,alt)
  local height=list.itemheight
  if y+list:getYScroll()+height<=0 or y+list:getYScroll()>=list:getHeight() then return y+height end
  local data=row.item;local selected=list.selected==row.index
  local bg=selected and (p.selection or p.blue) or alt and p.light or p.white
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
   R.text(list,row.ledgerCells[i],x,y+5,selected and (p.selectedText or p.white) or p.black)
   if i>1 then R.rect(list,col.x,y,1,height,p.grey) end
  end
  if paper then R.rect(list,1,y+height-1,list:getWidth()-m.scrollbar-2,1,p.shadow) end
  return y+height
 end
 function view:draw()
  local w=panel:getWidth();local mode=panel.ledgerControls and panel.ledgerControls.networkMode
  local roomX=math.floor(w*(mode and .45 or .60));local roomRight=mode and math.floor(w*.70) or w;local left=self.left;local width=w-2*left
  if paper then paper.draw(panel,self,m)
  else
   R.rect(panel,0,0,w,panel:getHeight(),p.grey)
   R.text(panel,R.fit(tr('LedgerTableSearch'),roomX-16),8,6,p.black)
   R.text(panel,R.fit(tr('LedgerTableRoom'),(mode and w*.25 or w-roomX)-8),roomX,6,p.black)
   if mode then R.text(panel,R.fit(tr('LedgerViewLabel'),w*.30-8),math.floor(w*.70),6,p.black) end
  end
  local page=tr(paper and 'LedgerClipboardPage' or 'LedgerTablePage',self.page,self.count)
  local pageWidth=math.min(w*.40,getTextManager():MeasureStringX(U.Theme.fonts.body,page))
  R.text(panel,R.fit(self.status,width-pageWidth-20),left,self.statusY,p.black)
  R.text(panel,R.fit(page,pageWidth),w-pageWidth-left,self.statusY,p.muted)
  inset(panel,list.x,list.y,list:getWidth(),list:getHeight(),p)
  if paper then
   -- The native list scrolls rows; the page background must use the same phase.
   local y=list.y+(list:getYScroll()+list.itemheight-1)%list.itemheight
   while y<list.y+list:getHeight() do R.rect(panel,list.x+1,y,list:getWidth()-2,1,p.shadow);y=y+list.itemheight end
  end
  if self.count==0 then R.text(panel,R.fit(self.emptyLabel,list:getWidth()-32),list.x+8,list.y+8,p.muted) end
  -- Fixed header is outside the scrolling viewport. Reserve its scrollbar gutter.
  R.rect(panel,left,self.headerY,list:getWidth(),m.button,p.grey)
  for _,col in ipairs(self.columns) do
   local x=left+col.x;local y=self.headerY
   R.border(panel,x,y,col.width,m.button,p.shadow)
   if not paper then R.rect(panel,x,y,col.width-1,1,p.light);R.rect(panel,x,y,1,m.button-1,p.light) end
   R.text(panel,R.fit(col.label,col.width-16),x+8,y+(m.button-m.font)/2,p.black)
  end
  inset(panel,left,self.detailsY,width,self.detailsHeight,p)
  local row=list.items[list.selected];local lines=row and T.lines(row.item)
  if paper then
   R.text(panel,R.fit(lines and lines[1] or tr('LedgerTableSelect'),width-16),left+8,self.detailsY+6,p.black)
   R.text(panel,R.fit(lines and lines[2] or self.summary,width-16),left+8,self.detailsY+m.font+10,p.muted)
   R.text(panel,R.fit(lines and lines[3] or '',width-16),left+8,self.detailsY+2*m.font+14,p.muted)
  else
   R.text(panel,R.fit(lines and lines[3] or tr('LedgerTableSelect'),width-16),left+8,self.detailsY+6,p.black)
   R.text(panel,R.fit(lines and lines[2] or self.summary,width-16),left+8,self.detailsY+m.font+10,p.muted)
  end
 end
 list.doDrawItem=function(_,y,row,alt) return view:drawRow(y,row,alt) end
 return view
end
return T
