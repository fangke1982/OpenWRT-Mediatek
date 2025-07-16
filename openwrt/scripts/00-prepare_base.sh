#!/bin/bash

# default LAN IP
sed -i "s/192.168.1.1/$LAN/g" package/base-files/files/bin/config_generate

# default name
sed -i 's/ImmortalWrt/ZeroWrt/' package/base-files/files/bin/config_generate

# banner
curl -s $mirror/openwrt/files/base-files/banner > package/base-files/files/etc/banner

# default password
if [ -n "$ROOT_PASSWORD" ]; then
    # sha256 encryption
    default_password=$(openssl passwd -5 $ROOT_PASSWORD)
    sed -i "s|^root:[^:]*:|root:${default_password}:|" package/base-files/files/etc/shadow
fi

# default wifi name
sed -i "s/MT7986_AX6000_2.4G/$Wifi_Name-2.4G/g" package/mtk/drivers/wifi-profile/files/mt7986/mt7986-ax6000.dbdc.b0.dat
sed -i "s/MT7986_AX6000_5G/$Wifi_Name-5G/g" package/mtk/drivers/wifi-profile/files/mt7986/mt7986-ax6000.dbdc.b1.dat
sed -i "s/MT7981_AX3000_2.4G/$Wifi_Name-2.4G/g" package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b0.dat
sed -i "s/MT7981_AX3000_5G/$Wifi_Name-5G/g" package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b1.dat
sed -i "s/ImmortalWrt-2.4G/$Wifi_Name-2.4G/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "s/ImmortalWrt-5G/$Wifi_Name-5G/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# default wifi password
curl -sL $mirror/openwrt/patch/0001-mtwifi-default-password-setting.patch | patch -p1
sed -i "s/12345678/$Wifi_Password/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# Add author information
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='ZeroWrt-$(date +%Y%m%d)'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By OPPEN321'/g" package/base-files/files/etc/openwrt_release
sed -i "s|^OPENWRT_RELEASE=\".*\"|OPENWRT_RELEASE=\"ZeroWrt 标准版 @R$(date +%Y%m%d) BY OPPEN321\"|" package/base-files/files/usr/lib/os-release

# Load patch file
if [ "$platform" = "Netcore-N60-pro-512rom" ]; then
    curl -sL $mirror/openwrt/patch/0001-netcore-n60-pro-512-flash-version.patch | patch -p1
elif [ "$platform" = "Cetron-CT3003" ]; then
    curl -sL $mirror/openwrt/patch/0001-mediatek-Device-Cetron-ct3003-patch-file.patch | patch -p1
elif [ "$platform" = "Qihoo-360t7-512rom" ]; then
    curl -sL $mirror/openwrt/patch/0001-Qihoo-360t7-512-flash-version.patch | patch -p1 
fi
curl -sL $mirror/openwrt/patch/0001-Modify-version-information.patch | patch -p1
pushd feeds/luci
    curl -s $mirror/openwrt/patch/0001-luci-mod-system-add-modal-overlay-dialog-to-reboot.patch | patch -p1
    curl -s $mirror/openwrt/patch/0002-luci-mod-status-displays-actual-process-memory-usage.patch | patch -p1
    curl -s $mirror/openwrt/patch/0003-luci-mod-status-storage-index-applicable-only-to-val.patch | patch -p1
    curl -s $mirror/openwrt/patch/0004-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
    curl -s $mirror/openwrt/patch/0005-luci-mod-system-add-refresh-interval-setting.patch | patch -p1
    curl -s $mirror/openwrt/patch/0006-luci-mod-system-mounts-add-docker-directory-mount-po.patch | patch -p1
    curl -s $mirror/openwrt/patch/0007-luci-mod-system-add-ucitrack-luci-mod-system-zram.js.patch | patch -p1
popd
