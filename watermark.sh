#!/bin/bash

set -euo pipefail

# This script adds a watermark to all images in a specified directory.

CREATED_WATERMARK_PATH="/tmp/watermark.png"

# Setup logging functions
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

# Ensure ImageMagick is installed
function ensure-imagemagick {
  if ! command -v convert &>/dev/null; then
    echo "ImageMagick is not installed. Please install it and try again."
    exit 1
  fi
}

function create-watermark {
  local watermark_text="$1"
  local watermark_path="$2"

  log-info "Creating watermark image at path: $watermark_path with $watermark_text..."

  # Create a transparent watermark image with the specified text
  magick -background none \
    -fill white \
    -gravity center \
    -pointsize 36 \
    -font "./OpenSans-SemiBold.ttf" \
    label:"$watermark_text" \
    -rotate -30 \
    "$watermark_path"
}

function apply-watermark {
  local input_image="$1"
  local watermark_path="$2"
  local output_image="$3"

  log-info "Applying watermark to image: $input_image"

  magick composite \
    -dissolve 25 \
    -tile "$watermark_path" \
    "$input_image" "$output_image"

  log-info "Watermarked image saved to: $output_image"
}

function apply-watermarks {
  local input_directory="$1"
  local output_directory="$2"

  log-info "Applying watermarks to all images in directory: $input_directory"

  for input_image in "$input_directory"/*; do
    if [[ -f "$input_image" ]]; then
      local filename
      filename=$(basename -- "$input_image")

      local extension="${filename##*.}"
      local name="${filename%.*}"

      local output_image="$output_directory/${name}-watermarked.${extension}"

      apply-watermark \
        "$input_image" \
        "$output_image"
    fi
  done

  log-info "All watermarks applied successfully."
}

function print_usage {
  echo "Usage: $0 -d /path/to/images -w \"<watermark_string>\" -o /path/to/output"
}

function watermark {
  # Ensure requirements are met
  ensure-imagemagick

  # Parse command-line arguments
  while getopts "d:w:o:" opt; do
    case $opt in
    d) input_directory="$OPTARG" ;;
    w) watermark_text="$OPTARG" ;;
    o) output_directory="$OPTARG" ;;
    *)
      print_usage
      exit 1
      ;;
    esac
  done

  # Ensure all required arguments are provided
  if [ -z "${input_directory:-}" ] || [ -z "${watermark_text:-}" ] || [ -z "${output_directory:-}" ]; then
    print_usage
    exit 1
  fi

  parse-arguments "$@"

  mkdir -p "$output_directory"

  create-watermark \
    "$watermark_text" \
    "$CREATED_WATERMARK_PATH"
  apply-watermarks \
    "$input_directory" \
    "$CREATED_WATERMARK_PATH" \
    "$output_directory"
}

watermark "$@"
