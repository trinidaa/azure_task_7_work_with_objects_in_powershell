Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
$folderPath = "$PWD\data"
$searchValue = "Standard_B2pts_v2"
$results = @()
$jsonFiles = Get-ChildItem -Path $folderPath -Filter "*.json"

foreach ($file in $jsonFiles) {
    $jsonContent = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
    if (($jsonContent | ConvertTo-Json -Depth 10) -match $searchValue) {
        $results += $file.BaseName
    }
}

$results | ConvertTo-Json | Out-File -FilePath "$PWD\result.json" -Encoding utf8

Write-Host "Search completed. Results saved to >> result.json"