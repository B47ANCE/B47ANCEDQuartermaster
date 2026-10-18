"""Offline integration with installed native tables; never generates game loot."""
import argparse
from pathlib import Path
from lupa.lua51 import LuaRuntime

parser = argparse.ArgumentParser()
parser.add_argument('--game-root', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
# These helpers only supply unused junk fields in the selected items arrays.
lua.execute('ClutterTables={}; BagsAndContainers={}; Distributions={}')
for name in ('ProceduralDistributions.lua', 'Distributions.lua'):
    lua.execute((args.game_root / 'media/lua/server/Items' / name).read_text(encoding='utf-8'))
lua.execute("""
local targets={'OfficeDesk','OfficeDeskSecretary','OfficeDeskStressed','OfficeCounter','OfficeShelfSupplies','CrateOfficeSupplies','ElectronicStoreComputers','CrateComputer'}
local selected={};for _,name in ipairs(targets) do selected[name]=true end
local snapshots={}
for name,pool in pairs(ProceduralDistributions.list) do
 if type(pool.items)=='table' then
  local copy={};for n,v in ipairs(pool.items) do copy[n]=v end
  snapshots[name]=copy
 end
end
function verifyPlacement()
 local item='B47ANCEDQuartermaster.ApplicationCD'
 for name,before in pairs(snapshots) do
  local after=ProceduralDistributions.list[name].items
  assert(#after==#before+(selected[name] and 2 or 0),name)
  for n,v in ipairs(before) do assert(after[n]==v,name..' unrelated item changed') end
  if selected[name] then assert(after[#before+1]==item and after[#before+2]==1,name) end
 end
 for _,name in ipairs(targets) do assert(snapshots[name],name..' missing native pool') end
 local function mapped(room,container,pool)
  for _,entry in ipairs(SuburbsDistributions[room][container].procList) do if entry.name==pool then return end end
  error(room..'/'..container..' does not reference '..pool)
 end
 mapped('office','desk','OfficeDesk');mapped('office','desk','OfficeDeskSecretary');mapped('office','desk','OfficeDeskStressed')
 mapped('office','counter','OfficeCounter');mapped('office','metal_shelves','OfficeShelfSupplies');mapped('office','other','CrateOfficeSupplies')
 mapped('officestorage','shelves','OfficeShelfSupplies');mapped('officestorage','other','CrateOfficeSupplies')
end
package.loaded['Items/ProceduralDistributions']=true
package.loaded['B47ANCEDQuartermaster/Migration']={option=function() return 1 end}
package.loaded['B47ANCEDQuartermaster/LedgerPolicy']={enabled=function() return true end}
Events={OnPreDistributionMerge={Add=function(fn) lootCallback=fn end}}
""")
lua.execute((root / 'src/B47ANCEDQuartermaster/42/media/lua/server/B47ANCEDQuartermaster/ApplicationLoot.lua').read_text(encoding='utf-8'))
lua.execute('lootCallback();lootCallback();verifyPlacement()')
print('PASS OFFLINE installed native loot-table integration: eight pools, office mappings, repeated merge and all unrelated items preserved; no native loot generation')
