#!/bin/bash

# 检查是否以root用户身份运行
if [ "$(id -u)" != "0" ]; then
    echo "请以root用户运行此脚本！"
    exit 1
fi

# 检测系统信息并将其保存到变量中
if [ -f /etc/os-release ]; then
    if grep -q "ID=debian\|ID=ubuntu" /etc/os-release; then
        SYSTEM="Debian/Ubuntu"
    elif grep -q "ID=centos\|ID=\"rhel\"" /etc/os-release; then
        SYSTEM="CentOS/RHEL"
    else
        SYSTEM="Unknown"
    fi
else
    SYSTEM="Unknown"
fi

function update_dependencies() {
    # 更新包列表并更新系统已安装的软件包
    if [ "$SYSTEM" == "Debian/Ubuntu" ]; then
        apt-get update
        apt-get upgrade -y
    elif [ "$SYSTEM" == "CentOS/RHEL" ]; then
        yum update -y
        yum upgrade -y
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
    # 检查软件包的依赖关系
    if [ "$SYSTEM" == "Debian/Ubuntu" ]; then
        apt-get check
    elif [ "$SYSTEM" == "CentOS/RHEL" ]; then
        yum check
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
}

function display_menu(){
    clear
    echo "=============================="
    echo "          菜单                "
    echo "=============================="
    echo "系统类型: $SYSTEM"
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
