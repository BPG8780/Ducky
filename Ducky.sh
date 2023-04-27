#!/bin/bash

function downloadDuckyClient {

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

    read -p $'\e[31m请输入 User 值：\e[0m' user_value
    read -p $'\e[31m请输入 Key 值: \e[0m' key_value

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
        read -p $'\e[31m请输入 《user、fingerprint、tenancy、region、key_file》=数值（用空格分隔）：\e[0m'
 
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

function DuckyClientService {
    cat << EOF > "/etc/systemd/system/DuckyClient.service"
[Unit]
Description=DuckyClient Service
After=network.target

[Service]
ExecStart=/root/Ducky/DuckyClient
WorkingDirectory=/root/Ducky/
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable DuckyClient.service

    echo -e "\033[32mDuckyClient 已设置开机启动！\033[0m"

    if ! pgrep DuckyClient > /dev/null; then
        echo "DuckyClient 进程未运行！"
    else
        echo "正在重启 DuckyClient ..."
        systemctl restart DuckyClient.service
    fi

    sleep 1s

    if ! pgrep DuckyClient > /dev/null; then
        echo -e "\033[31mDuckyClient 启动失败！\033[0m"
    else
        echo -e "\033[32mDuckyClient 启动成功！\033[0m"
    fi

    displayMenu
}

function displayMenu {
    echo -e "\033[33m请选择要执行的操作：\033[0m"
    echo -e "\033[33m1 - 安装 DuckyClient\033[0m"
    echo -e "\033[33m2 - 创建 conf.ini 文件\033[0m"
    echo -e "\033[33m3 - 添加新的配置\033[0m"
    echo -e "\033[33m4 - 启动 DuckyClient\033[0m"
    echo -e "\033[33m0 - 退出\033[0m"

    read -p "请输入数字选项：" choice

    case "$choice" in
        1)
            downloadDuckyClient
            ;;
        2)
            createConfFile
            ;;
        3) 
            addNewOracleAccount
            ;;
        4) 
            DuckyClientService
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
