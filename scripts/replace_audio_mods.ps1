clear

# Define script and main folder paths
$scriptFolder = $PSScriptRoot                       # Current script location
$mainFolder = Split-Path -Path $scriptFolder -Parent # Parent folder of the script

# Change directory to the script folder
cd $scriptFolder

# Define paths
$sourceFolder = Join-Path -Path $mainFolder -ChildPath "mods"
$customAssetsFolder = Join-Path -Path $mainFolder -ChildPath "resourcepacks\MyCustomDiscs\assets"
$targetPattern = "morediscs-*-fabric.jar"

# Step 1: Locate the target .jar file
$jarFile = Get-ChildItem -Path $sourceFolder -Filter $targetPattern | Select-Object -First 1

if ($null -eq $jarFile) {
    Write-Output "No file matching '$targetPattern' was found in $sourceFolder."
    exit
}

Write-Output "Processing $($jarFile.FullName)"

# Unique temporary paths for this jar processing
$tempFolder = Join-Path -Path $sourceFolder -ChildPath "temp_$($jarFile.GetHashCode())"
$tempJarPath = Join-Path -Path $tempFolder -ChildPath "temp_jar"

# Ensure temporary folders exist
New-Item -ItemType Directory -Path $tempJarPath -Force | Out-Null

$success = $true  # Track success for this .jar

try {
    # Step 1.1: Extract contents of the .jar file to a temporary folder
    Write-Output "Extracting contents of $($jarFile.FullName)"
    $zipFile = Join-Path -Path $tempFolder -ChildPath "$($jarFile.GetHashCode()).zip"
    Copy-Item -Path $jarFile.FullName -Destination $zipFile -Force
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $tempJarPath)

    # Step 2: Merge assets folder contents
    Write-Output "Merging custom assets into $($jarFile.FullName)"
    $destinationAssetsPath = Join-Path -Path $tempJarPath -ChildPath "assets"

    # Ensure the destination assets folder exists
    if (-not (Test-Path -Path $destinationAssetsPath)) {
        New-Item -ItemType Directory -Path $destinationAssetsPath -Force | Out-Null
    }

    # Copy individual files from custom assets to the extracted assets folder, preserving existing content
    Get-ChildItem -Path "$customAssetsFolder\*" -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring($customAssetsFolder.Length + 1).TrimStart("\")
        $destinationFile = Join-Path -Path $destinationAssetsPath -ChildPath $relativePath
        New-Item -ItemType Directory -Path (Split-Path -Path $destinationFile) -Force | Out-Null
        Copy-Item -Path $_.FullName -Destination $destinationFile -Force
    }

    # Step 3: Repack the updated folder as a .jar
    Write-Output "Updating $($jarFile.FullName) with merged assets"
    Remove-Item -Path $zipFile -Force
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempJarPath, $zipFile)
    Move-Item -Path $zipFile -Destination $jarFile.FullName -Force

} catch {
    Write-Error "Error processing $($jarFile.FullName): $_"
    $success = $false  # Mark process as failed
}

# Step 4: Cleanup if successful
if ($success) {
    Write-Output "Successfully updated assets in $($jarFile.FullName)"
    # Cleanup temporary folders
    Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Output "Processing failed for $($jarFile.FullName). Temporary files are left for inspection."
}
