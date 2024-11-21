clear

# Define script and main folder paths
$scriptFolder = $PSScriptRoot                       # Current script location
$mainFolder = Split-Path -Path $scriptFolder -Parent # Parent folder of the script

# Change directory to the script folder
cd $scriptFolder

# Define paths based on the main folder and script folder
$sourceFolder = Join-Path -Path $mainFolder -ChildPath "mods"
$ffmpegPath = Join-Path -Path $scriptFolder -ChildPath "ffmpeg\ffmpeg.exe"  # Path to FFmpeg
$mp3gainPath = Join-Path -Path $scriptFolder -ChildPath "mp3gain.exe"       # Path to MP3Gain

# List of target JAR file patterns
$targetJars = @(
    "AmbientSounds_FABRIC_*.jar",
    "better-end-*.jar",
    "better-nether-*.jar",
    "paradise-lost-*.jar",
    "PresenceFootsteps-*.jar",
    "timm-*.jar",
    "xercamusic-fabric-*.jar"
)

# Step 1: Process each specified .jar in isolation
foreach ($pattern in $targetJars) {
    Get-ChildItem -Path $sourceFolder -Filter $pattern | ForEach-Object {
        $jarFile = $_.FullName
        Write-Output "Processing $jarFile"
        
        # Unique temporary paths for this jar processing
        $tempFolder = "$sourceFolder\temp_$($jarFile.GetHashCode())"
        $tempOGGFolder = "$tempFolder\OGG"
        $tempMP3Folder = "$tempFolder\MP3"
        $tempResultFolder = "$tempFolder\Result"
        $tempJarPath = "$tempFolder\temp_jar"
        
        # Ensure temporary folders exist
        New-Item -ItemType Directory -Path $tempOGGFolder, $tempMP3Folder, $tempResultFolder, $tempJarPath -Force | Out-Null
        
        $success = $true  # Track success for this .jar

        try {
            # Step 1.1: Extract contents of the .jar file to a temporary folder
            Write-Output "Extracting contents of $jarFile"
            $zipFile = "$tempFolder\$($jarFile.GetHashCode()).zip"
            Copy-Item -Path $jarFile -Destination $zipFile -Force
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $tempJarPath)
            
            # Move .ogg files from assets to temp OGG folder
            Get-ChildItem -Path "$tempJarPath\assets" -Recurse -Filter "*.ogg" | ForEach-Object {
                $relativePath = $_.FullName.Substring($tempJarPath.Length + 1)
                $destinationPath = Join-Path -Path $tempOGGFolder -ChildPath $relativePath
                New-Item -ItemType Directory -Path (Split-Path -Path $destinationPath) -Force | Out-Null
                Copy-Item -Path $_.FullName -Destination $destinationPath
            }

            # Step 2: Convert .ogg to .mp3 using FFmpeg
            Write-Output "Converting OGG files to MP3"
            Get-ChildItem -Path $tempOGGFolder -Recurse -Filter "*.ogg" | ForEach-Object {
                $sourceFile = $_.FullName
                $relativePath = $sourceFile.Substring($tempOGGFolder.Length + 1)
                $destinationFile = Join-Path -Path $tempMP3Folder -ChildPath ($relativePath -replace '\.ogg$', '.mp3')
                New-Item -ItemType Directory -Path (Split-Path -Path $destinationFile) -Force | Out-Null
                $ffmpegCommand = "& `"$ffmpegPath`" -i `"$sourceFile`" -q:a 2 -y `"$destinationFile`""
                Invoke-Expression $ffmpegCommand 2>&1 | ForEach-Object { Write-Output $_ }
            }

            # Step 3: Normalize volume with MP3Gain
            Write-Output "Normalizing MP3 files"
            Get-ChildItem -Path $tempMP3Folder -Recurse -Filter "*.mp3" | ForEach-Object {
                $filePath = $_.FullName
                if ($filePath -notmatch "(?i)(silence|wind)") {
                    Write-Output "Running MP3Gain on $filePath"
                    $mp3gainCommand = "& `"$mp3gainPath`" /r /p /d 0 /k `"$filePath`""
                    try {
                        Invoke-Expression $mp3gainCommand 2>&1 | ForEach-Object { Write-Output $_ }
                    } catch {
                        Write-Output "Error running MP3Gain on ${filePath}: $_"
                    }
                } else {
                    Write-Output "Skipping normalization for $filePath (silence or wind detected)"
                }
            }

            # Step 4: Convert MP3 back to OGG with compression (80kbit)
            Write-Output "Converting MP3 files back to OGG with compression"
            Get-ChildItem -Path $tempMP3Folder -Recurse -Filter "*.mp3" | ForEach-Object {
                $sourceFile = $_.FullName
                $relativePath = $sourceFile.Substring($tempMP3Folder.Length + 1)
                $destinationFile = Join-Path -Path $tempResultFolder -ChildPath ($relativePath -replace '\.mp3$', '.ogg')
                New-Item -ItemType Directory -Path (Split-Path -Path $destinationFile) -Force | Out-Null
                & $ffmpegPath -i $sourceFile -b:a 80k $destinationFile
            }

            # Step 5: Merge updated assets into .jar file
            Write-Output "Merging updated assets into $jarFile"
            $destinationAssetsPath = Join-Path -Path $tempJarPath -ChildPath "assets"
            $sourceAssetsPath = Join-Path -Path $tempResultFolder -ChildPath "assets"

            # Ensure destination assets folder exists
            if (-not (Test-Path -Path $destinationAssetsPath)) {
                New-Item -ItemType Directory -Path $destinationAssetsPath -Force | Out-Null
            }

            # Merge each .ogg file individually to prevent overwriting other assets
            Get-ChildItem -Path "$sourceAssetsPath\*" -Recurse | ForEach-Object {
                $relativePath = $_.FullName.Substring($sourceAssetsPath.Length + 1).TrimStart("\")
                $destinationFile = Join-Path -Path $destinationAssetsPath -ChildPath $relativePath
                Copy-Item -Path $_.FullName -Destination $destinationFile -Force
            }

            # Repack the updated .jar file
            Remove-Item -Path $zipFile -Force
            [System.IO.Compression.ZipFile]::CreateFromDirectory($tempJarPath, $zipFile)
            Move-Item -Path $zipFile -Destination $jarFile -Force

        } catch {
            Write-Error "Error processing ${jarFile}: $_"
            $success = $false  # Mark process as failed
        }

        # Step 6: Cleanup if successful
        if ($success) {
            Write-Output "Successfully updated $jarFile"
            Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            Write-Output "Processing failed for $jarFile. Temporary files are left for inspection."
        }
    }
}
