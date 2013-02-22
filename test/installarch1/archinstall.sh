#!/bin/bash

# Author: Carlos Fagiani Junior                                        #
# E-mail: fagianijunior@gmail.com                                      #
# Versão: 0.2                                                          #

# Este Script segue o guia de instalação Arch:                         #
# https://wiki.archlinux.org/index.php/Installation_Guide              #
########################################################################

# 1- Rode o CD/PenDrive de instalação do Arch Linux
# 2- Transfira o script para a máquina (via PenDrive ou via wget)
# wget https://github.com/fagianijunior/ArchInstall/blob/master/src/archinstall.sh
# 3- Altere os dados abaixo
# 4- De permissão e rode o Script
# chmod +x archinstall.sh
# ./archinstall.sh
# Se tudo ocorrer bem, seu Arch Linux estará instalado.

#######################################
# Altere as informações a sua escolha #
#######################################
root_senha="senha_root";

novo_usuario="terabytes";
novo_usuario_nome_completo="Carlos Fagiani Junior";
novo_usuario_senha="senha_usuario";
novo_usuario_grupos="sys,disk,wheel,uucp,games,network,video,audio,storage,power";

layout_teclado="br-abnt2";
linguagem="pt_BR.UTF-8";
font="lat9w-16";
font_map="8859-1_to_uni";

hostname="ArchNote";
localtime="America/Fortaleza";

boot_hd="/dev/sda1";
swap_hd="/dev/sda2";
root_hd="/dev/sda3";
home_hd="/dev/sda4";

# nao/sim
formatar_home_hd="nao";

# Usar wifi na instalação? sim/nao
usar_wifi="nao";

# syslinux/grub/nenhum
boot_loader="grub";

# Desktop - cinnamon/e17/gnome/kde/xfce/nenhum
ambiente_de_trabalho = "cinnamon";

# Browser opera/firefox/chromiun/nenhum
navegador = "opera";


alterei_os_dados_acima="nao";
####################################
# Não alterar a partir deste ponto #
####################################

loadkeys $layout_teclado;

# Verifica se as informações estão corretas #

if [ "$alterei_os_dados_acima" == "nao" ]; then
   echo "Antes de rodar o script edite os dados internos. Operação cancelada.";
   exit;
fi

if [ ! -e "$boot_hd" ] || [ ! -e "$swap_hd" ] || [ ! -e "$root_hd" ] || [ ! -e "$home_hd" ]; then
   echo "Crie as 4 partições antes de continuar com o script.";
   echo "Será iniciado o comando 'cfdisk' para isso.";
   echo "A primeira partição deve ser a boot (~100MB)";
   echo "A segunda partição deve ser a SWAP (~1024MB)";
   echo "A terceira partição deve ser a ROOT (>=3GB)";
   echo "A quarta partição deve ser a HOME (Tamanho variado >=3GB)";
   cfdisk;
   if [ ! -e "$boot_hd" ] || [ ! -e "$swap_hd" ] || [ ! -e "$root_hd" ] || [ ! -e "$home_hd" ]; then
      echo "Particionamento errado, saindo do script";
      exit;
   fi
fi

mkfs -t ext2 $boot_hd;
mkswap $swap_hd;
mkfs -t ext3 $root_hd;

if [ "$formatar_home_hd" == "sim" ]; then
   mkfs -t ext3 $home_hd;
fi

swapon $swap_hd;
mount $root_hd /mnt;
mkdir /mnt/{boot,home};
mount $boot_hd /mnt/boot;
mount $home_hd /mnt/home;

if [ "$usar_wifi" == "sim" ]; then
	wifi-menu;
fi

pacstrap /mnt base base-devel;

case $ambiente_de_trabalho in
 kde)
  pacstrap /mnt kde;
  ;;
 xfce)
  pacstrap /mnt xfce4;
  ;;
 gnome)
  pacstrap /mnt gnome gnome-extra;
  ;;
 cinnamon)
  pacstrap /mnt cinnamon gnome gnome-extra;
  ;;
 e17)
  pacstrap /mnt enlightenment17;
  ;;
 *)
  ;;;
