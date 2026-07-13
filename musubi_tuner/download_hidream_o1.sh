#!/usr/bin/env bash
set -euo pipefail

# HiDream-O1-Image Model Download Script using the Hugging Face CLI
# Tokenizer / processor assets are auto-downloaded by the training scripts from
# the official HiDream-ai repositories, so only the DiT checkpoint is needed here.

echo "Starting HiDream-O1-Image model download..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models

echo "Downloading HiDream-O1-Image DiT (bf16)..."
dit_path="$(
  hf download \
    Comfy-Org/HiDream-O1-Image \
    checkpoints/hidream_o1_image_bf16.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_path" ./diffusion_models/hidream_o1_image_bf16.safetensors

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/hidream_o1_image_bf16.safetensors"
echo
echo "Note: VAE and text encoders are loaded automatically from HiDream-ai/HiDream-O1-Image"
echo "      (use --model_type full) the first time you cache/train."
