include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ranga-mt7620
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_KCONFIG := RANGA_MTK_RT2860_LED_SYSFS
PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))

include $(INCLUDE_DIR)/package.mk

#DEPENDS:=+wireless-tools
define KernelPackage/ranga-mt7620
  SECTION:=ranga
  CATEGORY:=NSWA Ranga
  DEPENDS:=+ranga-mtk
  TITLE:=MT7620 2.4GHz radio proprietary driver
endef

define KernelPackage/ranga-mt7620/description
  install MT7620A/N on-chip 2.4GHz radio device proprietary driver binaries from MTK.
endef

define KernelPackage/ranga-mt7620/config
	source "$(SOURCE)/Config.in"
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -r ./rt2860v2 $(PKG_BUILD_DIR)
	$(Build/Patch)
endef

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	LINUX_DIR="$(LINUX_DIR)"

define Build/Compile
	$(MAKE) -C "$(PKG_BUILD_DIR)/rt2860v2" $(MAKE_OPTS)
endef

define KernelPackage/ranga-mt7620/install
	cp -r ./files/. $(1)/
	ln -s /tmp/RT2860.dat $(1)/etc/Wireless/RT2860/RT2860.dat
	$(INSTALL_BIN) "$(PKG_BUILD_DIR)/rt2860v2/rt2860v2_ap.ko" $(1)/lib/mtkdrv/
	../ledtool.sh $(CONFIG_RANGA_MTK_RT2860_LED_SYSFS) $(1)/lib/mtkdrv/rt2860/led
endef

$(eval $(call KernelPackage,ranga-mt7620))
