Connect-AzureRmAccount

Select-AzureRMSubscription -Subscription "DemoEnvironment-Dev"

.\SideLoad-CreateUIDefinition.ps1 -createUIDefFile ".\createUIDefinition.json"