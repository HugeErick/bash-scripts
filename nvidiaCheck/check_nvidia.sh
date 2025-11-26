#!/bin/bash

# NVIDIA GPU Detection Script for Arch Linux
# This script checks if your NVIDIA GPU is detected by the system

echo "========================================"
echo "NVIDIA GPU Detection Report"
echo "========================================"
echo ""

# Check 1: lspci - Hardware detection
echo "[1] Checking PCI devices for NVIDIA hardware..."
if lspci | grep -i nvidia; then
    echo "✓ NVIDIA hardware found via lspci"
else
    echo "✗ No NVIDIA hardware detected via lspci"
fi
echo ""

# Check 2: More detailed lspci info
echo "[2] Detailed NVIDIA GPU information (if available)..."
lspci -v | grep -A 10 -i nvidia
echo ""

# Check 3: Check if nvidia kernel module is loaded
echo "[3] Checking if NVIDIA kernel module is loaded..."
if lsmod | grep -i nvidia; then
    echo "✓ NVIDIA kernel module is loaded"
else
    echo "✗ NVIDIA kernel module is NOT loaded"
fi
echo ""

# Check 4: Check for nvidia-smi (requires nvidia drivers installed)
echo "[4] Checking nvidia-smi (NVIDIA System Management Interface)..."
if command -v nvidia-smi &> /dev/null; then
    echo "✓ nvidia-smi is available"
    echo "Running nvidia-smi:"
    nvidia-smi
else
    echo "✗ nvidia-smi not found (NVIDIA drivers may not be installed)"
fi
echo ""

# Check 5: Check installed NVIDIA packages
echo "[5] Checking installed NVIDIA packages..."
pacman -Qs nvidia
echo ""

# Check 6: Check Xorg configuration
echo "[6] Checking for Xorg NVIDIA configuration..."
if [ -f /etc/X11/xorg.conf ]; then
    echo "Found /etc/X11/xorg.conf"
    grep -i nvidia /etc/X11/xorg.conf
elif [ -d /etc/X11/xorg.conf.d/ ]; then
    echo "Checking /etc/X11/xorg.conf.d/ directory..."
    grep -r -i nvidia /etc/X11/xorg.conf.d/ 2>/dev/null || echo "No NVIDIA configuration found"
else
    echo "No Xorg configuration files found"
fi
echo ""

# Check 7: Check current graphics driver in use
echo "[7] Checking which graphics driver is currently in use..."
if command -v glxinfo &> /dev/null; then
    glxinfo | grep -i "opengl renderer"
else
    echo "glxinfo not available (install mesa-utils to use this check)"
fi
echo ""

echo "========================================"
echo "Detection Complete"
echo "========================================"
