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

    while true; do
        echo ""
        echo "请输入自定义配置信息："
        read -p "请输入方括号中的名称：" section_name
        echo "[$section_name]" >> "/root/Ducky/conf.ini"

        while true; do
            read -p "请输入变量名（输入 'q' 退出）：" var_name
            if [[ $var_name == "q" ]]; then
                break
            fi

            read -p "请输入 $var_name 的值：" var_value
            echo "$var_name=\"$var_value\"" >> "/root/Ducky/conf.ini"
        done

        echo ""
        read -p "是否要继续添加配置？（y/n） " choice
        if [[ $choice != "y" ]]; then
            break
        fi
    done

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
