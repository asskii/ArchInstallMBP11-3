#!/usr/bin/bash
# Defining the shell path and global variables 
SHELL_PATH=$(readlink -f $0 | xargs dirname)
source ${SHELL_PATH}/bin/global.sh

info "Setting Time zone and Time"
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc --utc

info "Setting system wide language"
sed -i '/en_US.UTF-8'/s/^#//g /etc/locale.gen
locale-gen
cp ${SHELL_PATH}/config/etc/locale.conf /etc/

info "Setting font for vconsole"
cp ${SHELL_PATH}/config/etc/vconsole.conf /etc/

info "Setting machine name."
echo ada-mbp > /etc/hostname

info "Copying the modules to /etc/"
cp ${SHELL_PATH}/config/etc/modules /etc/

info "Setting environment variables for Wayland"
cp ${SHELL_PATH}//config/etc/environment /etc/

info "Giving user wheel access"
sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL'/s/^#//g /etc/sudoers

# systemd-boot Configurations
#info "Making bootable drive and configurations"
#bootctl --path=/boot install
#cp ${SHELL_PATH}/config/boot/arch.conf /boot/loader/entries/
#cp ${SHELL_PATH}/config/boot/lts.conf /boot/loader/entries/
#cp ${SHELL_PATH}/config/boot/loader.conf /boot/loader/

info "Setting the sound card index to PCA"
cp ${SHELL_PATH}/config/modprobe/snd_hda_intel.conf /etc/modprobe.d/
cp ${SHELL_PATH}/config/modprobe/i915.conf /etc/modprobe.d/
cp ${SHELL_PATH}/config/modprobe/hid_apple.conf /etc/modprobe.d/
cp ${SHELL_PATH}/config/modprobe/xhci_reset_on_suspend.conf /etc/modprobe.d/

sed -i '/Color'/s/^#//g /etc/pacman.conf

info "Type the the username for this installation:"
read USERNAME
useradd -m -g users -G wheel,sys,log,network,floppy,scanner,power,rfkill,users,video,storage,optical,lp,audio,adm,ftp,mail,git -s /bin/bash ${USERNAME}
info "Password for the user ${USERNAME}"
passwd ${USERNAME}
info "Password for root"
passwd


# bootctl set-default lts.conf
# bootctl list

info "Making bootable drive and configurations"
pacman -Sy --noconfirm grub efibootmgr hfsprogs mkinitcpio
modprobe hfsplus
mkinitcpio -P

mkdir -p /boot/efi
mount /dev/nvme0n1p1 /boot/efi
touch /boot/mach_kernel
mkdir -p /boot/EFI/arch && touch /boot/EFI/arch/mach_kernel

wget https://github.com/0xbb/apple_set_os.efi/releases/download/v1/apple_set_os.efi
mkdir -p /boot/EFI/custom
cp apple_set_os.efi /boot/EFI/custom
echo "search --no-floppy --set=root --label EFI
      chainloader ($root)/EFI/custom/apple_set_os.efi
      boot" >> /etc/grub.d/40_custom

grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

mkdir -p /boot/System/Library/CoreServices
cp SystemVersion.plist /boot/System/Library/CoreServices

info "Setting boot icon."
pacman -S --noconfirm wget librsvg libicns
wget -O /tmp/archlinux.svg https://www.archlinux.org/logos/archlinux-icon-crystal-64.svg
rsvg-convert -w 128 -h 128 -o /tmp/archlogo.png /tmp/archlinux.svg
png2icns /boot/.VolumeIcon.icns /tmp/archlogo.png
rm /tmp/archlogo.png
rm /tmp/archlinux.svg

# info "Patching GRUB"
# su $USERNAME
# cd grub-git
# makepkg -si
# grub-mkconfig -o /boot/grub/grub.cfg
# cd ..

sudo systemctl enable NetworkManager 
# sudo systemctl enable man-db.timer
# sudo systemctl enable paccache.timer

info "The system will shutdown in 60 seconds. When the screen goes dark, remove the install media. Run post_install.sh after restart."
#exit
#shutdown -r +1
