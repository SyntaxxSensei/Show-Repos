$gitDirectoryName = ".git"
$settingsFileName = "show-repos.settings.json"
$directoryLocations = @()


$settingsFile = ""
$settingsData = ""
$gitDirectories = @()
$count = 1

try
{
    $settingsFile = [Environment]::GetFolderPath("MyDocuments") + "\$settingsFileName"
    $settingsData = Get-Content $settingsFile | ConvertFrom-Json
}
catch 
{
    Write-Host "Unable to find settings file in $settingsFile"
    Add-RepoSettings
}

foreach ($directory in $settingsData.includeDirectories)
{
    $directories = Get-ChildItem -Path $directory -Recurse -ErrorAction SilentlyContinue -Force | Where-Object { $_.PSIsContainer -eq $true -and $_.Name -eq $gitDirectoryName }

    for ($i = 0; $i -lt $directories.Length; $i++)
    {
        $newObject = @{ID = $count; Directory = $directories[$i] -replace $gitDirectoryName, ""}
        $gitDirectories += $newObject
        $count++
    }
}

Write-Host "Please Choose an Option:" -ForegroundColor Red
Write-Host "------------------------"

foreach ($x in $gitDirectories)
{
    Write-Host $x.ID, ":", $x.Directory -ForegroundColor Green
}

$selectedOption = Read-Host "Option"

foreach ($item in $gitDirectories)
{
    if ($selectedOption -eq $item.ID)
    {
        Set-Location $item.Directory
    }
}
