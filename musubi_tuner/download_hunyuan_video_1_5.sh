#!/usr/bin/env bash
set -euo pipefail

# HunyuanVideo 1.5 Model Download Script using the Hugging Face CLI
# DiT (t2v + i2v) and VAE are the bf16 weights from the official tencent repo
# (the Comfy-Org repackage is fp16-only and not recommended for bf16 training).
# Text encoders + image encoder come from the Comfy-Org repackaged repo.

echo "Starting HunyuanVideo 1.5 model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders image_encoder

echo "Downloading HunyuanVideo 1.5 720p T2V DiT..."
dit_t2v_path="$(
  hf download \
    tencent/HunyuanVideo-1.5 \
    transformer/720p_t2v/diffusion_pytorch_model.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_t2v_path" ./diffusion_models/hunyuanvideo1.5_720p_t2v.safetensors

echo "Downloading HunyuanVideo 1.5 720p I2V DiT..."
dit_i2v_path="$(
  hf download \
    tencent/HunyuanVideo-1.5 \
    transformer/720p_i2v/diffusion_pytorch_model.safetensors \
    --quiet
)"
cp --reflink=auto "$dit_i2v_path" ./diffusion_models/hunyuanvideo1.5_720p_i2v.safetensors

echo "Downloading HunyuanVideo 1.5 VAE..."
vae_path="$(
  hf download \
    tencent/HunyuanVideo-1.5 \
    vae/diffusion_pytorch_model.safetensors \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/hunyuanvideo15_vae.safetensors

echo "Downloading Qwen2.5-VL 7B text encoder..."
encoder1_path="$(
  hf download \
    Comfy-Org/HunyuanVideo_1.5_repackaged \
    split_files/text_encoders/qwen_2.5_vl_7b.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder1_path" ./text_encoders/qwen_2.5_vl_7b.safetensors

echo "Downloading ByT5 small (glyph) text encoder..."
encoder2_path="$(
  hf download \
    Comfy-Org/HunyuanVideo_1.5_repackaged \
    split_files/text_encoders/byt5_small_glyphxl_fp16.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder2_path" ./text_encoders/byt5_small_glyphxl_fp16.safetensors

echo "Downloading SigLIP image encoder..."
image_encoder_path="$(
  hf download \
    Comfy-Org/HunyuanVideo_1.5_repackaged \
    split_files/clip_vision/sigclip_vision_patch14_384.safetensors \
    --quiet
)"
cp --reflink=auto "$image_encoder_path" ./image_encoder/sigclip_vision_patch14_384.safetensors

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/hunyuanvideo1.5_720p_t2v.safetensors"
echo "  - diffusion_models/hunyuanvideo1.5_720p_i2v.safetensors"
echo "  - vae/hunyuanvideo15_vae.safetensors"
echo "  - text_encoders/qwen_2.5_vl_7b.safetensors"
echo "  - text_encoders/byt5_small_glyphxl_fp16.safetensors"
echo "  - image_encoder/sigclip_vision_patch14_384.safetensors"
