[CmdletBinding()]
param(
    [string]$PythonPath = (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'),
    [string]$GamePath = 'E:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $PythonPath)) { throw 'Pass -PythonPath with a Python runtime containing lupa, or install lupa into .test-deps.' }
& $PythonPath (Join-Path $PSScriptRoot 'scripts\runtime_directories.py')
if ($LASTEXITCODE -ne 0) { throw 'Required runtime directory preparation failed.' }
& $PythonPath (Join-Path $PSScriptRoot 'scripts\check_versions.py') --root $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw 'Version consistency failed.' }
& $PythonPath (Join-Path $PSScriptRoot 'scripts\check_native_categories.py') --game $GamePath --output (Join-Path $env:TEMP 'B47ANCEDQuartermaster-native-categories.json')
if ($LASTEXITCODE -ne 0) { throw 'Native category metadata comparison failed.' }
& $PythonPath (Join-Path $PSScriptRoot 'tests\run_tests.py') --package
if ($LASTEXITCODE -ne 0) { throw 'Quartermaster Balanced Sorting validation/package failed.' }
& $PythonPath (Join-Path $PSScriptRoot 'scripts\check_deployment.py') --package
if ($LASTEXITCODE -ne 0) { throw 'Source/package parity failed.' }
& $PythonPath (Join-Path $PSScriptRoot 'tests\test_deployment.py')
if ($LASTEXITCODE -ne 0) { throw 'Deployment gate regression failed.' }
& $PythonPath (Join-Path $PSScriptRoot 'tests\run_auto_clean_single_player.py') --game $GamePath --rooms (Join-Path $PSScriptRoot '..\B47ANCEDRooms')
if ($LASTEXITCODE -ne 0) { throw 'Clean Building SP/MP guard regression failed.' }
& $PythonPath (Join-Path $PSScriptRoot 'scripts\check_versions.py') --root $PSScriptRoot --release
if ($LASTEXITCODE -ne 0) { throw 'Artifact version consistency failed.' }
