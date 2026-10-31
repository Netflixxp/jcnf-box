#!/usr/bin/env bash
[[ $EUID == 0 ]] || { echo "Run as root." >&2; exit 1; }
command -v systemctl >/dev/null || { echo "systemd required."; exit 1; }
red="\033[31m"
black="\033[0m"

####
echo "正在安装依赖...."
if command -v apt-get >/dev/null; then
    apt-get update && apt-get install -y dnsutils iptables iproute2 || exit 1
elif command -v dnf >/dev/null; then
    dnf install -y bind-utils iptables iproute || exit 1
elif command -v yum >/dev/null; then
    yum install -y bind-utils iptables iproute || exit 1
else
    echo 'Install host, iptables and ip manually.'; exit 1
fi
echo "Completed：依赖安装完毕"
echo ""

base=/etc/dnat
install -d -m 700 "$base"
conf=$base/conf
touch "$conf"
chmod 600 "$conf"


    [[ ! -t 1 ]] || clear
    echo "#############################################################"
    echo "# Usage: setup iptables nat rules for domian/ip             #"
    echo "# Website:  http://www.arloor.com/                          #"
    echo "# Author: ARLOOR <admin@arloor.com>                         #"
    echo "# Github: https://github.com/arloor/iptablesUtils           #"
    echo "#############################################################"
    echo


