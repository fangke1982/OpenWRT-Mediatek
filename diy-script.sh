#!/bin/bash

# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 修改默认名称
sed -i 's/LEDE/ZeroWrt/' package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除要替换的包
rm -rf feeds/packages/net/{mosdns,pdnsd-alt,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/{luci-app-mosdns,luci-app-netdata,luci-app-serverchan}
rm -rf feeds/luci/themes/{luci-theme-argon,luci-theme-netgear}

# golang 1.25
rm -rf feeds/packages/lang/golang
git clone http://10.0.0.245:3000/zhao/packages_lang_golang -b 25.x feeds/packages/lang/golang

# 添加额外插件
git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
git clone --depth=1 -b openwrt-18.06 https://github.com/tty228/luci-app-wechatpush package/luci-app-serverchan
git clone --depth=1 https://github.com/ilxp/luci-app-ikoolproxy package/luci-app-ikoolproxy
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
git clone --depth=1 https://github.com/destan19/OpenAppFilter package/OpenAppFilter
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
git_sparse_clone main https://github.com/Lienol/openwrt-package luci-app-filebrowser luci-app-ssr-mudb-server
git_sparse_clone openwrt-18.06 https://github.com/immortalwrt/luci applications/luci-app-eqos

# 科学上网插件
git clone --depth=1 http://10.0.0.245:3000/zhao/openwrt_helloworld package/helloworld

# Themes
git clone --depth=1 -b 18.06 http://10.0.0.245:3000/zhao/luci-theme-argon package/new/luci-theme-argon
git clone --depth=1 -b 18.06 http://10.0.0.245:3000/zhao/luci-app-argon-config package/new/luci-app-argon-config

# MosDNS
git clone --depth=1 http://10.0.0.245:3000/zhao/v2ray-geodata package/v2ray-geodata
git clone --depth=1 -b v5-lua http://10.0.0.245:3000/zhao/luci-app-mosdns package/new/luci-app-mosdns

# 默认设置
cp -f $GITHUB_WORKSPACE/scripts/zzz-default-settings package/lean/default-settings/files/zzz-default-settings

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by OPPEN321/g" package/lean/default-settings/files/zzz-default-settings
sed -i 's/LEDE/ZeroWrt 标准版 @/g' package/lean/default-settings/files/zzz-default-settings
cp -f $GITHUB_WORKSPACE/other/banner package/base-files/files/etc/banner

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-design/g' feeds/luci/collections/luci-nginx/Makefile

# WIFI相关设置
cp -f $GITHUB_WORKSPACE/scripts/mac80211.sh package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 切换内核版本为6.12
sed -i 's/6.6/6.12/g' target/linux/mediatek/Makefile

./scripts/feeds update -a
./scripts/feeds install -a
