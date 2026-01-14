# ==============================================================================
# microWakeWord Training Container for NVIDIA Blackwell GPUs (RTX 50 Series)
# ==============================================================================
# Supports: RTX 5090, 5080, 5070, 5060 Ti (compute capability 12.0)
# Also works with: RTX 40/30 series (backward compatible)
#
# Based on: NVIDIA Optimized TensorFlow 25.02 (official Blackwell support)
# ==============================================================================

FROM nvcr.io/nvidia/tensorflow:25.02-tf2-py3

LABEL maintainer="Home Assistant microWakeWord Training"
LABEL description="Blackwell GPU compatible microWakeWord training environment"
LABEL tensorflow_version="NVIDIA Optimized 25.02"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ==============================================================================
# System Dependencies (some already in NVIDIA container)
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Audio processing
    ffmpeg \
    libportaudio2 \
    portaudio19-dev \
    libsndfile1 \
    libsndfile1-dev \
    # Utilities
    vim \
    htop \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# ==============================================================================
# CUDA Environment Variables for Blackwell
# ==============================================================================
# Increase PTX JIT cache to 4GB to prevent recompilation issues
ENV CUDA_CACHE_MAXSIZE=4294967296
ENV TF_FORCE_GPU_ALLOW_GROWTH=true
ENV TF_GPU_ALLOCATOR=cuda_malloc_async

# ==============================================================================
# Python Dependencies (TensorFlow already installed in NVIDIA container)
# ==============================================================================

# Install microWakeWord dependencies (NVIDIA container uses virtualenv, no --break-system-packages needed)
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
