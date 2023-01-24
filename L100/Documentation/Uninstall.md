# AKS Edge Essentials L100
## Progress

- [x] [Introduction](../README.md)  
- [x] [Exercise 1: Set up Environment](./Documentation/SetUp_Environment.md)
- [x] [Exercise 2: Set up Machine](./Documentation/SetUp_Machine.md)
- [x] [Exercise 3: Create single machine deployment](./Documentation/SingleMachine_Deployment.md)
- [x] [Exercise 4: Deploy Application](./Documentation/Deploy_Application.md)
- [x] [Exercise 5: Connect to Arc (Optional)](./Documentation/Connect_Arc.md)
- [ ] **Exercise 6: Uninstall AKS Edge Essentials**
---


## Exercise 6: Uninstall AKS Edge Essentials

Follow the steps in this article to uninstall AKS Edge Essentials.

## Disconnect from Arc

If you used the commands from the AKSEdgeDeploy module to connect to Arc, run `Disconnect-ArcIotK8s` to disconnect your cluster from Azure Arc. For a complete clean-up, delete the service principal and resource group you created for this example.

```powershell
Disconnect-ArcIotK8s
```

If you used PowerShell 7 and the `Set-AksEdgeArcConnection` command to connect to Arc, you can test the Arc connection status using `Test-AksEdgeArcConnection` and disconnect it using:

```powershell
Set-AksEdgeArcConnection -connect $false
```

You can also manually remove the cluster from Arc using the Azure portal.

## Remove your application from cluster

Delete the applications that you deployed using the following command.

```powershell
kubectl delete -f ./path-to-your-YAML-file/app.yaml
```

For example, if you deployed the sample Linux application, you can delete it using:

```powershell
kubectl delete -f linux-sample.yaml
```

## Remove nodes on a single-machine cluster

To remove the Windows node only,

```powershell
Remove-AksEdgeNode -nodeType Windows
```

To remove your single machine cluster with a `Linux` or `LinuxandWindows` workload run:

```powershell
Remove-AksEdgeDeployment
```

You can't remove the Linux node alone, you must remove the deployment if you need to remove Linux node.

> [!NOTE]
> If your single machine cluster doesn't clean up properly, run `hnsdiag list networks`, then delete any existing AKS edge network objects using `hnsdiag delete networks <ID>`.

> [!NOTE]
> There is a known issue in which repeatedly creating a new deployment and removing the node may result in an "error during ConnectToVirtualMachine". If this occurs, reboot your system to resolve the error.

## Remove nodes on a multi-machine cluster

Before removing a node, make sure to drain the node that you'll be removing with `Set-AksEdgeNodeToDrain`. This ensures the safe de-allocation of the node's resources and that the application pods are gracefully shut down and transferred to other remaining nodes.

Be careful when removing control plane nodes and make sure you have another working control plane node before doing so.

To remove a **Windows** only node:

```powershell
Set-AksEdgeNodeToDrain -NodeType Windows
Remove-AksEdgeNode -NodeType Windows
```

To remove a **Linux** only node:

```powershell
Set-AksEdgeNodeToDrain -NodeType Linux
Remove-AksEdgeNode -NodeType Linux
```

To remove both:

```powershell
Set-AksEdgeNodeToDrain -NodeType LinuxAndWindows
Remove-AksEdgeDeployment
```

> [!NOTE]
> There is a known issue in which repeatedly creating a new deployment and removing the node can result in an error. If this occurs, reboot your system to resolve the error.

## Uninstall AKS edge

On your machine, go to **Settings > Apps > Apps & Features**. Alternatively, you can also go to **Control Panel > Uninstall a Program**. From there, look for **Azure Kubernetes Service Edge Essentials (Public Preview)**. Click **Uninstall**.

> [!NOTE]
> You may want to reboot your machine right after the uninstall so that all resources are cleaned and your machine is ready for a new installation in the future.

If you encounter any issues uninstalling AKS edge, try [downloading this troubleshooting tool](https://support.microsoft.com/topic/fix-problems-that-block-programs-from-being-installed-or-removed-cca7d1b6-65a9-3d98-426b-e9f927e1eb4d) to uninstall.




