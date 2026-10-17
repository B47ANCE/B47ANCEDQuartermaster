-- Payload capabilities are independent from project SemVer and taxonomy IDs.
local P={versions={handshake=1,loadPolicy=1,ledger=3,configuration=6,presets=3,personal=2,shopping=3,dibs=1,movement=11,rooms=4,allocation=1}}
local commands={shoppingPaperRead='shopping',shoppingPaperCreate='shopping',shoppingPaperSelect='shopping',shoppingPaperRename='shopping',hello='handshake',ledgerDriveList='ledger',ledgerDriveMount='ledger',ledgerDriveEject='ledger',ledgerBegin='ledger',ledgerNext='ledger',ledgerRead='ledger',ledgerBurn='ledger',ledgerConfirm='ledger',ledgerCancel='ledger',loadGet='loadPolicy',loadChange='loadPolicy',discover='configuration',load='configuration',groupChange='configuration',viewSelect='configuration',commit='configuration',close='configuration',
 presetsList='presets',presetChange='presets',personalList='personal',personalChange='personal',
 personalProject='shopping',wishToShopping='shopping',shoppingAdd='shopping',shoppingSourceRemove='shopping',
 shoppingPreference='shopping',shoppingBegin='shopping',shoppingNext='shopping',shoppingCancel='shopping',
 dibsInspect='dibs',dibsChange='dibs',tripDiscover='movement',tripBegin='movement',tripNext='movement',tripCancel='movement',
 movePlan='movement',moveTake='movement',moveCarried='movement',movePut='movement',moveDone='movement',moveRevert='movement',moveReverted='movement',moveCancel='movement',moveBatch='movement',
 roomList='rooms',roomGet='rooms',roomDiscover='rooms',areaOptions='rooms',areaDiscover='rooms',
 allocationInfo='allocation',allocationRoomList='allocation',allocationRoomGet='allocation',allocationRoomCommit='allocation',allocationPreset='allocation',allocationPreview='allocation',allocationDiagnostics='allocation',allocationInspect='allocation'}
function P.family(command) return commands[command] end
function P.version(command) local family=P.family(command);return family and P.versions[family] end
function P.accepts(command,args)
 return type(args)=='table' and P.version(command)~=nil and args.protocol==P.version(command)
end
return P
