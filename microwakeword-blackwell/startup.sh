#!/bin/bash
# ==============================================================================
# microWakeWord Blackwell Container Startup Script
# ==============================================================================

echo "=============================================="
echo " microWakeWord Training Environment"
echo " Blackwell GPU Compatible (RTX 50 Series)"
echo "=============================================="

# Check for NVIDIA GPU
echo ""
echo "Checking GPU availability..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,compute_cap,memory.total --format=csv,noheader
    GPU_DETECTED=true
else
    echo "WARNING: nvidia-smi not found. Running in CPU-only mode."
    GPU_DETECTED=false
fi

# Test TensorFlow GPU access (don't exit on failure)
echo ""
echo "Testing TensorFlow GPU access..."
python3 /test_gpu.py || echo "GPU test completed (see above for results)"

# Copy training notebook if not present
if [ ! -f /data/microWakeWord_training_notebook.ipynb ]; then
    echo ""
    echo "Copying training notebook to /data..."
    cp /opt/microWakeWord/notebooks/basic_training_notebook.ipynb /data/microWakeWord_training_notebook.ipynb 2>/dev/null || \
    echo "Note: No default notebook found. Please provide your own."
fi

# Create sample directories
mkdir -p /data/generated_samples
mkdir -p /data/personal_samples
mkdir -p /data/trained_models

echo ""
echo "=============================================="
echo " Starting Jupyter Lab"
echo " Access at: http://localhost:8888"
echo "=============================================="
echo ""
echo "IMPORTANT: First TensorFlow GPU operation may take ~30 seconds"
echo "           (one-time PTX to Blackwell native code compilation)"
echo ""

# Start Jupyter Lab
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password='' \
    --notebook-dir=/data
