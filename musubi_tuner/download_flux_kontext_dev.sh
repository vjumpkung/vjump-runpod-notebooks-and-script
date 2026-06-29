#!/bin/bash

# FLUX.1 Kontext [dev] Model Download Script
# Downloads FLUX.1 Kontext dev models using aria2c
# Note: bf16 DiT is gated on black-forest-labs/FLUX.1-Kontext-dev. This script uses the
#       non-gated Comfy-Org repackaged fp8 DiT (train with --fp8_base --fp8_scaled).

echo "Starting FLUX.1 Kontext [dev] model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae
mkdir -p text_encoders

# Download diffusion model (DiT)
echo "Downloading FLUX.1 Kontext dev DiT (fp8 scaled)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=flux1-dev-kontext_fp8_scaled.safetensors \
  "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors"

# Download VAE model (FLUX ae, from the non-gated FLUX.1-schnell repo)
echo "Downloading FLUX VAE (ae)..."
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
  "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors"

# Download T5-XXL text encoder (text_encoder1)
echo "Downloading T5-XXL fp16 text encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=t5xxl_fp16.safetensors \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"

# Download CLIP-L text encoder (text_encoder2)
echo "Downloading CLIP-L text encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=clip_l.safetensors \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors"
echo "  - vae/ae.safetensors"
echo "  - text_encoders/t5xxl_fp16.safetensors"
echo "  - text_encoders/clip_l.safetensors"
