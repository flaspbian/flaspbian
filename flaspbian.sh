#!/bin/bash

set -eo pipefail  # Exit on error and fail if a pipe fails

flutter_pi_dir="/home/endurance/flutter-pi" # Set the Flaspbian directory
flapps_dir="/home/endurance/.flapps" # Set the Flaspbian directory

#OK
# Display System Information
display_system_info() {
  echo "------------------------"
  echo "Flaspbian - by Devstroop"
  echo "------------------------"
  echo "System Information"
  echo "------------------------"
  echo "OS: $(lsb_release -d | cut -f2)"
  echo "Kernel: $(uname -r)"
  echo "Architecture: $(uname -m)"
  echo "------------------------"
}

### System Functions ###

# OK
# Function to check and update .bashrc without duplicating entries
# update_bashrc() {
#   local entry="$1"
#   if ! grep -qF -- "$entry" ~/.bashrc; then
#     echo "$entry" >> ~/.bashrc
#     echo "Added $entry to ~/.bashrc. Please source ~/.bashrc to update your session."
#   fi
#   source ~/.bashrc
# }

# OK
# System Update and Installation of Dependencies
update_and_install_dependencies() {
  echo "Updating the system and installing dependencies..."
  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt-get install -y git
  sudo apt install -y cmake libgl1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdrm-dev libgbm-dev ttf-mscorefonts-installer fontconfig libsystemd-dev libinput-dev libudev-dev  libxkbcommon-dev
  sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-alsa
  sudo fc-cache
}

### Flaspbian Engine Customization Functions ###


# Enabling 3D Acceleration
enable_3d_acceleration() {
  echo "Enabling 3D acceleration..."
  sudo usermod -a -G render $(whoami)
}

# Disable 3D Acceleration
disable_3d_acceleration() {
  echo "Disabling 3D acceleration..."
  sudo usermod -G render $(whoami)
}

# Set Boot Options
set_boot_options() {
  echo "Setting boot options..."
  sudo raspi-config nonint do_boot_behaviour B2
  sudo raspi-config nonint do_boot_splash 1
}

# Reset Boot Options
reset_boot_options() {
  echo "Resetting boot options to default..."
  sudo raspi-config nonint do_boot_behaviour B1
  sudo raspi-config nonint do_boot_splash 0
}

### Flaspbian Engine Functions ###
# Function to manage the Flaspbian engine
engine() {
  case "$1" in
    install)
      install_engine
      ;;
    update)
      update_engine
      ;;
    uninstall)
      uninstall_engine
      ;;
    *)
      echo "Error: Invalid command '$1'"
      show_engine_usage
      ;;
  esac
}

# Function to show engine usage information
show_engine_usage() {
  echo "Usage: $0 engine <command> [options]"
  echo "Commands:"
  echo "  install    Install the Flaspbian engine"
  echo "  update     Update the Flaspbian engine"
  echo "  uninstall  Uninstall the Flaspbian engine"
}
# Install Flaspbian
install_engine() {
  echo "Installing Flaspbian..."

  # Check if the Flaspbian directory exists
  if [[ -d "$flutter_pi_dir" ]]; then
    echo "Flaspbian directory already exists. Consider updating instead."
    exit 1
  fi

  # Update and install dependencies
  update_and_install_dependencies

  git clone https://github.com/flaspbian/flutter-pi.git "$flutter_pi_dir"
  cd $flutter_pi_dir || exit
  mkdir -p build && cd build
  cmake ..
  make -j$(nproc) && sudo make install
  cd ../..  # Ensure returning to the original directory

  # Create the flapps directory, if it doesn't exist
  if [[ ! -d "$flapps_dir" ]]; then
    mkdir -p "$flapps_dir"
  fi

  # Enable 3D acceleration
  enable_3d_acceleration

  # Set boot options
  set_boot_options
}

