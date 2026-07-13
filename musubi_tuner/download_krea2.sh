#!/usr/bin/env bash
set -euo pipefail

# Krea 2 (RAW) Model Download Script using the Hugging Face CLI

echo "Starting Krea 2 model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders

echo "Downloading Krea 2 RAW DiT..."
hf download \
  krea/Krea-2-Raw \
  raw.safetensors \
  --local-dir ./diffusion_models

echo "Downloading Qwen-Image VAE..."
vae_path="$(
  hf download \
    Comfy-Org/Qwen-Image_ComfyUI \
    split_files/vae/qwen_image_vae.safetensors \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/qwen_image_vae.safetensors

echo "Downloading Qwen3-VL 4B text encoder..."
encoder_path="$(
  hf download \
    Comfy-Org/Qwen3-VL \
    text_encoders/qwen3vl_4b_bf16.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder_path" ./text_encoders/qwen3vl_4b_bf16.safetensors

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/raw.safetensors"
echo "  - vae/qwen_image_vae.safetensors"
echo "  - text_encoders/qwen3vl_4b_bf16.safetensors"
