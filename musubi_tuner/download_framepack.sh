#!/bin/bash

# FramePack (FramePackI2V_HY) Model Download Script
# Downloads FramePack models using aria2c
# DiT comes as 3 sharded safetensors; point --dit at the first shard during training.

echo "Starting FramePack model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae
mkdir -p text_encoders
mkdir -p image_encoder

# Download diffusion model (DiT) - sharded (3 files + index)
echo "Downloading FramePackI2V_HY DiT (shard 1/3)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=diffusion_pytorch_model-00001-of-00003.safetensors \
  "https://huggingface.co/lllyasviel/FramePackI2V_HY/resolve/main/diffusion_pytorch_model-00001-of-00003.safetensors"

echo "Downloading FramePackI2V_HY DiT (shard 2/3)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=diffusion_pytorch_model-00002-of-00003.safetensors \
  "https://huggingface.co/lllyasviel/FramePackI2V_HY/resolve/main/diffusion_pytorch_model-00002-of-00003.safetensors"

echo "Downloading FramePackI2V_HY DiT (shard 3/3)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=diffusion_pytorch_model-00003-of-00003.safetensors \
  "https://huggingface.co/lllyasviel/FramePackI2V_HY/resolve/main/diffusion_pytorch_model-00003-of-00003.safetensors"

echo "Downloading FramePackI2V_HY DiT (shard index)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=diffusion_pytorch_model.safetensors.index.json \
  "https://huggingface.co/lllyasviel/FramePackI2V_HY/resolve/main/diffusion_pytorch_model.safetensors.index.json"

# Download VAE model (HunyuanVideo VAE)
echo "Downloading HunyuanVideo VAE..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./vae \
  --out=hunyuan_video_vae_bf16.safetensors \
  "https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/vae/hunyuan_video_vae_bf16.safetensors"

# Download LLaMA text encoder (text_encoder1)
echo "Downloading LLaVA-LLaMA3 text encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=llava_llama3_fp16.safetensors \
  "https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/llava_llama3_fp16.safetensors"

# Download CLIP-L text encoder (text_encoder2)
echo "Downloading CLIP-L text encoder..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./text_encoders \
  --out=clip_l.safetensors \
  "https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/clip_l.safetensors"

# Download SigLIP image encoder
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
  "https://huggingface.co/Comfy-Org/sigclip_vision_384/resolve/main/sigclip_vision_patch14_384.safetensors"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/diffusion_pytorch_model-0000{1,2,3}-of-00003.safetensors (+ index)"
echo "  - vae/hunyuan_video_vae_bf16.safetensors"
echo "  - text_encoders/llava_llama3_fp16.safetensors"
echo "  - text_encoders/clip_l.safetensors"
echo "  - image_encoder/sigclip_vision_patch14_384.safetensors"
