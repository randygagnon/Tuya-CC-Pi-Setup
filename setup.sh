#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

DHCPCD_CONF="/etc/dhcpcd.conf"
WPA_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"
NM_CONF="/etc/NetworkManager/NetworkManager.conf"
COUNTRY_CODE="US" # For a list of possible country codes, please see https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements

# If an argument is provided, use it as the country code
if [ "$#" -eq 1 ]; then
    COUNTRY_CODE="$1"
fi

function install_packages() {
  # Update and Upgrade APT, Install network-manager, Git, and Docker

  trap 'echo "!! Error in install_packages: Command $BASH_COMMAND exited with status $?"; exit 1' ERR
  
  echo "## Updating and upgrading APT packages for critical installations..."
  apt update
  apt upgrade -y
  
  echo "## Installing Network Manager, Git and Docker..."

  # Check if Network Manager is already installed
  if dpkg-query -W -f='${Status}' network-manager 2>/dev/null | grep -q "ok installed"; then
    echo "## Network Manager is already installed."
  else
    apt install -y network-manager
    echo "## Installed Network Manager"
  fi
  
  # Check if Git is already installed
  if dpkg-query -W -f='${Status}' git 2>/dev/null | grep -q "ok installed"; then
    echo "## Git is already installed."
  else
    apt install -y git
    echo "## Installed Git"
  fi
  
  # Check if Docker is already installed
  if dpkg-query -W -f='${Status}' docker-ce 2>/dev/null | grep -q "ok installed"; then
    echo "## Docker is already installed, upgrading to make sure you're on the latest."
    apt-get install --only-upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo "## Docker installed successfully."
  fi

  trap - ERR
}

function set_wlan_country() {
  # 

  trap 'echo "!! Error in set_wlan_country: Command $BASH_COMMAND exited with status $?"; exit 1' ERR

  echo "## Setting WLAN country for regulatory compliance..."

  if [ -z "$WPA_CONF" ]; then
    echo "## WLAN country was skipped because the var WPA_CONF is not specified in the script."
  elif [ ! -f "$WPA_CONF" ]; then
    echo "## WLAN country was skipped because the file does not exist on the pi."
  elif grep -q "country=$COUNTRY_CODE" "$WPA_CONF"; then
    echo "## WLAN country was skipped because the country is already set."
  else
    echo "country=$COUNTRY_CODE" >> "$WPA_CONF"
    echo "## WLAN country was set."
  fi

  trap - ERR
}

function disable_dhcp_on_wlan() {
  trap 'echo "!! Error in disable_dhcp_on_wlan: Command $BASH_COMMAND exited with status $?"; exit 1' ERR
  
  echo "## Disabling DHCP on the wireless interface..."
  touch $DHCPCD_CONF
  if grep -q "denyinterfaces wlan0" $DHCPCD_CONF; then
    echo "## denyinterfaces wlan0 is already set"
  else
    echo "denyinterfaces wlan0" >> $DHCPCD_CONF
    echo "## denyinterfaces wlan0 added to dhcpcd.conf"
  fi
  
  trap - ERR
}

function update_network_manager_conf() {
  trap 'echo "!! Error in update_network_manager_conf: Command $BASH_COMMAND exited with status $?"; exit 1' ERR
  
  echo "## Configuring NetworkManager..."
  if [ -f "$NM_CONF" ]; then
    echo "[main]
    plugins=ifupdown,keyfile
    dhcp=internal
    
    [ifupdown]
    managed=true" > "$NM_CONF"
    
    echo "## NetworkManager configuration updated"
  else
    echo "## The NM_CONF var was not set in the script"
  fi
  
  trap - ERR
}

function get_repo() {
  trap 'echo "!! Error in get_repo: Command $BASH_COMMAND exited with status $?"; exit 1' ERR
  
  if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
  else
    USER_HOME=$HOME
  fi

  REPO_DIR="$USER_HOME/tuya-cloudcutter"
  
  echo "## Cloning or updating Tuya Cloudcutter repository..."
  # echo "Debug: REPO_DIR is $REPO_DIR"
  if [ -d "$REPO_DIR" ]; then
    echo "## Tuya Cloudcutter repository already exists. Pulling latest changes."
    sudo -u $SUDO_USER sh -c "cd $REPO_DIR && git pull origin main"
  else
    sudo -u $SUDO_USER sh -c "git clone https://github.com/tuya-cloudcutter/tuya-cloudcutter.git $REPO_DIR"
    echo "## Tuya Cloudcutter repository cloned."
  fi
  
  trap - ERR
}

function prompt_for_reboot() {
  echo "## A reboot is necessary to apply changes."
  read -p "Would you like to reboot now? [y/N]: " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    reboot
  else
    echo "## Skipping reboot."
  fi
}

# Main script execution
install_packages
set_wlan_country
disable_dhcp_on_wlan
update_network_manager_conf
get_repo
prompt_for_reboot