esac

case $navegador in
 opera)
  pacstrap /mnt opera;
  ;;
 chromium)
  pacstrap /mnt chromiun;
  ;;
 firefox)
  pacstrap /mnt firefox;
  ;;
 *)
  ;;;
esac


# ORGANIZAR

#complementares
# bluez blueman networkmanager network-manager-applet \
pacstrap /mnt wpa_supplicant dialog bash-completion xorg gvfs gvfs-smb flashplugin \
 jdk7-openjdk file-roller vlc leafpad transmission-gtk ttf-freefont ttf-dejavu slim;

arch-chroot /mnt /bin/bash -c "systemctl enable bluetooth.service";
#arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager";

arch-chroot /mnt /bin/bash -c "systemctl enable slim.service";

sed '/twm &/d' /mnt/etc/X11/xinit/xinitrc;
sed '/xclock/d' /mnt/etc/X11/xinit/xinitrc;
sed '/xterm -geometry/d' /mnt/etc/X11/xinit/xinitrc;

echo "# A variável a seguir define a sessão que será iniciada se o usuário não selecionar explicitamente uma sessão
# Fonte: http://svn.berlios.de/svnroot/repos/slim/trunk/xinitrc.sample
DEFAULT_SESSION=xfce4

case $1 in
 kde)
  exec startkde
 ;;
 xfce4)
  exec startxfce4
 ;;
 icewm)
  icewmbg &
  icewmtray &
  exec icewm
 ;;
 wmaker)
  exec wmaker
 ;;
 blackbox)
  exec blackbox
 ;;
 *)
  exec $DEFAULT_SESSION
 ;;
esac" >> /etc/X11/xinit/xinitrc

#/ORGANIZAR



if [ "$boot_loader" == "grub" ]; then
	pacstrap /mnt grub-bios;
elif [ "$boot_loader" == "syslinux" ]; then
	pacstrap /mnt syslinux;
fi

genfstab -p /mnt >> /mnt/etc/fstab;
cat /mnt/etc/fstab;

echo $hostname > /mnt/etc/hostname;

arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/$localtime /etc/localtime;";
espera "Configurou localtime.";

echo "LANG="$linguagem > /mnt/etc/locale.conf;

echo "KEYMAP="$layout_teclado > /mnt/etc/vconsole.conf;
echo "FONT="$font >> /mnt/etc/vconsole.conf;
echo "FONT_MAP="$font_map >> /mnt/etc/vconsole.conf;

cp /mnt/etc/locale.gen /mnt/tmp/locale.gen;
sed "s/#"$linguagem"/"$linguagem"/g" /mnt/tmp/locale.gen > /mnt/etc/locale.gen;

arch-chroot /mnt /bin/bash -c "locale-gen";
arch-chroot /mnt /bin/bash -c "mkinitcpio -p linux";

if [ "$boot_loader" == "grub" ]; then
   arch-chroot /mnt /bin/bash -c "modprobe dm-mod";
   arch-chroot /mnt /bin/bash -c "grub-install --recheck --debug "${boot_hd:0:8};
   arch-chroot /mnt /bin/bash -c "mkdir -p /boot/grub/locale";
   arch-chroot /mnt /bin/bash -c "cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo";
   arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg";
elif [ "$boot_loader" == "syslinux" ]; then
   arch-chroot /mnt /bin/bash -c "/usr/sbin/syslinux-install_update -iam;";
fi

arch-chroot /mnt /bin/bash -c "passwd << EOF
$root_senha
$root_senha
EOF";

arch-chroot /mnt /bin/bash -c "useradd -d /hone/"$novo_usuario" -m -g users -G "$novo_usuario_grupos" -s /bin/bash "$novo_usuario;
arch-chroot /mnt /bin/bash -c "passwd $novo_usuario << EOF
$novo_usuario_senha
$novo_usuario_senha
EOF";

umount /mnt/{boot,home,};

echo "Seu novo Arch Linux está instalado e com as configurações básicas.";
exit;
