#!/bin/bash

# HunyuanVideo Model Download Script
# Downloads HunyuanVideo models using aria2c.
# DiT and VAE come from the official tencent repo (.pt); text encoders from the
# Comfy-Org repackaged repo (.safetensors).

echo "Starting HunyuanVideo model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae
mkdir -p text_encoders

# Download diffusion model (DiT, official .pt)
echo "Downloading HunyuanVideo DiT (mp_rank_00_model_states.pt)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=mp_rank_00_model_states.pt \
  "https://huggingface.co/tencent/HunyuanVideo/resolve/main/hunyuan-video-t2v-720p/transformers/mp_rank_00_model_states.pt"

# Download VAE model (official .pt)
echo "Downloading HunyuanVideo VAE (pytorch_model.pt)..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./vae \
  --out=pytorch_model.pt \
  "https://huggingface.co/tencent/HunyuanVideo/resolve/main/hunyuan-video-t2v-720p/vae/pytorch_model.pt"

# Download LLaVA-LLaMA3 text encoder (text_encoder1)
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

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/mp_rank_00_model_states.pt"
echo "  - vae/pytorch_model.pt"
echo "  - text_encoders/llava_llama3_fp16.safetensors"
echo "  - text_encoders/clip_l.safetensors"
