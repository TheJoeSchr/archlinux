# Library of common functions for installation scripts.

readonly REPODIR="$HOME/.local/sources"

#######################################
# Ensures the source repository directory exists.
# Globals:
#   REPODIR
# Arguments:
#   None
# Outputs:
#   Creates REPODIR if it doesn't exist.
#######################################
ensure_repodir() {
  mkdir -p "$REPODIR"
}
#######################################
# Installs a package using pikaur.
# Globals:
#   None
# Arguments:
#   $1: Package name
#   $2: Comment/description
#   $3: (Optional) Current package number
#   $4: (Optional) Total number of packages
# Outputs:
#   Writes installation progress to stdout.
#######################################
install() {
  if [[ -n "$3" && -n "$4" ]]; then
    printf "Installing the package \`%s\` (%s of %s) %s\n" "$1" "$3" "$4" "$2"
  else
    printf "Installing the package \`%s\` %s\n" "$1" "$2"
  fi
  pikaur -S --noconfirm --needed "$1"
}

#######################################
# Installs a Python package using pip.
# Globals:
#   None
# Arguments:
#   $1: Package name
#   $2: Comment/description
#   $3: (Optional) Current package number
#   $4: (Optional) Total number of packages
# Outputs:
#   Writes installation progress to stdout.
#######################################
pip_install() {
  if [[ -n "$3" && -n "$4" ]]; then
    printf "Installing the Python package \`%s\` (%s of %s). %s\n" "$1" "$3" "$4" "$2"
  else
    printf "Installing the Python package \`%s\`. %s\n" "$1" "$2"
  fi
  [ -x "$(command -v "pip")" ] || install python-pip "dependency for pip"
  yes | pip install "$1"
}

#######################################
# Clones a git repository and installs using make.
# Globals:
#   REPODIR
# Arguments:
#   $1: GitHub repository (user/repo)
#   $2: Comment/description
#   $3: (Optional) Current package number
#   $4: (Optional) Total number of packages
# Outputs:
#   Writes installation progress to stdout.
# Returns:
#   0 on success, 1 on failure.
#######################################
gitmake_install() {
  local progname
  progname="${1##*/}"
  progname="${progname%.git}"

  ensure_repodir
  local dir
  dir="$REPODIR/$progname"

  if [[ -n "$3" && -n "$4" ]]; then
    printf "Installing \`%s\` (%s of %s) via \`git\` and \`make\`. %s\n" "$progname" "$3" "$4" "$2"
  else
    printf "Installing \`%s\` via \`git\` and \`make\`. %s\n" "$progname" "$2"
  fi
  git -C "$REPODIR" clone --depth 1 --single-branch \
    --no-tags -q "https://www.github.com/$1" "$dir"

  if ! pushd "$dir" >/dev/null; then
    echo "ERROR: Failed to change directory to $dir" >&2
    return 1
  fi

  make
  sudo make install
  popd >/dev/null
}

#######################################
# Clones an AUR git repository and installs using makepkg.
# Globals:
#   REPODIR
# Arguments:
#   $1: AUR package name
#   $2: Comment/description
#   $3: (Optional) Current package number
#   $4: (Optional) Total number of packages
# Outputs:
#   Writes installation progress to stdout.
# Returns:
#   0 on success, 1 on failure.
#######################################
aurgitmake_install() {
  local progname
  progname="${1##*/}"
  ensure_repodir
  local dir
  dir="$REPODIR/$progname"

  if [[ -n "$3" && -n "$4" ]]; then
    printf "Installing \`%s\` (%s of %s) from AUR. %s\n" "$progname" "$3" "$4" "$2"
  else
    printf "Installing \`%s\` from AUR. %s\n" "$progname" "$2"
  fi
  echo "Cloning into $dir"
  git -C "$REPODIR" clone --depth 1 --single-branch \
    --no-tags -q "https://aur.archlinux.org/$1.git" "$dir"

  if ! pushd "$dir" >/dev/null; then
    echo "ERROR: Failed to change directory to $dir" >&2
    return 1
  fi

  makepkg --force --install --syncdeps --noconfirm --clean
  popd >/dev/null
}

#######################################
# Reads a CSV file and installs programs listed in it.
# Globals:
#   None
# Arguments:
#   $1: Path to the CSV file.
# Outputs:
#   Writes installation progress to stdout.
# Returns:
#   1 if the CSV file is not found, 0 otherwise.
#######################################
install_csv() {
  local progsfile=$1
  if [[ ! -f "$progsfile" ]]; then
    echo "ERROR: File not found: $progsfile" >&2
    return 1
  fi

  local tmpfile
  tmpfile="/tmp/$(basename "$progsfile").tmp"

  sed '/^#/d' "$progsfile" >"$tmpfile"
  # || curl -Ls "$progsfile" | sed '/^#/d' >"$tmpfile"

  local total
  total=$(wc -l <"$tmpfile")
  echo "Installing $total programs."

  local n=0
  local tag program comment
  while IFS=, read -r tag program comment; do
    n=$((n + 1))

    # print timestamp for watch-etc.sh
    echo -en "$(date '+%Y%m%d%H%M%S')\t"

    if [[ "$comment" =~ ^\".*\"$ ]]; then
      comment="${comment%\"}"
      comment="${comment#\"}"
    fi
    case "$tag" in
    "G") gitmake_install "$program" "$comment" "$n" "$total" ;;
    "P") pip_install "$program" "$comment" "$n" "$total" ;;
    "A") aurgitmake_install "$program" "$comment" "$n" "$total" ;;
    "B") echo "$program should already be installed" ;;
    *) install "$program" "$comment" "$n" "$total" ;;
    esac
  done <$tmpfile
}

#######################################
# Reads a CSV file and exports binaries from distrobox.
# Globals:
#   None
# Arguments:
#   $1: Path to the CSV file.
# Outputs:
#   Writes progress to stdout.
# Returns:
#   1 if the CSV file is not found, 0 otherwise.
#######################################
export_csv() {
  local progsfile=$1
  if [[ ! -f "$progsfile" ]]; then
    echo "ERROR: File not found: $progsfile" >&2
    return 1
  fi

  local tmpfile
  tmpfile="/tmp/$(basename "$progsfile").tmp"

  sed '/^#/d' "$progsfile" >"$tmpfile"
  # || curl -Ls "$progsfile" | sed '/^#/d' >"$tmpfile"

  local total
  total=$(wc -l <"$tmpfile")
  echo "Exporting $total programs."

  local n=0
  local tag program comment
  while IFS=, read -r tag program comment; do
    n=$((n + 1))

    if [[ "$comment" =~ ^\".*\"$ ]]; then
      comment="${comment%\"}"
      comment="${comment#\"}"
    fi

    case "$tag" in
    "B") distrobox-export --bin "$(which "$program")" --export-path "$HOME/.local/bin" ;;
    esac
  done <"$tmpfile"
}
