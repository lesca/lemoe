
# Backup and Restore

## Base images

The base images are used to restore a distribution quickly.

You should put the base image should be in this folder. Supported based image names are like these:

* archlinux-base.tar.gz
* debian-base.tar.gz

## Profile backups

The distribution profile backup in this format `$DISTRO-profile-tar.gz` can be restored, for example:

* archlinux-profile.tar.gz
* debian-profile.tar.gz

The termux profile backup in this format `termux-profile-tar.gz` can be restored. It automatically restores only if **lemoe** was setup in the first time. You can manually restoer it by this command: `lemoe.sh restore_termux`.

## Create backups with default names

This command creates all kinds of backups metioned above.

```
lemoe.sh backup
```

New backups follow the name convertions below:

* Distro Image: $DISTRO-base-yyyyMMdd-hhmmss.tar.gz
* Distro Profile: $DISTRO-profile-yyyyMMdd-hhmmss.tar.gz
* Termux Profile: termux-profile-yyyyMMdd-hhmmss.tar.gz

Later, you can rename them by removing the date and time to make **lemoe** pick them automatically.

## Create and Restore Custom Backups

However, you can specify a **name** to replace the date and time format. Here is an example:


```
lemoe.sh backup mybackup
```

New backups are named like this:

* Distro Image: $DISTRO-base-mybackup.tar.gz
* Distro Profile: $DISTRO-profile-mybackup.tar.gz
* Termux Profile: termux-profile-mybackup.tar.gz

You can restore distro backups with `lemoe.sh restore mybackup`. It resotres distro image and distro profile backups.

