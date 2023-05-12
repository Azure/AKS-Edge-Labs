# High Availability Weld Porosity Solution Setup Guide

## Prerequisites

1. Three edge machines, each with the required OS and AKS Edge Essentials installed. Follow the **Prerequisites**, **Download AKS Edge Essentials**, and **Install AKS Edge Essentials** sections in [this documentation](https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-edge-howto-setup-machine).
1. Build the solution [modules](./modules/): **opcua**, **pipeline**, **rtspsim** and **telegraf**.
1. If you're using your own [modules](./modules/), ensure to update the [welding-demo.yaml](./welding-demo.yaml).

## Setup

The following steps only need to be completed on one of the three edge machines. You will be using this machine to display dashboards showing the weld porosity detection and high availability.

1. [Install Grafana](https://grafana.com/grafana/download/8.3.2?edition=oss&platform=windows) on the Windows host OS.
2. Download this [GitHub repository](https://github.com/fcabrera23/AKS-EE-HMI). Navigate to the **Code** tab and click the **Download Zip** button to download the repository as a **.zip** file. Extract the GitHub **.zip** file to a working folder.
3. Run a **Command Prompt** window as an Administrator.
4. In the **Command Prompt** window, install and setup Telegraf on windows, run the `telegraf/setup_telegraf.bat` file using below commands.
   
   ```sh
   cd <path to repo>\telegraf
   .\setup_telegraf.bat
   ```
5. [Install Python 3](https://realpython.com/installing-python/).
6. [Install Pip](https://phoenixnap.com/kb/install-pip-windows#:~:text=1%20Installing%20PIP%20On%20Windows%202%20Step%201%3A,the%20location%20of%20the...%205%20Step%204%3A%20).
7. Install requests in Python by running the following command.
   
   ```sh
   pip install requests
   ```

## Deploy an AKS Edge Essentials Scalable Cluster

Find more details on deploying a scalable cluster [here](https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-edge-howto-multi-node-deployment).

### Prepare machine for deployment

1. Open **PowerShell** as an Administrator.
2. Set the execution policy.

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Unrestricted
   ```
3. Use the `Install-AksEdgeHostFeatures` command to validate teh Hyper-V, SSH, and Power settings on the machine. This might require a system reboot.

   ```powershell
   Install-AksEdgeHostFeatures
   ```

### Create a scalable deployment

1. Use the following command to generate a configuration file for a scalable cluster with a Linux node.
   
   ```powershell
   New-AksEdgeConfig -outFile <file path>\Node1Config.json -DeploymentType ScalableCluster -NodeType Linux
   ```
2. Update the newly generated `Node1Config.json` file.
   - **External switch information** A full deployment uses an external switch to enable communication across the nodes. Specify the `AdapterName` as `Ethernet` or `Wi-Fi`. View the list of available adapters with the following module.
     
     ```powershell
     Get-NetAdapter
     ```
   - **IP addresses**:  You must allocate free IP addresses from your network for the **Control Plane**, **Kubernetes services**, and **Nodes (VMs)**. Read the [AKS Edge Essentials Networking](./aks-edge-concept-networking.md) overview for more details. For example, in local networks with the 192.168.1.0/24 IP address range, 1.151 and above are outside of the DHCP scope, and therefore are guaranteed to be free. AKS Edge Essentials currently supports IPv4 addresses only. You can use the [AksEdge-ListUsedIPv4s](https://github.com/Azure/AKS-Edge/blob/main/tools/scripts/network/AksEdge-ListUsedIPv4s.ps1) script from the [GitHub repo](https://github.com/Azure/AKS-Edge) to view IPs that are currently in use, to avoid using those IP addresses in your configuration. The following parameters will need to be provided in the `Network` section of the configuration file -  `ControlPlaneEndpointIp`, `Ip4GatewayAddress`, `Ip4PrefixLength`, `ServiceIPRangeSize`, `ServiceIPRangeStart` and `DnsServers`.
   - The `Network.NetworkPlugin` by default is `flannel`. Flannel is the default CNI for a K3S cluster. In K8S cluster change the `NetworkPlugin` to `calico`.
   - In addition to the above, the following parameters can be set according to your deployment configuration as described [here](aks-edge-deployment-config-json.md)  -  `LinuxNode.CpuCount`, `LinuxNode.MemoryInMB`, `LinuxNode.DataSizeInGB`,  `LinuxNode.Ip4Address`, `WindowsNode.CpuCount`, `WindowsNode.MemoryInMB`, `WindowsNode.Ip4Address`, `Init.ServiceIPRangeSize`,  `Network.InternetDisabled`. Adjust 'AcceptEula` and `AcceptOptionalTelemetry` as needed.
4. Create your deployment.

   ```powershell
   New-AksEdgeDeployment -JsonConfigFilePath .\Node1Config.json
   ```

### Scale out deployment

Repeat each step in this section for the third node, adjusting file names accordingly.

1. While logged into the first node, create a configuration file to scale out to an additonal Linux control plane node. Provide a unique IP address corresponding to the machine that is being scaled to.
   
   ```powershell
   New-AksEdgeScaleConfig -outFile <filepath>\Node2Config.json -ScaleType AddMachine -NodeType Linux -LinuxNodeIp x.x.x.x -ControlPlane
   ```
2. Copy the newly generated configuration file into the edge machine being scaled out to.
3. Update `AdapterName` and modify  `LinuxNode.CpuCount`, `LinuxNode.MemoryInMB`, `LinuxNode.DataSizeInGB`,  `LinuxNode.Ip4Address`, `WindowsNode.CpuCount`, `WindowsNode.MemoryInMB`, `WindowsNode.Ip4Address`, `Init.ServiceIPRangeSize`,  `Network.InternetDisabled`, `AcceptEula`, and `AcceptOptionalTelemetry` as needed. 
4. In the machine being scaled out to, run the deployment command.
   ```powershell
   New-AksEdgeDeployment -JsonConfigFilePath <file path>\Node2Config.json

## Run welding porosity solution with multi-node cluster

1. After scaling out to all three nodes, using admin **PowerShell** window, navigate to the previously downloaded repo and run the Configurator script to start view the dashboards.

   ```powershell
   cd <path to repo>
   .\Configurator.ps1
   ```
