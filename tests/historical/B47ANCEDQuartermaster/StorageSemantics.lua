-- Owned interpretation of stable vanilla script identity, never instance state.
-- No external classifier/data. Narrow Base families are scoped and metadata-gated.
local H={}
local function read(o,key,...)
    if not o then return nil end
    local ok,v=pcall(function(...) return o[key](o,...) end,...)
    return ok and v or nil
end
local function atom(v) return v and tostring(v):lower():gsub('^.-:',''):gsub('[%s_%-]','') or '' end
local function any(tags,list) for _,t in ipairs(list) do if tags[t] then return true end end end
local alcohol={beer=true,wine=true,whiskey=true,brandy=true,gin=true,rum=true,vodka=true,tequila=true,
 scotch=true,port=true,sherry=true,vermouth=true,champagne=true,cider=true,coffeeliqueur=true,curacao=true}
local drinks={cowmilk=true,milkchocolate=true,juiceapple=true,juicecranberry=true,juicefruitpunch=true,
 juicegrape=true,juiceorange=true,juicetomato=true,cola=true,coladiet=true,gingerale=true,
 sodagrape=true,sodastrewberry=true,sodapop=true,sodalime=true,sodablueberry=true,
 sodabubblegum=true,sodapineapple=true,carbonatedwater=true}
-- Grenadine, SimpleSyrup and JuiceLemon remain ingredients; Petrol/RubbingAlcohol
-- are not drinks. Random choices classify only when ALL declared options agree.
function H.fluids(item)
    local out={}
    local component=ComponentType and read(item,'getComponentScriptFor',ComponentType.FluidContainer)
    if not component then return out end
    local random=read(component,'isInitialFluidsIsRandom')==true
    local list=read(component,'getInitialFluids');if not list then return out,random,component end
    local count=read(list,'size')
    if type(list)=='table' and not count then count=#list end
    if type(count)~='number' or count<0 or count>64 then return out end
    for i=0,count-1 do
        local entry=type(list)=='table' and not list.get and list[i+1] or read(list,'get',i)
        local percent=read(entry,'getPercentage')
        if type(percent)=='number' and percent>0 then out[atom(read(entry,'getFluidType'))]=true end
    end
    return out,random,component
