[CmdletBinding()]
param([string]$WorkshopRoot='C:\Users\willi\Zomboid\Workshop',
      [string]$PCFrameworkPath=(Join-Path (Split-Path $PSScriptRoot -Parent) 'B47ANCEDPCFramework'),
      [string]$RoomsPath=(Join-Path (Split-Path $PSScriptRoot -Parent) 'B47ANCEDRooms'),
      [string]$UIPath=(Join-Path (Split-Path $PSScriptRoot -Parent) 'B47ANCEDUI'))
$ErrorActionPreference='Stop'
& (Join-Path $PSScriptRoot 'Build.ps1') -PCFrameworkPath $PCFrameworkPath -RoomsPath $RoomsPath -UIPath $UIPath
$source=Join-Path $PSScriptRoot 'src\B47ANCEDQuartermaster'
$stage=Join-Path $WorkshopRoot 'B47ANCEDQuartermaster'
if(Test-Path -LiteralPath $stage){
    $resolved=[IO.Path]::GetFullPath($stage)
    if([IO.Path]::GetDirectoryName($resolved) -ne [IO.Path]::GetFullPath($WorkshopRoot).TrimEnd('\')){throw 'Invalid staging path'}
    if((Get-Item -LiteralPath $stage).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Linked staging path'}
    $backup=Join-Path $PSScriptRoot ('dist\staging-backup-'+[guid]::NewGuid().ToString('N'))
    Move-Item -LiteralPath $resolved -Destination $backup
}
$mods=Join-Path $stage 'Contents\mods'
New-Item -ItemType Directory -Path $mods -Force | Out-Null
Copy-Item -LiteralPath $source -Destination $mods -Recurse
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'preview-client.png') -Destination (Join-Path $stage 'preview.png')
$description=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'WORKSHOP_DESCRIPTION.txt')).Trim()
if([Text.Encoding]::UTF8.GetByteCount($description) -gt 8000){throw 'Workshop description too long'}
$idPath=Join-Path $PSScriptRoot 'WORKSHOP_ID.txt'
$id=if(Test-Path -LiteralPath $idPath){(Get-Content -LiteralPath $idPath -Raw).Trim()}else{''}
$lines=@('version=1','title=B47ANCE''d Quartermaster',"id=$id",'visibility=public','tags=Build 42;Interface;QoL')
$lines+=@($description -split '\r?\n' | ForEach-Object {'description='+$_})
[IO.File]::WriteAllLines((Join-Path $stage 'workshop.txt'),$lines,[Text.UTF8Encoding]::new($false))
$deployed=Join-Path $mods 'B47ANCEDQuartermaster'
$files=@(Get-ChildItem -LiteralPath $source -Recurse -File)
if(@(Get-ChildItem -LiteralPath $deployed -Recurse -File).Count -ne $files.Count){throw 'Staging count mismatch'}
foreach($file in $files){
    $relative=$file.FullName.Substring($source.Length+1)
    if((Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath (Join-Path $deployed $relative)).Hash){throw "Staging mismatch: $relative"}
}
Write-Output "Verified Workshop staging: $stage"
$python=Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $python (Join-Path $PSScriptRoot 'scripts\check_deployment.py') --package --stage $stage
if($LASTEXITCODE -ne 0){throw 'Workshop stage/package/source parity failed'}
