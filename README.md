# Framework WCF Detection Plugin

A GitHub Copilot CLI plugin that detects .NET Framework WCF assembly references in one `.csproj` file or a directory of projects.

The detector follows the inventory in `wcf-detection-data/`: `System.ServiceModel` and its optional WCF assemblies are direct evidence, while general framework assemblies such as `System.Runtime.Serialization` are supporting evidence only.

## Install From GitHub

GitHub Copilot CLI and Git are required. Replace `OWNER` with the GitHub account or organization that hosts this repository:

```powershell
copilot plugin marketplace add OWNER/FrameworkWcfDetection
copilot plugin install framework-wcf-detection@framework-wcf-plugins
copilot plugin list
```

Start a new Copilot CLI session, then ask Copilot to check a project or invoke the skill directly:

```text
/detect-framework-wcf path/to/project.csproj
```

To receive a published update, run:

```powershell
copilot plugin marketplace update framework-wcf-plugins
copilot plugin update framework-wcf-detection@framework-wcf-plugins
```

## Try Locally

From this repository's root directory, load the working copy for one session:

```powershell
copilot --plugin-dir ./
```

Or exercise the same installation flow used by the marketplace:

```powershell
copilot plugin marketplace add ./
copilot plugin install framework-wcf-detection@framework-wcf-plugins
```

The deterministic detector can also run without Copilot:

```powershell
./skills/detect-framework-wcf/scripts/detect-framework-wcf.ps1 -Path path/to/project.csproj
./skills/detect-framework-wcf/scripts/detect-framework-wcf.ps1 -Path path/to/repository -Json
```

## Test

PowerShell 6 or later is required.

```powershell
./tests/test-detector.ps1
./tests/test-plugin.ps1
```

Before publishing a release, keep the `version` values in `plugin.json`, `marketplace.json`, and the marketplace plugin entry identical. The packaging test enforces this.

## Scope

This plugin detects framework assembly `<Reference>` items in .NET Framework projects. It intentionally does not classify modern `System.ServiceModel.*` NuGet clients or CoreWCF servers.
