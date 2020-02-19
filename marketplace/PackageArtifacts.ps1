((Get-Content -path ".\metadata-template.json" -Raw) -replace '@@DATE@@',(get-date -Format "yyyy-MM-dd")) | Set-Content -Path ".\metadata.json"
$compress = @{
    Path= "..\mainTemplate.json", ".\createUiDefinition.json", ".\metadata.json"
    DestinationPath = "pkg" + (get-date -Format "yyyy-MM-dd_HH-mm") + ".zip"
    
}
Compress-Archive @compress
