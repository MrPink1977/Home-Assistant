# microWakeWord Training Container for RTX 50 Series (Blackwell)

Custom Docker container for training wake words on NVIDIA RTX 5090, 5080, 5070, and 5060 Ti GPUs.

## Why This Exists

The standard microWakeWord training container uses TensorFlow with CUDA 11.x/12.x, which doesn't have pre-compiled kernels for RTX 50 series GPUs (compute capability 12.0 / Blackwell architecture). This container provides:

- **CUDA 12.8** - Required for Blackwell support
- **TensorFlow 2.18+** - With Blackwell compatibility
- **JIT Compilation** - First-run operations compile PTX to native Blackwell code

## Supported GPUs

| GPU | Compute Capability | Status |
|-----|-------------------|--------|
| RTX 5090 | 12.0 | Supported |
| RTX 5080 | 12.0 | Supported |
| RTX 5070 Ti | 12.0 | Supported |
| RTX 5070 | 12.0 | Supported |
| RTX 5060 Ti | 12.0 | Supported |
| RTX 4090/4080/4070/4060 | 8.9 | Supported (backward compatible) |
| RTX 3090/3080/3070/3060 | 8.6 | Supported (backward compatible) |

## Prerequisites

### 1. NVIDIA Driver (570+)

```bash
# Check your driver version
nvidia-smi
# Should show Driver Version: 570.x or higher
```

If needed, update drivers:
- **Windows**: Download from [NVIDIA](https://www.nvidia.com/Download/index.aspx)
- **Linux**: `sudo apt install nvidia-driver-570`

### 2. Docker with NVIDIA Container Toolkit

```bash
# Install NVIDIA Container Toolkit (Linux)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

**Windows/WSL2**: Install Docker Desktop with WSL2 backend. GPU support is automatic with recent versions.

### 3. Verify GPU Access in Docker

```bash
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi
```

## Quick Start

### 1. Build the Container

```bash
cd microwakeword-blackwell
chmod +x *.sh
./build.sh
```

Build takes 10-20 minutes (downloads ~8GB).

### 2. Run Training

```bash
# Navigate to your training data directory
cd /path/to/your/training/data

# Run with GPU
/path/to/microwakeword-blackwell/run.sh

# Or run with CPU only (if GPU fails)
/path/to/microwakeword-blackwell/run-cpu.sh
```

### 3. Access Jupyter

Open http://localhost:8888 in your browser.

## First Run: JIT Compilation

**Important**: The first TensorFlow GPU operation will take ~30 seconds while CUDA compiles PTX code to native Blackwell instructions. This is a one-time delay per session.

You'll see messages like:
```
TensorFlow was not built with CUDA kernel binaries compatible with compute capability 12.0.
CUDA kernels will be jit-compiled from PTX...
```

This is **normal and expected**. After the initial compilation, GPU operations run at full speed.

## Directory Structure

When you run the container, mount your data directory:

```
your-training-directory/
├── generated_samples/     # Auto-created: synthetic TTS samples
├── personal_samples/      # Your voice recordings (optional)
│   ├── hey_freya_01.wav
│   ├── hey_freya_02.wav
│   └── ...
├── trained_models/        # Output: trained .tflite models
└── microWakeWord_training_notebook.ipynb  # Training notebook
```

## Training Parameters for RTX 50 Series

Recommended settings in your notebook:

```python
# These work well on RTX 5060 Ti (16GB VRAM)
MAX_SAMPLES = 30000      # Increase for better accuracy
BATCH_SIZE = 256         # Larger batches = faster training
EPOCHS = 100             # With early stopping
```

For 8GB VRAM GPUs:
```python
MAX_SAMPLES = 15000
BATCH_SIZE = 128
```

## Troubleshooting

### "CUDA_ERROR_INVALID_HANDLE" on First Run

This can happen if JIT compilation fails. Try:

1. Restart the container
2. Run a simple TensorFlow test first:
   ```python
   import tensorflow as tf
   print(tf.config.list_physical_devices('GPU'))
   ```

### Out of Memory (OOM)

Reduce batch size or samples:
```python
BATCH_SIZE = 128  # Down from 256
MAX_SAMPLES = 10000  # Down from 30000
```

### GPU Not Detected

1. Check NVIDIA driver: `nvidia-smi`
2. Check Docker GPU access: `docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi`
3. Verify NVIDIA Container Toolkit is installed

### Fallback to CPU

If GPU issues persist, use CPU mode:
```bash
./run-cpu.sh
```

Training takes 3-6 hours on CPU vs 1-2 hours on GPU.

## Manual Docker Commands

```bash
# Build
docker build -t microwakeword-blackwell:latest .

# Run with GPU
docker run --rm -it --gpus all -p 8888:8888 -v $(pwd):/data microwakeword-blackwell:latest

# Run CPU-only
docker run --rm -it -p 8888:8888 -v $(pwd):/data -e CUDA_VISIBLE_DEVICES="" microwakeword-blackwell:latest

# Interactive shell
docker run --rm -it --gpus all -v $(pwd):/data microwakeword-blackwell:latest /bin/bash
```

## References

- [microWakeWord](https://github.com/kahrendt/microWakeWord)
- [NVIDIA Blackwell Compatibility Guide](https://docs.nvidia.com/cuda/blackwell-compatibility-guide/)
- [TensorFlow RTX 5090 Issue](https://github.com/tensorflow/tensorflow/issues/89272)
- [dconsorte/pytorch-tensorflow-gpu](https://github.com/dconsorte/pytorch-tensorflow-gpu) - Base Blackwell TensorFlow work
