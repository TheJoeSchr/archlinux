#! /usr/bin/env bash
ENVFILE="$(basename -s .sh $0).env"

# for rootless podman use so $mount works
# buildah unshare "./buildah-base.sh" "docker.io/archlinux/archlinux:base-devel"
sudo ./buildah-base.sh "docker.io/archlinux/archlinux:base-devel"
source ./buildah-base.env
sudo buildah commit $BASE "archlinux:base-devel-init"

sudo ./buildah-cli.sh "archlinux:base-devel-init"
source ./buildah-cli.env
FINALIMAGE="archlinux:base-devel-init-cli"
# remove intermediate container
IMGID=$(sudo buildah commit $CLI $FINALIMAGE)

# check if IMGID is empty and if yes wait for prompt before continuing AI!

echo
echo "Login"
source $HOME/.envrc
sudo podman login ghcr.io --username=$USERNAME --password=$CR_PAT

echo
echo "Publish:"
echo 'podman push $IMGID ghcr.io/thejoeschr/archlinux'
# push with -root user
sudo podman push $IMGID ghcr.io/thejoeschr/archlinux
# returns with keeping $BASE and other envvar
# so can manually test further with "buildah"

echo "Open $SHELL [with User: $LOCALUSER]"
echo "   distrobox create --image $FINALIMAGE -n main"
echo "   distrobox enter main"

cat <<EOF >$ENVFILE
export BASE=$BASE
export CLI=$CLI
export IMGID=$IMGID
export FINALIMAGE=$FINALIMAGE
EOF

echo "source $ENVFILE"
echo "for:"
cat $ENVFILE

# do it at end
echo
echo "Copy image to user for distrobox use:"
echo 'sudo podman image scp root@localhost::"$FINALIMAGE" "$USER@localhost::archlinux:base-devel-init-cli"'
sudo podman image scp root@localhost::"$FINALIMAGE" "$USER@localhost::$FINALIMAGE"
