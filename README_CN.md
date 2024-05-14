[[中文](README_CN.md)|[EN](README.md)]

# 关于 **lemoe**

**lemoe** 是 **lemon moe** (🍋萌) 的缩写。

该项目的灵感来源于 **tmoe**。

但与 tmoe 不同的是：
* 该项目旨在提供一个易于使用的命令行工具，在 termux 中用一条命令 **构建** 和 **部署** Linux 发行版。
* 该项目提供了集成应用程序的接口，以便在 **构建** 过程中自动集成你的应用程序，然后你可以轻松地重新分发镜像。


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

| 命令                                | 描述                                                         | 默认设置                                                     |
| ----------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `lemoe.sh`                          | 启动X11。                                                    | 默认启动**debian**，并以**Lemoe**用户登录。您可以通过`lemoe.sh config`更改。 |
| `lemoe.sh config distro <distro>`   | 配置发行版。                                                 | 默认为**debian**。配置文件为`~/.lemoe`。                     |
| `lemoe.sh config user <user>`       | 配置发行版用户。                                             | 默认用户为**Lemoe**。配置文件为`~/.lemoe`。                  |
| `lemoe.sh config dpi <num>`         | 通过指定数字配置发行版DPI。对于2.5~3K显示器，建议使用200。    | 默认为200。                                                  |
| `lemoe.sh build`                    | 构建自定义镜像。                                             | 默认发行版为**debian**。您可以通过`lemoe.sh config`更改。   |
| `lemoe.sh reset`                    | 从安装位置删除配置的发行版。您可以稍后`restore`或`build`。            | 默认情况下，它会移除在`~/.lemoe`中配置的发行版。             |
| `lemoe.sh backup`                   | 分别备份发行版基础镜像、发行版配置文件和termux配置文件。更多信息，请参考[备份](/backups/README.md)页面。 | 默认情况下，备份保存如下：<br />发行版镜像：`backups/$DISTRO-base-yyyyMMdd-hhmmss.tar.gz` <br />发行版配置文件：`backups/$DISTRO-profile-yyyyMMdd-hhmmss.tar.gz`。<br />termux配置文件：`backups/termux-profile-yyyyMMdd-hhmmss.tar.gz`。 |
| `lemoe.sh restore`                  | 分别恢复发行版基础镜像和发行版配置文件。如果这是第一次运行，也会恢复termux配置文件。更多信息，请参考[备份](/backups/README.md)页面。 | 默认情况下，它查找以下文件：<br />发行版镜像：`backups/$DISTRO-base.tar.gz` <br />发行版配置文件：`backups/$DISTRO-profile.tar.gz`。 |
| `lemoe.sh login [user_name]`        | 以命令行（bash）模式登录配置的发行版，以**root**用户身份。    | 默认登录用户为**root**。                                     |
| `lemoe.sh lazypack` | 立即对当前项目打包成懒人包，保存为 zip 文件。 | 默认包的名称格式为 `lemoe-$DISTRO-yyyyMMdd-hhmmss.zip`。<br />默认的包目录为 `$HOME/storage/documents/lazy-packs-lemoe`。 |

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

# 开发指南

## 添加一个新应用

### 主要步骤

你可以将自己的应用添加到相应的发行版文件夹中，例如 debian 或 archlinux。

要添加一个新应用，请按照以下步骤操作：
1. 创建一个名为 `app_xxx.sh` 的脚本文件，其中 **xxx** 代表你的应用名称。
2. 在脚本中的 `install_xxx()` 函数中定义安装步骤。
3. （可选）在脚本中的 `setup_user_xxx()` 函数中定义应用的用户配置。
4. （可选）如果希望在 `build` 过程中自动安装该应用，将应用名称 **xxx** 添加到 `config/apps.sh` 文件中。

### 示例

以下是 **ime** 应用的示例。它定义在文件 `lemoe/debian/app_ime.sh` 中。

* `install_ime()` 是用于安装该应用的函数。它以 **root** 身份运行。
  * 你可以将 **ime** 替换为自己的应用名称。
  * 你可以通过运行 `lemoe.sh install_ime` 进行测试。
  * 在 `build` 过程中，如果在 `config/apps.sh` 文件中定义了该函数，它也会调用此函数。
* `setup_user_ime()` 是用于在用户创建过程中设置应用的函数。它以发行版用户身份运行，默认情况下是 **Lemoe**。
  * 你可以将 **ime** 替换为自己的应用名称。
  * 你可以通过运行 `lemoe.sh setup_user_ime` 进行测试。
  * 在用户创建过程中，如果在 `config/apps.sh` 文件中定义了该函数，它也会调用此函数。

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
