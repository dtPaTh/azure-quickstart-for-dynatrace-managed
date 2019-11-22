# Dyntrace Managed Cluster via ARM
- Default is to create a new VNet, optional join an existing one.
- 1x master node + [2-n] secondary nodes provisioned within a loop
- Each node with 4 data-disks (one for dynatrace, transactions, long-term and elastic)
- As we provide a public domain (<clusterid>.dynatrace-managed.com) to access the cluster after installation, all nodes provision with a public ip. 
- Setup is done via custom script extensions. Master node passes the token to install the secondary nodes to StdOut, where it is than extracted and passed as parameter to secondary nodes custom script extension.
- Uses tracking code (https://docs.microsoft.com/en-us/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers)
- Currently limited to 2TB per datadisk mount 

## How-To use
The scripts in folder /custom-scripts need to be hosted on e.g. a blob-storage. You then only need to provide the script host url in the scriptHost parameter. 

See how-to [edit and deploy the template in the Azure Portal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-quickstart-create-templates-use-the-portal#edit-and-deploy-the-template) 


## Notes

### Cluster Installation

- Node-installer requires to be run serial.

  - Restricts the use of VMSS.
  
  - Limited to deploy via Availability-Sets/-Zones, since copy-operator allows to set deployment batchSize of 1

- Installation requires public IPs for all nodes so the domain service (https://<clusterid>.dynatrace-managed.com/ ) works.


## Possible improvements

- Consider using nested template approach 

- Data-disks are currently mounted with the public script from quickstart samples (https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/prepare_vm_disks.sh). 

    - Limited to 2TB disks as the command fdisk is used. (Alternatives see here: https://www.tecmint.com/add-disk-larger-than-2tb-to-an-existing-linux/)

- Reconfigure port for Oneagent to use the public IP-Address

- Option to use either password or certificate for accessing the nodes

# Solution Template
- [How-To Test createUIDefinition](https://docs.microsoft.com/en-us/azure/managed-applications/test-createuidefinition)
- [How-To Validate SolutionTemplate](https://github.com/Azure/azure-quickstart-templates/tree/master/test/template-validation-tests)

