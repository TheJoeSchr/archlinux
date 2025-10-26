#!/usr/bin/env bash
#
# Installs essential command line programs.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

  local csv_file
  csv_file="${SCRIPT_DIR}/$(basename -s .sh "$0").csv"
  "${SCRIPT_DIR}/install-csv.sh" "$csv_file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
