[[中文](README_CN.md)|[EN](README.md)]

# About **lemoe**

**lemoe** is short for **lemon moe** (🍋萌)

This project is inspired by **tmoe**.

But unlike tmoe:
* this project is aimed to provide an easy-to-use command-line tool to **build** and **deploy** Linux distributions within termux, with a single command.
* this project provides interfaces for integrating applications, allowing you to automatically integrate your apps during the **build** process, after which you can easily redistribute the image.


## Features:

* Lemoe deploys and starts up a Linux distribution with X11 with one single command: `bash lemoe.sh`
* Lemoe uses `termux:x11` for better graphical performance, in comparison to VNC.
* Lemoe focuses on productivity, it pre-installs chromium, vscode, fcitx5, etc.
* Lemoe can **backup / restore** distribution images and user's profile easily.


# Quick Start

1. Install `Termux` or `ZeroTermux` app from your favourite app store.

2. Install the latest `termux-x11` app from [offical release](https://github.com/termux/termux-x11/releases)

3. Clone this repo

Clone the repo to the `Download` folder on your device. Step 5 is based on this assumuption. 

```
git clone https://github.com/lesca/lemoe.git
```

4. Download distro base image

You can [download](https://github.com/lesca/lemoe/wiki/Download) the base image and put it into the `lemoe/backups` folder.

Optionally, you can build your own image by running `lemoe.sh build`.

5. Your first run

```
termux-change-repo && pkg install termux-am && termux-setup-storage && ln -sf storage/downloads/lemoe && bash lemoe/lemoe.sh
```

> [!TIP]
> Documents and Download folders are mounted at `/media` folder for quick access.

# Usage

## Command Reference



| Command                           | Description                                                  | Defaults                                                     |
| --------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `lemoe.sh`                        | Start X11.                                                   | By default, it starts **debian**, and login as **Lemoe**. You can change this by `lemoe.sh config` |
| `lemoe.sh config distro <distro>` | Config distro.                                               | Default is **debian**. Configuration file is `.lemoe`.     |
| `lemoe.sh config user <user>`     | Config distro user.                                          | Default is **Lemoe**. Configuration file is `.lemoe`.      |
| `lemoe.sh config dpi <num>`       | Config distro DPI by specifying a number. 200 is recommended for a 2.5~3K display. | Default is 200.                                              |
| `lemoe.sh build`                  | Build custom image.                                          | Default distro is **debian**. You can change this by `lemoe.sh config`. |
| `lemoe.sh reset`                  | Remove the configured distro from installation location. You can `restore` or `build` it later. | By default, it removes the distro configured in `.lemoe`.  |
| `lemoe.sh backup`                 | Backup distro base image, distro profile and termux profile respectively. For more information, refer to the [backup](/backups/README.md) page. | By default, it saves backups as below:<br />distro image: `backups/$DISTRO-base-yyyyMMdd-hhmmss.tar.gz` <br />distro profile: `backups/$DISTRO-profile-yyyyMMdd-hhmmss.tar.gz`.<br />termux profile: `backups/termux-profile-yyyyMMdd-hhmmss.tar.gz`. |
| `lemoe.sh restore`                | Restore distro base image and distro profile respectively. For more information, refer to the [backup](/backups/README.md) page. | By default, it looks for the following files:<br />distro image: `backups/$DISTRO-base.tar.gz` <br />distro profile: `backups/$DISTRO-profile.tar.gz`. |
| `lemoe.sh login [user_name]`      | Login configured distribution in command line (bash) mode as **root**. | By default, login user is **root**.                          |
| `lemoe.sh lazypack` | Pack the current project to a lazy pack immediately, saved as zip file. | Default pack name is as `lemoe-$DISTRO-yyyyMMdd-hhmmss.zip`.<br />Default pack directory is `../lazy-packs-lemoe`. |


## Build your own image

Make sure you have good Internet connectivity to github, and run below command:

```
bash lemoe.sh build
``` 

By default, the Linux distribution is **Debian** and the user name is **Lemoe**. 

If you want different ones, run `configure` before `build`:

To configure the distribution:

```
bash lemoe.sh config distro <archlinux|debian>
```

To configure the user name:

```
bash lemoe.sh config user <your_name>
```


The configuration is saved to `.lemoe`.

# Development Guide

## Add a new app

### General Steps 

You can add your own application into the corresponding distribution folder, e.g., debian or archlinux.

To add a new app, follow the steps below:
1. Create a script file named `xx_app.sh` where **xx** is a two-digits prefix, lower nubmer higher priority; **app** is the name of the application.
2. Define the installation steps in the `install_app()` function within the script.
3. (Optional) Define the user configuration for the application in the `setup_user_app()` function within the script.

### Example

Let's take the **ime** app for example. It's defined in this file: `lemoe/debian/02_ime.sh`.

* `install_ime()` is the funcation to install the app. It runs as **root**.
  * You should replace the **ime** with your own application name.
  * You can call it with `lemoe.sh install_ime` for testing purpose.
  * During the `build` progress, it's called automatically.
* `setup_user_ime()` is the function to setup the app during the user creation process. It runs as the distro user, by default it is **Lemoe**.
  * You should replace the **ime** with your own application name.
  * You can call it with `lemoe.sh setup_user_ime` for testing purpose.
  * During the user creation process, it's called automatically.


```bash
# install software
install_ime() {
    PKGS="fcitx5 fcitx5-chinese-addons fcitx5-material-color"
    $DISTRO_LOGIN -- apt install -y $PKGS

    # export to environment
    if ! grep -q "XMODIFIERS" $DISTRO_ROOTFS/etc/environment; then
        echo "GTK_IM_MODULE=fcitx" >> $DISTRO_ROOTFS/etc/environment
        echo "QT_IM_MODULE=fcitx" >> $DISTRO_ROOTFS/etc/environment
        echo "XMODIFIERS=@im=fcitx" >> $DISTRO_ROOTFS/etc/environment
    fi
}

# post user setup after installation
setup_user_ime() {
    # auto start
    $DISTRO_LOGIN --user $DISTRO_USER -- bash -c "mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart"
}
```

# Troubleshooting

## No sound

Try the following:

1. Completely close termux and start again

2. If you are using Bluetooth headphone, disable bluetooth and try abvoe again.

> This is known issue, that the playback won't work if the BT audio device is connected and idle.

2. If still not working, run below command:

```
bash lemoe.sh fix_audio
```

This changes the `pulseaudio` module from `load-module module-sles-sink` to `load-module module-aaudio-sink`.

This works for HUAWEI devices, and is automatically applied during your fisrt run. 

For other devices, it worth a try. 

> [!NOTE]
> Remember to close `termux` completely and start over again. 

## Process completed (singal 9)

Run below commands in `adb shell` to unrestrict the process number limits:

```
device_config set_sync_disabled_for_tests persistent
device_config put activity_manager max_phantom_processes 2147483647
```
