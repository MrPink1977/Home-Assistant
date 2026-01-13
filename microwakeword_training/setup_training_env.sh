#!/bin/bash
# =============================================================================
# microWakeWord Training Environment Setup Script
# For HAVoice PE Custom Wake Word Training
# =============================================================================

set -e

echo "=============================================="
echo "  microWakeWord Training Environment Setup"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PYTHON_VERSION="3.10"
REPO_URL="https://github.com/FutureProofHomes/microWakeWord.git"
VENV_NAME="microwakeword_venv"

# Check if running in correct directory
if [ ! -f "../docker-compose.yml" ]; then
    echo -e "${YELLOW}Warning: Not running from microwakeword_training directory${NC}"
fi

# Function to check Python version
check_python() {
    echo -e "\n${GREEN}[1/6] Checking Python version...${NC}"

    if command -v python3.10 &> /dev/null; then
        PYTHON_CMD="python3.10"
        echo -e "  Found Python 3.10: $(python3.10 --version)"
    elif command -v python3 &> /dev/null; then
        PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
        if [ "$PY_VER" = "3.10" ]; then
            PYTHON_CMD="python3"
            echo -e "  Found Python 3.10: $(python3 --version)"
        else
            echo -e "${RED}Error: Python 3.10 required (found $PY_VER)${NC}"
            echo "  Install Python 3.10:"
            echo "    Ubuntu/Debian: sudo apt install python3.10 python3.10-venv python3.10-dev"
            echo "    macOS: brew install python@3.10"
            exit 1
        fi
    else
        echo -e "${RED}Error: Python 3.10 not found${NC}"
        exit 1
    fi
}

# Function to install system dependencies
install_deps() {
    echo -e "\n${GREEN}[2/6] Installing system dependencies...${NC}"

    if command -v apt &> /dev/null; then
        echo "  Detected Debian/Ubuntu system"
        sudo apt update
        sudo apt install -y ffmpeg libportaudio2 libsndfile1 cmake git
    elif command -v dnf &> /dev/null; then
        echo "  Detected Fedora system"
        sudo dnf install -y ffmpeg portaudio libsndfile cmake git
    elif command -v brew &> /dev/null; then
        echo "  Detected macOS system"
        brew install ffmpeg portaudio libsndfile cmake
    else
        echo -e "${YELLOW}  Warning: Could not detect package manager${NC}"
        echo "  Please manually install: ffmpeg, portaudio, libsndfile, cmake"
    fi
}

# Function to create virtual environment
create_venv() {
    echo -e "\n${GREEN}[3/6] Creating virtual environment...${NC}"

    if [ -d "$VENV_NAME" ]; then
        echo -e "${YELLOW}  Virtual environment already exists. Removing...${NC}"
        rm -rf "$VENV_NAME"
    fi

    $PYTHON_CMD -m venv "$VENV_NAME"
    source "$VENV_NAME/bin/activate"

    echo "  Upgrading pip..."
    pip install --upgrade pip wheel setuptools
}

# Function to clone microWakeWord repository
clone_repo() {
    echo -e "\n${GREEN}[4/6] Cloning microWakeWord repository...${NC}"

    if [ -d "microWakeWord" ]; then
        echo "  Repository already exists. Updating..."
        cd microWakeWord
        git pull
        cd ..
    else
        git clone "$REPO_URL"
    fi
}

# Function to install Python dependencies
install_python_deps() {
    echo -e "\n${GREEN}[5/6] Installing Python dependencies...${NC}"

    cd microWakeWord

    # Install the package in editable mode
    pip install -e .

    # Install Jupyter
    pip install jupyter jupyterlab

    # Install additional dependencies for training
    pip install tensorflow==2.15.0
    pip install tflite-runtime || true  # May not be available on all platforms

    cd ..
}

# Function to setup notebooks
setup_notebooks() {
    echo -e "\n${GREEN}[6/6] Setting up notebooks...${NC}"

    # Copy notebooks to our notebooks directory for easier access
    if [ -d "microWakeWord/notebooks" ]; then
        cp -r microWakeWord/notebooks/* notebooks/
        echo "  Notebooks copied to ./notebooks/"
    else
        # Create a custom training notebook
        echo "  Creating custom training notebook..."
    fi

    # Create a symbolic link to the data directory
    if [ ! -L "microWakeWord/data" ]; then
        mkdir -p samples
        ln -sf "$(pwd)/samples" microWakeWord/data 2>/dev/null || true
    fi
}

# Main execution
main() {
    echo ""
    echo "This script will set up the microWakeWord training environment"
    echo "for creating custom wake words for your HAVoice PE device."
    echo ""

    check_python
    install_deps
    create_venv
    clone_repo
    install_python_deps
    setup_notebooks

    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Setup Complete!"
    echo "==============================================${NC}"
    echo ""
    echo "To start training:"
    echo ""
    echo "  1. Activate the virtual environment:"
    echo "     source $VENV_NAME/bin/activate"
    echo ""
    echo "  2. Start Jupyter Notebook:"
    echo "     jupyter notebook"
    echo ""
    echo "  3. Open one of these notebooks:"
    echo "     - easy_training_notebook.ipynb (recommended for beginners)"
    echo "     - basic_training_notebook.ipynb (advanced users)"
    echo ""
    echo "  4. Follow the notebook instructions to train your wake word"
    echo ""
    echo "For more details, see: CUSTOM_WAKE_WORD_TRAINING.md"
    echo ""
}

main "$@"