# Update Flaspbian
update_engine() {
  echo "Checking for updates..."
  # Check if the Flaspbian directory exists
  if [[ ! -d "$flutter_pi_dir" ]]; then
    echo "Flaspbian directory not found, cannot update. Consider installing first."
    exit 1
  fi
  
  update_and_install_dependencies

  # Navigate to the Flaspbian directory
  pushd "$flutter_pi_dir"

  # Display the repository URL
  echo "Repository URL: $(git remote get-url origin)"
  # Display the current branch
  echo "Current branch: $(git branch --show-current)"

  # Implement to return when git has no updates with message
  git fetch
  # Check if the repository is up-to-date
  if [[ $(git rev-parse HEAD) == $(git rev-parse @{u}) ]]; then
    echo "Flaspbian is already up-to-date."
    exit 0
  fi

  # Set git to rebase when pulling
  git config pull.rebase true
  # Pull the latest changes from the repository
  git pull
  
  # Check if the build directory exists, create it if not
  if [[ ! -d build ]]; then
    mkdir build
  fi
  
  # Navigate to the build directory
  pushd build || exit
  # Re-run cmake and build the project
  cmake .. 
  make -j"$(nproc)" && sudo make install
  
  # Return to the original directory
  popd  # Exit build directory
  popd  # Exit flaspbian directory

  # Create the flapps directory, if it doesn't exist
  if [[ ! -d "$flapps_dir" ]]; then
    mkdir -p "$flapps_dir"
  fi

  # Enable 3D acceleration
  enable_3d_acceleration

  # Overwrite boot options
  set_boot_options

  echo "Flaspbian update complete."
}

