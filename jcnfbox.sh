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


# Download completely and validate Bash syntax before execution. Never run stale files.
run_remote() (
    local url=$1 script
    shift
    script=$(mktemp) || exit 1
    trap 'rm -f "$script"' EXIT
    command -v curl >/dev/null || { echo 'Install curl and ca-certificates first.' >&2; exit 1; }
    curl --proto '=https' --proto-redir '=https' -fSL --connect-timeout 15 --max-time 180 --retry 2 "$url" -o "$script" || exit 1
    [[ -s $script ]] && bash -n "$script" || { echo 'Invalid/empty Bash download.' >&2; exit 1; }
    bash "$script" "$@"
)
# Prefer files from this checkout, so a maintenance branch can be tested as a unit.
JCNF_BOX_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
run_bundled() {
    local name=$1
    if [[ -f $JCNF_BOX_DIR/sh/$name ]]; then
        bash "$JCNF_BOX_DIR/sh/$name"
    else
        run_remote "https://raw.githubusercontent.com/Netflixxp/jcnf-box/${JCNF_BOX_REF:-main}/sh/$name"
    fi
}
require_root() {
    [[ $EUID == 0 ]] || { echo 'Please run this operation as root.' >&2; return 1; }
}
install_packages() {
    require_root || return
    if command -v apt-get >/dev/null; then
        apt-get update && apt-get install -y "$@"
    elif command -v dnf >/dev/null; then
        dnf install -y "$@"
    elif command -v yum >/dev/null; then
        yum install -y "$@"
    else
        echo 'Unsupported package manager; install dependencies manually.' >&2
        return 1
    fi
}

#服务器检查项目
#Lemonbench 综合测试
function Lemonbench(){
run_remote https://raw.githubusercontent.com/LemonBench/LemonBench/main/LemonBench.sh -f
}

#三网Speedtest测速
function 3speed(){
run_remote https://raw.githubusercontent.com/BlueSkyXN/SpeedTestCN/main/superspeed.sh
}

#Memorytest 内存压力测试
function memorytest(){
command -v memtester >/dev/null || install_packages memtester || return
local size loops
read -r -p 'Memory to test in MiB (leave memory for the OS): ' size || return
read -r -p 'Number of passes [1]: ' loops || return
loops=${loops:-1}
[[ $size =~ ^[1-9][0-9]*$ && $loops =~ ^[1-9][0-9]*$ ]] || return 1
memtester "${size}M" "$loops"
}

#Route-trace 回城路由追踪
function rtsh(){
command -v traceroute >/dev/null || install_packages traceroute || return
local target
read -r -p 'Destination IP/domain: ' target || return
[[ $target =~ ^[a-zA-Z0-9][a-zA-Z0-9.:-]*$ ]] || return 1
traceroute "$target"
}

#Speedtest for Linux·下载
function speedtest-linux(){
if command -v speedtest >/dev/null; then
    speedtest
else
    echo 'Install the official Ookla Speedtest CLI for your architecture:'
    echo 'https://www.speedtest.net/apps/cli'
    return 1
fi
}

#获取本机IP
function getip(){
curl -fSL --connect-timeout 10 --max-time 30 https://api.ipify.org; echo
}

#nf.sh 流媒体解锁测试
function nf(){
run_remote https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh
}

#检测/诊断Youtube地域
function tubecheck(){
echo 'YouTube region is included in RegionRestrictionCheck.'
nf
}

#服务器功能调试
#ChangeSource Linux换源脚本·下载
function cssh(){
require_root && run_bundled changesource.sh
}

#IPV.SH ipv4/6优先级调整
function ipvsh(){
require_root && run_bundled ipv4.sh
}

#SWAP一键安装/卸载脚本
function swapsh(){
require_root && run_bundled swap.sh
}

