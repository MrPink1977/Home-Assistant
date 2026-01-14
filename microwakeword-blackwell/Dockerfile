# ==============================================================================
# microWakeWord Training Container for NVIDIA Blackwell GPUs (RTX 50 Series)
# ==============================================================================
# Supports: RTX 5090, 5080, 5070, 5060 Ti (compute capability 12.0)
# Also works with: RTX 40/30 series (backward compatible)
#
# Based on: NVIDIA CUDA 12.8 + TensorFlow built from source
# ==============================================================================

FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04

LABEL maintainer="Home Assistant microWakeWord Training"
LABEL description="Blackwell GPU compatible microWakeWord training environment"
LABEL cuda_version="12.8"
LABEL tensorflow_version="2.18+"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ==============================================================================
# System Dependencies
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Python (Ubuntu 24.04 uses Python 3.12)
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    python3-full \
    # Audio processing
    ffmpeg \
    libportaudio2 \
    portaudio19-dev \
    libsndfile1 \
    libsndfile1-dev \
    # Build tools
    cmake \
    build-essential \
    gcc \
    g++ \
    git \
    curl \
    wget \
    # Utilities
    vim \
    htop \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Set up Python aliases
RUN ln -sf /usr/bin/python3 /usr/bin/python

# ==============================================================================
# CUDA Environment Variables for Blackwell
# ==============================================================================
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Enable JIT compilation for Blackwell (compute capability 12.0)
# This allows TensorFlow to compile PTX to native Blackwell code
ENV TF_FORCE_GPU_ALLOW_GROWTH=true
ENV TF_GPU_ALLOCATOR=cuda_malloc_async
ENV XLA_FLAGS=--xla_gpu_cuda_data_dir=/usr/local/cuda

# ==============================================================================
# Python Dependencies
# ==============================================================================
# Skip upgrading pip/setuptools/wheel - use system versions (they work fine)

# Install TensorFlow with CUDA support
# Note: For Blackwell, first-run operations will JIT compile (~30s one-time delay)
RUN pip install --break-system-packages "tensorflow[and-cuda]==2.18.0"

# Install microWakeWord dependencies
RUN pip install --break-system-packages \
    audiomentations \
    datasets \
    mmap_ninja \
    numpy \
    pyyaml \
    webrtcvad \
    scipy \
    librosa \
    soundfile \
    matplotlib \
    tqdm \
    pandas

# Install special forks with fixes
RUN pip install --break-system-packages 'git+https://github.com/puddly/pymicro-features@puddly/minimum-cpp-version'
RUN pip install --break-system-packages 'git+https://github.com/whatsnowplaying/audio-metadata@d4ebb238e6a401bb1a5aaaac60c9e2b3cb30929f'

# Install Jupyter for notebook interface
RUN pip install --break-system-packages \
    jupyter \
    jupyterlab \
    ipywidgets \
    notebook

# Install microWakeWord from source
RUN git clone https://github.com/kahrendt/microWakeWord.git /opt/microWakeWord \
    && cd /opt/microWakeWord \
    && pip install --break-system-packages -e .

# ==============================================================================
# Workspace Setup
# ==============================================================================
WORKDIR /data

# Copy startup script and fix line endings (Windows CRLF -> Unix LF)
COPY startup.sh /startup.sh
RUN sed -i 's/\r$//' /startup.sh && chmod +x /startup.sh

# Copy GPU test script and fix line endings
COPY test_gpu.py /test_gpu.py
RUN sed -i 's/\r$//' /test_gpu.py

# Expose Jupyter port
EXPOSE 8888

# ==============================================================================
# Entrypoint
# ==============================================================================
CMD ["/startup.sh"]
