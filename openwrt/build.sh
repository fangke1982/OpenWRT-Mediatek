#!/bin/bash -e
export RED_COLOR='\e[1;31m'
export GREEN_COLOR='\e[1;32m'
export YELLOW_COLOR='\e[1;33m'
export BLUE_COLOR='\e[1;34m'
export PINK_COLOR='\e[1;35m'
export SHAN='\e[1;33;5m'
export RES='\e[0m'

GROUP=
group() {
    endgroup
    echo "::group::  $1"
    GROUP=1
}
endgroup() {
    if [ -n "$GROUP" ]; then
        echo "::endgroup::"
    fi
    GROUP=
}

#####################################
#   Mediatek OpenWrt Build Script   #
#####################################

# 脚本URL
export mirror=http://127.0.0.1:8080

# GitHub镜像
export github="github.com"

# 私有Gitea
export gitea=git.kejizero.online/zhao

# Check root
if [ "$(id -u)" = "0" ]; then
    echo -e "${RED_COLOR}Building with root user is not supported.${RES}"
    exit 1
fi

# Start time
starttime=`date +'%Y-%m-%d %H:%M:%S'`

# Cpus
cores=`expr $(nproc --all) + 1`

# $CURL_BAR
if curl --help | grep progress-bar >/dev/null 2>&1; then
    CURL_BAR="--progress-bar";
fi

if [ -z "$1" ] || [ "$1" != "Netcore-N60" -a "$1" != "Netcore-N60-pro" -a "$1" != "Netcore-N60-pro-512rom" -a "$1" != "Cetron-CT3003" ]; then
    echo -e "\n${RED_COLOR}Building type not specified or incorrect.${RES}\n"
    echo -e "Usage:\n"
    echo -e "Netcore-N60 releases: ${GREEN_COLOR}bash build.sh Netcore-N60${RES}"
    echo -e "Netcore-N60-pro releases: ${GREEN_COLOR}bash build.sh Netcore-N60-pro${RES}"
    echo -e "Netcore-N60-pro-512rom releases: ${GREEN_COLOR}bash build.sh Netcore-N60-pro-512rom${RES}"
    echo -e "Cetron-CT3003 releases: ${GREEN_COLOR}bash build.sh Cetron-CT3003${RES}"
    exit 1
fi

# lan
[ -n "$LAN" ] && export LAN=$LAN || export LAN=10.0.0.1

# platform
[ "$1" = "Netcore-N60" ] && export platform="Netcore-N60" toolchain_arch="aarch64_cortex-a53"
[ "$1" = "Netcore-N60-pro" ] && export platform="Netcore-N60-pro" toolchain_arch="aarch64_cortex-a53"
[ "$1" = "Netcore-N60-pro-512rom" ] && export platform="Netcore-N60-pro-512rom" toolchain_arch="aarch64_cortex-a53"
[ "$1" = "Cetron-CT3003" ] && export platform="Cetron-CT3003" toolchain_arch="aarch64_cortex-a53"

# Passwaor
export ROOT_PASSWORD=$ROOT_PASSWORD

# print version
echo -e "\r\n${GREEN_COLOR}Building $branch${RES}\r\n"
if [ "$platform" = "Netcore-N60" ]; then
    echo -e "${GREEN_COLOR}Model: Netcore-N60${RES}"
elif [ "$platform" = "Netcore-N60-pro" ]; then
    echo -e "${GREEN_COLOR}Model: Netcore-N60-pro${RES}"
elif [ "$platform" = "Netcore-N60-pro-512rom" ]; then
    echo -e "${GREEN_COLOR}Model: Netcore-N60-pro-512rom${RES}"
elif [ "$platform" = "Cetron-CT3003" ]; then
    echo -e "${GREEN_COLOR}Model: Cetron-CT3003${RES}"
fi

# openwrt - releases
[ "$(whoami)" = "runner" ] && group "source code"
git clone --depth=1 -b openwrt-24.10-6.6 https://github.com/padavanonly/immortalwrt-mt798x-6.6 openwrt

if [ -d openwrt ]; then
    cd openwrt
    curl -Os $mirror/openwrt/patch/key.tar.gz && tar zxf key.tar.gz && rm -f key.tar.gz
else
    echo -e "${RED_COLOR}Failed to download source code${RES}"
    exit 1
fi

# Init feeds
[ "$(whoami)" = "runner" ] && group "feeds update -a"
./scripts/feeds update -a
[ "$(whoami)" = "runner" ] && endgroup

