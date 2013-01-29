#!/bin/bash

root_senha="a";

layout_teclado="br-abnt2";
linguagem="pt_BR.UTF-8";
fonte_console="lat9w-16";
fonte_map="8859-1_to_uni";
localtime="America/Fortaleza";
hostname="ArchPC";

criar_boot_hd="";
  boot_hd="/dev/sd";
   boot_hd_tamanho="0";

criar_swap="";
  swap_hd="/dev/sd";
   swap_hd_tamanho="0";

root_hd="/dev/sd";
  root_hd_tamanho="0";

criar_home_hd="";
  home_hd="/dev/sd";
   home_hd_tamanho="0";

function SenhaRoot() {
   while [ "$root_senha" == "" ]; do
      root_senha1=$(dialog --stdout --title "Senha Root" \
       --passwordbox "A senha não deve ser nula.\n\nSenha Root:" 0 0);
      root_senha2=$(dialog --stdout --title "Senha Root" \
       --passwordbox "Redigite a senha Root:" 0 0);
      if [ "$root_senha1" != "" ] && [ "$root_senha1" == "$root_senha2" ]; then
         root_senha = "$root_senha1";
         break;
      fi
   done;
}

function Teclado() {
   while [ "$layout_teclado" == "" ]; do
      layout_teclado=$(dialog \
       --no-cancel \
       --stdout \
       --title "Teclado" \
       --menu "Layout do teclado: " \
       0 0 0 \
       be-latin1              "Belgo" \
       br-abnt2               "Português Brasileiro" \
       cf                     "Canadian-French" \
       colemak                "Colemak (US)" \
       croat                  "Croatian" \
       cz-lat2                "Czech" \
       dvorak                 "Dvorak" \
       fi-latin1              "Finnish" \
       fr-latin1              "French" \
       de-latin1              "German" \
       de-latin1-nodeadkeys   "German (no dead keys)" \
       it                     "Italian" \
       lt.baltic              "Lithuanian (qwerty)" \
       no-latin1              "Norwegian" \
       pl                     "Polish" \
       pt-latin9              "Portuguese" \
       ro_win                 "Romanian" \
       ru4                    "Russian" \
       sg-latin1              "Singapore" \
       slovene                "Slovene" \
       sv-latin1              "Swedish" \
       fr_CH-latin1           "Swiss-French" \
       de_CH-latin1           "Swiss-German" \
       es                     "Spanish" \
       la-latin1              "Spanish Latinoamerican" \
       tr_q-latin5            "Turkish" \
       ua                     "Ukrainian" \
       uk                     "United Kingdom" \
       OUTRO                  "Outro layout" \
       );

      if [ "$layout_teclado" ==  "OUTRO" ]; then
         layout_teclado=$(dialog \
          --no-cancel \
          --stdout \
          --title "Teclado" \
          --inputbox "Informe o Layout do seu teclado:" \
          0 0);
      fi
   done;
}

function Linguagem() {
   while [ "$linguagem" == "" ]; do
      linguagem=$(dialog \
       --no-cancel \
       --stdout \
       --title "Linguagem" \
       --menu  "Selecione a linguagem do sistema:" \
       0 0 0 \
       pt_BR.UTF-8   "Português brasileiro UTF-8" \
       OUTRO         "Outra linguagem" \
       );
      if [ "$linguagem" == "OUTRO" ]; then
         linguagem=$(dialog \
          --no-cancel \
          --stdout \
          --title "Linguagem" \
          --inputbox "Informe a linguagem do sistema:" \
          0 0);
      fi
   done;
}

function FonteConsole() {
   while [ "$fonte_console" == "" ]; do
      fonte_console=$(dialog \
       --no-cancel \
       --stdout \
       --title "Console" \
       --menu  "Selecione a fonte para o console:" \
       0 0 0 \
       lat9w-16   "" \
       lat0-16    "" \
       OUTRO      "Outra fonte");

      if [ "$fonte_console" == "OUTRO" ]; then
         fonte_console=$(dialog \
          --no-cancel \
          --stdout \
          --title "Console" \
          --inputbox "Informe a fonte para o console:" \
          0 0);
      fi
   done;
}

function MapaFonte() {
   while [ "$fonte_map" == "" ]; do
      fonte_map=$(dialog \
       --no-cancel \
       --stdout \
       --title "Mapa da fonte" \
       --menu  "Selecione o mapa de fonte:" \
       0 0 0 \
       8859-1_to_uni "" \
       OUTRO         "Outro mapa de fonte ");

      if [ "$fonte_map" == "OUTRO" ]; then
         fonte_map=$(dialog \
          --no-cancel \
          --stdout \
          --title "Console" \
          --inputbox "Informe a fonte para o console:" \
          0 0);
      fi
   done;
}

