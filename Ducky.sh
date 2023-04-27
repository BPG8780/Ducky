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

    displayMenu
}

function createConfFile {
    echo "[Client]" > "/root/Ducky/conf.ini"

    read -p "请输入 User 值：" user_value
    read -p "请输入 Key 值: " key_value

    echo "User=$user_value" >> "/root/Ducky/conf.ini"
    echo "Key=$key_value" >> "/root/Ducky/conf.ini"
    echo "Port=8088" >> "/root/Ducky/conf.ini"
    echo "" >> "/root/Ducky/conf.ini"
    echo "##### 甲骨文账号配置 #####" >> "/root/Ducky/conf.ini"

    addNewOracleAccount
}

function addNewOracleAccount {
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

    echo -e "\033[33mconf.ini 文件已更新！\033[0m"

    displayMenu
}

function startDuckyClient {
    # Check if the script is being run as root
    if [ "$EUID" -ne 0 ]; then
        echo "请以root用户运行此脚本！"
        displayMenu
    fi

    # Check if the DuckyClient is already running
    if pgrep DuckyClient > /dev/null; then
        echo "DuckyClient 已经在运行中，请勿重复启动！"
        displayMenu
    fi

    cd "/root/Ducky/"

    nohup ./DuckyClient > /dev/null &

    echo -e "\033[32mDuckyClient 已成功启动！\033[0m"

    displayMenu
}

function enableDuckyClientAtBoot {
    # Check if the script is being run as root
    if [ "$EUID" -ne 0 ]; then
        echo "请以root用户运行此脚本！"
        displayMenu
    fi

    # Check if systemd is installed
    if ! command -v systemctl > /dev/null; then
        echo "系统未安装 systemd，请手动设置开机启动！"
        displayMenu
    fi

    cat << EOF > "/etc/systemd/system/DuckyClient.service"
[Unit]
Description=DuckyClient Service
After=network.target

[Service]
ExecStart=/root/Ducky/DuckyClient
WorkingDirectory=/root/Ducky/
StandardOutput=null

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable DuckyClient.service

    echo -e "\033[32mDuckyClient 已经配置为开机启动！\033[0m"

    displayMenu
}

function restartDuckyClient {
    # Check if the script is being run as root
    if [ "$EUID" -ne 0 ]; then
        echo "请以root用户运行此脚本！"
        displayMenu
    fi

    # Check if the DuckyClient is running
    if ! pgrep DuckyClient > /dev/null; then
        echo "DuckyClient 没有在运行中！"
        displayMenu
    fi

    pkill DuckyClient
    sleep 2s
    cd "/root/Ducky/"
    nohup ./DuckyClient > /dev/null &

    echo -e "\033[32mDuckyClient 已成功重启！\033[0m"

    displayMenu
}

function displayMenu {
echo "请选择要执行的操作："
echo "1 - 安装 DuckyClient"
echo "2 - 创建 conf.ini 文件"
echo "3 - 添加新的配置"
echo "4 - 启动 DuckyClient"
echo "5 - 设置开机启动"
echo "6 - 重启 DuckyClient"
echo "0 - 退出"

read -p "请输入数字选项：" choice

case "$choice" in
    1)
        downloadDuckyClient
        ;;
    2)
        createAndReadConfFile
        ;;
    3) 
        addNewOracleAccount
        ;;
    4) 
        startDuckyClient
        ;;
    5) 
        enableDuckyClientAtBoot
        ;;
    6) 
        restartDuckyClient
        ;;
    0) 
        exit 0
        ;;
    *)
        echo "无效的选择！"
        displayMenu
        ;;
esac
}

displayMenu
