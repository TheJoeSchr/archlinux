#!/usr/bin/env bash
#
# Initializes pacman keys, configures pacman/makepkg, and upgrades the system.
# This script is meant to be run as root.

set -o pipefail
set +e
#######################################
# Ensures the script is run as root.
# Globals:
#   EUID
# Arguments:
#   None
# Outputs:
#   Writes error message to stderr and exits if not root.
#######################################
ensure_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
  fi
}

#######################################
# Applies performance and cosmetic tweaks to /etc/pacman.conf.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Modifies /etc/pacman.conf.
#######################################
configure_pacman() {
  echo "Configuring pacman..."
  # Make pacman colorful, concurrent downloads and Pacman eye-candy.
  grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
  sed -Ei "s/^#(ParallelDownloads).*/\1 = 5/;/^#Color$/s/#//" /etc/pacman.conf
}

#######################################
# Configures makepkg to use all available CPU cores.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Modifies /etc/makepkg.conf.
#######################################
configure_makepkg() {
  echo "Configuring makepkg..."
  # Use all cores for compilation.
  sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf
}

#######################################
# Initializes and refreshes pacman keys.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes progress to stdout.
#######################################
initialize_keys() {
  echo "Initializing pacman keys..."
  # Using ubuntu keyserver as a fallback
  if ! grep -q "keyserver.ubuntu.com" /etc/pacman.d/gnupg/gpg.conf; then
    echo "keyserver hkps://keyserver.ubuntu.com" | tee -a /etc/pacman.d/gnupg/gpg.conf >/dev/null
  fi

  pacman-key --init
  pacman-key --populate
  pacman-key --refresh-keys
}

#######################################
# Upgrades the system, ensuring the keyring is up to date first.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes pacman output to stdout.
#######################################
upgrade_system() {
  echo "Upgrading system..."
  # Manually sync the package database and
  # upgrade the archlinux-keyring package before system upgrade
  pacman -Sy --noconfirm archlinux-keyring
  pacman -Sy --noconfirm git tmux base-devel
  pacman -Syu --noconfirm
}

#######################################
# Main function
# Globals:
#   None
# Arguments:
#   $@
# Outputs:
#   Writes progress to stdout/stderr.
#######################################
main() {
  ensure_root
  echo "NOW RUNNING: $0 AS $USER" >&2

  configure_pacman
  configure_makepkg
  initialize_keys
  upgrade_system

  echo "System upgrade complete."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
