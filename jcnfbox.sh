#! /bin/bash
# By jcnf

#颜色
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

#服务器检查项目
#Lemonbench 综合测试
function Lemonbench(){
curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
}

#三网Speedtest测速
function 3speed(){
bash <(curl -Lso- https://raw.githubusercontent.com/BlueSkyXN/SpeedTestCN/main/superspeed.sh)
}

#Memorytest 内存压力测试
function memorytest(){
yum install wget -y
yum groupinstall "Development Tools" -y
wget https://raw.githubusercontent.com/FunctionClub/Memtester/master/memtester.cpp
blue "下载完成"
gcc -l stdc++ memtester.cpp
./a.out
}

#Route-trace 回城路由追踪
function rtsh(){
wget -O "/root/jcnf.sh" "https://raw.githubusercontent.com/Netflixxp/jcnfbesttrace/main/jcnf.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/jcnf.sh"
chmod 777 "/root/jcnf.sh"
yellow "下载完成,之后可执行 bash /root/jcnf.sh 再次运行"
bash "/root/jcnf.sh"
}

#Speedtest for Linux·下载
function speedtest-linux(){
wget -O "/root/speedtest" "https://raw.githubusercontent.com/Netflixxp/jcnf-box/master/sh/speedtest" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/speedtest"
chmod 777 "/root/speedtest"
yellow "下载完成,之后可执行 bash /root/speedtest 再次运行"
./speedtest
}

#获取本机IP
function getip(){
echo  
curl ip.p3terx.com
echo
}

#nf.sh 流媒体解锁测试
function nf(){
        #安装JQ
	if [ -e "/etc/redhat-release" ];then
	yum install epel-release -y -q > /dev/null;
	yum install jq -y -q > /dev/null;
	elif [[ $(cat /etc/os-release | grep '^ID=') =~ ubuntu ]] || [[ $(cat /etc/os-release | grep '^ID=') =~ debian ]];then
	apt-get update -y > /dev/null;
	apt-get install jq > /dev/null;
	else 
	echo -e "${Font_Red}请手动安装jq${Font_Suffix}";
	exit;
	fi
        jq -V > /dev/null 2>&1;
        if [ $? -ne 0 ];then
	echo -e "${Font_Red}请手动安装jq${Font_Suffix}";
	exit;
        fi
bash <(curl -sSL https://raw.githubusercontent.com/Netflixxp/NF/main/nf.sh)
}

#检测/诊断Youtube地域
function tubecheck(){
wget -O "/root/tubecheck" "https://cdn.jsdelivr.net/gh/sjlleo/TubeCheck/CDN/tubecheck_1.0beta_linux_amd64" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/tubecheck"
chmod 777 "/root/tubecheck"
yellow "下载完成,之后可执行 ./tubecheck 再次运行"
./tubecheck
}

#服务器功能调试
#ChangeSource Linux换源脚本·下载
function cssh(){
wget -O "/root/changesource.sh" "https://raw.githubusercontent.com/Netflixxp/jcnf-box/master/sh/changesource.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/changesource.sh"
chmod 777 "/root/changesource.sh"
yellow "下载完成"
echo
green "请自行输入下面命令切换对应源"
green " =================================================="
echo
green " bash changesource.sh 切换推荐源 "
green " bash changesource.sh cn  切换中科大源 "
green " bash changesource.sh aliyun 切换阿里源 "
green " bash changesource.sh 163 切换网易源 "
green " bash changesource.sh aws 切换AWS亚马逊云源 "
green " bash changesource.sh restore 还原默认源 "
}

#IPV.SH ipv4/6优先级调整
function ipvsh(){
wget -O "/root/ipv4.sh" "https://raw.githubusercontent.com/Netflixxp/jcnf-box/master/sh/ipv4.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/ipv4.sh"
chmod 777 "/root/ipv4.sh"
yellow "下载完成,之后可执行 bash /root/ipv4.sh 再次运行"
bash "/root/ipv4.sh"
}

#SWAP一键安装/卸载脚本
function swapsh(){
wget -O "/root/swap.sh" "https://raw.githubusercontent.com/Netflixxp/jcnf-box/master/sh/swap.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/swap.sh"
chmod 777 "/root/swap.sh"
yellow "下载完成,你也可以输入 bash /root/swap.sh 来手动运行"
bash "/root/swap.sh"
}

#安装BBR
function bbr(){
wget -O "/root/tcp.sh" "https://github.000060000.xyz/tcp.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/tcp.sh"
chmod 777 "/root/tcp.sh"
yellow "下载完成,你也可以输入 bash /root/tcp.sh 来手动运行"
bash "/root/tcp.sh"
}

#系统网络配置优化
function system-best(){
	sed -i '/net.ipv4.tcp_retries2/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_slow_start_after_idle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fastopen/d' /etc/sysctl.conf
	sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf

echo "net.ipv4.tcp_retries2 = 8
net.ipv4.tcp_slow_start_after_idle = 0
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
#net.ipv4.ip_forward = 1">>/etc/sysctl.conf
sysctl -p
	echo "*               soft    nofile           1000000
*               hard    nofile          1000000">/etc/security/limits.conf
	echo "ulimit -SHn 1000000">>/etc/profile
	read -p "需要重启VPS后，才能生效系统优化配置，是否现在重启 ? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} VPS 重启中..."
		reboot
	fi
}

#宝塔面板 官方版·一键安装
function btnew(){
wget -O "/root/install.sh" "http://download.bt.cn/install/install_6.0.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/install.sh"
chmod 777 "/root/install.sh"
blue "下载完成"
bash "/root/install.sh"
}

#宝塔面板英文官方版·一键安装
function aaPanel(){
wget -O "/root/aaPanel.sh" "http://www.aapanel.com/script/install_6.0_en.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/aaPanel.sh"
chmod 777 "/root/aaPanel.sh"
blue "下载完成"
bash "/root/aaPanel.sh"
}

#宝塔面板破解版·一键安装
function btpj(){
wget -O "/root/btpj.sh" "http://download.hostcli.com/install/install_6.0.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/btpj.sh"
chmod 777 "/root/btpj.sh"
blue "下载完成"
bash "/root/btpj.sh"
}

#科学上网工具
#iptables.sh iptable中转
function iptsh(){
wget -O "/root/iptables.sh" "https://raw.githubusercontent.com/Netflixxp/jcnf-box/main/sh/iptables.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/iptables.sh"
chmod 777 "/root/iptables.sh"
yellow "下载完成，你也可以输入 bash /root/iptables.sh 来手动运行"
bash "/root/iptables.sh"
}

#gost.sh gost一键中转
function gost(){
wget -O "/root/gost.sh" "https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/gost.sh"
chmod 777 "/root/gost.sh"
yellow "下载完成，你也可以输入 bash /root/gost.sh 来手动运行"
bash "/root/gost.sh"
}

#MTP&TLS 一键脚本
function mtp(){
wget -O "/root/mtp.sh" "https://raw.githubusercontent.com/sunpma/mtp/master/mtproxy.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/mtp.sh"
chmod 777 "/root/mtp.sh"
yellow "下载完成，你也可以输入 bash /root/mtp.sh 来手动运行"
bash "/root/mtp.sh"
}

#xray.sh xray一键安装8合一
function xray(){
wget -O "/root/xray.sh" "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/xray.sh"
chmod 777 "/root/xray.sh"
yellow "下载完成，你也可以输入 bash /root/xray.sh 来手动运行"
bash "/root/xray.sh"
}

#wulabing.sh wulabingxray安装脚本
function wulabing(){
wget -O "/root/wulabing.sh" "https://raw.githubusercontent.com/wulabing/Xray_onekey/main/install.sh" --no-check-certificate -T 30 -t 5 -d
chmod +x "/root/wulabing.sh"
chmod 777 "/root/wulabing.sh"
yellow "下载完成，你也可以输入 bash /root/wulabing.sh 来手动运行"
bash "/root/wulabing.sh"
}

#v2-ui.sh 一键安装
function v2-ui(){
bash <(curl -Ls https://blog.sprov.xyz/v2-ui.sh)
}

# Cloudflare WARP 一键配置脚本
function WARP(){
bash <(curl -fsSL git.io/warp.sh) menu
}

# Ehcoo隧道中转
function ehco(){
bash <(curl -fsSL https://leo.moe/ehco.sh)
}

#主菜单
function start_menu(){
    clear
    red " jcnf 常用脚本包" 
    green " https://github.com/Netflixxp/jcnf-box "
    green " 博客 https://ybfl.xyz "
	green " TG频道 https://t.me/mffjc "
	
	yellow " =======服务器检查============================== "
    green " 1. Lemonbench 综合测试 "
    green " 2. 三网Speedtest测速"
    green " 3. 内存压力测试"
    green " 4. 回程路由追踪" 
    green " 5. Speedtest测速"
    green " 6. 获取本机IP"
    green " 7. 流媒体解锁测试"
	green " 8. 检测/诊断Youtube地域"
	
    yellow " =======服务器功能============================== "
    green " 11. Linux换源脚本"
    green " 12. ipv4/6优先级调整 " 
    green " 13. 虚拟内存SWAP一键安装 "
    green " 14. 一键安装BBR "
    green " 15. 系统网络配置优化 "
    green " 16. 宝塔中文官方一键安装 "
	green " 17. 宝塔英文官方一键安装（无需验证） "
	green " 18. 宝塔面板破解纯净版 "
	green " 19. Cloudflare WARP 一键配置脚本 "

    yellow " =======科学上网工具============================ "
    green " 21. iptables一键中转 "
    green " 22. gost一键中转 "
    green " 23. MTP&TLS 一键脚本 "
    green " 24. xray一键安装8合一脚本 "
    green " 25. v2-ui一键安装 "
	green " 26. wulabing一键xray脚本 "
	green " 27. Ehcoo隧道中转 "
	
    yellow " =============================================== "
    green " 0. 退出脚本"
    echo
    read -p "请输入数字:" menuNumberInput
    case "$menuNumberInput" in
        1 )
           Lemonbench
	;;
        2 )
           3speed
	;;
        3 )
           memorytest
	;;
        4 )
           rtsh
	;;
        5 )
           speedtest-linux
	;;
	    6 )
           getip
	;;
	    7 )
           nf
	;;
		8 )
           tubecheck
	;;
		11 )
           cssh
	;;
		12 )
           ipvsh
	;;
		13 )
           swapsh
	;;
		14 )
           bbr
	;;
		15 )
           system-best
	;;
		16 )
           btnew
	;;
		17 )
           aaPanel
	;;
		18 )
           btpj
	;;
		19 )
           WARP
	;;
		21 )
           iptsh
	;;
		22 )
           gost
	;;
		23 )
           mtp
	;;
		24 )
           xray
	;;
		25 )
           v2-ui
	;;
		26 )
           wulabing
	;;
		27 )
           ehco
	;;
        0 )
            exit 1
        ;;
        * )
            clear
            red "请输入正确数字 !"
            start_menu
        ;;
    esac
}


start_menu "first"
