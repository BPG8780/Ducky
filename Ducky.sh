#!/bin/bash

# 检测是否以root用户运行
if [ "$EUID" -ne 0 ]; then
    echo "请使用root用户运行此脚本！"
    exit 1
fi

# 创建Ducky目录
mkdir -p "/root/Ducky/"

# 获取系统信息，判断是amd64还是arm64
if [ $(uname -m) == "x86_64" ]; then
    CPU_ARCH="amd64"
else
    CPU_ARCH="arm64"
fi

# 获取最新版本号和下载链接
LATEST_VERSION=$(curl --silent https://api.github.com/repos/DuckyProject/DuckyRoBot/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_URL="https://github.com/DuckyProject/DuckyRoBot/releases/download/$LATEST_VERSION/DuckyClient-$CPU_ARCH"

# 下载文件到/root/Ducky目录下，并重命名为DuckyClient
cd "/root/Ducky/"
wget -O "DuckyClient" "$DOWNLOAD_URL"

# 给予可执行权限
chmod +x "./DuckyClient"

# 安装DuckyClient函数
function installDuckyClient {
    cd "/root/Ducky/"
    chmod +x "./DuckyClient"
    echo -e "\033[33m安装完成！\033[0m"
    return 0 # 返回0表示安装成功
}

# 配置DuckyClient函数
function configDuckyClient {
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
    CONFIG="[Client]\nUser=$USER\nKey=$KEY\nPort=8088\n\n##### 甲骨文账号配置 #####\n[$CUSTOM_NAME]\nuser=$USER\nuser=$USER2\nfingerprint=$FINGERPRINT\ntenancy=$TENANCY\nregion=$REGION\nkey_file=$KEY_FILE"
    echo -e "$CONFIG" > "/root/Ducky/config.ini"

    echo -e "\033[33m配置完成！\033[0m"
    return 0 # 返回0表示配置成功
}

# 提示用户选择操作
echo -e "\033[33m请选择要进行的操作：\033[0m"
echo -e "\033[33m1. 安装 DuckyClient\033[0m"
echo -e "\033[33m2. 配置 DuckyClient\033[0m"
read CHOICE

if [ "$CHOICE" = "1" ]; then
    installDuckyClient
    if [ $? -eq 0 ]; then
        exit 0 # 安装成功，退出脚本并返回0
    else
        exit 1 # 安装失败，退出脚本并返回1
    fi
elif [ "$CHOICE" = "2" ]; then
    configDuckyClient
fi
