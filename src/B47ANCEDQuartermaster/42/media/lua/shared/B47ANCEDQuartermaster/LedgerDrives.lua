-- Quartermaster adapter. Legacy persistence keys deliberately remain unchanged.
local Q=B47ANCEDQuartermaster
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Scope=require 'B47ANCEDQuartermaster/LedgerScope'
local Policy=require 'B47ANCEDQuartermaster/LedgerPolicy'
local D=require('B47ANCEDPCFramework/DriveService').new({
 store='B47ANCEDQuartermasterLedgerDrives',computerKey='B47LedgerDrive',storageKey='B47LedgerDriveStorage',
 media=Media,enabled=Policy.enabled,
 valid=function(t,a) return Q.Targets.valid(t,a) end,
 can=function(a,t,action) return Q.RoomAccess.can(a,t,action) end,
 target=function(o,ci,a) return Q.Targets.make(o,ci,a) end,
 snapshot=function(i) return require('B47ANCEDQuartermaster/Ledger').snapshotFor(i) end,
 grants=function() return Q.Ledger and Q.Ledger.grants or {} end,
 building=function(c) local s=Scope.capture({getCurrentSquare=function() return c:getSquare() end},'building');return s and s.key end,
 commands={list='ledgerDriveList',mount='ledgerDriveMount',eject='ledgerDriveEject'},
 status={disabled='LedgerDisabled',power='LedgerPower',denied='RoomAccessDenied',changed='LedgerDriveChanged',occupied='LedgerDriveOccupied'}
})
Q.LedgerDrives=D
return D
