-- App-owned installation receipts. Framework CDPrograms validates genuine media;
-- the existing challenged native ledger action owns installation timing.
local Media=require 'B47ANCEDQuartermaster/LedgerMedia'
local Policy=require 'B47ANCEDQuartermaster/LedgerPolicy'
local Options=require 'B47ANCEDQuartermaster/Migration'
local Q=B47ANCEDQuartermaster
local P={id='quartermaster.setup',version='1',disc='B47ANCEDQuartermaster.ApplicationCD'}
local function integer(v) return type(v)=='number' and v==v and v%1==0 and math.abs(v)<=10000000 end
local function position(c)
 local s=c:getSquare();return {x=s:getX(),y=s:getY(),z=s:getZ(),index=c:getObjectIndex()}
end
local function same(a,b) return a.x==b.x and a.y==b.y and a.z==b.z and a.index==b.index end
local function root()
 if isClient() then return end
 local r=ModData.getOrCreate('B47ANCEDQuartermasterPrograms')
 if r.schema==nil then local empty=true;for _ in pairs(r) do empty=false end
  if empty then r.schema=1;r.records={};r.count=0 end
 end
 if r.schema~=1 or type(r.records)~='table' or not integer(r.count) or r.count<0 or r.count>4096 then return end
 return r
end
function P.required() return Options.option('RequireComputerApplication')~=false end
function P.localInstalled(c)
 if not P.required() then return true end
 return c and c:getModData().B47QMProgramVersion==P.version or false
end
function P.has(actor,c,near,strict)
 if isClient() or not Media.computer(actor,c,near) then return false end
 if not strict and not P.required() then return true end
 local r=root();local md=c:getModData();local id=md.B47QMProgram
 local v=r and type(id)=='string' and #id<=80 and r.records[id]
 if type(v)~='table' or v.version~=P.version or type(v.position)~='table' then return false end
 for _,key in ipairs({'x','y','z','index'}) do if not integer(v.position[key]) then return false end end
 return same(v.position,position(c))
end
local driveMedia={disc=P.disc,object=Media.object,computer=Media.computer}
local D=require('B47ANCEDPCFramework/DriveService').new({
 store='B47ANCEDQuartermasterProgramDrives',computerKey='B47QMSetupDrive',storageKey='B47QMSetupStorage',
 media=driveMedia,enabled=Policy.enabled,
 valid=function(t,a) return Q.Targets.valid(t,a) end,
 can=function(a,t,action) return Q.RoomAccess.can(a,t,action) end,
 target=function(o,ci,a) return Q.Targets.make(o,ci,a) end,
 snapshot=function(item) if item:getFullType()==P.disc then return {program=P.id,programVersion=P.version} end end,
 grants=function() return Q.Ledger and Q.Ledger.grants or {} end,
 building=function() return '' end,
 commands={list='ledgerSetupList',mount='ledgerSetupMount',eject='ledgerSetupEject'},
 status={disabled='LedgerDisabled',power='LedgerPower',denied='RoomAccessDenied',changed='LedgerDriveChanged',occupied='LedgerDriveOccupied'}
})
local CD=require('B47ANCEDPCFramework/CDPrograms').new({drive=D,programs={{
 id=P.id,version=P.version,mediaTypes={P.disc},enabled=function() return Policy.enabled() end,
 accepts=function(ctx) return ctx.snapshot.program==P.id and ctx.snapshot.programVersion==P.version
  and Q.RoomAccess.can(ctx.player,{obj=ctx.computer},'configure')==true end
}}})
function P.resolve(actor,c,args) return CD.resolve(actor,c,args) end
function P.authorize(actor,c,args) return CD.authorize(actor,c,args) end
function P.occupied(c) return D.occupied(c) end
function P.drive(actor,command,args)
 local c=Media.object(args.computer)
 if command=='ledgerSetupMount' and c and require('B47ANCEDQuartermaster/LedgerDrives').occupied(c) then return {status='LedgerDriveOccupied'} end
 if command=='ledgerSetupEject' and c and D.busy(c) then return {status='busy'} end
 return D.handle(actor,command,args)
end
function P.install(actor,c,args)
 local ctx,status=CD.resolve(actor,c,args);if not ctx then return status end
 local r=root();if not r then return 'schema' end
 if P.has(actor,c,true,true) and c:getModData().B47QMProgramVersion==P.version then return 'ProgramInstalled' end
 if r.count>=4096 then return 'tooLarge' end -- internal persistent-record safety bound
 local id=getRandomUUID()
 if type(id)~='string' or #id==0 or #id>80 or r.records[id] then return 'failed' end
 r.records[id]={version=P.version,position=position(c)};r.count=r.count+1
 local md=c:getModData();md.B47QMProgram=id;md.B47QMProgramVersion=P.version;c:transmitModData()
 return 'ProgramInstalled'
end
return P
