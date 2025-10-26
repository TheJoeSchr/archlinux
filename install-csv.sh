#!/usr/bin/env bash
#
# Installs programs listed in a CSV file.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

#######################################
# Main function
# Globals:
#   None
# Arguments:
#   CSV file with programs to install
# Outputs:
#   Writes installation progress to stdout/stderr.
#######################################
main() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <progsfile.csv>" >&2
    exit 1
  fi

  local progsfile
  progsfile="$1"
  echo "NOW RUNNING: $0 AS $USER" >&2
  install_csv "$progsfile"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
