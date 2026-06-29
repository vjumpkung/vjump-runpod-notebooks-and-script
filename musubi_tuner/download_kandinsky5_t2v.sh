#!/bin/bash

# Kandinsky 5 (T2V Pro 5s) Model Download Script
# Downloads Kandinsky 5 DiT + VAE using aria2c.
# The text encoders (Qwen2.5-VL-7B-Instruct and CLIP ViT-L/14) are passed to the
# training scripts as HuggingFace model IDs and are auto-downloaded at runtime,
# so they are NOT fetched here.

echo "Starting Kandinsky 5 T2V model downloads..."

# Create directories for organized storage
mkdir -p diffusion_models
mkdir -p vae

# Download diffusion model (DiT) - Kandinsky 5 Pro T2V SFT 5s
echo "Downloading Kandinsky 5 Pro T2V SFT 5s DiT..."
aria2c \
  --continue=true \
  --max-connection-per-server=16 \
  --split=16 \
  --min-split-size=1M \
  --max-concurrent-downloads=1 \
  --file-allocation=none \
  --summary-interval=10 \
  --dir=./diffusion_models \
  --out=kandinsky5pro_t2v_sft_5s.safetensors \
  "https://huggingface.co/kandinskylab/Kandinsky-5.0-T2V-Pro-sft-5s/resolve/main/model/kandinsky5pro_t2v_sft_5s.safetensors"

# Download VAE model (HunyuanVideo 3D VAE)
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
  --out=hunyuan_video_vae.safetensors \
  "https://huggingface.co/hunyuanvideo-community/HunyuanVideo/resolve/main/vae/diffusion_pytorch_model.safetensors"

echo "All downloads completed!"
echo ""
echo "Files downloaded to:"
echo "  - diffusion_models/kandinsky5pro_t2v_sft_5s.safetensors"
echo "  - vae/hunyuan_video_vae.safetensors"
echo ""
echo "Note: text encoders are passed as HF model IDs to the training script:"
echo "      --text_encoder_qwen Qwen/Qwen2.5-VL-7B-Instruct"
echo "      --text_encoder_clip openai/clip-vit-large-patch14"
echo "      They download automatically on first use."
