#!/usr/bin/env bash
set -euo pipefail

# FLUX.1 Kontext [dev] Model Download Script using the Hugging Face CLI
# Note: bf16 DiT is gated on black-forest-labs/FLUX.1-Kontext-dev. This script uses the
#       non-gated Comfy-Org repackaged fp8 DiT (train with --fp8_base --fp8_scaled).

echo "Starting FLUX.1 Kontext [dev] model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders

echo "Downloading FLUX.1 Kontext dev DiT (fp8 scaled)..."
dit_path="$(
  hf download \
    Comfy-Org/flux1-kontext-dev_ComfyUI \
    split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_path" ./diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors

echo "Downloading FLUX VAE (ae)..."
hf download \
  black-forest-labs/FLUX.1-schnell \
  ae.safetensors \
  --local-dir ./vae

echo "Downloading T5-XXL fp16 text encoder..."
hf download \
  comfyanonymous/flux_text_encoders \
  t5xxl_fp16.safetensors \
  --local-dir ./text_encoders

echo "Downloading CLIP-L text encoder..."
hf download \
  comfyanonymous/flux_text_encoders \
  clip_l.safetensors \
  --local-dir ./text_encoders

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors"
echo "  - vae/ae.safetensors"
echo "  - text_encoders/t5xxl_fp16.safetensors"
echo "  - text_encoders/clip_l.safetensors"