#安装BBR
function bbr(){
require_root || return
modprobe tcp_bbr 2>/dev/null || true
grep -qw bbr /proc/sys/net/ipv4/tcp_available_congestion_control || { echo 'BBR is unavailable in this kernel.'; return 1; }
install -d -m 755 /etc/sysctl.d || return
printf '%s\n' 'net.core.default_qdisc = fq' 'net.ipv4.tcp_congestion_control = bbr' > /etc/sysctl.d/90-jcnf-bbr.conf || return
sysctl -p /etc/sysctl.d/90-jcnf-bbr.conf
}

#旧网络优化说明（已停用）
function system-best(){
echo 'Legacy blanket tuning retired: it overwrote limits.conf and unrelated settings.'
echo 'Use option 14 for kernel BBR; tune other settings for your workload.'
}

#宝塔面板 官方版·一键安装
function btnew(){
require_root && run_remote https://download.bt.cn/install/install_panel.sh
}

#宝塔面板英文官方版·一键安装
function aaPanel(){
require_root && run_remote https://www.aapanel.com/script/install_7.0_en.sh
}

#宝塔面板7.7·一键安装
function btpj(){
echo 'Legacy panel 7.7 installer retired. Use official options 16 or 17.'
}

#科学上网工具
#iptables.sh iptable中转
function iptsh(){
require_root && run_bundled iptables.sh
}

#gost.sh gost一键中转
function gost(){
require_root && run_remote https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.sh
}

#MTP&TLS 一键脚本
function mtp(){
require_root && run_remote https://raw.githubusercontent.com/sunpma/mtp/master/mtproxy.sh
}

#xray.sh xray一键安装8合一
function xray(){
require_root && run_remote https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh
}

#wulabing.sh wulabingxray安装脚本
function wulabing(){
require_root && run_remote https://raw.githubusercontent.com/wulabing/Xray_onekey/main/install.sh
}

#v2-ui.sh 一键安装
function v2-ui(){
require_root && run_remote https://raw.githubusercontent.com/MHSanaei/3x-ui/master/install.sh
}

# Cloudflare WARP 一键配置脚本
function WARP(){
require_root && run_remote https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh
}

# Ehco 安装说明
function ehco(){
echo 'Old installer is unavailable. See https://github.com/Ehco1996/ehco for current installation.'; return 1
}

#主菜单
function start_menu(){
    if [[ -t 1 ]]; then clear; fi
    red " jcnf 常用脚本包"
    green " https://github.com/Netflixxp/jcnf-box "
    green " 博客 https://ybfl.xyz "
	green " TG频道 https://t.me/mffjc "

	yellow " =======服务器检查============================== "
    green " 1. Lemonbench 综合测试 "
    green " 2. 三网Speedtest测速"
    green " 3. 内存压力测试"
    green " 4. 路由追踪（输入目标）"
    green " 5. Speedtest测速"
    green " 6. 获取本机IP"
    green " 7. 流媒体解锁测试"
	green " 8. 检测/诊断Youtube地域"

    yellow " =======服务器功能============================== "
    green " 11. Linux换源脚本"
    green " 12. ipv4/6优先级调整 "
    green " 13. 虚拟内存SWAP一键安装 "
    green " 14. 一键安装BBR "
    green " 15. 旧网络优化说明（已停用） "
    green " 16. 宝塔中文官方一键安装 "
	green " 17. aaPanel 官方安装 "
	green " 18. 旧宝塔 7.7 说明（已停用） "
	green " 19. Cloudflare WARP 一键配置脚本 "

    yellow " =======科学上网工具============================ "
    green " 21. iptables一键中转 "
    green " 22. gost一键中转 "
    green " 23. MTP&TLS 一键脚本 "
    green " 24. xray一键安装8合一脚本 "
    green " 25. 3x-ui 安装（替代 v2-ui） "
	green " 26. wulabing一键xray脚本 "
	green " 27. Ehco 安装说明 "

    yellow " =============================================== "
    green " 0. 退出脚本"
    echo
    read -r -p "请输入数字:" menuNumberInput || return 0
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
            return 0
        ;;
        * )
            clear
            red "请输入正确数字 !"
            return 2
        ;;
    esac
}


if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    start_menu
fi
