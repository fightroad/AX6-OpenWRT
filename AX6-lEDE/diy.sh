#!/bin/bash
# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Add packages
#添加科学上网源
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall-packages
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/openwrt-passwall
git clone -b 18.06 --single-branch --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone -b 18.06 --single-branch --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
#git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddnsgo
#git clone -b v5-lua --single-branch --depth 1 https://github.com/sbwml/luci-app-mosdns package/mosdns
#git clone -b v3.35.0 --single-branch --depth 1 https://github.com/sbwml/luci-app-alist package/alist
#git clone --depth=1 https://github.com/sirpdboy/luci-app-lucky package/lucky
#git clone --depth=1 https://github.com/sirpdboy/NetSpeedTest package/NetSpeedTest
#git clone --depth=1 https://github.com/sirpdboy/NetSpeedTest package/NetSpeedTest
#git clone --depth=1 https://github.com/0x676e67/luci-theme-design package/luci-theme-design
#git clone --depth=1 https://github.com/0x676e67/luci-app-design-config package/luci-app-design-config

#添加自定义的软件包源
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-theme-design
#git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-design-config


# Remove packages
#删除lean库中的插件，使用自定义源中的包。
#rm -rf feeds/packages/net/v2ray-geodata
#rm -rf feeds/packages/utils/v2dat
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
#rm -rf feeds/packages/net/mosdns
#rm -rf feeds/luci/applications/luci-app-mosdns
#rm -rf feeds/luci/themes/luci-theme-design
#rm -rf feeds/luci/applications/luci-app-design-config

# Default IP
#sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 修改主机名
#sed -i "s/hostname='OpenWrt'/hostname='Redmi-AX6'/g" package/base-files/files/bin/config_generate
sed -i "s/hostname='OpenWrt'/hostname='RT-HOME'/g" package/base-files/files/bin/config_generate

#修改默认时间格式
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $(find ./package/*/autocore/files/ -type f -name "index.htm")
