dofile(TEST_ROOT..'/fixtures/containers.lua')
local M=require 'B47ANCEDQuartermaster/Migration'
assert(M.envelope==nil,'legacy sorting fallback remains active')
SandboxVars={B47ANCEDSorting={ClassifyToolsByUse=false},QuartermasterSorting={ContainerRange=23}}
assert(M.option('ClassifyToolsByUse')==false and M.option('ContainerRange')==23)
SandboxVars.B47ANCEDQuartermaster={ContainerRange=10,ClassifyToolsByUse=true}
assert(M.option('ContainerRange')==10 and M.option('ClassifyToolsByUse')==true)
assert(B47ANCEDSorting==nil and QuartermasterSorting==nil and QuartermasterSimpleSorting==nil)
print('PASS OFFLINE sandbox aliases preserved independently of retired sorting-data formats')
