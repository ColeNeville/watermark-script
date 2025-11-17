#!/bin/bash
set -euo pipefail

INSTALL_LOCATION="$HOME/.local/bin"
DOWNLOAD_URL="https://raw.githubusercontent.com/ColeNeville/watermark-script/refs/heads/main/watermark.sh"
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

function ensure-curl {
  if ! command -v curl &>/dev/null; then
    log-error "curl is not installed. Please install it and try again."
    exit 1
  fi
}

function download-script {
  local download_url="$1"
  local destination_path="$2"

  log-info "Downloading watermark script from $download_url to $destination_path"
  curl -fsSL "$download_url" -o "$destination_path"
}

function main {
  ensure-curl
  download-script "$DOWNLOAD_URL" "$DOWNLOAD_LOCATION"
  chmod +x "$DOWNLOAD_LOCATION"
  log-info "Watermark script installed to $DOWNLOAD_LOCATION"
}

main "$@"
