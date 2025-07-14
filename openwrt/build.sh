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
CURRENT_DATE=$(date +%s)

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

# wifi_name
[ -n "$Wifi_Name" ] && export Wifi_Name=$Wifi_Name || export Wifi_Name=ZeroWrt

# wifi_password
[ -n "$Wifi_Password" ] && export Wifi_Password=$Wifi_Password || export Wifi_Password=12345678

# platform
[ "$1" = "Netcore-N60" ] && export platform="Netcore-N60" toolchain_arch="aarch64_cortex-a53"
[ "$1" = "Netcore-N60-pro" ] && export platform="Netcore-N60-pro" toolchain_arch="aarch64_cortex-a53"
[ "$1" = "Netcore-N60-pro-512rom" ] && export platform="Netcore-N60-pro-512rom" toolchain_arch="aarch64_cortex-a53"
[ "$1" = "Cetron-CT3003" ] && export platform="Cetron-CT3003" toolchain_arch="aarch64_cortex-a53"

# gcc13 & 14
if [ "$USE_GCC13" = y ]; then
    export USE_GCC13=y gcc_version=13
elif [ "$USE_GCC14" = y ]; then
    export USE_GCC14=y gcc_version=14
else
    export USE_GCC14=y gcc_version=14
fi

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
get_kernel_version=$(curl -s https://raw.githubusercontent.com/padavanonly/immortalwrt-mt798x-6.6/refs/heads/openwrt-24.10-6.6/include/kernel-6.6)
kmod_hash=$(echo -e "$get_kernel_version" | awk -F'HASH-' '{print $2}' | awk '{print $1}' | tail -1 | md5sum | awk '{print $1}')
kmodpkg_name=$(echo $(echo -e "$get_kernel_version" | awk -F'HASH-' '{print $2}' | awk '{print $1}')~$(echo $kmod_hash)-r1)
echo -e "${GREEN_COLOR}Kernel: $kmodpkg_name ${RES}"
echo -e "${GREEN_COLOR}Date: $CURRENT_DATE${RES}\r\n"
echo -e "${GREEN_COLOR}SCRIPT_URL:${RES} ${BLUE_COLOR}$mirror${RES}\r\n"
echo -e "${GREEN_COLOR}GCC VERSION: $gcc_version${RES}"
[ -n "$LAN" ] && echo -e "${GREEN_COLOR}LAN: $LAN${RES}" || echo -e "${GREEN_COLOR}LAN: 10.0.0.1${RES}"
[ -n "$ROOT_PASSWORD" ] && echo -e "${GREEN_COLOR}Default Password:${RES} ${BLUE_COLOR}$ROOT_PASSWORD${RES}" || echo -e "${GREEN_COLOR}Default Password: (${RES}${YELLOW_COLOR}password${RES}${GREEN_COLOR})${RES}"
[ -n "$Wifi_Name" ] && echo -e "${GREEN_COLOR}Default Wifi Name:${RES} ${BLUE_COLOR}$Wifi_Name{RES}" || echo -e "${GREEN_COLOR}Default Wifi Name: (${RES}${YELLOW_COLOR}ZeroWrt${RES}${GREEN_COLOR})${RES}"
[ -n "$Wifi_Password" ] && echo -e "${GREEN_COLOR}Default Wifi Password:${RES} ${BLUE_COLOR}$Wifi_Password{RES}" || echo -e "${GREEN_COLOR}Default Wifi Password: (${RES}${YELLOW_COLOR}12345678${RES}${GREEN_COLOR})${RES}"
[ "$BUILD_FAST" = "y" ] && echo -e "${GREEN_COLOR}BUILD_FAST: true${RES}" || echo -e "${GREEN_COLOR}BUILD_FAST:${RES} ${YELLOW_COLOR}false${RES}"
[ "$ENABLE_CCACHE" = "y" ] && echo -e "${GREEN_COLOR}ENABLE_CCACHE: true${RES}" || echo -e "${GREEN_COLOR}ENABLE_CCACHE:${RES} ${YELLOW_COLOR}false${RES}"

# openwrt - releases
[ "$(whoami)" = "runner" ] && group "source code"
git clone --depth=1 -b openwrt-24.10-6.6 https://github.com/padavanonly/immortalwrt-mt798x-6.6 openwrt

if [ -d openwrt ]; then
    cd openwrt
    curl -s $mirror/openwrt/files/feeds/feeds.conf.default > feeds.conf.default
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
case "$platform" in
    "Netcore-N60")
        curl -s $mirror/openwrt/24-config-netcore-n60 > .config
        ;;
    "Netcore-N60-pro")
        curl -s $mirror/openwrt/24-config-netcore-n60-pro > .config
        ;;
    "Netcore-N60-pro-512rom")
        curl -s $mirror/openwrt/24-config-netcore-n60-pro-512rom > .config
        ;;
    "Cetron-CT3003")
        curl -s $mirror/openwrt/24-config-cetron-ct3003 > .config
        ;;
    *)
        echo -e "${RED_COLOR}Unsupported platform: $platform${RES}"
        exit 1
        ;;
