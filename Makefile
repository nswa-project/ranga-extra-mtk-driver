include $(TOPDIR)/rules.mk

PKG_NAME:=ranga-mtk
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/ranga-mtk
  SECTION:=ranga
  CATEGORY:=NSWA Ranga
  DEPENDS:=
  TITLE:=NSWA MTK driver firmwork
endef

define Package/ranga-mtk/description
  Ranga MTK driver firmwork
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	true
endef

define Package/ranga-mtk/install
	cp -r ./files/. $(1)/
	true
endef

$(eval $(call BuildPackage,ranga-mtk))
