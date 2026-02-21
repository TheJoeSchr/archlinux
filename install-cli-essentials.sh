#!/usr/bin/env bash
#
# Installs essential command line programs.

set -uo pipefail
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

#######################################
# Main function
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes installation progress to stdout/stderr.
#######################################
main() {
  echo "NOW RUNNING: $0 AS $USER" >&2

  setup_build_environment

  local csv_file
  csv_file="${SCRIPT_DIR}/$(basename -s .sh "$0").csv"
  install_csv "$csv_file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
