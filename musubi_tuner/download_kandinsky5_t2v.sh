#!/usr/bin/env bash
set -euo pipefail

# Kandinsky 5 (T2V Pro 5s) Model Download Script using the Hugging Face CLI
# The text encoders (Qwen2.5-VL-7B-Instruct and CLIP ViT-L/14) are passed to the
# training scripts as HuggingFace model IDs and are auto-downloaded at runtime,
# so they are NOT fetched here.

echo "Starting Kandinsky 5 T2V model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae

echo "Downloading Kandinsky 5 Pro T2V SFT 5s DiT..."
dit_path="$(
  hf download \
    kandinskylab/Kandinsky-5.0-T2V-Pro-sft-5s \
    model/kandinsky5pro_t2v_sft_5s.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_path" ./diffusion_models/kandinsky5pro_t2v_sft_5s.safetensors

echo "Downloading HunyuanVideo VAE..."
vae_path="$(
  hf download \
    hunyuanvideo-community/HunyuanVideo \
    vae/diffusion_pytorch_model.safetensors \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/hunyuan_video_vae.safetensors

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/kandinsky5pro_t2v_sft_5s.safetensors"
echo "  - vae/hunyuan_video_vae.safetensors"
echo
echo "Note: text encoders are passed as HF model IDs to the training script:"
echo "      --text_encoder_qwen Qwen/Qwen2.5-VL-7B-Instruct"
echo "      --text_encoder_clip openai/clip-vit-large-patch14"
echo "      They download automatically on first use."
