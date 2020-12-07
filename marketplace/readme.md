# Solution Template

## Getting Started
What are [Solution Templates](https://docs.microsoft.com/en-us/azure/marketplace/marketplace-solution-templates)

# General How-To's 
- [How-To Validate SolutionTemplate (uidefinition + arm policies)](https://github.com/Azure/arm-ttk/tree/master/arm-ttk)
- [How-To Test createUIDefinition in Portal](https://docs.microsoft.com/en-us/azure/managed-applications/test-createu

## Testing & Packaging
### ValidateTemplates.ps1
Is a helper script that utilizes arm-ttk to validate the arm template & uidefinition file. It copies both files into a temp folder and execute arm-ttk's Az-testtemplate.ps1. 

arm-ttk is assued to be checked out at the same directory as this repository. Make sure arm-ttk is updated, to rely on latest validation rules.

After scripts validate, it is recommended to test the arm template in the azure portal, as well as the createuidefinition.

### PackageArtifacts.ps1
Creates a new package to be uploaded into the marketplace. Automatically timestamp's the package & metadata.json. 
