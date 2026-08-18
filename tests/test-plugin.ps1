$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repositoryRoot = Split-Path $PSScriptRoot -Parent
$pluginManifestPath = Join-Path $repositoryRoot "plugin.json"
$marketplaceManifestPath = Join-Path $repositoryRoot "marketplace.json"

foreach ($requiredPath in @(
    $pluginManifestPath,
    $marketplaceManifestPath,
    (Join-Path $repositoryRoot "skills\is-framework-wcf-project\SKILL.md"),
    (Join-Path $repositoryRoot "skills\is-framework-wcf-project\scripts\is-framework-wcf-project.ps1"),
    (Join-Path $repositoryRoot "skills\is-framework-wcf-project\references\wcf-packages.json")
)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Required plugin file is missing: $requiredPath"
    }
}

$plugin = Get-Content -LiteralPath $pluginManifestPath -Raw | ConvertFrom-Json
$marketplace = Get-Content -LiteralPath $marketplaceManifestPath -Raw | ConvertFrom-Json

if ($plugin.name -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
    throw "Plugin name must be kebab-case: $($plugin.name)"
}
if ($plugin.version -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$') {
    throw "Plugin version must be semantic: $($plugin.version)"
}

$skillsPath = Join-Path $repositoryRoot $plugin.skills
if (-not (Test-Path -LiteralPath $skillsPath -PathType Container)) {
    throw "Plugin skills directory does not exist: $skillsPath"
}

$marketplacePlugins = @($marketplace.plugins | Where-Object { $_.name -eq $plugin.name })
if ($marketplacePlugins.Count -ne 1) {
    throw "Marketplace must contain exactly one entry for '$($plugin.name)'."
}

$marketplacePlugin = $marketplacePlugins[0]
if ($marketplacePlugin.source -ne "./") {
    throw "Marketplace plugin source must point to the repository root."
}
if ($marketplacePlugin.version -ne $plugin.version -or $marketplace.metadata.version -ne $plugin.version) {
    throw "Plugin and marketplace versions must match."
}

Write-Output "Plugin packaging tests passed ($($plugin.name) v$($plugin.version))."