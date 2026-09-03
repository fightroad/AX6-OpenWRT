### 自用 Redmi AX6（大分区）一键编译

基于 [VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt.git) `main`，目标机型 **redmi_ax6-stock**，带 NSS 加速。

## Workflows

| Workflow | 说明 |
|----------|------|
| **AX6-IPQ Config** | 同步/编辑 `.config`（可选 SSH menuconfig） |
| **Build OpenWRT for AX6-NSS** | 云编译固件 |

配置目录：`AX6-IPQ/`（`.config`、`diy.sh`、`files/`）

## 使用流程

1. **（可选）修改配置**
   - 直接使用仓库内现成的 `AX6-IPQ/.config` 即可编译，无需改动。
   - 需要调整插件或内核选项时：
     - 本地编辑 `AX6-IPQ/.config` 后提交；或
     - 运行 **AX6-IPQ Config**，勾选 **SSH 进入 menuconfig**，通过 FRP 连入 Actions 执行 `make menuconfig`（见下方 FRP 配置）。
2. 编译固件：运行 **Build OpenWRT for AX6-NSS**
3. 在仓库 **Releases** 页面下载最新固件，刷入 **redmi_ax6-stock（大分区）** 机型

## FRP 配置（仅 SSH menuconfig 时需要）

使用 **AX6-IPQ Config** 的 SSH 模式前，需在仓库 **Settings → Secrets and variables → Actions** 中配置：

| 类型 | 名称 | 说明 |
|------|------|------|
| Variable | `FRP_SERVER_ADDR` | FRP 服务端地址（公网 IP 或域名） |
| Variable | `FRP_SERVER_PORT` | FRP 服务端端口 |
| Variable | `FRP_REMOTE_PORT` | 映射到 Runner SSH 的远程端口 |
| Secret | `FRP_TOKEN` | FRP 认证 token |

需自行部署 [frp](https://github.com/fatedier/frp) 服务端；Workflow 日志中会输出 SSH 连接地址、端口和临时密码。

## 注意

- NSS 加速默认开启，**不要**在防火墙里额外打开系统硬件/软件流量分载，容易冲突。
- 大流量时 CPU 占用很低，说明 NSS 在起作用。
- 固件使用 **opkg** 包管理器；Passwall、OpenClash 等插件建议在编译时勾选打进固件。
- 自编译固件（自定义内核/NSS）**不建议**使用官方在线源安装 kmod 等内核相关包，容易 ABI 不匹配。

## opkg 软件源

若 **更新列表** 提示 `Signature check failed`：进入 **系统 → 软件包 → 配置**，注释或删除 `option check_signature` 后重试。

关闭签名校验有安全风险；不要用在线源安装 kmod，PassWall 等已编入固件的包勿用 opkg 覆盖升级。


![image](https://github.com/user-attachments/assets/89a32e90-f5e1-4f46-9d54-9ba8c6e85f9e)
![微信截图_20241116071804](https://github.com/user-attachments/assets/502012e5-83d0-4e4b-be8b-a53c1edd0f8b)
