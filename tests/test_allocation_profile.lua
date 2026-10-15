local A=require 'B47ANCEDQuartermaster/AllocationProfile'
local parent={Perishable='Food',Meat='Perishable',Produce='Perishable',Canned='Food'}
local resolver={parent=function(id) return parent[id] end}
local index=assert(A.index({{fullType='Base.Steak',name='Meat',category='Meat'},{fullType='Other.Steak',name='Meat',category='Meat'},
 {fullType='Base.Chicken',category='Meat'},{fullType='Base.Cabbage',category='Produce'},{fullType='Base.Beans',category='Canned'}},resolver))
local p=A.empty();assert(A.valid(p));p=assert(A.setCategory(p,'Food',50,index))
assert(A.value(p,'Base.Steak',index.items['Base.Steak'].path)==50 and #A.ceilings(p,'Base.Steak',index.items['Base.Steak'].path)==1)
p=assert(A.setCategory(p,'Meat',100,index));p=assert(A.setItem(p,'Base.Steak',25,index.items['Base.Steak'].path))
assert(A.value(p,'Other.Steak',index.items['Other.Steak'].path)==100,'localized/shared name became allocation identity')
local v,state=A.state(p,'Meat',index);assert(v==nil and state=='mixed')
local ceilings=A.ceilings(p,'Base.Steak',index.items['Base.Steak'].path)
assert(#ceilings==3 and ceilings[1].percent==50 and ceilings[2].percent==100 and ceilings[3].percent==25,'ancestor limits were multiplied or lost')
p=assert(A.setCategory(p,'Canned',0,index));p=assert(A.setCategory(p,'Meat',75,index))
assert(p.items['Base.Steak']==nil and p.cats.Canned==0 and p.cats.Food==50)
p=assert(A.setItem(p,'Removed.Fish',40,{'Food','Perishable','Meat'}))
p=assert(A.setItem(p,'Unrelated.Removed',10,{'Unknown'}));p=assert(A.setCategory(p,'Perishable',60,index))
assert(p.items['Removed.Fish']==nil and p.items['Unrelated.Removed']==10 and p.cats.Canned==0)
assert(A.value(p,'New.Food',{'Food','Perishable','Meat'})==60,'new modded child did not inherit')
p=assert(A.reset(p,'category','Perishable'));assert(A.value(p,'Base.Chicken',index.items['Base.Chicken'].path)==50)
assert(A.equal(p,A.copy(p)));local clone=A.copy(p);clone.cats.Food=0;assert(not A.equal(p,clone) and p.cats.Food==50)
assert(not A.setItem(p,'Localized Name',50,{}));assert(not A.setItem(p,'Base.Steak',0/0,{}))
local corrupt=A.copy(p);corrupt.items['Base.Bad']=101;assert(not A.valid(corrupt))
corrupt=A.copy(p);corrupt.paths['No.Override']={'Food'};assert(not A.valid(corrupt))
local preset=A.empty(0);preset.cats.Food=60;local localProfile=A.empty();localProfile.items['Base.Steak']=25
local effective=A.effective(localProfile,{preset});assert(effective.default==0 and effective.cats.Food==60 and effective.items['Base.Steak']==25)
local cycle={parent=function(id) return id end};assert(not A.index({{fullType='Base.X',category='X'}},cycle))
print('PASS OFFLINE sparse allocation: hierarchy/propagation, siblings, Mixed, exact FullType, inheritance, explicit aggregate ceilings, orphan preservation, reset and preset composition')
