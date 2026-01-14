#!/bin/bash
# ==============================================================================
# Run Script for microWakeWord Blackwell Container
# ==============================================================================

set -e

IMAGE_NAME="microwakeword-blackwell"
IMAGE_TAG="latest"
CONTAINER_NAME="microwakeword-training"

# Default to current directory for data volume
DATA_DIR="${1:-$(pwd)}"

echo "=============================================="
echo " microWakeWord Blackwell Training Container"
echo "=============================================="
echo ""
echo "Data directory: ${DATA_DIR}"
echo "Jupyter URL: http://localhost:8888"
echo ""

# Check if image exists
if ! docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" &> /dev/null; then
    echo "ERROR: Image ${IMAGE_NAME}:${IMAGE_TAG} not found."
    echo "Run ./build.sh first to build the container."
    exit 1
fi

# Stop existing container if running
if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
    echo "Stopping existing container..."
    docker stop "${CONTAINER_NAME}"
fi

# Remove existing container if exists
if docker ps -aq -f name="${CONTAINER_NAME}" | grep -q .; then
    docker rm "${CONTAINER_NAME}"
fi

# Create data directories if they don't exist
mkdir -p "${DATA_DIR}/generated_samples"
mkdir -p "${DATA_DIR}/personal_samples"
mkdir -p "${DATA_DIR}/trained_models"

echo "Starting container with GPU support..."
echo ""

# Run the container
docker run \
    --rm \
    -it \
    --gpus all \
    --name "${CONTAINER_NAME}" \
    -p 8888:8888 \
    -v "${DATA_DIR}:/data" \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    "${IMAGE_NAME}:${IMAGE_TAG}"
