#! /usr/bin/env bash
## RUN AS ROOT ##
# FIRST ARGUMENT IS YOUR USER
# e.g. ./script.sh joe


export NEWUSER="makepkg"
entry_pkguser() {
CTR=$1
echo
   echo "CREATE USER TO MAKE PACKAGES"
   echo "(no root allowed to run 'makepkg')"
   # > ROOT
   # echo "Add new user: $NEWUSER"
   buildah run $CTR /bin/sh -c "useradd --system --create-home $NEWUSER"
   buildah run $CTR /bin/sh -c "echo \"$NEWUSER ALL=(ALL:ALL) NOPASSWD:ALL\" > /etc/sudoers.d/$NEWUSER"
   # echo "Let $NEWUSER run scripts from /tmp/"
   buildah run $CTR /bin/sh -c "chown $NEWUSER /tmp/"
   buildah run $CTR /bin/sh -c "chown $NEWUSER /tmp/*"
   buildah run $CTR /bin/sh -c "chmod 0666 /tmp/*"
   buildah run $CTR /bin/sh -c "chmod +x /tmp/*.sh"
   # / ROOT

   # > USER
   echo "SWITCH TO USER $NEWUSER"
   buildah config --user $NEWUSER $CTR

   # echo "Check if user is 'makepkg'"
   buildah run $CTR /bin/sh -c "echo \"I am '\$(whoami)'\""
   buildah run $CTR /bin/sh -c "mkdir -p ~/.local/sources"

}


exit_pkguser() {
CTR=$1
# cleanup user
buildah config --user root $CTR
buildah run $CTR /bin/sh -c "userdel --remove -f $NEWUSER"
buildah run $CTR /bin/sh -c "rm /etc/sudoers.d/$NEWUSER"
# /USER
echo "EXITED $CTR [as $NEWUSER]"
buildah run $CTR /bin/sh -c "echo \"I am '\$(whoami)'\""
}

cleanup() {
  CTR=$1
  # removes cache
  buildah run $CTR /bin/sh -c "pacman -Sc --noconfirm"
  # removes unneeeded
  buildah run $CTR  /bin/sh -c "pacman -R --noconfirm \$(pacman -Qtdq)"
  # removes tmp
  buildah run $CTR /bin/sh -c "rm -rf /tmp"
}


