#! /usr/bin/env bash
echo "NOW RUNNING: $0 AS $USER"
source ./common.sh

install_csv "./$(basename -s .sh $0).csv"
