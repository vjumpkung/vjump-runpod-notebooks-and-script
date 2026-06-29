#!/bin/bash

# HunyuanVideo 1.5 Model Download Script
# Downloads HunyuanVideo 1.5 models using aria2c.
# DiT (t2v + i2v) and VAE are the bf16 weights from the official tencent repo
# (the Comfy-Org repackage is fp16-only and not recommended for bf16 training).
# Text encoders + image encoder come from the Comfy-Org repackaged repo.

echo "Starting HunyuanVideo 1.5 model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae
mkdir -p text_encoders
mkdir -p image_encoder

# Download diffusion model (T2V DiT, bf16)
echo "Downloading HunyuanVideo 1.5 720p T2V DiT..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=hunyuanvideo1.5_720p_t2v.safetensors \
  "https://huggingface.co/tencent/HunyuanVideo-1.5/resolve/main/transformer/720p_t2v/diffusion_pytorch_model.safetensors"

# Download diffusion model (I2V DiT, bf16) - only needed for --task i2v
echo "Downloading HunyuanVideo 1.5 720p I2V DiT..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=hunyuanvideo1.5_720p_i2v.safetensors \
  "https://huggingface.co/tencent/HunyuanVideo-1.5/resolve/main/transformer/720p_i2v/diffusion_pytorch_model.safetensors"

# Download VAE model (bf16)
echo "Downloading HunyuanVideo 1.5 VAE..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./vae \
  --out=hunyuanvideo15_vae.safetensors \
  "https://huggingface.co/tencent/HunyuanVideo-1.5/resolve/main/vae/diffusion_pytorch_model.safetensors"

# Download Qwen2.5-VL text encoder
echo "Downloading Qwen2.5-VL 7B text encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=qwen_2.5_vl_7b.safetensors \
  "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b.safetensors"

# Download ByT5 text encoder
echo "Downloading ByT5 small (glyph) text encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=byt5_small_glyphxl_fp16.safetensors \
  "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/text_encoders/byt5_small_glyphxl_fp16.safetensors"

# Download SigLIP image encoder (only needed for --task i2v)
echo "Downloading SigLIP image encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./image_encoder \
  --out=sigclip_vision_patch14_384.safetensors \
  "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/clip_vision/sigclip_vision_patch14_384.safetensors"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/hunyuanvideo1.5_720p_t2v.safetensors"
echo "  - diffusion_models/hunyuanvideo1.5_720p_i2v.safetensors"
echo "  - vae/hunyuanvideo15_vae.safetensors"
echo "  - text_encoders/qwen_2.5_vl_7b.safetensors"
echo "  - text_encoders/byt5_small_glyphxl_fp16.safetensors"
echo "  - image_encoder/sigclip_vision_patch14_384.safetensors"
