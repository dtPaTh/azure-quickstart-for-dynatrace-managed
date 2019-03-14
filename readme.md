# Dyntrace Managed Cluster via ARM
- Default is to create a new VNet, optional join an existing one.
- 1x master node + [2-n] secondary nodes provisioned with a loop
- Each node with 2 data-disks (one for dynatrace, cassandra + elastic and one for transaction data)
- As we provide a public domain (<clusterid>.dynatrace-managed.com) to access the cluster after installation, all nodes provision with a public ip. 
- Setup is done via custom script extensions. Master node passes the token to install the secondary nodes to StdOut, where it is than extracted and passed as parameter to secondary nodes custom script extension.
- Uses tracking code (https://docs.microsoft.com/en-us/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers)
- Currently limited to 2TB per datadisk mount 

## How-To use
See how-to [edit and deploy the template in the Azure Portal](https://github.com/dtPaTh/azure-quickstart-for-dynatrace-managed/tree/develop) 

## Learnings

### Cluster Installation

- Node-installer requires to be run serial.

  - Restricts the use of VMSS.
  
  - Limited to deploy via Availability-Sets/-Zones, since copy-operator allows to set deployment batchSIze of 1

- Installation requires public IPs for all nodes so the domain service (https://<clusterid>.dynatrace-managed.com/ ) works.

### ARM 

- Configuring extensions under a VM.

  - requires type "extension" since it inherts "Microsoft.Compute/virtualMachines/" from parent

  - Serial deployment doesn't work as expected, but it works when deploying as a resource on it's own.


## Possible improvements

- Consider using nested template approach to re-use template for a single-node cluster for a multi-node cluster. 

- Data-disks are currently mounted with the external public script from quickstart samples (https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/prepare_vm_disks.sh). (maybe just re-package - it's included in the custom scripts)

    - Limited to 2TB disks as the command fdisk is used. (Alternatives see here: https://www.tecmint.com/add-disk-larger-than-2tb-to-an-existing-linux/)

- Scripts should be hosted on e.g. offical public storage, so customer can directly use the template

- Reconfigure port for Oneagent to use the public IP-Address

- Option to use either password or certificate for accessing the nodes

### Open Questions
- Best Data-disk cache settings

- Different data-disk setup for dynatrace and cassandra/elastic.

# Solution Template
- [How-To Test createUIDefinition](https://docs.microsoft.com/en-us/azure/managed-applications/test-createuidefinition)
- [How-To Validate SolutionTemplate](https://github.com/Azure/azure-quickstart-templates/tree/master/test/template-validation-tests)