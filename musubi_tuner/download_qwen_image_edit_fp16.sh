#!/usr/bin/env bash
set -euo pipefail

# QWEN Image Model Download Script using the Hugging Face CLI

echo "Starting QWEN Image model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders

echo "Downloading QWEN Image model..."
dit_path="$(
  hf download \
    Comfy-Org/Qwen-Image-Edit_ComfyUI \
    split_files/diffusion_models/qwen_image_edit_bf16.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_path" ./diffusion_models/qwen_image_edit_bf16.safetensors

echo "Downloading QWEN Image VAE..."
vae_path="$(
  hf download \
    Qwen/Qwen-Image \
    vae/diffusion_pytorch_model.safetensors \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/qwen_image_vae.safetensors

echo "Downloading QWEN 2.5 VL encoder..."
encoder_path="$(
  hf download \
    Comfy-Org/Qwen-Image_ComfyUI \
    split_files/text_encoders/qwen_2.5_vl_7b.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder_path" ./text_encoders/qwen_2.5_vl_7b.safetensors

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/qwen_image_edit_bf16.safetensors"
echo "  - vae/qwen_image_vae.safetensors"
echo "  - text_encoders/qwen_2.5_vl_7b.safetensors"
