#!/bin/bash

# 移除要替换的包
rm -rf feeds/packages/net/{lucky,mosdns,pdnsd-alt,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/{luci-app-mosdns,luci-app-netdata,luci-app-serverchan,luci-app-lucky}
rm -rf feeds/luci/themes/{luci-theme-argon,luci-theme-netgear}
