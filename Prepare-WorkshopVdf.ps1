[CmdletBinding()]
param([Parameter(Mandatory)][string]$OutputPath,
      [string]$WorkshopRoot = (Join-Path $env:USERPROFILE 'Zomboid\Workshop'),
      [switch]$DescriptionOnly)
$ErrorActionPreference = 'Stop'
function VdfEscape([string]$text) {
    return $text.Replace('\','\\').Replace('"','\"').Replace("`r`n","`n").Replace("`r","`n")
}
$id = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'WORKSHOP_ID.txt')).Trim()
$version = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'VERSION')).Trim()
$description = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'WORKSHOP_DESCRIPTION.txt')).Trim()
$note = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'WORKSHOP_CHANGE_NOTE.txt')).Trim()
if ($id -notmatch '^\d{7,20}$') { throw 'Invalid Workshop identity' }
if ([string]::IsNullOrWhiteSpace($description)) { throw 'Workshop description is empty' }
if (-not $note.StartsWith("[b]Version $version[/b]")) { throw 'Workshop changenote version mismatch' }
# Player-facing prose need not expose a version. Bind identity to source metadata.
$info = @{}
foreach ($line in [IO.File]::ReadAllLines((Join-Path $PSScriptRoot 'src/B47ANCEDQuartermaster/42/mod.info'))) {
    if ($line -match '^([^=]+)=(.*)$') { $info[$Matches[1]] = $Matches[2].Trim() }
}
if ($id -ne '3807217050' -or $info.id -ne 'B47ANCEDQuartermaster' -or $info.modversion -ne $version) { throw 'Workshop source identity/version mismatch' }
if ($description.Contains('\n') -or $note.Contains('\n')) { throw 'Workshop prose must use real paragraph breaks' }
if ([Text.Encoding]::UTF8.GetByteCount($description) -gt 8000) { throw 'Workshop description too long' }
if (Test-Path -LiteralPath $OutputPath) { throw 'Use a new output path; preserve prior submission evidence' }
$stage = Join-Path $WorkshopRoot 'B47ANCEDQuartermaster'
$fields = [ordered]@{appid='108600';publishedfileid=$id;contentfolder=(Join-Path $stage 'Contents');
    previewfile=(Join-Path $stage 'preview.png');title="B47ANCE'd Quartermaster";
    description=$description;changenote=$note}
if ($DescriptionOnly) {
    # Omitted SteamCMD keys preserve existing content, artwork and visibility.
    $fields = [ordered]@{appid='108600';publishedfileid=$id;description=$description}
}
$lines = @('"workshopitem"','{')
foreach ($key in $fields.Keys) { $lines += '    "'+$key+'" "'+(VdfEscape $fields[$key])+'"' }
$lines += '}'
# SteamCMD on Windows needs the UTF-8 BOM to preserve non-ASCII Workshop prose.
[IO.File]::WriteAllText([IO.Path]::GetFullPath($OutputPath), ($lines -join "`n")+"`n", [Text.UTF8Encoding]::new($true))
Write-Output ([IO.Path]::GetFullPath($OutputPath))
