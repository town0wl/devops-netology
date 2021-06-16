## ДЗ 3.5

1.
Разреженный файл - файл, в котором последовательности нулевых байтов не хранятся напрямую на диске, а заменены на информацию о них (смещение от начала файла и количество нулевых байт), хранимую в метаданных файловой системы. Поддерживается большинством распространенных файловых систем, в том числе NTFS, ext2, ext3, ext4. 

2.
Не могут, так как владелец и права являются атрибутами одного файлового объекта, на который имеется две жесткие ссылки. Уникальным идентификатором для файлового объекта будет inode.

4.
```
root@vagrant:/home/vagrant# fdisk /dev/sdb

Command (m for help): p

Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x5e313382

Command (m for help): F

Unpartitioned space /dev/sdb: 2.51 GiB, 2683305984 bytes, 5240832 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes

Start     End Sectors  Size
 2048 5242879 5240832  2.5G

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-5242879, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 2
First sector (4196352-5242879, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): F
Unpartitioned space /dev/sdb: 0 B, 0 bytes, 0 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes

Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x5e313382

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

5.
```
root@vagrant:/home/vagrant# sfdisk -d /dev/sdb
label: dos
label-id: 0x5e313382
device: /dev/sdb
unit: sectors

/dev/sdb1 : start=        2048, size=     4194304, type=83
/dev/sdb2 : start=     4196352, size=     1046528, type=83
root@vagrant:/home/vagrant# sfdisk -d /dev/sdc
sfdisk: /dev/sdc: does not contain a recognized partition table
root@vagrant:/home/vagrant# sfdisk -d /dev/sdb | sfdisk /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0x5e313382.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x5e313382

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
root@vagrant:/home/vagrant# sfdisk -d /dev/sdc
label: dos
label-id: 0x5e313382
device: /dev/sdc
unit: sectors

/dev/sdc1 : start=        2048, size=     4194304, type=83
/dev/sdc2 : start=     4196352, size=     1046528, type=83
root@vagrant:/home/vagrant#
```

6.
```
root@vagrant:/home/vagrant# ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sda5  /dev/sdb  /dev/sdb1  /dev/sdb2  /dev/sdc  /dev/sdc1  /dev/sdc2
root@vagrant:/home/vagrant# mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? (y/n) y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
root@vagrant:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
      [=======>.............]  resync = 38.4% (805504/2094080) finish=0.1min speed=201376K/sec

unused devices: <none>
```
7.
```
root@vagrant:/home/vagrant# mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
root@vagrant:/home/vagrant#
root@vagrant:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md0 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks

md1 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]

unused devices: <none>
```

8.
```
root@vagrant:/home/vagrant# pvs
  PV         VG        Fmt  Attr PSize   PFree
  /dev/sda5  vgvagrant lvm2 a--  <63.50g    0
root@vagrant:/home/vagrant# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda5
  VG Name               vgvagrant
  PV Size               <63.50 GiB / not usable 0
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              16255
  Free PE               0
  Allocated PE          16255
  PV UUID               uMWVeB-SwGW-y0XL-7DKQ-fN0L-zsHh-SIBf2y

root@vagrant:/home/vagrant# pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
root@vagrant:/home/vagrant# pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
root@vagrant:/home/vagrant# pvs
  PV         VG        Fmt  Attr PSize    PFree
  /dev/md0             lvm2 ---  1018.00m 1018.00m
  /dev/md1             lvm2 ---    <2.00g   <2.00g
  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0
root@vagrant:/home/vagrant# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda5
  VG Name               vgvagrant
  PV Size               <63.50 GiB / not usable 0
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              16255
  Free PE               0
  Allocated PE          16255
  PV UUID               uMWVeB-SwGW-y0XL-7DKQ-fN0L-zsHh-SIBf2y

  "/dev/md0" is a new physical volume of "1018.00 MiB"
  --- NEW Physical volume ---
  PV Name               /dev/md0
  VG Name
  PV Size               1018.00 MiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               KB4FVy-Kkvn-LfoK-X1hj-qNV1-3ISW-a5PVXM

  "/dev/md1" is a new physical volume of "<2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/md1
  VG Name
  PV Size               <2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               dVBn6g-hHE0-g5jz-FB8U-aKDv-3CB8-LH53En
