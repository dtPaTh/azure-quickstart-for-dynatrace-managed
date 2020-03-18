# Deploy Dyntrace Managed Cluster via ARM Template
- Default is to create a new VNet with one subnet, optionally join an existing one.
- NSG is configured to open port 443 and 8443. [See Port requirements](https://www.dynatrace.com/support/help/setup-and-configuration/dynatrace-managed/configuration/which-network-ports-does-dynatrace-server-use/)
- 1 master node + [2-n] secondary nodes provisioned within a loop. 
  - Remote access to nodes can be choosen to either use password or certificate
  - Each node gets 4 data-disks (one for dynatrace installation, transaction storage, long-term storage and elastic storage). 
    - Each type can be seperately sized to fit sizing needs. 
    - Limited to 2TB disks as the fdisk-command is used. (Alternatives see here: https://www.tecmint.com/add-disk-larger-than-2tb-to-an-existing-linu  
      - If required - adapt/change the prepare_vm_disks.sh to your needs.
  - All nodes provision with a public ip (Making the cluster accessible via the subdomein provided from Dynatrace (<clusterid>.dynatrace-managed.com)
- Node setup/installation is done via custom script extensions.  
- Templates includes the Azure partner tracking code for Dynatrace (https://docs.microsoft.com/en-us/azure/marketplace/azure-partner-customer-usage-attribution#notify-your-customers)

## How-To use

See how-to [edit and deploy the template in the Azure Portal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-quickstart-create-templates-use-the-portal#edit-and-deploy-the-template) or see how-too [deploy templates via Azure Powershell module or Azure Cli](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/quickstart-create-templates-use-visual-studio-code?tabs=CLI#deploy-the-template)



