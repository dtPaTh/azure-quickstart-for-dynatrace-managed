# Dyntrace Managed Cluster via ARM
- Default is to create a new VNet, optional join an existing one.
- 1x master node + [2-n] secondary nodes provisioned with a loop
- Each node with 2 data-disks (one for dynatrace, cassandra + elastic and one for transaction data)
- As we provide a public domain (<clusterid>.dynatrace-managed.com) to access the cluster after installation, all nodes provision with a public ip. 
- Setup is done via custom script extensions. Master node passes the token to install the secondary nodes to StdOut, where it is than extracted and passed as parameter to secondary nodes custom script extension.

## How-To use
See how-to [edit and deploy the template in the Azure Portal](https://github.com/dtPaTh/azure-quickstart-for-dynatrace-managed/tree/develop) 


## Things to consider

### Cluster Installation

- Node-installer requires to be run serial.

  - Restricts the use of VMSS.
  
  - Limited to deploy via Availability-Sets/-Zones, since copy-operator allows to set deployment batchSIze of 1

- Installation requires public IPs for all nodes so the domain service (https://<clusterid>.dynatrace-managed.com/ ) works.

### ARM Learnings

- Configuring extensions under a VM..

  - requires type "extension" since it inherts "Microsoft.Compute/virtualMachines/" from parent

  - Serial deployment doesn't work as expected, but it works when deploying as a resource on it's own.

## Things to improve

- Use nested template approach to re-use template for a single-node cluster for a multi-node cluster

- Consider separate data-disks for dynatrace and cassandra/elastic.

- Data-disks are currently mounted with the external public script from quickstart samples (https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/prepare_vm_disks.sh). (maybe just re-package - it's included in the custom scripts)

- Scripts should be hosted on e.g. offical dynatrace blob-storage

- Prevent download of the managed installer for every node from dynatrace (reducing download time)

- Reconfigure port for Oneagent to use the public IP-Address

- Option to use either password or certificate for accessing the nodes

## Open Questions
- Data-disk cache settings

