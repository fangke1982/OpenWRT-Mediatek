#!/bin/bash

# golang 1.25
rm -rf feeds/packages/lang/golang
git clone https://$gitea/packages_lang_golang -b 25.x feeds/packages/lang/golang

# default-settings 
curl -s $mirror/openwrt/files/default-settings/99-default-settings > package/emortal/default-settings/files/99-default-settings


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
rm -rf package/new/helloworld/{daed,luci-app-daed,nikki,luci-app-nikki,dns2socks-rust,luci-app-homeproxy}

# argon
rm -rf feeds/luci/themes/luci-theme-argon
git clone https://$github/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
curl -s $mirror/openwrt/files/argon/bg1.jpg > package/new/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
curl -s $mirror/openwrt/files/argon/iconfont.ttf > package/new/luci-theme-argon/htdocs/luci-static/argon/fonts/iconfont.ttf
curl -s $mirror/openwrt/files/argon/iconfont.woff > package/new/luci-theme-argon/htdocs/luci-static/argon/fonts/iconfont.woff
curl -s $mirror/openwrt/files/argon/iconfont.woff2 > package/new/luci-theme-argon/htdocs/luci-static/argon/fonts/iconfont.woff2
curl -s $mirror/openwrt/files/argon/cascade.css > package/new/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css

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

# socat
git clone https://github.com/zhiern/luci-app-socat package/new/luci-app-socat

# install feeds
./scripts/feeds update -a
./scripts/feeds install -a
