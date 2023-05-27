#!/bin/bash
# 检查是否以root用户身份运行
if [ "$(id -u)" != "0" ]; then
    echo "请以Root用户运行此脚本！"
    exit 1
fi

# 提取Linux版本号并将其保存到变量中
OS=$(cat /etc/*-release | grep "^NAME" | head -n1 | cut -d= -f2 | tr -d '""')

function update_dependencies() {
    # 根据操作系统变量执行适当的更新命令
    if [ "$OS" == "Ubuntu" ] || [ "$OS" == "Debian GNU/Linux" ]; then
        apt-get update
        apt-get upgrade -y
        apt-get check
    elif [ "$OS" == "CentOS Linux" ] || [ "$OS" == "Red Hat Enterprise Linux Server" ]; then
        yum update -y
        yum upgrade -y
        yum check
    else
        echo "不支持的操作系统"
        exit 1
    fi
}

function downloadDuckyClient {

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

    if [[ -f "/root/Ducky/DuckyClient" ]]; then
        CURRENT_VERSION=$(/root/Ducky/DuckyClient -v | cut -d ' ' -f 2)
        if [[ $LATEST_VERSION == $CURRENT_VERSION ]]; then
            echo -e "\033[32m你已经安装了最新版本的 DuckyClient！\033[0m"
            displayMenu
        else
            echo -e "\033[33m检测到当前已安装 DuckyClient 的版本为 $CURRENT_VERSION，最新版本为 $LATEST_VERSION。\033[0m"
        fi
    fi

    echo "正在下载DuckyClient $LATEST_VERSION 到 /root/Ducky 目录..."
    wget "$DOWNLOAD_URL" -O "/root/Ducky/DuckyClient" && chmod +x "/root/Ducky/DuckyClient"

    echo -e "\033[32mDuckyClient 下载完成！\033[0m"

    displayMenu
}

function createConfFile {
    echo "[Client]" > "/root/Ducky/conf.ini"

    read -p $'\e[33m请输入 User 值：\e[0m' user_value
    read -p $'\e[33m请输入 Key 值: \e[0m' key_value

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
        read -p $'\e[33m请输入 《user、fingerprint、tenancy、region、key_file》=数值（用空格分隔）：\e[0m'
 
        account_id=$(echo "$REPLY" | cut -d ' ' -f 1)
        fingerprint=$(echo "$REPLY" | cut -d ' ' -f 2)
        tenancy=$(echo "$REPLY" | cut -d ' ' -f 3)
        region_name=$(echo "$REPLY" | cut -d ' ' -f 4)
        key_file_path=$(echo "$REPLY" | cut -d ' ' -f 5)

        echo "user=$account_id" >> "/root/Ducky/conf.ini"
        echo "fingerprint=$fingerprint" >> "/root/Ducky/conf.ini"
        echo "tenancy=$tenancy" >> "/root/Ducky/conf.ini"
        echo "region=$region_name" >> "/root/Ducky/conf.ini"
        echo "key_file=/root/Ducky/$key_file_path" >> "/root/Ducky/conf.ini"
        echo "" >> "/root/Ducky/conf.ini"
    done

    echo -e "\033[33mconf.ini 文件已更新！\033[0m"

    displayMenu
}

function DuckyClientService {
    cat << EOF > "/etc/systemd/system/DuckyClient.service"
[Unit]
Description=DuckyClient Service

[Service]
Type=simple
WorkingDirectory=/root/Ducky
ExecStart=/root/Ducky/DuckyClient &
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl start DuckyClient.service
    systemctl enable DuckyClient.service

    echo -e "\033[32mDuckyClient 已启动以及设置开机启动！\033[0m"

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
    echo -e "========================="
    echo -e "操作系统: \033[33m$OS\033[0m"
    echo -e "========================="
    echo -e "\033[33m请选择要执行的操作：\033[0m"
    echo -e "\033[33m1 - 更新$OS软件和依赖\033[0m"
    echo -e "\033[33m2 - 安装 DuckyClient\033[0m"
    echo -e "\033[33m3 - 创建 conf.ini 文件\033[0m"
    echo -e "\033[33m4 - 添加新的配置\033[0m"
    echo -e "\033[33m5 - 启动 DuckyClient\033[0m"
    echo -e "\033[33m0 - 退出\033[0m"

    read -p "请输入数字选项：" choice

    case "$choice" in
        1)
            update_dependencies
            ;;
        2)
            downloadDuckyClient
            ;;
        3)
            createConfFile
            ;;
        4) 
            addNewOracleAccount
            ;;
        5) 
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
