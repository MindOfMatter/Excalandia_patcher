import os
import sys
import subprocess

# Ensure required modules are installed
REQUIRED_MODULES = ["requests"]

for module in REQUIRED_MODULES:
    try:
        __import__(module)
    except ImportError:
        print(f"Module '{module}' not found. Installing...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", module])

import requests

# Set DOWNLOAD_DIR to the parent folder of the script's directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DOWNLOAD_DIR = os.path.join(SCRIPT_DIR, "..", "mods")

# Mapping of filenames to Modrinth project IDs
mod_files = {
    "2mal3s-recipes-v1.7.1.jar": "hIlFLwrl",
    "armorstands-1.0.2-1.19.jar": "FlC9CXUY",
    "betterladdersmod-0.0.1-1.19.x-No-3D-Model.jar": "CvgtCmGj",
    "blasting-plus-1.1.jar": "bSKJNoQF",
    "campfire_xp-1.1.0.jar": "duYxsTy5",
    "crafting+-1.20.1.10.jar": "sjUk6lfU",
    "DamageVignette-2.0.1-fabric+mc1.19.x.jar": "TsEhjL6r",
    "enhanced-searchability-mc1.19-3.0.1+build.9.jar": "Scg0CNUt",
    "EnhancedBookWriting-1.1.1+mc1.19.2.jar": "6XFa5bbd",
    "experienceprogress-1.0.0+1.19.jar": "WLzTG5bH",
    "explosive-enhancement-1.2.2-1.19.2.jar": "OSQ8mw2r",
    "extended_dropper-1.0.0.jar": "ajGW8XXy",
    "flatworld-1.0.5+1.19.2.jar": "xZIo4pHq",
    "LogsBeGone-1.1.0.jar": "SpQWQ4KX",
    "log_minecraft_startup-1.0.0.jar": "604L8uva",
    "LowDurabilitySwitcher-1.0.1+1.19.2.jar": "aq4dI2bx",
    "mob-captains-v2.1.2.jar": "7tKn1fLd",
    "more-amethyst-recipes-1.0.jar": "DcLnY1WI",
    "morefuel-backport-1.19.2.jar": "lsHqikzP",
    "moremusic-0.1.3+1.19.jar": "dGBEUH8l",
    "noxesium-0.1.4.jar": "Kw7Sm3Xf",
    "ores-1.0.0.jar": "Fv4jDxvH",
    "peaceful_fixed-1.0.jar": "xlqb2iiJ",
    "recycle-leather-1.48.0.jar": "A7OneGH8",
    "saferespawn-1.0.2.jar": "izAOI0WZ",
    "shield-disruptor-1.8.1.jar": "ded5u7eL",
    "stonecobbling-1.jar": "6R6Tq5dp",
    "threatengl-fabric-1.3.3-release.1.jar": "RSFrpoou",
    "trashslot-fabric-1.19.2-12.1.0.jar": "vRYk0bv7",
    "village-hero-plus-5.1.jar": "BZnc0tTs",
    "wooden_shield-0.0.3-1.19.jar": "93Ohla4d",
    "world-day-1.0.jar": "s9XmaS3m",
    "[1.18+]-elytrabombing-1.1.1.jar": "Uo5uFsvU"
}

# Base URL for Modrinth API
BASE_URL = "https://api.modrinth.com/v2/project"

def download_mod(mod_name, project_id):
    """Downloads a mod file from Modrinth."""
    url = f"{BASE_URL}/{project_id}/version"
    file_path = os.path.join(DOWNLOAD_DIR, mod_name)

    # Check if the file already exists
    if os.path.exists(file_path):
        print(f"{mod_name} already exists. Skipping download.")
        return True

    try:
        # Get the latest version information
        response = requests.get(url)
        response.raise_for_status()
        versions = response.json()

        # Find the file corresponding to mod_name
        for version in versions:
            for file in version["files"]:
                if file["filename"] == mod_name:
                    download_url = file["url"]
                    print(f"Downloading {mod_name} from {download_url}...")
                    mod_response = requests.get(download_url)
                    mod_response.raise_for_status()

                    # Save the file
                    with open(file_path, 'wb') as f:
                        f.write(mod_response.content)
                    print(f"Downloaded {mod_name} to {file_path}.")
                    return True

        print(f"File {mod_name} not found in the latest versions of project {project_id}. Skipping...")
        return False

    except requests.RequestException as e:
        print(f"Failed to download {mod_name}: {e}")
        return False

def main():
    """Main function to download all mods."""

    # Create the directory if it doesn't exist
    os.makedirs(DOWNLOAD_DIR, exist_ok=True)

    # Download each mod
    for mod_name, project_id in mod_files.items():
        if not download_mod(mod_name, project_id):
            print(f"Failed to download {mod_name}. Please check the project ID or download manually.")

if __name__ == "__main__":
    main()