end
-- These rules are NOT a global name heuristic. Each pattern requires Base module
-- and the specified existing vanilla semantic category. All matches are audited.
H.families={
 {id='seed-packaging',category='OutdoorFarming',display={RecipeResource=true,Gardening=true},kind='literature',pattern='^%a+BagSeed_Empty$'},
 {id='fabric-roll',category='MaterialsTextile',display={Material=true},pattern='^FabricRoll_%a+$'},
 {id='strip-bundle',category='MaterialsTextile',display={Material=true},pattern='^DenimStrips%a*Bundle$'},
 {id='leather-stock',category='MaterialsTextile',display={Material=true},pattern='^LeatherStrips%a*$'},
 {id='sheet-bundle',category='MaterialsTextile',display={Material=true},pattern='^RippedSheets%a*Bundle$'},
 {id='flax-processing',category='MaterialsTextile',display={Material=true},pattern='^Flax%a*$'},
 {id='hemp-processing',category='MaterialsTextile',display={Material=true},pattern='^Hemp%a*$'},
 {id='fur-tuft',category='MaterialsAnimal',display={Junk=true},pattern='^FurTuft_%a+$'},
 {id='log-stack',category='MaterialsWood',display={Material=true},pattern='^LogStacks[234]$'},
 {id='anvil',category='ToolsMetal',display={Tool=true},pattern='^%a*Anvil$'},
 {id='recreation-board',category='Recreation',display={Junk=true},pattern='^%a+Board$'},
 {id='chess-piece',category='Recreation',display={Junk=true},pattern='^Chess%a+$'},
 {id='game-piece',category='Recreation',display={Junk=true},pattern='^GamePiece%a+$'},
 {id='tarp-stock',category='MaterialsTextile',display={Material=true},pattern='^Tarp%a*$'},
 {id='vise-mold',category='MaterialsOther',display={Tool=true},pattern='^%a+CrudeBenchVisePartsMold%a*$'},
 -- Verified CanBeWrite=true script families. Item has no exposed writable getter;
 -- never read Java instance fields through Lua or debug/private reflection.
 {id='notebook',category='LiteratureNotes',display={Literature=true},kind='literature',pattern='^Notebook$'},
 {id='journal',category='LiteratureNotes',display={Literature=true},kind='literature',pattern='^Journal$'},
 {id='notepad',category='LiteratureNotes',display={Literature=true},kind='literature',pattern='^Notepad$'},
 {id='diary',category='LiteratureNotes',display={Literature=true},kind='literature',pattern='^Diary[12]$'},
 {id='loose-writing-paper',category='LiteratureNotes',display={Literature=true},kind='literature',pattern='^SheetPaper2$'},
 {id='graph-paper',category='LiteratureNotes',display={Literature=true},kind='literature',pattern='^GraphPaper$'},
 {id='index-card',category='LiteratureNotes',display={Literature=true,Junk=true},kind='literature',pattern='^IndexCard$'},
 {id='menu-card',category='LiteratureNotes',display={Literature=true},kind='literature',pattern='^MenuCard$'},
 {id='personal-card',category='LiteratureNotes',display={Literature=true,Memento=true},kind='literature',pattern='^Card_%a+$'},
 {id='blank-id',category='LiteratureNotes',display={Literature=true,Junk=true},kind='literature',pattern='^IDcard_Blank$'},
 {id='canned-fruit-drink',category='BeveragesOther',display={Food=true},pattern='^CannedFruitBeverage[_%a]*$'},
 {id='canned-milk',category='BeveragesMilk',display={Food=true},pattern='^CannedMilk[_%a]*$'},
}
function H.matches(item,tags,kind,display,fullType)
    local out={}
    local function add(cat,why,on) if on then out[#out+1]={category='B47_'..cat,reason=why} end end
    local localName=type(fullType)=='string' and fullType:match('^Base%.([%w_]+)$')
    if localName then
        for _,f in ipairs(H.families) do
            add(f.category,'family:'..f.id,f.display[display] and (not f.kind or f.kind==kind) and localName:match(f.pattern))
        end
    end
    -- Native purpose wins over incidental improvised weapon/material/memento use.
    add('Instruments','instrument-identity',display=='Instrument' or display=='InstrumentWeapon' or any(tags,{'harmonica','whistle'}))
    add('BeveragesWater','water-product-category',display=='Water')
    add('Smoking','smoking-purpose',any(tags,{'smokable','tobacco','chewingtobacco','rollingpaper','smokingpipe'}))
    add('Recreation','recreation-purpose',display=='Sports' or tags.dice)
    add('AnimalSupplies','animal-care',display=='Animal' and kind~='animal')
    add('ElectricalOther','camera-purpose',tags.camera)
    -- Multiple distinct tool roles establish a multipurpose tool, not a sewing
    -- implement/metalworking tool merely because one accessory function matches.
    local roles=0
    for _,group in ipairs({{'smithinghammer','sheetmetalsnips','smallfiles'}, {'hammer','saw'},
        {'wrench','lugwrench'},{'awl','sewingneedle','needle'},{'sharpknife','scissors'},{'screwdriver','pliers'}}) do
        if any(tags,group) then roles=roles+1 end
    end
    add('ToolsGeneral','multipurpose-tool',roles>=3 and (display=='Tool' or display=='ToolWeapon'))
    -- Writing utensils are stationery, writable/readable documents remain literature.
    add('Stationery','writing-utensil',kind~='literature' and any(tags,{'pen','pencil','bluepen','redpen','greenpen','eraser','correctionfluid'}))
    add('HouseholdCleaning','cleaning-purpose',tags.cleanstains)
    add('HouseholdKitchen','kitchen-purpose',display=='Cooking' or display=='CookingWeapon' or tags.coffeemaker)
    add('HouseholdCare','grooming-purpose',display=='Appearance' or any(tags,{'razor','dohairdo'}))
    add('BeveragesMilk','drinkable-food',kind=='food' and tags.milk and tags.wetbeverageingredient)
    -- EatType CanDrink also animates canned meals; it does not establish beverage purpose.
    add('ElectricalComponents','electrical-component',tags.wire)
    add('MaterialsFasteners','sewing-fastener',display=='Material' and tags.button)
    add('MaterialsBinding','binding-purpose',(display=='Material' or display=='MaterialWeapon' or display=='Tool') and any(tags,{'epoxy','fiberglasstape','rope','twine','glue','tape','binding','inferiorbinding','wallpaperpaste'}))
    -- Medical dressings and raw textile semantics are not interchangeable.
    add('MaterialsTextile','textile-purpose',(display=='Material' or display=='MaterialWeapon') and any(tags,{'thread','fabric','leather','heavythread','sheet'}))
    add('MaterialsWood','wood-purpose',(display=='Material' or display=='MaterialWeapon') and any(tags,{'log','plank','woodhandle','giveslongstick','charcoal'}))
    add('ToolsMetal','smithing-purpose',display~='Cooking' and display~='CookingWeapon' and any(tags,{'headingtool','tongs','crudetongs','smallfiles','metalworkingpliers','smithinghammer'}))
    add('ToolsSewing','sewing-purpose',tags.thimble or tags.fleshingtool)
    -- Purposeful electronic tools (e.g. sheep shears) keep their tool discipline.
    add('ElectricalOther','electronic-device',tags.megaphone)
    local fluids,random,component=H.fluids(item)
    local hasAlcohol,hasDrink,onlyDrink,onlyAlcohol=false,false,true,true
    for f in pairs(fluids) do
        if alcohol[f] then hasAlcohol=true end;if drinks[f] then hasDrink=true end
        if not alcohol[f] and not drinks[f] and f~='water' then onlyDrink=false end
        if not alcohol[f] then onlyAlcohol=false end
    end
    add('BeveragesAlcohol','script-initial-alcohol',onlyDrink and hasAlcohol and (not random or onlyAlcohol))
    local soda={cola=true,coladiet=true,gingerale=true,sodagrape=true,sodastrewberry=true,sodapop=true,sodalime=true,sodablueberry=true,sodabubblegum=true,sodapineapple=true,carbonatedwater=true}
    local milk={cowmilk=true,milkchocolate=true}
    local onlySoda,onlyMilk,onlyWater,hasFluid=true,true,true,false
    for f in pairs(fluids) do
        hasFluid=true
        if not soda[f] then onlySoda=false end
        if not milk[f] then onlyMilk=false end
        if f~='water' then onlyWater=false end
    end
    add('BeveragesSoda','script-initial-soda',hasFluid and onlySoda)
    add('BeveragesMilk','script-initial-milk',hasFluid and onlyMilk)
    add('BeveragesWater','script-initial-water',hasFluid and onlyWater and kind~='container' and (display=='Food' or display=='Water' or display=='WaterContainer' or tags.waterbottle))
    add('BeveragesOther','script-initial-drink',onlyDrink and hasDrink and (not hasAlcohol or random) and not onlySoda and not onlyMilk)
    add('BeveragesAlcohol','wine-package-recipe',display=='Food' and read(item,'getDoubleClickRecipe')=='OpenBoxOfWine')
    add('HouseholdCleaning','script-initial-cleaner',fluids.bleach or fluids.cleaningliquid)
    add('HouseholdCare','script-initial-cosmetic',fluids.cologne or fluids.perfume or fluids.hairdye)
    local empty=true;for _ in pairs(fluids) do empty=false;break end
    local capacity=read(component,'getCapacity')
    local emptyWater=component and empty and type(capacity)=='number' and capacity>0 and (display=='WaterContainer' or tags.waterbottle)
    add('BeveragesEmptyWater','empty-water-container-definition',emptyWater)
    add('ContainersFluid','empty-script-fluid-container',not emptyWater and component and empty and type(capacity)=='number' and capacity>0 and (display=='Material' or display=='WaterContainer'))
    add('MaterialsMetal','metal-stock-purpose',(display=='Material' or display=='Memento') and any(tags,{'ironore','ironsource'}))
    add('MaterialsAnimal','animal-tanning-input',display=='Material' and tags.braintan)
    return out
end
return H
