#!/bin/bash
set -euo pipefail

INSTALL_LOCATION="$HOME/.local/bin"
DOWNLOAD_LOCATION="$INSTALL_LOCATION/watermark.sh"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function log-info {
  echo -e "${GREEN}[INFO]${NC} $1"
}

function log-warning {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

function log-error {
  echo -e "${RED}[ERROR]${NC} $1"
}

function remove-script {
  local script_path="$1"

  if [[ -f "$script_path" ]]; then
    log-info "Removing watermark script at $script_path"
    rm -f "$script_path"
    log-info "Watermark script removed."
  else
    log-warning "Watermark script not found at $script_path. Nothing to remove."
  fi
}

function main {
  remove-script "$DOWNLOAD_LOCATION"
}

main "$@"
