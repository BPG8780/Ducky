#!/bin/bash

# Create Ducky directory in /root
mkdir -p "/root/Ducky/"

# Download DuckyClient function
function downloadDuckyClient {
    # Check if the script is being run as root
    if [ "$EUID" -ne 0 ]; then
        echo "请以root用户运行此脚本！"
        exit 1
    fi

    # Check system architecture and select appropriate DuckyClient version
    if [ $(uname -m) == "x86_64" ]; then
        CPU_ARCH="amd64"
    else
        CPU_ARCH="arm64"
    fi

    # Get latest version number and download URL
    LATEST_VERSION=$(curl --silent https://api.github.com/repos/DuckyProject/DuckyRoBot/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    DOWNLOAD_URL="https://github.com/DuckyProject/DuckyRoBot/releases/download/$LATEST_VERSION/DuckyClient-$CPU_ARCH"

    # Download DuckyClient from GitHub to /root/Ducky directory
    echo "正在下载DuckyClient $LATEST_VERSION 到 /root/Ducky 目录..."
    wget "$DOWNLOAD_URL" -O "/root/Ducky/DuckyClient" && chmod +x "/root/Ducky/DuckyClient"

    # Your code here
}

# Create conf.ini file
function createConfFile {
    echo "[Client]" > "/root/Ducky/conf.ini"
    read -p "请输入User值: " user
    echo "User=$user" >> "/root/Ducky/conf.ini"
    read -p "请输入Key值: " key
    echo "Key=$key" >> "/root/Ducky/conf.ini"
    echo "Port=808" >> "/root/Ducky/conf.ini"
    echo "" >> "/root/Ducky/conf.ini"
    echo "##### 甲骨文账号配置 #####"

    read -p "请输入中括号中的内容: " section_name
    echo "[$section_name]" >> "/root/Ducky/conf.ini"
    read -p "请输入$section_name中的user值: " jg_user
    echo "user=$jg_user" >> "/root/Ducky/conf.ini"
    read -p "请输入$section_name中的fingerprint值: " fingerprint
    echo "fingerprint=$fingerprint" >> "/root/Ducky/conf.ini"
    read -p "请输入$section_name中的tenancy值: " tenancy
    echo "tenancy=$tenancy" >> "/root/Ducky/conf.ini"
    read -p "请输入$section_name中的region值: " region
    echo "region=$region" >> "/root/Ducky/conf.ini"
    read -p "请输入$section_name中的key_file值: " key_file
    echo "key_file=$key_file" >> "/root/Ducky/conf.ini"

    echo -e "\033[33mconf.ini文件已创建！\033[0m"
}

# Display menu
echo "请选择您要执行的操作："
echo "1. 下载最新版本的 DuckyClient"
echo "2. 创建自定义的 conf.ini 配置文件"
read choice

# Call appropriate function based on user's choice
if [ "$choice" == "1" ]; then
    echo -e "\033[33m您选择了下载最新版本的 DuckyClient\033[0m"
    downloadDuckyClient
elif [ "$choice" == "2" ]; then
    echo -e "\033[33m您选择了创建自定义的 conf.ini 配置文件\033[0m"
    createConfFile
else
    echo "尚未实现此功能！"
fi
