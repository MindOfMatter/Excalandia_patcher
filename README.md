# Complete_Modpack

![alt](https://media.forgecdn.net/attachments/description/null/description_d95d0ee1-396e-4be8-ae78-414b7f34624e.png)

A set of scripts and resources designed to help automate and customize modpack creation for Minecraft, specifically tailored for the **[CurseForge Excalandia Modpack](https://www.curseforge.com/minecraft/modpacks/excalandia)**. These tools allow you to enhance modpacks while respecting licensing restrictions by downloading mods directly from official sources (like Modrinth) and applying local modifications.

---

## Key Features

- **Automated Mod Downloads**: Downloads mods directly from Modrinth using their project IDs, ensuring compatibility and compliance with licensing.
- **Flexible Structure**: Scripts designed to work with the CurseForge modding framework while allowing custom modifications to enhance gameplay.

---

## Included Tools

### **`complete_modpack.ps1`**
- The main script orchestrates the download processes by running the other scripts in sequence.
- Automates:
  - Mod downloads via the Python script.

### **`modrinth_downloader.py`**
- Downloads mods from Modrinth using project IDs and filenames.
- Ensures mods are saved in the correct directory (`mods`) relative to the script folder.
- Skips already downloaded mods for efficiency.

---

## Folder Structure

```plaintext
Complete_Modpack/
│
├── complete_modpack.ps1              # Main script
│
├── mods/                             # Target directory for mods
├── scripts/
│   ├── modrinth_downloader.py        # Python script for downloading mods
```
# Prerequisites

Before using the scripts, ensure the following dependencies are installed:

### **General**
- **Minecraft Modpack Manager**:
  - Use the **CurseForge App** or **ATLauncher** to manage your modpacks.

- **Python 3.10+**:
  - Add Python to your PATH.
  - Install the `requests` module:
    ```bash
    pip install requests
    ```

### **PowerShell**
- Ensure your system allows script execution:
  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# How to Use

### **1. Clone or Download the Repository**
- Clone the repository or download it as a `.zip`.

### **2. Preparation**
- Place all the repo (or zip) content into the local installed [modpack Excalandia](https://www.curseforge.com/minecraft/modpacks/excalandia)

### **3. Run the Main Script**
- Execute the main script in PowerShell:
  ```powershell
  ./complete_modpack.ps1
### **4. Review Logs**
- Monitor the output for success or error messages.
- Processed mods and audio files will be saved in their respective directories.

---

# Why This Tool Exists

CurseForge modpacks often limit sharing modified files to respect the licenses of mod creators. This tool helps you:
- **Download mods** directly from their original sources, ensuring compliance with licensing.
- **Apply your own modifications** locally without redistributing altered files.

This ensures a respectful and legal way to customize modpacks.

---

# Planned Features

- Support for additional modding platforms (e.g., direct CurseForge API integration).
- Further automation of modpack deployment.

---

# License

This repository is shared under the **MIT License**, making it free and open-source. Feel free to use, modify, and contribute!

