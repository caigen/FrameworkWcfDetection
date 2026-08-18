---
name: detect-framework-wcf
description: This skill should be used when the user asks to "detect Framework WCF", "check a csproj for WCF", "find WCF projects", or determine whether a .NET Framework C# project uses Windows Communication Foundation.
version: 1.0.0
---

# Detect .NET Framework WCF

Detect .NET Framework WCF usage in one C# project or all C# projects under a directory.

## Procedure

1. Identify the requested `.csproj` path. Use the current working directory when no path is supplied.
2. Run the bundled detector from the project working directory:

   ```powershell
   & "${COPILOT_PLUGIN_ROOT}/skills/detect-framework-wcf/scripts/detect-framework-wcf.ps1" -Path "<path>"
   ```

3. Add `-Json` when structured output is useful or when scanning multiple projects.
4. Report the detection result, target frameworks, matched WCF assemblies, and supporting assemblies. Clearly distinguish evidence from supporting signals.
5. Do not classify a project as Framework WCF from supporting assemblies alone.

## Detection Rules

- Require a .NET Framework target (`TargetFrameworkVersion` such as `v4.8`, or an SDK-style target such as `net48`).
- Treat framework `<Reference>` items for `System.ServiceModel`, `System.ServiceModel.Web`, `System.ServiceModel.Discovery`, `System.ServiceModel.Activities`, or `System.ServiceModel.Routing` as direct WCF evidence.
- Treat `System.Runtime.Serialization`, `System.IdentityModel`, `System.Messaging`, `System.ServiceProcess`, and `System.EnterpriseServices` as supporting signals only.
- Do not count `<PackageReference>` items. This inventory covers .NET Framework assembly references, not modern WCF client packages or CoreWCF.
- Match assembly names case-insensitively and ignore version/public-key details after the first comma in `Reference Include`.

The complete inventory is in `references/wcf-packages.json`.