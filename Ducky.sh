#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root. Please try again with sudo." >&2
  exit 1
fi

# Create Ducky directory in root
mkdir /root/Ducky

# Determine system architecture
if [[ $(uname -m) == "x86_64" ]]; then
    ARCH="amd64"
else
    ARCH="arm64"
fi

# Get the latest release version from GitHub API
VERSION=$(curl -s https://api.github.com/repos/DuckyProject/DuckyRoBot/releases/latest | grep tag_name | cut -d '"' -f 4)

# Download the latest release of DuckyClient for the detected architecture
URL="https://github.com/DuckyProject/DuckyRoBot/releases/download/${VERSION}/DuckyClient-${ARCH}"
wget $URL -P /root/Ducky

# Give execute permission to the downloaded file
chmod +x /root/Ducky/DuckyClient-${ARCH}
