#!/bin/bash

# 获取系统信息，判断是amd64还是arm64
if [ $(uname -m) == "x86_64" ]; then
    CPU_ARCH="amd64"
else
    CPU_ARCH="arm64"
fi

# 获取最新版本号
LATEST_VERSION=$(curl --silent https://api.github.com/repos/DuckyProject/DuckyRoBot/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

# 拼接下载链接
DOWNLOAD_URL="https://github.com/DuckyProject/DuckyRoBot/releases/download/$LATEST_VERSION/DuckyClient-$CPU_ARCH"

# 下载文件到/root目录下
cd "/root/"
wget -O "DuckyClient.zip" "$DOWNLOAD_URL"

# 解压文件到/root/Ducky目录下
unzip -q "DuckyClient.zip" -d "./Ducky/"

# 删除临时文件
rm "DuckyClient.zip"

# 提示用户选择安装
echo "请输入 1 来安装 DuckyClient"
read CHOICE

if [ "$CHOICE" = "1" ]; then
    cd "/root/Ducky/"
    chmod +x "./DuckyClient"
    echo "安装完成！"
fi
