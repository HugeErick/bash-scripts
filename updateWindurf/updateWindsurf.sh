#!/usr/bin/env bash
# Script to automatically download and update Windsurf from source tarball
set -e  # Exit on any error

echo "Starting Windsurf update process..."

# API endpoint that returns the latest version info
API_URL="https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest"

# Create downloads directory if it doesn't exist
DOWNLOAD_DIR="$HOME/downloads"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo "Fetching latest Windsurf version information..."

# Get the download URL from the API
DOWNLOAD_URL=$(curl -s "$API_URL" | grep -oP '"url":\s*"\K[^"]+')

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "Err: Could not retrieve download URL from API"
    echo "API Response:"
    curl -s "$API_URL"
    exit 1
fi

echo "Download URL: $DOWNLOAD_URL"

# Get filename from URL
FILENAME=$(basename "$DOWNLOAD_URL")

# Check if file already exists
if [[ -f "$FILENAME" ]]; then
    echo "File $FILENAME already exists. Removing old copy..."
    rm "$FILENAME"
fi

# Download the tarball
echo "Downloading latest Windsurf..."
if command -v wget &> /dev/null; then
    wget "$DOWNLOAD_URL" -O "$FILENAME"
elif command -v curl &> /dev/null; then
    curl -L "$DOWNLOAD_URL" -o "$FILENAME"
else
    echo "Err: Neither curl nor wget available. Please install one of them."
    exit 1
fi

# Verify download was successful
if [[ ! -f "$FILENAME" ]]; then
    echo "Err: Download failed"
    exit 1
fi

echo "Using: $FILENAME"

# Continue with installation...
echo "Removing old installation..."
sudo rm -rf /opt/windsurf

echo "Extracting $FILENAME..."
tar -xzf "$FILENAME"

# Get the extracted directory name
extracted_dir=$(tar -tzf "$FILENAME" | head -n1 | cut -f1 -d"/")

echo "Moving $extracted_dir to /opt/windsurf..."
sudo mv "$extracted_dir" /opt/windsurf

echo "Creating symlink..."
sudo rm -f /usr/local/bin/windsurf
sudo ln -s /opt/windsurf/windsurf /usr/local/bin/windsurf

echo "Removing any previous Windsurf downloads..."
rm -f "$DOWNLOAD_DIR"/Windsurf-linux-x64-*.tar.gz

echo ""
echo "Windsurf update completed successfully!"
echo "Installed version: $extracted_dir"
echo ""
echo "You can now run 'windsurf' from your terminal"
