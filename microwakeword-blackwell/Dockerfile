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
    # Python
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
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

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

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
RUN pip install --upgrade pip setuptools wheel

# Install TensorFlow with CUDA support
# Note: For Blackwell, first-run operations will JIT compile (~30s one-time delay)
RUN pip install tensorflow[and-cuda]==2.18.0

# Install microWakeWord dependencies
RUN pip install \
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
RUN pip install 'git+https://github.com/puddly/pymicro-features@puddly/minimum-cpp-version'
RUN pip install 'git+https://github.com/whatsnowplaying/audio-metadata@d4ebb238e6a401bb1a5aaaac60c9e2b3cb30929f'

# Install Jupyter for notebook interface
RUN pip install \
    jupyter \
    jupyterlab \
    ipywidgets \
    notebook

# Install microWakeWord from source
RUN git clone https://github.com/kahrendt/microWakeWord.git /opt/microWakeWord \
    && cd /opt/microWakeWord \
    && pip install -e .

# ==============================================================================
# Workspace Setup
# ==============================================================================
WORKDIR /data

# Copy startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

# Copy GPU test script
COPY test_gpu.py /test_gpu.py

# Expose Jupyter port
EXPOSE 8888

# ==============================================================================
# Entrypoint
# ==============================================================================
CMD ["/startup.sh"]
