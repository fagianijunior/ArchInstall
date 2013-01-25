#!/bin/bash

root_senha="";

layout_teclado="";
linguagem="";
fonte_console="";
fonte_map="";
localtime="";

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
   if [ "$layout_teclado" == "" ]; then
      layout_teclado=$(dialog \
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
   fi
   if [ "$layout_teclado" ==  "OUTRO" ]; then
      layout_teclado=$(dialog \
       --no-cancel \
       --stdout \
       --title "Teclado" \
       --inputbox "Informe o Layout do seu teclado:" \
       0 0);
   fi
}
if [ $layout_teclado == "" ]; then
   Teclado
else
   Linguagem
fi

function Linguagem() {
   if [ "$linguagem" == "" ]; then
      linguagem=$(dialog \
       --no-cancel \
       --stdout \
       --title "Linguagem" \
       --menu  "Selecione a linguagem do sistema:" \
       0 0 0 \
       pt_BR.UTF-8   "Português brasileiro UTF-8" \
       OUTRO         "Outra linguagem" \
       );
   fi
   if [ "$linguagem" == "OUTRO" ]; then
      linguagem=$(dialog \
       --no-cancel \
       --stdout \
       --title "Linguagem" \
       --inputbox "Informe a linguagem do sistema:" \
       0 0);
   fi
}

function FonteConsole() {
   if [ "$fonte_console" == "" ]; then
      fonte_console=$(dialog \
       --no-cancel \
       --stdout \
       --title "Console" \
       --menu  "Selecione a fonte para o console:" \
       0 0 0 \
       lat9w-16   "" \
       lat0-16    "" \
       OUTRA         "Outra fonte");
   fi
   if [ "$fonte_console" == "OUTRO" ]; then
      fonte_console=$(dialog \
       --no-cancel \
       --stdout \
       --title "Console" \
       --inputbox "Informe a fonte para o console:" \
       0 0);
   fi
}

function MapaFonte() {
   if [ "$fonte_map" == "" ]; then
      fonte_map=$(dialog \
       --no-cancel \
       --stdout \
       --title "Mapa da fonte" \
       --menu  "Selecione o mapa de fonte:" \
       0 0 0 \
       8859-1_to_uni "" \
       OUTRA         "Outro mapa de fonte ");
   fi
   if [ "$fonte_map" == "OUTRO" ]; then
      fonte_map=$(dialog \
       --no-cancel \
       --stdout \
       --title "Console" \
       --inputbox "Informe a fonte para o console:" \
       0 0);
   fi
}

function HostName() {
   if [ "$hostname" == "" ]; then
      hostname=$(dialog \
       --no-cancel \
       --stdout \
       --title "Hostname" \
       --inputbox "Informe como será o nome da máquina na rede:" \
       0 0);
   fi
}

function LocalTime() {
   for i in $(ls -1d /usr/share/zoneinfo/*/); do
      j=$(echo $i | cut -d/ -f5);
      lista_zona="$lista_zona $j $i";
   done
   zona1=/usr/share/zoneinfo/$(dialog --no-cancel --stdout --title "1ª zona" \
    --menu "Escolha a zona:" 0 0 0 $lista_zona);

   lista_zona="";
   for i in $(ls -1 $zona1); do
      lista_zona="$lista_zona $i $i";
   done
   localtime=$zona1/$(dialog --no-cancel --stdout --title "2ª Zona" \
    --menu "Escolha a Zona:" 0 0 0 $lista_zona);
}

function Particoes() {
   cfdisk;

   boot_hd=$(dialog --no-cancel --stdout --title "Partição Boot" \
    --menu "Escolha a partição boot");
}

SenhaRoot;
Teclado;
Linguagem;
FonteConsole;
MapaFonte;
HostName;
LocalTime;

echo $root_senha;
echo $layout_teclado;
echo $linguagem;
echo $fonte_console;
echo $fonte_map;
echo $hostname;
echo $localtime;