# Uninstall Flaspbian
uninstall_engine() {
  echo "Uninstalling Flaspbian..."
  
  # Stop and Remove app services, if any
  if [[ -f /etc/systemd/system/*.flapp.service ]]; then
    sudo systemctl stop *.flapp.service
    sudo systemctl disable *.flapp.service
    sudo rm /etc/systemd/system/*.flapp.service
    sudo systemctl daemon-reload
  fi

  # Remove flapps directory if it exists
  if [[ -d "$flapps_dir" ]]; then
    sudo rm -rf "$flapps_dir"
  fi

  # Remove the flaspbian directory
  if [[ -d "$flutter_pi_dir" ]]; then
    sudo rm -rf "$flutter_pi_dir"
  fi

  # Issue: when setting boot options to default, doesnt execute further commands
  # Reset boot options to their defaults
  reset_boot_options

  echo "Flaspbian has been uninstalled."
  # Optionally prompt for a reboot here
  reboot
}

### Flaspbian App Functions ###
# Function to manage Flaspbian apps
app() {
  case "$1" in
    install)
      install_app "$2" "$3"
      ;;
    update)
      update_app "$2" "$3"
      ;;
    uninstall)
      uninstall_app "$2"
      ;;
    list)
      list_apps
      ;;
    *)
      echo "Error: Invalid command '$1'"
      show_app_usage
      ;;
  esac
}
# Function to show app usage information
show_app_usage() {
  echo "Usage: $0 app <command> [options]"
  echo "Commands:"
  echo "  install <app> <url>    Install a Flaspbian app"
  echo "  update <app> <url>     Update a Flaspbian app"
  echo "  uninstall <app>        Uninstall a Flaspbian app"
  echo "  list                   List installed Flaspbian apps"
}

# Install Flaspbian App
install_app() {
  echo "Installing Flaspbian App..."

  echo "\$0=$0"
  echo "\$1=$1"
  echo "\$2=$2"
  echo "\$3=$3"

  app="$2"
  url="$3"
  apparchive="~/$app.flapp"

  # Check for app and URL arguments
  if [[ -z "$app" ]] || [[ -z "$url" ]]; then
    echo "Usage: $0 app <app> <url>"
    exit 1
  fi

  # Check if the app is already installed
  if [[ -d $flapps_dir/$app ]]; then
    echo "Error: an app '$app' is already installed."
    exit 1
  fi

  echo "Installing $app from web..."
  curl -L "$url" -o $apparchive
  mkdir -p $flapps_dir/$app 
  tar -xzvf $apparchive -C $flapps_dir/$app
  sudo rm $apparchive
  sudo mv $flapps_dir/$app/build/flutter_assets/* $flapps_dir/$app
  create_app_service
}

# Update Flaspbian App
update_app() {
  echo "Updating Flaspbian App..."

  app="$2"
  url="$3"
  apparchive="~/$app.flapp"

  # Check for app and URL arguments
  if [[ -z "$app" ]] || [[ -z "$url" ]]; then
    echo "Usage: $0 <app> <url>"
    exit 1
  fi

  # Check if the app is already installed
  if [[ ! -d $flapps_dir/$app ]]; then
    echo "Error: an app '$app' is not installed."
    exit 1
  fi

  echo "Updating $app from web..."
  curl -L "$url" -o $apparchive
  mkdir -p $flapps_dir/$app 
  tar -xzvf $apparchive -C $flapps_dir/$app
  sudo rm $apparchive
  sudo mv $flapps_dir/$app/build/flutter_assets/* $flapps_dir/$app
  remove_app_service
  create_app_service
}
# Uninstall Flaspbian App
uninstall_app() {
  echo "Uninstalling Flaspbian App..."

  app="$2"

  # Check for app argument
  if [[ -z "$app" ]]; then
    echo "Usage: $0 <app>"
    exit 1
  fi

  # Check if the app is already installed
  if [[ ! -d $flapps_dir/$app ]]; then
    echo "Error: an app '$app' is not installed."
    exit 1
  fi

  echo "Uninstalling $app..."
  remove_app_service
  sudo rm -R $flapps_dir/$app
  sudo rm $apparchive
  sudo systemctl daemon-reload
}
# List Flaspbian Apps
list_apps() {
  echo "Installed Flaspbian apps:"
  ls $flapps_dir
}

# Create and enable a systemd service for flaspbian app
create_app_service() {
  echo "Creating $app systemd service..."
  cat <<EOF | sudo tee /etc/systemd/system/$app.flapp.service > /dev/null
[Unit]
Description=$app Application Service
After=graphical.target

[Service]
ExecStart=/usr/local/bin/flutter-pi --release $flapps_dir/$app
User=$(whoami)
Group=$(whoami)
Environment="DISPLAY=:0"
Restart=always

[Install]
WantedBy=graphical.target
EOF
  # Enable the service
  sudo systemctl daemon-reload && sudo systemctl enable $app.flapp.service
}

# Remove the systemd service for flaspbian app
remove_app_service() {
  echo "Removing $app.flapp systemd service..."
  sudo systemctl stop $app.flapp.service
  sudo systemctl disable $app.flapp.service
  sudo rm /etc/systemd/system/$app.flapp.service
  sudo systemctl daemon-reload
}

### WiFi Functions ###
# Function to manage WiFi credentials
wifi() {
  case "$2" in
    add)
      add_wifi_networks "$3" "$4"
      ;;
    delete)
      delete_wifi_networks
      ;;
    list)
      get_wifi_networks
      ;;
    *)
      echo "Error: Invalid command '$2'"
      show_wifi_usage
      ;;
  esac
}
# Function to show wifi usage information
show_wifi_usage() {
    echo "Usage: $0 wifi <command> [options]"
    echo "Commands:"
    echo "  add <ssid> <psk>   Add WiFi credentials"
    echo "  delete             Delete WiFi credentials"
    echo "  list               List known WiFi networks"
}
# Function to add WiFi Network
add_wifi_network() {
    echo "Setting WiFi credentials..."

    ssid="$3"
    psk="$4"

    # Check for SSID and password arguments
    if [[ -z "$ssid" ]] || [[ -z "$psk" ]]; then
        echo "Usage: $2 <ssid> <psk>"
        exit 1
    fi

    # Generate WPA PSK from passphrase
    wpa_passphrase "$ssid" "$psk" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null

    # Notify user and suggest action
    echo "WiFi credentials set for SSID: $ssid. You may need to restart the networking service or the device."
}
# Function to get WiFi Networks
get_wifi_networks() {
    echo "Known WiFi networks (SSIDs):"
    grep 'ssid=' /etc/wpa_supplicant/wpa_supplicant.conf | cut -d'"' -f2
}

# TODO: Implement delete_wifi_networks
# Function to delete WiFi Networks
delete_wifi_networks() {
    echo "Deleting WiFi credentials..."
    # Implement deletion of WiFi credentials
}

# OK
# Reboot
reboot() {
    echo "Rebooting now..."
    sudo reboot
}

# Function to show usage information
show_usage() {
  echo "Usage: $0 <command> [options]"
  echo "Commands:"
  echo "  engine <command>     Manage the Flaspbian engine"
  echo "  wifi <command>       Manage WiFi credentials"
  echo "  app <command>        Manage Flaspbian apps"
}

# Main function to parse commands and execute corresponding actions
main() {
  display_system_info

  case "$1" in
    engine)
      engine "${@:2}"
      ;;
    wifi)
      wifi "${@:2}"
      ;;
    app)
      app "${@:2}"
      ;;
    *)
      echo "Error: Invalid command '$1'"
      show_usage
      exit 1
      ;;
  esac
}

# Pass all script arguments to the main function
main "$@"
