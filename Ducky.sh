#!/bin/bash

# 创建Ducky目录
mkdir -p "/root/Ducky/"

# 下载DuckyClient函数
function downloadDuckyClient {
    # 检测是否以root用户运行
    if [ "$EUID" -ne 0 ]; then
        echo "请使用root用户运行此脚本！"
        exit 1
    fi

    # 判断系统架构，选择合适的DuckyClient版本
    if [ $(uname -m) == "x86_64" ]; then
        CPU_ARCH="amd64"
    else
        CPU_ARCH="arm64"
    fi

    # 获取最新版本号和下载链接
    LATEST_VERSION=$(curl --silent https://api.github.com/repos/DuckyProject/DuckyRoBot/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    DOWNLOAD_URL="https://github.com/DuckyProject/DuckyRoBot/releases/download/$LATEST_VERSION/DuckyClient-$CPU_ARCH"

    # 判断DuckyClient是否已经存在
    if [ -f "/root/Ducky/DuckyClient" ]; then
        read -p "DuckyClient已经存在，确定要覆盖吗？[Y/N]" CHOICE
        case $CHOICE in
            Y|y)
                rm "/root/Ducky/DuckyClient"
                ;;
            *)
                return 0 # 返回0表示未安装
                ;;
        esac
    fi

    # 下载文件到/root/Ducky目录下，并重命名为DuckyClient
    cd "/root/Ducky/"
    wget -O "DuckyClient" "$DOWNLOAD_URL"

    # 给予可执行权限
    chmod +x "./DuckyClient"

    echo -e "\033[33m下载完成！\033[0m"
    return 1 # 返回1表示已安装
}

# 配置DuckyClient函数
function configDuckyClient {
    # 检查DuckyClient是否已经安装
    if [ ! -x "/root/Ducky/DuckyClient" ]; then
        echo -e "\033[33mDuckyClient未安装，请先选择1下载！\033[0m"
        return
    fi

    # 提示用户输入配置信息
    echo -e "\033[33m请按提示输入 DuckyClient 的配置信息：\033[0m"
    read -p "User = " USER
    read -p "Key = " KEY
    read -p "User Name = " CUSTOM_NAME
    read -p "user = " USER2
    read -p "finger print = " FINGERPRINT
    read -p "tenancy id = " TENANCY
    read -p "region = " REGION
    read -p "key file = " KEY_FILE

    # 根据用户输入生成配置文件
    CONFIG="[Client]\nUser=$USER\nKey=$KEY\nPort=8088\n\n##### 甲骨文账号配置 #####\n[$CUSTOM_NAME]\nuser=$USER2\nfingerprint=$FINGERPRINT\ntenancy=$TENANCY\nregion=$REGION\nkey_file=$KEY_FILE"
    echo -e "$CONFIG" > "/root/Ducky/config.ini"

    echo -e "\033[33m配置完成！\033[0m"
}

# 菜单函数
function menu {
    echo "请选择操作："
    echo "1. 下载并安装DuckyClient"
    echo "2. 配置DuckyClient"
    read -p "请输入数字[1-2]: " CHOICE
    case $CHOICE in
        1)
            downloadDuckyClient
            ;;
        2)
            configDuckyClient
            ;;
        *)
            echo "无效的选择！"
            ;;
    esac
}

# 运行菜单函数
menu
