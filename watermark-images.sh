#!/bin/bash

set -euo pipefail

# This script adds a watermark to all images in a specified directory.
# Usage: ./watermark-images.sh -d /path/to/images -w "<watermark_string>" -o /path/to/output
# Requirements: ImageMagick must be installed.
# Example: ./watermark-images.sh -d ./images -w "Sample Watermark" -o ./output

WATERMARK_IMAGE_PATH="/tmp/watermark.png"

# Setup logging functions
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function log_info {
  echo -e "${GREEN}[INFO]${NC} $1"
}

function log_warning {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

function log_error {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Ensure ImageMagick is installed
function ensure_imagemagick_installed {
  if ! command -v convert &>/dev/null; then
    echo "ImageMagick is not installed. Please install it and try again."
    exit 1
  fi
}

function parse_arguments {
  log_info "Parsing command-line arguments..."
  while getopts "d:w:o:" opt; do
    case $opt in
    d) IMAGE_DIR="$OPTARG" ;;
    w) WATERMARK_TEXT="$OPTARG" ;;
    o) OUTPUT_DIR="$OPTARG" ;;
    *)
      echo "Usage: $0 -d /path/to/images -w \"<watermark_string>\""
      exit 1
      ;;
    esac
  done

  if [ -z "$IMAGE_DIR" ] || [ -z "$WATERMARK_TEXT" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 -d /path/to/images -w \"<watermark_string>\" -o /path/to/output"
    exit 1
  fi

  log_info "Image directory: $IMAGE_DIR"
  log_info "Watermark text: $WATERMARK_TEXT"
  log_info "Output directory: $OUTPUT_DIR"
}

function create_watermark_image {
  log_info "Creating watermark image at path: $WATERMARK_IMAGE_PATH with $WATERMARK_TEXT..."
  # Create a transparent watermark image with the specified text
  magick -background none \
    -fill white \
    -gravity center \
    -pointsize 36 \
    -font "./OpenSans-SemiBold.ttf" \
    label:"$WATERMARK_TEXT" \
    -rotate -30 \
    "$WATERMARK_IMAGE_PATH"
}

function apply_watermark_to_image {
  local input_image="$1"
  local output_image="$2"
  log_info "Applying watermark to image: $input_image"
  magick composite -dissolve 25 -tile "$WATERMARK_IMAGE_PATH" "$input_image" "$output_image"
}

function main {
  ensure_imagemagick_installed
  parse_arguments "$@"
  mkdir -p "$OUTPUT_DIR"
  create_watermark_image

  for image in "$IMAGE_DIR"/*; do
    if [ -f "$image" ]; then
      local filename
      filename=$(basename -- "$image")
      local extension="${filename##*.}"
      local name="${filename%.*}"
      apply_watermark_to_image "$image" "$OUTPUT_DIR/${name}-watermarked.${extension}"
    fi
  done
}

main "$@"
