#!/bin/bash

# Ideogram 4 Model Download Script
# Downloads Ideogram 4 ComfyUI models using aria2c.
# Ideogram 4 ships fp8 weights only (fp8 is the mandatory operating mode).
# The Qwen3-VL tokenizer is auto-downloaded from Qwen/Qwen3-VL-8B-Instruct at runtime.

echo "Starting Ideogram 4 model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae
mkdir -p text_encoders

# Download diffusion model (DiT, fp8 scaled - conditional transformer)
echo "Downloading Ideogram 4 DiT (fp8 scaled)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=ideogram4_fp8_scaled.safetensors \
  "https://huggingface.co/Comfy-Org/Ideogram-4/resolve/main/diffusion_models/ideogram4_fp8_scaled.safetensors"

# Download VAE model (Flux2 KL-VAE)
echo "Downloading Ideogram 4 VAE (flux2-vae)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./vae \
  --out=flux2-vae.safetensors \
  "https://huggingface.co/Comfy-Org/Ideogram-4/resolve/main/vae/flux2-vae.safetensors"

# Download Qwen3-VL 8B text encoder (fp8 scaled)
echo "Downloading Qwen3-VL 8B text encoder (fp8 scaled)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=qwen3vl_8b_fp8_scaled.safetensors \
  "https://huggingface.co/Comfy-Org/Ideogram-4/resolve/main/text_encoders/qwen3vl_8b_fp8_scaled.safetensors"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/ideogram4_fp8_scaled.safetensors"
echo "  - vae/flux2-vae.safetensors"
echo "  - text_encoders/qwen3vl_8b_fp8_scaled.safetensors"
