# AKS Edge Essentials L100
## Progress

- [x] [Introduction](../README.md)  
- [x] [Exercise 1: Set up Environment](./Documentation/SetUp_Environment.md)
- [x] [Exercise 2: Set up Machine](./Documentation/SetUp_Machine.md)
- [ ] **Exercise 3: Create single machine deployment**
- [ ] [Exercise 4: Deploy Application](./Documentation/Deploy_Application.md)
- [ ] [Exercise 5: Connect to Arc (Optional)](./Documentation/Connect_Arc.md)
- [ ] [Exercise 6: Uninstall AKS Edge Essentials](./Documentation/Uninstall.md)
---

## Exercise 3: Create a Simple Deployment

### Single machine deployment

You can deploy AKS Edge Essentials on either a single machine or on multiple machines. In a single machine Kubernetes deployment, both the Kubernetes control node and worker node run on the same machine. This article describes how to create the Kubernetes control node on your machine on a private network.

#### Prerequisite

Set up your primary machine as described in the [setup article](aks-edge-howto-setup-machine.md).

#### Create a single machine cluster

You can run the `New-AksEdgeDeployment` cmdlet to deploy a single-machine AKS Edge cluster with a single Linux control-plane node. You can do so by providing your values in the AKSEdgeConfig JSON file. Run the `New-AksEdgeConfig` cmdlet to create a sample JSON **mydeployconfig.json** file with the default parameters and edit this file to provide your own values:

```powershell
#create a deployment configuration file with defaults
New-AksEdgeConfig -outFile .\mydeployconfig.json
```

You can edit **mydeployconfig**.json with the parameters you need and pass the JSON config file for deployment. To get a full list of the parameters and their default values, run `Get-Help New-AksEdgeDeployment -full` in your PowerShell window. You can then use this file in your deployment.

```powershell
New-AksEdgeDeployment -JsonConfigFilePath .\mydeployconfig.json
```

Alternatively, you can programmatically edit the JSON object and pass it as a string:

```powershell
$jsonString = New-AksEdgeConfig -outFile .\mydeployconfig.json
$jsonObj = $jsonString | ConvertFrom-Json 
$jsonObj.EndUser.AcceptEula = $true
$jsonObj.EndUser.AcceptOptionalTelemetry = $true
$jsonObj.LinuxVm.CpuCount = 4
$jsonObj.LinuxVm.MemoryInMB = 4096
$jsonObj.Network.ServiceIpRangeSize = 10

New-AksEdgeDeployment -JsonConfigString ($jsonObj | ConvertTo-Json)
```

Some of the common parameters and their default values are as follows:

