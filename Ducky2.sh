#!/bin/bash

# 检查是否以root用户身份运行
if [ "$(id -u)" != "0" ]; then
    echo "请以root用户运行此脚本！"
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
        echo "Unsupported operating system"
        exit 1
    fi
}

function display_menu(){
    clear
    echo "=============================="
    echo -e "          菜单                "
    echo "=============================="
    echo -e "操作系统: \033[33m$OS\033[0m"
    echo 
    echo "1. 更新系统和依赖项"
    echo "2. 退出"
    echo 
}

function read_options(){
    local choice
    read -p "请输入选项数字 [1-2]: " choice
    case $choice in
        1) update_dependencies ;;
        2) exit 0;;
        *) echo -e "${RED}错误: 请选择正确的选项${NC}" && sleep 2
    esac
}

while true
do
    display_menu
    read_options
done