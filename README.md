[[中文](README_CN.md)|[EN](README.md)]

# About **lemoe**

**lemoe** is short for **lemon moe** (🍋萌)

This project is inspired by tmoe.

An easy-to-use command-line tool to deploy ArchiLinux distribution with X11 in termux, with a single command. 

## Features:

* Lemoe deploys and starts up a Linux distribution with X11 with one single command.
* Lemoe uses `termux:x11` for better graphical performance, in comparison to VNC.
* Lemoe focuses on productivity, it pre-installs chromium, vscode, fcitx5, etc.
* Lemoe can **backup / restore** distribution images easily.
* Lemoe can **backup / restore** profiles easily.



# Quick Start

1. Install `Termux` or `ZeroTermux` app from your favourite app store.

2. Install the latest `termux-x11` app from [offical release](https://github.com/termux/termux-x11/releases)

3. Clone this repo

Clone the repo to the `Documents` folder on your device. Step 5 is based on this assumuption. 

```
git clone https://github.com/lesca/lemoe.git
```

4. Download distro base image

You can [download](https://github.com/lesca/lemoe/wiki/Download) the base image and put it into the `lemoe/distro_backup` folder.

Optionally, you can build your own image by running `lemoe.sh build`.

5. Your first run

```
termux-change-repo && pkg install termux-am && termux-setup-storage && ln -s storage/documents/lemoe && bash lemoe/lemoe.sh
```

> [!TIP]
> Documents and Download folders are mounted at `/media` folder for quick access.

# Usage

## Build your own image

Make sure you have good Internet connectivity to github, and run below command:

```
bash lemoe.sh build
``` 

By default, the user name is **lemoe**. If you want a different one, append it to the end, like this:

```
bash lemoe.sh build your_name
```

The user name is saved to `.lemoe_user` file for next run.

## Backup image

Run command below to backup Linux image. This includes all files in the system, as well as user's profile. The image is saved in `lemoe/distro-backup` folder.

```
bash lemoe.sh backup_distro
```

By default, the file name is `$DISTRO-base.tar.gz`, where `$DISTRO` is the distribution you set. 

For example, `DISTRO=debian`, then the file name is `debian-base.tar.gz`. If the file exists, backup will fail. You need to remove the file, or specify another name to the end of the command to create another one, like this:

```
bash lemoe.sh backup_distro name
```

In this case, it will save the image as `debian-name.tar.gz`

## Restore image

Restore the base image:

```
bash lemoe.sh restore_distro
```

Restore a custom image:

```
bash lemoe.sh restore_distro name
```

## Backup and restore profile

```
bash lemoe.sh backup_profile
```

This command saves two profiles:

* distro user profile: backup files in `$HOME` of the prrot Linux. 
  * Default file name is `$DISTRO-profile.tar.gz`.
  * This backup can be manually restored by `bash lemoe.sh restore_profile`
* termux user profile: backup files in `$HOME` of termux.
  * Default file name is `termux-profile.tar.gz`.
  * This backup is automatically used when `setup_termux` is executed. 
  * This backup can be manually restored by `bash lemoe.sh restore_termux`

Both backup files are saved in `lemoe/profile-backup` folder.

As usual, you can append your custom name to the end to create your own backup for further use or testing purpose. 

```
bash lemoe.sh backup_profile name
```

Use the same name if you want to restore it.

## Reset

Command below removes the installed Linux system completely and restore it from base image.

```
bash lemoe.sh reset
```

## Login 

By default, below command login as root.

```
bash lemoe.sh login
```

You can specify another user to login, e.g.:

```
bash lemoe.sh login Lemoe
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
