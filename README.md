# Freya Home Assistant Setup

Complete Home Assistant setup for the Freya voice assistant project, including Docker configuration, Voice PE hardware integration, and custom wake word training.

## Overview

This repository contains everything you need to set up Home Assistant with voice assistant capabilities for the Freya project. The setup runs entirely in Docker on Windows and includes:

- **Home Assistant Core** - Central hub for automation and device management
- **Wyoming Protocol Services** - Speech-to-text (Whisper), text-to-speech (Piper), wake word detection (OpenWakeWord)
- **Ollama** - Local LLM inference for conversational AI
- **ChromaDB** - Vector database for semantic memory
- **Voice PE Device** - ESP32-based hardware for always-listening wake word detection
- **Custom Wake Word Training** - Train your own "Hey Freya" wake word using microWakeWord

## Quick Start

**New to Home Assistant?** Start here: [QUICKSTART_HOME_ASSISTANT.md](QUICKSTART_HOME_ASSISTANT.md)

**Experienced users?** Jump to: [HOME_ASSISTANT_SETUP.md](HOME_ASSISTANT_SETUP.md)

**Having issues?** Check: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## Documentation

### Setup Guides

- **[QUICKSTART_HOME_ASSISTANT.md](QUICKSTART_HOME_ASSISTANT.md)** - 30-minute quick start guide
- **[HOME_ASSISTANT_SETUP.md](HOME_ASSISTANT_SETUP.md)** - Complete setup and configuration guide
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Comprehensive troubleshooting guide

### Configuration Files

- **[docker-compose.homeassistant.yml](docker-compose.homeassistant.yml)** - Docker Compose template for all services
- **[voice-pe-config-template.yaml](voice-pe-config-template.yaml)** - ESPHome configuration template

### Reference

- **[DOCUMENTATION_SUMMARY.md](DOCUMENTATION_SUMMARY.md)** - Navigation guide and documentation overview

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Windows Host System                          │
│  Location: C:\AI_Projects\homeassistant\                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Docker Containers                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │ Home Assistant   │  │ Wyoming-Whisper  │  │ Wyoming-Piper │ │
│  │ Port: 8123       │  │ Port: 10300      │  │ Port: 10200   │ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
│           │                     │                     │          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │ OpenWakeWord     │  │ Ollama           │  │ ChromaDB      │ │
│  │ Port: 10400      │  │ Port: 11434      │  │ Port: 8000    │ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Voice PE Device (ESP32)                       │
│  Always-listening wake word detection with microWakeWord         │
└─────────────────────────────────────────────────────────────────┘
```

## Features

### Core Voice Assistant
- ✅ Speech-to-text with Wyoming-Whisper
- ✅ Text-to-speech with Wyoming-Piper
- ✅ Wake word detection with OpenWakeWord
- ✅ Conversational AI with Ollama LLMs
- ✅ Semantic memory with ChromaDB
- ✅ Home automation control via natural language

### Voice PE Integration
- ✅ Always-listening ESP32 hardware
- ✅ On-device wake word detection
- ✅ LED ring feedback
- ✅ ESPHome integration
- ✅ Custom wake word support

### Custom Wake Word Training
- ✅ Train "Hey Freya" or any custom phrase
- ✅ Docker-based training environment
- ✅ Synthetic voice sample generation
- ✅ Personal voice sample support
- ✅ microWakeWord format for ESP32

## Prerequisites

- Windows 10/11 with WSL2 enabled
- Docker Desktop installed and running
- 16GB+ RAM (12GB allocated to Docker)
- Voice PE device or compatible ESP32 hardware
- Basic command line knowledge

## Installation

### 1. Configure WSL2

Create `C:\Users\<YourUsername>\.wslconfig`:

```ini
[wsl2]
memory=12GB
processors=6
swap=4GB
```

Restart WSL2:
```powershell
wsl --shutdown
```

### 2. Setup Directory

```powershell
mkdir C:\AI_Projects\homeassistant
cd C:\AI_Projects\homeassistant
```

### 3. Download Configuration

Clone this repository or download the Docker Compose file:

```powershell
# Option 1: Clone repository
git clone https://github.com/MrPink1977/Home-Assistant.git
cd Home-Assistant

