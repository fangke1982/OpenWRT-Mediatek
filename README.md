<div align="center">

![GitHub Header](https://git.kejizero.online/zhao/image/raw/branch/main/openwrt.png)

**基于 [OpenWrt](https://github.com/openwrt/openwrt) 打造的高效固件，覆盖 Mediatek 平台，专为进阶用户设计！**  

</div>

---

I18N: [English](README_EN.md) | [简体中文](README.md) 

## 🔍 固件信息概览 
- 🛠 **源码基础**：[Padavanonly](https://github.com/padavanonly/immortalwrt-mt798x-24.10)

- 🔧 **默认设置**：
  - 管理地址：`10.0.0.1`，密码：`password` 或留空
  - 所有 LAN 口均可访问网页终端和 SSH
  - WAN 默认启用防火墙保护
  - Docker 已切换为国内源，支持镜像加速
 
- 🚀 **增强支持**：[具体请查看hanwckf项目说明](https://cmi.hanwckf.top/p/immortalwrt-mt798x)
  - 使用mtk-openwrt-feeds提供的有线驱动、hnat驱动、内核补丁及配置工具，支持所有硬件加速特性
  - 使用mtwifi原厂无线驱动，默认开启802.11k，支持warp在内的所有加速特性
  - mt7981/mt7986均支持两个ppe，每个ppe有32k Entry（当有线驱动使用ADMAv1时，每个PPE最大支持16k Entry）
  - mtwifi-cfg无线配置工具支持openwrt的原生luci界面以及netifd-wireless标准接口。除此以外，还支持mtk原厂提供的luci-app-mtk和wifi-profile

- 🎛 **功能优化**：
  - 内置 ZeroWrt 设置菜单，轻松管理
  - 支持高级插件、自定义启动项

---
# Mediatek 系类固件简易构建脚本存档

### 存档来自：https://init.kejizero.online

---------------

## 基于 Linux 6.6/6.12 LTS 固件下载:

#### Mediatek : https://openwrt.kejizero.online

#### 构建来源: https://github.com/zhiern/OpenWRT-Mediatek

---------------

## 本地编译环境安装（根据 debian 11 / ubuntu 22）
```shell
sudo apt-get update
sudo apt-get install -y build-essential flex bison g++ gawk gcc-multilib g++-multilib gettext git libfuse-dev libncurses5-dev libssl-dev python3 python3-pip python3-ply python3-distutils python3-pyelftools rsync unzip zlib1g-dev file wget subversion patch upx-ucl autoconf automake curl asciidoc binutils bzip2 lib32gcc-s1 libc6-dev-i386 uglifyjs msmtp texinfo libreadline-dev libglib2.0-dev xmlto libelf-dev libtool autopoint antlr3 gperf ccache swig coreutils haveged scons libpython3-dev jq
```

## 授权构建
#### 如果你得到授权，请在构建前执行以下命令

```
export git_name=账户名 git_password=密码
```

---------------

### 启用 [GCC13](https://gcc.gnu.org/gcc-13/)/[GCC14](https://gcc.gnu.org/gcc-14/)/[GCC15](https://gcc.gnu.org/gcc-15/) 工具链编译
##### 只需在构建固件前执行以下命令即可启用 GCC13/GCC14/GCC15 交叉工具链

```
# GCC13
export USE_GCC13=y
```

```
# GCC14
export USE_GCC14=y
```

```
# GCC15
export USE_GCC15=y
```

### 更改 LAN IP 地址
##### 自定义默认 LAN IP 地址
##### 只需在构建固件前执行以下命令即可覆盖默认 LAN 地址（默认：10.0.0.1）

```
export LAN=10.0.0.1
```

### 更改默认 ROOT 密码
##### 只需在构建固件前执行以下命令即可设置默认 ROOT 密码（默认：无密码）

```
export ROOT_PASSWORD=12345678
```

### 使用 uhttpd 轻量 web 引擎
##### 固件默认使用 Nginx（quic） 作为页面引擎，只需在构建固件前执行以下命令即可使用 uhttpd 取代 nginx
##### Nginx 在具备公网的环境下可以提供更丰富的功能支持

```
export ENABLE_UHTTPD=y
```

## 构建 OpenWrt 24.10 开发版（24.10-SNAPSHOT）

### 开始构建
```shell
# linux-6.12
bash <(curl -sS https://init.kejizero.online/build.sh) 设备名称{Netcore-N60，Netcore-N60-pro，Netcore-N60-pro-512rom，Cetron-CT3003，Qihoo-360t7，Qihoo-360t7-512rom}
```

-----------------

# 基于本仓库进行自定义构建 - 本地编译

#### 如果你有自定义的需求，建议不要变更内核版本号，这样构建出来的固件可以直接使用 `opkg install kmod-xxxx`

### 一、Fork 本仓库到自己 GitHub 存储库

### 二、修改构建脚本文件：`openwrt/build.sh`（使用 Github Actions 构建时无需更改）

将 init.cooluc.com 脚本默认连接替换为你的 github raw 连接，像这样 `https://raw.githubusercontent.com/你的用户名/r4s_build_script/refs/heads/master`

```diff
 # script url
-    export mirror=https://init.kejizero.online
+    export mirror=https://raw.githubusercontent.com/你的用户名/OpenWRT-Mediatek/refs/heads/openwrt-24.10
```

### 三、在本地 Linux 执行基于你自己仓库的构建脚本，即可编译所需固件

#### nanopi-r4s openwrt-24.10
```shell
# linux-6.12
bash <(curl -sS https://raw.githubusercontent.com/你的用户名/OpenWRT-Mediatek/refs/heads/openwrt-24.10/openwrt/build.sh) 设备名称{Netcore-N60，Netcore-N60-pro，Netcore-N60-pro-512rom，Cetron-CT3003，Qihoo-360t7，Qihoo-360t7-512rom}
```
-----------------

# 使用 Github Actions 构建

### 一、Fork 本仓库到自己 GitHub 存储库

### 二、构建固件

- 在存储库名称下，单击（<img src="https://github.com/user-attachments/assets/f1db14da-2dd9-4f10-8e37-d92ef9651912" alt="Actions"> Actions）。
  
- 在左侧边栏中，单击要运行的工作流的名称：**Build releases**。
  
- 在工作流运行的列表上方，单击“**Run workflow**”按钮，选择要构建的设备固件并运行工作流。
  
  ![image](https://github.com/user-attachments/assets/3eae2e9f-efe6-48ad-8e9d-39c176fcd71c)
  
## 🏆 鸣谢 [![](https://img.shields.io/badge/-跪谢各大佬-FFFFFF.svg)](#鸣谢-)
| [ImmortalWrt](https://github.com/immortalwrt) | [coolsnowwolf](https://github.com/coolsnowwolf) | [P3TERX](https://github.com/P3TERX) | [Flippy](https://github.com/unifreq) |
| :-------------: | :-------------: | :-------------: | :-------------: |
| <img width="100" src="https://avatars.githubusercontent.com/u/53193414"/> | <img width="100" src="https://avatars.githubusercontent.com/u/31687149"/> | <img width="100" src="https://avatars.githubusercontent.com/u/25927179"/> | <img width="100" src="https://avatars.githubusercontent.com/u/39355261"/> |
| [sbwml](https://github.com/sbwml) | [SuLingGG](https://github.com/SuLingGG) | [QiuSimons](https://github.com/QiuSimons) | [padavanonly](https://github.com/padavanonly/immortalwrt-mt798x-24.10) |
| <img width="100" src="https://avatars.githubusercontent.com/u/16485166?v=4"/> | <img width="100" src="https://avatars.githubusercontent.com/u/22287562"/> | <img width="100" src="https://avatars.githubusercontent.com/u/45143996"/> | <img width="100" src="https://avatars.githubusercontent.com/u/83120842?v=4"/> |

---
