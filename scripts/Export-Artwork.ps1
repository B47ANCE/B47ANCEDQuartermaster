[CmdletBinding()]
param()

# Host-only size/format exports of the approved originals. No artwork is redrawn.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repoRoot = Split-Path -Parent $PSScriptRoot
$artRoot = Join-Path $repoRoot 'assets/branding'
$thumbnail = Join-Path $artRoot 'quartermaster-thumbnail-master.png'
$icon = Join-Path $artRoot 'quartermaster-icon-master.png'

function Export-Image([string]$Source, [string]$Destination, [int]$Size, [bool]$Alpha) {
    $inputImage = [Drawing.Image]::FromFile($Source)
    $outputImage = $null
    $graphics = $null
    try {
        $format = if ($Alpha) { [Drawing.Imaging.PixelFormat]::Format32bppArgb } else { [Drawing.Imaging.PixelFormat]::Format24bppRgb }
        $outputImage = [Drawing.Bitmap]::new($Size, $Size, $format)
        $graphics = [Drawing.Graphics]::FromImage($outputImage)
        $graphics.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
        $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::None
        $graphics.DrawImage($inputImage, [Drawing.Rectangle]::new(0, 0, $Size, $Size), 0, 0, $inputImage.Width, $inputImage.Height, [Drawing.GraphicsUnit]::Pixel)
        $outputImage.Save($Destination, [Drawing.Imaging.ImageFormat]::Png)
    } finally {
        if ($graphics) { $graphics.Dispose() }
        if ($outputImage) { $outputImage.Dispose() }
        $inputImage.Dispose()
    }
}

foreach ($source in @($thumbnail, $icon)) {
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing approved original: $source" }
}

# Full-resolution preview and native poster retain the exact approved bytes.
Copy-Item -LiteralPath $thumbnail -Destination (Join-Path $repoRoot 'preview.png') -Force
Copy-Item -LiteralPath $thumbnail -Destination (Join-Path $repoRoot 'src/B47ANCEDQuartermaster/42/poster.png') -Force
Export-Image $thumbnail (Join-Path $repoRoot 'preview-client.png') 512 $false
Export-Image $icon (Join-Path $repoRoot 'src/B47ANCEDQuartermaster/42/icon.png') 256 $true

# Keep the established JPEG preview mirror in sync, without changing its dimensions.
$inputImage = [Drawing.Image]::FromFile($thumbnail)
$parameters = [Drawing.Imaging.EncoderParameters]::new(1)
try {
    $codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
    $parameters.Param[0] = [Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality, [long]95)
    $inputImage.Save((Join-Path $repoRoot 'preview.jpg'), $codec, $parameters)
} finally {
    $parameters.Dispose()
    $inputImage.Dispose()
}

Write-Output 'Exported approved Quartermaster thumbnail, poster and transparent icon. No package, deployment or upload.'
