# WCF Package and Assembly Inventory

This inventory covers .NET Framework Windows Communication Foundation (WCF). The package names below are framework assembly references used to detect WCF usage in a project or repository.

## Layer Dependency

```text
Application
  |
  v
Contracts
  |
  v
Service Runtime
  |
  v
Messaging
  |
  v
Activation and hosting
```

## Packages

### System.ServiceModel

- **Communicate Side:** Server Side and Client Side
- **Architecture Layer:** Contracts; Service Runtime; Messaging; Activation and hosting
- **Component Purpose:**
  - Message Contract
  - Service Contract
  - Policy and Binding
  - Throttling Behavior
  - Error Behavior
  - Metadata Behavior
  - Instance Behavior
  - Message Inspection
  - Transaction Behavior
  - Dispatch Behavior
  - Concurrency Behavior
  - Parameter Filtering
  - WS Security Channel
  - WS Reliable Messaging Channel
  - Encoders: Binary/MTOM/Text/XML
  - HTTP Channel
  - TCP Channel
  - Transaction Flow Channel
  - NamedPipe Channel
  - MSMQ Channel
  - Windows Activation Service
  - .EXE
  - Windows Services
  - COM+

### System.Runtime.Serialization

- **Communicate Side:** Server Side and Client Side
- **Architecture Layer:** Contracts
- **Component Purpose:** Data Contract

### System.ServiceModel.Web

- **Communicate Side:** Server Side and Client Side
- **Architecture Layer:** Contracts; Service Runtime; Messaging
- **Component Purpose:** Service Contract; Policy and Binding; Error Behavior; Dispatch Behavior; Parameter Filtering; Encoders: Binary/MTOM/Text/XML; HTTP Channel

### System.ServiceModel.Discovery

- **Communicate Side:** Server Side and Client Side
- **Architecture Layer:** Contracts; Service Runtime; Messaging
- **Component Purpose:** Policy and Binding; Metadata Behavior; Dispatch Behavior

### System.ServiceModel.Activities

- **Communicate Side:** Server Side and Client Side
- **Architecture Layer:** Contracts; Service Runtime; Messaging; Activation and hosting
- **Component Purpose:** Service Contract; Error Behavior; Instance Behavior; Transaction Behavior; Dispatch Behavior; Transaction Flow Channel; .EXE; Windows Activation Service

### System.ServiceModel.Routing

- **Communicate Side:** Server Side and Client Side
- **Architecture Layer:** Service Runtime; Messaging
- **Component Purpose:** Message Inspection; Dispatch Behavior; Parameter Filtering

### System.IdentityModel

- **Communicate Side:** Server Side and Client Side
- **Architecture Layer:** Messaging
- **Component Purpose:** WS Security Channel

### System.Messaging

- **Communicate Side:** Server Side and Client Side
- **Architecture Layer:** Messaging
- **Component Purpose:** MSMQ Channel

### System.ServiceProcess

- **Communicate Side:** Server Side
- **Architecture Layer:** Activation and hosting
- **Component Purpose:** Windows Services

### System.EnterpriseServices

- **Communicate Side:** Server Side
- **Architecture Layer:** Activation and hosting
- **Component Purpose:** COM+

## Detection Notes

- `System.ServiceModel` is the primary high-confidence WCF assembly reference for both clients and services.
- `System.ServiceModel.Web`, `System.ServiceModel.Discovery`, `System.ServiceModel.Activities`, and `System.ServiceModel.Routing` are high-confidence optional WCF assembly references.
- `System.Runtime.Serialization`, `System.IdentityModel`, `System.Messaging`, `System.ServiceProcess`, and `System.EnterpriseServices` are supporting assemblies. Do not treat them as proof of WCF unless a WCF assembly, namespace, type, or `system.serviceModel` configuration section is also present.
- This documentation folder covers .NET Framework WCF assemblies. It is not an authoritative catalog of modern `System.ServiceModel` NuGet client packages or CoreWCF server packages.

## Source Data

The machine-readable version of this inventory is in [wcf-packages.json](wcf-packages.json).