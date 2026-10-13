local Model = require 'B47ANCEDQuartermaster/Model'
local function fixture(cats, items)
    local p = { selectedCats = cats or {}, selectedItems = items or {} }
    local api = {
        getCategories = function() return {'Food', 'Medical'} end,
        getItemNames = function() return {'Apple','Bread','Shared','Bandage','Loose'} end,
        getItemsInCategory = function(cat)
            if cat == 'Food' then return {{name='Apple'},{name='Bread'},{name='Shared'}} end
            if cat == 'Medical' then return {{name='Bandage'},{name='Shared'}} end
            return {}
        end,
    }
    local m = Model.new(p, api, 'Other')
    return p, m, m.byId['c:Food'], m.byId['c:Medical']
end

local p,m,f,d = fixture({Food=true}, {Legacy=true})
assert(f.state=='full' and not p.selectedItems.Apple and p.selectedItems.Legacy)
m:rows('', false, nil, {})
assert(p.selectedCats.Food and not p.selectedItems.Apple, 'render/open mutated config')
m:setItem(f,'Bread',false)
assert(not p.selectedCats.Food and p.selectedItems.Apple and p.selectedItems.Shared and not p.selectedItems.Bread)
assert(f.state=='partial' and d.state=='partial')
m:setItem(f,'Bread',true)
assert(p.selectedCats.Food and not p.selectedItems.Apple and not p.selectedItems.Bread)
assert(p.selectedItems.Shared and d.state=='partial', 'normalization lost another category coverage')
m:setGroup(f,false)
assert(f.state=='none' and d.state=='none' and p.selectedItems.Legacy)
m:setGroup(f,true)
assert(p.selectedCats.Food and not p.selectedItems.Apple)
m:setItem(f,'Apple',false)
m:setGroup(f,false)
assert(f.state=='none')

p,m,f,d = fixture({}, {Apple=true})
m:setItem(f,'Bread',true)
m:setItem(f,'Shared',true)
assert(p.selectedCats.Food and p.selectedItems.Apple, 'pre-existing explicit precedence was removed')
assert(not p.selectedItems.Bread and p.selectedItems.Shared)

p,m,f,d = fixture({Food=true,Medical=true})
m:setItem(f,'Apple',false)
m:setItem(f,'Apple',true)
assert(p.selectedCats.Food and p.selectedCats.Medical and not p.selectedItems.Shared)

p,m,f,d = fixture({}, {Apple=true,Bread=true,Shared=true})
assert(f.state=='full' and not p.selectedCats.Food, 'opening must preserve existing representation')
local rows = m:rows('bread',false,nil,{})
assert(#rows==3 and rows[1].group==f and rows[3].key=='Bread')
rows = m:rows('food',false,nil,{})
assert(#rows==5)
rows = m:rows('',false,nil,{})
assert(#rows==3, 'compact categories plus Other')
rows = m:rows('bread',true,{Apple=true}, {})
assert(#rows==0, 'filters must AND together')
rows = m:rows('',true,{Apple=true}, {})
assert(#rows==3 and rows[3].key=='Apple')

p,m,f,d = fixture({MissingCategory=true},{MissingItem=true})
assert(m.byId['c:MissingCategory'].state=='full')
local other=m.byId['other:']
assert(other and #other.children==2)
m:setItem(other,'MissingItem',false)
assert(not p.selectedItems.MissingItem)
m:setGroup(m.byId['c:MissingCategory'],false)
assert(not p.selectedCats.MissingCategory)
local cats,items=p.selectedCats,p.selectedItems
m:clear()
assert(p.selectedCats==cats and p.selectedItems==items)

-- Final selected child -> none; a zero-child native category is still editable.
p,m,f,d = fixture({}, {Bread=true})
m:setItem(f,'Bread',false)
assert(f.state=='none')

-- A single shared name may remain covered in a different category by its own native rule.
p,m,f,d = fixture({Food=true,Medical=true})
m:setItem(f,'Shared',false)
assert(not m:covered(f,'Shared') and m:covered(d,'Shared'))
assert(p.selectedCats.Medical)
print('PASS model: transitions, normalization, shared names, filtering, stale data, no mutation on open')
