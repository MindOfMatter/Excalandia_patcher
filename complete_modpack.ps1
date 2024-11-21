# Set the current directory to the location of this script
$scriptFolder = Join-Path -Path $PSScriptRoot -ChildPath "scripts"

# Define paths to the scripts you want to run
$modrinthDownloaderScript = Join-Path -Path $scriptFolder -ChildPath "modrinth_downloader.py"
$replaceAudioScript = Join-Path -Path $scriptFolder -ChildPath "replace_audio_mods.ps1"
$shrinkAudioScript = Join-Path -Path $scriptFolder -ChildPath "shrink_audio_mods.ps1"

# Function to run a script and handle errors
function Run-Script {
    param (
        [string]$scriptPath,
        [string]$scriptDescription,
        [string]$commandPrefix = ""
    )

    Write-Output "Running $scriptDescription"
    try {
        if ($commandPrefix) {
            & $commandPrefix $scriptPath
        } else {
            & $scriptPath
        }
        Write-Output "Completed $scriptDescription"
    } catch {
        Write-Error "Error running $scriptDescription : $_"
        exit 1
    }
}

# Run Python script (modrinth_downloader.py)
Run-Script -scriptPath $modrinthDownloaderScript -scriptDescription "modrinth_downloader.py" -commandPrefix "python"

# Run PowerShell script (replace_audio_mods.ps1)
Run-Script -scriptPath $replaceAudioScript -scriptDescription "replace_audio_mods.ps1"

# Run PowerShell script (shrink_audio_mods.ps1)
Run-Script -scriptPath $shrinkAudioScript -scriptDescription "shrink_audio_mods.ps1"
