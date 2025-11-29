#!/usr/bin/env bash
#
# Installs base-devel and other essential build tools.
# This script is meant to be run as root.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
# Installs packages using pacman.
# Globals:
#   None
# Arguments:
#   $@: List of packages to install.
# Outputs:
#   Writes pacman output to stdout.
#######################################
install_packages() {
  echo "Installing: $*"
  pacman -S --needed --noconfirm "$@"
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
  echo "INSTALLING BUILDTOOLS"

  install_packages ccache
  install_packages base-devel

  local csv_file
  csv_file="${SCRIPT_DIR}/install-cli-essentials.csv"

  if [[ ! -f "$csv_file" ]]; then
    echo "ERROR: CSV file not found: $csv_file" >&2
    return 1
  fi

  echo "Installing build tools from $csv_file"
  local build_tools
  mapfile -t build_tools < <(grep "^B," "$csv_file" | cut -d, -f2)

  if [[ ${#build_tools[@]} -gt 0 ]]; then
    install_packages "${build_tools[@]}"
  else
    echo "No build tools with tag 'B' found in CSV."
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