| Attribute | Value type      |  Description |  Default value |
| :------------ |:-----------|:--------|:--------|
| `NodeType` | `Linux` or `LinuxAndWindows` | `Linux` creates the Linux control plane. You cannot specify `Windows` because the control plane node needs to be Linux. Read more about [AKS edge workload types](/docs/AKS-Edge-Concepts.md#aks-edge-workload-types) *| `Linux` |
| `NetworkPlugin` | `calico` or `flannel` | CNI plugin choice for the Kubernetes network model. | `flannel` |
| `LinuxVm.CpuCount` | number | Number of CPU cores reserved for Linux VM/VMs. | `2` |
| `LinuxVm.MemoryInMB` | number | RAM in MBs reserved for Linux VM/VMs. | `2048` |
| `LinuxVm.DataSizeInGB` | number | Size of the data partition. For large applications, we recommend  | `10` |
| `ServiceIPRangeSize` | number | Defines a service IP range for your workloads. We recommend you reserve some IP range (ServiceIPRangeSize > 0) for your Kubernetes services.| `0` |

## Example deployment options

- **Create a simple cluster without a load balancer**. You can create a very simple cluster with no service IPs(`ServiceIPRangeSize` set as 0). You cannot create a LoadBalancer service in this approach:

   ```powershell
   New-AksEdgeDeployment -JsonConfigString (New-AksEdgeConfig)
   ```

- **Allocate resources to your nodes**. To connect to Arc and deploy your apps with GitOps, allocate four CPUs or more for the `LinuxVm.CpuCount` (processing power), 4GB or more for `LinuxVm.MemoryinMB` (RAM) and to assign a number greater than 0 to the `ServiceIpRangeSize`. Here, we allocate 10 IP addresses for your Kubernetes services:

   ```json
       "DeployOptions": {
           "NetworkPlugin": "flannel",
           "SingleMachineCluster": true,
           "NodeType": "Linux"
       },
       "EndUser": {
           "AcceptEula": true,
           "AcceptOptionalTelemetry": true
       },
       "LinuxVm": {
           "CpuCount": 4,
           "MemoryInMB": 4096
       },
       "Network": {
           "ServiceIPRangeRange": 10
       }
   ```

   ```powershell
   #create a deployment configuration file with defaults
   New-AksEdgeConfig -outFile .\mydeployconfig.json
   #Edit mydeployconfig.json with the parameters you need and pass the json config for deployment
   New-AksEdgeDeployment -JsonConfigFilePath .\mydeployconfig.json
   ```

   Pass the parameters as a JSON string, as previously mentioned:

   ```powershell
   $jsonString = New-AksEdgeConfig -outFile .\mydeployconfig.json
   $jsonObj = $jsonString | ConvertFrom-Json 
   $jsonObj.EndUser.AcceptEula = $true
   $jsonObj.EndUser.AcceptOptionalTelemetry = $true
   $jsonObj.LinuxVm.CpuCount = 4
   $jsonObj.LinuxVm.MemoryInMB = 4096
   $jsonObj.Network.ServiceIpRangeSize = 10

   New-AksEdgeDeployment -JsonConfigString ($jsonObj | ConvertTo-Json)
   ```

   > [!NOTE]
   > AKS allocates IP addresses from your internal switch to run your Kubernetes services if you specified a `ServiceIPRangeSize`.

- **Create a mixed workload cluster**. You can also deploy mixed-workloads clusters. The following example shows how to bring up both Linux and Windows workloads at the same time:

   ```json
       "DeployOptions": {
           "NetworkPlugin": "flannel",
           "SingleMachineCluster": true,
           "NodeType": "LinuxAndWindows"
       },
       "EndUser": {
           "AcceptEula": true,
           "AcceptOptionalTelemetry": true
       },
       "LinuxVm": {
           "CpuCount": 4,
           "MemoryInMB": 4096
       },
       "WindowsVm": {
           "CpuCount": 2,
           "MemoryInMB": 4096
       },
       "Network": {
           "ServiceIPRangeRange": 10
       }
   ```

   ```powershell
   $jsonString = New-AksEdgeConfig .\mydeployconfig.json
   $jsonObj = $jsonString | ConvertFrom-Json 
   $jsonObj.EndUser.AcceptEula = $true
   $jsonObj.EndUser.AcceptOptionalTelemetry = $true
   $jsonObj.DeployOptions.NodeType = "LinuxAndWindows"
   $jsonObj.LinuxVm.CpuCount = 4
   $jsonObj.LinuxVm.MemoryInMB = 4096
   $jsonObj.WindowsVm.CpuCount = 2
   $jsonObj.WindowsVm.MemoryInMB = 4096
   $jsonObj.Network.ServiceIpRangeSize = 10

   New-AksEdgeDeployment -JsonConfigString ($jsonObj | ConvertTo-Json)
   ```

## Validate your cluster

Confirm that the deployment was successful by running:

```powershell
kubectl get nodes -o wide
kubectl get pods -A -o wide
```

The following screenshot shows pods on a K3S cluster:

![Screenshot showing all pods running.](images/all-pods-running.png)

## Add a Windows worker node (optional)

If you want to add Windows workloads to an existing Linux only single machine cluster, you can run:

```powershell
Add-AksEdgeNode -NodeType Windows
```

You can also specify parameters such as `CpuCount` and/or `MemoryInMB` for your Windows VM here.

Go to [Next Step](./Deploy_Application.md)
