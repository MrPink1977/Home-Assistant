#!/bin/bash
# ==============================================================================
# Build Script for microWakeWord Blackwell Container
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="microwakeword-blackwell"
IMAGE_TAG="latest"

echo "=============================================="
echo " Building microWakeWord Blackwell Container"
echo "=============================================="
echo ""
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Context: ${SCRIPT_DIR}"
echo ""

# Check for NVIDIA Container Toolkit
if ! command -v nvidia-container-toolkit &> /dev/null && ! docker info 2>/dev/null | grep -q "nvidia"; then
    echo "WARNING: NVIDIA Container Toolkit may not be installed."
    echo "GPU support requires: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build the image
echo "Building Docker image (this may take 10-20 minutes)..."
echo ""

docker build \
    --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
    --file "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"

echo ""
echo "=============================================="
echo " Build Complete!"
echo "=============================================="
echo ""
echo "To run the container:"
echo "  ./run.sh"
echo ""
echo "Or manually:"
echo "  docker run --rm -it --gpus all -p 8888:8888 -v \$(pwd):/data ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
