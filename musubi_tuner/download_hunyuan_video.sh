#!/usr/bin/env bash
set -euo pipefail

# HunyuanVideo Model Download Script using the Hugging Face CLI
# DiT and VAE come from the official tencent repo (.pt); text encoders from the
# Comfy-Org repackaged repo (.safetensors).

echo "Starting HunyuanVideo model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders

echo "Downloading HunyuanVideo DiT (mp_rank_00_model_states.pt)..."
dit_path="$(
  hf download \
    tencent/HunyuanVideo \
    hunyuan-video-t2v-720p/transformers/mp_rank_00_model_states.pt \
    --quiet
)"
cp --reflink=auto "$dit_path" ./diffusion_models/mp_rank_00_model_states.pt

echo "Downloading HunyuanVideo VAE (pytorch_model.pt)..."
vae_path="$(
  hf download \
    tencent/HunyuanVideo \
    hunyuan-video-t2v-720p/vae/pytorch_model.pt \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/pytorch_model.pt

echo "Downloading LLaVA-LLaMA3 text encoder..."
encoder1_path="$(
  hf download \
    Comfy-Org/HunyuanVideo_repackaged \
    split_files/text_encoders/llava_llama3_fp16.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder1_path" ./text_encoders/llava_llama3_fp16.safetensors

echo "Downloading CLIP-L text encoder..."
encoder2_path="$(
  hf download \
    Comfy-Org/HunyuanVideo_repackaged \
    split_files/text_encoders/clip_l.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder2_path" ./text_encoders/clip_l.safetensors

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/mp_rank_00_model_states.pt"
echo "  - vae/pytorch_model.pt"
echo "  - text_encoders/llava_llama3_fp16.safetensors"
echo "  - text_encoders/clip_l.safetensors"
