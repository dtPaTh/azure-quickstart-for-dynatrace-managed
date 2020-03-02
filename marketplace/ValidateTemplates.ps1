
##Import-Module ..\..\arm-ttk\arm-ttk\arm-ttk.psd1

Remove-Item -Path ".\test-temp" -Recurse
New-Item -Name "test-temp" -ItemType "directory"
Copy-Item "createUiDefinition.json" -Destination ".\test-temp\"
Copy-Item "..\mainTemplate.json" -Destination ".\test-temp"

& "..\..\arm-ttk\arm-ttk\test-AzTemplate.cmd"
#$TestResults = Test-AzTemplate -TemplatePath ".\test-temp" 
#$TestFailures =  $TestResults | Where-Object { -not $_.Passed }
#$FailureTargetObjects = $TestFailures | Select-Object -ExpandProperty Errors |  Select-Object -ExpandProperty TargetObject

#Write-Output $FailureTargetObjects

#Remove-Item -Path ".\test-temp" -Recurse