esac

# gcc config
echo -e "\n# gcc ${gcc_version}" >> .config
echo -e "CONFIG_DEVEL=y" >> .config
echo -e "CONFIG_TOOLCHAINOPTS=y" >> .config
echo -e "CONFIG_GCC_USE_VERSION_${gcc_version}=y\n" >> .config
[ "$(whoami)" = "runner" ] && endgroup

# ccache
if [ "$ENABLE_CCACHE" = "y" ]; then
    echo "CONFIG_CCACHE=y" >> .config
    [ "$(whoami)" = "runner" ] && echo "CONFIG_CCACHE_DIR=\"/builder/.ccache\"" >> .config
    tools_suffix="_ccache"
fi

# Toolchain Cache
if [ "$BUILD_FAST" = "y" ]; then
    TOOLCHAIN_URL=https://github.com/oppen321/openwrt_caches/releases/download/OpenWrt_Toolchain_Cache
    echo -e "\n${GREEN_COLOR}Download Toolchain ...${RES}"
    curl -L -k ${TOOLCHAIN_URL}/toolchain_${toolchain_arch}_x${gcc_version}.tar.zst -o toolchain.tar.zst $CURL_BAR
    echo -e "\n${GREEN_COLOR}Process Toolchain ...${RES}"
    tar -I "zstd" -xf toolchain.tar.zst
    rm -f toolchain.tar.zst
    mkdir bin
    find ./staging_dir/ -name '*' -exec touch {} \; >/dev/null 2>&1
    find ./tmp/ -name '*' -exec touch {} \; >/dev/null 2>&1
fi

# init openwrt config
rm -rf tmp/*
make defconfig

# Compile
if [ "$BUILD_TOOLCHAIN" = "y" ]; then
    echo -e "\r\n${GREEN_COLOR}Building Toolchain ...${RES}\r\n"
    make -j$cores toolchain/compile || make -j$cores toolchain/compile V=s || exit 1
    mkdir -p toolchain-cache
    tar -I "zstd -19 -T$(nproc --all)" -cf toolchain-cache/toolchain_${toolchain_arch}_gcc-${gcc_version}.tar.zst ./{build_dir,dl,staging_dir,tmp}
    echo -e "\n${GREEN_COLOR} Build success! ${RES}"
    exit 0
else
    echo -e "\r\n${GREEN_COLOR}Building OpenWrt ...${RES}\r\n"
    sed -i "/BUILD_DATE/d" package/base-files/files/usr/lib/os-release
    sed -i "/BUILD_ID/aBUILD_DATE=\"$CURRENT_DATE\"" package/base-files/files/usr/lib/os-release
    make -j$cores IGNORE_ERRORS="n m"
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
