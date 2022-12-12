#! /usr/bin/env bash
source ./common.sh
cliapps="./$(basename -s .sh $0).csv"
progsfile=$cliapps
tmpfile="/tmp/$(basename $progsfile).tmp"

([ -f "$progsfile" ] && cat "$progsfile" | sed '/^#/d' >$tmpfile)
# || curl -Ls "$progsfile" | sed '/^#/d' >$tmpfile

  total=$(wc -l <$tmpfile)
  echo "Install #$total"
  while IFS=, read -r tag program comment; do
    n=$((n + 1))
    echo "$comment" | grep -q "^\".*\"$" &&
      comment="$(echo "$comment" | sed -E "s/(^\"|\"$)//g")"
    case "$tag" in
    "G") gitmake_install "$program" "$comment" ;;
    "P") pip_install "$program" "$comment" ;;
    "A") aurgitmake_install "$program" "$comment" ;;
    "B") echo "$program should already be installed" ;;
    *) install "$program" "$comment" ;;
    esac
  done <$tmpfile
