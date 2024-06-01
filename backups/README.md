
# Backup and Restore

The default backup directory is `lemoe/backups`.

It contains three types of backups:
* Base image backup: the Linux system image backup
* Distro user profile backup: It contains dot files and folder in user's `$HOME` folder of the proot Linux, e.g., `.config` and `.bashrc` etc.
* Termux user profile backup: It contains dot files and folder in Termux's `$HOME` folder, e.g., termux configurations in `.termux` folder.

## Base images

The base images are used to restore a distribution quickly.

You should put the base image in this folder. Supported base image names are like these:

* archlinux-base.tar.gz
* debian-base.tar.gz 
* hunter-base.tar.gz - Kali

The command below restores both base image and its corresponding profile backup:

```
lemoe.sh restore
```

If you want to restore base image and its profile manually, run like this:

```
lemoe.sh restore_distro
lemoe.sh restore_profile
```

## Profile backups

In **lemoe**, there are two types of profiles:
* Distribution profile backup
* Termux profile backup

### distribution profile backup
The **distribution profile backup** in this format `$DISTRO-profile-tar.gz` can be restored automatically when the base image is restored. 

Here are some examples of the profile backup:

* archlinux-profile.tar.gz
* debian-profile.tar.gz

You can manually restoer the termux profile by running this command: 

```
lemoe.sh restore_profile
```

### termux profile backup
The default **termux profile backup** is named as `termux-profile-tar.gz`. 

For the first run, if `.config` folder is missing in the Termux's environment, it will be restored automatically.

You can manually restoer the termux profile by running this command: 

```
lemoe.sh restore_termux
```

## Create Backups with default names

This command creates all kinds of backups (distribution image backup, distribution profile backup, and termux profile backup):

```
lemoe.sh backup
```

Without specifing a custom name, new backups follow the naming convertions as below:

* Distribution Image: $DISTRO-base-yyyyMMdd-hhmmss.tar.gz
* Distribution Profile: $DISTRO-profile-yyyyMMdd-hhmmss.tar.gz
* Termux Profile: termux-profile-yyyyMMdd-hhmmss.tar.gz

Later, you can rename them by removing the date and time to make `lemoe.sh` pick them automatically.

## Custom Backups

You can specify a **custom name** to replace the date and time in the naming format. Here is an example:


```
lemoe.sh backup mybackup
```

New backups are named like this:

* Distribution Image: $DISTRO-base-mybackup.tar.gz
* Distribution Profile: $DISTRO-profile-mybackup.tar.gz
* Termux Profile: termux-profile-mybackup.tar.gz

You can restore the backups with 

```
lemoe.sh restore mybackup
```

* It removes the existing proot distro if it's existed before restoring.
* When you restore a custom backup, it resotres the distro image only. It is because the profile backup is part of the image that you just backed up.

To backup and restore manually, you can run:
```
# backup
lemoe.sh backup_distro mybackup
lemoe.sh backup_profile mybackup
lemoe.sh backup_termux mybackup

# restore
lemoe.sh restore_distro mybackup
lemoe.sh restore_profile mybackup
lemoe.sh restore_termux mybackup
```

