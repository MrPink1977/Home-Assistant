#!/usr/bin/env python3
"""
GPU Test Script for microWakeWord Blackwell Container
Tests TensorFlow GPU availability and performs a simple computation.
"""

import os
import sys

# Suppress TensorFlow info messages (keep warnings/errors)
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '1'

def test_gpu():
    """Test GPU availability and perform basic computation."""

    print("-" * 50)

    try:
        import tensorflow as tf
        print(f"TensorFlow version: {tf.__version__}")
    except ImportError:
        print("ERROR: TensorFlow not installed!")
        return False

    # List physical devices
    gpus = tf.config.list_physical_devices('GPU')
    cpus = tf.config.list_physical_devices('CPU')

    print(f"CPUs detected: {len(cpus)}")
    print(f"GPUs detected: {len(gpus)}")

    if gpus:
        for i, gpu in enumerate(gpus):
            print(f"  GPU {i}: {gpu.name}")

        # Enable memory growth to avoid OOM
        for gpu in gpus:
            try:
                tf.config.experimental.set_memory_growth(gpu, True)
                print(f"  Memory growth enabled for {gpu.name}")
            except RuntimeError as e:
                print(f"  Warning: Could not set memory growth: {e}")

        # Test GPU computation
        print("\nTesting GPU computation...")
        print("(First run may take ~30s for Blackwell JIT compilation)")

        try:
            with tf.device('/GPU:0'):
                # Simple matrix multiplication test
                a = tf.random.normal([1000, 1000])
                b = tf.random.normal([1000, 1000])
                c = tf.matmul(a, b)
                # Force execution
                _ = c.numpy()

            print("GPU computation: SUCCESS")
            print("-" * 50)
            return True

        except Exception as e:
            print(f"GPU computation FAILED: {e}")
            print("\nFalling back to CPU mode...")
            print("Training will work but be slower.")
            print("-" * 50)
            return False
    else:
        print("\nNo GPU detected. Running in CPU-only mode.")
        print("Training will work but be slower (3-6 hours vs 1-2 hours).")
        print("-" * 50)
        return False


def print_system_info():
    """Print system information for debugging."""

    print("\nSystem Information:")
    print("-" * 50)

    # CUDA environment
    cuda_home = os.environ.get('CUDA_HOME', 'Not set')
    print(f"CUDA_HOME: {cuda_home}")

    cuda_visible = os.environ.get('CUDA_VISIBLE_DEVICES', 'Not set (all GPUs visible)')
    print(f"CUDA_VISIBLE_DEVICES: {cuda_visible}")

    # Check for common issues
    ld_library_path = os.environ.get('LD_LIBRARY_PATH', '')
    if '/usr/local/cuda' in ld_library_path:
        print("LD_LIBRARY_PATH: Contains CUDA paths (good)")
    else:
        print("LD_LIBRARY_PATH: Missing CUDA paths (may cause issues)")

    print("-" * 50)


if __name__ == '__main__':
    print_system_info()
    success = test_gpu()
    sys.exit(0 if success else 1)
