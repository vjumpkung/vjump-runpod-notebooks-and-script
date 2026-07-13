#!/usr/bin/env bash
set -euo pipefail

# Z Image Turbo Model Download Script using the Hugging Face CLI

echo "Starting Z Image Turbo model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders

echo "Downloading Z Image Turbo model..."
dit_path="$(
  hf download \
    Comfy-Org/z_image \
    split_files/diffusion_models/z_image_bf16.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_path" ./diffusion_models/z_image_bf16.safetensors

echo "Downloading Z Image Turbo VAE..."
vae_path="$(
  hf download \
    Comfy-Org/z_image_turbo \
    split_files/vae/ae.safetensors \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/ae.safetensors

echo "Downloading QWEN 3 4B encoder..."
encoder_path="$(
  hf download \
    Comfy-Org/z_image_turbo \
    split_files/text_encoders/qwen_3_4b.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder_path" ./text_encoders/qwen_3_4b.safetensors

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/z_image_bf16.safetensors"
echo "  - vae/ae.safetensors"
echo "  - text_encoders/qwen_3_4b.safetensors"