function HostName() {
   while [ "$hostname" == "" ]; do
      hostname=$(dialog \
       --no-cancel \
       --stdout \
       --title "Hostname" \
       --inputbox "Informe como será o nome da máquina na rede:" \
       0 0);
   done;
}

function LocalTime() {
   if [ "$localtime" == "" ]; then
      for i in $(ls -1d /usr/share/zoneinfo/*/); do
         j=$(echo $i | cut -d/ -f5);
         lista_zona="$lista_zona $j $i";
      done
      zona1=/usr/share/zoneinfo/$(dialog --no-cancel --stdout \
       --title "1ª zona" \
       --menu "Escolha a zona:" \
       0 0 0 \
       $lista_zona);

      lista_zona="";
      for i in $(ls -1 $zona1); do
         lista_zona="$lista_zona $i $i";
      done
      localtime=$zona1/$(dialog --no-cancel --stdout \
       --title "2ª Zona" \
       --menu "Escolha a Zona:" \
       0 0 0 \
       $lista_zona);
   fi
}

function Particoes() {
   todos="0";

   if [ "$criar_boot_hd" == "" ]; then
      criar_boot_hd=$(dialog --no-cancel --stdout \
       --title "BOOT HD" \
       --menu "Deseja criar uma partição separada para o BOOT?" \
       0 0 0 \
       "sim" "" \
       "não" ""
       );
   fi
   if [ "$criar_boot_hd" == "sim" ]; then
   menu_boot="BOOT" "$boot_hd  $boot_hd_tamanho MB" "SWAP" "$swap_hd  $swap_hd_tamanho MB" "ROOT" "$root_hd  $root_hd_tamanho MB" "HOME" "$home_hd  $home_hd_tamanho MB"

   fi
   while [ "$todos" -le "4" ]; do
      escolha=$(dialog --no-cancel --stdout \
       --title "Particionamento" \
       --menu "Partições" \
       -1 0 0 \
       $menu_boot);

      if [ "$escolha" == "BOOT" ]; then
         boot_hd=$(dialog --stdout \
          --title "BOOT HD" \
          --inputbox "Partição para o boot" \
          0 0 \
          "$boot_hd");
          while [ "$boot_hd_tamanho" -le "39" ]; do
             boot_hd_tamanho=$(dialog --no-cancel --stdout \
              --title "BOOT HD" \
              --inputbox "Tamanho mínimo: 40MB \nTamanho aconselhado: entre 50MB a 100MB" \
              0 0 "50");
          done;
      elif [ "$escolha" == "SWAP" ]; then
         swap_hd=$(dialog --stdout \
          --title "SWAP" \
          --inputbox "Partição para o swap" \
          0 0 \
          "$swap_hd");
         swap_hd_tamanho=$(dialog --no-cancel --stdout \
          --title "SWAP HD" \
          --inputbox "Tamanho mínimo: 0MB \nTamanho aconselhado: o dobro de sua memória RAM" \
          0 0 "50");

      elif [ "$escolha" == "ROOT" ]; then
         root_hd=$(dialog --stdout \
          --title "ROOT HD" \
          --inputbox "Partição para a pasta root" \
          0 0 \
          "$root_hd");
         while [ $root_hd_tamanho -le "9999" ]; do
            root_hd_tamanho=$(dialog --no-cancel --stdout \
             --title "ROOT HD" \
             --inputbox "Tamanho mínimo: 10000MB \nTamanho aconselhado: > 50000MB \n0 para o restante do HD" \
             0 0 "50");
         done;

      elif [ "$escolha" == "HOME" ]; then
         home_hd=$(dialog --stdout \
          --title "HOME HD" \
          --inputbox "Partição para a pasta home" \
          0 0 \
          "$home_hd");
         home_hd_tamanho=$(dialog --no-cancel --stdout \
          --title "HOME HD" \
          --inputbox "Tamanho mínimo: 10000MB \nTamanho aconselhado: 50000MB \n0 para o restante do HD" \
          0 0 "50");
      fi
   done;
}

SenhaRoot;
Teclado;
Linguagem;
FonteConsole;
MapaFonte;
HostName;
LocalTime;
Particoes;

echo $root_senha;
echo $layout_teclado;
echo $linguagem;
echo $fonte_console;
echo $fonte_map;
echo $hostname;
echo $localtime;
