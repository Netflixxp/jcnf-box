# By BlueSkyXN
# fonts color
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
bold(){
    echo -e "\033[1m\033[01m$1\033[0m"
}

Green_font_prefix="\033[32m" 
Red_font_prefix="\033[31m" 
Green_background_prefix="\033[42;37m" 
Red_background_prefix="\033[41;37m" 
Font_color_suffix="\033[0m"


function preferIPV4(){

    if [[ -f "/etc/gai.conf" ]]; then
        sed -i '/^precedence \:\:ffff\:0\:0/d' /etc/gai.conf
        sed -i '/^label 2002\:\:\/16/d' /etc/gai.conf
    fi

    if [[ -z $1 ]]; then
        
        echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf

        echo
        green " VPS服务器已成功设置为 IPv4 优先访问网络"

    else

        green " ================================================== "
        yellow " 请为服务器设置 IPv4 还是 IPv6 优先访问: "
        echo
        green " 1 优先 IPv4 访问网络"
        green " 2 优先 IPv6 访问网络"
        green " 3 删除 IPv4 或 IPv6 优先访问的设置, 还原为系统默认配置"
        echo
        read -p "请选择 IPv4 还是 IPv6 优先访问? 直接回车默认选1, 请输入[1/2/3]:" isPreferIPv4Input
        isPreferIPv4Input=${isPreferIPv4Input:-1}

        if [[ ${isPreferIPv4Input} == [2] ]]; then

            # 设置 IPv6 优先
            echo "label 2002::/16   2" >> /etc/gai.conf

            echo
            green " VPS服务器已成功设置为 IPv6 优先访问网络 "
        elif [[ ${isPreferIPv4Input} == [3] ]]; then

            echo
            green " VPS服务器 已删除 IPv4 或 IPv6 优先访问的设置, 还原为系统默认配置 "  
        else
            # 设置 IPv4 优先
            echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
            
            echo
            green " VPS服务器已成功设置为 IPv4 优先访问网络 "    
        fi

        green " ================================================== "
        echo
        yellow " 验证 IPv4 或 IPv6 访问网络优先级测试, 命令: curl ip.p3terx.com " 
        echo  
        curl ip.p3terx.com
        echo
        green " 上面信息显示："   
        green " 如果是IPv4地址->则VPS服务器已设置为 IPv4优先访问 "  
	green " 如果是IPv6地址->则VPS服务器已设置为 IPv6优先访问 "  
        green " ================================================== "

    fi
    echo

}

function start_menu(){
    clear
    green " 1. 设置 VPS服务器 IPv4 还是 IPv6 网络优先访问" 
    echo
    green " =================================================="
    green " 0. 退出脚本"
    echo
    read -p "请输入数字:" menuNumberInput
    case "$menuNumberInput" in
        1 )
           preferIPV4 "redo"
	;;
        0 )
            exit 1
        ;;
        * )
            clear
            red "请输入正确数字 !"
            sleep 2s
            start_menu
        ;;
    esac
}


start_menu "first"