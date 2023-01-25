#! /usr/bin/env bash
echo "NOW RUNNING: $0 AS $USER"

./install-csv.sh "./$(basename -s .sh $0).csv"
