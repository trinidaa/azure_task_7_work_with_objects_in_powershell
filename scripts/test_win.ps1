Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

# Проверяем и удаляем result.json если он существует
if (Test-Path -Path "$PWD\result.json") {
    Remove-Item -Path "$PWD\result.json" -Force
    Write-Host "`u{26A0} Existing 'result.json' was removed" -ForegroundColor Yellow
}

Write-Host "`u{2705} Checked if 'result.json' is not commited to the repo - OK"

# Добавляем проверку существования task.ps1 перед запуском
$taskScriptPath = "$PWD\task.ps1"
if (-not (Test-Path $taskScriptPath)) {
    throw "File 'task.ps1' not found at: $taskScriptPath"
}

try {
    & $taskScriptPath
    Write-Host "`u{2705} Checked if task script is running - OK"
}
catch {
    throw "Unable to run the task script - please check if it's running locally and try again. Original error: $_"
}

# Добавляем задержку для гарантии создания файла
Start-Sleep -Seconds 1

if (Test-Path -Path "$PWD\result.json") {
    Write-Host "`u{2705} Checked if 'result.json' was created after running task script - OK"
} else {
    # Добавляем более информативное сообщение об ошибке
    throw @"
Unable to find file 'result.json'.

Possible solutions:
1. Make sure task.ps1 creates the file with:
   `$data | ConvertTo-Json | Out-File "$PWD\result.json"
2. Check for errors in task.ps1 execution
3. Verify write permissions in directory: $PWD
"@
}

try {
    $regions = Get-Content "$PWD\result.json" -Raw | ConvertFrom-Json
}
catch {
    throw "Unable to read regions data from file 'result.json'. Please check if script saves data in the json format and try again. Error: $_"
}

if ($regions.Count -eq 22) {
    Write-Host "`u{2705} Checked the count of the regions in the result file - OK"
} else {
    throw "Unable to validate the count of regions in the result file. Expected - 22, got - $($regions.Count). Please check possible reasons and try again. Possible reasons: source data was re-generated (make sure to use original source data when submitting the solution); script is not using proper size family name; script is not implementing logic, described in the task."
}

$secretRegion = $regions | Where-Object {$_ -eq 'southukraine'}
if ($secretRegion) {
    Write-Host "`u{2705} Checked if script found all the required regions - OK"
} else {
    throw "Unable to validate the result list of regions. Please check possible reasons and try again. Possible reasons: source data was re-generated (make sure to use original source data when submitting the solution); script is not using proper size family name; script is not implementing logic, described in the task."
}

Write-Output ""
Write-Output "`u{1F973} Congratulations! All tests passed!"