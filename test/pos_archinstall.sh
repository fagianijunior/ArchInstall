#!/bin/bash

#sim/nao
instalar_x="sim";

###################################
###################################
#Atualiza pacman
pacman -Sy;

# Criar novo usuario


# instalar Interface gráfica
if [ "$instala_x" == "sim" ]; then
   pacman -S xorg-server xorg-init xorg-server-utils;

   #00:02.0 VGA compatible controller: Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09)
   #00:02.0 VGA compatible controller: Intel Corporation 3rd Gen Core processor Graphics Controller (rev 09)
   if lspci | grep "VGA" | grep "Intel" > /dev/null || lspci | grep "VGA" | grep "INTEL" > /dev/null; then
      pacman -S xf86-video-intel libva-intel-driver;
   fi

   #02:00.0 VGA compatible controller: NVIDIA Corporation C77 [GeForce 9100M G] (rev a2)
   #01:00.0 VGA compatible controller: nVidia Corporation GT218 [GeForce 310M] (rev a2)
   #01:00.0 VGA compatible controller: NVIDIA Corporation GF108 [GeForce GT 630M] (rev a1)
   #01:00.0 VGA compatible controller: NVIDIA Corporation GF114 [GeForce GTX 560 Ti] (rev a1)
   #01:00.0 VGA compatible controller: NVIDIA  Corporation NV44 [GeForce 7100 GS] (rev a1)
   if lspci | grep "VGA" | grep "nVidia" > /dev/null || lspci | grep "VGA" | grep "NVIDIA" > /dev/null; then
      pacman -S nvidia nvidia-utils;
      X -configure;
      cp /root/xorg.conf.new /etc/X11/xorg.conf;
   fi

   #00:02.0 VGA compatible controller: InnoTek Systemberatung GmbH VirtualBox Graphics Adapter
   if lspci | grep "VGA" | grep "VirtualBox" > /dev/null; then
      pacman;
   fi
fi
