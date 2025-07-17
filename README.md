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

## 基于 immortalwrt-mt798x-6.6 [固件下载](https://github.com/padavanonly/immortalwrt-mt798x-6.6)

### 鸣谢

|               [ImmortalWrt](https://github.com/immortalwrt)               |              [coolsnowwolf](https://github.com/coolsnowwolf)              |                    [Lienol](https://github.com/Lienol)                    |
| :-----------------------------------------------------------------------: | :-----------------------------------------------------------------------: | :-----------------------------------------------------------------------: |
| <img width="60" src="https://avatars.githubusercontent.com/u/53193414"/>  | <img width="60" src="https://avatars.githubusercontent.com/u/31687149" /> | <img width="60" src="https://avatars.githubusercontent.com/u/23146169" /> |
|            [NoTengoBattery](https://github.com/NoTengoBattery)            |                    [tty228](https://github.com/tty228)                    |                  [destan19](https://github.com/destan19)                  |
| <img width="60" src="https://avatars.githubusercontent.com/u/11285513" /> | <img width="60" src="https://avatars.githubusercontent.com/u/33397881" /> | <img width="60" src="https://avatars.githubusercontent.com/u/3950091" />  |
|                 [jerrykuku](https://github.com/jerrykuku)                 |                    [lisaac](https://github.com/lisaac)                    |             [rufengsuixing](https://github.com/rufengsuixing)             |
| <img width="60" src="https://avatars.githubusercontent.com/u/9485680" />  | <img width="60" src="https://avatars.githubusercontent.com/u/3320969" />  | <img width="60" src="https://avatars.githubusercontent.com/u/22387141" /> |
|                     [ElonH](https://github.com/ElonH)                     |                   [NateLol](https://github.com/NateLol)                   |                   [kiddin9](https://github.com/kiddin9)                   |
| <img width="60" src="https://avatars.githubusercontent.com/u/32666230" /> | <img width="60" src="https://avatars.githubusercontent.com/u/5166306" />  | <img width="60" src="https://avatars.githubusercontent.com/u/48883331" /> |
|              [AmadeusGhost](https://github.com/AmadeusGhost)              |                [1715173329](https://github.com/1715173329)                |                 [vernesong](https://github.com/vernesong)                 |
| <img width="60" src="https://avatars.githubusercontent.com/u/42570690" /> | <img width="60" src="https://avatars.githubusercontent.com/u/22235437" /> | <img width="60" src="https://avatars.githubusercontent.com/u/42875168" /> |
