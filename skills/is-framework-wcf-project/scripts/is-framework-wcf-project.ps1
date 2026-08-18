[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Csproj
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ElementValues {
    param(
        [xml]$Project,
        [string]$LocalName
    )

    return @($Project.SelectNodes("//*[local-name()='$LocalName']") |
        ForEach-Object { $_.InnerText.Trim() } |
        Where-Object { $_ })
}

function Test-NetFrameworkTarget {
    param([string]$TargetFramework)

    return $TargetFramework -match '^(?i:v\d+(?:\.\d+)+|net\d{2,3}(?:-[a-z0-9.-]+)?)$' -and
        $TargetFramework -notmatch '^(?i:netcoreapp|netstandard)'
}

$resolvedPath = Resolve-Path -LiteralPath $Csproj -ErrorAction Stop
if (-not (Test-Path -LiteralPath $resolvedPath.Path -PathType Leaf) -or
    [IO.Path]::GetExtension($resolvedPath.Path) -ine ".csproj") {
    throw "Csproj must be the path to one .csproj file: $Csproj"
}

$inventoryPath = Join-Path $PSScriptRoot "..\references\wcf-packages.json"
$inventory = Get-Content -LiteralPath $inventoryPath -Raw | ConvertFrom-Json

try {
    [xml]$projectXml = Get-Content -LiteralPath $resolvedPath.Path -Raw
}
catch {
    [pscustomobject]@{
        csproj = $resolvedPath.Path
        isFrameworkWcfProject = $false
        targetFrameworks = @()
        frameworkPackageEvidence = [pscustomobject]@{
            direct = @()
            supporting = @()
        }
        reason = "Could not parse project XML: $($_.Exception.Message)"
    } | ConvertTo-Json -Depth 5
    exit 0
}

$targetFrameworks = @(
    Get-ElementValues -Project $projectXml -LocalName "TargetFrameworkVersion"
    Get-ElementValues -Project $projectXml -LocalName "TargetFramework"
    Get-ElementValues -Project $projectXml -LocalName "TargetFrameworks" |
        ForEach-Object { $_ -split ';' }
) | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique

$frameworkTargets = @($targetFrameworks | Where-Object { Test-NetFrameworkTarget $_ })
$assemblyReferences = @($projectXml.SelectNodes("//*[local-name()='Reference']") |
    ForEach-Object {
        $include = $_.GetAttribute("Include")
        if ($include) { ($include -split ',', 2)[0].Trim() }
    } |
    Where-Object { $_ } |
    Select-Object -Unique)

$directLookup = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$supportingLookup = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$inventory.directEvidence | ForEach-Object { [void]$directLookup.Add($_) }
$inventory.supportingEvidence | ForEach-Object { [void]$supportingLookup.Add($_) }

$directEvidence = @($assemblyReferences | Where-Object { $directLookup.Contains($_) })
$supportingEvidence = @($assemblyReferences | Where-Object { $supportingLookup.Contains($_) })
$isFrameworkWcfProject = $frameworkTargets.Count -gt 0 -and $directEvidence.Count -gt 0

$reason = if ($isFrameworkWcfProject) {
    ".NET Framework target and direct WCF framework assembly reference found."
}
elseif ($frameworkTargets.Count -eq 0 -and $directEvidence.Count -gt 0) {
    "WCF-named assembly reference found, but no .NET Framework target was identified."
}
elseif ($supportingEvidence.Count -gt 0) {
    "Only supporting framework package evidence was found; it is not proof of WCF."
}
else {
    "No direct WCF framework package evidence was found."
}

[pscustomobject]@{
    csproj = $resolvedPath.Path
    isFrameworkWcfProject = $isFrameworkWcfProject
    targetFrameworks = @($targetFrameworks)
    frameworkPackageEvidence = [pscustomobject]@{
        direct = @($directEvidence)
        supporting = @($supportingEvidence)
    }
    reason = $reason
} | ConvertTo-Json -Depth 5