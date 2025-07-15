#!/bin/bash

# default LAN IP
sed -i "s/192.168.6.1/$LAN/g" package/base-files/files/bin/config_generate

# default name
sed -i 's/ImmortalWrt/ZeroWrt/' package/base-files/files/bin/config_generate

# banner
curl -s $mirror/files/base-files/banner > package/base-files/files/etc/banner

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

# Emortal
curl -s $mirror/files/emortal/99-default-settings > package/emortal/default-settings/files/99-default-settings

# Load patch file
curl -sL $mirror/openwrt/patch/0001-Modify-version-information.patch | patch -p1
curl -sL $mirror/openwrt/patch/0001-netcore-n60-pro-512-flash-version.patch | patch -p1
curl -sL $mirror/openwrt/patch/0001-mediatek-Device-Cetron-ct3003-patch-file.patch | patch -p1
pushd feeds/luci
    curl -s $mirror/openwrt/patch/0001-luci-mod-system-add-modal-overlay-dialog-to-reboot.patch | patch -p1
    curl -s $mirror/openwrt/patch/0002-luci-mod-status-displays-actual-process-memory-usage.patch | patch -p1
    curl -s $mirror/openwrt/patch/0003-luci-mod-status-storage-index-applicable-only-to-val.patch | patch -p1
    curl -s $mirror/openwrt/patch/0004-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
    curl -s $mirror/openwrt/patch/0005-luci-mod-system-add-refresh-interval-setting.patch | patch -p1
    curl -s $mirror/openwrt/patch/0006-luci-mod-system-mounts-add-docker-directory-mount-po.patch | patch -p1
    curl -s $mirror/openwrt/patch/0007-luci-mod-system-add-ucitrack-luci-mod-system-zram.js.patch | patch -p1
popd

# golang 1.25
rm -rf feeds/packages/lang/golang
git clone https://$gitea/packages_lang_golang -b 25.x feeds/packages/lang/golang

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://$gitea/luci-app-dockerman -b openwrt-24.10 feeds/luci/applications/luci-app-dockerman
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
git clone https://$gitea/packages_utils_docker feeds/packages/utils/docker
git clone https://$gitea/packages_utils_dockerd feeds/packages/utils/dockerd
git clone https://$gitea/packages_utils_containerd feeds/packages/utils/containerd
git clone https://$gitea/packages_utils_runc feeds/packages/utils/runc

# SSRP & Passwall
rm -rf feeds/luci/applications/{luci-app-daed,luci-app-dae,luci-app-homeproxy,luci-app-openclash,luci-app-passwall}
rm -rf feeds/packages/net/{daed,xray-core,v2ray-core,v2ray-geodata,sing-box}
git clone https://"$git_name":"$git_password"@$gitea/openwrt_helloworld package/new/helloworld

# argon
rm -rf feeds/luci/themes/luci-theme-argon
git clone https://$github/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
curl -s $mirror/files/argon/bg1.jpg > package/new/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
curl -s $mirror/files/argon/iconfont.ttf > package/new/luci-theme-argon/htdocs/luci-static/argon/fonts/iconfont.ttf
curl -s $mirror/files/argon/iconfont.woff > package/new/luci-theme-argon/htdocs/luci-static/argon/fonts/iconfont.woff
curl -s $mirror/files/argon/iconfont.woff2 > package/new/luci-theme-argon/htdocs/luci-static/argon/fonts/iconfont.woff2
curl -s $mirror/files/argon/cascade.css > package/new/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css

# argon-config
rm -rf feeds/luci/applications/luci-app-argon-config
git clone https://$github/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config
sed -i "s/bing/none/g" package/new/luci-app-argon-config/root/etc/config/argon

# Theme settings
sed -i 's|<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a>|<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a>|g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/zhiern/OpenWRT" target="_blank">ZeroWrt</a> |g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a>|<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a>|g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/zhiern/OpenWRT" target="_blank">ZeroWrt</a> |g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm

# lucky
git clone https://$github/gdy666/luci-app-lucky.git package/new/lucky

# Mosdns
rm -rf feeds/packages/net/mosdns
git clone https://$github/sbwml/luci-app-mosdns -b v5 package/new/mosdns

# openlist
rm -rf feeds/luci/applications/luci-app-openlist
git clone https://$github/sbwml/luci-app-openlist package/new/openlist

# adguardhome
git clone https://$gitea/luci-app-adguardhome package/new/luci-app-adguardhome

# install feeds
./scripts/feeds update -a
./scripts/feeds install -a
