# Macbook Pro 11,3 {Status = Development}

You can follow the 'Readme.me' file and carry the set-up step by step or run the automated scripts. 
There are 3 scripts (pre, post and package install).

## Installation Instructions

### Setting the font

Macbook Pro have HiDPI which makes reading the text hard. To make it readable.

```{bash}
setfont latarcyrheb-sun32
```
If the system is not connected to internet through LAN, it can be connected using wifi
```
wifi-menu
```

Git is not available in the start which can be installed using:

```{bash}
pacman -Sy git
```

### Disk Preparation 

Following is my disk set-up. I am choosing not to create a special partition for swap file. If swap is required in the future, I plan to create a swap file.

| Size | Mount Point | Partition | Format | Partition Code |
|---|---|---|---|---|
| 500MB | /boot | nvme0n1p1 | FAT32 | UEFI Boot Partition |
| 150GB | macOS | nvmeon1p2 | AFPS | macOS | 
| 50GB | / | nvme0n1p3 | ext4 | Linux File System |
| 100GB | /home | nvme0n1p4| ext4 | Linux Home System |

```{bash}
cgdisk /dev/nvme0n1
```

#### Formatting the Drives

```{bash}
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 -l main /dev/sda2
```

### Mounting drives for install
```{bash}
mount /dev/sda2 /mnt
mkdir /mnt/boot && mount /dev/sda1 /mnt/boot
lsblk 
```

**lsblk** allows you to look at the structure of the disk.

### Installing Arch Linux files

```{bash}
pacstrap /mnt base base-devel nano intel-ucode sudo networkmanager wpa_supplicant  git util-linux sway wlroots wayland swaylock swayidle termite mako grim slurp wl-clipboard
```

| Package | Purpose |
|---|---|
| base | The required one with base utils. |
| base-devel | Development tools |
| intel-ucode | |
| sudo | To run superuser commands without changing the suer |
| networkmanager | Package to manage network connections |
| wpa_supplicant | |
| git | |
| util-linux | |
| sway | Wayland based tiling windows manager and 100% compatible with i3 |
| wlroots | Required by wayland |
| wayland | The new Xorg compositor |
| swaylock | Sway's addon to allow system lock down with idle |
| swayidle | | 
| termite | Terminal application |
| mako | Notification Daemon |
| nano | text editor|
| grim + slurp | Screen shot |
| wl-clipboard | Clipboard copy/paste |

#### Configuring fstab

```{bash}
genfstab -L -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```
## Running Scripts 
There are 3+ scripts that need to be run in each stage.
| Script Name | Stage | Purpose |
| --- | --- | --- |
| pre_install.sh | Preparation | Install basic required packages |
| install.sh | Install | Basic Configuration and Bootup setup |
| post_install.sh | Post Install | Starting Services for day and patching |
| gnome.sh | Desktop Environment | Setting up Gnome DE - Development |

## Other
Also included is [gpu-switch](https://github.com/0xbb/gpu-switch), a utility to switch between iGPU and dGPU. This requires a grub patch that has yet to be fully added here.

https://bugzilla.kernel.org/show_bug.cgi?id=193121
