"""Read-only native API/source evidence. Not a PZ runtime test."""
import hashlib,json,zipfile,io
from audit_consolidated_native import ClassFile
from pathlib import Path
from audit_consolidated_native import inspect_method
GAME=Path(r'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid')
paths=[
 'media/lua/client/Entity/ISUI/CraftRecipe/ISWidgetHandCraftControl.lua',
 'media/lua/client/Entity/ISUI/BuildRecipe/ISBuildRecipePanel.lua',
 'media/lua/client/Entity/ISUI/BuildRecipe/ISWidgetBuildControl.lua',
 'media/lua/client/Entity/ISUI/CraftRecipe/ISWidgetInput.lua',
 'media/lua/client/ISUI/ISInventoryPage.lua',
 'media/lua/client/ISUI/ISInventoryItem.lua',
 'media/lua/client/ISUI/AdminPanel/ISItemsListViewer.lua',
 'media/lua/client/ISUI/AdminPanel/ISItemsListTable.lua',
 'media/lua/shared/TimedActions/ISAddItemInRecipe.lua']
report={'environment':'Installed source/JAR inspection only; no native execution','jarSha256':hashlib.sha256((GAME/'projectzomboid.jar').read_bytes()).hexdigest(),
 'sources':{p:hashlib.sha256((GAME/p).read_bytes()).hexdigest() for p in paths}}
with zipfile.ZipFile(GAME/'projectzomboid.jar') as jar:
 core=ClassFile(io.BytesIO(jar.read('zombie/core/Core.class')))
 init=next(m for m in core.methods if m.name.value=='<clinit>')
 instructions=list(init.code.disassemble())
 assert instructions[2].mnemonic==instructions[3].mnemonic=='bipush'
 report['nativeCoreBaseVersion']=str(instructions[2].operands[0].value)+'.'+str(instructions[3].operands[0].value)
 report['methods']=[inspect_method(jar,p,m) for p,m in [
  ('zombie/scripting/ScriptManager.class','getCraftRecipe'),
  ('zombie/scripting/entity/components/crafting/InputScript.class','isUsesPartialItem'),
  ('zombie/entity/components/crafting/recipe/CraftRecipeManager.class','isItemValidForInputScript'),
  ('zombie/entity/components/crafting/recipe/CraftRecipeManager.class','getAllItemsFromContainers'),
  ('zombie/scripting/ScriptManager.class','getAllEvolvedRecipes'),
  ('zombie/scripting/objects/EvolvedRecipe.class','getItemsCanBeUse'),
  ('zombie/scripting/objects/EvolvedRecipe.class','checkItemCanBeUse'),
  ('zombie/scripting/objects/EvolvedRecipe.class','addItem'),
  ('zombie/scripting/objects/EvolvedRecipe.class','useSpice'),
  ('zombie/scripting/objects/EvolvedRecipe.class','getUntranslatedName'),
  ('zombie/scripting/objects/EvolvedRecipe.class','getFullResultItem'),
  ('zombie/scripting/objects/ItemRecipe.class','getUse'),
  ('zombie/inventory/types/Food.class','getHungerChange'),
  ('zombie/inventory/InventoryItem.class','getCondition'),
  ('zombie/inventory/InventoryItem.class','getConditionMax'),
  ('zombie/inventory/InventoryItem.class','getAge'),
  ('zombie/inventory/InventoryItem.class','getOffAge'),
  ('zombie/inventory/InventoryItem.class','isCooked'),
  ('zombie/inventory/types/Food.class','isRotten'),
  ('zombie/inventory/types/Food.class','isFrozen'),
  ('zombie/inventory/types/DrainableComboItem.class','getCurrentUsesFloat')]]
 item_types=ClassFile(io.BytesIO(jar.read('zombie/scripting/objects/ItemType.class')))
 assert {'WEAPON','CLOTHING','ALARM_CLOCK_CLOTHING','FOOD','DRAINABLE'}<=set(f.name.value for f in item_types.fields)
 report['shoppingPreferenceItemTypes']=['WEAPON','CLOTHING','ALARM_CLOCK_CLOTHING','FOOD','DRAINABLE']
 cook=Path(r'E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\3490188370\mods\Project_Cook')
 report['optionalCook']={'version':'1.4.8','evidence':'Source/API inspection, no reference Lua executed',
  'hashes':{p:hashlib.sha256((cook/p).read_bytes()).hexdigest() for p in [
   '42.15/mod.info','common/media/lua/client/Project_Cook/HandCraftPanel/PJCK_CraftActionPanel.lua',
   'common/media/lua/client/Project_Cook/HandCraftPanel/PJCK_HandCraftPanel.lua',
   'common/media/lua/client/Project_Cook/EvolvedRecipePanel/PJCK_EvoPanel.lua',
   'common/media/lua/client/Project_Cook/EvolvedRecipePanel/PJCK_CookingInfo.lua',
   'common/media/lua/client/Project_Cook/PJCK_Config.lua']}}
 assert 'modversion=1.4.8' in (cook/'42.15/mod.info').read_text()
 mathlib=ClassFile(io.BytesIO(jar.read('se/krka/kahlua/j2se/MathLib.class')))
 assert {'frexp','ldexp'}<=set(m.name.value for m in mathlib.methods)
 report['kahluaArithmetic']='MathLib frexp/ldexp present (source evidence, not runtime execution)'
print(json.dumps(report,indent=2))
