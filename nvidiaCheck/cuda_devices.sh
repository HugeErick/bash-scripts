#!/bin/bash

echo "========================================"
echo "TensorFlow GPU Detection & Fix"
echo "========================================"
echo ""

# Check if CUDA_VISIBLE_DEVICES is set
echo "[1] Checking CUDA_VISIBLE_DEVICES environment variable..."
if [ -n "$CUDA_VISIBLE_DEVICES" ]; then
    echo "⚠️  CUDA_VISIBLE_DEVICES is set to: '$CUDA_VISIBLE_DEVICES'"
    if [ "$CUDA_VISIBLE_DEVICES" = "-1" ]; then
        echo "❌ This is HIDING your GPU from TensorFlow!"
        echo ""
        echo "To fix temporarily (current session):"
        echo "  unset CUDA_VISIBLE_DEVICES"
        echo ""
        echo "To fix permanently, check these files:"
        echo "  ~/.bashrc"
        echo "  ~/.zshrc"
        echo "  ~/.profile"
        echo "  /etc/environment"
        echo ""
    fi
else
    echo "✓ CUDA_VISIBLE_DEVICES is not set (good)"
fi
echo ""

# Check CUDA installation
echo "[2] Checking CUDA toolkit installation..."
if command -v nvcc &> /dev/null; then
    echo "✓ CUDA toolkit found:"
    nvcc --version | grep "release"
else
    echo "⚠️  nvcc not found - CUDA toolkit may not be installed"
fi
echo ""

# Check for cuDNN
echo "[3] Checking for cuDNN libraries..."
if ldconfig -p | grep -q libcudnn; then
    echo "✓ cuDNN libraries found:"
    ldconfig -p | grep libcudnn | head -3
else
    echo "⚠️  cuDNN not found"
fi
echo ""

# Test Python GPU detection
echo "[4] Testing Python/TensorFlow GPU detection..."
echo "Running Python test..."
python3 << 'PYEOF'
import sys
import os

print("\n--- Python Environment Check ---")
print(f"Python: {sys.version}")

# Remove CUDA_VISIBLE_DEVICES if it's -1
if os.environ.get('CUDA_VISIBLE_DEVICES') == '-1':
    print("\n⚠️  Removing CUDA_VISIBLE_DEVICES=-1 for this test...")
    del os.environ['CUDA_VISIBLE_DEVICES']

try:
    import tensorflow as tf
    print(f"TensorFlow: {tf.__version__}")
    
    # Check GPU availability
    gpus = tf.config.list_physical_devices('GPU')
    print(f"\nGPUs detected by TensorFlow: {len(gpus)}")
    
    if gpus:
        print("✓ SUCCESS! GPU(s) found:")
        for gpu in gpus:
            print(f"  - {gpu}")
            # Get GPU details
            try:
                details = tf.config.experimental.get_device_details(gpu)
                if details:
                    print(f"    Compute Capability: {details.get('compute_capability', 'N/A')}")
            except:
                pass
    else:
        print("❌ No GPUs detected by TensorFlow")
        print("\nPossible issues:")
        print("  1. CUDA_VISIBLE_DEVICES is set to -1")
        print("  2. Missing CUDA libraries")
        print("  3. TensorFlow-CUDA version mismatch")
        
except ImportError as e:
    print(f"❌ Cannot import TensorFlow: {e}")
except Exception as e:
    print(f"❌ Error checking GPU: {e}")

# Check for CUDA libraries
print("\n--- CUDA Library Check ---")
try:
    import ctypes
    try:
        ctypes.CDLL('libcudart.so')
        print("✓ libcudart.so found")
    except:
        print("❌ libcudart.so not found")
    
    try:
        ctypes.CDLL('libcublas.so')
        print("✓ libcublas.so found")
    except:
        print("❌ libcublas.so not found")
        
except Exception as e:
    print(f"Error checking libraries: {e}")

PYEOF

echo ""
echo "========================================"
echo "RECOMMENDED FIXES"
echo "========================================"
echo ""
echo "If GPU was not detected:"
echo ""
echo "1. Remove CUDA_VISIBLE_DEVICES=-1:"
echo "   unset CUDA_VISIBLE_DEVICES"
echo ""
echo "2. Check/remove from config files:"
echo "   grep -r 'CUDA_VISIBLE_DEVICES' ~/.bashrc ~/.zshrc ~/.profile /etc/environment 2>/dev/null"
echo ""
echo "3. Install CUDA toolkit (if missing):"
echo "   sudo pacman -S cuda cuda-tools"
echo ""
echo "4. Install cuDNN (if missing):"
echo "   sudo pacman -S cudnn"
echo ""
echo "5. After installing CUDA/cuDNN, add to ~/.bashrc:"
echo "   export PATH=/opt/cuda/bin:\$PATH"
echo "   export LD_LIBRARY_PATH=/opt/cuda/lib64:\$LD_LIBRARY_PATH"
echo ""
echo "6. Reload shell config:"
echo "   source ~/.bashrc"
echo ""
