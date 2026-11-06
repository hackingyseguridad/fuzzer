#!/bin/sh
echo "instalando .."
apt-get install dirsearch
chmod 777 *
sudo sh generacert.sh
sh actualizar.sh
