$ErrorActionPreference = "Stop"
$detector = Join-Path $PSScriptRoot "..\skills\is-framework-wcf-project\scripts\is-framework-wcf-project.ps1"
$fixtures = Join-Path $PSScriptRoot "fixtures"

$expected = @{
    "framework-wcf.csproj" = @{
        result = $true
        direct = @("System.ServiceModel")
        supporting = @("System.Runtime.Serialization")
    }
    "framework-wcf-optional.csproj" = @{
        result = $true
        direct = @("System.ServiceModel.Web")
        supporting = @()
    }
    "supporting-only.csproj" = @{
        result = $false
        direct = @()
        supporting = @("System.Runtime.Serialization", "System.IdentityModel")
    }
    "modern-package.csproj" = @{
        result = $false
        direct = @()
        supporting = @()
    }
}

foreach ($name in $expected.Keys) {
    $projectPath = Join-Path $fixtures $name
    $result = & $detector -Csproj $projectPath | ConvertFrom-Json
    $expectedResult = $expected[$name]

    if ((Resolve-Path $result.csproj).Path -ne (Resolve-Path $projectPath).Path) {
        throw "Expected csproj input '$projectPath', got '$($result.csproj)'."
    }
    if ($result.isFrameworkWcfProject -ne $expectedResult.result) {
        throw "Expected $name isFrameworkWcfProject=$($expectedResult.result), got $($result.isFrameworkWcfProject)."
    }

    $direct = @($result.frameworkPackageEvidence.direct)
    $supporting = @($result.frameworkPackageEvidence.supporting)
    if (($direct -join ',') -ne ($expectedResult.direct -join ',')) {
        throw "Unexpected direct evidence for ${name}: $($direct -join ', ')."
    }
    if (($supporting -join ',') -ne ($expectedResult.supporting -join ',')) {
        throw "Unexpected supporting evidence for ${name}: $($supporting -join ', ')."
    }
}

$directoryRejected = $false
try {
    & $detector -Csproj $fixtures | Out-Null
}
catch {
    $directoryRejected = $true
}
if (-not $directoryRejected) {
    throw "Expected the detector to reject a directory input."
}

Write-Output "Detector tests passed ($($expected.Count) fixtures)."