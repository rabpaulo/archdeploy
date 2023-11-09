sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 10/" /etc/pacman.conf
pacman --noconfirm -Sy archlinux-keyring
pacman-key --init

clear
cfdisk /dev/sda
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
swapon /dev/sda2
mkfs.fat -F32 /dev/sda1
mount /dev/sda3 /mnt
mkdir -p /mnt/boot/efi 
mount /dev/sda1 /mnt/boot/efi
pacstrap /mnt base base-devel linux linux-firmware sudo sed
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/archinstall2.sh
chmod +x /mnt/archinstall2.sh
arch-chroot /mnt ./archinstall2.sh
exit

#part2
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 10/" /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "amadeus" >> /etc/hostname

# Baixando e instalando GRUB
pacman --noconfirm -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="amdgpu.ppfeaturemask=0xffffffff loglevel=3 quiet"/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


pacman --noconfirm -S networkmanager corectrl neovim firefox gimp keepassxc mpv \
        btop qbittorrent git rsync yt-dlp bc ffmpegthumbnailer \
        nicotine+ cmus neofetch zathura zathura-pdf-mupdf unrar \
        pulseaudio pulsemixer polkit xclip xwallpaper ufw imagemagick \
        man zsh ueberzug lf sxiv upower newsboat tmux fzf android-file-transfer \
        xorg xorg-xinit slock dmenu unzip python-pip xcompmgr \
	noto-fonts-cjk noto-fonts-emoji noto-fonts 
sudo systemctl enable NetworkManager 
id="$(ls -al /dev/disk/by-uuid/ | awk '/nvme0n1$/ {print $9}')"
sudo mkdir -p /mnt/nvme0n1
echo "UUID="$id"	/mnt/nvme0n1	ext4	defaults	0	0" >> /etc/fstab

clear
echo "Senha root"
passwd
echo " %wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
read -p "Nome do usuario: " usuario
useradd -mG wheel -s /bin/zsh $usuario
echo "Senha do usuario"
passwd $usuario
ai3_path=/home/$usuario/archinstall3.sh
sed '1,/^#part3$/d' archinstall2.sh > $ai3_path
chown $usuario:$usuario $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $usuario
exit 

#part3
cd
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/rabpaulo/dots temparq
rsync --recursive --exclude '.git' temparq/ $HOME/

git clone --separate-git-dir=$HOME/.lfrun https://github.com/thimc/lfimg.git lfrun
cd $HOME/lfrun
make install
cd 

git clone --depth=1 https://github.com/rabpaulo/suckless-stuff

cd 'suckless-stuff/dwm/' 
sudo make clean install
cd '../dwmblocks/'
sudo make clean install
cd '../st/'
sudo make clean install
cd '../dmenu/'
sudo make clean install
cd 

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si cd $HOME

sudo rm -f /etc/polkit-1/rules.d/90-corectrl.rules
sudo mv $HOME/.local/90-corectrl.rules /etc/polkit-1/rules.d/90-corectrl.rules

pulseaudio -D 

pip install --break-system-packages gallery-dl

yay -S cmusfm zsh-syntax-highlighting-git  downgrade
yay -Yc

cd 
rm -rf  yay/ .cache temparq/ .dotfiles/ arch_install3.sh .lfrun lfimg lfrun suckless-stuff
mkdir Downloads/ repos/

sudo mount /dev/nvme0n1 /mnt/nvme0n1
ln -s /mnt/nvme0n1 .
ln -s /mnt/nvme0n1/Music .
ln -s /mnt/nvme0n1/Documents/ .  
ln -s /mnt/nvme0n1/Pictures .

echo "Tudo finalizado!"
exit
