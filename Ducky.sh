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

# 获取最新版本号
LATEST_VERSION=$(curl --silent https://api.github.com/repos/DuckyProject/DuckyRoBot/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_URL="https://github.com/DuckyProject/DuckyRoBot/releases/download/$LATEST_VERSION/DuckyClient-$CPU_ARCH"

# 下载文件到/root/Ducky目录下
cd "/root/Ducky/"
wget -O "DuckyClient.zip" "$DOWNLOAD_URL"

# 解压文件并重命名为DuckyClient
unzip -q "DuckyClient.zip"
chmod +x "./DuckyClient"
mv "./DuckyClient-$CPU_ARCH" "./DuckyClient"

# 删除临时文件
rm "DuckyClient.zip"

# 定义一个函数来安装DuckyClient
function installDuckyClient {
    cd "/root/Ducky/"
    chmod +x "./DuckyClient"
    echo -e "\033[33m安装完成！\033[0m"
}

# 提示用户选择安装
echo -e "\033[33m请输入 1 来安装 DuckyClient\033[0m"
read CHOICE

if [ "$CHOICE" = "1" ]; then
    installDuckyClient
fi
