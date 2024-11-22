#!/bin/bash

# Description:
# This script helps to mount a CIFS network share on Fedora/RHEL
# Installs BTRFS Assistant, adds Codecs for Firefox multimedia, mounts paragon Nas Shares

sudo dnf update

### Snapshots
sudo dnf install btrfs-assistant -y

### RPM Fusion 
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf group update core

### Multimedia Codecs
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld


# Update the .smbcredentials file with CIFS username and password
# Template for .smbcredentials:
#   username=<cifsusername>
#   password=<password>

# Variables here
cifs_host1="//paragon.local/data"
cifs_host2="//100.95.243.12/data"


# cifs host mountPoint1: mount_point1_name
mount_point1="/home/paragon"
mount_point2="/home/ts_paragon"          


# Ask user to update .smbcredentials file with their respective CIFS username and password
echo "Editing .smbcredentials file, please enter your credentials (CIFS username and password)."
sudo nano /root/.smbcredentials

# Create a Mount point Directory using variable mount_point1
if [ ! -d $mount_point1 ]; then
    sudo mkdir -p $mount_point1
fi

if [ ! -d $mount_point2 ]; then
    sudo mkdir -p $mount_point2
fi

# Change permissions to root only access for .smbcredentials as it has sensitive data
sudo chmod 700 /root/.smbcredentials

# Install cifs-utils if not installed
sudo dnf install cifs-utils -y

# Add the CIFS entry to /etc/fstab
echo '# CIFS mount for network share and tailscale share' | sudo tee --append /etc/fstab > /dev/null
echo "${cifs_host1} ${mount_point1} cifs credentials=/root/.smbcredentials,iocharset=utf8,_netdev,file_mode=0777,dir_mode=0777 0 0" | sudo tee --append /etc/fstab > /dev/null
echo "${cifs_host2} ${mount_point2} cifs credentials=/root/.smbcredentials,iocharset=utf8,_netdev,file_mode=0777,dir_mode=0777 0 0" | sudo tee --append /etc/fstab > /dev/null


# Mount all filesystems mentioned in /etc/fstab
echo "Mounting all filesystems..."
sudo mount -a
# Display all mounted filesystems with their sizes
echo "Displaying details of all mounted filesystems..."
df -h

### Tailscale
curl -fsSL https://tailscale.com/install.sh | sh


### Jellyfin
flatpak install flathub com.github.iwalton3.jellyfin-media-player


### Gnome Extensions
flatpak install flathub org.gnome.Extensions
flatpak install flathub com.mattjakeman.ExtensionManager


sudo dnf update

# End of the script. You can save this script with a .sh extension. Suggested filename: mount_cifs.sh