# Option 2: Download docker-compose.homeassistant.yml
# Copy to C:\AI_Projects\homeassistant\docker-compose.yml
```

### 4. Start Services

```powershell
docker-compose up -d
```

### 5. Configure Home Assistant

1. Open `http://localhost:8123`
2. Complete setup wizard
3. Add Wyoming integrations (Whisper, Piper, OpenWakeWord)
4. Add Home Agent integration (Ollama)
5. Create voice assistant "Freya"

**For detailed instructions, see [QUICKSTART_HOME_ASSISTANT.md](QUICKSTART_HOME_ASSISTANT.md)**

## Custom Wake Word Training

To train a custom "Hey Freya" wake word:

1. Navigate to training directory:
   ```powershell
   cd C:\AI_Projects\homeassistant\microwakeword_training
   ```

2. Start training container:
   ```powershell
   docker run --rm -it -p 8888:8888 -v ${PWD}:/data ghcr.io/tatertotterson/microwakeword:latest
   ```

3. Open Jupyter: `http://localhost:8888`

4. Configure training parameters:
   - `TARGET_WORD = "hey_freya"`
   - `MAX_SAMPLES = 10000`

5. Run training (1-4 hours)

6. Deploy model to Voice PE device

**For detailed instructions, see [HOME_ASSISTANT_SETUP.md](HOME_ASSISTANT_SETUP.md#custom-wake-word-training)**

## Integration with Freya Agent System

This Home Assistant setup provides the voice interface for the Freya agent system. The main Freya project includes:

- Advanced conversation with multi-turn dialog
- Memory management with ChromaDB
- Tool execution (time, calculator, files, web search)
- Model escalation (fast → reasoning models)
- Vision capabilities (facial recognition, camera integration)

**Main Freya Repository:** https://github.com/MrPink1977/freya_project

## Troubleshooting

Common issues and solutions:

- **Containers won't start** → Check Docker Desktop, verify WSL2 config
- **Can't access Home Assistant** → Check firewall, verify port 8123
- **Wake word not detected** → Adjust sensitivity, retrain model
- **Ollama not responding** → Check container logs, verify model loaded
- **Training crashes** → Reduce MAX_SAMPLES, increase WSL2 memory

**For complete troubleshooting guide, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

## Network Configuration

| Service | Host | Port | Protocol |
|---------|------|------|----------|
| Home Assistant | 192.168.0.50 | 8123 | HTTP |
| Wyoming Whisper | 192.168.0.50 | 10300 | Wyoming |
| Wyoming Piper | 192.168.0.50 | 10200 | Wyoming |
| OpenWakeWord | 192.168.0.50 | 10400 | Wyoming |
| Ollama | 192.168.0.50 | 11434 | HTTP |
| ChromaDB | 192.168.0.50 | 8000 | HTTP |

## Resources

### Official Documentation
- [Home Assistant](https://www.home-assistant.io/docs/)
- [ESPHome](https://esphome.io/)
- [Wyoming Protocol](https://github.com/rhasspy/wyoming)
- [Ollama](https://ollama.ai/docs)

### Community
- [Home Assistant Community](https://community.home-assistant.io/)
- [ESPHome Discord](https://discord.gg/KhAMKrd)
- [Ollama Discord](https://discord.gg/ollama)

### Training Resources
- [microWakeWord](https://github.com/kahrendt/microWakeWord)
- [Training Container](https://github.com/TaterTotterson/microWakeWord-Trainer-Nvidia-Docker)

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of the Freya voice assistant ecosystem.

## Support

For issues and questions:
- **GitHub Issues**: https://github.com/MrPink1977/Home-Assistant/issues
- **Main Project**: https://github.com/MrPink1977/freya_project

---

**Last Updated:** January 2026  
**Maintained By:** MrPink1977  
**Project:** Freya Voice AI Assistant
