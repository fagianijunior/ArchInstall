#!/bin/bash

#sim/nao
instalar_x="sim";

###################################
###################################
#Atualiza pacman e o sistema
pacman -Syu;

# Criar novo usuario

# Configura Virtual Box

#00:02.0 VGA compatible controller: InnoTek Systemberatung GmbH VirtualBox Graphics Adapter
if lspci | grep "VGA" | grep "VirtualBox" > /dev/null; then
   pacman -S virtualbox-guest-utils;

   modprobe -a vboxguest vboxsf vboxvideo;

   echo vboxguest > /etc/modules-load.d/virtualbox.conf;
   echo vboxsf >> /etc/modules-load.d/virtualbox.conf;
   echo vboxvideo >> /etc/modules-load.d/virtualbox.conf;
   VBoxClient-all;
   x_config;
fi


# instalar Interface gráfica
if [ "$instalar_x" == "sim" ]; then
   pacman --noconfirm -S xorg-server xorg-xinit xorg-server-utils;

   #00:02.0 VGA compatible controller: Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09)
   #00:02.0 VGA compatible controller: Intel Corporation 3rd Gen Core processor Graphics Controller (rev 09)
   if lspci | grep "VGA" | grep "Intel" > /dev/null || lspci | grep "VGA" | grep "INTEL" > /dev/null; then
      pacman --noconfirm -S xf86-video-intel intel-dri libva-intel-driver;
      x_config;
   fi

   #02:00.0 VGA compatible controller: NVIDIA Corporation C77 [GeForce 9100M G] (rev a2)
   #01:00.0 VGA compatible controller: nVidia Corporation GT218 [GeForce 310M] (rev a2)
   #01:00.0 VGA compatible controller: NVIDIA Corporation GF108 [GeForce GT 630M] (rev a1)
   #01:00.0 VGA compatible controller: NVIDIA Corporation GF114 [GeForce GTX 560 Ti] (rev a1)
   #01:00.0 VGA compatible controller: NVIDIA  Corporation NV44 [GeForce 7100 GS] (rev a1)
   if lspci | grep "VGA" | grep "nVidia" > /dev/null || lspci | grep "VGA" | grep "NVIDIA" > /dev/null; then
      pacman -S nvidia nvidia-utils;
      x_config;
      nvidia_config;
   fi
fi

function x_config() {
   X -configure;
   cp /root/xorg.conf.new /etc/X11/xorg.conf;
}

function nvidia_config() {
   nvidia-xconfig --add-argb-glx-visuals --allow-glx-with-composite --composite -no-logo --nvagp=1 --render-accel -o /etc/X11/xorg.conf;
}
