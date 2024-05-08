$gitDirectoryName = ".git"
$settingsFileName = "show-repos.settings.json"
$directoryLocations = @()

function Add-RepoSettings
{
    Write-Host "This will create a file called $settingsFileName in your Documents Folder." -ForegroundColor Red
    Write-Host "------------------------"
    $moreToAdd = $true

    while ($moreToAdd)
    {
        $response = Read-Host "Do you have a repository to add? (Y)es or (N)o"

        switch ($response)
        {
            "n" { exit(0); Break }
            "y" { Get-RepoSettingsItem }
        }
    }
}

function Get-RepoSettingsItem
{
    $repoLocation = Read-Host "Please enter the location of your Git repo"

    Add-RepoSettingsItem $repoLocation
}

function Add-RepoSettingsItem
{
    param (
        $repoLocation
    )

    Write-Host "Adding $repoLocation"
    $directoryLocations += $repoLocation

    Save-RepoSettingsItem
}

function Save-RepoSettingsItem
{
    Write-Host "Saving repo settings"
    Write-Host $directoryLocations
}

function Select-Repo
{
    param (
        [Parameter(Mandatory=$false)]
        [Int16]$option = -1
    )

    $settingsFile = ""
    $settingsData = ""
    $gitDirectories = @()

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
            $newObject = @{ID = $i; Directory = $directories[$i] -replace $gitDirectoryName, ""}
            $gitDirectories += $newObject
        }
    }

    if (-not($PSBoundParameters.ContainsKey('option')) -and $option)
    {
        Write-Host "Please Choose an Option:" -ForegroundColor Red
        Write-Host "------------------------"
    
        foreach ($x in $gitDirectories)
        {
            Write-Host $x.ID, ":", $x.Directory -ForegroundColor Green
        }

        $selectedOption = Read-Host "Option"
    } 
    else 
    {
        $selectedOption = $option
    }

    foreach ($item in $gitDirectories)
    {
        if ($selectedOption -eq $item.ID)
        {
            Set-Location $item.Directory
        }
    }
}

Export-ModuleMember -Function Select-Repo
