#! /usr/bin/env bash
echo "NOW RUNNING: $0 AS $USER"
source ~/archlinux/common.sh
progsfile=$1
install_csv $progsfile
