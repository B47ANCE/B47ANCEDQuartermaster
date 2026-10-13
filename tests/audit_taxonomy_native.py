"""Installed native contract evidence only. Does not execute PZ or third-party Lua."""
from pathlib import Path
import hashlib,io,json,sys,zipfile
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.test-deps'))
from jawa.cf import ClassFile
GAME=Path(r'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid')
methods={'getEatType':'()Ljava/lang/String;','getWeaponCategories':'()Ljava/util/Set;','getAmmoType':'()Lzombie/scripting/objects/AmmoType;',
 'getBodyLocation':'()Lzombie/scripting/objects/ItemBodyLocation;','getSwingAnim':'()Ljava/lang/String;',
 'getDoubleClickRecipe':'()Ljava/lang/String;','getDaysFresh':'()I','getDaysTotallyRotten':'()I',
 'isCanBandage':'()Z','isSpice':'()Z','isAlcoholic':'()Z','getSkillTrained':'()Ljava/lang/String;',
 'getFabricType':'()Ljava/lang/String;','getLearnedRecipes':'()Ljava/util/List;',
 'hasResearchableRecipes':'()Z','getRecordedMediaCat':'()Ljava/lang/String;',
 'isSurvivalGearLoot':'()Z','isMedicalLoot':'()Z','isMechanicsLoot':'()Z','isMementoLoot':'()Z'}
report={'evidence':'VERIFIED installed JAR API/bytecode; Kahlua/native runtime NOT TESTED',
 'jar_sha256':hashlib.sha256((GAME/'projectzomboid.jar').read_bytes()).hexdigest(),'methods':methods,'resource_types':{}}
with zipfile.ZipFile(GAME/'projectzomboid.jar') as z:
 item=ClassFile(io.BytesIO(z.read('zombie/scripting/objects/Item.class')))
 writable=next(f for f in item.fields if f.name.value=='canBeWrite')
 assert writable.descriptor.value=='Z' and writable.access_flags.acc_public
 assert not any(m.name.value in ('getCanBeWrite','isCanBeWrite') for m in item.methods)
 report['writable_script_field']='public non-static Item.canBeWrite:boolean, no Lua getter; verified Base identity families used instead of Java field/reflection access'
 components={
 'zombie/scripting/entity/GameEntityScript':{'getComponentScriptFor':'(Lzombie/entity/ComponentType;)Lzombie/scripting/entity/ComponentScript;'},
 'zombie/scripting/entity/components/fluids/FluidContainerScript':{'getInitialFluids':'()Ljava/util/ArrayList;','isInitialFluidsIsRandom':'()Z'},
 'zombie/scripting/entity/components/fluids/FluidContainerScript$FluidScript':{'getFluidType':'()Ljava/lang/String;','getPercentage':'()F'}}
 for path,contracts in components.items():
  cls=ClassFile(io.BytesIO(z.read(path+'.class')))
  for name,descriptor in contracts.items():
   assert any(m.name.value==name and m.descriptor.value==descriptor and m.access_flags.acc_public for m in cls.methods),(path,name,descriptor)
 report['script_initial_fluid_contracts']=components
 exposer=ClassFile(io.BytesIO(z.read('zombie/Lua/LuaManager$Exposer.class')))
 exposed={constant.name.value for constant in exposer.constants if constant.__class__.__name__=='ConstantClass'}
 for path in components: assert path in exposed,path
 assert 'zombie/entity/ComponentType' in exposed
 report['initial_fluid_classes_in_native_lua_exposer']=True
 for name,descriptor in methods.items():
  assert any(m.name.value==name and m.descriptor.value==descriptor for m in item.methods),(name,descriptor)
 init=next(m for m in item.methods if m.name.value=='<init>')
 ops=list(init.code.disassemble())
 for field in ('daysFresh','daysTotallyRotten'):
  assignments=[]
  for i,o in enumerate(ops):
   if o.mnemonic=='putfield' and item.constants.get(o.operands[0].value).name_and_type.name.value==field:
    previous=ops[i-1];assert previous.mnemonic=='ldc'
    assignments.append(item.constants.get(previous.operands[0].value).value)
  assert assignments==[1000000000],(field,assignments)
 report['native_no_spoilage_default']=1000000000
 for name in ('ItemBodyLocation','ItemTag','WeaponCategory','AmmoType'):
  path='zombie/scripting/objects/'+name+'.class';data=z.read(path);c=ClassFile(io.BytesIO(data))
  method=next(m for m in c.methods if m.name.value=='toString')
  calls=[c.constants.get(o.operands[0].value) for o in method.code.disassemble() if o.mnemonic=='invokevirtual']
  assert any(ref.class_.name.value=='zombie/scripting/objects/Registry' and ref.name_and_type.name.value=='getLocation' for ref in calls)
  assert any(ref.class_.name.value=='zombie/scripting/objects/ResourceLocation' and ref.name_and_type.name.value=='toString' for ref in calls)
  report['resource_types'][name]={'sha256':hashlib.sha256(data).hexdigest(),'identity':'Registry ResourceLocation; not a localized display name'}
 core=ClassFile(io.BytesIO(z.read('zombie/core/Core.class')))
 init=next(m for m in core.methods if m.name.value=='<clinit>');ops=list(init.code.disassemble())
 assert ops[2].mnemonic==ops[3].mnemonic=='bipush'
 report['native_core_version']=str(ops[2].operands[0].value)+'.'+str(ops[3].operands[0].value)
print(json.dumps(report,indent=2))
