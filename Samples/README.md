# AKS Edge Essentials Samples

This repo contains samples to help customers get started with AKS Edge Essentials. Many of these samples demonstrate end-to-end scenarios. 

## Interop Samples

_:warning: **WARNING**: Enabling a communication channel between the Windows host and the AKS edge VM may increase security risks._

| Name           | Description      |
|----------------|------------------|
| [Interop-Textmsg-Consoleapp](./Interop-textmsg-consoleapp) | Basic interop sample demonstrating text messaging between a Windows console app and an workload running inside the AKS edge cluster. | 

The interop samples demonstrate usage patterns for interoperatibility between Microsoft's Windows host OS and workloads running on the AKS Edge cluster.  These code samples were created with templates available in Visual Studio and are designed, but not limited to, run on devices using AKS edge. For more information, review [AKS edge docs](/docs/AKS-Lite-Concepts.md).

> **Note:** If you are unfamiliar with Git and GitHub, you can download the entire collection as a 
> [ZIP file](https://github.com/Microsoft/Windows-universal-samples/archive/master.zip), but be 
> sure to unzip everything to access shared dependencies. For more info on working with the ZIP file, 
> the samples collection, and GitHub, see [Get the UWP samples from GitHub](https://aka.ms/ovu2uq). 
> For more samples, see the [Samples portal](https://aka.ms/winsamples) on the Windows Dev Center. 

## Edge AI Samples

| Name           | Description      |
|----------------|------------------|
| [Welding-Demo](./Welding-Demo/) | Edge AI & Industrial IoT sample demonstrating computer vision, AI weld porosity inferencing and OPC UA messaging using a 3-node cluster with AKS EE (highly available), and a Grafana dashboard. | 


### Using the samples

The easiest way to use these samples without using Git is to download the zip file containing the current version (using the following link or by clicking the "Download ZIP" button on the repo page). You can then unzip the entire archive and use the samples in Visual Studio.

   **Notes:**

   * Before you unzip the archive, right-click it, select **Properties**, and then select **Unblock**.
   * Be sure to unzip the entire archive, and not just individual samples. The samples all depend on the SharedContent folder in the archive.   
   * In Visual Studio, the platform target defaults to ARM, so be sure to change that to x64 or x86 if you want to test on a non-ARM device. 

The samples use Linked files in Visual Studio to reduce duplication of common files, including sample template files and image assets. These common files are stored in the SharedContent folder at the root of the repository and are referred to in the project files using links.

**Reminder:** If you unzip individual samples, they will not build due to references to other portions of the ZIP file that were not unzipped. You must unzip the entire archive if you intend to build the samples.

For more info about the programming models, platforms, languages, and APIs demonstrated in these samples, please refer to the guidance, tutorials, and reference topics provided in the Windows 10 documentation available in the [Windows Developer Center](http://go.microsoft.com/fwlink/p/?LinkID=532421). These samples are provided as-is in order to indicate or demonstrate the functionality of the programming models and feature APIs for Windows and AKS edge.

## Contributing

This project welcomes contributions and suggestions. For more information, visit [Contributing](/CONTRIBUTING.md).
