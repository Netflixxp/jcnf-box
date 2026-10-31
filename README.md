# jcnf 常用脚本工具包

2026-10-31 维护更新：修复失效入口、跨发行版依赖、下载失败仍执行、旧换源配置和全局 NAT 清空问题。详细结果及尚未实机验证的部分见 [维护记录](MAINTENANCE.md)。

建议在 Debian/Ubuntu 或使用 dnf/yum 的 Linux 上运行 Bash。换源目前只支持 Debian/Ubuntu；iptables 需要 systemd。涉及系统配置与安装的选项需要 root。

测速选项 5 需要先按 [Ookla 官方说明](https://www.speedtest.net/apps/cli) 安装当前架构的 Speedtest CLI。选项 15、18 已停用，27 提供安装指引；25 已替换为 3x-ui，不自动迁移旧面板。
玩机，是不是有很多命令或者脚本记不住，因此我整理了一些我个人常用的脚本。
***

# 使用说明
安装依赖（新机器必须运行一次，此后无需运行）

	apt-get update && apt-get install -y ca-certificates curl wget

RHEL 系列请使用 `dnf install -y ca-certificates curl wget`（旧系统使用 yum）。

安装并运行脚本

	wget -O jcnfbox.sh https://raw.githubusercontent.com/Netflixxp/jcnf-box/main/jcnfbox.sh && bash jcnfbox.sh
英文版，机器翻译English version

	wget -O jcnfbox-en.sh https://raw.githubusercontent.com/Netflixxp/jcnf-box/main/jcnfbox-en.sh && bash jcnfbox-en.sh
***


# 功能说明
菜单编号保持兼容，功能变更详见 [逐项处理表](MAINTENANCE.md)。

- 服务器检查：LemonBench、三网测速、memtester、traceroute、Speedtest、本机 IP、流媒体及 YouTube 检测。
- 系统功能：Debian/Ubuntu 换源（含 deb822）、IPv4/IPv6 优先级、SWAP、内核 BBR、官方宝塔/aaPanel、WARP。
- 代理与中转：iptables 独立链转发、gost、MTProxy、v2ray-agent、3x-ui、wulabing。

完整 checkout 会优先使用本地 `sh/` 文件；单文件启动默认读取 main 分支。测试分支时可设置 `JCNF_BOX_REF=分支名`。

# 维护检查

```bash
bash tests/smoke.sh             # 离线检查，不安装软件或修改系统
python3 tests/check_urls.py     # 仅访问远程入口，不执行脚本
```

推送与 PR 运行离线检查，每周一巡检远程入口。第三方安装脚本的实机兼容性不能仅凭链接正常来保证；本次未在真实 VPS 上执行 root 配置操作。

***

# 免责声明
* jcnfbox属于自用分享工具，请勿用于违背良知与道德之事，否则后果自负。
* 工具中所有脚本均来自互联网，不对脚本安全性负责。如果你比较在意安全，请勿使用各类一键脚本。
***

# 问题反馈
[TG频道](https://t.me/mffjc)
[TG群组](https://t.me/jcnfnatuo)
***

# [购买奈飞、YouTube正规合租车](https://jcnf.xyz/nf)
***

# [群友众筹公益机场](https://jcnf.xyz/jd)
***

# 感谢
 * [BlueSkyXN](https://github.com/BlueSkyXN/SKY-BOX)
 * [arloor](https://github.com/arloor/iptablesUtils)
 * [KANIKIG](https://github.com/KANIKIG/Multi-EasyGost)
 * [wulabing](https://github.com/wulabing/Xray_onekey)
 * [mack-a](https://github.com/mack-a/v2ray-agent)
