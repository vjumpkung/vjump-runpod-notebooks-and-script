#!/usr/bin/env bash
set -euo pipefail

# Ideogram 4 Model Download Script using the Hugging Face CLI
# Ideogram 4 ships fp8 weights only (fp8 is the mandatory operating mode).
# The Qwen3-VL tokenizer is auto-downloaded from Qwen/Qwen3-VL-8B-Instruct at runtime.

echo "Starting Ideogram 4 model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders

echo "Downloading Ideogram 4 DiT (fp8 scaled)..."
dit_path="$(
  hf download \
    Comfy-Org/Ideogram-4 \
    diffusion_models/ideogram4_fp8_scaled.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_path" ./diffusion_models/ideogram4_fp8_scaled.safetensors

echo "Downloading Ideogram 4 VAE (flux2-vae)..."
vae_path="$(
  hf download \
    Comfy-Org/Ideogram-4 \
    vae/flux2-vae.safetensors \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/flux2-vae.safetensors

echo "Downloading Qwen3-VL 8B text encoder (fp8 scaled)..."
encoder_path="$(
  hf download \
    Comfy-Org/Ideogram-4 \
    text_encoders/qwen3vl_8b_fp8_scaled.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder_path" ./text_encoders/qwen3vl_8b_fp8_scaled.safetensors

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/ideogram4_fp8_scaled.safetensors"
echo "  - vae/flux2-vae.safetensors"
echo "  - text_encoders/qwen3vl_8b_fp8_scaled.safetensors"
