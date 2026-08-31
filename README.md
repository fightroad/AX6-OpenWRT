### 自用 Redmi AX6（大分区）一键编译

基于 [VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt.git) `main`，目标机型 **redmi_ax6-stock**，带 NSS 加速。

## Workflows

| Workflow | 说明 |
|----------|------|
| **AX6-IPQ Config** | 同步/编辑 `.config`（可选 SSH menuconfig） |
| **Build OpenWRT for AX6-NSS** | 云编译固件 |

配置目录：`AX6-IPQ/`（`.config`、`diy.sh`、`files/`）

## 注意

- NSS 加速默认开启，**不要**在防火墙里额外打开系统硬件/软件卸载加速，容易冲突。
- 大流量时 CPU 占用很低，说明 NSS 在起作用。
- 固件使用 **apk** 包管理器；插件建议在编译时勾选打进固件，自编译内核不建议依赖官方在线源装 kmod。

家用日常使用稳定运行 100+ 天，开梯子内存剩余约 100MB。

![image](https://github.com/user-attachments/assets/89a32e90-f5e1-4f46-9d54-9ba8c6e85f9e)
![微信截图_20241116071804](https://github.com/user-attachments/assets/502012e5-83d0-4e4b-be8b-a53c1edd0f8b)