```


9.
```
root@vagrant:/home/vagrant# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  vgvagrant   1   2   0 wz--n- <63.50g    0
root@vagrant:/home/vagrant# vgdisplay
  --- Volume group ---
  VG Name               vgvagrant
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <63.50 GiB
  PE Size               4.00 MiB
  Total PE              16255
  Alloc PE / Size       16255 / <63.50 GiB
  Free  PE / Size       0 / 0
  VG UUID               7BSgp8-ukNs-898j-wRdT-jDVA-TLU9-sSZ36F

root@vagrant:/home/vagrant# vgcreate justvg /dev/md0 /dev/md1
  Volume group "justvg" successfully created
root@vagrant:/home/vagrant# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  justvg      2   0   0 wz--n-  <2.99g <2.99g
  vgvagrant   1   2   0 wz--n- <63.50g     0
root@vagrant:/home/vagrant# vgdisplay
  --- Volume group ---
  VG Name               vgvagrant
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <63.50 GiB
  PE Size               4.00 MiB
  Total PE              16255
  Alloc PE / Size       16255 / <63.50 GiB
  Free  PE / Size       0 / 0
  VG UUID               7BSgp8-ukNs-898j-wRdT-jDVA-TLU9-sSZ36F

  --- Volume group ---
  VG Name               justvg
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <2.99 GiB
  PE Size               4.00 MiB
  Total PE              765
  Alloc PE / Size       0 / 0
  Free  PE / Size       765 / <2.99 GiB
  VG UUID               xxBBdq-hx0U-S3Ny-6l3W-Y1ES-iWzc-Qn2ge3
```

10.
```
root@vagrant:/home/vagrant# lvs
  LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   vgvagrant -wi-ao---- <62.54g
  swap_1 vgvagrant -wi-ao---- 980.00m
root@vagrant:/home/vagrant# lvdisplay
  --- Logical volume ---
  LV Path                /dev/vgvagrant/root
  LV Name                root
  VG Name                vgvagrant
  LV UUID                8oG9Wg-njJx-buVu-ewPB-P2gy-TRC7-yLRu5Z
  LV Write Access        read/write
  LV Creation host, time vagrant, 2021-05-25 05:42:42 +0000
  LV Status              available
  # open                 1
  LV Size                <62.54 GiB
  Current LE             16010
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/vgvagrant/swap_1
  LV Name                swap_1
  VG Name                vgvagrant
  LV UUID                OXf1hc-6u1q-Fanf-X8xq-B45n-eZgs-65c8nD
  LV Write Access        read/write
  LV Creation host, time vagrant, 2021-05-25 05:42:42 +0000
  LV Status              available
  # open                 2
  LV Size                980.00 MiB
  Current LE             245
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1

root@vagrant:/home/vagrant# lvcreate -L 100M -n lv_raid0 justvg /dev/md0
  Logical volume "lv_raid0" created.
root@vagrant:/home/vagrant# lvs
  LV       VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv_raid0 justvg    -wi-a----- 100.00m
  root     vgvagrant -wi-ao---- <62.54g
  swap_1   vgvagrant -wi-ao---- 980.00m
root@vagrant:/home/vagrant# lvdisplay
  --- Logical volume ---
  LV Path                /dev/vgvagrant/root
  LV Name                root
  VG Name                vgvagrant
  LV UUID                8oG9Wg-njJx-buVu-ewPB-P2gy-TRC7-yLRu5Z
  LV Write Access        read/write
  LV Creation host, time vagrant, 2021-05-25 05:42:42 +0000
  LV Status              available
  # open                 1
  LV Size                <62.54 GiB
  Current LE             16010
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/vgvagrant/swap_1
  LV Name                swap_1
  VG Name                vgvagrant
  LV UUID                OXf1hc-6u1q-Fanf-X8xq-B45n-eZgs-65c8nD
  LV Write Access        read/write
  LV Creation host, time vagrant, 2021-05-25 05:42:42 +0000
  LV Status              available
  # open                 2
  LV Size                980.00 MiB
  Current LE             245
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/justvg/lv_raid0
  LV Name                lv_raid0
  VG Name                justvg
  LV UUID                9Nh0HP-Spvf-x6PR-vTiZ-WQGm-60Ms-98BgQ2
  LV Write Access        read/write
  LV Creation host, time vagrant, 2021-06-16 13:22:56 +0000
  LV Status              available
  # open                 0
  LV Size                100.00 MiB
  Current LE             25
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     4096
  Block device           253:2
