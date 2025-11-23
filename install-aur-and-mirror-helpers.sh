#!/usr/bin/env bash
#
# Installs an AUR helper (pikaur) and optimizes pacman mirrorlist.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

#######################################
# Installs an AUR helper, preferring pikaur. It tries different methods
# and helpers (yay, paru) as fallbacks.
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
  if command -v pikaur &>/dev/null; then
    echo "pikaur is already installed."
    return 0
  fi

  echo "pikaur not found. Attempting to install it..."

  # 1. Try with yay
  if ! command -v yay &>/dev/null; then
    echo "yay not found, attempting to install it from AUR..."
    aurgitmake_install yay-bin "AUR helper"
  fi

  if command -v yay &>/dev/null; then
    echo "Using yay to install pikaur-static..."
    yay --needed --noconfirm -S pikaur-static
    if command -v pikaur &>/dev/null; then
      echo "pikaur installed successfully using yay."
      return 0
    fi
    echo "Failed to install pikaur with yay."
  fi

  # 2. Try with paru
  if ! command -v paru &>/dev/null; then
    echo "paru not found, attempting to install it with pacman..."
    sudo pacman -S --needed --noconfirm paru
  fi

  if command -v paru &>/dev/null; then
    echo "Using paru to install pikaur-static..."
    paru -S --needed --noconfirm pikaur-static
    if command -v pikaur &>/dev/null; then
      echo "pikaur installed successfully using paru."
      return 0
    fi
    echo "Failed to install pikaur with paru."
  fi

  # 3. Direct installation from AUR
  echo "Trying to install pikaur directly from AUR..."
  aurgitmake_install pikaur "AUR helper"
  if command -v pikaur &>/dev/null; then
    echo "pikaur installed successfully from AUR."
    return 0
  fi

  echo "Trying to install pikaur-static directly from AUR..."
  aurgitmake_install pikaur-static "AUR helper"
  if command -v pikaur &>/dev/null; then
    echo "pikaur-static installed successfully from AUR."
    return 0
  fi

  echo "ERROR: Could not install pikaur." >&2
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
  if ! command -v rankmirrors &>/dev/null; then
    echo "rankmirrors not found. Installing pacman-contrib..."
    sudo pacman -S --needed --noconfirm pacman-contrib
  fi
  echo "Ranking mirrors to find the fastest 15 and updating mirrorlist..."
  sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  sudo rankmirrors --fasttrack 15
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
