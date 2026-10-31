# 2026-10-31 维护记录

本次检查包含仓库全部 6 个 Shell 文件（双语入口和 4 个辅助脚本）、菜单中远程脚本的 HTTP/内容检查，以及离线回归。没有在真实 VPS 上执行安装、测速、压力测试、换源、内核、面板或防火墙操作。链接可下载不代表第三方脚本在所有系统上都能安装成功。

## 逐项处理

| 选项 | 检查结果与更新 |
| --- | --- |
| 1 LemonBench | 旧域名本次无法解析；改为上游 GitHub `LemonBench.sh -f` |
| 2 三网测速 | 入口仍可访问；增加完整下载、失败退出及 Bash 语法检查 |
| 3 内存测试 | 移除 yum-only 编译和相对路径运行；改用系统 memtester，输入测试大小和次数 |
| 4 路由追踪 | 原脚本 404；改用发行版 traceroute，用户输入目标。不是原来的自动三网回程测试 |
| 5 Speedtest | 移除仓库内旧 amd64 程序的调用和下载/运行路径不一致；运行已安装的 `speedtest`，缺少时显示 Ookla 官方安装地址 |
| 6 本机 IP | 使用 HTTPS、超时和 HTTP 错误检测 |
| 7 流媒体 | 改为 RegionRestrictionCheck 上游入口；不再在入口里重复安装 jq |
| 8 YouTube | 使用选项 7 的综合检测，移除固定 amd64 beta 程序 |
| 11 换源 | 重写；支持 Debian/Ubuntu 的 sources.list 和 deb822 `.sources`，保留系统代号、组件和第三方源；支持中科大/阿里云及恢复。其他系统拒绝修改 |
| 12 IP 优先级 | 修复 IPv6 只设置 6to4 label 的错误；备份原文件，使用完整 precedence 表，可恢复 |
| 13 SWAP | 验证大小、防止覆盖已有文件、创建失败停止、只停用 /swapfile；swapoff 失败不删文件或 fstab |
| 14 BBR | 不再下载第三方域名内核脚本；检查当前内核 BBR，写独立 sysctl 文件，不更换内核、不自动重启 |
| 15 网络优化 | 停用覆盖 limits.conf、追加 profile 和修改全局网络设置的旧功能，保留说明 |
| 16 宝塔 | 更新到官方 HTTPS install_panel.sh |
| 17 aaPanel | 更新到官方 HTTPS install_7.0_en.sh，移除“无需验证”的保证 |
| 18 旧宝塔 | 停用旧 7.7 第三方安装器，保留迁移说明 |
| 19 WARP | 改为作者目前的 GitLab 地址，不再依赖 git.io 短链 |
| 21 iptables | 使用 JCNF_DNAT/JCNF_SNAT 独立链，不清空公共 NAT 链或修改 FORWARD 默认策略；端口及主机名校验；MASQUERADE 支持 NAT VPS；选择正确包管理器 |
| 22 gost | 上游入口可访问；统一下载失败处理 |
| 23 MTProxy | 上游入口可访问；统一下载失败处理 |
| 24 Xray | 上游入口可访问；统一下载失败处理 |
| 25 v2-ui | 旧域名 TLS 错误；替换为 3x-ui。属于新面板安装，**不会迁移旧 v2-ui 数据** |
| 26 wulabing | 上游入口可访问；统一下载失败处理。未承诺现代发行版兼容性 |
| 27 Ehco | 旧域名本次无法解析；停止执行，显示上游项目地址，尚未提供替代一键安装 |

## 通用修复

- 双语入口同步修改；退出返回 0，输入结束正常退出，无效输入不递归。
- 远程脚本使用私有临时文件；HTTPS 与重定向均校验证书；下载失败、空响应或语法错误时不执行；执行后删除临时文件，保留退出状态和参数。
- 移除入口中的 `chmod 777`、关闭证书校验、持久化 /root 临时安装器及下载后无条件执行。
- 从完整 checkout 运行时优先执行同一 checkout 的辅助脚本；单文件模式从 `JCNF_BOX_REF`（默认 main）获取。
- 添加 LF 行尾规则、离线 CI 与每周远程入口巡检。

## 验证与限制

`bash tests/smoke.sh`：6 个 Shell 文件语法、两个菜单退出/EOF、下载失败不执行、HTML 拒绝、参数与退出码传递、换源规则 fixture、禁止全局 NAT flush / swapoff -a；通过。

`python tests/check_urls.py`：菜单直接引用的 11 个外部脚本入口均能通过 HTTPS 获取非空且非 HTML 的响应。仓库辅助脚本另做语法检查；检查时线上仍为旧版，须合并本次更新后才会替换。

本地环境是 Windows/Git Bash；Linux root 操作尚需在可丢弃 VPS/虚拟机上验证。尤其需要验证 Debian/Ubuntu 的实际 apt update、BBR 内核支持、IPv6 地址排序、低内存 swapoff 失败、systemd 服务、iptables/nft 后端与已有 Docker/防火墙规则共存。

iptables 不会替管理员打开全部 FORWARD 流量，需要已有防火墙允许对应转发。老版本部署留下的全局规则不会被自动删除；升级前请备份 `iptables-save`，核对旧 dnat 服务与现存规则。当前仍不是 IPv6 转发工具。

换源备份保存在 `/var/backups/jcnf-sources/original`，恢复会覆盖备份中同名源文件。发行版已停止支持的问题不会通过换镜像解决；需要先升级系统。旧 163/AWS 参数不再支持。

入口仍会调用由第三方维护的可变脚本；HTTP/语法检查不能验证其后续下载、安装效果或安全性。每周巡检失败只显示为 Actions 失败，不会自动改代码。
