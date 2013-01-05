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
# Versão: 1.2                                                          #
#                                                                      #
# Este Script segue o guia de instalação Arch:                         #
# https://wiki.archlinux.org/index.php/Installation_Guide              #
#                                                                      #
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

#sim/nao
pos_instalacao="sim";

alterei_os_dados_acima="nao";
####################################
# Não alterar a partir deste ponto #
####################################
function espera() {
	read -p "$1 Tecle <ENTER> para continuar..." a;
	unset a;
}

# Configura o teclado
loadkeys $layout_teclado;
espera "Teclado Configurado.";

# Verifica se as informações estão corretas #

#Verifica se o usuário realmente alterou os dados
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
   espera "cfdisk";
   cfdisk;
   if [ ! -e "$boot_hd" ] || [ ! -e "$swap_hd" ] || [ ! -e "$root_hd" ] || [ ! -e "$home_hd" ]; then
      espera "Particionamento errado, saindo do script";
      exit;
   fi
fi

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
	espera "Wifi conectado.";
fi

# Instala a base do sistema
pacstrap /mnt base base-devel wpa_supplicant dialog;
espera "base e base-devel instalados.";

# Instala o bootloader
if [ "$boot_loader" == "grub" ]; then
	pacstrap /mnt grub-bios;
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

# Tradução
echo "LANG="$linguagem > /mnt/etc/locale.conf;
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
arch-chroot /mnt /bin/bash -c "locale-gen";
arch-chroot /mnt /bin/bash -c "mkinitcpio -p linux";
espera "gerou o locale. Criou a RAM disk.";

if [ "$boot_loader" == "grub" ]; then
   arch-chroot /mnt /bin/bash -c "modprobe dm-mod";
   arch-chroot /mnt /bin/bash -c "grub-install --recheck --debug "${boot_hd:0:8};
   arch-chroot /mnt /bin/bash -c "mkdir -p /boot/grub/locale";
   arch-chroot /mnt /bin/bash -c "cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo";
   arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg";
elif [ "$boot_loader" == "syslinux" ]; then
   arch-chroot /mnt /bin/bash -c "/usr/sbin/syslinux-install_update -iam;";
fi
espera "Configurou o $boot_loader";

if [ "$pos_instalacao" == "sim" ]; then
   pacstrap /mnt wget;
   arch-chroot /mnt /bin/bash -c "wget https://github.com/fagianijunior/ArchInstall/blob/master/src/pos_archinstall.sh -O /root/pos_archinstall.sh";
   espera "Quando reiniciar o sistema execute o script pos_archinstall.sh que foi gerado na pasta /root";
fi

#Cria senha do ROOT
arch-chroot /mnt /bin/bash -c "passwd";
espera "Setou a senha do ROOT.";

# Desmonta as partições
umount /mnt/{boot,home,};
echo "Desmontou as partições.";
read -p "Tecle <ENTER> para continuar..." a;
unset a;

echo "Seu novo Arch Linux está instalado e com as configurações básicas.";
exit;
