#!/usr/bin/env python3
"""
CPU-Optimized Training Configuration for microWakeWord
======================================================

Use this script to configure TensorFlow for optimal CPU training performance
when GPU is unavailable or incompatible (e.g., RTX 50 series Blackwell GPUs).

Run this BEFORE importing TensorFlow in your training notebook.
"""

import os
import multiprocessing

# ============================================================================
# STEP 1: Disable GPU completely (prevents CUDA initialization overhead)
# ============================================================================
os.environ['CUDA_VISIBLE_DEVICES'] = ''
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '1'  # Enable Intel oneDNN optimizations

# ============================================================================
# STEP 2: Configure CPU threading for optimal performance
# ============================================================================
NUM_PHYSICAL_CORES = multiprocessing.cpu_count()
# For hyperthreaded CPUs, use physical cores (usually half of cpu_count)
NUM_PHYSICAL_CORES_ESTIMATED = max(1, NUM_PHYSICAL_CORES // 2)

# Set threading environment variables BEFORE TensorFlow import
os.environ['OMP_NUM_THREADS'] = str(NUM_PHYSICAL_CORES_ESTIMATED)
os.environ['TF_NUM_INTRAOP_THREADS'] = str(NUM_PHYSICAL_CORES_ESTIMATED)
os.environ['TF_NUM_INTEROP_THREADS'] = '2'  # Usually 2 is optimal

# Intel MKL optimizations (if available)
os.environ['MKL_NUM_THREADS'] = str(NUM_PHYSICAL_CORES_ESTIMATED)
os.environ['KMP_AFFINITY'] = 'granularity=fine,verbose,compact,1,0'
os.environ['KMP_BLOCKTIME'] = '0'  # Release threads immediately

print(f"CPU Training Configuration:")
print(f"  - Physical cores (estimated): {NUM_PHYSICAL_CORES_ESTIMATED}")
print(f"  - OMP_NUM_THREADS: {os.environ['OMP_NUM_THREADS']}")
print(f"  - TF_NUM_INTRAOP_THREADS: {os.environ['TF_NUM_INTRAOP_THREADS']}")
print(f"  - TF_NUM_INTEROP_THREADS: {os.environ['TF_NUM_INTEROP_THREADS']}")
print(f"  - CUDA disabled: CUDA_VISIBLE_DEVICES='{os.environ['CUDA_VISIBLE_DEVICES']}'")

# ============================================================================
# STEP 3: Now import TensorFlow with optimized settings
# ============================================================================
import tensorflow as tf

# Configure TensorFlow threading
tf.config.threading.set_intra_op_parallelism_threads(NUM_PHYSICAL_CORES_ESTIMATED)
tf.config.threading.set_inter_op_parallelism_threads(2)

# Verify CPU-only mode
print(f"\nTensorFlow Configuration:")
print(f"  - Version: {tf.__version__}")
print(f"  - Intra-op parallelism: {tf.config.threading.get_intra_op_parallelism_threads()}")
print(f"  - Inter-op parallelism: {tf.config.threading.get_inter_op_parallelism_threads()}")
print(f"  - GPUs available: {len(tf.config.list_physical_devices('GPU'))}")
print(f"  - CPUs available: {len(tf.config.list_physical_devices('CPU'))}")

# ============================================================================
# OPTIMIZED TRAINING PARAMETERS FOR CPU
# ============================================================================

OPTIMIZED_PARAMS = {
    # Reduce samples for faster iteration (can increase after testing)
    'MAX_SAMPLES': 15000,  # Down from 50000, balance between speed and quality

    # Larger batch size is more CPU-efficient (better cache utilization)
    'BATCH_SIZE': 256,  # Increased from 100, test with 128, 256, or 512

    # Data pipeline optimization
    'PREFETCH_BUFFER': tf.data.AUTOTUNE,  # Let TF optimize prefetching
    'NUM_PARALLEL_CALLS': tf.data.AUTOTUNE,  # Parallelize data loading
    'SHUFFLE_BUFFER': 10000,  # Balance memory vs randomization

    # Training optimization
    'EPOCHS': 100,  # May need fewer with good convergence
    'EARLY_STOPPING_PATIENCE': 15,  # Stop if no improvement
    'REDUCE_LR_PATIENCE': 5,  # Reduce learning rate on plateau

    # Mixed precision NOT recommended for CPU (slower)
    'USE_MIXED_PRECISION': False,
}

print(f"\nOptimized Training Parameters:")
for key, value in OPTIMIZED_PARAMS.items():
    print(f"  - {key}: {value}")


def create_optimized_dataset(dataset, batch_size=256, training=True):
    """
    Apply CPU-optimized data pipeline transformations.

    Usage in notebook:
        train_ds = create_optimized_dataset(raw_train_dataset, batch_size=256, training=True)
    """
    if training:
        dataset = dataset.shuffle(buffer_size=OPTIMIZED_PARAMS['SHUFFLE_BUFFER'])

    dataset = dataset.batch(batch_size)
    dataset = dataset.prefetch(buffer_size=OPTIMIZED_PARAMS['PREFETCH_BUFFER'])

    return dataset


def get_callbacks(model_name='hey_freya'):
    """
    Return optimized callbacks for CPU training.
    """
    callbacks = [
        # Early stopping to avoid wasting CPU cycles
        tf.keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=OPTIMIZED_PARAMS['EARLY_STOPPING_PATIENCE'],
            restore_best_weights=True,
            verbose=1
        ),
        # Reduce learning rate on plateau
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=OPTIMIZED_PARAMS['REDUCE_LR_PATIENCE'],
            min_lr=1e-6,
            verbose=1
        ),
        # Checkpoint best model
        tf.keras.callbacks.ModelCheckpoint(
            filepath=f'{model_name}_best.keras',
            monitor='val_loss',
            save_best_only=True,
            verbose=1
        ),
    ]
    return callbacks


if __name__ == '__main__':
    print("\n" + "="*60)
    print("CPU TRAINING READY!")
    print("="*60)
    print("""
To use in your notebook, add this cell at the TOP (before any other imports):

    # Cell 1 - Run FIRST before anything else
    %run /data/cpu_training_optimization.py

    # Or copy the environment variables:
    import os
    os.environ['CUDA_VISIBLE_DEVICES'] = ''
    os.environ['TF_ENABLE_ONEDNN_OPTS'] = '1'
    os.environ['OMP_NUM_THREADS'] = '6'  # Adjust to your CPU cores
    os.environ['TF_NUM_INTRAOP_THREADS'] = '6'
    os.environ['TF_NUM_INTEROP_THREADS'] = '2'

Then modify your training parameters:
    - MAX_SAMPLES = 15000   (faster iteration, increase later)
    - BATCH_SIZE = 256      (more CPU-efficient)

Expected training time: 2-4 hours on modern 6-core CPU
""")
