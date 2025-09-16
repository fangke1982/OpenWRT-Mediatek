#!/bin/bash

# 设置变量
export github="github.com"
export mirror="http://10.0.0.245:3000/zhao"

# 修改默认IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 修改默认名称
sed -i 's/LEDE/ZeroWrt/' package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 移除要替换的包
rm -rf feeds/packages/net/{lucky,mosdns,pdnsd-alt,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/{luci-app-mosdns,luci-app-netdata,luci-app-serverchan,luci-app-lucky}
rm -rf feeds/luci/themes/{luci-theme-argon,luci-theme-netgear}

# golang 1.25
rm -rf feeds/packages/lang/golang
git clone $mirror/packages_lang_golang -b 25.x feeds/packages/lang/golang

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/other/bg1.jpg feeds/Zero/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# MosDNS
git clone --depth=1 $mirror/v2ray-geodata package/v2ray-geodata
git clone --depth=1 -b v5-lua $mirror/luci-app-mosdns package/luci-app-mosdns

# 默认设置
cp -f $GITHUB_WORKSPACE/other/zzz-default-settings package/lean/default-settings/files/zzz-default-settings

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by OPPEN321/g" package/lean/default-settings/files/zzz-default-settings
sed -i 's/LEDE/ZeroWrt 标准版 @/g' package/lean/default-settings/files/zzz-default-settings
cp -f $GITHUB_WORKSPACE/other/banner package/base-files/files/etc/banner

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-nginx/Makefile

# WIFI相关设置
cp -f $GITHUB_WORKSPACE/other/mac80211.sh package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 切换内核版本为6.12
sed -i 's/6.6/6.12/g' target/linux/mediatek/Makefile

./scripts/feeds update -a
./scripts/feeds install -a
