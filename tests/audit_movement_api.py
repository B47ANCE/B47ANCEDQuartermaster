"""Read-only native movement evidence. Does not launch PZ or certify transfers.

Print API guard/authority facts to support MASTER_HANDOFF_STATUS.md. No game or
third-party implementation is copied, executed, patched, or deployed.
"""
import argparse
import hashlib
import io
from pathlib import Path
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.test-deps'))
from jawa.cf import ClassFile

parser = argparse.ArgumentParser()
parser.add_argument('--game', type=Path, default=Path(
    r'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'))
args = parser.parse_args()
jar = args.game / 'projectzomboid.jar'
print('Project Version:', (ROOT / 'VERSION').read_text().strip())
print('VERIFIED_SOURCE jar SHA256:', hashlib.sha256(jar.read_bytes()).hexdigest())


def references(cf, method):
    out = set()
    for instruction in method.code.disassemble():
        for operand in instruction.operands:
            if operand.op_type.name != 'CONSTANT_INDEX':
                continue
            value = cf.constants.get(operand.value)
            if hasattr(value, 'class_') and hasattr(value, 'name_and_type'):
                out.add(value.class_.name.value + '.' + value.name_and_type.name.value)
    return out


with zipfile.ZipFile(jar) as archive:
    def read(name):
        return ClassFile(io.BytesIO(archive.read(name + '.class')))

    def method(cf, name):
        matches = [m for m in cf.methods if m.name.value == name]
        assert len(matches) == 1, (cf.this.name.value, name, 'reinspect overloads')
        return matches[0]

    global_api = read('zombie/Lua/LuaManager$GlobalObject')
    create = method(global_api, 'createItemTransaction')
    code = list(create.code.disassemble())
    assert [i.mnemonic for i in code[:4]] == ['getstatic', 'ifne', 'iconst_0', 'ireturn'], 'Reinspect create guard'
    guard = global_api.constants.get(code[0].operands[0].value)
    assert guard.class_.name.value == 'zombie/network/GameClient' and guard.name_and_type.name.value == 'client'
    print('VERIFIED_SOURCE createItemTransaction: non-client returns 0 before creating a transaction')

    consistent = method(global_api, 'isItemTransactionConsistent')
    code = list(consistent.code.disassemble())
    assert [i.mnemonic for i in code[:2]] == ['getstatic', 'ifeq'], 'Reinspect consistency guard'
    guard = global_api.constants.get(code[0].operands[0].value)
    assert guard.class_.name.value == 'zombie/network/GameClient' and guard.name_and_type.name.value == 'client'
    branch_target = code[1].pos + code[1].operands[0].value
    by_position = {i.pos: n for n, i in enumerate(code)}
    target = by_position[branch_target]
    assert [i.mnemonic for i in code[target:target + 2]] == ['iconst_1', 'ireturn'], 'Reinspect non-client result'
    print('VERIFIED_SOURCE isItemTransactionConsistent: non-client returns true without TransactionManager validation')

    server = read('zombie/network/GameServer')
    for name in ('sendAddItemToContainer', 'sendRemoveItemFromContainer'):
        refs = references(server, method(server, name))
        assert not any(r.startswith('zombie/core/Transaction') for r in refs), 'Reinspect transaction integration'
        assert not any(r in refs for r in ('zombie/inventory/ItemContainer.AddItem', 'zombie/inventory/ItemContainer.Remove'))
        assert 'zombie/network/packets/INetworkPacket.send' in refs
        print('VERIFIED_SOURCE', name + ': packet notification, no mutation/TransactionManager reference')

    manager = read('zombie/core/TransactionManager')
    refs = references(manager, method(manager, 'isConsistent'))
    for required in ('zombie/core/TransactionManager.transactions',
                     'zombie/core/TransactionManager.chainContainsContainingItem',
                     'zombie/inventory/ItemContainer.hasRoomFor',
                     'zombie/iso/areas/SafeHouse.isSafehouseAllowLoot'):
        assert required in refs, 'Reinspect native validation: ' + required
    print('VERIFIED_SOURCE native validator considers active transactions, nested-container chains, capacity and safehouse access')

    transaction = read('zombie/core/Transaction')
    refs = references(transaction, method(transaction, 'updateItem'))
    for required in ('zombie/inventory/ItemContainer.Remove', 'zombie/inventory/ItemContainer.AddItem',
                     'zombie/network/GameServer.sendAddItemToContainer', 'zombie/network/GameServer.sendRemoveItemFromContainer'):
        assert required in refs, 'Reinspect native transfer: ' + required
    print('VERIFIED_SOURCE native Transaction.updateItem owns inventory mutation and notifications')

    exposer = read('zombie/Lua/LuaManager$Exposer')
    explicit = [c.name.value for c in exposer.constants
                if type(c).__name__ == 'ConstantClass' and c.name.value.startswith('zombie/core/Transaction')]
    print('VERIFIED_SOURCE explicit Transaction class constants in inspected Exposer:', explicit)
    print('UNKNOWN: absence of an explicit class reference alone does not prove every Lua access route unavailable')

    packet = read('zombie/network/packets/ItemTransactionPacket')
    server_refs = references(packet, method(packet, 'processServer'))
    assert 'zombie/core/TransactionManager.isConsistent' in server_refs
    assert 'zombie/core/TransactionManager.add' in server_refs
    assert 'zombie/core/Transaction$TransactionState.Accept' in server_refs
    assert 'zombie/core/Transaction$TransactionState.Reject' in server_refs
    print('VERIFIED_SOURCE ItemTransactionPacket.processServer: native validation then accepted scheduling or rejection')

    update_refs = references(manager, method(manager, 'update'))
    assert 'zombie/network/GameServer.server' in update_refs
    assert 'zombie/core/Transaction.update' in update_refs
    assert 'zombie/core/Transaction$TransactionState.Done' in update_refs
    print('VERIFIED_SOURCE TransactionManager.update: server executes accepted due transactions and acknowledges Done')

    entry = read('zombie/core/Transaction$TransactionEntry')
    assert {f.name.value for f in entry.fields} == {'itemId', 'sourceId', 'destinationId'}
    wire_refs = references(packet, method(packet, 'write'))
    assert 'zombie/core/Transaction$TransactionEntry.itemId' in wire_refs
    assert 'zombie/network/fields/ContainerID.write' in wire_refs
    print('VERIFIED_SOURCE native entry: integer item ID plus source/destination ContainerID; no owned authorization token field')

    container = read('zombie/network/fields/ContainerID')
    object_refs = references(container, method(container, 'setObject'))
    for field in ('x', 'y', 'z', 'index', 'containerIndex'):
        assert 'zombie/network/fields/ContainerID.' + field in object_refs
    resolve_refs = references(container, method(container, 'findObject'))
    assert 'zombie/util/list/PZArrayList.get' in resolve_refs
    assert 'zombie/iso/IsoObject.getContainerByIndex' in resolve_refs
    assert 'zombie/network/fields/ContainerID.findObject' in references(container, method(container, 'parse'))
    update = method(transaction, 'updateItem')
    first_calls = []
    for ins in update.code.disassemble():
        if ins.pos > 12:
            break
        if ins.mnemonic == 'invokevirtual':
            value = transaction.constants.get(ins.operands[0].value)
            first_calls.append(value.class_.name.value + '.' + value.name_and_type.name.value)
    assert first_calls == ['zombie/network/fields/ContainerID.findObject'] * 2
    print('VERIFIED_SOURCE ObjectContainer address: square + object index + section index; updateItem re-resolves both endpoints before execution')

    for class_name, mutation in (
        ('AddInventoryItemToContainerPacket', 'zombie/inventory/ItemContainer.addItem'),
        ('RemoveInventoryItemFromContainerPacket', 'zombie/inventory/ItemContainer.removeItemWithID')):
        cf = read('zombie/network/packets/' + class_name)
        assert mutation in references(cf, method(cf, 'processClient'))
    print('VERIFIED_SOURCE client replicas apply server add/remove packets by native container and item identity')

    dispatch = read('zombie/network/PacketTypes$PacketType')
    dispatch_refs = references(dispatch, method(dispatch, 'onServerPacket'))
    assert 'zombie/network/packets/INetworkPacket.processServer' in dispatch_refs
    assert not any(ref.startswith('zombie/Lua/LuaEventManager.') for ref in dispatch_refs | server_refs)
    print('VERIFIED_SOURCE inspected generic dispatch/processServer has no Lua event veto for owned movement authorization')

    # Narrow final-boundary follow-up: inspect exact overloads, not similarly
    # named helpers. These assertions are source evidence, not native tests.
    def overload(cf, name, descriptor):
        matches = [m for m in cf.methods if m.name.value == name and m.descriptor.value == descriptor]
        assert len(matches) == 1, (name, descriptor, 'reinspect overload')
        return matches[0]

    def calls(cf, meth):
        result = []
        for ins in meth.code.disassemble():
            if ins.mnemonic not in ('invokevirtual', 'invokestatic', 'invokespecial', 'invokeinterface'):
                continue
            ref = cf.constants.get(ins.operands[0].value)
            result.append((ins.pos, ref.class_.name.value + '.' + ref.name_and_type.name.value))
        return result

    items = read('zombie/inventory/ItemContainer')
    remove = overload(items, 'Remove', '(Lzombie/inventory/InventoryItem;)V')
    add = overload(items, 'AddItem', '(Lzombie/inventory/InventoryItem;)Lzombie/inventory/InventoryItem;')
    remove_calls = dict((name, pos) for pos, name in calls(items, remove))
    assert remove_calls['zombie/inventory/InventoryItem.OnBeforeRemoveFromContainer'] < remove_calls['java/util/ArrayList.remove']
    item = read('zombie/inventory/InventoryItem')
    before = overload(item, 'OnBeforeRemoveFromContainer', '(Lzombie/inventory/ItemContainer;)V')
    assert [i.mnemonic for i in before.code.disassemble()] == ['return']
    for meth in (remove, add):
        refs = references(items, meth)
        assert not any(ref.startswith(('zombie/Lua/', 'se/krka/kahlua/')) for ref in refs)
        assert 'zombie/inventory/ItemContainer.isItemAllowed' not in refs
        assert 'zombie/inventory/ItemContainer.isRemoveItemAllowed' not in refs
    admission = overload(items, 'isItemAllowed', '(Lzombie/inventory/InventoryItem;)Z')
    assert 'se/krka/kahlua/integration/LuaCaller.protectedCallBoolean' in references(items, admission)
    execution_refs = references(transaction, update)
    assert 'zombie/inventory/ItemContainer.isItemAllowed' not in execution_refs
    assert 'zombie/inventory/ItemContainer.isRemoveItemAllowed' not in execution_refs
    assert update.access_flags.acc_private, 'Reinspect transaction extension surface'
    execution_calls = calls(transaction, update)
    # Pin the inspected ordinary branch; earlier special conversion branches
    # have their own Remove calls and must not be mistaken for this path.
    assert (1272, 'zombie/inventory/ItemContainer.Remove') in execution_calls
    assert (1261, 'zombie/network/packets/INetworkPacket.sendToRelative') in execution_calls
    add_calls = dict((name, pos) for pos, name in calls(items, add))
    assert add_calls['java/util/ArrayList.add'] < add_calls['zombie/inventory/InventoryItem.OnAddedToContainer']
    print('VERIFIED_SOURCE final boundary: private updateItem; source notification precedes Remove; admission predicates not called by updateItem/Remove/AddItem')
    print('VERIFIED_SOURCE Remove calls void item/source-only OnBeforeRemoveFromContainer; base implementation empty; AddItem lifecycle callback occurs after list insertion')
    print('BLOCKED: no usable cancellable authorization hook established at this inspected boundary; lifecycle callback is not a transaction veto')

for name in ('media/lua/client/ISUI/ISInventoryPane.lua',
             'media/lua/shared/TimedActions/ISInventoryTransferUtil.lua',
             'media/lua/client/TimedActions/ISTimedActionQueue.lua',
             'media/lua/client/TimedActions/ISInventoryTransferAction.lua', 'media/lua/server/ClientCommands.lua'):
    path = args.game / name
    print('VERIFIED_SOURCE', name, 'SHA256:', hashlib.sha256(path.read_bytes()).hexdigest())
print('BLOCKED: client initiation is valid native architecture, but manifest-only authorization is not enforced by the inspected execution path')
print('DIAGNOSTIC ONLY. No PZ execution; G6/G7 remain NOT TESTED and G8 BLOCKED.')
