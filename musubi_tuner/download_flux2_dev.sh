#!/bin/bash

# FLUX.2 [dev] Model Download Script
# Downloads FLUX.2 dev ComfyUI repackaged models using aria2c
# Note: bf16 DiT is gated on black-forest-labs/FLUX.2-dev. This script uses the
#       non-gated Comfy-Org repackaged fp8 DiT (train with --fp8_base --fp8_scaled).

echo "Starting FLUX.2 [dev] model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae
mkdir -p text_encoders

# Download diffusion model (DiT)
echo "Downloading FLUX.2 dev DiT (fp8 mixed)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=flux2_dev_fp8mixed.safetensors \
  "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/diffusion_models/flux2_dev_fp8mixed.safetensors"

# Download VAE model
echo "Downloading FLUX.2 VAE..."
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
  "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors"

# Download Mistral 3 text encoder
echo "Downloading Mistral 3 Small text encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=mistral_3_small_flux2_bf16.safetensors \
  "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/text_encoders/mistral_3_small_flux2_bf16.safetensors"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/flux2_dev_fp8mixed.safetensors"
echo "  - vae/flux2-vae.safetensors"
echo "  - text_encoders/mistral_3_small_flux2_bf16.safetensors"
