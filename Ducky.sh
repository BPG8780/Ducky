#!/bin/bash

function downloadDuckyClient {
    # Check if the script is being run as root
    if [ "$EUID" -ne 0 ]; then
        echo "请以root用户运行此脚本！"
        displayMenu
    fi
    
    mkdir -p "/root/Ducky/"

    if [ $(uname -m) == "x86_64" ]; then
        CPU_ARCH="amd64"
    else
        CPU_ARCH="arm64"
    fi

    LATEST_VERSION=$(curl --silent https://api.github.com/repos/DuckyProject/DuckyRoBot/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    DOWNLOAD_URL="https://github.com/DuckyProject/DuckyRoBot/releases/download/$LATEST_VERSION/DuckyClient-$CPU_ARCH"

    echo "正在下载DuckyClient $LATEST_VERSION 到 /root/Ducky 目录..."
    wget "$DOWNLOAD_URL" -O "/root/Ducky/DuckyClient" && chmod +x "/root/Ducky/DuckyClient"

    # Return to menu
    displayMenu
}

#!/bin/bash

#!/bin/bash

#!/bin/bash

function createAndReadConfFile {
    echo "[Client]" > "/root/Ducky/conf.ini"
    read -p "请输入 User 值和 Key 值（用空格分隔）：" 

    user_value=$(echo "$REPLY" | cut -d ' ' -f 2)
    key_value=$(echo "$REPLY" | cut -d ' ' -f 4)

    echo "User=$user_value" >> "/root/Ducky/conf.ini"
    echo "Key=$key_value" >> "/root/Ducky/conf.ini"
    echo "Port=8088" >> "/root/Ducky/conf.ini"
    echo "" >> "/root/Ducky/conf.ini"
    echo "##### 甲骨文账号配置 #####" >> "/root/Ducky/conf.ini"

    while true; do
        read -p "输入 'BPG' 完成配置，输入要自定义的名称：" section_name
        if [[ $section_name == BPG ]]; then
            break
        fi
        echo "[$section_name]" >> "/root/Ducky/conf.ini"
        read -p "请输入 account ID、fingerprint、tenancy、region 和 key file path（用空格分隔）：" 

        account_id=$(echo "$REPLY" | cut -d ' ' -f 1)
        fingerprint=$(echo "$REPLY" | cut -d ' ' -f 2)
        tenancy=$(echo "$REPLY" | cut -d ' ' -f 3)
        region_name=$(echo "$REPLY" | cut -d ' ' -f 4)
        key_file_path=$(echo "$REPLY" | cut -d ' ' -f 5)

        echo "user=$account_id" >> "/root/Ducky/conf.ini"
        echo "fingerprint=$fingerprint" >> "/root/Ducky/conf.ini"
        echo "tenancy=$tenancy" >> "/root/Ducky/conf.ini"
        echo "region=$region_name" >> "/root/Ducky/conf.ini"
        echo "key_file=$key_file_path" >> "/root/Ducky/conf.ini"
        echo "" >> "/root/Ducky/conf.ini"
    done

    echo -e "\033[33mconf.ini 文件已创建！\033[0m"

    awk -F= '/^\[/ {section=$1} /^\[.*$/ {next;} /^user/ {printf("Section: %s, User: %s, Key: %s\n", section, $2, $(getline));} /^fingerprint/ {printf("Fingerprint: %s\n", $2)} /^tenancy/ {printf("Tenancy: %s\n", $2)} /^region/ {printf("Region: %s\n", $2)} /^key_file/ {printf("Key File Path: %s\n\n", $2)}' /root/Ducky/conf.ini

    displayMenu
}

function readConfFile {
    if [ ! -f "/root/Ducky/conf.ini" ]; then
        echo "conf.ini 文件不存在！"
        displayMenu
    fi

    awk -F= '/^\[/ {section=$1} /^\[.*$/ {next;} /^user/ {printf("Section: %s, User: %s, Key: %s\n", section, $2, $(getline));} /^fingerprint/ {printf("Fingerprint: %s\n", $2)} /^tenancy/ {printf("Tenancy: %s\n", $2)} /^region/ {printf("Region: %s\n", $2)} /^key_file/ {printf("Key File Path: %s\n\n", $2)}' /root/Ducky/conf.ini

    displayMenu
}

function displayMenu {
echo "请输入要执行的操作："
echo "1. 安装DuckyBot客户端"
echo "2. 创建conf.ini配置文件"
echo "3. 读取已有的conf.ini文件"
echo "4. 退出"
read -p "请选择： " choice

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
