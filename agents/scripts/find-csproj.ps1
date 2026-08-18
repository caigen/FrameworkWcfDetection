[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ScanRoot
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$resolvedRoot = (Resolve-Path -LiteralPath $ScanRoot -ErrorAction Stop).Path
if (-not (Test-Path -LiteralPath $resolvedRoot -PathType Container)) {
    throw "Scan root is not a directory: $resolvedRoot"
}

$excludedDirectories = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
foreach ($directory in @("bin", "obj", ".git")) {
    [void]$excludedDirectories.Add($directory)
}

$projects = @(
    Get-ChildItem -LiteralPath $resolvedRoot -Filter "*.csproj" -File -Recurse |
        Where-Object {
            $relativePath = [System.IO.Path]::GetRelativePath($resolvedRoot, $_.FullName)
            $segments = $relativePath -split '[\\/]'
            -not ($segments | Where-Object { $excludedDirectories.Contains($_) })
        } |
        ForEach-Object { $_.FullName } |
        Sort-Object -Unique
)

ConvertTo-Json -InputObject $projects -Compress