```

11.
```
root@vagrant:/home/vagrant# mkfs.ext4 /dev/justvg/lv_raid0
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```

12.
```
root@vagrant:/home/vagrant# mount /dev/justvg/lv_raid0 /mnt/raid0
root@vagrant:/home/vagrant# mount | grep 'raid0'
/dev/mapper/justvg-lv_raid0 on /mnt/raid0 type ext4 (rw,relatime,stripe=256)
```

13.
```
root@vagrant:/home/vagrant# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /mnt/raid0/test.gz
--2021-06-16 13:36:27--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 20893574 (20M) [application/octet-stream]
Saving to: ‘/mnt/raid0/test.gz’

/mnt/raid0/test.gz         100%[=======================================>]  19.92M  5.77MB/s    in 3.5s

2021-06-16 13:36:30 (5.77 MB/s) - ‘/mnt/raid0/test.gz’ saved [20893574/20893574]

root@vagrant:/home/vagrant# ls -l /mnt/raid0/
total 20420
drwx------ 2 root root    16384 Jun 16 13:31 lost+found
-rw-r--r-- 1 root root 20893574 Jun 16 12:26 test.gz
```

14.
```
root@vagrant:/home/vagrant# lsblk
NAME                  MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                     8:0    0   64G  0 disk
├─sda1                  8:1    0  512M  0 part  /boot/efi
├─sda2                  8:2    0    1K  0 part
└─sda5                  8:5    0 63.5G  0 part
  ├─vgvagrant-root    253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1  253:1    0  980M  0 lvm   [SWAP]
sdb                     8:16   0  2.5G  0 disk
├─sdb1                  8:17   0    2G  0 part
│ └─md1                 9:1    0    2G  0 raid1
└─sdb2                  8:18   0  511M  0 part
  └─md0                 9:0    0 1018M  0 raid0
    └─justvg-lv_raid0 253:2    0  100M  0 lvm   /mnt/raid0
sdc                     8:32   0  2.5G  0 disk
├─sdc1                  8:33   0    2G  0 part
│ └─md1                 9:1    0    2G  0 raid1
└─sdc2                  8:34   0  511M  0 part
  └─md0                 9:0    0 1018M  0 raid0
    └─justvg-lv_raid0 253:2    0  100M  0 lvm   /mnt/raid0
```

15.
```
root@vagrant:/home/vagrant# gzip -t /mnt/raid0/test.gz
root@vagrant:/home/vagrant# echo $?
0
```

16.
```
root@vagrant:/home/vagrant# pvmove -v /dev/md0 /dev/md1
  Executing: /sbin/modprobe dm-mirror
  Archiving volume group "justvg" metadata (seqno 2).
  Creating logical volume pvmove0
  activation/volume_list configuration setting not defined: Checking only host tags for justvg/lv_raid0.
  Moving 25 extents of logical volume justvg/lv_raid0.
  activation/volume_list configuration setting not defined: Checking only host tags for justvg/lv_raid0.
  Creating justvg-pvmove0
  Loading table for justvg-pvmove0 (253:3).
  Loading table for justvg-lv_raid0 (253:2).
  Suspending justvg-lv_raid0 (253:2) with device flush
  Resuming justvg-pvmove0 (253:3).
  Resuming justvg-lv_raid0 (253:2).
  Creating volume group backup "/etc/lvm/backup/justvg" (seqno 3).
  activation/volume_list configuration setting not defined: Checking only host tags for justvg/pvmove0.
  Checking progress before waiting every 15 seconds.
  /dev/md0: Moved: 100.00%
  Polling finished successfully.
root@vagrant:/home/vagrant# lvs -a -o+devices
  LV       VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices
  lv_raid0 justvg    -wi-ao---- 100.00m                                                     /dev/md1(0)
  root     vgvagrant -wi-ao---- <62.54g                                                     /dev/sda5(0)
  swap_1   vgvagrant -wi-ao---- 980.00m                                                     /dev/sda5(16010)  
