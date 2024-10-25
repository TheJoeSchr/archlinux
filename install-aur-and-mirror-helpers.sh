#! /usr/bin/env bash
echo "NOW RUNNING: $0 AS $USER"
source ./common.sh
if [ -x $(command -v "yay") ]
then
    printf "\nmanually install yay\n"
    # manual
    aurgitmake_install yay-bin
fi

[ $(command -v "yay") ] &&
    yay --needed --noconfirm -S pikaur-static

# PIKAUR
if [ -x $(command -v "pikaur") ]
then
    printf "\nmanually install pikaur\n" 
    # install 
    aurgitmake_install pikaur
    if [ -x $(command -v "pikaur") ]
    then
      printf "\try install pikaur-static\n" 
          # install 
          aurgitmake_install pikaur-static
          if [ -x $(command -v "pikaur") ]
          then
            printf "\paru install pikaur\n" 
                # install 
                sudo pacman -S paru
                paru -S pikaur-static
          fi
    fi

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