[ "$(whoami)" = "runner" ] && group "feeds install -a"
./scripts/feeds install -a
[ "$(whoami)" = "runner" ] && endgroup

###############################################
echo -e "\n${GREEN_COLOR}Patching ...${RES}\n"

# scripts
curl -sO $mirror/openwrt/scripts/prepare_base.sh
curl -sO $mirror/openwrt/scripts/preset-mihimo-core.sh
curl -sO $mirror/openwrt/scripts/preset-adguard-core.sh
chmod 0755 *sh
if [ "$platform" = "Netcore-N60-pro-512rom" ]; then
bash 00-prepare_base.sh
bash 01-prepare_base-mainline.sh
bash 02-prepare_package.sh
bash 04-fix_kmod.sh
bash 05-fix-source.sh

# 修改默认ip
sed -i "s/192.168.6.1/10.0.0.1/g" package/base-files/files/bin/config_generate

# 修改名称
sed -i 's/ImmortalWrt/ZeroWrt/' package/base-files/files/bin/config_generate

# WiFi
sed -i "s/MT7986_AX6000_2.4G/ZeroWrt-2.4G/g" package/mtk/drivers/wifi-profile/files/mt7986/mt7986-ax6000.dbdc.b0.dat
sed -i "s/MT7986_AX6000_5G/ZeroWrt-5G/g" package/mtk/drivers/wifi-profile/files/mt7986/mt7986-ax6000.dbdc.b1.dat

sed -i "s/MT7981_AX3000_2.4G/ZeroWrt-2.4G/g" package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b0.dat
sed -i "s/MT7981_AX3000_5G/ZeroWrt-5G/g" package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b1.dat

# New WiFi
sed -i "s/ImmortalWrt-2.4G/ZeroWrt-2.4G/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "s/ImmortalWrt-5G/ZeroWrt-5G/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# 版本设置
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

# 加入作者信息
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='ZeroWrt-$(date +%Y%m%d)'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By OPPEN321'/g" package/base-files/files/etc/openwrt_release
sed -i "s|^OPENWRT_RELEASE=\".*\"|OPENWRT_RELEASE=\"ZeroWrt 标准版 @R$(date +%Y%m%d) BY OPPEN321\"|" package/base-files/files/usr/lib/os-release

# Emortal
curl -s $mirror/Customize/emortal/99-default-settings > package/emortal/default-settings/files/99-default-settings

# 加载补丁文件
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
git clone -b openwrt-24.10 https://$gitea/openwrt_helloworld package/new/helloworld

# argon
rm -rf feeds/luci/themes/luci-theme-argon
git clone https://$github/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
curl -s $mirror/Customize/argon/bg1.jpg > package/new/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
curl -s $mirror/Customize/argon/iconfont.ttf > package/new/luci-theme-argon/htdocs/luci-static/argon/fonts/iconfont.ttf
curl -s $mirror/Customize/argon/iconfont.woff > package/new/luci-theme-argon/htdocs/luci-static/argon/fonts/iconfont.woff
curl -s $mirror/Customize/argon/iconfont.woff2 > package/new/luci-theme-argon/htdocs/luci-static/argon/fonts/iconfont.woff2
curl -s $mirror/Customize/argon/cascade.css > package/new/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css

# argon-config
rm -rf feeds/luci/applications/luci-app-argon-config
git clone https://$github/jerrykuku/luci-app-argon-config.git package/new/luci-app-argon-config
sed -i "s/bing/none/g" package/new/luci-app-argon-config/root/etc/config/argon

# 主题设置
sed -i 's|<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a>|<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a>|g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/zhiern/OpenWRT" target="_blank">ZeroWrt</a> |g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a>|<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a>|g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/zhiern/OpenWRT" target="_blank">ZeroWrt</a> |g' package/new/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm

# lucky
git clone https://$github/gdy666/luci-app-lucky.git package/new/lucky

# Mosdns
git clone https://$github/sbwml/luci-app-mosdns -b v5 package/new/mosdns

# openlist
rm -rf feeds/luci/applications/luci-app-openlist
git clone https://$github/sbwml/luci-app-openlist package/new/openlist

# adguardhome
git clone https://$gitea/luci-app-adguardhome package/new/luci-app-adguardhome

# install feeds
./scripts/feeds update -a
./scripts/feeds install -a
