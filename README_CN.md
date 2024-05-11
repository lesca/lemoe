[[中文](README_CN.md)|[EN](README.md)]

# 关于 **lemoe**

**lemoe** 是 **lemon moe**（🍋萌）的简称。

该项目受到了 tmoe 的启发。

一个易于使用的命令行工具，在 termux 中一键部署 ArchiLinux 发行版，并提供 X11 图形界面支持。

## 特性：

* Lemoe 通过一条命令即可部署并启动 Linux 发行版，并提供 X11 图形界面支持。
* Lemoe 使用 `termux:x11` 来获得比 VNC 更好的图形性能。
* Lemoe 注重生产力工具，预装了 chromium、vscode、fcitx5 等。
* Lemoe 可以轻松 **备份/恢复** 发行版镜像。
* Lemoe 可以轻松 **备份/恢复** 配置文件。



# 快速开始

1. 从你喜爱的应用商店安装 `Termux` 或 `ZeroTermux` 应用。

2. 从[官方发布页](https://github.com/termux/termux-x11/releases)安装最新 `termux-x11` 应用。

3. 克隆代码库

可以将代码库克隆到设备的`Documents`目录下。第5步将以此为基础。

```
git clone https://github.com/lesca/lemoe.git
```

4. 下载发行版镜像

你可以[下载 base 镜像](https://github.com/lesca/lemoe/wiki/Download)，并将其放入 `lemoe/distro_backup` 文件夹。

另外，你也可以自行构建镜像，命令为 `lemoe.sh build`。

5. 首次运行

```
termux-change-repo && pkg install termux-am && termux-setup-storage && ln -sf storage/documents/lemoe && bash lemoe/lemoe.sh
```

> [!TIP]
> 提示： Documents 和 Download 目录已挂载在 `/media` 目录下，以方便使用。

# 使用方法

## 命令指南

| 命令                                  | 描述                                                         | 默认设置                                                    |
| ------------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------- |
| `lemoe.sh`                            | 启动 X11。                                                    | 默认启动 **debian**，并以 **Lemoe** 用户身份登录。可以通过 `lemoe.sh config` 修改。 |
| `lemoe.sh config distro <distro>`     | 配置发行版。                                                  | 默认为 **debian**。配置文件位于 `~/.lemoe`。                |
| `lemoe.sh config user <user>`         | 配置发行版用户。                                              | 默认用户为 **Lemoe**。配置文件位于 `~/.lemoe`。             |
| `lemoe.sh build`                      | 构建自定义镜像。                                              | 默认发行版为 **debian**。可以通过 `lemoe.sh config` 修改。  |
| `lemoe.sh reset`                      | 从安装位置删除配置的发行版。可以稍后恢复或重建。              | 默认情况下，它将删除在 `~/.lemoe` 中配置的发行版。         |
| `lemoe.sh restore`                    | 分别恢复基础镜像和用户配置备份。用户配置将恢复到配置的用户。  | 默认情况下，它会查找以下文件：<br />基础镜像 `distro-backup/$DISTRO-base.tar.gz` <br />用户配置备份 `profile-backup/$DISTRO-profile.tar.gz`。 |
| `lemoe.sh backup_distro [name]`       | 备份发行版镜像。用户配置也会保存到镜像文件中。确保用户配置干净，并删除临时文件和缓存，如果你想要一个金色镜像并分发它。 | 默认情况下，它将镜像 `$DISTRO-base-$NOW.tar.gz` 保存到 `lemoe/distro-backup` 文件夹。 |
| `lemoe.sh backup_profile [name]`      | 分别备份 termux 配置和用户配置。                              | Termux 配置被保存为 `termux-profile-$NOW.tar.gz`。<br />用户配置被保存为 `$DISTRO-profile-$NOW.tar.gz`。<br />它们被保存到 `lemoe/profile-backup` 文件夹。 |
| `lemoe.sh login [user_name]`          | 以 **root** 用户身份在命令行（bash）模式下登录配置的发行版。  | 默认登录用户为 **root**。                                   |


## 构建你自己的镜像

确保你的设备能够顺畅访问 github，然后运行以下命令：

```
bash lemoe.sh build
``` 

默认的发行版是 **Debian**，用户名是 **Lemoe**。如果你想用其他设置，需要先 `config` 之后再 `build` ：

配置发行版：

```
bash lemoe.sh config distro <archlinux|debian>
```

配置用户名：

```
bash lemoe.sh config user <your_name>
```

配置会被保存在 `~/.lemoe` 文件中，供下次运行使用。


# 故障排除

## 没有声音

尝试以下操作：

1. 完全关闭 termux 并重新启动

2. 如果你正在使用蓝牙耳机，请关闭蓝牙并再次尝试。

> 已知问题：如果蓝牙音频设备连接且处于空闲状态，播放将不工作。

3. 如果仍然不工作，请运行以下命令：

```
bash lemoe.sh fix_audio
```

这将 `pulseaudio` 模块从 `load-module module-sles-sink` 更改为 `load-module module-aaudio-sink`。

这适用于华为设备，并且会在你首次运行时自动应用。

对于其他设备，这也值得一试。

> [!NOTE]
> 注意：记得完全关闭 `termux` 并重新开始。

## Process completed (singal 9)

在 `adb shell` 中运行以下命令以解除进程数量限制：

```
device_config set_sync_disabled_for_tests persistent
device_config put activity_manager max_phantom_processes 2147483647
```
