#!/bin/bash
source functions.sh

# br-abnt2 br-abnt us en
layout_teclado "br-abnt2"
# sim/não
usar_wifi "sim"

# Para a partição Swap, tamanho mínimo 1GB, aconselhado o mesmo tamanho da sua memória RAM
# Para a partição Sistema, tamanho mínimo de 15GB aconselhado 30GB+
# Para a partição Home, tamanho mínimo de 10GB aconselhado 20GB+
# Obs. para a partição Home, caso queira usar todo o restante do HD, informe "0" na terceira opção 

# File System == ext3/ext2/ext4/reiserfs/...

# sim/não | Partição | File System
hd_para_boot "nao" "1" "ext2"
# sim/não | partição
hd_para_swap "sim" "1"
# Particao | File System
hd_para_sistema "2" "ext3"
# sim/não/manter | Partição | File System
hd_para_home "manter" "4" "ext3"
# /dev/sda ou /dev/sdb ou /dev/hda ou etc.
hd "/dev/sda"

# Adicione os pacotes que deverão ser instalados
# O pacote "base" já é instalado por padrão
# pacotes adicionais
iniciar_instalacao "base-devel dialog wpa_supplicant"

# Nome na rede (Hostname) | Zona (localtime) | Linguagem do sistema | mapa de fonte
configuracao_inicial "ArchNote" "America/Fortaleza" "pt_BR.UTF-8" "lat9w-16" "8859-1_to_uni"

# grub/syslinux
gerenciador_de_boot "grub"

# Caso queira fazer a instalação básica do desktop escolhido
# Responda "não" na segunda opção
# cinnamon/xfce/kde/gnome/nenhum | sim/não
instalar_desktop "gnome" "sim"

# Senha
root_senha "tutopiajr"
# Caso queira adicionar mais de um  usuário, copie esse comando
# em outra linha
# Usuario | Senha | Grupos adicionnais
novo_usuario "terabytes" "t" "sys disk wheel uucp games network video audio storage power"

finalizar_instalacao
