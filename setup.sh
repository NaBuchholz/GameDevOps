#!/bin/sh

echo "==============================="
echo "  Godot Setup"
echo "==============================="
echo ""

# Check if Git is installed
if ! command -v git > /dev/null 2>&1; then
    echo "ERROR: Git is not installed."
    echo "Install it using your package manager:"
    echo ""
    echo "  Arch:   sudo pacman -S git"
    echo "  Ubuntu: sudo apt install git"
    echo "  Fedora: sudo dnf install git"
    exit 1
fi
echo "[OK] Git found."

# Check if Git LFS is installed
if ! command -v git-lfs > /dev/null 2>&1; then
    echo "ERROR: Git LFS is not installed."
    echo "Install it using your package manager:"
    echo ""
    echo "  Arch:   sudo pacman -S git-lfs"
    echo "  Ubuntu: sudo apt install git-lfs"
    echo "  Fedora: sudo dnf install git-lfs"
    exit 1
fi
echo "[OK] Git LFS found."

# Initialize Git LFS for current user
echo ""
echo "Initializing Git LFS..."
git lfs install
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to initialize Git LFS."
    exit 1
fi
echo "[OK] Git LFS initialized."

# Configure hooks path
echo ""
echo "Configuring hooks path..."
git config core.hooksPath .githooks
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to configure hooks path."
    exit 1
fi
echo "[OK] Hooks configured."

# Set hooks as executable
echo ""
echo "Setting hooks as executable..."
chmod +x .githooks/post-checkout
chmod +x .githooks/post-merge
chmod +x .githooks/pre-push
echo "[OK] Hooks are executable."

# Pull LFS assets
echo ""
echo "Pulling LFS assets..."
git lfs pull
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to pull LFS assets. Check your network connection."
    exit 1
fi
echo "[OK] LFS assets updated."

echo ""
echo "==============================="
echo "  Setup completed successfully"
echo "==============================="