
# Backup and Restore

The default backup directory is `lemoe/backups`.

## Base images

The base images are used to restore a distribution quickly.

You should put the base image in this folder. Supported base image names are like these:

* archlinux-base.tar.gz
* debian-base.tar.gz 
* hunter-base.tar.gz - Kali

## Profile backups

In **lemoe**, there are two types of profiles:
* Distribution profile backup
* Termux profile backup

The **distribution profile backup** in this format `$DISTRO-profile-tar.gz` can be restored automatically, for example:

* archlinux-profile.tar.gz
* debian-profile.tar.gz

The **termux profile backup** in this format `termux-profile-tar.gz` is restored automatically only when **lemoe** was setup in the first time. You can manually restoer it by running this command: `lemoe.sh restore_termux`.

## Create backups with default names

This command creates all kinds of backups (distribution image backup, distribution profile backup, and termux profile backup):

```
lemoe.sh backup
```

New backups follow the naming convertions below:

* Distribution Image: $DISTRO-base-yyyyMMdd-hhmmss.tar.gz
* Distribution Profile: $DISTRO-profile-yyyyMMdd-hhmmss.tar.gz
* Termux Profile: termux-profile-yyyyMMdd-hhmmss.tar.gz

Later, you can rename them by removing the date and time to make `lemoe.sh` pick them automatically.

## Custom Backups

You can specify a **name** to replace the date and time in the naming format. Here is an example:


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

* It removes the existing distro if it's existing before restoring.
* It resotres distro image only. 
* For termux profile backup, it restores only if it's the first time to run `lemoe.sh`.

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

