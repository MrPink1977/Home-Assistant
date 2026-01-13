# microWakeWord Training for HAVoice PE

Train custom wake words for your Home Assistant Voice PE device.

## Wake Word: "Hey Freya"

- **Display Name:** Hey Freya
- **Phonetic:** "hey fray uh" (3 syllables)

## Quick Start

### Option 1: Docker (Recommended)

```bash
# Start training environment
docker-compose up

# Open in browser
# http://localhost:8888
# Token: microwakeword
```

### Option 2: Local Installation

```bash
# Run setup script
chmod +x setup_training_env.sh
./setup_training_env.sh

# Start Jupyter
source microwakeword_venv/bin/activate
jupyter notebook
```

## Training Steps

1. **Record personal samples** (optional but recommended)
   - Place WAV files in `samples/personal/`
   - Name them: `hey_freya_01.wav`, `hey_freya_02.wav`, etc.

2. **Open Jupyter Notebook**
   - Navigate to `notebooks/easy_training_notebook.ipynb`

3. **Configure and train**
   - Set your wake word settings in the first cell
   - Run all cells

4. **Deploy to Voice PE**
   ```bash
   chmod +x deploy_wake_word.sh
   ./deploy_wake_word.sh
   ```

## Directory Structure

```
microwakeword_training/
├── config/
│   └── training_config.yaml    # Training settings
├── samples/
│   ├── personal/               # Your voice recordings
│   └── synthetic/              # Generated samples
├── models/
│   └── hey_freya/             # Trained model output
├── notebooks/
│   └── easy_training_notebook.ipynb
├── docker-compose.yaml         # Docker training environment
├── setup_training_env.sh       # Local setup script
└── deploy_wake_word.sh         # Deployment script
```

## Tips for "Hey Freya"

- Pronounce as "hey FRAY-uh" (emphasis on FRAY)
- Record 20-30 personal samples for best results
- Include variations: whisper, normal, loud
- Record from different distances

## Resources

- [CUSTOM_WAKE_WORD_TRAINING.md](../CUSTOM_WAKE_WORD_TRAINING.md) - Full training guide
- [microWakeWord GitHub](https://github.com/FutureProofHomes/microWakeWord)
- [ESPHome Micro Wake Word](https://esphome.io/components/micro_wake_word/)
