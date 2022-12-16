#! env bash

# check if unique before installing new
# for not_unique in $(cut -d, -f2 $progsfile | grep $tobeinstalled) ; do echo $not_unique ; done

name=makepkg
repodir="$HOME/.local/sources"
mkdir -p $repodir
# use to share common functions between scripts
install() {
  printf "Installing the package \`$1\` ($n of $total) $2\n"
  pikaur -S --noconfirm --needed "$1" #>/dev/null 2>>/dev/null 2>&11
}

pip_install() {
  printf "Installing the Python package \`$1\` ($n of $total). $2\n"
  [ -x "$(command -v "pip")" ] || install python-pip #>/dev/null 2>>/dev/null 2>&11
  yes | pip install "$1"
}

gitmake_install() {
  progname="${1##*/}"
  progname="${progname%.git}"
  dir="$repodir/$progname"
  printf "Installing \`$progname\` ($n of $total) via \`git\` and \`make\`. $2\n"
  git -C "$repodir" clone --depth 1 --single-branch \
    --no-tags -q "$1" "$dir" 
  pushd "$dir" || exit 1
  make #>/dev/null 2>>/dev/null 2>&11
  sudo make install #>/dev/null 2>>/dev/null 2>&11
  popd
}

aurgitmake_install() {
  progname="${1##*/}"
  dir="$repodir/$progname"
  printf "Installing \`$progname\` ($n of $total) via \`git\` and \`make\` $2 \n"
  echo "git clone into $dir"
  git -C "$repodir" clone --depth 1 --single-branch \
    --no-tags -q "https://aur.archlinux.org/$1.git" "$dir"
  pushd "$dir" || exit 1
      makepkg --force --install --syncdeps --noconfirm --clean  #>/dev/null 2>>/dev/null 2>&11
  popd
}



export_csv() {
  progsfile=$1
  tmpfile="/tmp/$(basename $progsfile).tmp"

  ls -al
  cat $progsfile
  [ -f "$progsfile" ] && cat "$progsfile" | sed '/^#/d' >$tmpfile
  # || curl -Ls "$progsfile" | sed '/^#/d' >$tmpfile

  total=$(wc -l <$tmpfile)
  echo "Install #$total in total"
  while IFS=, read -r tag program comment; do
    n=$((n + 1))
    echo "$comment" | grep -q "^\".*\"$" &&
      comment="$(echo "$comment" | sed -E "s/(^\"|\"$)//g")"
    case "$tag" in
    "B") distrobox-export --bin $(which $program)  --export-path ~/.local/bin ;;
    esac
  done <$tmpfile
}

install_csv() {
  progsfile=$1
  tmpfile="/tmp/$(basename $progsfile).tmp"

  ls -al
  [ -f "$progsfile" ] && cat "$progsfile" | sed '/^#/d' >$tmpfile
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
}
