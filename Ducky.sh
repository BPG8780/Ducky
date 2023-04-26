#!/bin/bash

# 检查是否以 root 用户身份运行此脚本
if [ $(id -u) -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# 输出使用黄色文本的消息
echo -e "\033[33mThis message is displayed in yellow.\033[0m"


CONFIG_FILE="conf.ini"
REMOTE_CONFIG_URL="https://raw.githubusercontent.com/BPG8780/Ducky/main/conf.ini"

# 定义函数以获取当前操作系统框架类型
function get_system_architecture() {
  case "$(uname -m)" in
    "x86_64" | "amd64")
      echo "amd64"
      ;;
    "aarch64" | "arm64")
      echo "arm64"
      ;;
    *)
      echo "未知的架构类型"
      exit 1
      ;;
  esac
}

# 定义函数以获取最新版本的 Ducky Client
function get_latest_version() {
  # 发出 GitHub API 请求以获取最新版本标记
  response=$(curl --silent "https://api.github.com/repos/DuckyProject/DuckyRoBot/releases/latest")

  # 解析响应以获取最新版本号
  latest_version=$(echo "$response" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

  echo "$latest_version"
}

# 定义函数以显示菜单
function show_menu() {
  echo "请选择一个选项："
  echo "1. 安装 Ducky Client"
  echo "2. 自定义配置"
  echo "3. 选项 3"
}

# 定义函数以下载远程配置文件
function download_config() {
  curl -L -o "$CONFIG_FILE" "$REMOTE_CONFIG_URL"
  echo "配置文件已下载。"
}

# 定义函数以更改配置文件中的值
function change_config() {
  read -p "请输入 User 名称：" user_name
  read -p "请输入 Key 值：" key_value
  sed -i '' "s/^User=.*/User=$user_name/" "$CONFIG_FILE"
  sed -i '' "s/^Key=.*/Key=$key_value/" "$CONFIG_FILE"
}

# 获取用户输入并执行相应操作
show_menu
read choice
case $choice in
  1)
    system_architecture="$(get_system_architecture)"
    latest_version="$(get_latest_version)"
    mkdir -p ~/Ducky
    url="https://github.com/DuckyProject/DuckyRoBot/releases/download/$latest_version/DuckyClient-$system_architecture"
    curl -L -o "~/Ducky/DuckyClient" "$url"
    chmod +x "~/Ducky/DuckyClient"
    echo "Ducky Client $latest_version 已安装到 ~/Ducky 目录。"
    ;;
  2)
    if [ ! -f "$CONFIG_FILE" ]; then
      download_config
    fi
    change_config
    echo "配置已更改。"
    ;;
  3)
    echo "选项 3 已选择"
    ;;
  *)
    echo "无效的选择"
    exit 1
    ;;
esac
