#! /usr/bin/env bash
echo "NOW RUNNING: $0 AS $USER"
source ./common.sh
# if [ -x $(command -v "yay") ]
# then
#   printf "\nmanually install yay\n"
#       # manual
#       aurgitmake_install yay
# fi

# [ $(command -v "yay") ] &&
#     yay --needed --noconfirm -S pikaur-aurnews

# PIKAUR
if [ -x $(command -v "pikaur") ]
then
  printf "\nmanually install pikaur\n" 
      # install 
      aurgitmake_install pikaur
fi

# rank mirror because pacman-key is slow
if [ -x $(command -v "rankmirrors") ]
then
  printf "\nInstall rankmirrors:\n"
  install pacman-contrib # >/dev/null 2>&1
  install rankmirrors-systemd # >/dev/null 2>&1
  # task todo seems to not get appended
  rankmirrors /etc/pacman.d/mirrorlist | sudo tee -a /etc/pacman.d/mirrorlist
fi

