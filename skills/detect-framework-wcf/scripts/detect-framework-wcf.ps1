[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path = ".",

    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ProjectFiles {
    param([string]$InputPath)

    $resolvedPath = Resolve-Path -LiteralPath $InputPath -ErrorAction Stop
    if (Test-Path -LiteralPath $resolvedPath -PathType Leaf) {
        if ([IO.Path]::GetExtension($resolvedPath.Path) -ine ".csproj") {
            throw "Path must be a .csproj file or a directory: $InputPath"
        }

        return @($resolvedPath.Path)
    }

    return @(Get-ChildItem -LiteralPath $resolvedPath.Path -Filter *.csproj -File -Recurse |
        Where-Object { $_.FullName -notmatch '[\\/](bin|obj)[\\/]' } |
        Select-Object -ExpandProperty FullName)
}

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

function Test-Project {
    param(
        [string]$ProjectPath,
        [pscustomobject]$Inventory
    )

    try {
        [xml]$projectXml = Get-Content -LiteralPath $ProjectPath -Raw
    }
    catch {
        return [pscustomobject]@{
            project = $ProjectPath
            detected = $false
            targetFrameworks = @()
            wcfAssemblies = @()
            supportingAssemblies = @()
            reason = "Could not parse project XML: $($_.Exception.Message)"
        }
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
    $Inventory.directEvidence | ForEach-Object { [void]$directLookup.Add($_) }
    $Inventory.supportingEvidence | ForEach-Object { [void]$supportingLookup.Add($_) }

    $wcfAssemblies = @($assemblyReferences | Where-Object { $directLookup.Contains($_) })
    $supportingAssemblies = @($assemblyReferences | Where-Object { $supportingLookup.Contains($_) })
    $detected = $frameworkTargets.Count -gt 0 -and $wcfAssemblies.Count -gt 0

    $reason = if ($detected) {
        ".NET Framework target and direct WCF framework assembly reference found."
    }
    elseif ($frameworkTargets.Count -eq 0 -and $wcfAssemblies.Count -gt 0) {
        "WCF-named assembly reference found, but no .NET Framework target was identified."
    }
    elseif ($supportingAssemblies.Count -gt 0) {
        "Only supporting assemblies were found; they are not proof of WCF."
    }
    else {
        "No direct WCF framework assembly reference was found."
    }

    return [pscustomobject]@{
        project = $ProjectPath
        detected = $detected
        targetFrameworks = @($targetFrameworks)
        wcfAssemblies = @($wcfAssemblies)
        supportingAssemblies = @($supportingAssemblies)
        reason = $reason
    }
}

$inventoryPath = Join-Path $PSScriptRoot "..\references\wcf-packages.json"
$inventory = Get-Content -LiteralPath $inventoryPath -Raw | ConvertFrom-Json
$projectFiles = @(Get-ProjectFiles -InputPath $Path)
$results = @($projectFiles | ForEach-Object { Test-Project -ProjectPath $_ -Inventory $inventory })

if ($Json) {
    $results | ConvertTo-Json -Depth 5
    exit 0
}

if ($results.Count -eq 0) {
    Write-Output "No .csproj files found under '$Path'."
    exit 0
}

foreach ($result in $results) {
    $status = if ($result.detected) { "DETECTED" } else { "NOT DETECTED" }
    Write-Output "${status}: $($result.project)"
    Write-Output "  Targets: $(if ($result.targetFrameworks.Count) { $result.targetFrameworks -join ', ' } else { '(unknown)' })"
    Write-Output "  WCF assemblies: $(if ($result.wcfAssemblies.Count) { $result.wcfAssemblies -join ', ' } else { '(none)' })"
    Write-Output "  Supporting: $(if ($result.supportingAssemblies.Count) { $result.supportingAssemblies -join ', ' } else { '(none)' })"
    Write-Output "  Reason: $($result.reason)"
}