setupService(){
    cat > /usr/local/bin/dnat.sh <<"AAAA"
#! /bin/bash
[[ "$EUID" -ne '0' ]] && echo "Error:This script must be run as root!" && exit 1;



base=/etc/dnat
install -d -m 700 "$base"
conf=$base/conf
firstAfterBoot=1
lastConfig="/etc/dnat/iptables_nat.sh"
lastConfigTmp="/etc/dnat/iptables_nat.sh_tmp"


umask 077
####
turnOnNat(){
    # 开启端口转发
    echo "1. 端口转发开启  【成功】"
    sed -n '/^net.ipv4.ip_forward=1/'p /etc/sysctl.conf | grep -q "net.ipv4.ip_forward=1"
    if [ $? -ne 0 ]; then
        echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p
    fi

    # Use private chains; preserve Docker and administrator NAT/FORWARD rules.
    iptables -t nat -N JCNF_DNAT 2>/dev/null || true
    iptables -t nat -N JCNF_SNAT 2>/dev/null || true
    iptables -t nat -C PREROUTING -j JCNF_DNAT 2>/dev/null || iptables -t nat -A PREROUTING -j JCNF_DNAT
    iptables -t nat -C POSTROUTING -j JCNF_SNAT 2>/dev/null || iptables -t nat -A POSTROUTING -j JCNF_SNAT
    echo 'Ensure your firewall permits forwarding for the configured destinations.'

}
turnOnNat



testVars(){
    local localport=$1
    local remotehost=$2
    local remoteport=$3
    [[ $localport =~ ^[0-9]{1,5}$ && $remoteport =~ ^[0-9]{1,5}$ ]] || return 1
    (( 10#$localport >= 1 && 10#$localport <= 65535 && 10#$remoteport >= 1 && 10#$remoteport <= 65535 )) || return 1
    [[ $remotehost =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || return 1
    # 判断端口是否为数字
    local valid=
    echo "$localport"|[ -n "`sed -n '/^[0-9][0-9]*$/p'`" ] && echo $remoteport |[ -n "`sed -n '/^[0-9][0-9]*$/p'`" ]||{
       echo  -e "${red}本地端口和目标端口请输入数字！！${black}";
       return 1;
    }

    # 检查输入的不是IP
    #if [ "$(echo  $remotehost |grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}')" != "" ];then
     #   local isip=true
     #   local remote=$remotehost
#
 #       echo -e "${red}警告：你输入的目标地址是一个ip!${black}"
  #      return 2;
   # fi
}

dnat(){
     [ "$#" = "3" ]&&{
        local localport=$1
        local remote=$2
        local remoteport=$3

        cat >> $lastConfigTmp <<EOF
iptables -t nat -A JCNF_DNAT -p tcp --dport $localport -j DNAT --to-destination $remote:$remoteport
iptables -t nat -A JCNF_DNAT -p udp --dport $localport -j DNAT --to-destination $remote:$remoteport
iptables -t nat -A JCNF_SNAT -p tcp -d $remote --dport $remoteport -j MASQUERADE
iptables -t nat -A JCNF_SNAT -p udp -d $remote --dport $remoteport -j MASQUERADE
EOF
    }
}

dnatIfNeed(){
  [ "$#" = "3" ]&&{
    local needNat=0
    # 如果已经是ip
    if [ "$(echo  $2 |grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}')" != "" ];then
        local remote=$2
    else
        local remote=$(host -t a "$2"|grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -1)
    fi

    if [ "$remote" = "" ];then
            echo Warn:解析失败
          return 1;
     fi
  }||{
      echo "Error: host命令缺失或传递的参数数量有误"
      return 1;
  }
    echo $remote >$base/${1}IP
    dnat $1 $remote $3
}


echo "3. 开始监听域名解析变化"
echo ""
while true ;
do
## 获取本机地址
localIP=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1 | grep -Ev '(^127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.1[6-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.2[0-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.3[0-1]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^192\.168\.[0-9]{1,3}\.[0-9]{1,3}$)')
if [ "${localIP}" = "" ]; then
        localIP=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1|head -n 1 )
fi
echo  "本机网卡IP [$localIP]"
cat > $lastConfigTmp <<EOF
iptables -t nat -F JCNF_DNAT
iptables -t nat -F JCNF_SNAT
EOF
arr1=(`cat $conf`)
for cell in ${arr1[@]}
do
    arr2=(`echo $cell|tr ":" " "|tr ">" " "`)  #arr2=16 REJECT 0.0.0.0/0
    # 过滤非法的行
    [ "${arr2[2]}" != "" -a "${arr2[3]}" = "" ]&& testVars ${arr2[0]}  ${arr2[1]} ${arr2[2]}&&{
        echo "转发规则： ${arr2[0]} => ${arr2[1]}:${arr2[2]}"
        dnatIfNeed ${arr2[0]} ${arr2[1]} ${arr2[2]}
    }
done

lastConfigTmpStr=`cat $lastConfigTmp`
lastConfigStr=$(cat "$lastConfig" 2>/dev/null || true)
if [ "$firstAfterBoot" = "1" -o "$lastConfigTmpStr" != "$lastConfigStr" ];then
    echo '更新iptables规则[DOING]'
    source $lastConfigTmp
    cat $lastConfigTmp > $lastConfig
    echo '更新iptables规则[DONE]，新规则如下：'
    echo "###########################################################"
    iptables -L PREROUTING -n -t nat --line-number
    iptables -L POSTROUTING -n -t nat --line-number
    echo "###########################################################"
else
 echo "iptables规则未变更"
fi

firstAfterBoot=0
echo '' > $lastConfigTmp
sleep 60
echo ''
echo ''
echo ''
done
AAAA
echo


cat > /lib/systemd/system/dnat.service <<\EOF
[Unit]
Description=动态设置iptables转发规则
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=/root/
ExecStart=/bin/bash /usr/local/bin/dnat.sh
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable dnat > /dev/null 2>&1
service dnat stop > /dev/null 2>&1
service dnat start > /dev/null 2>&1
}


## 获取本机地址
localIP=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1 | grep -Ev '(^127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.1[6-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.2[0-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.3[0-1]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^192\.168\.[0-9]{1,3}\.[0-9]{1,3}$)')
if [ "${localIP}" = "" ]; then
        localIP=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1|head -n 1 )
fi


