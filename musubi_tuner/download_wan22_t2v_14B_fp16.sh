#!/usr/bin/env bash
set -euo pipefail

# Wan 2.2 Model Download Script using the Hugging Face CLI

echo "Starting Wan 2.2 T2V model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders

echo "Downloading Wan 2.2 T2V Low 14B model..."
dit_low_path="$(
  hf download \
    Comfy-Org/Wan_2.2_ComfyUI_Repackaged \
    split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_low_path" ./diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors

echo "Downloading Wan 2.2 T2V High 14B model..."
dit_high_path="$(
  hf download \
    Comfy-Org/Wan_2.2_ComfyUI_Repackaged \
    split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_high_path" ./diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors

echo "Downloading Wan 2.1 VAE..."
vae_path="$(
  hf download \
    Comfy-Org/Wan_2.1_ComfyUI_repackaged \
    split_files/vae/wan_2.1_vae.safetensors \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/wan_2.1_vae.safetensors

echo "Downloading T5 UMT5-XXL encoder..."
hf download \
  Wan-AI/Wan2.1-I2V-14B-480P \
  models_t5_umt5-xxl-enc-bf16.pth \
  --local-dir ./text_encoders

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors"
echo "  - diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors"
echo "  - vae/wan_2.1_vae.safetensors"
echo "  - text_encoders/models_t5_umt5-xxl-enc-bf16.pth"
