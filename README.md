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


# 功能列表

菜单编号沿用旧版，以下为 `main` 分支在 **2026-10-31** 更新后的功能。表中的“已更新”表示代码或入口已调整，不代表已经完成真实 VPS 安装测试。

## 服务器检查

| 编号 | 功能 | 当前实现与说明 |
| --- | --- | --- |
| 1 | LemonBench 综合测试 | 已更新为上游 GitHub 脚本，执行快速测试 |
| 2 | 三网测速 | 调用 SpeedTestCN；增加下载失败及语法检查 |
| 3 | 内存压力测试 | 使用系统 `memtester`，可输入测试内存大小与次数；缺少时通过 apt/dnf/yum 安装 |
| 4 | 路由追踪 | 使用 `traceroute`，手动输入目标 IP 或域名；替代失效的旧回程脚本 |
| 5 | Speedtest 测速 | 调用已安装的 `speedtest`；需先按 [Ookla 官方说明](https://www.speedtest.net/apps/cli) 安装对应架构客户端 |
| 6 | 获取本机公网 IP | 通过 HTTPS 查询，增加连接及请求超时 |
| 7 | 流媒体解锁检测 | 调用 RegionRestrictionCheck 综合检测脚本 |
| 8 | YouTube 地域检测 | 复用选项 7 的综合检测，不再下载固定 amd64 的旧 beta 程序 |

## 服务器功能

| 编号 | 功能 | 当前实现与说明 |
| --- | --- | --- |
| 11 | Linux 换源 | 支持 Debian/Ubuntu 的传统源和 deb822 源文件；保留发行版代号、组件与第三方源，提供中科大/阿里云及备份恢复；菜单默认中科大，其他模式见下方说明 |
| 12 | IPv4/IPv6 优先级 | 调整 glibc 地址优先级，支持备份与恢复；应用可能自行选择地址 |
| 13 | SWAP 管理 | 创建或删除 `/swapfile`；验证输入，失败时停止，只停用本工具管理的 swap 文件 |
| 14 | 启用 BBR | 检查当前内核是否支持 BBR，使用独立 sysctl 配置；不安装或更换内核 |
| 15 | 旧系统网络优化 | **已停用**；保留说明，避免覆盖系统限制和全局网络配置 |
| 16 | 宝塔中文面板 | 调用官方 HTTPS 安装脚本 |
| 17 | aaPanel 英文面板 | 调用官方 HTTPS 安装脚本 |
| 18 | 旧宝塔 7.7 安装 | **已停用**；建议使用选项 16 或 17 |
| 19 | Cloudflare WARP | 更新为作者的 GitLab 脚本入口 |

完整 checkout 下可运行 `bash sh/changesource.sh aliyun` 切换阿里云，或 `bash sh/changesource.sh restore` 恢复首次备份；其他系统不会执行换源。

## 代理与中转

| 编号 | 功能 | 当前实现与说明 |
| --- | --- | --- |
| 21 | iptables 中转 | 使用独立 NAT 链，校验端口及主机名，不清空公共 NAT 链；需要 systemd，现有防火墙需放行相应转发 |
| 22 | gost 中转 | 调用 Multi-EasyGost 上游脚本，统一下载失败处理 |
| 23 | MTProxy | 调用 MTP/TLS 上游脚本，统一下载失败处理 |
| 24 | Xray 综合安装 | 调用 v2ray-agent 上游安装脚本 |
| 25 | 3x-ui 面板 | 替代失效的 v2-ui 入口；**不会自动迁移旧面板数据** |
| 26 | wulabing Xray | 保留可访问的上游入口，增加下载检查；现代发行版兼容性仍待实机验证 |
| 27 | Ehco 安装指引 | **待恢复一键安装**；旧入口已失效，目前仅展示上游项目地址 |

选项 `0` 退出工具箱。涉及软件安装及系统配置的操作需要 root；第三方脚本的系统和架构支持范围以各上游项目为准。

完整 checkout 会优先使用本地 `sh/` 文件；单文件启动默认读取 main 分支。测试分支时可设置 `JCNF_BOX_REF=分支名`。

# 更新进度

最近更新：**2026-10-31**。第一轮维护已通过 [PR #6](https://github.com/Netflixxp/jcnf-box/pull/6) 合并至 `main`，原安装命令可获取新版。详细问题及功能变化见 [维护记录](MAINTENANCE.md)。

| 工作项 | 进度 | 说明 |
| --- | --- | --- |
| 仓库与菜单检查 | ✅ 已完成第一轮 | 检查双语入口、4 个辅助脚本及菜单远程入口，整理上述 24 项功能 |
| 失效入口处理 | ✅ 已完成第一轮 | 更新 LemonBench、流媒体、面板及 WARP 入口；替换旧路由实现；停用无法继续使用的旧入口 |
| 下载执行流程 | ✅ 已更新 | 使用 HTTPS 和私有临时文件；下载失败、空内容或 Bash 语法错误时不执行 |
| 系统配置脚本 | ✅ 已修复代码 | 更新换源、IP 优先级、SWAP、BBR 与 iptables；真实系统效果仍待下项验证 |
| 离线回归与 CI | ✅ 已通过 | 本地 Git Bash 及 [GitHub Ubuntu CI](https://github.com/Netflixxp/jcnf-box/actions/runs/41156165878) 通过；覆盖语法、菜单退出、下载失败处理与换源规则等 |
| 外部脚本入口检查 | ✅ 本轮通过 | 11 个直接外部脚本入口可获取 HTTPS 非空、非 HTML 响应；不代表其后续安装已验证 |
| 持续维护检查 | ✅ 已配置 | push/PR 运行离线检查；每周一巡检外部脚本入口，也可手动触发 Actions |
| Linux VPS 实机验证 | ⏳ 待完成 | 验证实际换源、SWAP、BBR、IPv6 排序、面板安装，以及 systemd/iptables/nft/Docker 共存 |
| Ehco 一键安装 | ⏳ 待恢复 | 需要确认和验证替代安装方案，目前保留上游指引 |
| 旧功能处置 | ℹ️ 已调整 | 15、18 停用；5 需预装官方客户端；8 复用综合检测；25 改为 3x-ui |

当前进度为“**首轮代码维护与自动检查完成，实机兼容性验证待完成**”。尚未验证的项目不标记为“全部可用”，后续完成验证后再更新进度。

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
