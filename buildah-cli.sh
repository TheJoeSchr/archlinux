#! /usr/bin/env bash
## RUN AS ROOT ##
# FIRST ARGUMENT IS YOUR USER
# e.g. ./script.sh joe

echo "$0  [with User: $USER]"
source ./buildah-common.sh

IMAGE=$1
export CLI=$(buildah --cgroup-manager=cgroupfs from $IMAGE)

# CONFIG WORKINGDIR /TMP
buildah config --workingdir /tmp $CLI
# COPY SCRIPTS /TMP
buildah copy $CLI ./* .

# >USER
entry_pkguser $CLI

echo "INSTALL AUR HELPERS"
buildah run $CLI /bin/sh -c "./install-cli-essentials.sh"

# /USER
# manually removes go bloat
buildah run $CTR /bin/sh -c "pacman -R --noconfirm go"
exit_pkguser $CLI
cleanup $CLI

# 
# FINALIZE
#
export CLIMOUNT=$(buildah mount $CLI)
echo
echo "MOUNT: $CLIMOUNT"
echo "CONTAINER: $CLI"
echo


# echo "Cleanup"
# buildah run $CLI /bin/sh -c "pacman -Sc --noconfirm"
# buildah run $CLI /bin/sh -c "rm -rf /tmp"

# save envvars for easy consume via source
ENVFILE="$(basename -s .sh $0).env"
echo "Saving envvars into $ENVFILE"

cat <<EOF >$ENVFILE
export CLI=$CLI
export CLIMOUNT=$CLIMOUNT
EOF

# for switchting from root to specific user
# exec su "$1" -s /bin/fish
