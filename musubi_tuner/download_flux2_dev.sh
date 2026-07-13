#!/usr/bin/env bash
set -euo pipefail

# FLUX.2 [dev] Model Download Script using the Hugging Face CLI
# Note: bf16 DiT is gated on black-forest-labs/FLUX.2-dev. This script uses the
#       non-gated Comfy-Org repackaged fp8 DiT (train with --fp8_base --fp8_scaled).

echo "Starting FLUX.2 [dev] model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders

echo "Downloading FLUX.2 dev DiT (fp8 mixed)..."
dit_path="$(
  hf download \
    Comfy-Org/flux2-dev \
    split_files/diffusion_models/flux2_dev_fp8mixed.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_path" ./diffusion_models/flux2_dev_fp8mixed.safetensors

echo "Downloading FLUX.2 VAE..."
vae_path="$(
  hf download \
    Comfy-Org/flux2-dev \
    split_files/vae/flux2-vae.safetensors \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/flux2-vae.safetensors

echo "Downloading Mistral 3 Small text encoder..."
encoder_path="$(
  hf download \
    Comfy-Org/flux2-dev \
    split_files/text_encoders/mistral_3_small_flux2_bf16.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder_path" ./text_encoders/mistral_3_small_flux2_bf16.safetensors

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/flux2_dev_fp8mixed.safetensors"
echo "  - vae/flux2-vae.safetensors"
echo "  - text_encoders/mistral_3_small_flux2_bf16.safetensors"
