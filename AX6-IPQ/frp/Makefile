# SPDX-License-Identifier: GPL-2.0-only
#
# Use official frp release binaries instead of building from source.
# ImmortalWrt's source build needs node/host for WebUI and often fails in CI.
# Keep ImmortalWrt's ./files (init/uci) so luci-app-frpc works unchanged.

include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.71.0
PKG_RELEASE:=1

PKG_MAINTAINER:=
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

ifeq ($(ARCH),x86_64)
  PKG_ARCH:=amd64
  PKG_HASH:=84f27e39f11169f7adcef8e8b70c9329de17747b1f14dad9fb95eef5682ea716
else ifeq ($(ARCH),aarch64)
  PKG_ARCH:=arm64
  PKG_HASH:=f33c293c275d8fc68c654b6fba8f10b2551d6463d09a9fc9cffb7227eae82266
else ifeq ($(ARCH),arm)
  PKG_ARCH:=arm
  PKG_HASH:=f40a984f83e8d34a9241b0be4a9d5fbcfe513a4a5c022b84a02637ff6d36833b
else ifeq ($(ARCH),mipsel)
  PKG_ARCH:=mipsle
  PKG_HASH:=14498e36554a275a9d41a61aa29680616a34c7c9d8914e2173a46dada4928c70
else ifeq ($(ARCH),mips)
  PKG_ARCH:=mips
  PKG_HASH:=dd3fb404b546f215848db466c5707f501bcc2e24f605228f52e2a1546904a29d
else ifeq ($(ARCH),riscv64)
  PKG_ARCH:=riscv64
  PKG_HASH:=92b48d5e4d44d2f1415fde24489d3dfff5badbd52ddf7e816467cdcaa973aa5c
endif

PKG_SOURCE:=frp_$(PKG_VERSION)_linux_$(PKG_ARCH).tar.gz
PKG_SOURCE_URL:=https://github.com/fatedier/frp/releases/download/v$(PKG_VERSION)/
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	tar -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components=1
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/frp/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/frp/$(2).d/
	$(INSTALL_DIR) $(1)/etc/init.d/

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(2) $(1)/usr/bin/
	$(INSTALL_CONF) ./files/$(2).config $(1)/etc/config/$(2)
	$(INSTALL_BIN) ./files/$(2).init $(1)/etc/init.d/$(2)

	if [ -r ./files/$(2).uci-defaults ]; then \
		$(INSTALL_DIR) $(1)/etc/uci-defaults; \
		$(INSTALL_DATA) ./files/$(2).uci-defaults $(1)/etc/uci-defaults/$(2); \
	fi
endef

define Package/frp/template
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=$(1) - fast reverse proxy $(2)
    URL:=https://github.com/fatedier/frp
    DEPENDS:=@(aarch64||arm||mips||mipsel||x86_64||riscv64)
  endef

  define Package/$(1)/description
    $(1) from official frp release binaries (includes WebUI assets).
    Compatible with ImmortalWrt luci-app-frpc / luci-app-frps.
  endef

  define Package/$(1)/conffiles
/etc/config/$(1)
/etc/frp/$(1).d/
  endef

  define Package/$(1)/install
    $(call Package/frp/install,$$(1),$(1))
  endef
endef

$(eval $(call Package/frp/template,frpc,client))
$(eval $(call Package/frp/template,frps,server))
$(eval $(call BuildPackage,frpc))
$(eval $(call BuildPackage,frps))
