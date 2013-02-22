#Array de partições (informações do usuário)
declare -A particoes=()

function pausa() {
  read -p "$1
Aperte [Enter] para continuar..."
}

function introducao() {
  echo "Bem vindo ao sistema de instalação para a distribuição Arch Linux!"
  echo "Os criadores desse script não se responsabilizam por qualquer dano"
  echo "em suas dados e/ou equipamento de hardware, executando esse script"
  echo "você estará aceitando "
  pausa
}

function layout_teclado() {
  introducao

  #Array com os layouts do teclado
  layouts=("br-abnt" "br-abnt2" "us" "en")

  for (( i=0; i<${#layouts[@]}; i++)); do
    if [ $1 == ${layouts[i]} ]; then
      loadkeys ${layouts[i]}
      layout=${layouts[i]}
      sucesso=1
    fi
  done
  if [ $sucesso == 1 ]; then
    sucesso=0
  else
    pausa "Ocoreu um erro na configuração do teclado! :("
  fi
}

function usar_wifi() {
  if [ $1 == "sim" ]; then
    wifi_menu
  fi
}

function hd_para_boot() {
  if [ $1 == "sim" ]; then
    particoes["boot_criar"]=$1
    particoes["boot_particao"]=$2
    particoes["boot_fs"]=$3
  else
    particoes["boot_criar"]=$1
  fi
}

function hd_para_swap() {
  if [ $1 == "sim" ]; then
    particoes["swap_criar"]=$1
    particoes["swap_particao"]=$2
  else
    particoes["swap_criar"]=$1
  fi
}

function hd_para_sistema() {
  particoes["sistema_particao"]=$1
  particoes["sistema_fs"]=$2
}

function hd_para_home() {
  particoes["home_criar"]=$1

  if [ $1 == "sim" ]; then
    particoes["home_particao"]=$2
    particoes["home_fs"]=$3
  elif [ $1 == "manter" ]; then
    particoes["home_particao"]=$2
  fi

}

function hd() {
  usar_hd=$1
  cfdisk $usar_hd

  criar_fs
}

function criar_fs() {
  mkfs -t ${particoes["sistema_fs"]} $usar_hd${particoes["sistema_particao"]}
  mount $usar_hd${particoes["sistema_particao"]} /mnt

  if [ ${particoes["boot_criar"]} == "sim" ]; then
    mkfs -t ${particoes["boot_fs"]} $usar_hd${particoes["boot_particao"]}
    mkdir /mnt/boot
    mount $usar_hd${particoes["boot_particao"]} /mnt/boot
  fi

  if [ ${particoes["swap_criar"]} == "sim" ]; then
    mkswap $usar_hd${particoes["swap_particao"]}
    swapon $usar_hd${particoes["swap_particao"]}
  fi

  if [ ${particoes["home_criar"]} == "sim" ]; then
    mkfs -t ${particoes["home_fs"]} $usar_hd${particoes["home_particao"]}
    mkdir /mnt/home
    mount $usar_hd${particoes["home_particao"]} /mnt/home
  elif [ ${particoes["home_criar"]} == "manter" ]; then
    mkdir /mnt/home
    mount $usar_hd${particoes["home_particao"]} /mnt/home
  fi
}

function iniciar_instalacao(){
  pacotes_adicionais=($1)

  pacstrap /mnt base

  for (( i = 0; $i<${#pacotes_adicionais[@]}; i++ )); do
    if [ ${pacotes_adicionais[$i]} != "base" ]; then
      pacstrap /mnt ${pacotes_adicionais[$i]}
    fi
  done
}

function configuracao_inicial() {
  arch-chroot /mnt /bin/bash -c "loadkeys "$layout
  genfstab -p /mnt >> /mnt/etc/fstab
  echo $1 > /mnt/etc/hostname
  arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/"$2" /etc/localtime"

  echo "LANG="$3 > /mnt/etc/locale.conf

  echo "KEYMAP="$layout > /mnt/etc/vconsole.conf
  echo "FONT="$4 >> /mnt/etc/vconsole.conf
  echo "FONT_MAP="$5 >> /mnt/etc/vconsole.conf

  cp /mnt/etc/locale.gen /mnt/tmp/locale.gen;
  sed "s/#"$3"/"$3"/g" /mnt/tmp/locale.gen > /mnt/etc/locale.gen;

  arch-chroot /mnt /bin/bash -c "locale-gen"
  arch-chroot /mnt /bin/bash -c "mkinitcpio -p linux"
}

function gerenciador_de_boot() {
  if [ $1 == "grub" ]; then
    pacstrap /mnt grub-bios
    arch-chroot /mnt /bin/bash -c "modprobe dm-mod";
    arch-chroot /mnt /bin/bash -c "grub-install --recheck --debug "$usar_hd
    arch-chroot /mnt /bin/bash -c "mkdir -p /boot/grub/locale";
    arch-chroot /mnt /bin/bash -c "cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo"
    arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
  elif [ $1 == "syslinux" ]; then
    pacstrap /mnt syslinux
    arch-chroot /mnt /bin/bash -c "/usr/sbin/syslinux-install_update -iam"
  fi
}

function instalar_desktop() {
  case $1 in
    cinnamon)
      instalar_cinnamon $2
    ;;
    *)
    ;;
  esac
}

function instalar_cinnamon() {
  if [ $1 == "sim" ]; then
    pacstrap /mnt gnome gnome-extra
  fi
  pacstrap /mnt xorg cinnamon
  arch-chroot /mnt /bin/bash -c "systemctl enable gdm.service"
}

function root_senha() {
  arch-chroot /mnt /bin/bash -c "passwd << EOF
$1
$1
EOF"
}

function novo_usuario() {
  grupos=($3)

  arch-chroot /mnt /bin/bash -c "useradd -d /home/"$1" -m -g users -s /bin/bash "$1
  arch-chroot /mnt /bin/bash -c "passwd "$1" << EOF
$2
$2
EOF"

  for (( i=0; $i<${#grupos[@]}; i++)); do
    arch-chroot /mnt /bin/bash -c "gpasswd -a "$1" "${grupos[$i]}
  done

}

function finalizar_instalacao() {
  umount /mnt/{boot,home,}
  pausa "Se tudo ocorreu dentro dos conformes, seu novo Arch Linux está instalado! :)" 
}
