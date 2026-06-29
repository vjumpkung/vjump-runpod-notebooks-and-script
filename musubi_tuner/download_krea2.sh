#!/bin/bash

# Krea 2 (RAW) Model Download Script
# Downloads Krea 2 RAW DiT, the Qwen-Image VAE, and the Qwen3-VL 4B text encoder.
# The text encoder is only needed when generating sample images during training.

echo "Starting Krea 2 model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae
mkdir -p text_encoders

# Download diffusion model (DiT - Krea 2 RAW)
echo "Downloading Krea 2 RAW DiT..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=raw.safetensors \
  "https://huggingface.co/krea/Krea-2-Raw/resolve/main/raw.safetensors"

# Download VAE model (Qwen-Image VAE)
echo "Downloading Qwen-Image VAE..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./vae \
  --out=qwen_image_vae.safetensors \
  "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors"

# Download Qwen3-VL 4B text encoder (for sampling during training)
echo "Downloading Qwen3-VL 4B text encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=qwen3vl_4b_bf16.safetensors \
  "https://huggingface.co/Comfy-Org/Qwen3-VL/resolve/main/text_encoders/qwen3vl_4b_bf16.safetensors"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/raw.safetensors"
echo "  - vae/qwen_image_vae.safetensors"
echo "  - text_encoders/qwen3vl_4b_bf16.safetensors"
