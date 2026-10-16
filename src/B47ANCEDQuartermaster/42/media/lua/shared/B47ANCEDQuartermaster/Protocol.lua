-- Payload capabilities are independent from project SemVer and taxonomy IDs.
local P={versions={handshake=1,loadPolicy=1,ledger=1,configuration=5,presets=2,personal=1,shopping=1,dibs=1,movement=9,rooms=2}}
local commands={hello='handshake',ledgerBegin='ledger',ledgerNext='ledger',ledgerRead='ledger',ledgerBurn='ledger',ledgerConfirm='ledger',ledgerCancel='ledger',loadGet='loadPolicy',loadChange='loadPolicy',discover='configuration',load='configuration',groupChange='configuration',viewSelect='configuration',commit='configuration',close='configuration',
 presetsList='presets',presetChange='presets',personalList='personal',personalChange='personal',
 personalProject='shopping',wishToShopping='shopping',shoppingAdd='shopping',shoppingSourceRemove='shopping',
 shoppingPreference='shopping',shoppingBegin='shopping',shoppingNext='shopping',shoppingCancel='shopping',
 dibsInspect='dibs',dibsChange='dibs',tripDiscover='movement',tripBegin='movement',tripNext='movement',tripCancel='movement',
 movePlan='movement',moveTake='movement',moveCarried='movement',movePut='movement',moveDone='movement',moveRevert='movement',moveReverted='movement',moveCancel='movement',moveBatch='movement',
 roomList='rooms',roomGet='rooms',roomDiscover='rooms',areaOptions='rooms',areaDiscover='rooms'}
function P.family(command) return commands[command] end
function P.version(command) local family=P.family(command);return family and P.versions[family] end
function P.accepts(command,args)
 return type(args)=='table' and P.version(command)~=nil and args.protocol==P.version(command)
end
return P
