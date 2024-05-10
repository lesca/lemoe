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
termux-change-repo && pkg install termux-am && termux-setup-storage && ln -s storage/documents/lemoe && bash lemoe/lemoe.sh
```

> [!TIP]
> 提示： Documents 和 Download 目录已挂载在 `/media` 目录下，以方便使用。

# 使用方法

## 构建你自己的镜像

确保你的设备能够顺畅访问 github，然后运行以下命令：

```
bash lemoe.sh build
``` 

默认的用户名是 **lemoe**。如果你想用另一个用户名，可以在命令的末尾添加，像这样：

```
bash lemoe.sh build your_name
```

用户名会被保存在 `.lemoe_user` 文件中，供下次运行使用。

## 备份镜像

运行以下命令来备份 Linux 镜像。这将包括系统中的所有文件以及用户的配置文件。镜像被保存在 `lemoe/distro-backup` 文件夹。

```
bash lemoe.sh backup_distro
```

默认的文件名是 `$DISTRO-base.tar.gz`，其中`$DISTRO`是环境中指定的发行版。

例如，环境变量`DISTRO=debian`，那么文件名为`debian-base.tar.gz`。如果文件已存在，备份将失败。你需要删除该文件，或在命令末尾指定另一个名称来创建新的文件，如下所示：

```
bash lemoe.sh backup_distro name
```

本例中，它将保存为 `debian-name.tar.gz`。

## 恢复镜像

恢复 base 镜像：

```
bash lemoe.sh restore_distro
```

恢复自定义镜像：

```
bash lemoe.sh restore_distro name
```

## 备份和恢复配置文件

```
bash lemoe.sh backup_profile
```

此命令保存两个配置文件：

* 发行版用户配置文件：备份 Linux 中 `$HOME` 目录的文件。
  * 默认文件名为 `$DISTRO-profile.tar.gz`。
  * 此备份可以通过 `bash lemoe.sh restore_profile` 手动恢复。
* termux 用户配置文件：备份 termux 中 `$HOME` 目录的文件。
  * 默认文件名为 `termux-profile.tar.gz`。
  * 当执行 `setup_termux` 时，此备份会自动使用。
  * 此备份可以通过 `bash lemoe.sh restore_termux` 手动恢复。

所有备份文件都保存在 `lemoe/profile-backup` 文件夹。

通常，你可以在命令末尾添加你的自定义名称，以创建自己的备份，以供进一步使用或测试。

```
bash lemoe.sh backup_profile name
```

如果你想恢复它，使用相同的名称。

## 重置

下面的命令将完全移除已安装的 Linux 系统，然后从 base 镜像中恢复。

```
bash lemoe.sh reset
```

## 登录

默认情况下，以下命令以 root 身份登录。

```
bash lemoe.sh login
```

你可以指定另一个用户进行登录，例如：

```
bash lemoe.sh login Lemoe
```


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