```

17.
```
root@vagrant:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md0 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks

md1 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]

unused devices: <none>
root@vagrant:/home/vagrant# mdadm --fail /dev/md1 /dev/sdc1
mdadm: set /dev/sdc1 faulty in /dev/md1
root@vagrant:/home/vagrant# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md0 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks

md1 : active raid1 sdc1[1](F) sdb1[0]
      2094080 blocks super 1.2 [2/1] [U_]

unused devices: <none>
```

18.
```
root@vagrant:/home/vagrant# dmesg | tail -n 5
[ 3956.869153] md: md1: data-check done.
[ 6898.398928] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: (null)
[ 6898.398933] ext4 filesystem being mounted at /mnt/raid0 supports timestamps until 2038 (0x7fffffff)
[ 9463.817585] md/raid1:md1: Disk failure on sdc1, disabling device.
               md/raid1:md1: Operation continuing on 1 devices.
```

19.
```
root@vagrant:/home/vagrant# ls -lh /mnt/raid0/test.gz
-rw-r--r-- 1 root root 20M Jun 16 12:26 /mnt/raid0/test.gz
root@vagrant:/home/vagrant# gzip -t /mnt/raid0/test.gz
root@vagrant:/home/vagrant# echo $?
0
```



## ДЗ 3.2 дополнение
6.\
/dev/tty is a special file, representing the terminal for the current process. It is a synonym for the controlling terminal of a process, if any.\
echo 333 > /dev/tty выводит в текущий терминал, как в графическом режиме, так и без него

/dev/ttyX\
ps aux | grep tty\
root         557  0.0  0.0   5784  1732 tty1     Ss+  02:27   0:00 /sbin/agetty -o -p -- \u --noclear tty1 linux\
root         558  0.5  4.0 877740 81372 tty7     Ssl+ 02:27   0:02 /usr/lib/xorg/Xorg :0 -seat seat0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch\
echo 111 > /dev/tty1 - ничего не выводится\
echo 777 > /dev/tty7 - ничего не выводится\
cat /dev/tty1 - ничего не выводится, в том числе если попользоваться графическими приложениями\
cat /dev/tty7 - ничего не выводится, в том числе если попользоваться графическими приложениями

/dev/ttySX\
ttyS0-ttyS3 write error: Input/output error\
в ttyS4 и выше можно вывести, потом прочитать\
echo 555 > /dev/ttyS4\
cat /dev/ttyS4


## ДЗ 3.4

1.\
$ systemctl cat node_exporter\
\# /etc/systemd/system/node_exporter.service\
[Unit]\
Description=Node Exporter\
Wants=network-online.target\
After=network-online.target

[Service]\
User=node_exporter\
Group=node_exporter\
Type=simple\
EnvironmentFile=-/etc/default/node_exporter\
ExecStart=/opt/node_exp/node_exporter $EXTRA_OPTS

[Install]\
WantedBy=multi-user.target

$ systemctl status node_exporter\
● node_exporter.service - Node Exporter\
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)\
     Active: active (running) since Sun 2021-06-06 06:33:25 UTC; 6min ago\
   Main PID: 783 (node_exporter)\
      Tasks: 5 (limit: 1072)\
     Memory: 12.9M\
     CGroup: /system.slice/node_exporter.service\
             └─783 /opt/node_exp/node_exporter

Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=thermal_zone\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=time\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=timex\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=udp_queues\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=uname\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=vmstat\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.828Z caller=node_exporter.go:113 collector=xfs\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.829Z caller=node_exporter.go:113 collector=zfs\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.829Z caller=node_exporter.go:195 msg="Listening on" address=:9100\
Jun 06 06:33:25 vagrant node_exporter[783]: level=info ts=2021-06-06T06:33:25.829Z caller=tls_config.go:191 msg="TLS is disabled." http2=false

2.\
--collector.uname          Enable the uname collector (default: enabled).    Exposes system information as provided by the uname system call.\
--collector.time           Enable the time collector (default: enabled).    Exposes the current system time.\
--collector.cpu.info       Enables metric cpu_info\
--collector.cpu            Enable the cpu collector (default: enabled).        Exposes CPU statistics\
--collector.diskstats      Enable the diskstats collector (default: enabled).    Exposes disk I/O statistics.\
--collector.filesystem     Enable the filesystem collector (default: enabled).    Exposes filesystem statistics, such as disk space used.\
--collector.loadavg        Enable the loadavg collector (default: enabled).    Exposes load average.\
--collector.meminfo        Enable the meminfo collector (default: enabled).    Exposes memory statistics.\
--collector.netclass       Enable the netclass collector (default: enabled).    Exposes network interface info from /sys/class/net/\
--collector.netdev         Enable the netdev collector (default: enabled).    Exposes network interface statistics such as bytes transferred.\
Перечисленные коллекторы включены по умолчанию, поэтому можно просто не менять дефолтные опции. Но если нужно отключить сбор остальных метрик, кроме выбранных:\
--collector.disable-defaults    Set all collectors to disabled by default.

3.\
cpu - процентная загрузка CPU суммарно (от 0 до 100%)\
load - загрузка CPU в единицах CPU, усредненнная за 1, 5 и 15 минут\
disk - суммарная загрузка I/O KiB/s\
ram - загрузка памяти MiB free/used/cached/buffers\
swap - MiB free/used\
network - kilobits/s received/sent суммарно/IP/IPv6\
processes - системные и суммарно\
и другие\
а также разбивки по контекстам, пользователям, состояниям, типам операций, файловым системам, сетевым протоколам, интерфейсам и пр.

4.\
Да, по наличию строки "Hypervisor detected:" :\
$ dmesg | grep "Hypervisor detected"\
[    0.000000] Hypervisor detected: KVM

5.\
fs.nr_open = 1048576\
/proc/sys/fs/nr_open содержит значение параметра ядра, ограничивающее максимальное количество файлов, которое может быть открыто процессом.\
Фактически максимальное количество файлов ограничивается лимитом RLIMIT_NOFILE (который не может превышать fs.nr_open), который можно установить в /etc/security/limits.conf:\
{\<user>|@\<group>}    {hard|soft|-}    nofile    10000\
А также временно установить в текущей сессии (на значение не выше текущего hard limit):\
ulimit -[HS]n 10000

6.\
\# unshare -f --pid --mount-proc sleep 111111 &\
\# ps aux | grep sleep\
root        1927  0.0  0.0   8080   596 pts/0    S    19:28   0:00 unshare -f --pid --mount-proc sleep 111111\
root        1928  0.0  0.0   8076   596 pts/0    S    19:28   0:00 sleep 111111\
\# nsenter --target 1928 --pid --mount\
/# ps aux\
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND\
root           1  0.0  0.0   8076   596 pts/0    S    19:28   0:00 sleep 111111\
root           2  0.0  0.4   9836  4084 pts/0    S    19:29   0:00 -bash\
root          11  0.0  0.3  11492  3260 pts/0    R+   19:29   0:00 ps aux\
/# lsns\
        NS TYPE   NPROCS PID USER COMMAND\
4026531835 cgroup      3   1 root sleep 111111\
4026531837 user        3   1 root sleep 111111\
4026531838 uts         3   1 root sleep 111111\
4026531839 ipc         3   1 root sleep 111111\
4026531992 net         3   1 root sleep 111111\
4026532188 mnt         3   1 root sleep 111111\
4026532189 pid         3   1 root sleep 111111\
/# exit\
\# lsns\
        NS TYPE   NPROCS   PID USER            COMMAND\
4026531835 cgroup    113     1 root            /sbin/init\
4026531836 pid       112     1 root            /sbin/init\
4026531837 user      113     1 root            /sbin/init\
4026531838 uts       111     1 root            /sbin/init\
4026531839 ipc       113     1 root            /sbin/init\
4026531840 mnt        99     1 root            /sbin/init\
4026531860 mnt         1    21 root            kdevtmpfs\
4026531992 net       113     1 root            /sbin/init\
4026532162 mnt         1   396 root            /lib/systemd/systemd-udevd\
4026532163 uts         1   396 root            /lib/systemd/systemd-udevd\
4026532164 mnt         1   405 systemd-network /lib/systemd/systemd-networkd\
4026532183 mnt         1   561 systemd-resolve /lib/systemd/systemd-resolved\
4026532184 mnt         5   787 netdata         /usr/sbin/netdata -D\
4026532186 mnt         1  1712 root            /usr/libexec/fwupd/fwupd\
4026532188 mnt         2  1927 root            unshare -f --pid --mount-proc sleep 111111\
4026532189 pid         1  1928 root            sleep 111111\
4026532247 uts         1   617 root            /lib/systemd/systemd-logind\
4026532249 mnt         1   608 root            /usr/sbin/irqbalance --foreground\
4026532250 mnt         1   617 root            /lib/systemd/systemd-logind

7.\
:(){ :|:& };:\
Создание функции, которая вызывает два экземпляра себя в фоне, + ее вызов.

] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-4.scope\
] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-23.scope

Ограничение максимального количества процессов в cgroup user-1000.slice:\
$ cat /sys/fs/cgroup/pids/user.slice/user-1000.slice/pids.max\
2359\
$ systemctl status user-1000.slice\
Tasks: 15 (limit: 2359)\
Можно настроить в файлах конфигурации юнитов systemd в TasksMax:\
$ systemctl cat user-1000.slice\
\# /usr/lib/systemd/system/user-.slice.d/10-defaults.conf\
...\
[Slice]\
TasksMax=33%\
(TasksMax= и DefaultTasksMax= могут быть заданы как число или процент от меньшего из /proc/sys/kernel/pid_max, /proc/sys/kernel/threads-max, /sys/fs/cgroup/pids.max)

Также есть ограничение максимального количества процессов на пользователя RLIMIT_NPROC:\
$ ulimit -Su\
3575\
Если поставить его ниже pids.max, поведение системы при запуске функции будет аналогичным, но без сообщения 'cgroup: fork rejected by pids controller' в dmesg:\
$ ulimit -Su\
1234



## ДЗ 3.3
1.\
stat("/tmp", {st_mode=S_IFDIR|S_ISVTX|0777, st_size=4096, ...}) = 0\
chdir("/tmp")

2.\
/usr/share/misc/magic.mgc -> ../../lib/file/magic.mgc

3.\
ls -l /proc/\<pid>/fd\
Для дескпритора, связанного с проблемным файлом:\
\> /proc/\<pid>/fd/\<number>

4.\
Зомби процессы не занимают CPU, RAM, IO, занимают только строчку в таблице процессов.

5.\
PID    COMM               FD ERR PATH\
1      systemd            12   0 /proc/400/cgroup\
773    vminfo              4   0 /var/run/utmp\
592    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services\
592    dbus-daemon        18   0 /usr/share/dbus-1/system-services\
592    dbus-daemon        -1   2 /lib/dbus-1/system-services\
592    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/

6.\
uname({sysname="Linux", nodename="vagrant", ...}) = 0\
/proc/sys/kernel/{ostype,hostname,osrelease,version,domainname}\
       Part of the utsname information is also accessible via\
       /proc/sys/kernel/{ostype, hostname, osrelease, version,\
       domainname}.

7.\
Команды через ; выполняются последовательно как отдельные команды. Через && - последующая команда выполняется при успешном коде завершения первой.\
&& можно использовать с set -e. При использовании set -e шелл будет закрыт сразу после возврата какой-нибудь командой кода завершения с ошибкой (>0). Но в последовательностях команд с && и || будет учитываться статус только последней команды.

8.\
set -euxo pipefail\
Опции -eo pipefail прерывают выполнение скрипта в случае неуспешного кода завершения какой-либо команды, включая команды в пайплайнах, но исключая команды составных команд, следующих за while, until, if, or elif, и непоследние команды в последовательностях && и ||. Опция -u прерывает выполнение скрипта при попытке обращения к неустановленным переменным (но при необходимости можно ${a:-}). Это опции защищают от продолжения выполнения скрипта после непредусмотренной ошибки.\
-x - выводит каждую команду перед выполнением, но после всех подстановок, что позволяет определить место ошибки.

9.\
ps -axh -o stat | grep ^S | wc -l\
S - 59\
I - 47\
R - 1\
Z - 1

D    uninterruptible sleep (usually IO)\
I    Idle kernel thread\
R    running or runnable (on run queue)\
S    interruptible sleep (waiting for an event to complete)\
T    stopped by job control signal\
t    stopped by debugger during the tracing\
W    paging (not valid since the 2.6.xx kernel)\
X    dead (should never be seen)\
Z    defunct ("zombie") process, terminated but not reaped by its parent

<    high-priority (not nice to other users)\
N    low-priority (nice to other users)\
L    has pages locked into memory (for real-time and custom IO)\
s    is a session leader\
l    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)\
\+    is in the foreground process group



## ДЗ 3.2
1.\
$ type -t cd\
builtin

cd сменяет текущую директирию в shell-сессии. Если бы она не была встроенного типа, пришлось бы дополнительно организовать обмен данными между cd и bash и смену директории в bash на основе полученных данных.

2.\
grep -с <some_string> <some_file>

3.\
systemd\
(/sbin/init -> /lib/systemd/systemd)

4.\
ls something 2>/dev/pts/1

5.\
$ cat \<log >newfile

6.\
Итак, я нахожусь в стороннем PTY(/dev/pts/1) и хочу вывести данные в TTY, который открыт в графическом режиме (/dev/pts/0).\
echo 12345456 > /dev/pts/0\
Или я нахожусть в графическом режиме в TTY (/dev/pts/0) и хочу получить данные из стороннего PTY(/dev/pts/1).\
cat /dev/pts/1\
При этом часть данных попадает в /dev/pts/0, а часть остается в /dev/pts/1\
cat /dev/pts/1 | tee /dev/pts/1\
Дает более интересный эффект - данные дублируются и там, и там, но pts/1 не работает адекватно\
Или что имелось в виду?

7.\
bash 5>&1\
Запускает баш с перенаправлением данных из файлового дескриптора 5 в stdout, а именно в /dev/pts/1.

echo netology > /proc/$$/fd/5\
Отправим данных в fd 5 и они выведутся в /dev/pts/1.

8.\
ls log kdsksdklog 3>&2 2>&1 1>&3 | grep --color log\
log\
ls: cannot access 'kdsksdklog': No such file or directory

9.\
/proc/$$/environ содержит переменные окружения, установленные на момент старта процесса. Данные в файле не обновляются при последующих изменениях переменных.\
cat /proc/$$/environ | tr '\000' '\n'

Аналогичные, но обновляемые, актуальные данные можно получить:\
env\
printenv\
set

10.\
/proc/\<PID\>/cmdline - полная командная строка запуска процесса или, для зомби процессов, пусто\
/proc/\<PID\>/exe - символическая ссылка на исполняемый файл процесса

11.\
SSE4.2

12.\
tty выводит имя терминала, связанного с stdin. При выполнении команды через SSH терминал не создается. Stdin имеет вид: /proc/2939/fd/0 -> pipe:[84091]

13.\
\# echo 0 > /proc/sys/kernel/yama/ptrace_scope

$ nc -l 3333\
^Z\
[1]+  Stopped                 nc -l 3333

vagrant     2454    1669  0 19:01 pts/1    00:00:00 nc -l 3333

$ disown 2454

vagrant     2454    1669  0 19:01 pts/1    00:00:00 nc -l 3333

(screen) $ reptyr 2454

vagrant     2454    1669  0 19:01 pts/0    00:00:00 nc -l 3333\
vagrant     2468    2256  0 19:04 pts/2    00:00:00 reptyr 2454

14.\
sudo echo string > /root/new_file\
echo string | sudo tee /root/new_file\
tee выводит stdin в файл и дублирует в stdout\
При использовании tee файл /root/new_file открывается с правами tee, которая запущена с sudo - с правами root.


## ДЗ 3.1

5.
vagrant_default_xxxxxxxxxxxxx_xxxxx\
1024 MB RAM\
2 CPU cores 100% +Enable PAE/NX -Enable Nested VT-x/AMD-V\
1 dynamic SATA vmdk 64 GB\
NAT network, port 22 to 127.0.0.1:2222\
1 display 4 MB\
No audio, USB, COM

6.
config.vm.provider "virtualbox" do |vb|\
  vb.memory = 2048\
  vb.cpus = 3\
end

8.
1) переменная HISTSIZE\
history-size (unset)\
       Set  the maximum number of history entries saved in the history list.  If set to zero, any existing history entries are deleted and no new entries are saved.  If set to a value less
       than zero, the number of history entries is not limited.  By default, the number of history entries is set to the value of the HISTSIZE shell variable.  If an attempt is made to set
       history-size to a non-numeric value, the maximum number of history entries will be set to 500.
2) ignoreboth в составе переменной HISTCONTROL приводит к несохранению в history команд, начинающихся с пробела, и команд, совпадающих с последней строкой history

9.
1) Для группировки команд и выполнения их в текущем контексте, в том числе для формирования тела функций:\
	{ list; }\
       list  is  simply  executed in the current shell environment.  list must be terminated with a newline or semicolon.  This is known as a group com‐
       mand.  The return status is the exit status of list.  Note that unlike the metacharacters ( and ), { and } are  reserved  words  and  must  occur
       where a reserved word is permitted to be recognized.  Since they do not cause a word break, they must be separated from list by whitespace or an‐
       other shell metacharacter.

2) brace expansion для генерации строк из перечислений и дипазонов\
	Brace Expansion\
		Brace expansion is a mechanism by which arbitrary strings may be generated. This mechanism is similar to pathname expansion, but the filenames generated need not exist. Patterns to be brace expanded take the form of an optional preamble, followed by either a series of comma-separated strings or a sequence expression between a pair of braces, followed by an optional postscript. The preamble is prefixed to each string contained within the braces, and the postscript is then appended to each resulting string, expanding left to right.
		Brace expansions may be nested. The results of each expanded string are not sorted; left to right order is preserved. For example, a{d,c,b}e expands into 'ade ace abe'.
		A sequence expression takes the form {x..y[..incr]}, where x and y are either integers or single characters, and incr, an optional increment, is an integer. When integers are supplied, the expression expands to each number between x and y, inclusive. Supplied integers may be prefixed with 0 to force each term to have the same width. When either x or y begins with a zero, the shell attempts to force all generated terms to contain the same number of digits, zero-padding where necessary. When characters are supplied, the expression expands to each character lexicographically between x and y, inclusive. Note that both x and y must be of the same type. When the increment is supplied, it is used as the difference between each term. The default increment is 1 or -1 as appropriate. 

3) в рамках конструкции ${} в parameter expansion\
${parameter}\
    The value of parameter is substituted. The braces are required when parameter is a positional parameter with more than one digit, or when parameter is followed by a character which is not to be interpreted as part of its name.

4) 
	Each redirection that may be preceded by a file descriptor number may instead be preceded by a word of the form {varname}. In this case, for each redirection operator except >&- and <&-, the shell will allocate a file descriptor greater than 10 and assign it to varname. If >&- or <&- is preceded by {varname}, the value of varname defines the file descriptor to close.

5) Управление форматом строки приглашения bash\
    \D{format} \
		the format is passed to strftime(3) and the result is inserted into the prompt string; an empty format results in a locale-specific time representation. The braces are required 

10.
$ touch f{01..100000}\
$ touch {1..300000}\
-bash: /usr/bin/touch: Argument list too long

$ getconf ARG_MAX\
2097152\
$ echo {1..300000} | wc -c\
1988895\
почему?..

11.\
       [[ expression ]]\
              Return  a status of 0 or 1 depending on the evaluation of the conditional expression expression.  Expressions are composed of the primaries described below under CONDITIONAL EXPRES‐
              SIONS.  Word splitting and pathname expansion are not performed on the words between the [[ and ]]; tilde expansion, parameter and variable expansion, arithmetic expansion,  command
              substitution, process substitution, and quote removal are performed.  Conditional operators such as -f must be unquoted to be recognized as primaries.
			  
[[ -d /tmp ]] - проверяет, что существует директория /tmp

12.
$ echo $PATH\
/tmp/new_path_directory:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\
$ type -a bash\
bash is /tmp/new_path_directory/bash\
bash is /usr/bin/bash\
bash is /bin/bash

13.
at - выполняет задание в явно указанное время\
batch - выполняет задание, когда загрузка CPU падает ниже порогового значения
