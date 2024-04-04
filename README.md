# Flaspbian Shell
Flaspbian brings the power of Flutter to Linux Embedded Systems, enabling the deployment of beautiful, natively-compiled applications for desktop from a single codebase.

## Getting Started
This guide will help you install Flaspbian and manage your Flaspbian applications (flapps) seamlessly.

---

## Installing Flaspbian
To install the Flaspbian engine and set up your environment for Flaspbian applications, follow these steps:

- Download the Installation Script
    Use curl to download the Flaspbian installation script:
    ```bash
    curl -sSL -o flaspbian.sh https://raw.githubusercontent.com/flaspbian/flaspbian/master/flaspbian.sh
    ```

- Make the Script Executable
    Change the script's permissions to make it executable:
    ```bash
    chmod +x flaspbian.sh
    ```

- Install Flaspbian
    Execute the script to install Flaspbian:

    ```bash
    ./flaspbian.sh install
    ```
    Follow any on-screen instructions to complete the installation.

## Managing Flaspbian Applications (Flapps)
With Flaspbian installed, you can easily install, update, and manage Flapps using the flapp.sh script.

- To Install a new flapp:

    ```bash
    sudo ./flapp.sh install "AppName" "URL_to_App_Flapp_File"
    ```
    Replace "AppName" with the name of your application and "URL_to_App_Flapp_File" with the direct URL to the .flapp file.

- Updating a Flaspbian App

    If you need to update an installed app, use the update command with the same arguments:

    ```bash
    sudo ./flapp.sh update "AppName" "https://example.com/path/to/new_version.flapp"
    ```

- Uninstalling a Flaspbian App

    To remove an installed app, use the uninstall command:

    ```bash
    sudo ./flapp.sh uninstall "AppName"
    ```

## Additional Commands

- Set WiFi Credentials: Set WiFi credentials for your device directly through the flaspbian.sh script:

    ```bash
    sudo ./flaspbian.sh set-wifi "SSID" "password"
    ```

- List Known WiFi Networks: To see a list of configured WiFi networks:

    ```bash
    sudo ./flaspbian.sh get-wifi
    ```

- For more information on commands and options, use the help command:
    ```bash
    ./flaspbian.sh help
    ```

---

## Create Flaspbian App `Development Machine` `Flutter`

To create a Flaspbian app from your Flutter source, you can utilize the flutterpi_tool, a tool designed to facilitate building and deploying Flutter applications on Flaspbian. Below are the instructions to install the flutterpi_tool, build your app, and prepare it for deployment as a Flaspbian app.

### Install `flutterpi_tool` (One-time)

- Activate flutterpi_tool:
    To install the flutterpi_tool, you need to use Flutter's pub package manager. Run the following command in your terminal:
    ```bash
    flutter pub global activate flutterpi_tool
    ```
    This command installs the flutterpi_tool globally on your system, making it accessible from any directory.

- Update your path:
    Ensure the path to Flutter's global executable scripts is included in your system's PATH. This makes the flutterpi_tool accessible from any directory.
    - Unix-like Systems (Linux/macOS):
        If it's not already included, you can add it by appending the following line to your .bashrc, .zshrc, or equivalent shell configuration file:
        ```bash
        export PATH="$HOME/.pub-cache/bin:$PATH"
        ```
        After adding the line, apply the changes by running source ~/.bashrc, source ~/.zshrc, or reopening your terminal.
    - Windows:
        For Windows users, adding to the PATH can be done through the System Properties.
        1. Right-click on 'This PC' or 'My Computer' and select 'Properties'.
        2. Click on 'Advanced system settings' on the left panel.
        3. In the System Properties window, go to the 'Advanced' tab and click on 'Environment Variables'.
        4. Under 'System Variables', find the 'Path' variable, select it, and click 'Edit'.
        5. In the 'Edit Environment Variable' window, click 'New' and add the path to the .pub-cache/bin directory, which typically is %USERPROFILE%\AppData\Roaming\Pub\Cache\bin.
        6. Click 'OK' on all windows to apply the changes.


### Build Flaspbian App
Once you have the flutterpi_tool installed, you can proceed to build your app bundle:

- Navigate to your Flutter project directory: 
    Change the directory to where your Flutter project is located.

- Build the app bundle: 
    Use the flutterpi_tool to compile your Flutter app for Flaspbian. You need to specify the architecture and CPU of your target device using the --arch and --cpu flags. For a release build, also include the --release flag:

    ```bash
    flutterpi_tool build --arch=arm64 --cpu=generic --release
    ```
    Replace `arm64` and `generic` with the appropriate architecture and CPU for your device if different.

### Archive Release Build
After building your app, you should archive the flutter_assets directory, which contains all the necessary assets and code for your app, into a .flapp file. This file can then be deployed to a Flaspbian device.

- Archive the build: 
    Use the tar command to compress the flutter_assets directory into a .flapp file. You can include versioning and architecture information in the file name for clarity:

    ```bash
    tar -czvf yourAppName-v1.0.0-arm64.flapp ./build/flutter_assets/
    ```
    Replace yourAppName-v1.0.0-arm64.flapp with a name that reflects your app's name, version, and the target architecture.

---

This README provides a comprehensive guide that incorporates the installation and management of both the Flaspbian environment and its applications, following the structure and capabilities of your updated scripts.
