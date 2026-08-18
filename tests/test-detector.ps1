$ErrorActionPreference = "Stop"
$detector = Join-Path $PSScriptRoot "..\skills\detect-framework-wcf\scripts\detect-framework-wcf.ps1"
$fixtures = Join-Path $PSScriptRoot "fixtures"
$results = @(& $detector -Path $fixtures -Json | ConvertFrom-Json)

$expected = @{
    "framework-wcf.csproj" = $true
    "framework-wcf-optional.csproj" = $true
    "supporting-only.csproj" = $false
    "modern-package.csproj" = $false
}

foreach ($result in $results) {
    $name = Split-Path $result.project -Leaf
    if (-not $expected.ContainsKey($name)) {
        throw "Unexpected fixture result: $name"
    }
    if ($result.detected -ne $expected[$name]) {
        throw "Expected $name detected=$($expected[$name]), got $($result.detected): $($result.reason)"
    }
    $expected.Remove($name)
}

if ($expected.Count -gt 0) {
    throw "Missing fixture results: $($expected.Keys -join ', ')"
}

Write-Output "Detector tests passed ($($results.Count) fixtures)."