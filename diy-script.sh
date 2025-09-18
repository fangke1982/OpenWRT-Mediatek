#!/bin/bash

# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 修改默认名称
sed -i 's/LEDE/ZeroWrt/' package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除要替换的包
rm -rf feeds/packages/net/{lucky,mosdns,pdnsd-alt,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/{luci-app-argon-config,luci-app-mosdns,luci-app-netdata,luci-app-serverchan,luci-app-lucky}
rm -rf feeds/luci/themes/{luci-theme-argon,luci-theme-netgear}

# golang 1.25
rm -rf feeds/packages/lang/golang
git clone $MIRROR_URL/packages_lang_golang -b 25.x feeds/packages/lang/golang

# 私有插件源
git clone $MIRROR_URL/openwrt_packages package/openwrt_packages

# 私有科学代理源
git clone $MIRROR_URL/openwrt_helloworld package/openwrt_helloworld

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/other/bg1.jpg package/openwrt_packages/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# 默认设置
cp -f $GITHUB_WORKSPACE/other/zzz-default-settings package/lean/default-settings/files/zzz-default-settings

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by OPPEN321/g" package/lean/default-settings/files/zzz-default-settings
sed -i 's/LEDE/ZeroWrt 标准版 @/g' package/lean/default-settings/files/zzz-default-settings
cp -f $GITHUB_WORKSPACE/other/banner package/base-files/files/etc/banner

# 个性化设置
sed -i ':a;N;$!ba;s|<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %>[[:space:]]*(<%= ver.luciversion %>)</a> /|<a class="luci-link" href="www.kejizero.online" target="_blank">探索无限</a> /|' package/openwrt_packages/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a> /|<a href="https://github.com/NeonPulse-Zero/ZeroWrt-Mediatek" target="_blank">项目地址</a> /|' package/openwrt_packages/luci-theme-argon/luasrc/view/themes/argon/footer.htm

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-nginx/Makefile

# WIFI相关设置
cp -f $GITHUB_WORKSPACE/other/mac80211.sh package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 切换内核版本为6.12
sed -i 's/6.6/6.12/g' target/linux/mediatek/Makefile

./scripts/feeds update -a
./scripts/feeds install -a
