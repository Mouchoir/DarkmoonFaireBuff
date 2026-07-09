param(
    [string]$WowAddOnsPath
)

$ErrorActionPreference = 'Stop'

$addonName = 'DarkmoonFaireBuff'
$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$source = Join-Path $projectRoot "addon\$addonName"

# Personal machine paths never live in source control. Provide yours via:
#  - the -WowAddOnsPath parameter,
#  - the DFB_WOW_ADDONS_PATH environment variable, or
#  - a local scripts\dev.local.ps1 file (gitignored) that sets $WowAddOnsPath.
if (-not $WowAddOnsPath) {
    $localOverride = Join-Path $PSScriptRoot 'dev.local.ps1'
    if (Test-Path -LiteralPath $localOverride) {
        . $localOverride
    }
}

if (-not $WowAddOnsPath) {
    $WowAddOnsPath = $env:DFB_WOW_ADDONS_PATH
}

if (-not $WowAddOnsPath) {
    $candidates = @(
        "${env:ProgramFiles(x86)}\World of Warcraft\_classic_era_\Interface\AddOns",
        "$env:ProgramFiles\World of Warcraft\_classic_era_\Interface\AddOns"
    )
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            $WowAddOnsPath = $candidate
            break
        }
    }
}

if (-not $WowAddOnsPath) {
    throw "WoW AddOns folder not found. Pass -WowAddOnsPath '<drive>:\...\_classic_era_\Interface\AddOns', set DFB_WOW_ADDONS_PATH, or create scripts\dev.local.ps1 setting `$WowAddOnsPath."
}

$destination = Join-Path $WowAddOnsPath $addonName

if (-not (Test-Path -LiteralPath $source)) {
    throw "Addon source folder not found: $source"
}

if (-not (Test-Path -LiteralPath (Join-Path $source "$addonName.toc"))) {
    throw "TOC file not found in addon source: $source"
}

if (-not (Test-Path -LiteralPath $WowAddOnsPath)) {
    New-Item -ItemType Directory -Force -Path $WowAddOnsPath | Out-Null
}

$resolvedAddOns = (Resolve-Path -LiteralPath $WowAddOnsPath).Path.TrimEnd('\')
$expectedSuffix = 'World of Warcraft\_classic_era_\Interface\AddOns'
if (-not $resolvedAddOns.EndsWith($expectedSuffix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to deploy outside the Classic Era AddOns folder: $resolvedAddOns"
}

New-Item -ItemType Directory -Force -Path $destination | Out-Null

robocopy $source $destination /MIR /NFL /NDL /NJH /NJS /NP /XF *.zip | Out-Host
$code = $LASTEXITCODE
if ($code -gt 7) {
    throw "robocopy failed with exit code $code"
}

Write-Host "DEV deploy complete:"
Write-Host "  $source"
Write-Host "  -> $destination"
Write-Host "Reload WoW with /reload to test."
exit 0