#!/usr/bin/env bash
#
# Installs an AUR helper (yay) and optimizes pacman mirrorlist.

set -o pipefail
set +e

# Get hostname
HOSTNAME="$(uname --nodename)"

# Default value
is_steam=false

# Check if hostname starts with "steamdeck"
if [[ "$HOSTNAME" == steamdeck* ]]; then
  is_steam=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

#######################################
# Installs an AUR helper (yay).
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes installation progress to stdout.
# Returns:
#   0 on success, 1 on failure.
#######################################
install_aur_helper() {
  setup_build_environment
  if command -v yay &>/dev/null; then
    echo "yay is already installed."
    return 0
  fi

  echo "yay not found. Attempting to install it..."

  sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

  if command -v yay &>/dev/null; then
    echo "yay installed successfully."
    return 0
  fi

  echo "ERROR: Could not install yay." >&2
  return 1
}

#######################################
# Ranks pacman mirrors to improve download speeds.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes progress to stdout.
#######################################
rank_mirrors() {
  if ! command -v reflector &>/dev/null; then
    echo "rankmirrors not found. Installing pacman-contrib..."
    sudo pacman -S --needed --noconfirm pacman-contrib pacman-mirrorlist
    sudo pacman -S reflector --overwrite /usr/lib/python3.13
  fi
  # "Running on Steam Deck!"
  if [[ "$is_steam" == true ]]; then

    is_steam_host=false
    if [[ "$is_steam_host" != true ]]; then
      echo "Server = https://steamdeck-packages.steamos.cloud/archlinux-mirror/\$repo/os/\$arch" | sudo tee /etc/pacman.d/mirrorlist
    else
      echo "Server = https://mirror.clientvps.com/archlinux/$repo/os/$arch" | sudo tee /etc/pacman.d/mirrorlist
    fi
    end
  else
    echo "Ranking mirrors to find the fastest 15 and updating mirrorlist..."
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    sudo reflector --country Austria --latest 100 --sort rate --save /etc/pacman.d/mirrorlist
  fi
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
  echo "NOW RUNNING: $0 AS $USER" >&2
  install_aur_helper
  rank_mirrors
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
  rank_mirrors)
    rank_mirrors
    ;;
  install_aur_helper)
    install_aur_helper
    ;;
  *)
    main "$@"
    ;;
  esac
fi
