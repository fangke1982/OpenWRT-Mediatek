#!/bin/bash

# default LAN IP
sed -i "s/192.168.6.1/$LAN/g" package/base-files/files/bin/config_generate

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

# distfeeds.conf
mkdir -p files/etc/opkg
cat > files/etc/opkg/distfeeds.conf <<EOF
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/aarch64_cortex-a53/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.2/packages/aarch64_cortex-a53/telephony
EOF

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

# Cancel the system default setting
# sed -i '/^DEFAULT_PACKAGES\.tweak:=\\/,/^[^ \t]/ {/^[ \t]*luci-light[ \t]*\\$/d}' include/target.mk

# nginx - latest version
rm -rf feeds/packages/net/nginx
git clone https://$github/sbwml/feeds_packages_net_nginx feeds/packages/net/nginx -b openwrt-24.10
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g;s/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/net/nginx/files/nginx.init

# nginx - ubus
sed -i 's/ubus_parallel_req 2/ubus_parallel_req 6/g' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 300;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support

# nginx - config
curl -s $mirror/openwrt/files/nginx/luci.locations > feeds/packages/net/nginx/files-luci-support/luci.locations
curl -s $mirror/openwrt/files/nginx/uci.conf.template > feeds/packages/net/nginx-util/files/uci.conf.template

# uwsgi - fix timeout
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i '/limit-as/c\limit-as = 5000' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# disable error log
sed -i "s/procd_set_param stderr 1/procd_set_param stderr 0/g" feeds/packages/net/uwsgi/files/uwsgi.init

# uwsgi - performance
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd - fix timeout
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# Version settings
cat << 'EOF' >> feeds/luci/modules/luci-mod-status/ucode/template/admin_status/index.ut
<script>
function addLinks() {
    var section = document.querySelector(".cbi-section");
    if (section) {
        var links = document.createElement('div');
        links.innerHTML = '<div class="table"><div class="tr"><div class="td left" width="33%"><a href="https://qm.qq.com/q/JbBVnkjzKa" target="_blank">QQ交流群</a></div><div class="td left" width="33%"><a href="https://t.me/kejizero" target="_blank">TG交流群</a></div><div class="td left"><a href="https://openwrt.kejizero.online" target="_blank">固件地址</a></div></div></div>';
        section.appendChild(links);
    } else {
        setTimeout(addLinks, 100); // 继续等待 `.cbi-section` 加载
    }
}

document.addEventListener("DOMContentLoaded", addLinks);
</script>
EOF

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

# fix gcc14
if [ "$USE_GCC14" = y ] || [ "$USE_GCC15" = y ]; then
    # linux-atm
    rm -rf package/network/utils/linux-atm
    git clone https://$github/sbwml/package_network_utils_linux-atm package/network/utils/linux-atm
fi

# fix gcc-15
if [ "$USE_GCC15" = y ]; then
    sed -i '/TARGET_CFLAGS/ s/$/ -Wno-error=unterminated-string-initialization/' package/libs/mbedtls/Makefile
    # elfutils
    curl -s $mirror/openwrt/901-backends-fix-string-initialization-error-on-gcc15.patch > package/libs/elfutils/patches/901-backends-fix-string-initialization-error-on-gcc15.patch
    # libwebsockets
    mkdir -p feeds/packages/libs/libwebsockets/patches
    curl -s $mirror/openwrt/patch/901-fix-string-initialization-error-on-gcc15.patch > feeds/packages/libs/libwebsockets/patches/901-fix-string-initialization-error-on-gcc15.patch
    # libxcrypt
    mkdir -p feeds/packages/libs/libxcrypt/patches
    curl -s $mirror/openwrt/patch/902-fix-string-initialization-error-on-gcc15.patch > feeds/packages/libs/libxcrypt/patches/901-fix-string-initialization-error-on-gcc15.patch
fi

# fix gcc-15.0.1 C23
if [ "$USE_GCC15" = y ]; then
    # gmp
    mkdir -p package/libs/gmp/patches
    curl -s $mirror/openwrt/patch/001-fix-build-with-gcc-15.patch > package/libs/gmp/patches/001-fix-build-with-gcc-15.patch
    # htop
    mkdir -p feeds/packages/admin/htop/patches
    curl -s $mirror/openwrt/patch/001-Avoid-compilation-issues-with-ncurses-on-GCC-15.patch > feeds/packages/admin/htop/patches/001-Avoid-compilation-issues-with-ncurses-on-GCC-15.patch
    # libtirpc
    sed -i '/TARGET_CFLAGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/libtirpc/Makefile
    # libsepol
    sed -i '/HOST_MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libsepol/Makefile
    # tree
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/tree/Makefile
    # gdbm
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/gdbm/Makefile
    # libical
    sed -i '/CMAKE_OPTIONS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/libical/Makefile
    # libconfig
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/feeds/packages/libconfig/Makefile
    # lsof
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/lsof/Makefile
    # screen
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/screen/Makefile
    # ppp
    sed -i '/CONFIGURE_VARS/i \\nTARGET_CFLAGS += -std=gnu17\n' package/network/services/ppp/Makefile
    # vim
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/vim/Makefile
    # mtd
    sed -i '/target=/i TARGET_CFLAGS += -std=gnu17\n' package/system/mtd/Makefile
    # libselinux
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/libs/libselinux/Makefile
    # avahi
    sed -i '/TARGET_CFLAGS +=/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/avahi/Makefile
    # bash
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/bash/Makefile
    # xl2tpd
    sed -i '/ifneq (0,0)/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/xl2tpd/Makefile
    # dnsmasq
    sed -i '/MAKE_FLAGS/i TARGET_CFLAGS += -std=gnu17\n' package/network/services/dnsmasq/Makefile
    # bluez
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/bluez/Makefile
    # e2fsprogs
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/e2fsprogs/Makefile
    # f2fs-tools
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' package/utils/f2fs-tools/Makefile
    # krb5
    sed -i '/CONFIGURE_VARS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/krb5/Makefile
    # parted
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/parted/Makefile
    # iperf3
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/iperf3/Makefile
    # db
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/libs/db/Makefile
    # python3
    sed -i '/TARGET_CONFIGURE_OPTS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/lang/python/python3/Makefile
    # uwsgi
    sed -i '/MAKE_VARS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/uwsgi/Makefile
    # perl
    sed -i '/Target perl/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/lang/perl/Makefile
    # rsync
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/net/rsync/Makefile
    # shine
    sed -i '/Build\/InstallDev/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/sound/shine/Makefile
    # jq
    sed -i '/CONFIGURE_ARGS/i TARGET_CFLAGS += -std=gnu17\n' feeds/packages/utils/jq/Makefile
fi
