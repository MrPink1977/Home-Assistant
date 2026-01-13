#!/bin/bash
# =============================================================================
# Deploy Custom Wake Word to HAVoice PE
# =============================================================================

set -e

# Configuration
WAKE_WORD="hey_freya"
MODEL_DIR="models/${WAKE_WORD}"
HA_WAKEWORDS_DIR="../config/custom_wakewords"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=============================================="
echo "  Deploy Wake Word: ${WAKE_WORD}"
echo "=============================================="

# Check if model files exist
if [ ! -f "${MODEL_DIR}/${WAKE_WORD}.tflite" ]; then
    echo -e "${RED}Error: Model file not found: ${MODEL_DIR}/${WAKE_WORD}.tflite${NC}"
    echo "Please run the training notebook first."
    exit 1
fi

if [ ! -f "${MODEL_DIR}/${WAKE_WORD}.json" ]; then
    echo -e "${RED}Error: Manifest file not found: ${MODEL_DIR}/${WAKE_WORD}.json${NC}"
    echo "Please run the training notebook first."
    exit 1
fi

# Create destination directory
echo -e "\n${GREEN}[1/4] Creating destination directory...${NC}"
mkdir -p "${HA_WAKEWORDS_DIR}"

# Copy model files
echo -e "\n${GREEN}[2/4] Copying model files...${NC}"
cp -v "${MODEL_DIR}/${WAKE_WORD}.tflite" "${HA_WAKEWORDS_DIR}/"
cp -v "${MODEL_DIR}/${WAKE_WORD}.json" "${HA_WAKEWORDS_DIR}/"

# Verify files
echo -e "\n${GREEN}[3/4] Verifying deployment...${NC}"
echo "Files in ${HA_WAKEWORDS_DIR}:"
ls -la "${HA_WAKEWORDS_DIR}/"

# Show ESPHome configuration
echo -e "\n${GREEN}[4/4] ESPHome Configuration Required${NC}"
echo ""
echo "Add the following to your Voice PE ESPHome configuration:"
echo ""
echo "-----------------------------------------------------------"
cat "${MODEL_DIR}/${WAKE_WORD}_esphome.yaml" 2>/dev/null || cat <<EOF
micro_wake_word:
  models:
    - model: /config/custom_wakewords/${WAKE_WORD}.json
      id: ${WAKE_WORD}
      probability_cutoff: 0.85
      sliding_window_size: 5
EOF
echo "-----------------------------------------------------------"
echo ""
echo -e "${GREEN}Deployment complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Update your Voice PE ESPHome configuration"
echo "  2. Flash the device: ESPHome Dashboard -> Install"
echo "  3. Select wake word in Home Assistant"
echo ""
