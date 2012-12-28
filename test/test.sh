#!/bin/bash
########################################################################
# This program is free software: you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation, either version 3 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program.  If not, see <http://www.gnu.org/licenses/> #
#                                                                      #
# Author: Carlos Fagiani Junior                                        #
# E-mail: fagianijunior@gmail.com                                      #
# Versão: 1.0                                                          #
#                                                                      #
# Este Script segue o guia de instalação Arch:                         #
# https://wiki.archlinux.org/index.php/Installation_Guide              #
#                                                                      #
########################################################################

# 1- Rode o CD/PenDrove de instalação do Arch Linux
# 2- Transfira o script para a máquina (via PenDrive o via wget)
# wget http://dl.dropbox.com/u/79200609/arch/archinstall.sh
# 3- Crie as 4 partições com o comando cfdisk /dev/sdX
# 4- Altere os dados abaixo
# chmod +x archinstall.sh
# ./archinstall.sh
# Se tudo ocorrer bem, seu Arch Linux estará instalado.

#######################################
# Altere as informações a sua escolha #
#######################################
root_senha="senha_root";

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

# sim/nao
usar_wifi="nao";

# syslinux/grub/nao
boot_loader="grub";

alterei_os_dados_acima="nao";
####################################
# Não alterar a partir deste ponto #
####################################

function espera() {
	read -p "$1 Tecle <ENTER> para continuar..." a;
	unset a;
}

#Verifica se o usuário realmente alterou os dados
if [ "$alterei_os_dados_acima" == "nao" ]; then
   echo "Antes de rodar o script edite os dados internos. Operação cancelada.";
   exit;
fi

# Configura o teclado
loadkeys $layout_teclado;
espera "Teclado Configurado.";

## Pode ser adicionado uma opção para criação de partições.
## Por enquanto o usuário deve criar as partições antes
## de rodar o script

# Formata as partições root, boot e SWAP
mkfs -t ext2 $boot_hd;
espera "$boot_hd formatado.";
mkswap $swap_hd;
espera "Swap criada em $swap_hd.";
mkfs -t ext3 $root_hd;
espera "$root_hd formatado.";

if [ "$formatar_home_hd" == "sim" ]; then
   mkfs -t ext3 $home_hd;
   espera "$home_hd formatado.";
fi

# Monta as partições e a SWAP
swapon $swap_hd;
espera "SWAP ligada.";
mount $root_hd /mnt;
espera "$root_hd montado em /mnt";
mkdir /mnt/{boot,home};
espera "Pasta /mnt/boot e /mnt/home criados.";
mount $boot_hd /mnt/boot;
espera "$boot_hd montado em /mnt/boot";
mount $home_hd /mnt/home;
espera "$home_hd montado em /mnt/home";

# Caso for utilizar o wifi
if [ "$usar_wifi" == "sim" ]; then
	wifi-menu;
	espera "Wifi conectadoj.";
fi

# Instala a base do sistema
pacstrap /mnt base base-devel wpa-supplicant dialog;
espera "base e base-devel instalados.";

# Instala o bootloader
if [ "$boot_loader" == "grub" ]; then
	pacstrap /mnt grub-bios
elif [ "$boot_loader" == "syslinux" ]; then 
	pacstrap /mnt syslinux;
fi
espera "$boot_loader bootloader instalado.";

# Cria o /etc/fstab
genfstab -p /mnt >> /mnt/etc/fstab;
cat /mnt/etc/fstab;
espera "fstab gerado.";

# Hostname
echo $hostname > /mnt/etc/hostname;
espera "Adicionou $hostname em /etc/hostname";

# Localtime
arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/$localtime /etc/localtime;";
espera "Configurou localtime.";

# Tradução para o português
echo "LANG="$linguagem > /mnt/etc/locale.conf
espera "Criou o arquivo locale.gen.";

# Configura texto no console
echo "KEYMAP="$layout_teclado > /mnt/etc/vconsole.conf;
echo "FONT="$font >> /mnt/etc/vconsole.conf;
echo "FONT_MAP="$font_map >> /mnt/etc/vconsole.conf;
espera "Configurou o vconsole.conf.";

# Configura o locale.gen
cp /mnt/etc/locale.gen /mnt/tmp/locale.gen;
sed "s/#"$linguagem"/"$linguagem"/g" /mnt/tmp/locale.gen > /mnt/etc/locale.gen;

# Entra no sistema instalado
arch-chroot /mnt /bin/bash -c "locale-gen; mkinitcpio -p linux;";
espera "gerou o locale. Criou a RAM disk.";
if [ "$boot_loader" == "grub" ]; then
   arch-chroot /mnt /bin/bash -c "modprobe dm-mod;	grub-install --recheck --debug echo "${boot_hd:0:8}";	mkdir -p /boot/grub/loale;	cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo;	grub-mkconfig -o /boot/grub/grub.cfg;";
elif [ "$boot_loader" == "syslinux" ]; then
   arch-chroot /mnt /bin/bash -c "/usr/sbin/syslinux-install_update -iam;";
fi
espera "Configurou o $boot_loader";

#Cria senha do ROOT
arch-chroot /mnt /bin/bash -c "passwd; $root_senha; $root_senha;"
espera "Setou a senha do ROOT.";

# Desmonta as partições
umount /mnt/{boot,home,};
echo "Desmontou as partições.";
read -p "Tecle <ENTER> para continuar..." a;
unset a;

echo "Seu novo Arch Linux está instalado e com as configurações básicas. ";
exit;
