#!/bin/bash

# Z Image Turbo Model Download Script
# Downloads Z Image Turbo ComfyUI models using aria2c

echo "Starting Z Image Turbo model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae
mkdir -p text_encoders

# Download diffusion model
echo "Downloading Z Image Turbo model..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=z_image_turbo_bf16.safetensors \
  "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors"

# Download VAE model
echo "Downloading Z Image Turbo VAE..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./vae \
  --out=ae.safetensors \
  "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"

# Download QWEN text encoder
echo "Downloading QWEN 3 4B encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=qwen_3_4b.safetensors \
  "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/z_image_turbo_bf16.safetensors"
echo "  - vae/ae.safetensors"
echo "  - text_encoders/qwen_3_4b.safetensors"