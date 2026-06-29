#!/bin/bash

# HiDream-O1-Image Model Download Script
# Downloads the HiDream-O1 single checkpoint using aria2c.
# Tokenizer / processor assets are auto-downloaded by the training scripts from
# the official HiDream-ai repositories, so only the DiT checkpoint is needed here.

echo "Starting HiDream-O1-Image model download..."

# Create directory for organized storage
mkdir -p diffusion_models

# Download diffusion model (DiT) - single bf16 checkpoint
echo "Downloading HiDream-O1-Image DiT (bf16)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=hidream_o1_image_bf16.safetensors \
  "https://huggingface.co/Comfy-Org/HiDream-O1-Image/resolve/main/checkpoints/hidream_o1_image_bf16.safetensors"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/hidream_o1_image_bf16.safetensors"
echo ""
echo "Note: VAE and text encoders are loaded automatically from HiDream-ai/HiDream-O1-Image"
echo "      (use --model_type full) the first time you cache/train."
