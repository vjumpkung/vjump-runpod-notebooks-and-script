#!/bin/bash

# Wan 2.1 Model Download Script
# Downloads Wan 2.1 ComfyUI models using aria2c

echo "Starting Wan 2.2 model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae
mkdir -p text_encoders

# Download diffusion model (main T2V model)
echo "Downloading Wan 2.2 T2V Low 14B model..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=wan2.2_t2v_low_noise_14B_fp16.safetensors \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors?download=true"
  
# Download diffusion model (main T2V model)
echo "Downloading Wan 2.2 T2V High 14B model..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=wan2.2_t2v_high_noise_14B_fp16.safetensors \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors?download=true"
  
# Download VAE model
echo "Downloading Wan 2.1 VAE..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./vae \
  --out=wan_2.1_vae.safetensors \
  "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

# Download T5 text encoder
echo "Downloading T5 UMT5-XXL encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=models_t5_umt5-xxl-enc-bf16.pth \
  "https://huggingface.co/Wan-AI/Wan2.1-I2V-14B-480P/resolve/main/models_t5_umt5-xxl-enc-bf16.pth"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors"
echo "  - diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors"
echo "  - vae/wan_2.1_vae.safetensors"
echo "  - text_encoders/models_t5_umt5-xxl-enc-bf16.pth"