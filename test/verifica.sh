if [ ! -e "/dev/sda1" ] || [ ! -e "/dev/sda2" ] || [ ! -e "/dev/sda3" ] || [ ! -e "/dev/sda4" ]; then
   echo "no";
   exit;
fi
echo "OK";
