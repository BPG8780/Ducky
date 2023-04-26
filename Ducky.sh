#!/bin/bash

mkdir -p "/root/Ducky/"

# Download DuckyClient function
function downloadDuckyClient {
    # Check if the script is being run as root
    if [ "$EUID" -ne 0 ]; then
        echo "请以root用户运行此脚本！"
        displayMenu
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

    # Return to menu
    displayMenu
}

# Create conf.ini file
function createAndReadConfFile {
    echo "[Client]" > "/root/Ducky/conf.ini"
    read -p "请输入User值和Key值（用空格分隔）：" user_and_key

    # 分离User和Key值
    user_value=$(echo $user_and_key | cut -d' ' -f1)
    key_value=$(echo $user_and_key | cut -d' ' -f2)

    echo "User=$user_value" >> "/root/Ducky/conf.ini"
    echo "Key=$key_value" >> "/root/Ducky/conf.ini"
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

    # Display all configuration sections and options
    awk -F= '/^\[/ {section=$1} /^\[.*$/ {next;} /^user/ {printf("Section: %s, User: %s, Key: %s\n", section, $2, $(getline));} /^fingerprint/ {printf("Fingerprint: %s\n", $2)} /^tenancy/ {printf("Tenancy: %s\n", $2)} /^region/ {printf("Region: %s\n", $2)} /^key_file/ {printf("Key File Path: %s\n\n", $2)}' /root/Ducky/conf.ini

    # Return to menu
    displayMenu
}

# Read conf.ini file
function readConfFile {
    # Check if the conf.ini file exists
    if [ ! -f "/root/Ducky/conf.ini" ]; then
        echo "conf.ini 文件不存在！"
        displayMenu
    fi

    # Display all configuration sections and options
    awk -F= '/^\[/ {section=$1} /^\[.*$/ {next;} /^user/ {printf("Section: %s, User: %s, Key: %s\n", section, $2, $(getline));} /^fingerprint/ {printf("Fingerprint: %s\n", $2)} /^tenancy/ {printf("Tenancy: %s\n", $2)} /^region/ {printf("Region: %s\n", $2)} /^key_file/ {printf("Key File Path: %s\n\n", $2)}' /root/Ducky/conf.ini

    # Return to menu
    displayMenu
}

function displayMenu {
echo "请输入要执行的操作："
echo "1. 下载和安装DuckyClient"
echo "2. 创建和读取conf.ini文件"
echo "3. 读取已有的conf.ini文件"
echo "4. 退出"
read -p "请选择： " choice

# Call appropriate function based on user input
case "$choice" in
    1)
        downloadDuckyClient
        ;;
    2)
        createAndReadConfFile
        ;;
    3)
        readConfFile
        ;;
    4)
        exit 0
        ;;
    *)
        echo "无效的选择！"
        displayMenu
        ;;
esac
}

displayMenu