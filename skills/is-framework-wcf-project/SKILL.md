---
name: is-framework-wcf-project
description: Use when the user asks whether one .csproj is a .NET Framework WCF project or requests Framework WCF package evidence for one C# project.
version: 1.1.0
---

# Is .NET Framework WCF Project

Determine whether one C# project is a .NET Framework WCF project.

## Procedure

1. Require the path to one `.csproj` file. If the caller needs to inspect multiple projects, the caller must enumerate them and invoke this skill once per project.
2. Run the bundled detector from the project working directory:

   ```powershell
   & "${COPILOT_PLUGIN_ROOT}/skills/is-framework-wcf-project/scripts/is-framework-wcf-project.ps1" -Csproj "<path-to-csproj>"
   ```

3. Consume the JSON result. Report `isFrameworkWcfProject`, `targetFrameworks`, and `frameworkPackageEvidence`.
4. Do not classify a project as Framework WCF from supporting evidence alone.

## Result

The script always emits one JSON object:

```json
{
  "csproj": "C:\\src\\Example.csproj",
  "isFrameworkWcfProject": true,
  "targetFrameworks": ["v4.8"],
  "frameworkPackageEvidence": {
    "direct": ["System.ServiceModel"],
    "supporting": ["System.Runtime.Serialization"]
  },
  "reason": ".NET Framework target and direct WCF framework assembly reference found."
}
```

## Detection Rules

- Require a .NET Framework target (`TargetFrameworkVersion` such as `v4.8`, or an SDK-style target such as `net48`).
- Treat framework `<Reference>` items for `System.ServiceModel`, `System.ServiceModel.Web`, `System.ServiceModel.Discovery`, `System.ServiceModel.Activities`, or `System.ServiceModel.Routing` as direct WCF evidence.
- Treat `System.Runtime.Serialization`, `System.IdentityModel`, `System.Messaging`, `System.ServiceProcess`, and `System.EnterpriseServices` as supporting evidence only.
- Do not count `<PackageReference>` items. This inventory covers .NET Framework assembly references, not modern WCF client packages or CoreWCF.
- Match assembly names case-insensitively and ignore version/public-key details after the first comma in `Reference Include`.

The complete inventory is in `references/wcf-packages.json`.