addDnat(){
    local localport=
    local remoteport=
    local remotehost=
    local valid=
    echo -n "本地端口号:" ;read -r localport
    echo -n "远程端口号:" ;read -r remoteport
    # echo $localport $remoteport
    [[ $localport =~ ^[0-9]{1,5}$ && $remoteport =~ ^[0-9]{1,5}$ ]] || return 1
    (( 10#$localport >= 1 && 10#$localport <= 65535 && 10#$remoteport >= 1 && 10#$remoteport <= 65535 )) || return 1
    # 判断端口是否为数字
    echo "$localport"|[ -n "`sed -n '/^[0-9][0-9]*$/p'`" ] && echo $remoteport |[ -n "`sed -n '/^[0-9][0-9]*$/p'`" ]||{
        echo  -e "${red}本地端口和目标端口请输入数字！！${black}"
        return 1;
    }

    echo -n "目标域名/IP:" ;read -r remotehost
    [[ $remotehost =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || return 1
    # # 检查输入的不是IP
    # if [ "$remotehost" = "" -o "$(echo  $remotehost |grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}')" != "" ];then
    #     isip=true
    #     remote=$remotehost
    #     echo -e "${red}请输入一个ddns域名${black}"
    #     return 1
    # fi

    sed -i "s/^$localport>.*/$localport>$remotehost:$remoteport/g" $conf
    [ "$(cat $conf|grep "$localport>$remotehost:$remoteport")" = "" ]&&{
            cat >> $conf <<LINE
$localport>$remotehost:$remoteport
LINE
    }
    echo "成功添加转发规则 $localport>$remotehost:$remoteport"
    setupService
}

rmDnat(){
    local localport=
    echo -n "本地端口号:" ;read -r localport
    [[ $localport =~ ^[0-9]{1,5}$ ]] || return 1
    sed -i "/^$localport>.*/d" $conf
    echo "done!"
}

testVars(){
    local localport=$1
    local remotehost=$2
    local remoteport=$3
    [[ $localport =~ ^[0-9]{1,5}$ && $remoteport =~ ^[0-9]{1,5}$ ]] || return 1
    (( 10#$localport >= 1 && 10#$localport <= 65535 && 10#$remoteport >= 1 && 10#$remoteport <= 65535 )) || return 1
    [[ $remotehost =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || return 1
    # 判断端口是否为数字
    local valid=
    echo "$localport"|[ -n "`sed -n '/^[0-9][0-9]*$/p'`" ] && echo $remoteport |[ -n "`sed -n '/^[0-9][0-9]*$/p'`" ]||{
       # echo  -e "${red}本地端口和目标端口请输入数字！！${black}";
       return 1;
    }

    # # 检查输入的不是IP
    # if [ "$(echo  $remotehost |grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}')" != "" ];then
    #     local isip=true
    #     local remote=$remotehost

    #     # echo -e "${red}警告：你输入的目标地址是一个ip!${black}"
    #     return 2;
    # fi
}

lsDnat(){
    arr1=(`cat $conf`)
for cell in ${arr1[@]}
do
    arr2=(`echo $cell|tr ":" " "|tr ">" " "`)  #arr2=16 REJECT 0.0.0.0/0
    # 过滤非法的行
    [ "${arr2[2]}" != "" -a "${arr2[3]}" = "" ]&& testVars ${arr2[0]}  ${arr2[1]} ${arr2[2]}&&{
        echo "转发规则： ${arr2[0]}>${arr2[1]}:${arr2[2]}"
    }
done
}




echo  -e "${red}你要做什么呢（请输入数字）？Ctrl+C 退出本脚本${black}"
select todo in 增加转发规则 删除转发规则 列出所有转发规则 查看当前iptables配置
do
    case $todo in
    增加转发规则)
        addDnat
        #break
        ;;
    删除转发规则)
        rmDnat
        #break
        ;;
    # 增加到IP的转发)
    #     addSnat
    #     #break
    #     ;;
    # 删除到IP的转发)
    #     rmSnat
    #     #break
    #     ;;
    列出所有转发规则)
        lsDnat
        ;;
    查看当前iptables配置)
        echo "###########################################################"
        iptables -L PREROUTING -n -t nat --line-number
        iptables -L POSTROUTING -n -t nat --line-number
        echo "###########################################################"
        ;;
    *)
        echo "如果要退出，请按Ctrl+C"
        ;;
    esac
done
