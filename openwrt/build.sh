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
    bash preset-mihimo-core.sh
    bash preset-adguard-core.sh
fi
bash prepare_base.sh

# Load devices Config
if [ "$platform" = "Netcore-N60" ]; then
    curl -s $mirror/openwrt/24-config-netcore-n60 > .config
elif [ "$platform" = "bcm53xx" ]; then
    curl -s $mirror/openwrt/24-config-netcore-n60-pro > .config
else
    curl -s $mirror/openwrt/24-config-netcore-n60-pro-512rom > .config
elif [ "$platform" = "rk3568" ]; then
    curl -s $mirror/openwrt/24-config-cetron-ct3003 > .config
fi

# Toolchain Cache
if [ "$BUILD_FAST" = "y" ]; then
    [ "$ENABLE_GLIBC" = "y" ] && LIBC=glibc || LIBC=musl
    [ "$isCN" = "CN" ] && github_proxy="ghp.ci/" || github_proxy=""
    echo -e "\n${GREEN_COLOR}Download Toolchain ...${RES}"
    PLATFORM_ID=""
    [ -f /etc/os-release ] && source /etc/os-release
    if [ "$PLATFORM_ID" = "platform:el9" ]; then
        TOOLCHAIN_URL="http://127.0.0.1:8080"
    else
        TOOLCHAIN_URL=https://"$github_proxy"github.com/sbwml/openwrt_caches/releases/download/openwrt-24.10
    fi
    curl -L ${TOOLCHAIN_URL}/toolchain_${LIBC}_${toolchain_arch}_gcc-${gcc_version}${tools_suffix}.tar.zst -o toolchain.tar.zst $CURL_BAR
    echo -e "\n${GREEN_COLOR}Process Toolchain ...${RES}"
    tar -I "zstd" -xf toolchain.tar.zst
    rm -f toolchain.tar.zst
    mkdir bin
    find ./staging_dir/ -name '*' -exec touch {} \; >/dev/null 2>&1
    find ./tmp/ -name '*' -exec touch {} \; >/dev/null 2>&1
fi

# Compile time
endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
SEC=$((end_seconds-start_seconds));

if [ -f bin/targets/*/*/sha256sums ]; then
    echo -e "${GREEN_COLOR} Build success! ${RES}"
    echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
else
    echo -e "\n${RED_COLOR} Build error... ${RES}"
    echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
    echo
    exit 1
fi
