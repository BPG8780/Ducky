#!/bin/sh

# 检查是否以root用户身份运行
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

# 创建Ducky目录并进入该目录
cd /
mkdir Ducky
cd Ducky

# 下载最新版本
if [ $(uname -m) = "x86_64" ]; then
    arch="amd64"
elif [ $(uname -m) = "aarch64" ]; then
    arch="arm64"
else
    echo "Unsupported architecture"
    exit 1
fi
url="https://github.com/DuckyProject/DuckyRoBot/releases/latest/download/DuckyClient-$arch"
wget "$url"

# 将文件重命名为DuckyClient并添加执行权限
chmod +x DuckyClient-$arch
mv DuckyClient-$arch DuckyClient

# 安装函数
install() {
    echo "Install function selected."
    # 在此处添加安装代码
}

# 选择要执行的操作
echo "Select an option:"
echo "1. Install DuckyClient"
read option

case $option in
    1)
        install
        ;;
    *)
        echo "Invalid option"
        ;;
esac
