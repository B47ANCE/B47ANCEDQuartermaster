[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$python=Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$mod='B47ANCEDQuartermaster'
$mods=Join-Path $env:USERPROFILE 'Zomboid\mods'
$workshop=Join-Path $env:USERPROFILE 'Zomboid\Workshop'
$subscription='E:\Program Files (x86)\Steam\steamapps\workshop\content\108600\3807217050\mods'
$running=Get-CimInstance Win32_Process | Where-Object {
    $_.Name -match 'ProjectZomboid|java' -and ($_.ExecutablePath -like '*ProjectZomboid*' -or $_.CommandLine -match 'zombie\.|ProjectZomboid')
}
if($running){throw 'Close Project Zomboid before replacing discoverable mod files; cached Lua cannot prove this build.'}
& (Join-Path $PSScriptRoot 'Build-Workshop.ps1')
$stage=Join-Path $workshop $mod
& $python (Join-Path $PSScriptRoot 'scripts\check_deployment.py') --package --stage $stage
if($LASTEXITCODE -ne 0){throw 'Pre-deployment parity failed'}
$backup=Join-Path $PSScriptRoot ('dist\local-test-deployments\'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backup | Out-Null
$archived=@()
function Archive-Mod([string]$root,[string]$name,[string]$label){
    $path=Join-Path $root $name
    if(-not(Test-Path -LiteralPath $path)){return}
    $resolved=[IO.Path]::GetFullPath($path)
    if([IO.Path]::GetDirectoryName($resolved) -ne [IO.Path]::GetFullPath($root).TrimEnd('\')){throw 'Archive path escaped expected root'}
    if((Get-Item -LiteralPath $resolved).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Refusing linked mod root'}
    $destination=Join-Path $backup ($label+'-'+$name)
    Move-Item -LiteralPath $resolved -Destination $destination
    $script:archived+=@{source=$resolved;backup=$destination}
}
foreach($old in @('QuartermasterSimpleSorting','QuartermasterSorting','B47ANCEDSorting')){
    Archive-Mod $mods $old 'local'
    Archive-Mod $workshop $old 'stage'
    Archive-Mod $subscription $old 'subscription'
}
Archive-Mod $mods $mod 'local'
# A subscribed canonical copy can also shadow local testing; archive only this user's item.
Archive-Mod $subscription $mod 'subscription'
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "src\$mod") -Destination $mods -Recurse
$preset=Join-Path $mods 'default.txt'
if(Test-Path -LiteralPath $preset){
    Copy-Item -LiteralPath $preset -Destination (Join-Path $backup 'default.txt')
    $text=[IO.File]::ReadAllText($preset)
    $text=[regex]::Replace($text,'(?m)^\s*mod = (QuartermasterSimpleSorting|QuartermasterSorting|B47ANCEDSorting|B47ANCEDQuartermaster),\s*\r?\n','')
    $text=[regex]::Replace($text,'(?m)^(mods\s*\r?\n\{)',('$1'+"`r`n    mod = $mod,"))
    if($text -notmatch 'mod = B47ANCEDQuartermaster,'){throw 'Unrecognized default mod preset format'}
    # Standalone testing excludes the former dependency; its installed files are untouched.
    $text=[regex]::Replace($text,'(?m)^\s*mod = Quartermaster,\s*\r?\n','')
    [IO.File]::WriteAllText($preset,$text,[Text.UTF8Encoding]::new($false))
}
& $python (Join-Path $PSScriptRoot 'scripts\check_deployment.py') --package --stage $stage --local (Join-Path $mods $mod)
if($LASTEXITCODE -ne 0){throw 'Deployment parity failed; do not test this installation'}
@{id=$mod;version=(Get-Content (Join-Path $PSScriptRoot 'VERSION') -Raw).Trim();workshop='3807217050';archived=$archived;runtimeTested=$false} |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $backup 'deployment.json') -Encoding utf8
Write-Output "Clean test deployment verified. Backups: $backup. Native load and Save remain UNTESTED."
