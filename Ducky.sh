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
function createAndReadConfFile {
    echo "[Client]" > "/root/Ducky/conf.ini"
    read -p "请输入User值: " user
    echo "User=$user" >> "/root/Ducky/conf.ini"
    read -p "请输入Key值: " key
    echo "Key=$key" >> "/root/Ducky/conf.ini"
    echo "Port=8088" >> "/root/Ducky/conf.ini"
    echo "" >> "/root/Ducky/conf.ini"
    echo "##### Oracle Cloud账户配置 #####"

    while true; do
        read -p "输入 'done' 完成配置添加，或者输入要添加的自定义节名称：" section_name
        if [[ $section_name == done ]]; then
            break
        fi
        echo "[$section_name]" >> "/root/Ducky/conf.ini"
        read -p "请输入account ID、fingerprint、tenancy、region和key file path（用空格分隔）：" account_id fingerprint tenancy region_name key_file_path
        echo "user=$account_id" >> "/root/Ducky/conf.ini"
        echo "fingerprint=$fingerprint" >> "/root/Ducky/conf.ini"
        echo "tenancy=$tenancy" >> "/root/Ducky/conf.ini"
        echo "region=$region_name" >> "/root/Ducky/conf.ini"
        echo "key_file=$key_file_path" >> "/root/Ducky/conf.ini"
        echo "" >> "/root/Ducky/conf.ini"
    done

    echo -e "\033[33mconf.ini文件已创建！\033[0m"

    # 从配置文件中获取Oracle Cloud账户相关信息
    user=$(awk -F= '/^user/ {gsub(/"/,"",$2);print $2}' /root/Ducky/conf.ini)
    echo "User: $user"
    echo ""

    awk -F= '/^\[/ {section=$1} /^\[.*$/ {next;} /^user/ {printf("Section: %s, Account: %s\n", section, $2)} /^fingerprint/ {printf("Fingerprint: %s\n", $2)} /^tenancy/ {printf("Tenancy: %s\n", $2)} /^region/ {printf("Region: %s\n", $2)} /^key_file/ {printf("Key File Path: %s\n\n", $2)}' /root/Ducky/conf.ini
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
    createAndReadConfFile
else
    echo "尚未实现此功能！"
fi
