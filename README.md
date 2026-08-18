# Is Framework WCF Project Plugin

A GitHub Copilot CLI plugin that determines whether one `.csproj` uses .NET Framework WCF assembly references.

The detector follows the inventory in `wcf-detection-data/`: `System.ServiceModel` and its optional WCF assemblies are direct evidence, while general framework assemblies such as `System.Runtime.Serialization` are supporting evidence only.

## Install From GitHub

GitHub Copilot CLI and Git are required. Run:

```powershell
copilot plugin marketplace add caigen/FrameworkWcfDetection
copilot plugin install framework-wcf-detection@framework-wcf-plugins
copilot plugin list
```

Start a new Copilot CLI session, then ask Copilot to check a project or invoke the skill directly:

```text
/is-framework-wcf-project path/to/project.csproj
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

The deterministic detector can also run without Copilot. It accepts exactly one `.csproj` and emits one JSON object; callers are responsible for enumerating multiple projects:

```powershell
./skills/is-framework-wcf-project/scripts/is-framework-wcf-project.ps1 -Csproj path/to/project.csproj
```

## Test

PowerShell 6 or later is required.

```powershell
./tests/test-detector.ps1
./tests/test-plugin.ps1
```

Before publishing a release, keep the `version` values in `plugin.json`, `marketplace.json`, and the marketplace plugin entry identical. The packaging test enforces this.

## Scope

This plugin checks one project per invocation for framework assembly `<Reference>` items. It intentionally does not classify modern `System.ServiceModel.*` NuGet clients or CoreWCF servers.
